import Foundation
import CoreLocation
import AVFoundation
import UIKit
import Capacitor

/* Atlas-GPS: zeichnet eine Cardio-Route nativ auf, auch bei gesperrtem
   Bildschirm. Die Web-Ansicht (WKWebView) schlaeft im Hintergrund, ihr
   navigator.geolocation liefert dann nichts mehr. CLLocationManager mit
   allowsBackgroundLocationUpdates laeuft weiter (UIBackgroundModes: location,
   Berechtigung "Beim Verwenden" reicht, weil die Aufnahme im Vordergrund
   startet). Jeder Fix bekommt eine laufende Nummer und bleibt im Puffer
   (auch auf der Platte), bis die Aufnahme endet. Die Web-App holt verpasste
   Fixes nach der Rueckkehr mit fixes({after}) ab und rechnet ALLES selbst
   (Strecke, Splits, Auswertung). Nativ laeuft nur die Live-Schicht:
   Strecke grob mitzaehlen, Auto-Pause (markiert jeden Fix mit "ap") und
   Kilometer-Ansage per Sprache, auch bei gesperrtem Bildschirm. */

// MARK: Puffer mit laufender Nummer, auf der Platte gespiegelt (JSON-Zeilen)
final class AtlasSeqBuf {
    private(set) var buf: [[String: Any]] = []
    private(set) var seq = 0
    private let url: URL
    private let cap: Int
    private var pending = Data()
    private var pendingN = 0
    private var lastFlush = Date()

    init(name: String, cap: Int) {
        let fm = FileManager.default
        let d = (fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fm.temporaryDirectory)
            .appendingPathComponent("AtlasLive", isDirectory: true)
        try? fm.createDirectory(at: d, withIntermediateDirectories: true,
                                attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication])
        url = d.appendingPathComponent(name)
        self.cap = cap
        load()
    }
    // Nach einem Neustart der App: was vor dem Beenden gesichert war, wieder einlesen
    private func load() {
        guard let d = try? Data(contentsOf: url), let s = String(data: d, encoding: .utf8) else { return }
        for line in s.split(separator: "\n") {
            guard let ld = line.data(using: .utf8),
                  let o = (try? JSONSerialization.jsonObject(with: ld)) as? [String: Any],
                  let n = (o["seq"] as? NSNumber)?.intValue, n > seq else { continue }
            buf.append(o); seq = n
        }
        if buf.count > cap { buf.removeFirst(buf.count - cap) }
    }
    /* urgent: sofort auf die Platte (App im Hintergrund — iOS kann sie
       jederzeit ohne Vorwarnung beenden). Sonst spaetestens alle 3 s oder
       10 Eintraege: ein Abbruch kostet hoechstens wenige Sekunden. */
    @discardableResult
    func append(_ f: [String: Any], urgent: Bool = false) -> [String: Any] {
        seq += 1
        var o = f; o["seq"] = seq
        buf.append(o)
        if buf.count > cap { buf.removeFirst(buf.count - cap) }
        if let d = try? JSONSerialization.data(withJSONObject: o) { pending.append(d); pending.append(0x0A); pendingN += 1 }
        if urgent || pendingN >= 10 || Date().timeIntervalSince(lastFlush) >= 3 { flush() }
        return o
    }
    func flush() {
        lastFlush = Date()
        guard !pending.isEmpty else { return }
        let fm = FileManager.default
        if !fm.fileExists(atPath: url.path) {
            fm.createFile(atPath: url.path, contents: nil,
                          attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication])
        }
        if let h = try? FileHandle(forWritingTo: url) { h.seekToEndOfFile(); h.write(pending); h.closeFile() }
        pending.removeAll(keepingCapacity: true); pendingN = 0
    }
    // Eintraege mit seq > after, hoechstens limit Stueck (aelteste zuerst)
    func after(_ n: Int, limit: Int) -> (items: [[String: Any]], more: Bool) {
        var out: [[String: Any]] = []
        var i = buf.count
        while i > 0, ((buf[i - 1]["seq"] as? Int) ?? 0) > n { i -= 1 }
        while i < buf.count && out.count < limit { out.append(buf[i]); i += 1 }
        return (out, i < buf.count)
    }
    var last: [String: Any]? { buf.last }
    func clear() {
        buf.removeAll(); seq = 0; pending.removeAll(); pendingN = 0
        try? FileManager.default.removeItem(at: url)
    }
}

// MARK: Live-Schicht einer Aufnahme (Parameter kommen aus der Web-App, gleiche Werte wie cxTrackStep/cxAutoPause)
struct AtlasLiveCfg {
    var q = 3.0, accMax = 35.0, vmax = 8.0, thrK = 1.0, thrMin = 5.0, thrMax = 25.0, spdMin = 5.0
    var stop = 0.6, stopF = 0.6, goF = 1.8, stopSec = 4.0, goSec = 2.0
    var autoPause = true, voice = true, cueKm = 1.0, bike = false
}

final class AtlasGeo: NSObject, CLLocationManagerDelegate, AVSpeechSynthesizerDelegate {
    static let shared = AtlasGeo()
    private let mgr = CLLocationManager()
    let fixBuf = AtlasSeqBuf(name: "geo.jsonl", cap: 43200)      // ~12 h bei 1 Hz
    private(set) var running = false
    var onFix: (([String: Any]) -> Void)?
    var onError: (([String: Any]) -> Void)?

    // Live-Schicht: nur aktiv zwischen session(on) und Ende
    private(set) var live = false
    private var cfg = AtlasLiveCfg()
    private var manualPaused = false, autoPaused = false, lo = 0.0, hi = 0.0
    private var lastFix: CLLocation?, rej = 0
    // Kalman-Lage (Grad, Varianz m^2) und Zaehlpunkt — wie cxKalman/cxTrackStep, damit die Ansage beim gleichen Meter kommt wie der gespeicherte Split
    private var kOn = false, kLat = 0.0, kLng = 0.0, kVar = 0.0, kT = 0.0
    private var hasAnchor = false, aLat = 0.0, aLng = 0.0
    private(set) var dist = 0.0
    private var movT = 0.0, lastKm = 0, lastSplitMovT = 0.0, startedAt = 0.0
    private(set) var pauses: [[Double]] = []                   // [von ms, bis ms] Auto-Pausen
    private(set) var cues: [[String: Any]] = []                // gesprochene Ansagen
    private let speech = AVSpeechSynthesizer()

    override init() {
        super.init()
        mgr.delegate = self
        mgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        mgr.distanceFilter = kCLDistanceFilterNone
        mgr.pausesLocationUpdatesAutomatically = false
        speech.delegate = self
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.fixBuf.flush()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { [weak self] _ in
            self?.fixBuf.flush()
        }
    }

    func authState() -> String {
        switch mgr.authorizationStatus {
        case .authorizedAlways: return "always"
        case .authorizedWhenInUse: return "whenInUse"
        case .denied: return "denied"
        case .restricted: return "restricted"
        default: return "notDetermined"
        }
    }

    private static var hasBgLocation: Bool {
        ((Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String]) ?? []).contains("location")
    }

    private var runStartedAt: Double {
        get { UserDefaults.standard.double(forKey: "atlasgeo.startedAt") }
        set { UserDefaults.standard.set(newValue, forKey: "atlasgeo.startedAt") } }

    func start(activity: String, keep: Bool) {
        if !keep { fixBuf.clear(); endLive() }
        if !keep || runStartedAt <= 0 { runStartedAt = Date().timeIntervalSince1970 }
        mgr.activityType = activity == "other" ? .other : (activity == "bike" ? .otherNavigation : .fitness)
        if authState() == "notDetermined" { mgr.requestWhenInUseAuthorization() }
        // Ohne den Hintergrundmodus wuerde iOS hier abstuerzen
        if AtlasGeo.hasBgLocation { mgr.allowsBackgroundLocationUpdates = true }
        mgr.showsBackgroundLocationIndicator = true
        mgr.startUpdatingLocation()
        running = true
    }

    func stop() {
        mgr.stopUpdatingLocation()
        if AtlasGeo.hasBgLocation { mgr.allowsBackgroundLocationUpdates = false }
        running = false
        fixBuf.flush()
        endLive()
    }

    func clear() { fixBuf.clear(); endLive(); if !running { runStartedAt = 0 } }

    // MARK: Live-Schicht
    func session(on: Bool, opts: [String: Any]) {
        if !on { endLive(); return }
        func d(_ k: String, _ v: Double) -> Double { (opts[k] as? NSNumber)?.doubleValue ?? v }
        func b(_ k: String, _ v: Bool) -> Bool { (opts[k] as? NSNumber)?.boolValue ?? v }
        var c = AtlasLiveCfg()
        c.q = d("q", c.q); c.accMax = d("accMax", c.accMax); c.vmax = d("vmax", c.vmax); c.thrK = d("thrK", c.thrK)
        c.thrMin = d("thrMin", c.thrMin); c.thrMax = d("thrMax", c.thrMax); c.spdMin = d("spdMin", c.spdMin)
        c.stop = d("stop", c.stop); c.stopF = d("stopF", c.stopF); c.goF = d("goF", c.goF)
        c.stopSec = d("stopSec", c.stopSec); c.goSec = d("goSec", c.goSec)
        c.autoPause = b("autoPause", c.autoPause); c.voice = b("voice", c.voice)
        c.cueKm = max(0.5, d("cueKm", c.cueKm)); c.bike = b("bike", c.bike)
        cfg = c
        // Fortsetzen nach Neustart: Stand der Web-App uebernehmen
        dist = d("dist", 0); movT = d("movT", 0); lastKm = Int(d("lastKm", 0)); lastSplitMovT = d("lastSplitMovT", 0)
        manualPaused = b("paused", false); autoPaused = false; lo = 0; hi = 0
        lastFix = nil; hasAnchor = false; kOn = false; rej = 0
        if !live { pauses = []; cues = []; startedAt = Date().timeIntervalSince1970 * 1000 }
        live = true
    }
    func configure(opts: [String: Any]) {
        if let v = opts["voice"] as? NSNumber { cfg.voice = v.boolValue }
        if let v = opts["autoPause"] as? NSNumber {
            cfg.autoPause = v.boolValue
            if !cfg.autoPause && autoPaused { setAuto(false, t: Date().timeIntervalSince1970 * 1000) }
        }
    }
    func setManualPause(_ on: Bool) {
        manualPaused = on
        hasAnchor = false; lo = 0; hi = 0
        if on && autoPaused { setAuto(false, t: Date().timeIntervalSince1970 * 1000) }
    }
    private func endLive() {
        live = false; lastFix = nil; hasAnchor = false; kOn = false
        if speech.isSpeaking { speech.stopSpeaking(at: .immediate) }
    }
    private func setAuto(_ on: Bool, t: Double) {
        if on == autoPaused { return }
        autoPaused = on
        if on { pauses.append([t, t]) }
        else if var p = pauses.last { p[1] = t; pauses[pauses.count - 1] = p }
        if pauses.count > 2000 { pauses.removeFirst(pauses.count - 2000) }
    }
    // Haversine wie _hav der Web-App (R = 6 371 000 m)
    static func hav(_ la1: Double, _ lo1: Double, _ la2: Double, _ lo2: Double) -> Double {
        let r = Double.pi / 180, dLa = (la2 - la1) * r, dLo = (lo2 - lo1) * r
        let x = pow(sin(dLa / 2), 2) + cos(la1 * r) * cos(la2 * r) * pow(sin(dLo / 2), 2)
        return 2 * 6371000 * asin(min(1, sqrt(x)))
    }

    // Ein Fix in der Live-Schicht: gleiche Regeln wie cxFixCheck/cxTrackStep/cxAutoPause (ohne Glaettung)
    private func liveStep(_ l: CLLocation) -> Bool? {
        guard live else { return nil }
        let acc = l.horizontalAccuracy
        if acc <= 0 || acc > cfg.accMax { return autoPaused }
        let t = l.timestamp.timeIntervalSince1970 * 1000
        var reanchor = false
        if let p = lastFix {
            let dt = l.timestamp.timeIntervalSince(p.timestamp)
            if dt <= 0 { return autoPaused }
            let dd = AtlasGeo.hav(p.coordinate.latitude, p.coordinate.longitude, l.coordinate.latitude, l.coordinate.longitude)
            if dd / dt > cfg.vmax * 1.5 && dd > max(25, acc) {
                if rej < 4 { rej += 1; return autoPaused }
                reanchor = true
            }
            // Auto-Pause mit Hysterese
            let v = l.speed >= 0 ? l.speed : dd / dt
            let step = min(max(dt, 0), 10)
            if cfg.autoPause && !manualPaused {
                if !autoPaused { lo = v < cfg.stop ? lo + step : 0; if lo >= cfg.stopSec { setAuto(true, t: t); lo = 0; hi = 0 } }
                else { hi = v > cfg.stop * cfg.goF ? hi + step : 0; if hi >= cfg.goSec { setAuto(false, t: t); hi = 0; lo = 0 } }
            }
            if !manualPaused && !autoPaused { movT += min(dt, 30) }
        }
        rej = 0
        // Kalman-Glaettung (neu verankert nach einem Dauersprung)
        let la = l.coordinate.latitude, lo2 = l.coordinate.longitude, a2 = max(acc, 1) * max(acc, 1)
        if reanchor || !kOn || t - kT > 30000 { kOn = true; kLat = la; kLng = lo2; kVar = a2 }   // > 30 s ohne Fix: neu beginnen
        else {
            let dtk = max(0, (t - kT) / 1000), v = kVar + dtk * cfg.q * cfg.q, K = v / (v + a2)
            kLat += K * (la - kLat); kLng += K * (lo2 - kLng); kVar = (1 - K) * v
        }
        kT = t
        let moving = !manualPaused && !autoPaused
        if hasAnchor && !reanchor && moving {
            let seg = AtlasGeo.hav(aLat, aLng, kLat, kLng)
            let thr = min(max(acc * cfg.thrK, cfg.thrMin), cfg.thrMax)
            let still = l.speed >= 0 && l.speed < cfg.stop * cfg.stopF
            if !still && (seg >= thr || (l.speed > 1 && seg >= cfg.spdMin)) { dist += seg; aLat = kLat; aLng = kLng }
        } else { hasAnchor = true; aLat = kLat; aLng = kLng }
        lastFix = l
        // Kilometer-Ansage
        let every = cfg.cueKm * 1000
        let k = Int(dist / every)
        if moving && k > lastKm {
            let split = (movT - lastSplitMovT) / (cfg.cueKm)
            lastKm = k; lastSplitMovT = movT
            let km = Double(k) * cfg.cueKm
            let hr = AtlasBand.shared.recentHr(maxAge: 15)
            cues.append(["km": km, "t": t, "sec": Int(split.rounded()), "hr": hr ?? 0])
            if cues.count > 500 { cues.removeFirst(cues.count - 500) }
            if cfg.voice { announce(km: km, secPerKm: split, hr: hr) }
        }
        return autoPaused
    }

    private func announce(km: Double, secPerKm: Double, hr: Int?) {
        let kmTxt = km == km.rounded() ? String(Int(km)) : String(format: "%.1f", km).replacingOccurrences(of: ".", with: ",")
        var s = "Kilometer \(kmTxt). "
        if cfg.bike, secPerKm > 0 {
            let kmh = 3600 / secPerKm
            s += String(format: "%.0f", kmh) + " Kilometer pro Stunde. "
        } else if secPerKm > 0 {
            let m = Int(secPerKm) / 60, sec = Int(secPerKm) % 60
            s += "Pace \(m) Minuten \(sec). "
        }
        if let h = hr { s += "Puls \(h)." }
        let a = AVAudioSession.sharedInstance()
        do {
            try a.setCategory(.playback, mode: .voicePrompt, options: [.duckOthers])
            try a.setActive(true)
        } catch { return }
        let u = AVSpeechUtterance(string: s)
        u.voice = AVSpeechSynthesisVoice(language: "de-DE")
        speech.speak(u)
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) { deactivateAudio() }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) { deactivateAudio() }
    private func deactivateAudio() {
        if speech.isSpeaking { return }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func liveState() -> [String: Any] {
        ["live": live, "dist": dist, "movT": movT, "autoPaused": autoPaused, "paused": manualPaused,
         "lastKm": lastKm, "pauses": pauses, "cues": cues, "startedAt": startedAt]
    }

    // MARK: CLLocationManagerDelegate (laeuft auf dem Haupt-Thread: Manager dort angelegt)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard running else { return }
        // Sicherheitsnetz: eine vergessene Aufnahme (Web-App nie zurueckgekehrt) endet nach 12 h
        if runStartedAt > 0 && Date().timeIntervalSince1970 - runStartedAt > 12 * 3600 { stop(); return }
        for l in locations {
            guard l.horizontalAccuracy >= 0 else { continue }
            var f: [String: Any] = [
                "t": l.timestamp.timeIntervalSince1970 * 1000,
                "lat": l.coordinate.latitude,
                "lng": l.coordinate.longitude,
                "acc": l.horizontalAccuracy
            ]
            if l.verticalAccuracy >= 0 { f["alt"] = l.altitude; f["vacc"] = l.verticalAccuracy }
            if l.speed >= 0 { f["spd"] = l.speed }
            if let ap = liveStep(l) { f["ap"] = ap ? 1 : 0 }
            let active = UIApplication.shared.applicationState == .active
            let o = fixBuf.append(f, urgent: !active)
            // Live nur an die sichtbare Web-App; im Hintergrund holt sie spaeter mit fixes() ab
            if active { onFix?(o) }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let code = (error as? CLError)?.code
        if code == .locationUnknown { return }          // kurz kein Signal: CoreLocation versucht es weiter
        onError?(["code": code == .denied ? 1 : 2, "message": error.localizedDescription])
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let st = authState()
        if st == "denied" || st == "restricted" { onError?(["code": 1, "message": st]) }
        else if running && (st == "whenInUse" || st == "always") { mgr.startUpdatingLocation() }
    }
}

// MARK: Bruecke zur Web-App (jsName "AtlasGeo")
@objc(AtlasGeoPlugin)
public class AtlasGeoPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "AtlasGeoPlugin"
    public let jsName = "AtlasGeo"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "start", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "stop", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "fixes", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "clear", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "status", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "session", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "pause", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "configure", returnType: CAPPluginReturnPromise),
    ]
    override public func load() {
        let setup = {
            let g = AtlasGeo.shared
            g.onFix = { [weak self] f in self?.notifyListeners("fix", data: f) }
            g.onError = { [weak self] e in self?.notifyListeners("error", data: e) }
        }
        if Thread.isMainThread { setup() } else { DispatchQueue.main.sync(execute: setup) }
    }
    @objc func start(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let g = AtlasGeo.shared
            g.start(activity: call.getString("activity") ?? "fitness", keep: call.getBool("keep") ?? false)
            call.resolve(["auth": g.authState(), "seq": g.fixBuf.seq])
        }
    }
    @objc func stop(_ call: CAPPluginCall) { DispatchQueue.main.async { AtlasGeo.shared.stop(); call.resolve() } }
    @objc func clear(_ call: CAPPluginCall) { DispatchQueue.main.async { AtlasGeo.shared.clear(); call.resolve() } }
    @objc func status(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let g = AtlasGeo.shared
            var o: [String: Any] = ["auth": g.authState(), "running": g.running, "seq": g.fixBuf.seq, "count": g.fixBuf.buf.count]
            o.merge(g.liveState()) { a, _ in a }
            call.resolve(o)
        }
    }
    @objc func fixes(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let g = AtlasGeo.shared
            let r = g.fixBuf.after(call.getInt("after") ?? 0, limit: max(100, min(call.getInt("limit") ?? 3000, 10000)))
            call.resolve(["fixes": r.items, "more": r.more, "seq": g.fixBuf.seq])
        }
    }
    @objc func session(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            AtlasGeo.shared.session(on: call.getBool("on") ?? true, opts: call.options as? [String: Any] ?? [:])
            call.resolve(AtlasGeo.shared.liveState())
        }
    }
    @objc func pause(_ call: CAPPluginCall) {
        DispatchQueue.main.async { AtlasGeo.shared.setManualPause(call.getBool("on") ?? true); call.resolve() }
    }
    @objc func configure(_ call: CAPPluginCall) {
        DispatchQueue.main.async { AtlasGeo.shared.configure(opts: call.options as? [String: Any] ?? [:]); call.resolve() }
    }
}

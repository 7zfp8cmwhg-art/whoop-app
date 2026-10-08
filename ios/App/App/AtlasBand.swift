import Foundation
import CoreBluetooth
import UIKit
import Capacitor

/* Atlas-Band: haelt die Verbindung zum WHOOP-Band nativ, auch im Hintergrund.
   Nur der Transport ist hier: verbinden, Historie abholen, quittieren, roh
   speichern. Ausgewertet wird wie bisher in der Web-App (WDayAgg ->
   wFinalizeDay). Protokoll 1:1 aus index.html (wbuildFrame, WFrameReassembler,
   wHandshake, wbuildBatchAck). Ablauf der Hintergrund-Abgleiche wie NOOP
   (BackfillPolicy, PolyForm Noncommercial, Copyright 2026 NoopApp): Abgleich
   bei Verbindung, bei Rueckkehr in die App und bei Band-Ereignissen,
   hoechstens alle 15 min; Wiederherstellung per CBCentralManager-Restore.
   Quittiert wird ein Block ERST, wenn er auf dem Speicher liegt. */

private let SVC4 = CBUUID(string: "61080001-8d6d-82b8-614a-1c8cb0f8dcc6")
private let SVC5 = CBUUID(string: "fd4b0001-cce1-4033-93ce-002d5875f58a")
private func roleUUID(_ gen: Int, _ n: Int) -> CBUUID {
    CBUUID(string: gen == 5 ? String(format: "fd4b%04x-cce1-4033-93ce-002d5875f58a", n)
                            : String(format: "6108%04x-8d6d-82b8-614a-1c8cb0f8dcc6", n))
}

// MARK: Protokoll (wie index.html)
enum WProto {
    static let SOF: UInt8 = 0xAA
    static let crc8T: [UInt8] = (0..<256).map { i -> UInt8 in
        var c = UInt8(i); for _ in 0..<8 { c = (c & 0x80) != 0 ? (c << 1) ^ 0x07 : (c << 1) }; return c }
    static let crc32T: [UInt32] = (0..<256).map { i -> UInt32 in
        var c = UInt32(i); for _ in 0..<8 { c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : (c >> 1) }; return c }
    static func crc8(_ b: [UInt8]) -> UInt8 { var c: UInt8 = 0; for x in b { c = crc8T[Int(c ^ x)] }; return c }
    static func crc32(_ b: [UInt8]) -> UInt32 {
        var c: UInt32 = 0xFFFFFFFF; for x in b { c = crc32T[Int((c ^ UInt32(x)) & 0xFF)] ^ (c >> 8) }; return c ^ 0xFFFFFFFF }
    static func crc16(_ b: [UInt8]) -> UInt16 {
        var c: UInt16 = 0xFFFF; for x in b { c ^= UInt16(x); for _ in 0..<8 { c = (c & 1) != 0 ? (c >> 1) ^ 0xA001 : (c >> 1) } }; return c }
    static func le16(_ v: Int) -> [UInt8] { [UInt8(v & 0xFF), UInt8((v >> 8) & 0xFF)] }
    static func le32(_ v: UInt32) -> [UInt8] { (0..<4).map { UInt8((v >> (8 * UInt32($0))) & 0xFF) } }
    static let forbidden: Set<UInt8> = [0x19, 0x1D, 0x9A, 0x20, 0x24, 0x25, 0x26, 0x2D, 0x53]

    static func frame(_ inner: [UInt8], gen: Int) -> [UInt8] {
        var ip = inner; while ip.count % 4 != 0 { ip.append(0) }
        let declared = ip.count + 4, tail = le32(crc32(ip))
        if gen == 4 { let len = le16(declared); return [SOF] + len + [crc8(len)] + ip + tail }
        var head: [UInt8] = [SOF, 0x01] + le16(declared) + [0x00, 0x01]
        head += le16(Int(crc16(head)))
        return head + ip + tail
    }
    static func command(seq: UInt8, op: UInt8, payload: [UInt8], gen: Int) -> [UInt8]? {
        if forbidden.contains(op) { return nil }
        return frame([0x23, seq, op] + payload, gen: gen)
    }
    static func batchAck(seq: UInt8, token: [UInt8], gen: Int) -> [UInt8] {
        frame([0x23, seq, 0x17, 0x01] + token, gen: gen)
    }
}

/* Laengenbasiert, nie auf 0xAA resynchronisieren (Sensorwerte enthalten 0xAA). */
final class WReassembler {
    let gen: Int; var buf: [UInt8] = []
    init(gen: Int) { self.gen = gen }
    private func resync() -> Bool {
        if let i = buf.dropFirst().firstIndex(of: WProto.SOF) { buf = Array(buf[i...]); return true }
        buf = []; return false
    }
    func feed(_ chunk: [UInt8]) -> [[UInt8]] {
        buf += chunk
        var out: [[UInt8]] = []
        let hl = gen == 4 ? 4 : 8
        while buf.count >= hl + 4 {
            if buf[0] != WProto.SOF { if !resync() { break }; continue }
            let declared: Int
            if gen == 4 { declared = Int(buf[1]) | Int(buf[2]) << 8 }
            else { if buf[1] != 0x01 { if !resync() { break }; continue }; declared = Int(buf[2]) | Int(buf[3]) << 8 }
            let total = hl + declared
            if declared < 4 || total > 4096 { if !resync() { break }; continue }
            if buf.count < total { break }
            let raw = Array(buf[0..<total]); buf = Array(buf[total...])
            let headOk = gen == 4 ? raw[3] == WProto.crc8(Array(raw[1..<3]))
                                  : (Int(raw[6]) | Int(raw[7]) << 8) == Int(WProto.crc16(Array(raw[0..<6])))
            let inner = Array(raw[hl..<(total - 4)])
            let want = UInt32(raw[total-4]) | UInt32(raw[total-3]) << 8 | UInt32(raw[total-2]) << 16 | UInt32(raw[total-1]) << 24
            if headOk && WProto.crc32(inner) == want { out.append(inner) }
        }
        return out
    }
}

// MARK: Verbindung + Abgleich
final class AtlasBand: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = AtlasBand()
    static let restoreID = "atlas.band.central"
    var onEvent: ((String, [String: Any]) -> Void)?

    private var central: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var ch: [Int: CBCharacteristic] = [:]          // 2 cmdTo, 3 cmdFrom, 4 events, 5 data
    private var notifyOn = 0
    private(set) var gen = 4
    private var reasm = WReassembler(gen: 4)
    private(set) var connected = false, ready = false, draining = false
    private var needHello = true, capped = false, scanning = false
    private var seq: UInt8 = 0, lseq: UInt8 = 0x9F
    private var lastData = Date(), drainStart = Date(), lastLink = Date.distantPast, lastRt = Date.distantPast
    private var drainRecords = 0, drainBatches = 0
    private var buf = Data()
    private var seg: FileHandle?, segURL: URL?, segBytes = 0
    private var bgTask: UIBackgroundTaskIdentifier = .invalid
    private var tick: Timer?
    private var liveWanted = false, liveOn = false, optical = false, r10 = false
    private var logLines: [String] = []
    private let ud = UserDefaults.standard

    private var deviceId: String? { get { ud.string(forKey: "atlasband.id") } set { ud.set(newValue, forKey: "atlasband.id") } }
    private var lastDrainAt: Double { get { ud.double(forKey: "atlasband.lastDrain") } set { ud.set(newValue, forKey: "atlasband.lastDrain") } }
    private var appActive: Bool { UIApplication.shared.applicationState == .active }

    static let dir: URL = {
        let d = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("atlasband", isDirectory: true)
        try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        var u = d; var rv = URLResourceValues(); rv.isExcludedFromBackup = true; try? u.setResourceValues(rv)
        // Lesbar nach dem ersten Entsperren — noetig fuer das Speichern im Hintergrund bei gesperrtem Handy
        try? FileManager.default.setAttributes([.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication], ofItemAtPath: d.path)
        return d
    }()

    func start() {
        if central != nil { return }
        central = CBCentralManager(delegate: self, queue: .main,
                                   options: [CBCentralManagerOptionRestoreIdentifierKey: AtlasBand.restoreID,
                                             CBCentralManagerOptionShowPowerAlertKey: true])
        let nc = NotificationCenter.default
        nc.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            guard let s = self else { return }
            s.connectKnown(); s.requestDrain("foreground"); if s.liveWanted { s.setLive(true) }
        }
        nc.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            guard let s = self else { return }
            if s.liveOn { s.liveStreams(false) }      // Live-Puls nur bei offener App (Akku)
            s.flush()
        }
        tick = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.onTick() }
    }

    func log(_ m: String) {
        let f = DateFormatter(); f.dateFormat = "dd.MM. HH:mm:ss"
        logLines.append(f.string(from: Date()) + " " + m); if logLines.count > 200 { logLines.removeFirst(logLines.count - 200) }
        onEvent?("log", ["m": m])
    }
    private func emitState() { onEvent?("state", status()) }

    func status() -> [String: Any] {
        ["connected": connected, "ready": ready, "draining": draining, "gen": gen,
         "deviceId": deviceId ?? "", "lastDrainAt": lastDrainAt * 1000, "drainRecords": drainRecords,
         "segments": closedSegments().count, "live": liveOn, "log": Array(logLines.suffix(40))]
    }

    // MARK: Geraet
    func configure(id: String?) {
        if let id = id, !id.isEmpty, id != deviceId { deviceId = id; peripheral = nil }
        connectKnown()
    }
    func pair() { guard let c = central, c.state == .poweredOn else { return }
        scanning = true; c.scanForPeripherals(withServices: [SVC4, SVC5], options: nil); log("suche Band")
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            guard let s = self, s.scanning else { return }; s.scanning = false; s.central?.stopScan(); s.log("kein Band gefunden") }
    }
    func forget() {
        if let p = peripheral { central?.cancelPeripheralConnection(p) }
        peripheral = nil; deviceId = nil; connected = false; ready = false; emitState()
    }
    private func connectKnown() {
        guard let c = central, c.state == .poweredOn else { return }
        if let p = peripheral { if p.state == .disconnected { c.connect(p, options: nil) }; return }
        if let s = deviceId, let u = UUID(uuidString: s), let p = c.retrievePeripherals(withIdentifiers: [u]).first {
            adopt(p); c.connect(p, options: nil); log("verbinde (wartet, bis das Band in der Naehe ist)"); return }
        /* Automatisch, aber SICHER: nur ein Band, das iOS schon mit DIESEM iPhone
           verbunden hat (gekoppelt in den Bluetooth-Einstellungen). Nie ein
           fremdes Band in der Naehe per Suche uebernehmen. */
        if let p = c.retrieveConnectedPeripherals(withServices: [SVC4, SVC5]).first {
            deviceId = p.identifier.uuidString; adopt(p); c.connect(p, options: nil)
            log("gekoppeltes Band uebernommen: \(p.name ?? "WHOOP")")
            onEvent?("paired", ["id": p.identifier.uuidString, "name": p.name ?? "WHOOP"]) }
    }
    private func adopt(_ p: CBPeripheral) { peripheral = p; p.delegate = self }

    func centralManagerDidUpdateState(_ c: CBCentralManager) {
        log("Bluetooth: \(c.state.rawValue)")
        if c.state == .poweredOn {
            if let p = peripheral, p.state == .connected { didConnectSetup(p) } else { connectKnown() }
        } else { connected = false; ready = false; emitState() }
    }
    func centralManager(_ c: CBCentralManager, willRestoreState dict: [String: Any]) {
        let ps = (dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral]) ?? []
        if let p = ps.first(where: { $0.identifier.uuidString == deviceId }) ?? ps.first {
            adopt(p); log("vom System wiederhergestellt") }
    }
    func centralManager(_ c: CBCentralManager, didDiscover p: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        guard scanning else { return }
        scanning = false; c.stopScan(); deviceId = p.identifier.uuidString; adopt(p); c.connect(p, options: nil)
        log("Band gefunden: \(p.name ?? "WHOOP")"); onEvent?("paired", ["id": p.identifier.uuidString, "name": p.name ?? "WHOOP"])
    }
    func centralManager(_ c: CBCentralManager, didConnect p: CBPeripheral) { log("verbunden"); didConnectSetup(p) }
    private func didConnectSetup(_ p: CBPeripheral) {
        adopt(p); connected = true; ready = false; needHello = true; notifyOn = 0; ch = [:]
        p.discoverServices([SVC4, SVC5]); emitState()
    }
    func centralManager(_ c: CBCentralManager, didFailToConnect p: CBPeripheral, error: Error?) {
        log("Verbindung fehlgeschlagen"); c.connect(p, options: nil)
    }
    func centralManager(_ c: CBCentralManager, didDisconnectPeripheral p: CBPeripheral, error: Error?) {
        log("getrennt"); connected = false; ready = false; liveOn = false
        if draining { endDrain(sendAbort: false) }
        emitState()
        if deviceId != nil { c.connect(p, options: nil) }   // wartet ohne Zeitlimit, bis das Band zurueck ist
    }
    func peripheral(_ p: CBPeripheral, didDiscoverServices error: Error?) {
        guard let s = p.services?.first(where: { $0.uuid == SVC4 || $0.uuid == SVC5 }) else { log("kein WHOOP-Dienst"); return }
        gen = s.uuid == SVC5 ? 5 : 4; reasm = WReassembler(gen: gen)
        p.discoverCharacteristics((2...5).map { roleUUID(gen, $0) }, for: s)
    }
    func peripheral(_ p: CBPeripheral, didDiscoverCharacteristicsFor s: CBService, error: Error?) {
        for c in s.characteristics ?? [] { for n in 2...5 where c.uuid == roleUUID(gen, n) { ch[n] = c } }
        for n in [5, 3, 4] { if let c = ch[n] { p.setNotifyValue(true, for: c) } }
    }
    func peripheral(_ p: CBPeripheral, didUpdateNotificationStateFor c: CBCharacteristic, error: Error?) {
        if let e = error { log("Abo fehlgeschlagen: \(e.localizedDescription)"); return }
        notifyOn += 1
        if notifyOn >= 3 && !ready { ready = true; log("bereit (Gen \(gen))"); emitState()
            requestDrain("connect"); if liveWanted && appActive { setLive(true) } }
    }
    func peripheral(_ p: CBPeripheral, didUpdateValueFor c: CBCharacteristic, error: Error?) {
        guard let v = c.value else { return }
        handle([UInt8](v))
    }

    // MARK: Schreiben
    private func write(_ bytes: [UInt8]?) {
        guard let b = bytes, let p = peripheral, let c = ch[2], p.state == .connected else { return }
        let t: CBCharacteristicWriteType = c.properties.contains(.write) ? .withResponse : .withoutResponse
        p.writeValue(Data(b), for: c, type: t)
    }
    private func nextSeq() -> UInt8 { seq = seq &+ 1; return seq }
    private func send(_ op: UInt8, _ pl: [UInt8]) { write(WProto.command(seq: nextSeq(), op: op, payload: pl, gen: gen)) }
    private func sendLive(_ op: UInt8, _ pl: [UInt8]) {
        lseq = lseq &+ 1; if lseq < 0xA0 { lseq = 0xA0 }
        write(WProto.command(seq: lseq, op: op, payload: pl, gen: gen))
    }

    // MARK: Empfang
    private func handle(_ bytes: [UInt8]) {
        if draining { lastData = Date() }
        if ready && Date().timeIntervalSince(lastLink) > 10 { lastLink = Date(); sendLive(0x01, [0]) }  // LINK_VALID
        for inner in reasm.feed(bytes) {
            guard inner.count >= 1 else { continue }
            switch inner[0] {
            case 0x2F:   // Historie
                if draining { buf += WProto.le16(inner.count); buf += inner; drainRecords += 1
                    if drainRecords % 2000 == 0 { onEvent?("progress", ["records": drainRecords]) } }
            case 0x31:   // Metadaten
                guard inner.count >= 3, draining else { break }
                if inner[2] == 2 && inner.count >= 21 {
                    drainBatches += 1; flush()                       // erst sichern ...
                    write(WProto.batchAck(seq: nextSeq(), token: Array(inner[13..<21]), gen: gen))   // ... dann quittieren
                } else if inner[2] == 3 { endDrain(sendAbort: false) }
            case 0x28, 0x2B:
                lastRt = Date()
                if appActive { onEvent?("rt", ["hex": inner.map { String(format: "%02x", $0) }.joined()]) }
            case 0x30:
                if inner.count > 2 && inner[2] == 13 { onEvent?("rtcLost", [:]) }
                requestDrain("event")
            default: break
            }
        }
    }

    // MARK: Abgleich
    func requestDrain(_ reason: String) {
        guard ready, !draining else { return }
        let el = Date().timeIntervalSince1970 - lastDrainAt
        let floor: Double = reason == "event" ? 900 : (reason == "manual" || reason == "continue") ? 0 : 90
        if el < floor { return }
        draining = true; capped = false; drainStart = Date(); lastData = Date(); drainRecords = 0; drainBatches = 0
        if bgTask == .invalid { bgTask = UIApplication.shared.beginBackgroundTask(withName: "atlas.drain") { [weak self] in self?.endBg() } }
        log("Abgleich (\(reason))"); emitState()
        if liveOn { sendLive(0x03, [0]) }
        var cmds: [(UInt8, [UInt8])]
        if needHello {
            needHello = false
            cmds = gen == 5 ? [(0x91, [0x01]), (0x22, []), (0x16, [])]
                            : [(0x23, [0x00]), (0x4C, [0x00]), (0x22, [0x00]), (0x43, [0x01]), (0x16, [0x00])]
            seq = gen == 5 ? 0 : 0xFF          // erste Nummer: Gen4 0, Gen5 1 (wie der echte Mitschnitt)
        } else {
            cmds = gen == 5 ? [(0x22, []), (0x16, [])] : [(0x22, [0x00]), (0x16, [0x00])]
        }
        for (i, c) in cmds.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14 * Double(i)) { [weak self] in self?.send(c.0, c.1) }
        }
    }
    private var lastAdoptTry = Date.distantPast
    private func onTick() {
        if peripheral == nil && Date().timeIntervalSince(lastAdoptTry) > 30 { lastAdoptTry = Date(); connectKnown() }
        if draining {
            if Date().timeIntervalSince(lastData) > 9 { endDrain(sendAbort: true) }
            else if Date().timeIntervalSince(drainStart) > 900 { capped = true; endDrain(sendAbort: true) }
            else if buf.count > 0 && Date().timeIntervalSince(lastData) > 2 { flush() }
        }
        if ready && Date().timeIntervalSince(lastLink) > 10 { lastLink = Date(); sendLive(0x01, [0]) }
        if liveOn && !optical && Date().timeIntervalSince(lastRt) > 10 && Date().timeIntervalSince(liveSince) > 10 { optical = true; sendLive(0x6B, [1, 1]) }
        if liveOn && !r10 && Date().timeIntervalSince(lastRt) > 10 && Date().timeIntervalSince(liveSince) > 20 { r10 = true; sendLive(0x3F, [1]) }
    }
    private func endDrain(sendAbort: Bool) {
        if sendAbort { send(0x14, [0]) }
        flush(); closeSegment()
        draining = false; lastDrainAt = Date().timeIntervalSince1970
        log("Abgleich fertig: \(drainRecords) Messungen, \(drainBatches) Bloecke")
        onEvent?("drained", ["records": drainRecords]); emitState()
        if liveWanted && appActive && ready { liveStreams(true) }
        if capped && ready { DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.requestDrain("continue") } }
        else { endBg() }
    }
    private func endBg() { if bgTask != .invalid { UIApplication.shared.endBackgroundTask(bgTask); bgTask = .invalid } }

    // MARK: Live-Puls (nur bei offener App)
    private var liveSince = Date()
    func setLive(_ on: Bool) {
        liveWanted = on
        guard ready else { return }
        if on && appActive { liveSince = Date(); if !draining { liveStreams(true) } }
        else if !on { liveStreams(false) }
    }
    private func liveStreams(_ on: Bool) {
        sendLive(0x03, [on ? 1 : 0])
        if r10 { sendLive(0x3F, [on ? 1 : 0]) }
        if !on && optical { sendLive(0x6B, [1, 0]); optical = false; r10 = false }
        liveOn = on
    }

    // MARK: Speicher: Segmente [u16 Laenge][Rahmen-Inhalt]...
    private func flush() {
        guard buf.count > 0 else { return }
        if seg == nil {
            let u = AtlasBand.dir.appendingPathComponent(String(format: "open-%.0f.bin", Date().timeIntervalSince1970 * 1000))
            FileManager.default.createFile(atPath: u.path, contents: nil)
            seg = try? FileHandle(forWritingTo: u); segURL = u; segBytes = 0
        }
        guard let h = seg else { return }
        h.seekToEndOfFile(); h.write(buf); h.synchronizeFile()
        segBytes += buf.count; buf.removeAll(keepingCapacity: true)
        if segBytes > 2_000_000 { closeSegment() }
    }
    private func closeSegment() {
        guard let h = seg, let u = segURL else { return }
        h.closeFile(); seg = nil; segURL = nil
        let dst = AtlasBand.dir.appendingPathComponent(u.lastPathComponent.replacingOccurrences(of: "open-", with: "seg-"))
        try? FileManager.default.moveItem(at: u, to: dst)
    }
    func closedSegments() -> [URL] {
        let fs = (try? FileManager.default.contentsOfDirectory(at: AtlasBand.dir, includingPropertiesForKeys: nil)) ?? []
        return fs.filter { $0.lastPathComponent.hasPrefix("seg-") }.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
    /* Nach einem Absturz liegen evtl. offene Segmente: beim Start abschliessen. */
    func recoverOpen() {
        let fs = (try? FileManager.default.contentsOfDirectory(at: AtlasBand.dir, includingPropertiesForKeys: nil)) ?? []
        for u in fs where u.lastPathComponent.hasPrefix("open-") && u != segURL {
            try? FileManager.default.moveItem(at: u, to: AtlasBand.dir.appendingPathComponent(u.lastPathComponent.replacingOccurrences(of: "open-", with: "seg-")))
        }
    }
    func takeSegment() -> (String, Data)? {
        if closedSegments().isEmpty && !draining { flush(); closeSegment() }
        guard let u = closedSegments().first, let d = try? Data(contentsOf: u) else { return nil }
        return (u.lastPathComponent, d)
    }
    func commit(_ name: String) {
        guard name.hasPrefix("seg-"), !name.contains("/") else { return }
        try? FileManager.default.removeItem(at: AtlasBand.dir.appendingPathComponent(name))
    }
}

// MARK: Bruecke zur Web-App
@objc(AtlasBandPlugin)
public class AtlasBandPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "AtlasBandPlugin"
    public let jsName = "AtlasBand"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "configure", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "pair", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "forget", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "status", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "syncNow", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setLive", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "read", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "commit", returnType: CAPPluginReturnPromise),
    ]
    override public func load() {
        let b = AtlasBand.shared
        b.onEvent = { [weak self] name, data in self?.notifyListeners(name, data: data) }
        b.start()
    }
    @objc func configure(_ call: CAPPluginCall) {
        DispatchQueue.main.async { AtlasBand.shared.configure(id: call.getString("deviceId")); call.resolve(AtlasBand.shared.status()) } }
    @objc func pair(_ call: CAPPluginCall) { DispatchQueue.main.async { AtlasBand.shared.pair(); call.resolve() } }
    @objc func forget(_ call: CAPPluginCall) { DispatchQueue.main.async { AtlasBand.shared.forget(); call.resolve() } }
    @objc func status(_ call: CAPPluginCall) { DispatchQueue.main.async { call.resolve(AtlasBand.shared.status()) } }
    @objc func syncNow(_ call: CAPPluginCall) { DispatchQueue.main.async { AtlasBand.shared.requestDrain("manual"); call.resolve(AtlasBand.shared.status()) } }
    @objc func setLive(_ call: CAPPluginCall) { DispatchQueue.main.async { AtlasBand.shared.setLive(call.getBool("on") ?? false); call.resolve() } }
    @objc func read(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            guard let r = AtlasBand.shared.takeSegment() else { call.resolve([:]); return }
            call.resolve(["name": r.0, "b64": r.1.base64EncodedString(), "gen": AtlasBand.shared.gen])
        }
    }
    @objc func commit(_ call: CAPPluginCall) {
        DispatchQueue.main.async { AtlasBand.shared.commit(call.getString("name") ?? ""); call.resolve() } }
}

/* Registriert das Plugin in der Bruecke (lokale Plugins im App-Ziel). */
class AtlasViewController: CAPBridgeViewController {
    override open func capacitorDidLoad() { bridge?.registerPluginInstance(AtlasBandPlugin()) }
}

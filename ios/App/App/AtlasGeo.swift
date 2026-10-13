import Foundation
import CoreLocation
import Capacitor

/* Atlas-GPS: zeichnet eine Cardio-Route nativ auf, auch bei gesperrtem
   Bildschirm. Die Web-Ansicht (WKWebView) schlaeft im Hintergrund, ihr
   navigator.geolocation liefert dann nichts mehr. CLLocationManager mit
   allowsBackgroundLocationUpdates laeuft weiter (UIBackgroundModes: location,
   Berechtigung "Beim Verwenden" reicht, weil die Aufnahme im Vordergrund
   startet). Jeder Fix bekommt eine laufende Nummer und bleibt im Puffer,
   bis die Aufnahme endet. Die Web-App holt verpasste Fixes nach der
   Rueckkehr mit fixes({after}) ab. Ausgewertet wird nur in der Web-App. */
final class AtlasGeo: NSObject, CLLocationManagerDelegate {
    static let shared = AtlasGeo()
    private let mgr = CLLocationManager()
    private(set) var buf: [[String: Any]] = []
    private(set) var seq = 0
    private(set) var running = false
    var onFix: (([String: Any]) -> Void)?
    var onError: (([String: Any]) -> Void)?

    override init() {
        super.init()
        mgr.delegate = self
        mgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        mgr.distanceFilter = kCLDistanceFilterNone
        mgr.pausesLocationUpdatesAutomatically = false
    }

    func authState() -> String {
        let s: CLAuthorizationStatus
        if #available(iOS 14.0, *) { s = mgr.authorizationStatus } else { s = CLLocationManager.authorizationStatus() }
        switch s {
        case .authorizedAlways: return "always"
        case .authorizedWhenInUse: return "whenInUse"
        case .denied: return "denied"
        case .restricted: return "restricted"
        default: return "notDetermined"
        }
    }

    func start(activity: String, keep: Bool) {
        if !keep { buf.removeAll(); seq = 0 }
        switch activity {
        case "bike": mgr.activityType = .otherNavigation
        case "other": mgr.activityType = .other
        default: mgr.activityType = .fitness
        }
        let st = authState()
        if st == "notDetermined" { mgr.requestWhenInUseAuthorization() }
        mgr.allowsBackgroundLocationUpdates = true
        if #available(iOS 11.0, *) { mgr.showsBackgroundLocationIndicator = true }
        mgr.startUpdatingLocation()
        running = true
    }

    func stop() {
        mgr.stopUpdatingLocation()
        mgr.allowsBackgroundLocationUpdates = false
        running = false
    }

    func clear() { buf.removeAll(); seq = 0 }

    func fixes(after: Int) -> [[String: Any]] { buf.filter { ($0["seq"] as? Int ?? 0) > after } }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for l in locations {
            guard l.horizontalAccuracy >= 0 else { continue }
            seq += 1
            var f: [String: Any] = [
                "seq": seq,
                "t": l.timestamp.timeIntervalSince1970 * 1000,
                "lat": l.coordinate.latitude,
                "lng": l.coordinate.longitude,
                "acc": l.horizontalAccuracy
            ]
            if l.verticalAccuracy >= 0 { f["alt"] = l.altitude; f["vacc"] = l.verticalAccuracy }
            if l.speed >= 0 { f["spd"] = l.speed }
            buf.append(f)
            // Obergrenze: ~10 h bei 1 Hz. Aelteres geht verloren, die Web-App hat es dann schon.
            if buf.count > 36000 { buf.removeFirst(buf.count - 36000) }
            onFix?(f)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let denied = (error as? CLError)?.code == .denied
        onError?(["code": denied ? 1 : 2, "message": error.localizedDescription])
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if authState() == "denied" { onError?(["code": 1, "message": "denied"]) }
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
    ]
    override public func load() {
        let g = AtlasGeo.shared
        g.onFix = { [weak self] f in self?.notifyListeners("fix", data: f) }
        g.onError = { [weak self] e in self?.notifyListeners("error", data: e) }
    }
    @objc func start(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            AtlasGeo.shared.start(activity: call.getString("activity") ?? "fitness", keep: call.getBool("keep") ?? false)
            call.resolve(["auth": AtlasGeo.shared.authState(), "seq": AtlasGeo.shared.seq])
        }
    }
    @objc func stop(_ call: CAPPluginCall) { DispatchQueue.main.async { AtlasGeo.shared.stop(); call.resolve() } }
    @objc func clear(_ call: CAPPluginCall) { DispatchQueue.main.async { AtlasGeo.shared.clear(); call.resolve() } }
    @objc func status(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let g = AtlasGeo.shared
            call.resolve(["auth": g.authState(), "running": g.running, "seq": g.seq, "count": g.buf.count])
        }
    }
    @objc func fixes(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let after = call.getInt("after") ?? 0
            call.resolve(["fixes": AtlasGeo.shared.fixes(after: after), "seq": AtlasGeo.shared.seq])
        }
    }
}

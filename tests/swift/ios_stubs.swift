import Foundation
struct UIBackgroundTaskIdentifier: Equatable { let v: Int; static let invalid = UIBackgroundTaskIdentifier(v: 0) }
final class UIApplication {
  enum State { case active, inactive, background }
  static let shared = UIApplication()
  var applicationState: State { .active }
  static let didBecomeActiveNotification = Notification.Name("a"), didEnterBackgroundNotification = Notification.Name("b")
  func beginBackgroundTask(withName: String?, expirationHandler: (() -> Void)?) -> UIBackgroundTaskIdentifier { UIBackgroundTaskIdentifier(v: 1) }
  func endBackgroundTask(_ id: UIBackgroundTaskIdentifier) {}
}

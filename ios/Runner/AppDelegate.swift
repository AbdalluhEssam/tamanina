import BackgroundTasks
import Flutter
import UIKit
import UserNotifications
import WidgetKit
import app_links

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var widgetChannel: FlutterMethodChannel?
  private var prayerQueueChannel: FlutterMethodChannel?
  private let widgetLinks = WidgetSceneLinks()
  private let prayerQueue = OfflinePrayerQueue()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    prayerQueue.register()
    excludeDownloadsFromBackup()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func excludeDownloadsFromBackup() {
    let files = FileManager.default
    guard let support = try? files.url(
      for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true
    ) else { return }

    var resources = URLResourceValues()
    resources.isExcludedFromBackup = true
    for folder in ["assistant", "recitation_alafasy"] {
      var directory = support.appendingPathComponent(folder, isDirectory: true)
      do {
        try files.createDirectory(at: directory, withIntermediateDirectories: true)
        try directory.setResourceValues(resources)
      } catch {
        NSLog("Could not exclude %@ downloads from backup", folder)
      }
    }
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TamaninaOfflinePrayerQueue") {
      let channel = FlutterMethodChannel(
        name: "com.abdalluh.tamanina/prayer_queue",
        binaryMessenger: registrar.messenger()
      )
      prayerQueueChannel = channel
      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "replace" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard let payload = call.arguments as? String, let queue = self?.prayerQueue,
              queue.replace(payload) else {
          result(FlutterError(code: "invalid_prayer_queue", message: "Invalid prayer queue", details: nil))
          return
        }
        result(nil)
      }
    }
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TamaninaHomeWidgets") else { return }
    registrar.addSceneDelegate(widgetLinks)
    let channel = FlutterMethodChannel(
      name: "com.abdalluh.tamanina/home_widgets",
      binaryMessenger: registrar.messenger()
    )
    widgetChannel = channel
    channel.setMethodCallHandler { call, result in
      let group = "group.com.abdalluh.tamanina"
      if call.method == "publishTasbeeh" {
        guard let count = call.arguments as? Int else {
          result(FlutterError(code: "invalid_count", message: "Tasbeeh count must be an integer", details: nil))
          return
        }
        let defaults = UserDefaults(suiteName: group) ?? .standard
        let value = min(33, max(0, count))
        if defaults.integer(forKey: "worship_widget_tasbeeh") != value {
          defaults.set(value, forKey: "worship_widget_tasbeeh")
          WidgetCenter.shared.reloadTimelines(ofKind: "TamaninaTasbeeh")
        }
        result(nil)
        return
      }
      guard call.method == "publish" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let payload = call.arguments as? String else {
        result(FlutterError(code: "invalid_payload", message: "Widget payload must be a JSON string", details: nil))
        return
      }
      if let defaults = UserDefaults(suiteName: group) {
        defaults.set(payload, forKey: "worship_widget_snapshot")
      }
      UserDefaults.standard.set(payload, forKey: "worship_widget_snapshot")
      WidgetCenter.shared.reloadAllTimelines()
      result(nil)
    }
  }
}

// The Flutter calculator prepares the next month locally. iOS can top up the
// pending notifications from that plan whenever it grants a background refresh.
@MainActor private final class OfflinePrayerQueue {
  private struct Alert: Decodable {
    let id: Int
    let at: Int64
    let title: String
    let route: String
    let sound: Bool
    let adhan: Bool

    var date: Date { Date(timeIntervalSince1970: Double(at) / 1000) }
  }

  private let taskId = "com.abdalluh.tamanina.prayer-refresh"
  private let queueKey = "tamanina_offline_prayer_queue"
  private var revision = 0
  private var checkingRequest = false

  func register() {
    BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId, using: nil) { [weak self] task in
      Task { @MainActor in
        guard let self else { task.setTaskCompleted(success: false); return }
        self.run(task)
      }
    }
  }

  func replace(_ payload: String) -> Bool {
    let data = Data(payload.utf8)
    guard let alerts = try? JSONDecoder().decode([Alert].self, from: data) else { return false }
    revision += 1
    UserDefaults.standard.set(data, forKey: queueKey)
    if alerts.contains(where: { $0.date > Date() }) {
      requestRefresh()
    } else {
      BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskId)
    }
    return true
  }

  private func remaining() -> [Alert] {
    guard let data = UserDefaults.standard.data(forKey: queueKey),
          let alerts = try? JSONDecoder().decode([Alert].self, from: data) else { return [] }
    let now = Date()
    return alerts.filter { $0.date > now }.sorted { $0.at < $1.at }
  }

  private func requestRefresh() {
    guard !checkingRequest, !remaining().isEmpty else { return }
    checkingRequest = true
    BGTaskScheduler.shared.getPendingTaskRequests { [weak self] requests in
      Task { @MainActor in
        guard let self else { return }
        self.checkingRequest = false
        guard !self.remaining().isEmpty,
              !requests.contains(where: { $0.identifier == self.taskId }) else { return }
        let request = BGAppRefreshTaskRequest(identifier: self.taskId)
        request.earliestBeginDate = Date().addingTimeInterval(18 * 60 * 60)
        try? BGTaskScheduler.shared.submit(request)
      }
    }
  }

  private func run(_ task: BGTask) {
    let work = Task { @MainActor in
      let done = await refill()
      task.setTaskCompleted(success: done && !Task.isCancelled)
      requestRefresh()
    }
    task.expirationHandler = { work.cancel() }
  }

  private func refill() async -> Bool {
    let token = revision
    let center = UNUserNotificationCenter.current()
    let settings = await center.notificationSettings()
    guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
      return true
    }
    let pending = await center.pendingNotificationRequests()
    guard token == revision && !Task.isCancelled else { return false }
    let slots = max(0, 64 - pending.filter { !isPrayer($0.identifier) }.count)
    let desired = remaining().prefix(slots)
    let desiredIds = Set(desired.map { String($0.id) })
    let existingIds = Set(pending.map(\.identifier))
    let obsolete = existingIds.filter { isPrayer($0) && !desiredIds.contains($0) }
    if !obsolete.isEmpty { center.removePendingNotificationRequests(withIdentifiers: Array(obsolete)) }

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    for alert in desired where !existingIds.contains(String(alert.id)) {
      guard token == revision && !Task.isCancelled else { return false }
      if alert.date <= Date() { continue }
      let content = UNMutableNotificationContent()
      content.title = alert.title
      if alert.sound {
        content.sound = alert.adhan ? UNNotificationSound(named: UNNotificationSoundName("adhan_alert.caf")) : .default
      }
      // Match flutter_local_notifications' userInfo for notification taps and foreground presentation.
      content.userInfo = [
        "NotificationId": alert.id, "payload": alert.route,
        "presentAlert": true, "presentSound": alert.sound, "presentBadge": false,
        "presentBanner": true, "presentList": true,
      ]
      var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: alert.date)
      components.timeZone = calendar.timeZone
      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
      do {
        try await center.add(UNNotificationRequest(identifier: String(alert.id), content: content, trigger: trigger))
      } catch {
        return false
      }
    }
    return true
  }

  private func isPrayer(_ identifier: String) -> Bool {
    guard let id = Int(identifier) else { return false }
    return (20000..<20360).contains(id)
  }
}


// AppLinks forwards warm application events. With UIScene, a widget may also
// launch the process through connection options before Dart starts listening.
private final class WidgetSceneLinks: NSObject, FlutterSceneLifeCycleDelegate {
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    handle(connectionOptions?.urlContexts ?? [])
  }

  func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) -> Bool {
    handle(contexts)
  }

  private func handle(_ contexts: Set<UIOpenURLContext>) -> Bool {
    guard let url = contexts.map(\.url).first(where: {
      $0.scheme == "tamanina" && $0.host == "open" &&
        ["/prayer-times", "/azkar", "/azkar/morning", "/azkar/evening", "/sebha", "/quran"].contains($0.path)
    }) else { return false }
    AppLinks.shared.handleLink(url: url)
    return true
  }
}

import Flutter
import UIKit
import WatchConnectivity

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let watchSyncBridge = WatchSyncBridge(config: .default)

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    watchSyncBridge.start()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

private struct WatchSyncConfig {
  let baseURL: URL
  let citySlug: String
  let editionYear: Int
  let mode: String

  static let `default` = WatchSyncConfig(
    baseURL: URL(string: "https://admin.larevira.app/api/v1")!,
    citySlug: "sevilla",
    editionYear: 2025,
    mode: "all"
  )
}

private final class WatchSyncBridge: NSObject {
  private let config: WatchSyncConfig

  init(config: WatchSyncConfig) {
    self.config = config
    super.init()
  }

  func start() {
    guard WCSession.isSupported() else { return }

    let session = WCSession.default
    session.delegate = self
    session.activate()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )

    Task {
      await pushSnapshotIfPossible()
    }
  }

  @objc private func appDidBecomeActive() {
    Task {
      await pushSnapshotIfPossible()
    }
  }

  @MainActor
  func pushSnapshotIfPossible() async {
    guard WCSession.isSupported() else { return }
    guard WCSession.default.activationState == .activated else { return }

    do {
      let snapshot = try await buildSnapshotPayload()
      try WCSession.default.updateApplicationContext(snapshot)
    } catch {
      // Non-fatal: watch app can fallback to direct API.
    }
  }

  private func buildSnapshotPayload() async throws -> [String: Any] {
    let days = try await fetchDays()
    let encodedDays = days.map { day in
      [
        "slug": day.slug,
        "name": day.name,
        "startsAt": day.startsAt?.toISO8601String() as Any,
        "processionEventsCount": day.processionEventsCount,
      ] as [String: Any]
    }

    return [
      "citySlug": config.citySlug,
      "editionYear": config.editionYear,
      "mode": config.mode,
      "syncedAt": Date().toISO8601String(),
      "days": encodedDays,
    ]
  }

  private func fetchDays() async throws -> [WatchDayPayload] {
    var components = URLComponents(
      url: config.baseURL.appendingPathComponent("\(config.citySlug)/\(config.editionYear)/days"),
      resolvingAgainstBaseURL: false
    )
    components?.queryItems = [URLQueryItem(name: "mode", value: config.mode)]

    guard let url = components?.url else {
      throw URLError(.badURL)
    }

    let (data, response) = try await URLSession.shared.data(from: url)
    guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
      throw URLError(.badServerResponse)
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let rawValue = try container.decode(String.self)

      if let date = ISO8601DateFormatter.withFractional.date(from: rawValue) {
        return date
      }
      if let date = ISO8601DateFormatter.standard.date(from: rawValue) {
        return date
      }

      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid date format: \(rawValue)"
      )
    }

    let envelope = try decoder.decode(WatchDaysEnvelope.self, from: data)
    return envelope.data
  }

  @MainActor
  private func openOnPhone(urlRaw: String?, routeRaw: String?) {
    if let urlRaw, let url = URL(string: urlRaw), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
      return
    }

    if let routeRaw {
      let route = routeRaw.hasPrefix("/") ? routeRaw : "/\(routeRaw)"
      var components = URLComponents()
      components.scheme = "larevira"
      components.path = route
      if let url = components.url {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }
  }
}

extension WatchSyncBridge: WCSessionDelegate {
  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    guard activationState == .activated else { return }

    Task {
      await pushSnapshotIfPossible()
    }
  }

  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    guard let type = message["type"] as? String else { return }

    if type == "requestSnapshot" {
      Task {
        await pushSnapshotIfPossible()
      }
      return
    }

    if type == "openOnPhone" {
      let urlRaw = message["url"] as? String
      let routeRaw = message["route"] as? String
      Task { @MainActor in
        openOnPhone(urlRaw: urlRaw, routeRaw: routeRaw)
      }
    }
  }
}

private struct WatchDaysEnvelope: Decodable {
  let data: [WatchDayPayload]
}

private struct WatchDayPayload: Decodable {
  let slug: String
  let name: String
  let startsAt: Date?
  let processionEventsCount: Int

  private enum CodingKeys: String, CodingKey {
    case slug
    case name
    case startsAt = "starts_at"
    case processionEventsCount = "procession_events_count"
  }
}

private extension Date {
  func toISO8601String() -> String {
    ISO8601DateFormatter.withFractional.string(from: self)
  }
}

private extension ISO8601DateFormatter {
  static let withFractional: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()

  static let standard: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }()
}

import Flutter
import Foundation
import TrainingKit

/// Bridges TrainingKit workout lifecycle events to the Flutter event channel.
///
/// The plugin owns the `FlutterEventSink`; the workout controllers — launched in
/// their own flow — push events through this shared instance.
final class TrainingKitEventBridge {
  static let shared = TrainingKitEventBridge()

  private var sink: FlutterEventSink?

  func setSink(_ sink: FlutterEventSink?) {
    self.sink = sink
  }

  func sendSave(_ state: SaveWorkoutState) {
    send(["type": "save", "data": Self.encode(state)])
  }

  func sendQuit() {
    send(["type": "quit"])
  }

  func sendEvent(_ name: Tracking.Event, _ properties: [Tracking.Property: String]?) {
    var props: [String: String] = [:]
    properties?.forEach { props[$0.key.rawValue] = $0.value }

    let propsJson = Self.jsonString(from: props)
    send(["type": "event", "name": name.rawValue, "properties": propsJson])
  }

  private func send(_ body: [String: Any]) {
    let sink = self.sink
    DispatchQueue.main.async {
      sink?(body)
    }
  }

  static func encode(_ state: SaveWorkoutState) -> String {
    guard
      let data = try? JSONEncoder().encode(state),
      let json = String(data: data, encoding: .utf8)
    else {
      return "{}"
    }
    return json
  }

  private static func jsonString(from object: Any) -> String {
    guard
      let data = try? JSONSerialization.data(withJSONObject: object),
      let json = String(data: data, encoding: .utf8)
    else {
      return "{}"
    }
    return json
  }
}

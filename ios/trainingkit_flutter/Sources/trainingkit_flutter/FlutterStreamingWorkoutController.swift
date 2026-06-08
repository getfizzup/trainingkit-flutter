import Combine
import CoreMedia
import TrainingKit
import UIKit

class FlutterStreamingWorkoutController: StreamingWorkoutController {
  var saveProm: AnyPublisher<Void, Never>?
  private var subscriptions = Set<AnyCancellable>()
  private var didSave = false

  override func saveSession(state: SaveWorkoutState) {
    super.saveSession(state: state)

    didSave = true
    TrainingKitEventBridge.shared.sendSave(state)

    saveProm = Future<Void, Never> { promise in
      DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        promise(.success(()))
      }
    }.eraseToAnyPublisher()
  }

  override func quitWorkout() {
    if !didSave {
      TrainingKitEventBridge.shared.sendQuit()
    }
    super.quitWorkout()
  }

  override func trackEvent(_ name: Tracking.Event, properties: [Tracking.Property: String]? = nil) {
    TrainingKitEventBridge.shared.sendEvent(name, properties)
    super.trackEvent(name, properties: properties)
  }

  override func displayPostWorkout() -> AnyPublisher<Void, Never> {
    if let saveProm {
      saveProm.sink { [weak self] _ in
        self?.quitWorkout()
      }.store(in: &subscriptions)

      return saveProm
    }

    return super.displayPostWorkout()
  }

  override func log(_ message: String, context _: [String: AnyHashable]? = nil) {
    print(message)
  }
}

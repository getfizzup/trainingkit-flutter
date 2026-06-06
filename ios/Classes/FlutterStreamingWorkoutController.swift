import Combine
import CoreMedia
import TrainingKit
import UIKit

class FlutterStreamingWorkoutController: StreamingWorkoutController {
  var saveProm: AnyPublisher<Void, Never>?
  private var subscriptions = Set<AnyCancellable>()

  override func saveSession(state: SaveWorkoutState) {
    super.saveSession(state: state)

    saveProm = Future<Void, Never> { promise in
      DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        promise(.success(()))
      }
    }.eraseToAnyPublisher()
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

import Combine
import Foundation
import HealthKit
import TrainingKit

class FlutterClassicWorkoutController: ClassicWorkoutController {
  var saveProm: AnyPublisher<Void, Never>?
  private var subscriptions = Set<AnyCancellable>()
  private var didSave = false

  override func viewDidLoad() {
    super.viewDidLoad()

    var writableTypes: Set<HKSampleType> = [HKWorkoutType.workoutType()]

    if let type = HKCategoryType.quantityType(forIdentifier: .activeEnergyBurned) {
      writableTypes.insert(type)
    }

    HKHealthStore().requestAuthorization(toShare: writableTypes, read: writableTypes) { _, _ in }
  }

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
}

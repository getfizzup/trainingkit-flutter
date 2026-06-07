import Combine
import Foundation
import HealthKit
import TrainingKit

class FlutterClassicWorkoutController: ClassicWorkoutController {
  var saveProm: AnyPublisher<Void, Never>?
  private var subscriptions = Set<AnyCancellable>()

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
}

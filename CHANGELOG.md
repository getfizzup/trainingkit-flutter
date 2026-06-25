## 0.1.0

Initial release of the FizzUp TrainingKit Flutter bridge.

* `deviceIdentifier()` returns the native TrainingKit device identifier.
* `launchWorkout(session)` launches a classic or video workout from a GraphQL
  session payload, dispatching automatically based on `__typename` / `format`.
* iOS bridge (CocoaPods) vendoring `TrainingKit.xcframework`, fetched from
  `getfizzup/trainingkit-ios-sdk@main` during `pod install`.
* Android bridge resolving `com.fizzup:trainingkit` from GitHub Packages, with
  optional Chromecast support for video workouts.
* Demo app under `example/` using `graphql_flutter`.

# trainingkit_flutter_example

A demo Flutter app for the [`trainingkit_flutter`](../README.md) bridge.

It connects to the FizzUp demo GraphQL endpoint, lists the available workouts
(classic and video), and launches the native TrainingKit experience when one is
selected. It mirrors the React Native sample app.

## What it shows

- Reading the device identifier with `deviceIdentifier()` and sending it as the
  `X-TrainingKit-Device` header (see [`lib/main.dart`](lib/main.dart)).
- Querying the workout catalog and the full session payload with
  [`graphql_flutter`](https://pub.dev/packages/graphql_flutter) (see
  [`lib/graphql/queries.dart`](lib/graphql/queries.dart)).
- Launching a workout with `launchWorkout(session)` (see
  [`lib/screens/sessions_screen.dart`](lib/screens/sessions_screen.dart)).

## Run it

```sh
flutter pub get
```

### Android

TrainingKit's Android SDK is resolved from GitHub Packages, so you need
credentials. Create `android/local.properties` and add:

```properties
GithubUser=your-github-username
GithubToken=your-github-token
# Optional, to enable Chromecast in video workouts:
# chromecastReceiverApplicationId=YOUR_CAST_APP_ID
```

Then run:

```sh
flutter run -d android
```

### iOS

> iOS builds require a Mac with Xcode.

The `TrainingKit.xcframework` is fetched automatically from
`getfizzup/trainingkit-ios-sdk@main` during `pod install` (triggered by
`flutter run`). The first build therefore needs network access.

```sh
flutter run -d ios
```

If CocoaPods cannot find the framework, fetch it manually and reinstall pods:

```sh
../ios/scripts/fetch-ios-trainingkit.sh
cd ios && pod install && cd ..
```

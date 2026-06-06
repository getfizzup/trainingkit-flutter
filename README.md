# trainingkit_flutter

Flutter bridge for FizzUp TrainingKit.

This package lets a Flutter application launch FizzUp TrainingKit workouts
without copying native bridges into the app. The GraphQL client stays in the
host application. The package exposes the native device identifier and a single
workout launcher that dispatches to the classic or video native SDK
automatically.

## What It Provides

- `deviceIdentifier()` returns the native TrainingKit device identifier.
- `launchWorkout(session)` launches a workout from a GraphQL session payload.
- iOS bridge is included in the package; `TrainingKit.xcframework` is fetched
  from `getfizzup/trainingkit-ios-sdk@main` during CocoaPods installation.
- Android bridge and TrainingKit activities are included in the package.
- Flutter plugin autolinking handles the native package integration.

`launchWorkout` supports sessions where either `__typename` or `format`
identifies the workout kind:

- `WorkoutBlockSession` or `format: 'CLASSIC'` launches the classic TrainingKit flow.
- `WorkoutVideoSession` or `format: 'PLAY'` launches the video TrainingKit flow.

## API at a glance

```dart
import 'package:trainingkit_flutter/trainingkit_flutter.dart';

// 1. Send the device id with your GraphQL requests
final headers = {'X-TrainingKit-Device': await deviceIdentifier()};

// 2. Launch the workout from the session payload (it carries trainingKitToken)
await launchWorkout(session);
```

Unlike the React Native bridge, `deviceIdentifier()` is asynchronous because
Flutter method channels are asynchronous. The identifier is stable for a device
installation, so read it once (for example when building your GraphQL client)
and reuse it.

## Demo App

This repository contains a local demo app in [`example`](example/).

The demo consumes the package using a local path dependency:

```yaml
dependencies:
  trainingkit_flutter:
    path: ../
```

Run it locally with:

```sh
cd example
flutter pub get
flutter run
```

See the [example README](example/README.md) for the per-platform prerequisites
(Android GitHub Packages credentials, iOS framework fetch).

## Installation In An Existing Flutter App

The package is **not published to pub.dev**. It is distributed as a Git
dependency from its public repository. Add it to your app `pubspec.yaml`,
pinning a release tag for reproducibility:

```yaml
dependencies:
  trainingkit_flutter:
    git:
      url: https://github.com/getfizzup/trainingkit-flutter
      ref: v0.1.0
```

Equivalently, from the command line:

```sh
flutter pub add trainingkit_flutter \
  --git-url https://github.com/getfizzup/trainingkit-flutter \
  --git-ref v0.1.0
```

While developing against a local checkout, use a path dependency instead:

```yaml
dependencies:
  trainingkit_flutter:
    path: ../relative/path/to/trainingkit-flutter
```

Then fetch packages:

```sh
flutter pub get
```

Flutter apps must be rebuilt after adding a native dependency:

```sh
flutter run
```

## iOS Setup

The iOS TrainingKit binary is not versioned in this repository. It is fetched
from the stable `main` branch of `https://github.com/getfizzup/trainingkit-ios-sdk`
during `pod install` through the package podspec.

CocoaPods installs the downloaded XCFramework inside the package at:

```text
ios/Vendor/TrainingKit.xcframework
```

The host app does not need to add the TrainingKit Swift Package manually.
CocoaPods integrates the package through `trainingkit_flutter.podspec` and its
`prepare_command`.

Because the bridge ships a binary `xcframework`, the iOS plugin uses CocoaPods
(not Swift Package Manager). Make sure your app uses CocoaPods for iOS (the
default for `flutter create`).

Set the iOS deployment target to **15.1 or higher** in `ios/Podfile` and in your
Xcode project:

```ruby
platform :ios, '15.1'
```

The classic workout flow requests HealthKit authorization. Add usage
descriptions to `ios/Runner/Info.plist`, otherwise the app crashes when a
classic workout starts:

```xml
<key>NSHealthShareUsageDescription</key>
<string>Read workout and energy data to track your sessions.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>Save completed workouts to Apple Health.</string>
```

For local package development, you can fetch the framework manually before
running pods:

```sh
ios/scripts/fetch-ios-trainingkit.sh
```

## Android Setup

The Android SDK is resolved from GitHub Packages. The package's
`android/build.gradle.kts` already declares the FizzUp Maven repository; you only
need to provide credentials.

In your app's `android/local.properties`:

```properties
GithubUser=your-github-username
GithubToken=your-github-token
```

Or through environment variables:

```sh
export GITHUB_USERNAME=your-github-username
export GITHUB_TOKEN=your-github-token
```

TrainingKit requires Android API level 24 or higher. Set `minSdk` accordingly in
your app's `android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    minSdk = 24
}
```

### Chromecast support (optional)

To enable casting in the video workout flow, provide your Google Cast receiver
application ID.

In `android/local.properties`:

```properties
chromecastReceiverApplicationId=YOUR_CAST_APP_ID
```

Or with an environment variable:

```sh
export CHROMECAST_RECEIVER_APPLICATION_ID=YOUR_CAST_APP_ID
```

## GraphQL Contract

The app is responsible for querying the backend. The package does not create or
own the GraphQL client.

The backend flow is:

1. The app sends `X-TrainingKit-Device` with the GraphQL request.
2. The backend returns the workout session payload and `trainingKitToken`.
3. The app passes the session object to `launchWorkout(session)`.
4. The package forwards the payload and token to the native SDK.

The session passed to `launchWorkout` is a `Map<String, dynamic>` that must
contain `trainingKitToken` and either `__typename` or `format`:

```dart
typedef TrainingKitSession = Map<String, dynamic>;
```

## GraphQL Client Setup

The bridge is client-agnostic. The demo uses
[`graphql_flutter`](https://pub.dev/packages/graphql_flutter); use whichever
client you prefer.

```dart
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:trainingkit_flutter/trainingkit_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final deviceId = await deviceIdentifier();

  final link = HttpLink(
    'https://cloud.demo.fizzup.com/graphql',
    defaultHeaders: {'X-TrainingKit-Device': deviceId},
  );

  final client = ValueNotifier(
    GraphQLClient(link: link, cache: GraphQLCache()),
  );

  runApp(GraphQLProvider(client: client, child: const MyApp()));
}
```

`graphql_flutter` automatically adds `__typename` to every selection set, so the
session payload it returns already carries `WorkoutBlockSession` /
`WorkoutVideoSession`, which the launcher uses to dispatch.

## Listing Workouts

The list query should return workout preview items with at least: `id`, `name`,
`duration`, `picture`, and `format`. `format` is `CLASSIC` (classic guided
workout) or `PLAY` (video workout).

```dart
Query(
  options: QueryOptions(document: gql(getSessions)),
  builder: (result, {fetchMore, refetch}) {
    if (result.isLoading) return const CircularProgressIndicator();
    if (result.hasException) return Text(result.exception.toString());

    final edges = result.data?['publicWorkouts']?['edges'] as List? ?? [];
    final nodes = edges.map((e) => e['node'] as Map<String, dynamic>).toList();

    return ListView(
      children: [
        for (final node in nodes)
          ListTile(
            title: Text(node['name'] as String),
            onTap: () => launchWorkoutById(context, node['id'] as String),
          ),
      ],
    );
  },
);
```

## Launching A Workout

To launch a workout, fetch the full session payload first. The full session
response must include `trainingKitToken`.

```dart
Future<void> launchWorkoutById(BuildContext context, String id) async {
  final client = GraphQLProvider.of(context).value;

  final result = await client.query(QueryOptions(
    document: gql(getSessionContent),
    variables: {'id': id},
    fetchPolicy: FetchPolicy.networkOnly,
  ));

  final session = result.data?['publicWorkoutSession'];
  if (session is Map<String, dynamic>) {
    await launchWorkout(session);
  }
}
```

`launchWorkout` handles the native dispatch internally:

- classic session → `launchClassicWorkout(jsonString, trainingKitToken)`
- video session → `launchVideoWorkout(jsonString, trainingKitToken)`

## Building A Demo App From Scratch

Create a new Flutter app:

```sh
flutter create my_trainingkit_demo
cd my_trainingkit_demo
```

Add dependencies:

```sh
flutter pub add graphql_flutter
flutter pub add trainingkit_flutter \
  --git-url https://github.com/getfizzup/trainingkit-flutter \
  --git-ref v0.1.0
```

During local package development, use a path dependency on this repository
instead of the Git dependency.

Configure Android access to the FizzUp Maven repository (credentials in
`android/local.properties`) and the iOS deployment target / HealthKit usage
descriptions as described above.

Wire your GraphQL client at the root of the app with `deviceIdentifier()` in the
headers, then build and run:

```sh
flutter run
```

## Troubleshooting

### Method channel not available / `MissingPluginException`

The native plugin was not registered. A hot reload is not sufficient after
adding a native package — do a full rebuild:

```sh
flutter clean
flutter pub get
flutter run
```

### iOS: `TrainingKit.xcframework` missing

If CocoaPods fails because the vendored framework is missing
(`ios/Vendor/TrainingKit.xcframework`), fetch it manually and reinstall pods:

```sh
ios/scripts/fetch-ios-trainingkit.sh
cd ios
pod install
```

The script honors `TRAININGKIT_IOS_SDK_URL` if you need to test a different
archive URL temporarily:

```sh
TRAININGKIT_IOS_SDK_URL=https://github.com/getfizzup/trainingkit-ios-sdk/archive/refs/heads/main.zip \
  ios/scripts/fetch-ios-trainingkit.sh
```

### iOS: deployment target / pod install errors

Make sure the app's iOS deployment target is **15.1 or higher**, both in
`ios/Podfile` (`platform :ios, '15.1'`) and in the Xcode project
(`IPHONEOS_DEPLOYMENT_TARGET`).

### iOS: crash when launching a classic workout

Add `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` to
`ios/Runner/Info.plist`. The classic workout flow requests HealthKit
authorization and iOS terminates the app if these usage strings are missing.

### Android: cannot resolve `com.fysiki:trainingkit`

The GitHub Packages Maven repository requires credentials. Check that
`GithubUser` / `GithubToken` are present in `android/local.properties`, or that
`GITHUB_USERNAME` / `GITHUB_TOKEN` are exported in the environment.

## Package Development Checklist

- Run `flutter analyze` and `flutter test` at the package root.
- The `ios/Vendor/TrainingKit.xcframework` directory is gitignored; it is
  downloaded from `getfizzup/trainingkit-ios-sdk@main` during CocoaPods
  installation.
- The demo in `example/` can be used as an integration test for the package.

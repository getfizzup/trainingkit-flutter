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
- iOS bridge is a Swift Package; it depends on the TrainingKit iOS SDK
  (`getfizzup/trainingkit-ios-sdk`) through Swift Package Manager.
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

The iOS plugin is a **Swift Package**. It depends on the TrainingKit iOS SDK
(`getfizzup/trainingkit-ios-sdk`), itself a Swift package whose `TrainingKit`
product is a binary target (`TrainingKit.xcframework`). Swift Package Manager
resolves and links it automatically — there is nothing to vendor, fetch, or add
manually.

### Enable Swift Package Manager

This plugin requires Flutter's Swift Package Manager support, which is enabled by
default on Flutter 3.29+. If you previously disabled it, turn it back on:

```sh
flutter config --enable-swift-package-manager
```

The first iOS build resolves the TrainingKit package from GitHub, so it needs
network access. No CocoaPods setup is required for this plugin.

### Deployment target

Set the iOS deployment target to **15.1 or higher** in your Xcode project
(`Runner` target → **iOS Deployment Target**). The plugin's Swift package
declares iOS 15.1 as its minimum.

The classic workout flow requests HealthKit authorization. Add usage
descriptions to `ios/Runner/Info.plist`, otherwise the app crashes when a
classic workout starts:

```xml
<key>NSHealthShareUsageDescription</key>
<string>Read workout and energy data to track your sessions.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>Save completed workouts to Apple Health.</string>
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

  final locale = WidgetsBinding.instance.platformDispatcher.locale;

  final link = HttpLink(
    'https://cloud.demo.fizzup.com/graphql',
    defaultHeaders: {
      'X-TrainingKit-Device': deviceId,
      // Derive Accept-Language from the app locale (see "Language" below).
      'Accept-Language': '${locale.languageCode}-${locale.countryCode}',
    },
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

### Language

A TrainingKit workout has two layers of language:

- **Content** — workout names, exercise instructions, and the voice-coaching
  text spoken during a workout — comes from the GraphQL API and is localized
  from the **`Accept-Language`** request header. Without it, the API serves its
  default language (English).
- **Native UI** — the buttons and labels of the workout screen — is localized by
  the native SDK from the **app's locale**. TrainingKit exposes no language API;
  it follows the device/app language, the same way any native app does.

To keep both layers consistent, derive `Accept-Language` from the app's locale
(`WidgetsBinding.instance.platformDispatcher.locale`) rather than hard-coding a
value. The content then follows the same language as the native UI.

> [!IMPORTANT]
> **The app must declare the languages it supports**, or the native UI stays in
> English even on a localized device. iOS only serves a framework's localized
> resources for languages the host app lists, and Flutter apps ship with English
> only by default. Declare your languages:
>
> - **iOS** — add `CFBundleLocalizations` to `ios/Runner/Info.plist`:
>
>   ```xml
>   <key>CFBundleLocalizations</key>
>   <array>
>     <string>en</string>
>     <string>fr</string>
>   </array>
>   ```
>
> - **Android** — add a `res/xml/locales_config.xml` listing the locales and
>   reference it from `<application android:localeConfig="@xml/locales_config">`.

To pin the whole experience to one language regardless of the device (as the demo
does for French), also set the app's locale on the native side — `AppleLanguages`
on iOS, `AppCompatDelegate.setApplicationLocales` on Android — and the derived
`Accept-Language` follows automatically. See the
[example](example/lib/main.dart).

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

### iOS: Swift Package Manager is disabled

This plugin is distributed as a Swift Package. If the iOS build cannot find the
plugin or the TrainingKit SDK, make sure SPM is enabled and rebuild:

```sh
flutter config --enable-swift-package-manager
flutter clean
flutter run
```

The first build resolves the TrainingKit package from GitHub, so it needs
network access.

### iOS: deployment target

Make sure the app's iOS deployment target is **15.1 or higher** in the Xcode
project (`IPHONEOS_DEPLOYMENT_TARGET`). The plugin's Swift package declares iOS
15.1 as its minimum.

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
- The iOS plugin is a Swift Package (`ios/trainingkit_flutter/Package.swift`)
  that depends on `getfizzup/trainingkit-ios-sdk`; SPM resolves
  `TrainingKit.xcframework` from that package — nothing is vendored here.
- The demo in `example/` can be used as an integration test for the package.

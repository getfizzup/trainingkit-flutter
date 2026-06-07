import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Demo only: force the app — and therefore TrainingKit's native UI — to
    // French, regardless of the device language. TrainingKit has no language
    // API; it follows the app's localization. A real app would simply follow
    // the device locale. The Accept-Language header is derived from this locale
    // on the Dart side (see lib/main.dart).
    UserDefaults.standard.set(["fr-FR", "fr"], forKey: "AppleLanguages")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

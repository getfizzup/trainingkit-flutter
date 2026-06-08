import Flutter
import Foundation
import TrainingKit
import UIKit

@objc(TrainingKitFlutterPlugin)
public class TrainingKitFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "trainingkit_flutter",
      binaryMessenger: registrar.messenger()
    )
    let instance = TrainingKitFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let eventChannel = FlutterEventChannel(
      name: "trainingkit_flutter/events",
      binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(instance)
  }

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    TrainingKitEventBridge.shared.setSink(events)
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    TrainingKitEventBridge.shared.setSink(nil)
    return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "deviceIdentifier":
      result(TrainingKitConfig.deviceId())

    case "launchClassicWorkout":
      guard let (jsonString, token) = workoutArguments(call, result: result) else { return }
      launchClassicWorkout(jsonString: jsonString, token: token, result: result)

    case "launchVideoWorkout":
      guard let (jsonString, token) = workoutArguments(call, result: result) else { return }
      launchVideoWorkout(jsonString: jsonString, token: token, result: result)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func workoutArguments(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) -> (jsonString: String, token: String)? {
    guard
      let args = call.arguments as? [String: Any],
      let jsonString = args["jsonString"] as? String,
      let token = args["token"] as? String
    else {
      result(
        FlutterError(
          code: "invalid_arguments",
          message: "Expected jsonString and token arguments.",
          details: nil
        )
      )
      return nil
    }

    return (jsonString, token)
  }

  private func launchClassicWorkout(
    jsonString: String,
    token: String,
    result: @escaping FlutterResult
  ) {
    guard let data = jsonString.data(using: .utf8) else {
      result(invalidJSONError())
      return
    }

    Task {
      do {
        let controller = try await FlutterClassicWorkoutController(data: data, token: token)
        await present(controller)
        await MainActor.run { result(nil) }
      } catch {
        await MainActor.run {
          result(
            FlutterError(
              code: "launch_failed",
              message: "Failed to launch classic workout: \(error)",
              details: nil
            )
          )
        }
      }
    }
  }

  private func launchVideoWorkout(
    jsonString: String,
    token: String,
    result: @escaping FlutterResult
  ) {
    guard let data = jsonString.data(using: .utf8) else {
      result(invalidJSONError())
      return
    }

    Task {
      do {
        let controller = try await FlutterStreamingWorkoutController(data: data, token: token)
        await present(controller)
        await MainActor.run { result(nil) }
      } catch {
        await MainActor.run {
          result(
            FlutterError(
              code: "launch_failed",
              message: "Failed to launch video workout: \(error)",
              details: nil
            )
          )
        }
      }
    }
  }

  private func invalidJSONError() -> FlutterError {
    FlutterError(
      code: "invalid_json",
      message: "Failed to convert the session JSON string to data.",
      details: nil
    )
  }

  @MainActor
  private func present(_ controller: UIViewController) {
    controller.modalPresentationStyle = .fullScreen

    guard let rootViewController = UIApplication.shared.fzTrainingKitRootViewController else {
      print("TrainingKit: failed to find a root view controller")
      return
    }

    rootViewController.present(controller, animated: true)
  }
}

private extension UIApplication {
  var fzTrainingKitRootViewController: UIViewController? {
    connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first { $0.isKeyWindow }?
      .rootViewController
  }
}

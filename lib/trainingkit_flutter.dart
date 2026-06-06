/// Flutter bridge for FizzUp TrainingKit.
///
/// This library lets a Flutter application launch FizzUp TrainingKit workouts
/// without copying any native bridge code into the host app. The GraphQL client
/// stays in the host application; the bridge exposes the native device
/// identifier and a single workout launcher that dispatches to the classic or
/// video native SDK automatically.
library;

import 'dart:convert';

import 'package:flutter/services.dart';

/// A FizzUp TrainingKit workout session payload, as returned by the GraphQL API.
///
/// At minimum it must carry a `trainingKitToken`. The workout kind is
/// identified by either `__typename` (`WorkoutBlockSession` /
/// `WorkoutVideoSession`) or `format` (`CLASSIC` / `PLAY`). Any additional
/// fields from the GraphQL response are preserved and forwarded to the native
/// SDK as part of the JSON payload.
typedef TrainingKitSession = Map<String, dynamic>;

const MethodChannel _channel = MethodChannel('trainingkit_flutter');

/// Returns the native TrainingKit device identifier.
///
/// Send this value as the `X-TrainingKit-Device` HTTP header on every GraphQL
/// request so the backend can associate the workout session with the correct
/// device.
///
/// Unlike the React Native bridge — where the identifier is exposed
/// synchronously — Flutter method channels are asynchronous, so this returns a
/// [Future]. The underlying identifier is stable for a given device
/// installation, so it is safe to read it once and cache it (for example when
/// constructing your GraphQL client).
Future<String> deviceIdentifier() async {
  final id = await _channel.invokeMethod<String>('deviceIdentifier');

  if (id == null || id.isEmpty) {
    throw const TrainingKitException(
      'TrainingKit returned an empty device identifier. '
      'Make sure trainingkit_flutter is linked and the native app was rebuilt.',
    );
  }

  return id;
}

/// Launches the native TrainingKit workout experience from a [session] payload.
///
/// The function inspects the session and opens the classic or video native
/// experience automatically:
///
/// - `__typename == 'WorkoutBlockSession'` or `format == 'CLASSIC'` launches the
///   classic TrainingKit flow.
/// - `__typename == 'WorkoutVideoSession'` or `format == 'PLAY'` launches the
///   video TrainingKit flow.
///
/// Throws a [TrainingKitException] if `trainingKitToken` is missing or if the
/// session kind cannot be identified.
Future<void> launchWorkout(TrainingKitSession session) async {
  final token = session['trainingKitToken'];

  if (token is! String || token.isEmpty) {
    throw const TrainingKitException(
      'TrainingKit session is missing trainingKitToken.',
    );
  }

  final jsonString = jsonEncode(session);

  if (_isClassicWorkout(session)) {
    await _channel.invokeMethod<void>('launchClassicWorkout', {
      'jsonString': jsonString,
      'token': token,
    });
    return;
  }

  if (_isVideoWorkout(session)) {
    await _channel.invokeMethod<void>('launchVideoWorkout', {
      'jsonString': jsonString,
      'token': token,
    });
    return;
  }

  final type = session['__typename'] ?? session['format'] ?? 'unknown';
  throw TrainingKitException('Unsupported TrainingKit session type: $type.');
}

bool _isClassicWorkout(TrainingKitSession session) =>
    session['__typename'] == 'WorkoutBlockSession' ||
    session['format'] == 'CLASSIC';

bool _isVideoWorkout(TrainingKitSession session) =>
    session['__typename'] == 'WorkoutVideoSession' ||
    session['format'] == 'PLAY';

/// Error thrown by the TrainingKit bridge when a workout cannot be launched.
class TrainingKitException implements Exception {
  /// Creates a TrainingKit error with a human-readable [message].
  const TrainingKitException(this.message);

  /// A human-readable description of what went wrong.
  final String message;

  @override
  String toString() => 'TrainingKitException: $message';
}

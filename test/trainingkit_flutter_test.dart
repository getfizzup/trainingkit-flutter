import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingkit_flutter/trainingkit_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('trainingkit_flutter');
  final log = <MethodCall>[];

  void handle(Future<Object?>? Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  setUp(log.clear);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('deviceIdentifier', () {
    test('returns the native identifier', () async {
      handle((call) async {
        log.add(call);
        return 'device-123';
      });

      expect(await deviceIdentifier(), 'device-123');
      expect(log.single.method, 'deviceIdentifier');
    });

    test('throws when the native identifier is empty', () async {
      handle((call) async => '');
      expect(deviceIdentifier(), throwsA(isA<TrainingKitException>()));
    });
  });

  group('launchWorkout', () {
    test('dispatches a classic session by __typename', () async {
      handle((call) async {
        log.add(call);
        return null;
      });

      await launchWorkout({
        '__typename': 'WorkoutBlockSession',
        'trainingKitToken': 'token-abc',
        'name': 'Arms - legs',
      });

      expect(log.single.method, 'launchClassicWorkout');
      expect(log.single.arguments['token'], 'token-abc');
      expect(log.single.arguments['jsonString'], contains('Arms - legs'));
    });

    test('dispatches a video session by format', () async {
      handle((call) async {
        log.add(call);
        return null;
      });

      await launchWorkout({
        'format': 'PLAY',
        'trainingKitToken': 'token-xyz',
      });

      expect(log.single.method, 'launchVideoWorkout');
      expect(log.single.arguments['token'], 'token-xyz');
    });

    test('throws when trainingKitToken is missing', () async {
      handle((call) async => null);
      expect(
        launchWorkout({'format': 'CLASSIC'}),
        throwsA(isA<TrainingKitException>()),
      );
    });

    test('throws for an unrecognized session type', () async {
      handle((call) async => null);
      expect(
        launchWorkout({'trainingKitToken': 'token', 'format': 'SOMETHING'}),
        throwsA(isA<TrainingKitException>()),
      );
    });
  });
}

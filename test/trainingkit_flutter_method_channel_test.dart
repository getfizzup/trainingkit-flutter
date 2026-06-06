import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainingkit_flutter/trainingkit_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelTrainingkitFlutter platform = MethodChannelTrainingkitFlutter();
  const MethodChannel channel = MethodChannel('trainingkit_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

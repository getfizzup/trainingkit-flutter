import 'package:flutter_test/flutter_test.dart';
import 'package:trainingkit_flutter/trainingkit_flutter.dart';
import 'package:trainingkit_flutter/trainingkit_flutter_platform_interface.dart';
import 'package:trainingkit_flutter/trainingkit_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTrainingkitFlutterPlatform
    with MockPlatformInterfaceMixin
    implements TrainingkitFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TrainingkitFlutterPlatform initialPlatform = TrainingkitFlutterPlatform.instance;

  test('$MethodChannelTrainingkitFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTrainingkitFlutter>());
  });

  test('getPlatformVersion', () async {
    TrainingkitFlutter trainingkitFlutterPlugin = TrainingkitFlutter();
    MockTrainingkitFlutterPlatform fakePlatform = MockTrainingkitFlutterPlatform();
    TrainingkitFlutterPlatform.instance = fakePlatform;

    expect(await trainingkitFlutterPlugin.getPlatformVersion(), '42');
  });
}

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'trainingkit_flutter_method_channel.dart';

abstract class TrainingkitFlutterPlatform extends PlatformInterface {
  /// Constructs a TrainingkitFlutterPlatform.
  TrainingkitFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static TrainingkitFlutterPlatform _instance = MethodChannelTrainingkitFlutter();

  /// The default instance of [TrainingkitFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelTrainingkitFlutter].
  static TrainingkitFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TrainingkitFlutterPlatform] when
  /// they register themselves.
  static set instance(TrainingkitFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

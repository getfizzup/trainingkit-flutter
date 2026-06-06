
import 'trainingkit_flutter_platform_interface.dart';

class TrainingkitFlutter {
  Future<String?> getPlatformVersion() {
    return TrainingkitFlutterPlatform.instance.getPlatformVersion();
  }
}

// Integration test exercising the native side of the plugin.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of the plugin implementation, unlike Dart unit tests.
// See https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trainingkit_flutter/trainingkit_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('deviceIdentifier returns a non-empty id', (tester) async {
    final id = await deviceIdentifier();
    // The value depends on the host device, so we only assert it is present.
    expect(id, isNotEmpty);
  });
}

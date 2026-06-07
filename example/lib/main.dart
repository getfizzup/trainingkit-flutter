import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:trainingkit_flutter/trainingkit_flutter.dart';

import 'screens/sessions_screen.dart';
import 'screens/welcome_screen.dart';

/// FizzUp demo GraphQL endpoint.
const String _endpoint = 'https://cloud.demo.fizzup.com/graphql';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The TrainingKit device identifier is stable for a device installation, so
  // we read it once and send it as a header on every GraphQL request.
  String deviceId = '';
  try {
    deviceId = await deviceIdentifier();
  } on TrainingKitException catch (error) {
    debugPrint('TrainingKit device identifier unavailable: ${error.message}');
  }

  final link = HttpLink(
    _endpoint,
    defaultHeaders: {
      'X-TrainingKit-Device': deviceId,
      // The FizzUp API localizes workout content (names, exercise instructions,
      // voice-coaching text…) from the Accept-Language header. We derive it from
      // the app's locale so the content matches the app's language — no
      // hard-coded language. The app is forced to French on the native side
      // (see ios/Runner/AppDelegate.swift and android MainActivity.kt), which
      // also drives TrainingKit's native UI language.
      'Accept-Language': _acceptLanguage(),
    },
  );

  final client = ValueNotifier<GraphQLClient>(
    GraphQLClient(link: link, cache: GraphQLCache()),
  );

  runApp(TrainingKitDemoApp(client: client));
}

/// Builds an `Accept-Language` value (e.g. `fr-FR`) from the app's current
/// locale, as reported by the platform.
String _acceptLanguage() {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final country = locale.countryCode;
  return (country == null || country.isEmpty)
      ? locale.languageCode
      : '${locale.languageCode}-$country';
}

class TrainingKitDemoApp extends StatelessWidget {
  const TrainingKitDemoApp({super.key, required this.client});

  final ValueNotifier<GraphQLClient> client;

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'TrainingKit Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF007AFF),
          useMaterial3: true,
        ),
        initialRoute: WelcomeScreen.routeName,
        routes: {
          WelcomeScreen.routeName: (_) => const WelcomeScreen(),
          SessionsScreen.routeName: (_) => const SessionsScreen(),
        },
      ),
    );
  }
}

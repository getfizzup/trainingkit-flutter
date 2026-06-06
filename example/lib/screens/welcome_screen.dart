import 'package:flutter/material.dart';

import 'sessions_screen.dart';

/// Landing screen mirroring the React Native sample: FizzUp wordmark, a "B2B
/// DEMO" tag, and a button that opens the workout list.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 768;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(text: 'Fizz'),
                        TextSpan(
                          text: 'Up',
                          style: TextStyle(color: Color(0xFF007AFF)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'B2B DEMO',
                    style: TextStyle(fontSize: 17, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Positioned(
              left: isPhone ? 20 : null,
              right: isPhone ? 20 : null,
              bottom: 50,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: isPhone ? double.infinity : 320,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(SessionsScreen.routeName),
                    child: const Text(
                      'Liste des séances',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

package com.fysiki.trainingkit_flutter_example

import android.os.Bundle
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.os.LocaleListCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Demo only: force the app — and therefore TrainingKit's native UI — to
        // French, regardless of the device language. TrainingKit has no language
        // API; its activities (AppCompatActivity) follow the per-app locale set
        // here. A real app would simply follow the device locale. The
        // Accept-Language header is derived from this locale on the Dart side
        // (see lib/main.dart).
        if (AppCompatDelegate.getApplicationLocales().isEmpty) {
            AppCompatDelegate.setApplicationLocales(
                LocaleListCompat.forLanguageTags("fr-FR"),
            )
        }
    }
}

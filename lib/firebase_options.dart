import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Firebase options for the mybvoice_secretary web app.
///
/// Web API keys are public client identifiers. dotenv (`.env` / Vercel env)
/// overrides these values when it is present and complete.
class DefaultFirebaseOptions {
  static const FirebaseOptions mybvoice = FirebaseOptions(
    apiKey: 'AIzaSyBEuX4P4LqXxPjty8jFsg07FDqH5KeIN04',
    appId: '1:571265659624:web:e4a946b2f2ec46d7900f5d',
    messagingSenderId: '571265659624',
    projectId: 'mybvoicesecretary',
    authDomain: 'mybvoicesecretary.firebaseapp.com',
    storageBucket: 'mybvoicesecretary.firebasestorage.app',
    measurementId: 'G-5VZQXB0CFB',
  );

  static FirebaseOptions get currentPlatform {
    if (!dotenv.isInitialized) return mybvoice;

    final apiKey = dotenv.env['FIREBASE_API_KEY']?.trim();
    final appId = dotenv.env['FIREBASE_APP_ID']?.trim();
    final messagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID']
        ?.trim();
    final projectId = dotenv.env['FIREBASE_PROJECT_ID']?.trim();

    final envReady =
        apiKey != null &&
        apiKey.isNotEmpty &&
        !apiKey.startsWith('your_') &&
        appId != null &&
        appId.isNotEmpty &&
        messagingSenderId != null &&
        messagingSenderId.isNotEmpty &&
        projectId != null &&
        projectId.isNotEmpty;

    if (!envReady) return mybvoice;

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      authDomain: _or(dotenv.env['FIREBASE_AUTH_DOMAIN'], mybvoice.authDomain),
      storageBucket: _or(
        dotenv.env['FIREBASE_STORAGE_BUCKET'],
        mybvoice.storageBucket,
      ),
      measurementId: _optional(dotenv.env['FIREBASE_MEASUREMENT_ID']),
    );
  }

  static bool get isConfigured => currentPlatform.projectId.isNotEmpty;

  static String _or(String? value, String? fallback) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return fallback ?? '';
    return trimmed;
  }

  static String? _optional(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

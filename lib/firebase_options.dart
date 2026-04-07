import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
    apiKey: "YOUR_FIREBASE_API_KEY",
    appId: "YOUR_FIREBASE_APP_ID",
    messagingSenderId: "YOUR_FIREBASE_SENDER_ID",
    projectId: "YOUR_FIREBASE_PROJECT_ID",
  );
}
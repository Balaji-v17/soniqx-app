import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'mock-key',
      appId: '1:1234567890:android:1234567890',
      messagingSenderId: '1234567890',
      projectId: 'soniq-music',
      storageBucket: 'soniq-music.appspot.com',
    );
  }
}

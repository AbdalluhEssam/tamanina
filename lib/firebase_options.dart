import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC7wWCJMJTfxMpn_6yF_zY7wqN3zM5A4bk',
    appId: '1:123456789:web:abc123def456',
    messagingSenderId: '123456789',
    projectId: 'tamanina-app',
    authDomain: 'tamanina-app.firebaseapp.com',
    storageBucket: 'tamanina-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBnSRX-HRsQ6_kmGJzrwfGz503THx1lQ30',
    appId: '1:902662652361:android:a3acbf9f1a10d6af7aa818',
    messagingSenderId: '902662652361',
    projectId: 'tamanina-624c9',
    storageBucket: 'tamanina-624c9.firebasestorage.app',
  );

//

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-YKvqL57q9hAMjlemHn1kz6jxQd3_aMg',
    appId: '1:902662652361:ios:d6322f60d322ec8f7aa818',
    messagingSenderId: '902662652361',
    projectId: 'tamanina-624c9',
    storageBucket: 'tamanina-624c9.firebasestorage.app',
    iosBundleId: 'com.abdalluh.tamanina',
  );
}

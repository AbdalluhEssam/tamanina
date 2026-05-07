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

  // ملاحظة: لم ترفق ملف الويب، لذا يفضل التأكد من بيانات الويب من كونسول فيربيز
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC7wWCJMJTfxMpn_6yF_zY7wqN3zM5A4bk',
    appId: '1:123456789:web:abc123def456',
    messagingSenderId: '902662652361',
    projectId: 'tamanina-624c9',
    authDomain: 'tamanina-624c9.firebaseapp.com',
    storageBucket: 'tamanina-624c9.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBnSRX-HRsQ6_kmGJzrwfGz503THx1lQ30', // تم التحديث من ملف json
    appId: '1:902662652361:android:5ffff616f55c095e7aa818', // تم التحديث لمطابقة الباكيج com.engaz.tech.tamanina
    messagingSenderId: '902662652361', //
    projectId: 'tamanina-624c9', //
    storageBucket: 'tamanina-624c9.firebasestorage.app', //
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-YKvqL57q9hAMjlemHn1kz6jxQd3_aMg', // 
    appId: '1:902662652361:ios:01b2cc2a7fd4c31a7aa818', // تم التحديث من ملف plist 
    messagingSenderId: '902662652361', // 
    projectId: 'tamanina-624c9', // 
    storageBucket: 'tamanina-624c9.firebasestorage.app', // 
    iosBundleId: 'com.engaz.tech.tamanina', // 
  );
}
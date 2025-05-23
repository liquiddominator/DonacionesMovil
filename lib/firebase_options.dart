// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDtKKY69u4mQkTtCX5JqiZaxc1LqVZAJPQ',
    appId: '1:481032608281:web:e555dc04a8103533256888',
    messagingSenderId: '481032608281',
    projectId: 'transparenciadonaciones',
    authDomain: 'transparenciadonaciones.firebaseapp.com',
    storageBucket: 'transparenciadonaciones.firebasestorage.app',
    measurementId: 'G-2G2T1E3EWT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_pqvD0sRqqGUVMCy-wECKXq1TQwgLSKc',
    appId: '1:481032608281:android:a9da36c9427043d3256888',
    messagingSenderId: '481032608281',
    projectId: 'transparenciadonaciones',
    storageBucket: 'transparenciadonaciones.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDtKKY69u4mQkTtCX5JqiZaxc1LqVZAJPQ',
    appId: '1:481032608281:web:ff4527bdff17f0a5256888',
    messagingSenderId: '481032608281',
    projectId: 'transparenciadonaciones',
    authDomain: 'transparenciadonaciones.firebaseapp.com',
    storageBucket: 'transparenciadonaciones.firebasestorage.app',
    measurementId: 'G-YSF1WR9V7R',
  );
}

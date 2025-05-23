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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyCQIUyruBbnXD8LGTvvV66N_0S90qZLv8U',
    appId: '1:680330433985:web:8e168a9fc71cce453e0b40',
    messagingSenderId: '680330433985',
    projectId: 'hastahaneprojesi-fa648',
    authDomain: 'hastahaneprojesi-fa648.firebaseapp.com',
    storageBucket: 'hastahaneprojesi-fa648.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBodyvY7RZaOxgxnTOfUT04pf8sqItnqbA',
    appId: '1:680330433985:android:9d12e8d4b7b57a5c3e0b40',
    messagingSenderId: '680330433985',
    projectId: 'hastahaneprojesi-fa648',
    storageBucket: 'hastahaneprojesi-fa648.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJ_AjBsowoQ_KaQbA_qIka7j_jF-K9_Oo',
    appId: '1:680330433985:ios:c4cf800261abd2e93e0b40',
    messagingSenderId: '680330433985',
    projectId: 'hastahaneprojesi-fa648',
    storageBucket: 'hastahaneprojesi-fa648.firebasestorage.app',
    iosBundleId: 'com.example.hastaneRandevuSistemi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAJ_AjBsowoQ_KaQbA_qIka7j_jF-K9_Oo',
    appId: '1:680330433985:ios:c4cf800261abd2e93e0b40',
    messagingSenderId: '680330433985',
    projectId: 'hastahaneprojesi-fa648',
    storageBucket: 'hastahaneprojesi-fa648.firebasestorage.app',
    iosBundleId: 'com.example.hastaneRandevuSistemi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCQIUyruBbnXD8LGTvvV66N_0S90qZLv8U',
    appId: '1:680330433985:web:95d20e065afdc9563e0b40',
    messagingSenderId: '680330433985',
    projectId: 'hastahaneprojesi-fa648',
    authDomain: 'hastahaneprojesi-fa648.firebaseapp.com',
    storageBucket: 'hastahaneprojesi-fa648.firebasestorage.app',
  );
}

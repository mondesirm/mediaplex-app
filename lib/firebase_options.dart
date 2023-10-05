import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      case TargetPlatform.macOS: throw UnsupportedError('DefaultFirebaseOptions have not been configured for macos (use the FlutterFire CLI)');
      case TargetPlatform.windows: throw UnsupportedError('DefaultFirebaseOptions have not been configured for windows (use the FlutterFire CLI)');
      case TargetPlatform.linux: throw UnsupportedError('DefaultFirebaseOptions have not been configured for linux (use the FlutterFire CLI)');
      default: throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD2KFfFedvSNQ8esKL_jr-IVCooGygRuSk',
    appId: '1:53243610812:web:8763d1c0b1bd6fbc63b2b9',
    messagingSenderId: '53243610812',
    projectId: 'mondesirm-mediaplex',
    authDomain: 'mondesirm-mediaplex.firebaseapp.com',
    storageBucket: 'mondesirm-mediaplex.appspot.com',
    measurementId: 'G-C57GWVCZGZ'
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA6F-pzDUlEMbd0vjp08iY0pQBcPQh0LJQ',
    appId: '1:53243610812:android:01992390c209ab3063b2b9',
    messagingSenderId: '53243610812',
    projectId: 'mondesirm-mediaplex',
    storageBucket: 'mondesirm-mediaplex.appspot.com'
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCG-7DFygiRVkl1RGGNs1pNcLX6Wk3W21A',
    appId: '1:53243610812:ios:271c8c8df0929d0763b2b9',
    messagingSenderId: '53243610812',
    projectId: 'mondesirm-mediaplex',
    storageBucket: 'mondesirm-mediaplex.appspot.com',
    iosBundleId: 'com.example.mediaplex'
  );
}
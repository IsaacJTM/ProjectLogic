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
    apiKey: 'AIzaSyB135VE0viZJenHlkeLSU9jsTN5cXlqMxw',
    appId: '1:264266504835:web:392ecedc61bc74228fd9b6',
    messagingSenderId: '264266504835',
    projectId: 'myfirstproject-2f4e5',
    authDomain: 'myfirstproject-2f4e5.firebaseapp.com',
    storageBucket: 'myfirstproject-2f4e5.firebasestorage.app',
    measurementId: 'G-FW17DQ7S47',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvIRczknnjEPCOkHjSVtivI5MURUriGDQ',
    appId: '1:264266504835:android:bdb0b277d9bea8fd8fd9b6',
    messagingSenderId: '264266504835',
    projectId: 'myfirstproject-2f4e5',
    storageBucket: 'myfirstproject-2f4e5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCmku8veHir0owHu0argoA_EMLMNTqVYXE',
    appId: '1:264266504835:ios:3754d218fc3f2b6d8fd9b6',
    messagingSenderId: '264266504835',
    projectId: 'myfirstproject-2f4e5',
    storageBucket: 'myfirstproject-2f4e5.firebasestorage.app',
    iosBundleId: 'com.miempresa.logisticsPro',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCmku8veHir0owHu0argoA_EMLMNTqVYXE',
    appId: '1:264266504835:ios:3754d218fc3f2b6d8fd9b6',
    messagingSenderId: '264266504835',
    projectId: 'myfirstproject-2f4e5',
    storageBucket: 'myfirstproject-2f4e5.firebasestorage.app',
    iosBundleId: 'com.miempresa.logisticsPro',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB135VE0viZJenHlkeLSU9jsTN5cXlqMxw',
    appId: '1:264266504835:web:6c02bec1b1820f458fd9b6',
    messagingSenderId: '264266504835',
    projectId: 'myfirstproject-2f4e5',
    authDomain: 'myfirstproject-2f4e5.firebaseapp.com',
    storageBucket: 'myfirstproject-2f4e5.firebasestorage.app',
    measurementId: 'G-1N40KCW7W8',
  );
}

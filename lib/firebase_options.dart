import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
        apiKey: "GCALC_APIKEY",
        authDomain: "GCALC_AUTHDOMAIN",
        projectId: "GCALC_PROJECTID",
        storageBucket: "GCALC_STORAGEBUCKET",
        messagingSenderId: "GCALC_MESSAGINGSENDERID",
        appId: "GCALC_APPID",
        measurementId: "GCALC_MEASUREMENTID",
    );
  }
}


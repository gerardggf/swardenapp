import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveïdor per obtenir la instància de la llibreria de PackageInfo per a la informació de versions de l'aplicació
final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

/// Proveïdor per obtenir la instància de la llibreria de SharedPreferences per a l'emmagatzematge local
final sharedPreferencesProvider = FutureProvider(
  (ref) => SharedPreferences.getInstance(),
);

/// Proveïdor per obtenir la instància de Firebase Firestore per a la base de dades
final firebaseFirestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

/// Proveïdor per obtenir la instància de Firebase Auth per a l'autenticació d'usuaris
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

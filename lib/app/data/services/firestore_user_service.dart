import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/constants/collections.dart';
import 'package:swardenapp/app/core/global_providers.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';

final firestoreUserServiceProvider = Provider<FirestoreUserService>(
  (ref) =>
      FirestoreUserService(firestore: ref.watch(firebaseFirestoreProvider)),
);

/// Servei per gestionar usuaris a Firestore
class FirestoreUserService {
  final FirebaseFirestore firestore;

  FirestoreUserService({required this.firestore});

  /// Crear nou usuari a Firestore
  Future<void> createUser({required UserModel user}) async {
    try {
      await firestore
          .collection(Collections.users)
          .doc(user.uid)
          .set(user.toJson());
    } on FirebaseException catch (e) {
      throw 'Error creant vault: ${e.message}';
    }
  }

  /// Carregar model d'usuari des de Firestore
  Future<UserModel?> loadUser(String uid) async {
    try {
      final doc = await firestore.collection(Collections.users).doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } on FirebaseException catch (e) {
      throw 'Error carregant usuari: ${e.message}';
    }
  }

  /// Actualitzar model d'usuari
  Future<void> updateUser({required UserModel user}) async {
    try {
      await firestore
          .collection(Collections.users)
          .doc(user.uid)
          .update(user.toJson());
    } on FirebaseException catch (e) {
      throw 'Error actualitzant usuari: ${e.message}';
    }
  }

  /// Eliminar model d'usuari
  Future<bool> deleteUser(String uid) async {
    try {
      final entriesQuery = await firestore
          .collection(Collections.users)
          .doc(uid)
          .collection(Collections.entries)
          .get();

      final batch = firestore.batch();
      for (final doc in entriesQuery.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(firestore.collection(Collections.users).doc(uid));

      await batch.commit();
      return true;
    } on FirebaseException catch (e) {
      throw 'Error eliminant usuari: ${e.message}';
    }
  }
}

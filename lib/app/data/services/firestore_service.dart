import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/constants/collections.dart';
import 'package:swardenapp/app/core/global_providers.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(firestore: ref.watch(firebaseFirestoreProvider)),
);

class FirestoreService {
  final FirebaseFirestore firestore;

  FirestoreService({required this.firestore});

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

  /// Carregar vault d'usuari des de Firestore
  Future<UserModel?> loadUser(String uid) async {
    try {
      final doc = await firestore.collection(Collections.users).doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } on FirebaseException catch (e) {
      throw 'Error carregant vault: ${e.message}';
    }
  }

  /// Actualitzar vault d'usuari
  Future<void> updateUser({required UserModel user}) async {
    try {
      await firestore
          .collection(Collections.users)
          .doc(user.uid)
          .update(user.toJson());
    } on FirebaseException catch (e) {
      throw 'Error actualitzant vault: ${e.message}';
    }
  }

  /// Eliminar vault d'usuari
  Future<void> deleteUser(String uid) async {
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

      // Eliminar el document d'usuari
      batch.delete(firestore.collection(Collections.users).doc(uid));

      await batch.commit();
    } on FirebaseException catch (e) {
      throw 'Error eliminant vault: ${e.message}';
    }
  }

  /// Crear entrada xifrada
  Future<void> createEntry({
    required String uid,
    required EntryModel entry,
  }) async {
    try {
      await firestore
          .collection(Collections.users)
          .doc(uid)
          .collection(Collections.entries)
          .doc(entry.id)
          .set(entry.toJson());
    } on FirebaseException catch (e) {
      throw 'Error creant entrada: ${e.message}';
    }
  }

  /// Carregar totes les entrades d'un usuari
  Future<List<EntryModel>> loadUserEntries(String uid) async {
    try {
      final querySnapshot = await firestore
          .collection(Collections.users)
          .doc(uid)
          .collection(Collections.entries)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return EntryModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e) {
      throw 'Error carregant entrades: ${e.message}';
    }
  }

  /// Actualitzar entrada
  Future<void> updateEntry({
    required String uid,
    required String entryId,
    required int version,
    required String encryptedData,
  }) async {
    try {
      await firestore
          .collection(Collections.users)
          .doc(uid)
          .collection(Collections.entries)
          .doc(entryId)
          .update({
            'version': version,
            'encryptedData': encryptedData,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } on FirebaseException catch (e) {
      throw 'Error actualitzant entrada: ${e.message}';
    }
  }

  /// Eliminar entrada
  Future<void> deleteEntry({
    required String uid,
    required String entryId,
  }) async {
    try {
      await firestore
          .collection(Collections.users)
          .doc(uid)
          .collection(Collections.entries)
          .doc(entryId)
          .delete();
    } on FirebaseException catch (e) {
      throw 'Error eliminant entrada: ${e.message}';
    }
  }
}

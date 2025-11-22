import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/constants/collections.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';

/// Proveïdor del servei d'entrades de Firestore
final firestoreEntryServiceProvider = Provider<FirestoreEntryService>((ref) {
  return FirestoreEntryService(firestore: FirebaseFirestore.instance);
});

/// Servei per gestionar les entrades a Firestore
class FirestoreEntryService {
  final FirebaseFirestore _firestore;

  FirestoreEntryService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  /// Crea una nova entrada a Firestore (ja xifrada)
  Future<bool> createEntry({
    required String userId,
    required EntryModel entry,
  }) async {
    try {
      await _firestore
          .collection(Collections.users)
          .doc(userId)
          .collection(Collections.entries)
          .doc(entry.id)
          .set(entry.toJson());

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error creant entrada: $e');
      }
      return false;
    }
  }

  /// Recupera totes les entrades d'un usuari
  Future<List<EntryModel>> getUserEntries(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(Collections.users)
          .doc(userId)
          .collection(Collections.entries)
          .get();

      return snapshot.docs
          .map((doc) => EntryModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error obtenint entrades: $e');
      }
      return [];
    }
  }

  /// Recupera una entrada específica
  Future<EntryModel?> getEntry(String userId, String entryId) async {
    try {
      final doc = await _firestore
          .collection(Collections.users)
          .doc(userId)
          .collection(Collections.entries)
          .doc(entryId)
          .get();

      if (doc.exists && doc.data() != null) {
        return EntryModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error obtenint entrada: $e');
      }
      return null;
    }
  }

  /// Actualitza una entrada existent a Firestore
  Future<bool> updateEntry({
    required String userId,
    required EntryModel entry,
  }) async {
    try {
      await _firestore
          .collection(Collections.users)
          .doc(userId)
          .collection(Collections.entries)
          .doc(entry.id)
          .set(entry.toJson());

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error actualitzant entrada: $e');
      }
      return false;
    }
  }

  /// Elimina una entrada
  Future<bool> deleteEntry(String userId, String entryId) async {
    try {
      await _firestore
          .collection(Collections.users)
          .doc(userId)
          .collection(Collections.entries)
          .doc(entryId)
          .delete();

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error eliminant entrada: $e');
      }
      return false;
    }
  }
}

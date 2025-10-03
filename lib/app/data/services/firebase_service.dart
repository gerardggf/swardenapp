import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/core/exceptions/auth_exception.dart';
import 'package:swardenapp/app/core/exceptions/firestore_exception.dart';
import 'package:swardenapp/app/data/services/crypto_service.dart';
import 'package:swardenapp/app/domain/models/entry_model.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  final crypto = ref.watch(cryptoServiceProvider);
  return FirebaseService(crypto);
});

/// Servei Firebase integrat amb el model Zero-Knowledge
///
/// ESTRUCTURA FIRESTORE:
/// ```
/// users/{uid}/
///   ├── version: int
///   ├── salt: String
///   ├── dekBox: String (DEK xifrada amb KEK)
///   ├── createdAt: Timestamp
///   └── entries/{entryId}/
///       ├── version: int
///       ├── box: String (dades xifrades amb DEK)
///       ├── title: String (xifrat)
///       ├── category: String (xifrat)
///       ├── createdAt: Timestamp
///       └── updatedAt: Timestamp
/// ```
///
/// El model zero-knowledge garanteix que Firebase només veu dades xifrades.
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CryptoService _crypto;

  FirebaseService(this._crypto);

  // ========== GESTIÓ D'AUTENTICACIÓ ==========

  /// Usuari actual autenticat a Firebase
  User? get currentUser => _auth.currentUser;

  /// UID de l'usuari actual
  String? get currentUid => _auth.currentUser?.uid;

  /// Stream per escoltar canvis d'autenticació
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// REGISTRE: Crea compte Firebase + bòvada zero-knowledge
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Crear compte a Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Error creant usuari a Firebase');
      }

      // 2. Crear bòvada zero-knowledge
      final userVault = _crypto.createUserVault(password);

      // 3. Desar bòvada xifrada a Firestore
      await _saveUserVault(credential.user!.uid, userVault);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Error en registre: $e');
    }
  }

  /// LOGIN: Autentica a Firebase + desbloqueja bòveda
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login a Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Error d\'autenticació');
      }

      // 2. Carregar i desbloquejar bòvada
      final userVault = await loadUserVault(credential.user!.uid);
      if (userVault == null) {
        throw AuthException('No s\'ha trobat la bòvada de l\'usuari');
      }

      // 3. Desbloquejar amb la contrasenya
      final unlocked = _crypto.unlockVault(password, userVault);
      if (!unlocked) {
        throw AuthException('Contrasenya incorrecta per la bòvada');
      }

      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Error en login: $e');
    }
  }

  /// LOGOUT: Tanca sessió Firebase + bloqueja bòvada
  Future<void> signOut() async {
    try {
      // 1. Bloquejar bòvada (esborra DEK de memòria)
      _crypto.lockVault();

      // 2. Logout de Firebase
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Error en logout: $e');
    }
  }

  // ========== GESTIÓ DE BÒVADA D'USUARI ==========

  /// Desa la bòvada de l'usuari a Firestore
  Future<void> _saveUserVault(String uid, UserModel userVault) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        ...userVault.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Error desant bòvada d\'usuari: $e');
    }
  }

  /// Carrega la bòvada de l'usuari des de Firestore
  Future<UserModel?> loadUserVault(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw FirestoreException('Error carregant bòvada d\'usuari: $e');
    }
  }

  // ========== GESTIÓ D'ENTRADES XIFRADES ==========

  /// Crea una nova entrada xifrada
  Future<String> createEntry({
    required String title,
    required String content,
    required String category,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (!_crypto.isVaultUnlocked) {
        throw FirestoreException('La bòvada no està desbloquejada');
      }

      if (currentUid == null) {
        throw AuthException('Usuari no autenticat');
      }

      // 1. Xifrar dades amb la DEK de la sessió
      final titleEntry = _crypto.encryptEntry(title);
      final contentEntry = _crypto.encryptEntry(content);
      final categoryEntry = _crypto.encryptEntry(category);

      // 2. Crear document a Firestore
      final entryRef = _firestore
          .collection('users')
          .doc(currentUid!)
          .collection('entries')
          .doc();

      await entryRef.set({
        'version': titleEntry.version,
        'titleBox': titleEntry.box,
        'contentBox': contentEntry.box,
        'categoryBox': categoryEntry.box,
        'metadata': metadata ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return entryRef.id;
    } catch (e) {
      throw FirestoreException('Error creant entrada: $e');
    }
  }

  /// Llegeix una entrada i la desxifra
  Future<DecryptedEntry?> getEntry(String entryId) async {
    try {
      if (!_crypto.isVaultUnlocked) {
        throw FirestoreException('La bòvada no està desbloquejada');
      }

      if (currentUid == null) {
        throw AuthException('Usuari no autenticat');
      }

      final doc = await _firestore
          .collection('users')
          .doc(currentUid!)
          .collection('entries')
          .doc(entryId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;

      // Desxifrar camps
      final titleEntry = EntryModel(
        version: data['version'],
        box: data['titleBox'],
      );
      final contentEntry = EntryModel(
        version: data['version'],
        box: data['contentBox'],
      );
      final categoryEntry = EntryModel(
        version: data['version'],
        box: data['categoryBox'],
      );

      return DecryptedEntry(
        id: entryId,
        title: _crypto.decryptEntry(titleEntry),
        content: _crypto.decryptEntry(contentEntry),
        category: _crypto.decryptEntry(categoryEntry),
        metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      throw FirestoreException('Error carregant entrada: $e');
    }
  }

  /// Llista totes les entrades de l'usuari (només metadades)
  Future<List<EntryMetadata>> getUserEntries() async {
    try {
      if (currentUid == null) {
        throw AuthException('Usuari no autenticat');
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUid!)
          .collection('entries')
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return EntryMetadata(
          id: doc.id,
          hasContent: data['contentBox'] != null,
          metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
        );
      }).toList();
    } catch (e) {
      throw FirestoreException('Error carregant llista d\'entrades: $e');
    }
  }

  /// Actualitza una entrada existent
  Future<void> updateEntry({
    required String entryId,
    String? title,
    String? content,
    String? category,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (!_crypto.isVaultUnlocked) {
        throw FirestoreException('La bòvada no està desbloquejada');
      }

      if (currentUid == null) {
        throw AuthException('Usuari no autenticat');
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Xifrar només els camps que es volen actualitzar
      if (title != null) {
        final titleEntry = _crypto.encryptEntry(title);
        updateData['titleBox'] = titleEntry.box;
      }

      if (content != null) {
        final contentEntry = _crypto.encryptEntry(content);
        updateData['contentBox'] = contentEntry.box;
      }

      if (category != null) {
        final categoryEntry = _crypto.encryptEntry(category);
        updateData['categoryBox'] = categoryEntry.box;
      }

      if (metadata != null) {
        updateData['metadata'] = metadata;
      }

      await _firestore
          .collection('users')
          .doc(currentUid!)
          .collection('entries')
          .doc(entryId)
          .update(updateData);
    } catch (e) {
      throw FirestoreException('Error actualitzant entrada: $e');
    }
  }

  /// Elimina una entrada
  Future<void> deleteEntry(String entryId) async {
    try {
      if (currentUid == null) {
        throw AuthException('Usuari no autenticat');
      }

      await _firestore
          .collection('users')
          .doc(currentUid!)
          .collection('entries')
          .doc(entryId)
          .delete();
    } catch (e) {
      throw FirestoreException('Error eliminant entrada: $e');
    }
  }

  // ========== UTILITATS ==========

  /// Converteix codis d'error de Firebase a missatges llegibles
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No s\'ha trobat cap usuari amb aquest email';
      case 'wrong-password':
        return 'Contrasenya incorrecta';
      case 'email-already-in-use':
        return 'Aquest email ja està registrat';
      case 'weak-password':
        return 'La contrasenya és massa feble';
      case 'invalid-email':
        return 'Format d\'email invàlid';
      case 'too-many-requests':
        return 'Masses intents. Prova més tard';
      default:
        return 'Error d\'autenticació: $code';
    }
  }
}

/// Model per entrada desxifrada
class DecryptedEntry {
  final String id;
  final String title;
  final String content;
  final String category;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DecryptedEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.metadata,
    this.createdAt,
    this.updatedAt,
  });
}

/// Model per metadades d'entrada (sense desxifrar contingut)
class EntryMetadata {
  final String id;
  final bool hasContent;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EntryMetadata({
    required this.id,
    required this.hasContent,
    required this.metadata,
    this.createdAt,
    this.updatedAt,
  });
}

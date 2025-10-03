import 'package:flutter/foundation.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';
import 'package:swardenapp/app/domain/repos/auth_repo.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/crypto_service.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseAuthService firebaseAuthService;
  final FirestoreService firestoreService;
  final CryptoService cryptoService;

  AuthRepoImpl({
    required this.firebaseAuthService,
    required this.firestoreService,
    required this.cryptoService,
  });

  @override
  Future<UserModel?> register(String email, String password) async {
    try {
      // Crear usuari a Firebase Auth
      final credential = await firebaseAuthService.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;

      // Crear element del usuari a Firestore
      // Retornar salt i dekBox
      final vaultData = cryptoService.createUserVault(password);
      final user = UserModel(
        uid: credential.user!.uid,
        email: credential.user!.email ?? email,
        salt: vaultData.$1,
        dekBox: vaultData.$2,
      );
      await firestoreService.createUser(user: user);

      return user;
    } catch (e) {
      if (kDebugMode) {
        print('Error en registre: $e');
      }
      return null;
    }
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;

      final user = await firestoreService.loadUser(credential.user!.uid);
      return user;
    } catch (e) {
      if (kDebugMode) {
        print('Error en login: $e');
      }
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await firebaseAuthService.signOut();
  }
}

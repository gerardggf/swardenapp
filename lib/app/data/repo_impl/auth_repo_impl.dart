import 'package:firebase_auth/firebase_auth.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';
import 'package:swardenapp/app/domain/repos/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UserModel?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? email,

          salt: '',
          dekBox: '',
        );
      }
      return null;
    } catch (e) {
      print('Error en registre: $e');
      return null;
    }
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? email,
          version: 1,
          salt: '',
          dekBox: '',
        );
      }
      return null;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

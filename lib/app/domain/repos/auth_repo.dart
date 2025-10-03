import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swardenapp/app/data/repo_impl/auth_repo_impl.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';

final authRepoProvider = Provider<AuthRepo>((ref) => AuthRepoImpl());

abstract class AuthRepo {
  Future<UserModel?> signIn(String email, String password);
  Future<void> signOut();
  Future<UserModel?> register(String email, String password);
}

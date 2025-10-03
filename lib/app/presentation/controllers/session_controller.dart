import 'package:flutter_riverpod/legacy.dart';
import 'package:swardenapp/app/domain/repos/auth_repo.dart';
import '../../domain/models/user_model.dart';

final sessionNotifierProvider =
    StateNotifierProvider<SessionController, UserModel?>(
      (ref) => SessionController(null, ref.watch(authRepoProvider)),
    );

class SessionController extends StateNotifier<UserModel?> {
  final AuthRepo authRepo;

  SessionController(super.state, this.authRepo);

  Future<void> register(String email, String password) async {
    final user = await authRepo.register(email, password);
    state = user;
  }

  Future<void> signIn(String email, String password) async {
    final userModel = await authRepo.signIn(email, password);

    state = userModel;
  }

  Future<void> signOut() async {
    await authRepo.signOut();
    state = null;
  }
}

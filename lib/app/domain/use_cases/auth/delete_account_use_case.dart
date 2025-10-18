import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/domain/repos/auth_repo.dart';
import 'package:swardenapp/app/core/utils/swarden_exceptions/swarden_exceptions.dart';
import 'package:swardenapp/app/domain/use_cases/base_use_case.dart';

class DeleteAccountParams {
  final String password;

  DeleteAccountParams({required this.password});
}

/// Cas d'ús per eliminar el compte d'usuari
class DeleteAccountUseCase implements UseCase<bool, DeleteAccountParams> {
  final AuthRepo authRepo;

  DeleteAccountUseCase(this.authRepo);

  @override
  Future<Either<SwardenException, bool>> call(
    DeleteAccountParams params,
  ) async {
    try {
      final reauthenticated = await authRepo.reauthenticate(params.password);
      if (!reauthenticated) {
        return Either.left(SwardenException.wrongPassword());
      }

      final result = await authRepo.deleteAccount();
      return Either.right(result);
    } catch (e) {
      return Either.left(SwardenException.undefined(message: e.toString()));
    }
  }
}

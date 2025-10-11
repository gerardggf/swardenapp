import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/domain/repos/auth_repo.dart';
import 'package:swardenapp/app/core/utils/swarden_exceptions/swarden_exceptions.dart';
import 'package:swardenapp/app/domain/use_cases/base_use_case.dart';

/// Cas d'ús per eliminar el compte d'usuari
class DeleteAccountUseCase implements UseCaseNoParams<bool> {
  final AuthRepo authRepo;

  DeleteAccountUseCase(this.authRepo);

  @override
  Future<Either<SwardenException, bool>> call() async {
    try {
      final result = await authRepo.deleteAccount();
      return Either.right(result);
    } catch (e) {
      return Either.left(SwardenException.undefined(message: e.toString()));
    }
  }
}

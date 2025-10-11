import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/domain/models/user_model.dart';
import 'package:swardenapp/app/domain/repos/auth_repo.dart';
import 'package:swardenapp/app/core/utils/swarden_exceptions/swarden_exceptions.dart';
import 'package:swardenapp/app/domain/use_cases/base_use_case.dart';

/// Cas d'ús per obtenir l'usuari actual
class GetCurrentUserUseCase implements UseCaseNoParams<UserModel?> {
  final AuthRepo authRepo;

  GetCurrentUserUseCase(this.authRepo);

  @override
  Future<Either<SwardenException, UserModel?>> call() async {
    return await authRepo.getCurrentUser();
  }
}

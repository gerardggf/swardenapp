import 'package:swardenapp/app/domain/either/either.dart';
import 'package:swardenapp/app/domain/swarden_exceptions/swarden_exceptions.dart';

/// Interfície base per tots els casos d'ús
abstract class UseCase<T, Params> {
  Future<Either<SwardenException, T>> call(Params params);
}

/// Cas d'ús sense paràmetres
abstract class UseCaseNoParams<T> {
  Future<Either<SwardenException, T>> call();
}

/// Cas d'ús síncron
abstract class SyncUseCase<T, Params> {
  Either<SwardenException, T> call(Params params);
}

/// Cas d'ús síncron sense paràmetres
abstract class SyncUseCaseNoParams<T> {
  Either<SwardenException, T> call();
}

/// Paràmetres buits per casos d'ús sense paràmetres
class NoParams {
  const NoParams();
}

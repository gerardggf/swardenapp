import 'package:swardenapp/app/core/utils/either/either.dart';
import 'package:swardenapp/app/core/utils/swarden_exceptions/swarden_exceptions.dart';

/// Drecera per a resultats que poden ser èxits o errors de Swarden
typedef SwardenResult<T> = Either<SwardenException, T>;

/// Drecera per a futures que retornen resultats de Swarden que poden ser èxits o errors
typedef AsyncSwardenResult<T> = Future<Either<SwardenException, T>>;

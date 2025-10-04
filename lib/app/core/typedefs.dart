import 'package:swardenapp/app/domain/either/either.dart';
import 'package:swardenapp/app/domain/swarden_exceptions/swarden_exceptions.dart';

typedef SwardenResult<T> = Either<SwardenException, T>;

typedef AsyncSwardenResult<T> = Future<Either<SwardenException, T>>;

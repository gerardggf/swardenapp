import 'package:freezed_annotation/freezed_annotation.dart';

part 'swarden_exceptions.freezed.dart';

/// Excepcions específiques de la app de Swarden per a la gestió d'errors
@freezed
class SwardenException with _$SwardenException {
  const factory SwardenException.emailAlreadyExists() = EmailAlreadyExists;
  const factory SwardenException.insufficientPermission() =
      InsufficientPermission;
  const factory SwardenException.internalError() = InternalError;
  const factory SwardenException.invalidCredential() = InvalidCredential;
  const factory SwardenException.wrongPassword() = WrongPassword;
  const factory SwardenException.invalidEmail() = InvalidEmail;
  const factory SwardenException.userNotFound() = UserNotFound;
  const factory SwardenException.invalidIdToken() = InvalidIdToken;
  const factory SwardenException.userDisabled() = UserDisabled;
  const factory SwardenException.operationNotAllowed() = OperationNotAllowed;
  const factory SwardenException.invalidPassword() = InvalidPassword;
  const factory SwardenException.tooManyRequests() = TooManyRequests;
  const factory SwardenException.weakPassword() = WeakPassword;
  const factory SwardenException.userAlreadyExists() = UserAlreadyExists;
  const factory SwardenException.requiresRecentLogin() = RequiresRecentLogin;
  const factory SwardenException.noCredentials() = NoCredentials;
  const factory SwardenException.noData() = NoData;
  const factory SwardenException.wrongPin() = WrongPin;
  const factory SwardenException.undefined({required String message}) =
      Undefined;
}

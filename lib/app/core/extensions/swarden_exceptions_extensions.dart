import 'package:swardenapp/app/domain/swarden_exceptions/swarden_exceptions.dart';

import '../generated/translations.g.dart';

extension StringSwardenExceptionsExtension on String {
  SwardenException fromFirebaseError() {
    final Map<String, SwardenException> errors = {
      "email-already-in-use": const SwardenException.emailAlreadyExists(),
      "insufficient-permission":
          const SwardenException.insufficientPermission(),
      "internal-error": const SwardenException.internalError(),
      "invalid-credential": const SwardenException.invalidCredential(),
      "invalid-email": const SwardenException.invalidEmail(),
      "invalid-id-token": const SwardenException.invalidIdToken(),
      "invalid-password": const SwardenException.invalidPassword(),
      "operation-not-allowed": const SwardenException.operationNotAllowed(),
      "too-many-requests": const SwardenException.tooManyRequests(),
      "wrong-password": const SwardenException.wrongPassword(),
      "user-not-found": const SwardenException.userNotFound(),
      "user-disabled": const SwardenException.userDisabled(),
      "weak-password": const SwardenException.weakPassword(),
      "undefined": SwardenException.undefined(message: this),
      "user-already-exists": const SwardenException.userAlreadyExists(),
      "requires-recent-login": const SwardenException.requiresRecentLogin(),
    };
    return errors[this] ?? SwardenException.undefined(message: this);
  }
}

extension SwardenExceptionsExtension on SwardenException {
  String toText() {
    if (this is Undefined) {
      return texts.auth.anErrorHasOccurred;
    }
    final Map<SwardenException, String> errorsTexts = {
      const SwardenException.emailAlreadyExists():
          texts.auth.emailAlreadyExists,
      const SwardenException.insufficientPermission():
          texts.auth.insufficientPermissions,
      const SwardenException.internalError(): texts.auth.internalError,
      const SwardenException.invalidCredential(): texts.auth.invalidCredential,
      const SwardenException.invalidEmail(): texts.auth.invalidEmail,
      const SwardenException.invalidIdToken(): texts.auth.anErrorHasOccurred,
      const SwardenException.invalidPassword(): texts.auth.invalidPassword,
      const SwardenException.operationNotAllowed():
          texts.auth.operationNotAllowed,
      const SwardenException.tooManyRequests(): texts.auth.tooManyRequests,
      const SwardenException.wrongPassword(): texts.auth.wrongPassword,
      const SwardenException.userNotFound(): texts.auth.userNotFound,
      const SwardenException.userDisabled(): texts.auth.userDisabled,
      const SwardenException.weakPassword(): texts.auth.passwordIsTooWeak,
      const SwardenException.userAlreadyExists(): texts.auth.userAlreadyExists,
      const SwardenException.requiresRecentLogin():
          texts.auth.requiresRecentLogin,
      const SwardenException.noCredentials(): texts.auth.noCredentials,
      const SwardenException.noData(): texts.auth.noData,
    };
    return errorsTexts[this] ?? texts.auth.anErrorHasOccurred;
  }
}

import '../generated/translations.g.dart';

/// Excepción que indica que la bóveda está bloqueada
class LockedException implements Exception {
  final String message;

  LockedException([String? customMessage])
    : message = customMessage ?? texts.global.vaultLocked;

  @override
  String toString() => 'LockedException: $message';
}

/// Excepció que indica que la bóveda està bloquejada
class LockedException implements Exception {
  final String message;
  const LockedException([
    this.message =
        'La bóveda està bloquejada. Cal desbloquejar-la primer.', //TODO:traducir
  ]);

  @override
  String toString() => 'LockedException: $message';
}

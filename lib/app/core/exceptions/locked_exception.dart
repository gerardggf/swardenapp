class LockedException implements Exception {
  final String message;
  const LockedException([
    this.message =
        'La bòvada està bloquejada. Cal desbloquejar-la primer.', //TODO:traducir
  ]);

  @override
  String toString() => 'LockedException: $message';
}

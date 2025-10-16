import 'package:encrypt/encrypt.dart';
import 'package:swardenapp/app/core/exceptions/locked_exception.dart';

/// Model per guardar a la memòria RAM la DEK desxifrada i l'estat de bloqueig
class VaultSession {
  final Key _dek;
  bool _isLocked;

  VaultSession._(this._dek) : _isLocked = false;

  factory VaultSession.create(Key dek) => VaultSession._(dek);

  Key get dek {
    if (_isLocked) throw LockedException();
    return _dek;
  }

  bool get isLocked => _isLocked;

  void lock() => _isLocked = true;
  void unlock() => _isLocked = false;
}

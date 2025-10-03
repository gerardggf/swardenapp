import 'package:encrypt/encrypt.dart';
import 'package:swardenapp/app/core/exceptions/locked_exception.dart';

/// Model per guardar a la RAM la sessió de la bòvada amb la DEK en memòria
class SessionModel {
  /// Clau d'encriptació de les dades
  final Key _dek;
  bool _isLocked;

  SessionModel._(this._dek) : _isLocked = false;

  factory SessionModel.create(Key dek) => SessionModel._(dek);

  Key get dek {
    if (_isLocked) throw const LockedException();
    return _dek;
  }

  bool get isLocked => _isLocked;

  void lock() => _isLocked = true;
  void unlock() => _isLocked = false;
}

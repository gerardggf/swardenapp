import 'package:freezed_annotation/freezed_annotation.dart';

part 'either.freezed.dart';

/// Classe genèrica per representar un valor que pot ser d'un tipus o d'un altre
@freezed
abstract class Either<L, R> with _$Either<L, R> {
  factory Either.left(L value) = Left;
  factory Either.right(R value) = Right;
}

extension EitherExtension<L, R> on Either<L, R> {
  bool isLeft() => this is Left<L, R>;
  bool isRight() => this is Right<L, R>;

  L getLeft() {
    if (this is Left<L, R>) {
      return (this as Left<L, R>).value;
    } else {
      throw StateError('No left value');
    }
  }

  R getRight() {
    if (this is Right<L, R>) {
      return (this as Right<L, R>).value;
    } else {
      throw StateError('No right value');
    }
  }
}

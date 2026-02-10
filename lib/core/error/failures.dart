import 'package:equatable/equatable.dart';

/// Failure abstract class — dartz Either bilan ishlatiladi
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server xatoligi']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Internet bilan aloqa yo\'q']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache xatoligi']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Autentifikatsiya xatosi']);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure([
    super.message = 'Validatsiya xatoligi',
    this.errors,
  ]);

  @override
  List<Object> get props => [message, errors ?? {}];
}

abstract class Failure {
  final String message;
  final String? code;

  Failure({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

class AuthFailure extends Failure {
  AuthFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class ServerFailure extends Failure {
  ServerFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class CacheFailure extends Failure {
  CacheFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class ValidationFailure extends Failure {
  ValidationFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class NetworkFailure extends Failure {
  NetworkFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class PolicyFailure extends Failure {
  PolicyFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class SecurityFailure extends Failure {
  SecurityFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class NotFoundFailure extends Failure {
  NotFoundFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class TimeoutFailure extends Failure {
  TimeoutFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}

class AuthenticationException extends AppException {
  AuthenticationException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'AUTH_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  ValidationException({
    required String message,
    required this.fieldErrors,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'VALIDATION_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'NETWORK_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

class StorageException extends AppException {
  StorageException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'STORAGE_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

class PolicyException extends AppException {
  PolicyException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'POLICY_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

class PermissionException extends AppException {
  PermissionException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'PERMISSION_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

class TimeoutException extends AppException {
  TimeoutException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'TIMEOUT_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

class DataException extends AppException {
  DataException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'DATA_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

class ConflictException extends AppException {
  ConflictException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code ?? 'CONFLICT_ERROR',
    originalError: originalError,
    stackTrace: stackTrace,
  );
}

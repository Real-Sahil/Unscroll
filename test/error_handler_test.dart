import 'package:flutter_test/flutter_test.dart';
import 'package:unscroll/core/errors/exceptions.dart';
import 'package:unscroll/core/utils/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    group('getErrorMessage', () {
      test('returns message for AppException', () {
        final error = AppException(
          message: 'Test error',
          code: 'TEST_CODE',
        );

        final message = ErrorHandler.getErrorMessage(error);
        expect(message, 'Test error');
      });

      test('returns first field error for ValidationException', () {
        final fieldErrors = {
          'email': 'Invalid email',
          'password': 'Password too short',
        };
        final error = ValidationException(
          message: 'Validation failed',
          fieldErrors: fieldErrors,
        );

        final message = ErrorHandler.getErrorMessage(error);
        expect(message, 'Invalid email');
      });

      test('returns message for ValidationException with no field errors', () {
        final error = ValidationException(
          message: 'General validation error',
          fieldErrors: {},
        );

        final message = ErrorHandler.getErrorMessage(error);
        expect(message, 'General validation error');
      });

      test('returns message for AuthenticationException', () {
        final error = AuthenticationException(message: 'Invalid credentials');
        final message = ErrorHandler.getErrorMessage(error);
        expect(message, 'Invalid credentials');
      });

      test('returns prefixed message for NetworkException', () {
        final error = NetworkException(message: 'Connection timeout');
        final message = ErrorHandler.getErrorMessage(error);
        expect(message, contains('Network error'));
        expect(message, contains('Connection timeout'));
      });

      test('returns prefixed message for StorageException', () {
        final error = StorageException(message: 'Disk full');
        final message = ErrorHandler.getErrorMessage(error);
        expect(message, contains('Storage error'));
      });

      test('returns timeout message for TimeoutException', () {
        final error = TimeoutException(message: 'Request timeout');
        final message = ErrorHandler.getErrorMessage(error);
        expect(message, 'Request timed out. Please try again.');
      });

      test('returns generic message for unknown error', () {
        final message = ErrorHandler.getErrorMessage('Unknown error');
        expect(message, 'An unexpected error occurred');
      });
    });

    group('getErrorCode', () {
      test('returns code from AppException', () {
        final error = AppException(
          message: 'Test error',
          code: 'CUSTOM_CODE',
        );

        final code = ErrorHandler.getErrorCode(error);
        expect(code, 'CUSTOM_CODE');
      });

      test('returns UNKNOWN_ERROR when code is null', () {
        final error = AppException(message: 'Test error');

        final code = ErrorHandler.getErrorCode(error);
        expect(code, 'UNKNOWN_ERROR');
      });

      test('returns UNKNOWN_ERROR for non-AppException', () {
        final code = ErrorHandler.getErrorCode('Some error');
        expect(code, 'UNKNOWN_ERROR');
      });
    });

    group('ValidationException', () {
      test('creates with multiple field errors', () {
        final errors = {
          'email': 'Invalid email format',
          'password': 'Password must be at least 8 characters',
          'name': 'Name is required',
        };

        final exception = ValidationException(
          message: 'Multiple validation errors',
          fieldErrors: errors,
        );

        expect(exception.fieldErrors.length, 3);
        expect(exception.fieldErrors['email'], 'Invalid email format');
      });

      test('creates with empty field errors', () {
        final exception = ValidationException(
          message: 'No field errors',
          fieldErrors: {},
        );

        expect(exception.fieldErrors, isEmpty);
      });
    });

    group('Custom Exceptions', () {
      test('creates AuthenticationException', () {
        final error = AuthenticationException(
          message: 'Unauthorized access',
          code: 'AUTH_FAILED',
        );

        expect(error.message, 'Unauthorized access');
        expect(error.code, 'AUTH_FAILED');
      });

      test('creates NetworkException', () {
        final error = NetworkException(
          message: 'Network unavailable',
          code: 'NO_INTERNET',
        );

        expect(error.message, 'Network unavailable');
        expect(error.code, 'NO_INTERNET');
      });

      test('creates StorageException', () {
        final error = StorageException(
          message: 'Failed to save data',
          code: 'STORAGE_ERROR',
        );

        expect(error.message, 'Failed to save data');
      });

      test('creates PolicyException', () {
        final error = PolicyException(
          message: 'Invalid policy configuration',
          code: 'POLICY_ERROR',
        );

        expect(error.message, 'Invalid policy configuration');
      });

      test('creates PermissionException', () {
        final error = PermissionException(
          message: 'Permission denied',
          code: 'PERMISSION_DENIED',
        );

        expect(error.message, 'Permission denied');
      });

      test('creates TimeoutException', () {
        final error = TimeoutException(
          message: 'Request timed out',
          code: 'TIMEOUT',
        );

        expect(error.message, 'Request timed out');
      });

      test('creates DataException', () {
        final error = DataException(
          message: 'Data parsing failed',
          code: 'DATA_ERROR',
        );

        expect(error.message, 'Data parsing failed');
      });

      test('creates ConflictException', () {
        final error = ConflictException(
          message: 'Resource conflict',
          code: 'CONFLICT',
        );

        expect(error.message, 'Resource conflict');
      });
    });

    group('Exception Hierarchy', () {
      test('all custom exceptions extend AppException', () {
        final errors = [
          AuthenticationException(message: 'Auth error'),
          NetworkException(message: 'Network error'),
          StorageException(message: 'Storage error'),
          PolicyException(message: 'Policy error'),
          PermissionException(message: 'Permission error'),
          TimeoutException(message: 'Timeout error'),
          DataException(message: 'Data error'),
          ConflictException(message: 'Conflict error'),
        ];

        for (final error in errors) {
          expect(error, isA<AppException>());
        }
      });

      test('ValidationException extends AppException', () {
        final error = ValidationException(
          message: 'Validation error',
          fieldErrors: {},
        );

        expect(error, isA<AppException>());
      });
    });

    group('Error Chaining', () {
      test('preserves original error in AppException', () {
        final originalError = FormatException('Invalid format');
        final appError = AppException(
          message: 'Wrapped error',
          code: 'WRAPPED',
          originalError: originalError,
        );

        expect(appError.originalError, originalError);
      });

      test('preserves stack trace', () {
        final error = AppException(
          message: 'Error with trace',
          code: 'TRACE_ERROR',
          stackTrace: StackTrace.current,
        );

        expect(error.stackTrace, isNotNull);
      });
    });

    group('createValidationError', () {
      test('creates ValidationException from field errors', () {
        final fieldErrors = {
          'email': 'Invalid email',
          'password': 'Too short',
        };

        final error = ErrorHandler.createValidationError(fieldErrors);

        expect(error, isA<ValidationException>());
        expect(error.fieldErrors, equals(fieldErrors));
        expect(error.message, contains('Please correct'));
      });

      test('preserves all field errors in created exception', () {
        final fieldErrors = {
          'email': 'Invalid format',
          'password': 'Missing uppercase',
          'name': 'Too short',
          'phone': 'Invalid length',
        };

        final error = ErrorHandler.createValidationError(fieldErrors);

        expect(error.fieldErrors.length, 4);
        expect(error.fieldErrors['email'], 'Invalid format');
        expect(error.fieldErrors['password'], 'Missing uppercase');
      });
    });
  });
}

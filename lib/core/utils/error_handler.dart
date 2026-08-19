import 'package:flutter/material.dart';
import 'package:unscroll/core/errors/exceptions.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is ValidationException) {
      if (error.fieldErrors.isEmpty) {
        return error.message;
      }
      return error.fieldErrors.values.first;
    } else if (error is AuthenticationException) {
      return error.message;
    } else if (error is NetworkException) {
      return 'Network error: ${error.message}';
    } else if (error is StorageException) {
      return 'Storage error: ${error.message}';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is Exception) {
      return error.toString();
    }
    return 'An unexpected error occurred';
  }

  static String getErrorCode(dynamic error) {
    if (error is AppException) {
      return error.code ?? 'UNKNOWN_ERROR';
    }
    return 'UNKNOWN_ERROR';
  }

  static void showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    VoidCallback? onRetry,
  }) {
    final message = getErrorMessage(error);
    final dialogTitle = title ?? 'Error';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = getErrorMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration,
      ),
    );
  }

  static void logError(dynamic error, StackTrace? stackTrace) {
    if (error is AppException) {
      // In production, send to error tracking service
      // For now, just print
      print('Error [${error.code}]: ${error.message}');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    } else {
      print('Error: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }

  static ValidationException createValidationError(Map<String, String> fieldErrors) {
    return ValidationException(
      message: 'Please correct the errors below',
      fieldErrors: fieldErrors,
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final String? title;

  const ErrorWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final message = ErrorHandler.getErrorMessage(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red[900],
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ValidationErrorWidget extends StatelessWidget {
  final Map<String, String> errors;
  final String? title;

  const ValidationErrorWidget({
    Key? key,
    required this.errors,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title ?? 'Validation Error',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.red[900],
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...errors.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.red[700])),
                  Expanded(
                    child: Text(
                      '${e.key}: ${e.value}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red[900],
                          ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class FieldErrorWidget extends StatelessWidget {
  final String? error;
  final String fieldName;

  const FieldErrorWidget({
    Key? key,
    this.error,
    required this.fieldName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              error!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

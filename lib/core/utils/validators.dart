class Validators {
  static const String emailRegex =
      r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$';

  static const String passwordRegex =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

  static const String phoneRegex = r'^[0-9]{10,}$';

  static const String urlRegex =
      r'^(https?|ftp)://[^\s/$.?#].[^\s]*$';

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final regex = RegExp(emailRegex);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    final regex = RegExp(passwordRegex);
    if (!regex.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, number, and special character';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s\'-]+$').hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {String fieldName = 'Number'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final regex = RegExp(phoneRegex);
    if (!regex.hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    final regex = RegExp(urlRegex);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid URL';
    }

    return null;
  }

  // PIN validation (4-6 digits)
  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }

    if (!RegExp(r'^[0-9]{4,6}$').hasMatch(value)) {
      return 'PIN must be 4-6 digits';
    }

    return null;
  }

  // Time format validation (HH:MM)
  static String? validateTimeFormat(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }

    if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
      return 'Time must be in HH:MM format';
    }

    return null;
  }

  // Range validation
  static String? validateRange(
    String? value, {
    required int min,
    required int max,
    String fieldName = 'Value',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    try {
      final numValue = int.parse(value);
      if (numValue < min || numValue > max) {
        return '$fieldName must be between $min and $max';
      }
    } catch (_) {
      return '$fieldName must be a valid number';
    }

    return null;
  }

  // Length validation
  static String? validateLength(
    String? value, {
    required int minLength,
    int? maxLength,
    String fieldName = 'Value',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (maxLength != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }

  // Custom regex validation
  static String? validateRegex(
    String? value,
    String pattern, {
    String errorMessage = 'Invalid format',
  }) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return errorMessage;
    }

    return null;
  }

  // Cooldown hours validation
  static String? validateCooldownHours(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cooldown hours is required';
    }

    try {
      final hours = int.parse(value);
      if (hours < 1 || hours > 72) {
        return 'Cooldown must be between 1 and 72 hours';
      }
    } catch (_) {
      return 'Must be a valid number';
    }

    return null;
  }

  // Policy name validation
  static String? validatePolicyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Policy name is required';
    }

    if (value.length < 3) {
      return 'Policy name must be at least 3 characters';
    }

    if (value.length > 50) {
      return 'Policy name must not exceed 50 characters';
    }

    return null;
  }
}

class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  ValidationResult({
    required this.isValid,
    this.errors = const {},
  });

  ValidationResult.valid() : this(isValid: true, errors: {});

  ValidationResult.invalid(this.errors) : isValid = false;

  String? getError(String fieldName) => errors[fieldName];

  bool hasError(String fieldName) => errors.containsKey(fieldName);
}

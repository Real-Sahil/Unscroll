import 'package:flutter_test/flutter_test.dart';
import 'package:unscroll/core/utils/form_validation_mixin.dart';
import 'package:unscroll/core/utils/validators.dart';

void main() {
  group('FormField', () {
    test('initializes with name and validator', () {
      final field = FormField(
        name: 'email',
        validator: Validators.validateEmail,
      );

      expect(field.name, 'email');
      expect(field.value, '');
    });

    test('initializes with initial value', () {
      final field = FormField(
        name: 'email',
        initialValue: 'test@example.com',
        validator: Validators.validateEmail,
      );

      expect(field.value, 'test@example.com');
    });

    test('validates empty field with required validator', () {
      final field = FormField(
        name: 'email',
        validator: Validators.validateEmail,
      );

      final error = field.validate();
      expect(error, isNotNull);
    });

    test('validates non-empty field', () {
      final field = FormField(
        name: 'email',
        initialValue: 'test@example.com',
        validator: Validators.validateEmail,
      );

      final error = field.validate();
      expect(error, isNull);
    });

    test('sets new value', () {
      final field = FormField(
        name: 'email',
        validator: Validators.validateEmail,
      );

      field.setValue('test@example.com');
      expect(field.value, 'test@example.com');
    });

    test('resets to initial value', () {
      final field = FormField(
        name: 'email',
        initialValue: 'original@example.com',
        validator: Validators.validateEmail,
      );

      field.setValue('new@example.com');
      expect(field.value, 'new@example.com');

      field.reset();
      expect(field.value, 'original@example.com');
    });

    test('resets to empty string when no initial value', () {
      final field = FormField(
        name: 'email',
        validator: Validators.validateEmail,
      );

      field.setValue('test@example.com');
      field.reset();
      expect(field.value, '');
    });
  });

  group('FormState', () {
    test('initializes with fields and empty errors', () {
      final field = FormField(
        name: 'email',
        validator: Validators.validateEmail,
      );

      final state = FormState(fields: {'email': field});

      expect(state.fields.length, 1);
      expect(state.errors, isEmpty);
      expect(state.isValid, true);
    });

    test('tracks dirty state', () {
      final field = FormField(
        name: 'email',
        initialValue: 'test@example.com',
        validator: Validators.validateEmail,
      );

      final state = FormState(fields: {'email': field});
      expect(state.isDirty, false);

      field.setValue('new@example.com');
      expect(state.isDirty, true);
    });

    test('validates all fields', () {
      final emailField = FormField(
        name: 'email',
        validator: Validators.validateEmail,
      );

      final passwordField = FormField(
        name: 'password',
        validator: Validators.validatePassword,
      );

      final state = FormState(fields: {
        'email': emailField,
        'password': passwordField,
      });

      final result = state.validate();
      expect(result.isValid, false);
      expect(result.errors.length, 2);
    });

    test('returns form data as map', () {
      final emailField = FormField(
        name: 'email',
        initialValue: 'test@example.com',
        validator: Validators.validateEmail,
      );

      final nameField = FormField(
        name: 'name',
        initialValue: 'John Doe',
        validator: Validators.validateName,
      );

      final state = FormState(fields: {
        'email': emailField,
        'name': nameField,
      });

      final data = state.getFormData();
      expect(data['email'], 'test@example.com');
      expect(data['name'], 'John Doe');
    });

    test('excludes empty fields from form data', () {
      final emailField = FormField(
        name: 'email',
        initialValue: 'test@example.com',
        validator: Validators.validateEmail,
      );

      final phoneField = FormField(
        name: 'phone',
        validator: Validators.validatePhone,
      );

      final state = FormState(fields: {
        'email': emailField,
        'phone': phoneField,
      });

      final data = state.getFormData();
      expect(data.containsKey('email'), true);
      expect(data.containsKey('phone'), false);
    });

    test('resets all fields', () {
      final emailField = FormField(
        name: 'email',
        initialValue: 'original@example.com',
        validator: Validators.validateEmail,
      );

      final state = FormState(fields: {'email': emailField});

      emailField.setValue('new@example.com');
      state.reset();

      expect(emailField.value, 'original@example.com');
    });

    test('returns values including null for empty fields', () {
      final emailField = FormField(
        name: 'email',
        initialValue: 'test@example.com',
        validator: Validators.validateEmail,
      );

      final phoneField = FormField(
        name: 'phone',
        validator: Validators.validatePhone,
      );

      final state = FormState(fields: {
        'email': emailField,
        'phone': phoneField,
      });

      final values = state.getValues();
      expect(values['email'], 'test@example.com');
      expect(values['phone'], isNull);
    });
  });

  group('FormBuilder', () {
    test('creates form with email field', () {
      final builder = FormBuilder();
      builder.addEmailField('email');

      final state = builder.build();
      expect(state.fields.containsKey('email'), true);
    });

    test('creates form with password field', () {
      final builder = FormBuilder();
      builder.addPasswordField('password');

      final state = builder.build();
      expect(state.fields.containsKey('password'), true);
    });

    test('creates form with name field', () {
      final builder = FormBuilder();
      builder.addNameField('name');

      final state = builder.build();
      expect(state.fields.containsKey('name'), true);
    });

    test('creates form with multiple field types', () {
      final builder = FormBuilder();
      builder.addEmailField('email');
      builder.addPasswordField('password');
      builder.addNameField('name');
      builder.addPhoneField('phone');

      final state = builder.build();
      expect(state.fields.length, 4);
      expect(state.fields.containsKey('email'), true);
      expect(state.fields.containsKey('password'), true);
      expect(state.fields.containsKey('name'), true);
      expect(state.fields.containsKey('phone'), true);
    });

    test('adds initial values to fields', () {
      final builder = FormBuilder();
      builder.addEmailField('email', initialValue: 'test@example.com');
      builder.addNameField('name', initialValue: 'John Doe');

      final state = builder.build();
      expect(state.fields['email']?.value, 'test@example.com');
      expect(state.fields['name']?.value, 'John Doe');
    });

    test('creates form with required field', () {
      final builder = FormBuilder();
      builder.addRequiredField('username');

      final state = builder.build();
      final result = state.validate();
      expect(result.isValid, false);
      expect(result.errors.containsKey('username'), true);
    });

    test('creates form with pin field', () {
      final builder = FormBuilder();
      builder.addPinField('pin');

      final state = builder.build();
      expect(state.fields.containsKey('pin'), true);
    });

    test('creates form with time field', () {
      final builder = FormBuilder();
      builder.addTimeField('startTime');

      final state = builder.build();
      expect(state.fields.containsKey('startTime'), true);
    });

    test('creates form with custom field', () {
      final builder = FormBuilder();
      builder.addCustomField(
        'custom',
        (value) => value == 'valid' ? null : 'Must be valid',
      );

      final state = builder.build();
      expect(state.fields.containsKey('custom'), true);
    });

    test('builds form state from builder', () {
      final builder = FormBuilder();
      builder.addEmailField('email', initialValue: 'test@example.com');
      builder.addPasswordField('password');

      final state = builder.build();
      expect(state.isValid, false); // password is empty
      expect(state.fields.length, 2);
    });
  });

  group('ValidationResult', () {
    test('creates valid result', () {
      final result = ValidationResult.valid();
      expect(result.isValid, true);
      expect(result.errors, isEmpty);
    });

    test('creates invalid result with errors', () {
      final errors = {
        'email': 'Invalid email',
        'password': 'Too short',
      };
      final result = ValidationResult.invalid(errors);

      expect(result.isValid, false);
      expect(result.errors, equals(errors));
    });

    test('gets error for field', () {
      final errors = {'email': 'Invalid email'};
      final result = ValidationResult.invalid(errors);

      expect(result.getError('email'), 'Invalid email');
      expect(result.getError('password'), isNull);
    });

    test('checks if field has error', () {
      final errors = {'email': 'Invalid email'};
      final result = ValidationResult.invalid(errors);

      expect(result.hasError('email'), true);
      expect(result.hasError('password'), false);
    });
  });

  group('Form Validation Scenarios', () {
    test('validates login form successfully', () {
      final builder = FormBuilder();
      builder.addEmailField('email', initialValue: 'user@example.com');
      builder.addPasswordField('password', initialValue: 'SecurePass123!');

      final state = builder.build();
      final result = state.validate();

      expect(result.isValid, true);
    });

    test('validates login form with missing email', () {
      final builder = FormBuilder();
      builder.addEmailField('email');
      builder.addPasswordField('password', initialValue: 'SecurePass123!');

      final state = builder.build();
      final result = state.validate();

      expect(result.isValid, false);
      expect(result.hasError('email'), true);
      expect(result.hasError('password'), false);
    });

    test('validates registration form', () {
      final builder = FormBuilder();
      builder.addNameField('name', initialValue: 'John Doe');
      builder.addEmailField('email', initialValue: 'john@example.com');
      builder.addPasswordField('password', initialValue: 'SecurePass123!');

      final state = builder.build();
      final result = state.validate();

      expect(result.isValid, true);
    });

    test('validates policy settings form', () {
      final builder = FormBuilder();
      builder.addRequiredField('policyName', initialValue: 'Evening Protection');
      builder.addTimeField('startTime', initialValue: '22:00');
      builder.addTimeField('endTime', initialValue: '07:00');
      builder.addCustomField(
        'cooldownHours',
        (value) => Validators.validateCooldownHours(value),
        initialValue: '24',
      );

      final state = builder.build();
      final result = state.validate();

      expect(result.isValid, true);
    });

    test('detects multiple validation errors', () {
      final builder = FormBuilder();
      builder.addEmailField('email');
      builder.addPasswordField('password');
      builder.addNameField('name');

      final state = builder.build();
      final result = state.validate();

      expect(result.isValid, false);
      expect(result.errors.length, 3);
    });
  });
}

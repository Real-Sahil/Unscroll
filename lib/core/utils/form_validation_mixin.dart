import 'package:flutter/material.dart';
import 'package:unscroll/core/utils/validators.dart';

mixin FormValidationMixin<T extends StatefulWidget> on State<T> {
  final Map<String, String> fieldErrors = {};
  bool _isValidating = false;

  void setFieldError(String fieldName, String? error) {
    setState(() {
      if (error == null || error.isEmpty) {
        fieldErrors.remove(fieldName);
      } else {
        fieldErrors[fieldName] = error;
      }
    });
  }

  void clearFieldError(String fieldName) {
    setState(() => fieldErrors.remove(fieldName));
  }

  void clearAllErrors() {
    setState(() => fieldErrors.clear());
  }

  bool hasError(String fieldName) => fieldErrors.containsKey(fieldName);

  String? getError(String fieldName) => fieldErrors[fieldName];

  bool get isValid => fieldErrors.isEmpty;

  bool get hasErrors => fieldErrors.isNotEmpty;

  int get errorCount => fieldErrors.length;

  Future<bool> validateForm(
    Map<String, String? Function()> validationRules,
  ) async {
    clearAllErrors();
    _isValidating = true;

    final errors = <String, String>{};

    for (var entry in validationRules.entries) {
      final error = entry.value();
      if (error != null && error.isNotEmpty) {
        errors[entry.key] = error;
      }
    }

    setState(() {
      fieldErrors.addAll(errors);
      _isValidating = false;
    });

    return errors.isEmpty;
  }

  Future<bool> validateField(
    String fieldName,
    String? Function() validationRule,
  ) async {
    final error = validationRule();
    setFieldError(fieldName, error);
    return error == null || error.isEmpty;
  }

  void resetForm() {
    clearAllErrors();
  }

  Map<String, String> getFormErrors() => Map.from(fieldErrors);

  String? getFirstError() {
    if (fieldErrors.isEmpty) return null;
    return fieldErrors.values.first;
  }

  List<String> getAllErrors() => fieldErrors.values.toList();
}

class FormField {
  final String name;
  final String? initialValue;
  final String? Function(String?) validator;
  late String value;

  FormField({
    required this.name,
    this.initialValue,
    required this.validator,
  }) {
    value = initialValue ?? '';
  }

  String? validate() => validator(value.isEmpty ? null : value);

  void setValue(String newValue) {
    value = newValue;
  }

  void reset() {
    value = initialValue ?? '';
  }
}

class FormState {
  final Map<String, FormField> fields;
  final Map<String, String> errors;

  FormState({
    required this.fields,
    this.errors = const {},
  });

  bool get isValid => errors.isEmpty;

  bool get isDirty => fields.values.any((f) => f.value != (f.initialValue ?? ''));

  Map<String, String?> getValues() {
    return {
      for (var entry in fields.entries)
        entry.key: entry.value.value.isEmpty ? null : entry.value.value
    };
  }

  Map<String, dynamic> getFormData() {
    final data = <String, dynamic>{};
    for (var entry in fields.entries) {
      if (entry.value.value.isNotEmpty) {
        data[entry.key] = entry.value.value;
      }
    }
    return data;
  }

  void reset() {
    for (var field in fields.values) {
      field.reset();
    }
  }

  ValidationResult validate() {
    final newErrors = <String, String>{};

    for (var entry in fields.entries) {
      final error = entry.value.validate();
      if (error != null) {
        newErrors[entry.key] = error;
      }
    }

    if (newErrors.isEmpty) {
      return ValidationResult.valid();
    }

    return ValidationResult.invalid(newErrors);
  }
}

class FormBuilder {
  final Map<String, FormField> _fields = {};

  void addField(
    String name,
    String? initialValue,
    String? Function(String?) validator,
  ) {
    _fields[name] = FormField(
      name: name,
      initialValue: initialValue,
      validator: validator,
    );
  }

  void addEmailField(String name, {String? initialValue}) {
    addField(
      name,
      initialValue,
      Validators.validateEmail,
    );
  }

  void addPasswordField(String name, {String? initialValue}) {
    addField(
      name,
      initialValue,
      Validators.validatePassword,
    );
  }

  void addNameField(String name, {String? initialValue}) {
    addField(
      name,
      initialValue,
      Validators.validateName,
    );
  }

  void addRequiredField(String name, {String? initialValue}) {
    addField(
      name,
      initialValue,
      (value) => Validators.validateRequired(value, name),
    );
  }

  void addPhoneField(String name, {String? initialValue}) {
    addField(
      name,
      initialValue,
      Validators.validatePhone,
    );
  }

  void addPinField(String name, {String? initialValue}) {
    addField(
      name,
      initialValue,
      Validators.validatePin,
    );
  }

  void addTimeField(String name, {String? initialValue}) {
    addField(
      name,
      initialValue,
      Validators.validateTimeFormat,
    );
  }

  void addCustomField(
    String name,
    String? Function(String?) validator, {
    String? initialValue,
  }) {
    addField(name, initialValue, validator);
  }

  FormState build() {
    return FormState(fields: _fields);
  }
}

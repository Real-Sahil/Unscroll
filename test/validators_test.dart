import 'package:flutter_test/flutter_test.dart';
import 'package:unscroll/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('Email Validation', () {
      test('valid email passes', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user.name+tag@example.co.uk'), isNull);
      });

      test('invalid email fails', () {
        expect(Validators.validateEmail('notanemail'), isNotNull);
        expect(Validators.validateEmail('test@'), isNotNull);
        expect(Validators.validateEmail('@example.com'), isNotNull);
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
      });
    });

    group('Password Validation', () {
      test('valid password passes', () {
        expect(
          Validators.validatePassword('SecurePass123!'),
          isNull,
        );
        expect(
          Validators.validatePassword('MyPassword@2024'),
          isNull,
        );
      });

      test('invalid password fails', () {
        expect(Validators.validatePassword('short'), isNotNull); // too short
        expect(Validators.validatePassword('nouppercase123!'), isNotNull); // no uppercase
        expect(Validators.validatePassword('NOLOWERCASE123!'), isNotNull); // no lowercase
        expect(Validators.validatePassword('NoSpecial123'), isNotNull); // no special char
        expect(Validators.validatePassword('NoNumber!'), isNotNull); // no number
      });
    });

    group('Name Validation', () {
      test('valid name passes', () {
        expect(Validators.validateName('John Doe'), isNull);
        expect(Validators.validateName('Mary-Jane'), isNull);
        expect(Validators.validateName("O'Brien"), isNull);
      });

      test('invalid name fails', () {
        expect(Validators.validateName(''), isNotNull);
        expect(Validators.validateName('A'), isNotNull); // too short
        expect(Validators.validateName('A' * 51), isNotNull); // too long
        expect(Validators.validateName('John123'), isNotNull); // contains number
        expect(Validators.validateName('John@Doe'), isNotNull); // contains invalid char
      });
    });

    group('PIN Validation', () {
      test('valid PIN passes', () {
        expect(Validators.validatePin('1234'), isNull);
        expect(Validators.validatePin('123456'), isNull);
      });

      test('invalid PIN fails', () {
        expect(Validators.validatePin('123'), isNotNull); // too short
        expect(Validators.validatePin('1234567'), isNotNull); // too long
        expect(Validators.validatePin('abcd'), isNotNull); // not digits
        expect(Validators.validatePin(''), isNotNull); // empty
      });
    });

    group('Time Format Validation', () {
      test('valid time passes', () {
        expect(Validators.validateTimeFormat('00:00'), isNull);
        expect(Validators.validateTimeFormat('12:30'), isNull);
        expect(Validators.validateTimeFormat('23:59'), isNull);
      });

      test('invalid time fails', () {
        expect(Validators.validateTimeFormat('25:00'), isNotNull); // hour > 23
        expect(Validators.validateTimeFormat('12:60'), isNotNull); // minute > 59
        expect(Validators.validateTimeFormat('1230'), isNotNull); // no colon
        expect(Validators.validateTimeFormat(''), isNotNull); // empty
      });
    });

    group('Phone Validation', () {
      test('valid phone passes', () {
        expect(Validators.validatePhone('1234567890'), isNull);
        expect(Validators.validatePhone('+1-234-567-8900'), isNull);
      });

      test('invalid phone fails', () {
        expect(Validators.validatePhone('123'), isNotNull); // too short
        expect(Validators.validatePhone('abc'), isNotNull); // not a number
        expect(Validators.validatePhone(''), isNotNull); // empty
      });
    });

    group('Required Field Validation', () {
      test('valid value passes', () {
        expect(Validators.validateRequired('value', 'Field'), isNull);
      });

      test('invalid value fails', () {
        expect(Validators.validateRequired('', 'Field'), isNotNull);
        expect(Validators.validateRequired(null, 'Field'), isNotNull);
      });
    });

    group('Cooldown Hours Validation', () {
      test('valid cooldown passes', () {
        expect(Validators.validateCooldownHours('1'), isNull);
        expect(Validators.validateCooldownHours('24'), isNull);
        expect(Validators.validateCooldownHours('72'), isNull);
      });

      test('invalid cooldown fails', () {
        expect(Validators.validateCooldownHours('0'), isNotNull); // < 1
        expect(Validators.validateCooldownHours('73'), isNotNull); // > 72
        expect(Validators.validateCooldownHours('abc'), isNotNull); // not a number
      });
    });

    group('Policy Name Validation', () {
      test('valid policy name passes', () {
        expect(Validators.validatePolicyName('My Policy'), isNull);
        expect(Validators.validatePolicyName('Evening Protection'), isNull);
      });

      test('invalid policy name fails', () {
        expect(Validators.validatePolicyName('ab'), isNotNull); // too short
        expect(Validators.validatePolicyName('A' * 51), isNotNull); // too long
        expect(Validators.validatePolicyName(''), isNotNull); // empty
      });
    });
  });
}

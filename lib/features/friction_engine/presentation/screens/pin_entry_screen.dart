import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/config/theme.dart';
import '../../../friction_engine/providers/friction_provider.dart';

class PinEntryScreen extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const PinEntryScreen({
    super.key,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  String _pin = '';
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final frictionState = ref.watch(frictionEngineProvider);
    final friction = ref.read(frictionEngineProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        title: const Text('Enter PIN'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (frictionState.isAccountLocked)
                _BuildLockedUI(
                  remainingMinutes: friction.getLockoutRemainingMinutes(),
                )
              else ...[
                Text(
                  'Enter your 4-digit PIN',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _PinDisplay(pin: _pin),
                const SizedBox(height: 32),
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Attempts remaining: ${frictionState.attemptsRemaining}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: frictionState.attemptsRemaining <= 2
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 40),
                _PinPad(
                  onDigitPressed: _onDigitPressed,
                  onBackspace: _onBackspace,
                  onSubmit: () => _onSubmit(context, friction),
                  canSubmit: _pin.length == 4,
                  canBackspace: _pin.isNotEmpty,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onDigitPressed(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
        _errorMessage = '';
      });
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = '';
      });
    }
  }

  Future<void> _onSubmit(BuildContext context, FrictionNotifier friction) async {
    if (_pin.length != 4) return;

    final success = await friction.verifyPin(_pin);
    if (success) {
      if (context.mounted) {
        widget.onSuccess();
      }
    } else {
      setState(() {
        _pin = '';
        _errorMessage = 'Incorrect PIN. Try again.';
      });
    }
  }
}

class _PinDisplay extends StatelessWidget {
  final String pin;

  const _PinDisplay({required this.pin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isFilled ? AppColors.primary : AppColors.borderColor,
              width: isFilled ? 2 : 1,
            ),
            color: isFilled ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          ),
          child: isFilled
              ? Icon(Icons.circle, color: AppColors.primary, size: 24)
              : null,
        );
      }),
    );
  }
}

class _PinPad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final bool canSubmit;
  final bool canBackspace;

  const _PinPad({
    required this.onDigitPressed,
    required this.onBackspace,
    required this.onSubmit,
    required this.canSubmit,
    required this.canBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Rows 1-3: Digits 1-9
        ...List.generate(3, (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (colIndex) {
                final digit = (rowIndex * 3 + colIndex + 1).toString();
                return _PinButton(
                  digit: digit,
                  onPressed: () => onDigitPressed(digit),
                );
              }),
            ),
          );
        }),
        // Row 4: 0, Backspace, Submit
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _PinButton(
              digit: '0',
              onPressed: () => onDigitPressed('0'),
            ),
            GestureDetector(
              onTap: canBackspace ? onBackspace : null,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: canBackspace ? AppColors.primary : AppColors.borderColor,
                  ),
                ),
                child: Icon(
                  Icons.backspace_outlined,
                  color: canBackspace ? AppColors.primary : AppColors.borderColor,
                ),
              ),
            ),
            GestureDetector(
              onTap: canSubmit ? onSubmit : null,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: canSubmit ? AppColors.primary : AppColors.borderColor,
                ),
                child: Icon(
                  Icons.check,
                  color: canSubmit ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PinButton extends StatelessWidget {
  final String digit;
  final VoidCallback onPressed;

  const _PinButton({
    required this.digit,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary),
        ),
        child: Center(
          child: Text(
            digit,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ),
      ),
    );
  }
}

class _BuildLockedUI extends StatelessWidget {
  final int remainingMinutes;

  const _BuildLockedUI({required this.remainingMinutes});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.error.withOpacity(0.1),
          ),
          child: Icon(
            Icons.lock_outline,
            size: 64,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Account Locked',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Too many failed attempts. Try again in $remainingMinutes minutes.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

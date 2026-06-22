import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/widgets/branded_background.dart';

enum _Step { request, verify, reset }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _contact = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _requestKey = GlobalKey<FormState>();
  final _resetKey = GlobalKey<FormState>();

  _Step _step = _Step.request;
  String? _generatedCode;
  String? _codeError;
  int _secondsLeft = 0;
  Timer? _countdown;

  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _contact.dispose();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    _countdown?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown?.cancel();
    setState(() => _secondsLeft = 30);
    _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft <= 1) {
          _secondsLeft = 0;
          t.cancel();
        } else {
          _secondsLeft--;
        }
      });
    });
  }

  void _sendCode() {
    if (_step == _Step.request && !_requestKey.currentState!.validate()) {
      return;
    }
    // TODO real delivery — send the code via SMS/email. On the emulator we
    // generate it locally and surface it so QA can proceed.
    final code = (Random().nextInt(900000) + 100000).toString();
    setState(() {
      _generatedCode = code;
      _codeError = null;
      _step = _Step.verify;
    });
    _startCountdown();
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    final code = (Random().nextInt(900000) + 100000).toString();
    setState(() {
      _generatedCode = code;
      _codeError = null;
    });
    _startCountdown();
  }

  void _verify() {
    if (_code.text.trim() == _generatedCode) {
      setState(() {
        _codeError = null;
        _step = _Step.reset;
      });
    } else {
      setState(() => _codeError = 'Invalid code.');
    }
  }

  void _reset() {
    if (!_resetKey.currentState!.validate()) return;
    // TODO actually reset the Firebase password — not possible on the emulator
    // without the user being signed in, so we simulate success.
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Password updated')));
    context.go(Routes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.signIn),
        ),
      ),
      body: BrandedBackground(
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildStep(context)
                    .animate()
                    .fadeIn(duration: 250.ms)
                    .slideY(begin: 0.05),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case _Step.request:
        return _buildRequest(context);
      case _Step.verify:
        return _buildVerify(context);
      case _Step.reset:
        return _buildReset(context);
    }
  }

  Widget _buildRequest(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _requestKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Reset password',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text('Enter your email or phone to receive a code',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 28),
          TextFormField(
            controller: _contact,
            decoration: const InputDecoration(
              labelText: 'Email or phone',
              prefixIcon: Icon(Icons.alternate_email),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Enter your email or phone'
                : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _sendCode,
            child: const Text('Send code'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerify(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Enter the code',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text('We sent a 6-digit code to ${_contact.text.trim()}',
            style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        if (_generatedCode != null)
          Text('(demo) your code: $_generatedCode',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(height: 20),
        TextField(
          controller: _code,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: '6-digit code',
            prefixIcon: Icon(Icons.pin_outlined),
            counterText: '',
          ),
        ),
        if (_codeError != null) ...[
          const SizedBox(height: 8),
          Text(_codeError!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _secondsLeft == 0 ? _resend : null,
            child: Text(_secondsLeft == 0
                ? 'Resend code'
                : 'Resend code in ${_secondsLeft}s'),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _verify,
          child: const Text('Verify'),
        ),
      ],
    );
  }

  Widget _buildReset(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _resetKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New password',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text('Choose a new password for your account',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 28),
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'New password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Min 6 characters' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirm,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: 'Confirm password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) =>
                (v != _password.text) ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _reset,
            child: const Text('Reset password'),
          ),
        ],
      ),
    );
  }
}

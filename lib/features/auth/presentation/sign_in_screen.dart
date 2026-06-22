import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/widgets/branded_background.dart';
import '../application/auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signIn(
          _email.text,
          _password.text,
        );
  }

  /// Autofill the credentials for a demo role. The user then taps Sign in.
  void _fillDemo(_DemoAccount account) {
    _email.text = account.email;
    _password.text = _DemoAccount.password;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: BrandedBackground(
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _AuthToggle(loginActive: true),
                      const SizedBox(height: 28),
                      Text('Welcome back',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Sign in to your community',
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Min 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () =>
                                  setState(() => _rememberMe = !_rememberMe),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(
                                        () => _rememberMe = v ?? false),
                                  ),
                                  Flexible(
                                    child: Text('Remember me',
                                        style: theme.textTheme.bodyMedium),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push(Routes.forgotPassword),
                            child: const Text('Forgot password?'),
                          ),
                        ],
                      ),
                      if (state.hasError) ...[
                        const SizedBox(height: 8),
                        Text(
                          _friendlyError(state.error!),
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _DemoAccounts(
                        busy: state.isLoading,
                        onPick: _fillDemo,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: state.isLoading ? null : _submit,
                        child: state.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Sign in'),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                            children: [
                              const TextSpan(
                                  text: "Don't have an account? "),
                              TextSpan(
                                text: 'Create an account',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => context.go(Routes.signUp),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.06),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented "Login | Sign up" pill at the top of both auth screens. The
/// active segment is filled with the lime accent; tapping the other navigates.
class _AuthToggle extends StatelessWidget {
  const _AuthToggle({required this.loginActive});

  final bool loginActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _AuthToggleSegment(
            label: 'Login',
            active: loginActive,
            onTap: loginActive ? null : () => context.go(Routes.signIn),
          ),
          _AuthToggleSegment(
            label: 'Sign up',
            active: !loginActive,
            onTap: loginActive ? () => context.go(Routes.signUp) : null,
          ),
        ],
      ),
    );
  }
}

class _AuthToggleSegment extends StatelessWidget {
  const _AuthToggleSegment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: active
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

String _friendlyError(Object e) {
  final s = e.toString();
  if (s.contains('user-not-found') ||
      s.contains('wrong-password') ||
      s.contains('invalid-credential')) {
    return 'Incorrect email or password.';
  }
  return 'Something went wrong. Please try again.';
}

/// A seeded demo account for one-tap login during QA.
class _DemoAccount {
  const _DemoAccount(this.label, this.email, this.sub, this.icon, this.color);
  final String label;
  final String email;
  final String sub;
  final IconData icon;
  final Color color;

  static const password = 'Password123!';
}

const _demoAccounts = <_DemoAccount>[
  _DemoAccount('Admin', 'admin@maplegrove.test', 'Maple Grove · admin view',
      Icons.shield_outlined, Color(0xFFC9A24A)),
  _DemoAccount('Resident', 'alex@maplegrove.test', 'Maple Grove · verified',
      Icons.person_outline, Color(0xFF2E9E78)),
  _DemoAccount('Pending', 'sam@maplegrove.test', 'awaiting approval',
      Icons.hourglass_top, Color(0xFFD9A036)),
  _DemoAccount('Oakwood admin', 'admin@oakwood.test', '2nd tenant · admin',
      Icons.apartment, Color(0xFF2E9E78)),
];

/// Tappable demo-account chips shown under the password field. Tapping one
/// autofills the credentials and signs in, so QA can jump straight into each
/// role/tenant view.
class _DemoAccounts extends StatelessWidget {
  const _DemoAccounts({required this.busy, required this.onPick});

  final bool busy;
  final void Function(_DemoAccount) onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bolt, size: 16, color: theme.colorScheme.secondary),
            const SizedBox(width: 6),
            Text('Demo accounts — tap to fill, then Sign in',
                style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _demoAccounts
              .map((a) => _DemoChip(
                    account: a,
                    enabled: !busy,
                    onTap: () => onPick(a),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _DemoChip extends StatelessWidget {
  const _DemoChip(
      {required this.account, required this.enabled, required this.onTap});
  final _DemoAccount account;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: account.color.withValues(alpha: 0.18),
                child: Icon(account.icon, size: 16, color: account.color),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(account.label,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Text(account.sub,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

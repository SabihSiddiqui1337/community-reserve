import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/widgets/branded_background.dart';
import '../../../shared/format/contact.dart';
import '../../community/data/community_directory_repository.dart';
import '../../community/domain/community_summary.dart';
import '../application/auth_controller.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _search = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<CommunitySummary> _all = [];
  CommunitySummary? _selected;
  bool _loading = true;
  String _query = '';
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadCommunities() async {
    try {
      final all =
          await ref.read(communityDirectoryRepositoryProvider).fetchAll();
      if (mounted) setState(() => _all = all);
    } catch (_) {
      // Leave the list empty; the user can retry by reopening the screen.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Client-side filter: show all when empty, else match any whole word that
  /// starts with the query (case-insensitive), or a substring of the name.
  List<CommunitySummary> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((c) {
      final name = c.name.toLowerCase();
      if (name.contains(q)) return true;
      return name.split(RegExp(r'\s+')).any((w) => w.startsWith(q));
    }).toList();
  }

  void _pick(CommunitySummary summary) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selected = summary;
      _query = '';
      _search.clear();
    });
  }

  void _clearSelection() {
    setState(() => _selected = null);
  }

  Future<void> _submit() async {
    final community = _selected;
    if (community == null) return;
    if (!_formKey.currentState!.validate()) return;

    // Phone uniqueness within the chosen community. Reading memberships before
    // joining is likely blocked by Firestore rules, so this is best-effort and
    // must never block signup.
    // TODO: enforce phone uniqueness server-side once rules allow it.
    try {
      // Intentionally not implemented client-side; rules block reads of a
      // community's memberships for non-members.
    } catch (_) {
      // Ignore — proceed with signup.
    }

    final ok = await ref.read(authControllerProvider.notifier).signUp(
          _name.text,
          _email.text,
          _password.text,
          communityId: community.id,
          phone: _phone.text,
        );
    if (!ok || !mounted) return;
    // The onboarding stage stream advances the router to residency next.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final unlocked = _selected != null;

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
                  // Validate live as the user types (errors appear/clear without
                  // having to tap Sign up).
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _AuthToggle(loginActive: false),
                      const SizedBox(height: 28),
                      Text('Create your account',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Join your community',
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 28),

                      // --- Community selection first ---
                      if (_selected == null) ...[
                        TextField(
                          controller: _search,
                          onChanged: (v) => setState(() => _query = v),
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Find your community',
                            hintText: 'Search by name',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => setState(() {
                                      _query = '';
                                      _search.clear();
                                    }),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))),
                          )
                        else if (_results.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text('No communities found.',
                                style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant)),
                          )
                        else
                          ..._results.map((r) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.location_city),
                                  title: Text(r.name),
                                  subtitle:
                                      r.city.isNotEmpty ? Text(r.city) : null,
                                  onTap: () => _pick(r),
                                ),
                              )),
                      ] else ...[
                        _SelectedCommunityChip(
                          summary: _selected!,
                          onClear: _clearSelection,
                        ),
                      ],

                      // --- Rest of the form, unlocked after selection ---
                      if (unlocked) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter your name'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
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
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          // Digits only, auto-formats to (123) 456-7890, caps
                          // at 10 digits.
                          inputFormatters: [PhoneInputFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            hintText: '(123) 456-7890',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (v) {
                            final digits =
                                (v ?? '').replaceAll(RegExp(r'\D'), '');
                            if (digits.length < 10) {
                              return 'Enter a valid 10-digit phone number';
                            }
                            return null;
                          },
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
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          validator: (v) => (v != _password.text)
                              ? 'Passwords do not match'
                              : null,
                        ),
                        if (state.hasError) ...[
                          const SizedBox(height: 12),
                          Text(
                            _friendlyError(state.error!),
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: state.isLoading ? null : _submit,
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Text('Sign up'),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                            children: [
                              const TextSpan(
                                  text: 'Have an account already? '),
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => context.go(Routes.signIn),
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

/// The picked community shown as a chip with a clear button.
class _SelectedCommunityChip extends StatelessWidget {
  const _SelectedCommunityChip({required this.summary, required this.onClear});

  final CommunitySummary summary;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(summary.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                if (summary.city.isNotEmpty)
                  Text(summary.city,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

/// Segmented "Login | Sign up" pill at the top of both auth screens.
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
  if (s.contains('email-already-in-use')) {
    return 'That email is already registered.';
  }
  if (s.contains('weak-password')) return 'Please choose a stronger password.';
  return 'Something went wrong. Please try again.';
}

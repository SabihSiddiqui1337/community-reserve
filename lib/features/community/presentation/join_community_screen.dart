import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/branded_background.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../data/community_directory_repository.dart';
import '../data/membership_repository.dart';
import '../domain/community_summary.dart';

class JoinCommunityScreen extends ConsumerStatefulWidget {
  const JoinCommunityScreen({super.key});

  @override
  ConsumerState<JoinCommunityScreen> createState() =>
      _JoinCommunityScreenState();
}

class _JoinCommunityScreenState extends ConsumerState<JoinCommunityScreen> {
  final _code = TextEditingController();
  final _search = TextEditingController();
  Timer? _debounce;

  CommunitySummary? _selected;
  List<CommunitySummary> _results = [];
  bool _looking = false;
  bool _joining = false;
  String? _hint;

  @override
  void dispose() {
    _code.dispose();
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onCodeChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _hint = null;
      _selected = null;
    });
    _debounce = Timer(const Duration(milliseconds: 350), () => _lookupCode(value));
  }

  Future<void> _lookupCode(String value) async {
    final code = value.trim();
    if (code.length < 4) return;
    setState(() => _looking = true);
    final repo = ref.read(communityDirectoryRepositoryProvider);
    final found = await repo.lookupByCode(code);
    if (!mounted) return;
    setState(() {
      _looking = false;
      if (found != null) {
        _selected = found;
        _hint = null;
      } else {
        _hint = "No community matches that code yet — keep typing.";
      }
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _runSearch(value));
  }

  Future<void> _runSearch(String value) async {
    if (value.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    final repo = ref.read(communityDirectoryRepositoryProvider);
    final found = await repo.searchByName(value);
    if (!mounted) return;
    setState(() => _results = found);
  }

  Future<void> _continue() async {
    final summary = _selected;
    final uid = ref.read(currentUidProvider);
    if (summary == null || uid == null) return;
    setState(() => _joining = true);
    await ref
        .read(membershipRepositoryProvider)
        .join(summary.id, uid);
    // The onboarding stage stream will advance the router to residency.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join your community'),
        actions: [
          TextButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: BrandedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Find your community',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Enter your join code or search by name.',
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _code,
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: _onCodeChanged,
                      decoration: InputDecoration(
                        labelText: 'Join code',
                        hintText: 'e.g. MAPLE',
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        suffixIcon: _looking
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : null,
                      ),
                    ),
                    if (_hint != null) ...[
                      const SizedBox(height: 8),
                      Text(_hint!,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                    const SizedBox(height: 20),
                    Row(children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or search',
                            style: theme.textTheme.bodySmall),
                      ),
                      const Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _search,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        labelText: 'Community name',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._results.map((r) => ListTile(
                          leading: BrandLogo(label: r.name, size: 40),
                          title: Text(r.name),
                          subtitle: Text(r.city),
                          onTap: () => setState(() {
                            _selected = r;
                            _hint = null;
                          }),
                        )),
                    if (_selected != null) ...[
                      const SizedBox(height: 16),
                      _ConfirmationCard(summary: _selected!),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: (_selected == null || _joining) ? null : _continue,
                      child: _joining
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationCard extends StatelessWidget {
  const _ConfirmationCard({required this.summary});
  final CommunitySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            BrandLogo(label: summary.name, size: 52),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Community',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  Text(summary.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  if (summary.city.isNotEmpty) Text(summary.city),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: theme.colorScheme.secondary),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideX(begin: 0.1);
  }
}

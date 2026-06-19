import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../community/application/tenant_providers.dart';
import '../../../community/data/community_repository.dart';

class BrandingEditorScreen extends ConsumerStatefulWidget {
  const BrandingEditorScreen({super.key});

  @override
  ConsumerState<BrandingEditorScreen> createState() =>
      _BrandingEditorScreenState();
}

class _BrandingEditorScreenState
    extends ConsumerState<BrandingEditorScreen> {
  late TextEditingController _name;
  late TextEditingController _primary;
  late TextEditingController _accent;
  String _theme = 'dark';
  bool _saving = false;
  bool _init = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _primary = TextEditingController();
    _accent = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _primary.dispose();
    _accent.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cid = ref.read(currentCommunityIdProvider);
    if (cid == null) return;
    setState(() => _saving = true);
    await ref.read(communityRepositoryProvider).update(cid, {
      'name': _name.text.trim(),
      'branding': {
        'primaryColor': _primary.text.trim(),
        'accentColor': _accent.text.trim(),
        'theme': _theme,
      },
    });
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Branding saved — theme updated live.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final community = ref.watch(activeCommunityProvider);
    if (!_init) {
      _name.text = community.name;
      _primary.text = community.branding.primaryColor;
      _accent.text = community.branding.accentColor;
      _theme = community.branding.theme;
      _init = true;
    }
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branding'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.admin),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Community name'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _ColorField(
              controller: _primary,
              label: 'Primary color (#RRGGBB)',
              onChanged: () => setState(() {})),
          const SizedBox(height: 16),
          _ColorField(
              controller: _accent,
              label: 'Accent color (#RRGGBB)',
              onChanged: () => setState(() {})),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _theme,
            decoration: const InputDecoration(labelText: 'Default theme'),
            items: const [
              DropdownMenuItem(value: 'dark', child: Text('Dark')),
              DropdownMenuItem(value: 'light', child: Text('Light')),
            ],
            onChanged: (v) => setState(() => _theme = v ?? 'dark'),
          ),
          const SizedBox(height: 24),
          Text('Preview', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _Preview(
            primary: hexToColor(_primary.text),
            accent: hexToColor(_accent.text),
            name: _name.text,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save),
            label: Text(_saving ? 'Saving…' : 'Save branding'),
          ),
        ],
      ),
    );
  }
}

class _ColorField extends StatelessWidget {
  const _ColorField(
      {required this.controller,
      required this.label,
      required this.onChanged});
  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 24,
            decoration: BoxDecoration(
              color: hexToColor(controller.text),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black26),
            ),
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview(
      {required this.primary, required this.accent, required this.name});
  final Color primary;
  final Color accent;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, accent]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Text(name.isEmpty ? 'Community' : name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

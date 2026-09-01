import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_background.dart';
import 'analytics_screen.dart';
import 'history_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _stars = 0;
  final _comment = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = context.read<SettingsProvider>();
      final theme = context.read<ThemeProvider>();
      await settings.loadSettings(theme: theme);
      if (!mounted) return;
      setState(() {
        _stars = settings.rating?.stars ?? 0;
        _comment.text = settings.rating?.comment ?? '';
      });
    });
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_stars < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }
    final ok = await context.read<SettingsProvider>().submitRating(
          _stars,
          comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Thank you for your rating!' : 'Could not save rating'),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: kAccentTeal),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: kAccentTeal,
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final theme = context.watch<ThemeProvider>();
    final cs = Theme.of(context).colorScheme;
    final onPanel = cs.brightness == Brightness.dark ? Colors.white : cs.onSurface;
    final user = auth.user;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: kDarkTeal,
        foregroundColor: kAccentTeal,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kPadMd, kPadMd + kToolbarHeight, kPadMd, kPadLg),
          children: [
            if (settings.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: kPadMd),
                child: Material(
                  color: cs.errorContainer.withAlpha(180),
                  borderRadius: BorderRadius.circular(kRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(kPadMd),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: cs.onErrorContainer, size: 20),
                        const SizedBox(width: kPadSm),
                        Expanded(
                          child: Text(
                            settings.error!,
                            style: TextStyle(color: cs.onErrorContainer, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            AppPanel(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: kDarkTeal,
                  child: Icon(Icons.person_rounded, color: kAccentTeal),
                ),
                title: Text(
                  user?.fullName ?? 'CRISPR-Sim user',
                  style: TextStyle(color: onPanel, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(user?.email ?? '', style: TextStyle(color: onPanel.withAlpha(180))),
              ),
            ),
            const SizedBox(height: kPadLg),
            _sectionTitle(context, 'Appearance', Icons.palette_outlined),
            const SizedBox(height: kPadSm),
            AppPanel(
              padding: const EdgeInsets.all(kPadMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Theme', style: TextStyle(color: onPanel, fontWeight: FontWeight.w600)),
                  const SizedBox(height: kPadSm),
                  _ThemePicker(
                    preference: theme.preference,
                    enabled: !settings.isLoading,
                    onPanel: onPanel,
                    onChanged: (choice) async {
                      await theme.setPreference(choice);
                      await settings.syncTheme(choice.name);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: kPadLg),
            _sectionTitle(context, 'Analytics', Icons.analytics_outlined),
            const SizedBox(height: kPadSm),
            AppPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Usage analytics', style: TextStyle(color: onPanel)),
                    subtitle: Text(
                      'Track sequences, scans, and repairs for your dashboard',
                      style: TextStyle(color: onPanel.withAlpha(170), fontSize: 12),
                    ),
                    activeThumbColor: kAccentTeal,
                    value: settings.analyticsEnabled,
                    onChanged: settings.isLoading
                        ? null
                        : (v) => settings.setAnalyticsEnabled(v),
                  ),
                  Divider(height: 1, color: onPanel.withAlpha(40)),
                  ListTile(
                    leading: Icon(Icons.insights_rounded, color: kAccentTeal),
                    title: Text('View analytics dashboard', style: TextStyle(color: onPanel)),
                    subtitle: Text(
                      settings.analyticsEnabled
                          ? 'Sequences, scans, repair stats'
                          : 'Enable analytics to view',
                      style: TextStyle(color: onPanel.withAlpha(170), fontSize: 12),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: kAccentTeal),
                    enabled: settings.analyticsEnabled,
                    onTap: settings.analyticsEnabled
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                            )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: kPadLg),
            _sectionTitle(context, 'History', Icons.history_rounded),
            const SizedBox(height: kPadSm),
            AppPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Save simulation history', style: TextStyle(color: onPanel)),
                    subtitle: Text(
                      'Store sequences, scans, and repair results in your account',
                      style: TextStyle(color: onPanel.withAlpha(170), fontSize: 12),
                    ),
                    activeThumbColor: kAccentTeal,
                    value: settings.saveHistory,
                    onChanged: settings.isLoading
                        ? null
                        : (v) => settings.setSaveHistory(v),
                  ),
                  Divider(height: 1, color: onPanel.withAlpha(40)),
                  ListTile(
                    leading: Icon(Icons.folder_open_rounded, color: kAccentTeal),
                    title: Text('View saved history', style: TextStyle(color: onPanel)),
                    subtitle: Text(
                      'Past sequences and repair simulations',
                      style: TextStyle(color: onPanel.withAlpha(170), fontSize: 12),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: kAccentTeal),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kPadLg),
            _sectionTitle(context, 'Rate CRISPR-Sim', Icons.star_rounded),
            const SizedBox(height: kPadSm),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'How is your experience with the app?',
                    style: TextStyle(color: onPanel),
                  ),
                  const SizedBox(height: kPadSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return IconButton(
                        iconSize: 36,
                        onPressed: () => setState(() => _stars = star),
                        icon: Icon(
                          star <= _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: star <= _stars ? Colors.amber.shade400 : onPanel.withAlpha(100),
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: _comment,
                    maxLines: 3,
                    style: TextStyle(color: onPanel),
                    decoration: InputDecoration(
                      labelText: 'Comments (optional)',
                      hintText: 'What do you like or want improved?',
                      labelStyle: TextStyle(color: onPanel.withAlpha(180)),
                      hintStyle: TextStyle(color: onPanel.withAlpha(120)),
                    ),
                  ),
                  const SizedBox(height: kPadMd),
                  FilledButton.icon(
                    onPressed: settings.isLoading ? null : _submitRating,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Submit rating'),
                    style: FilledButton.styleFrom(
                      backgroundColor: kAccentTeal,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kPadLg),
            OutlinedButton.icon(
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: onPanel.withAlpha(220),
                side: BorderSide(color: onPanel.withAlpha(80)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: kPadLg),
            _sectionTitle(context, 'Danger Zone', Icons.warning_amber_rounded),
            const SizedBox(height: kPadSm),
            Card(
              color: cs.brightness == Brightness.dark
                  ? const Color(0xFF1F1212)
                  : const Color(0xFFFFF5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadius),
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(kPadMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delete Account & All Data',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Permanently remove your account, profile, all saved simulations, and sequence sessions. This action cannot be reversed.',
                      style: TextStyle(
                        fontSize: 12,
                        color: onPanel.withAlpha(180),
                      ),
                    ),
                    const SizedBox(height: kPadMd),
                    FilledButton.icon(
                      onPressed: () => _showDeleteAccountDialog(context, auth),
                      icon: const Icon(Icons.delete_forever_rounded, size: 18),
                      label: const Text('Delete Account'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Delete Account?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? '
          'All your saved CRISPR simulations, sequences, ratings, and profile information will be permanently wiped from the database. '
          'This action is irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await auth.deleteAccount();
              if (!mounted) return;
              if (success) {
                Navigator.popUntil(context, (r) => r.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFFDC2626),
                    content: Text('Account permanently deleted.'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(auth.error ?? 'Could not delete account.'),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Permanently Delete'),
          ),
        ],
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker({
    required this.preference,
    required this.enabled,
    required this.onPanel,
    required this.onChanged,
  });

  final AppThemePreference preference;
  final bool enabled;
  final Color onPanel;
  final ValueChanged<AppThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        final options = <(AppThemePreference, String, IconData)>[
          (AppThemePreference.system, 'System', Icons.brightness_auto_rounded),
          (AppThemePreference.light, 'Light', Icons.light_mode_rounded),
          (AppThemePreference.dark, 'Dark', Icons.dark_mode_rounded),
        ];

        if (compact) {
          return Column(
            children: options.map((opt) {
              final selected = preference == opt.$1;
              return Padding(
                padding: const EdgeInsets.only(bottom: kPadSm),
                child: _ThemeOptionTile(
                  label: opt.$2,
                  icon: opt.$3,
                  selected: selected,
                  enabled: enabled,
                  onPanel: onPanel,
                  onTap: enabled ? () => onChanged(opt.$1) : null,
                ),
              );
            }).toList(),
          );
        }

        return Row(
          children: options.map((opt) {
            final selected = preference == opt.$1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: opt.$1 != AppThemePreference.dark ? kPadSm : 0,
                ),
                child: _ThemeOptionTile(
                  label: opt.$2,
                  icon: opt.$3,
                  selected: selected,
                  enabled: enabled,
                  onPanel: onPanel,
                  onTap: enabled ? () => onChanged(opt.$1) : null,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onPanel,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final Color onPanel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? kAccentTeal.withAlpha(45) : onPanel.withAlpha(12);
    final border = selected ? kAccentTeal : onPanel.withAlpha(50);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(kRadius),
            border: Border.all(color: border, width: selected ? 1.6 : 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: selected ? kAccentTeal : onPanel.withAlpha(enabled ? 200 : 100)),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? kAccentTeal : onPanel.withAlpha(enabled ? 220 : 120),
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

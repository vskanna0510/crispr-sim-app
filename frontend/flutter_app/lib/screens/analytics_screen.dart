import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings_models.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_background.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadAnalytics();
    });
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final cs = Theme.of(context).colorScheme;
    final onPanel = cs.brightness == Brightness.dark ? Colors.white : cs.onSurface;
    final data = settings.analytics;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: kDarkTeal,
        foregroundColor: kAccentTeal,
        title: const Text('Your Analytics'),
      ),
      body: AppBackground(
        child: settings.isLoading && data == null
            ? const Center(child: CircularProgressIndicator())
            : !settings.analyticsEnabled
                ? _disabledState(onPanel)
                : data == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(kPadLg),
                          child: Text(
                            settings.error ?? 'No analytics data yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: onPanel),
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          kPadMd,
                          kPadMd + kToolbarHeight,
                          kPadMd,
                          kPadLg,
                        ),
                        children: [
                          Text(
                            'Usage summary from your saved simulations',
                            style: TextStyle(color: onPanel.withAlpha(200)),
                          ),
                          const SizedBox(height: kPadMd),
                          _statGrid(data, onPanel),
                          const SizedBox(height: kPadLg),
                          _section('Repair breakdown', onPanel, [
                            _row('NHEJ repairs', '${data.nhejCount}', onPanel),
                            _row('HDR repairs', '${data.hdrCount}', onPanel),
                            _row('Frameshifts detected', '${data.frameshiftCount}', onPanel),
                          ]),
                          const SizedBox(height: kPadMd),
                          _section('Activity', onPanel, [
                            _row('Last sequence', _formatDate(data.lastSequenceAt), onPanel),
                            _row('Last simulation', _formatDate(data.lastSimulationAt), onPanel),
                            if (data.averageGcPercent != null)
                              _row(
                                'Average GC%',
                                '${data.averageGcPercent!.toStringAsFixed(1)}%',
                                onPanel,
                              ),
                          ]),
                          if (data.inputSources.isNotEmpty) ...[
                            const SizedBox(height: kPadMd),
                            _section(
                              'Input sources',
                              onPanel,
                              data.inputSources.entries
                                  .map((e) => _row(e.key.toUpperCase(), '${e.value}', onPanel))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
      ),
    );
  }

  Widget _disabledState(Color onPanel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kPadLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_outlined, size: 48, color: onPanel.withAlpha(120)),
            const SizedBox(height: kPadMd),
            Text(
              'Analytics is turned off',
              style: TextStyle(
                color: onPanel,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: kPadSm),
            Text(
              'Enable analytics in Settings to see your simulation stats.',
              textAlign: TextAlign.center,
              style: TextStyle(color: onPanel.withAlpha(180)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statGrid(UsageAnalytics data, Color onPanel) {
    final items = [
      ('Sequences', data.totalSequences, Icons.biotech_rounded),
      ('PAM scans', data.totalPamScans, Icons.search_rounded),
      ('Simulations', data.totalSimulations, Icons.science_rounded),
    ];
    return Wrap(
      spacing: kPadSm,
      runSpacing: kPadSm,
      children: items
          .map(
            (item) => SizedBox(
              width: 160,
              child: AppPanel(
                padding: const EdgeInsets.all(kPadMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.$3, color: kAccentTeal),
                    const SizedBox(height: kPadSm),
                    Text(
                      '${item.$2}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: onPanel,
                      ),
                    ),
                    Text(
                      item.$1,
                      style: TextStyle(color: onPanel.withAlpha(170), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _section(String title, Color onPanel, List<Widget> children) {
    return AppPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(kPadMd, kPadMd, kPadMd, kPadSm),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kAccentTeal,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color onPanel) {
    return ListTile(
      dense: true,
      title: Text(label, style: TextStyle(color: onPanel.withAlpha(200), fontSize: 13)),
      trailing: Text(
        value,
        style: TextStyle(color: onPanel, fontWeight: FontWeight.w600),
      ),
    );
  }
}

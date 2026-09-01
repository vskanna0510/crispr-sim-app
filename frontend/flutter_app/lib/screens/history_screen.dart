import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/settings_models.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_background.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: kDarkTeal,
        foregroundColor: kAccentTeal,
        title: const Text('Simulation History'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: kAccentTeal,
          unselectedLabelColor: kAccentTeal.withValues(alpha: 0.6),
          indicatorColor: kAccentTeal,
          tabs: const [
            Tab(text: 'Sequences'),
            Tab(text: 'Repairs'),
          ],
        ),
      ),
      body: AppBackground(
        child: settings.isLoading && settings.sessions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : settings.error != null && settings.sessions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(kPadLg),
                      child: Text(settings.error!, textAlign: TextAlign.center),
                    ),
                  )
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _SessionsTab(
                        sessions: settings.sessions,
                        formatDate: _formatDate,
                      ),
                      _SimulationsTab(
                        simulations: settings.simulations,
                        formatDate: _formatDate,
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _SessionsTab extends StatelessWidget {
  const _SessionsTab({required this.sessions, required this.formatDate});

  final List<HistorySession> sessions;
  final String Function(String) formatDate;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text('No saved sequences yet.\nRun a simulation with history saving on.'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(kPadMd),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: kPadSm),
      itemBuilder: (context, i) {
        final s = sessions[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(s.source[0].toUpperCase()),
            ),
            title: Text('${s.length} bp · ${s.source.toUpperCase()}'),
            subtitle: Text(
              [
                if (s.accession != null) 'Accession: ${s.accession}',
                'GC: ${s.gcPercent?.toStringAsFixed(1) ?? '—'}%',
                formatDate(s.createdAt),
              ].join('\n'),
            ),
            isThreeLine: s.accession != null,
          ),
        );
      },
    );
  }
}

class _SimulationsTab extends StatelessWidget {
  const _SimulationsTab({required this.simulations, required this.formatDate});

  final List<HistorySimulation> simulations;
  final String Function(String) formatDate;

  @override
  Widget build(BuildContext context) {
    if (simulations.isEmpty) {
      return const Center(
        child: Text('No repair simulations saved yet.'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(kPadMd),
      itemCount: simulations.length,
      separatorBuilder: (_, __) => const SizedBox(height: kPadSm),
      itemBuilder: (context, i) {
        final s = simulations[i];
        return Card(
          child: ListTile(
            leading: Icon(
              s.frameshift ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: s.frameshift ? Colors.amber.shade800 : Colors.green.shade700,
            ),
            title: Text('${s.repairType} at position ${s.cutPosition}'),
            subtitle: Text(
              [
                if (s.frameshift) 'Frameshift detected',
                if (s.prematureStop) 'Premature stop codon',
                formatDate(s.createdAt),
              ].join(' · '),
            ),
          ),
        );
      },
    );
  }
}

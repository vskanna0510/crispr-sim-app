// Cut Simulation screen – shows selected gRNA details and triggers Cas9 cut.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crispr_models.dart';
import '../providers/crispr_provider.dart';
import '../utils/constants.dart';
import '../widgets/dna_text_widget.dart';
import '../widgets/gc_content_bar.dart';
import 'repair_selection_screen.dart';

class CutSimulationScreen extends StatelessWidget {
  const CutSimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CrisprProvider>();
    final site = prov.selectedPamSite;
    final seq  = prov.sequenceResult;

    if (site == null || seq == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cut Simulation')),
        body: const Center(child: Text('No PAM site selected.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cut Simulation')),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(kPadMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── gRNA info card ────────────────────────────────────────
                  _GrnaCard(site: site),
                  const SizedBox(height: kPadMd),

                  // ── Mechanism explainer ───────────────────────────────────
                  _InfoCard(
                    icon: Icons.info_outline_rounded,
                    text: 'Cas9 creates a blunt-ended double-strand break '
                        '3 bp upstream of the PAM site '
                        '(cut position = PAM_start − 3 = ${site.start - 3}).',
                  ),
                  const SizedBox(height: kPadMd),

                  // ── Sequence with cut position preview ───────────────────
                  if (prov.cutResult == null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(kPadMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sequence Preview',
                                style:
                                    Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: kPadSm),
                            DnaTextWidget(
                              sequence: seq.sequence,
                              pamSites: [site],
                              cutPosition: site.start - 3,
                              maxChars: 200,
                            ),
                            const SizedBox(height: kPadSm),
                            const Text(
                              '| marks the predicted cut position',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── Cut result ────────────────────────────────────────────
                  if (prov.cutResult != null) ...[
                    _CutResultCard(prov: prov),
                    const SizedBox(height: kPadMd),
                  ],

                  if (prov.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: kPadMd),
                      child: Text(prov.error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),

                  const SizedBox(height: kPadMd),

                  // ── CTA ───────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: prov.cutResult == null
                        ? FilledButton.icon(
                            onPressed: () async {
                              await prov.simulateCut();
                            },
                            icon: const Icon(Icons.cut_rounded),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('Simulate Cas9 Cut',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const RepairSelectionScreen()),
                            ),
                            icon: const Icon(Icons.build_rounded),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Text('Choose Repair Pathway',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── gRNA card ────────────────────────────────────────────────────────────────

class _GrnaCard extends StatelessWidget {
  final PamSite site;
  const _GrnaCard({required this.site});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kPadMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.biotech_rounded,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: kPadSm),
                Text('Selected Guide RNA',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Text('PAM:',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text(site.pam,
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(width: 16),
                const Text('Position:',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text('${site.start}',
                    style: const TextStyle(fontFamily: 'monospace')),
              ],
            ),
            if (site.grna != null) ...[
              const SizedBox(height: kPadSm),
              const Text('gRNA Sequence (20 nt):',
                  style:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(kPadSm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  site.grna!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
              const SizedBox(height: kPadSm),
              if (site.gcPercent != null)
                GcContentBar(gcPercent: site.gcPercent!),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Cut result card ──────────────────────────────────────────────────────────

class _CutResultCard extends StatelessWidget {
  final CrisprProvider prov;
  const _CutResultCard({required this.prov});

  @override
  Widget build(BuildContext context) {
    final cut = prov.cutResult!;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(kPadMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: Colors.green.shade700),
                const SizedBox(width: kPadSm),
                Text('Cut Simulated!',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.green.shade800,
                        )),
              ],
            ),
            const SizedBox(height: kPadSm),
            _Row('Cut position', '${cut.cutPosition} bp'),
            _Row('Upstream length',   '${cut.upstream.length} bp'),
            _Row('Downstream length', '${cut.downstream.length} bp'),
            const Divider(height: 16),
            const Text('Upstream:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            Text(
              cut.upstream.length > 40
                  ? '…${cut.upstream.substring(cut.upstream.length - 40)}'
                  : cut.upstream,
              style:
                  const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const Text('Downstream:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            Text(
              cut.downstream.length > 40
                  ? '${cut.downstream.substring(0, 40)}…'
                  : cut.downstream,
              style:
                  const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(kPadSm),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(kRadius),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue.shade700, size: 18),
            const SizedBox(width: kPadSm),
            Expanded(
              child: Text(text,
                  style:
                      TextStyle(fontSize: 12, color: Colors.blue.shade900)),
            ),
          ],
        ),
      );
}

// DNA Viewer screen – shows colour-coded sequence, composition stats, and
// triggers PAM scanning.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crispr_models.dart';
import '../providers/crispr_provider.dart';
import '../utils/constants.dart';
import '../widgets/animated_dna_text.dart';
import '../widgets/cas_system_selector.dart';
import '../widgets/dna_sequencing_helix.dart';
import '../widgets/dna_text_widget.dart';
import '../widgets/gene_info_card.dart';
import 'pam_scanner_screen.dart';

class DnaViewerScreen extends StatelessWidget {
  const DnaViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CrisprProvider>();
    final seq  = prov.sequenceResult;

    if (seq == null) return const _NoData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DNA Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'New sequence',
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
        ],
      ),
      body: prov.isLoading
          ? const _DnaViewerLoadingBody(
              message: 'Scanning & preparing…',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(kPadMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              kPadMd, kPadMd, kPadMd, 0),
                          child: Row(
                            children: [
                              Icon(Icons.biotech_rounded,
                                  size: 22,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: kPadSm),
                              Text(
                                'Live sequencing',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        DnaSequencingHelix(
                          sequence: seq.sequence,
                          height: 220,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: kPadMd),

                  if (prov.geneInfo != null) ...[
                    GeneInfoCard(info: prov.geneInfo!),
                    const SizedBox(height: kPadMd),
                  ],

                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(kPadMd),
                      child: CasSystemSelector(),
                    ),
                  ),
                  const SizedBox(height: kPadMd),

                  // ── Stats card ────────────────────────────────────────────
                  _StatsCard(seq: seq),
                  const SizedBox(height: kPadMd),

                  // ── Composition bar ───────────────────────────────────────
                  if (seq.composition != null) ...[
                    _CompositionBar(composition: seq.composition!),
                    const SizedBox(height: kPadMd),
                  ],

                  // ── Sequence display ──────────────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(kPadMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Sequence',
                                  style: Theme.of(context).textTheme.titleSmall),
                              const DnaLegend(),
                            ],
                          ),
                          const Divider(height: 16),
                          AnimatedDnaTextWidget(
                            sequence: seq.sequence,
                            maxChars: 400,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: kPadLg),
                  if (prov.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: kPadMd),
                      child: Text(prov.error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),

                  // ── CTA ───────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final ok = await prov.scanPamSites();
                        if (ok && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PamScannerScreen()),
                          );
                        }
                      },
                      icon: const Icon(Icons.search_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Scan PAM Sites',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── Stats card ───────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final SequenceResult seq;
  const _StatsCard({required this.seq});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kPadMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sequence Summary',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: kPadSm),
            Wrap(
              spacing: kPadLg,
              runSpacing: kPadSm,
              children: [
                _Stat('Length',    '${seq.length} bp'),
                _Stat('GC %',      seq.gcPercent != null
                    ? '${seq.gcPercent!.toStringAsFixed(1)} %'
                    : '–'),
                _Stat('Session',   seq.sessionId?.substring(0, 8) ?? '–'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      );
}

// ─── Composition bar ─────────────────────────────────────────────────────────

class _CompositionBar extends StatelessWidget {
  final Map<String, double> composition;
  const _CompositionBar({required this.composition});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kPadMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Base Composition',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: kPadSm),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: ['A', 'T', 'G', 'C'].map((base) {
                      final pct = composition[base] ?? 0.0;
                      final flex = ((pct * 10) * t).round().clamp(0, 1000);
                      return Flexible(
                        flex: flex > 0 ? flex : 1,
                        child: Container(
                          height: 20,
                          color: dnaBaseColour(base),
                          alignment: Alignment.center,
                          child: pct * t > 0.08
                              ? Text(base,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold))
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: kPadSm),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (context, t, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['A', 'T', 'G', 'C'].map((base) {
                    final pct = composition[base] ?? 0.0;
                    return Opacity(
                      opacity: t,
                      child: Text(
                        '$base: ${pct.toStringAsFixed(1)}%',
                        style: TextStyle(
                            fontSize: 12,
                            color: dnaBaseColour(base),
                            fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DnaViewerLoadingBody extends StatelessWidget {
  final String message;
  const _DnaViewerLoadingBody({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kPadMd),
      child: Column(
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(kPadMd, kPadMd, kPadMd, 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: kPadSm),
                      Expanded(
                        child: Text(
                          'Sequencing in progress',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                const DnaSequencingHelix(
                  sequence: '',
                  height: 240,
                ),
              ],
            ),
          ),
          const SizedBox(height: kPadLg),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: kPadMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                backgroundColor: cs.surfaceContainerHighest,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('DNA Viewer')),
        body: const Center(child: Text('No sequence loaded.')),
      );
}

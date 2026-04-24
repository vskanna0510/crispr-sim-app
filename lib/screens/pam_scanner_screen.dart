// PAM Scanner screen – shows all NGG PAM sites; user selects one to proceed.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crispr_provider.dart';
import '../models/crispr_models.dart';
import '../utils/constants.dart';
import '../widgets/gc_content_bar.dart';
import 'cut_simulation_screen.dart';

class PamScannerScreen extends StatelessWidget {
  const PamScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CrisprProvider>();
    final scan = prov.scanResult;

    if (scan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PAM Scanner')),
        body: const Center(child: Text('No scan data.')),
      );
    }

    final sites = scan.pamSites;
    // Only sites with gRNA are actionable
    final actionable = sites.where((s) => s.grna != null).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('PAM Scanner')),
      body: Column(
        children: [
          // ── Summary banner ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(
                vertical: kPadSm, horizontal: kPadMd),
            child: Text(
              'Found ${sites.length} PAM sites  •  ${actionable.length} with valid gRNA',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),

          // ── Site list ─────────────────────────────────────────────────────
          Expanded(
            child: sites.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(kPadSm),
                    itemCount: sites.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: kPadSm / 2),
                    itemBuilder: (ctx, i) => _PamCard(
                      site:     sites[i],
                      selected: prov.selectedPamSite?.start == sites[i].start,
                      onTap:    sites[i].grna != null
                          ? () => prov.selectPamSite(sites[i])
                          : null,
                    ),
                  ),
          ),

          // ── CTA ──────────────────────────────────────────────────────────
          if (prov.selectedPamSite != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(kPadMd),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CutSimulationScreen()),
                    ),
                    icon: const Icon(Icons.cut_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Text('Simulate Cut',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── PAM site card ────────────────────────────────────────────────────────────

class _PamCard extends StatelessWidget {
  final PamSite site;
  final bool selected;
  final VoidCallback? onTap;

  const _PamCard({
    required this.site,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs       = Theme.of(context).colorScheme;
    final hasGrna  = site.grna != null;
    final gc       = site.gcPercent;

    return Card(
      elevation: selected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
        side: selected
            ? BorderSide(color: cs.primary, width: 2)
            : const BorderSide(color: Colors.transparent),
      ),
      color: selected ? cs.primaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(kRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(kPadMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  _BaseBadge(site.pam),
                  const SizedBox(width: kPadSm),
                  Text('Position ${site.start}–${site.end}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const Spacer(),
                  if (site.recommended == true)
                    const _Badge('Recommended', Colors.green),
                  if (site.recommended == false && hasGrna)
                    const _Badge('Low GC', Colors.orange),
                  if (!hasGrna)
                    const _Badge('No gRNA', Colors.grey),
                ],
              ),

              // gRNA
              if (hasGrna) ...[
                const SizedBox(height: kPadSm),
                Row(
                  children: [
                    const Text('gRNA: ',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600)),
                    Expanded(
                      child: Text(
                        site.grna!,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: kPadSm),
                if (gc != null) GcContentBar(gcPercent: gc),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BaseBadge extends StatelessWidget {
  final String pam;
  const _BaseBadge(this.pam);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          pam,
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color colour;
  const _Badge(this.label, this.colour);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colour.withAlpha(30),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colour.withAlpha(80)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 10, color: colour, fontWeight: FontWeight.w600)),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: kPadMd),
            const Text('No PAM sites found in this sequence.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: kPadSm),
            const Text(
              'SpCas9 requires the NGG motif.\n'
              'Try a longer or different sequence.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
}

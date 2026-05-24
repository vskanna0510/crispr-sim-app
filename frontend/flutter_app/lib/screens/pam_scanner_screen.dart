// PAM Scanner screen – shows all NGG PAM sites; user selects one to proceed.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crispr_provider.dart';
import '../models/crispr_models.dart';
import '../utils/constants.dart';
import '../widgets/gc_content_bar.dart';
import '../widgets/stagger_column.dart';
import 'cut_simulation_screen.dart';
import 'off_target_screen.dart';

class PamScannerScreen extends StatefulWidget {
  const PamScannerScreen({super.key});

  @override
  State<PamScannerScreen> createState() => _PamScannerScreenState();
}

class _PamScannerScreenState extends State<PamScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _listAnim;

  @override
  void initState() {
    super.initState();
    _listAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _listAnim.forward();
    });
  }

  @override
  void dispose() {
    _listAnim.dispose();
    super.dispose();
  }

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
    final actionable = sites.where((s) => s.grna != null).toList();
    final ranked = scan.rankedGuides;
    final rec = scan.recommendation;

    return Scaffold(
      appBar: AppBar(title: const Text('PAM Scanner')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(
                vertical: kPadSm, horizontal: kPadMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${scan.casName ?? 'Cas'}  •  PAM ${scan.pamMotif ?? ''}  •  ${sites.length} sites',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                if (scan.application != null)
                  Text(
                    scan.application!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withAlpha(200),
                    ),
                  ),
                Text(
                  '${actionable.length} guides ranked for efficiency & safety',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          if (rec != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(kPadMd, kPadSm, kPadMd, 0),
              child: Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(kPadMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recommended guide',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('${rec.guideId}: ${rec.grna}',
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 12)),
                      Text(
                        'Efficiency ${rec.efficiencyPercent}%  •  '
                        'Specificity ${rec.specificityPercent}%  •  '
                        'Safety ${rec.safetyPercent}%',
                        style: const TextStyle(fontSize: 11),
                      ),
                      if (rec.reasons.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        ...rec.reasons.map(
                          (r) => Text('• $r',
                              style: const TextStyle(fontSize: 11)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          if (ranked.isNotEmpty)
            SizedBox(
              height: 118,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: kPadMd, vertical: kPadSm),
                children: ranked.take(5).map((g) {
                  final medal = g.rank == 1
                      ? '🥇'
                      : g.rank == 2
                          ? '🥈'
                          : g.rank == 3
                              ? '🥉'
                              : '#${g.rank}';
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: kPadSm),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$medal ${g.guideId}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                            Text(
                              'Eff ${g.efficiencyPercent}%  Spec ${g.specificityPercent}%',
                              style: const TextStyle(fontSize: 10),
                            ),
                            Text(
                              'Safety ${g.safetyPercent}%  Risk ${g.overallRisk}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: sites.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(kPadSm),
                    itemCount: sites.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: kPadSm / 2),
                    itemBuilder: (ctx, i) => StaggerListTile(
                      index: i,
                      controller: _listAnim,
                      total: sites.length,
                      child: _PamCard(
                        site: sites[i],
                        selected:
                            prov.selectedPamSite?.start == sites[i].start,
                        onTap: sites[i].grna != null
                            ? () => prov.selectPamSite(sites[i])
                            : null,
                      ),
                    ),
                  ),
          ),
          AnimatedSlide(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            offset: prov.selectedPamSite != null
                ? Offset.zero
                : const Offset(0, 1.25),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 280),
              opacity: prov.selectedPamSite != null ? 1 : 0,
              child: prov.selectedPamSite != null
                  ? SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(kPadMd),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (prov.safetyScoreResult != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: kPadSm),
                                child: Text(
                                  'Safety score: ${prov.safetyScoreResult!.score}/100 (${prov.safetyScoreResult!.label})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const OffTargetScreen(),
                                      ),
                                    ),
                                    icon: const Icon(Icons.radar_rounded),
                                    label: const Text('Off-targets'),
                                  ),
                                ),
                                const SizedBox(width: kPadSm),
                                Expanded(
                                  flex: 2,
                                  child: FilledButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CutSimulationScreen(),
                                      ),
                                    ),
                                    icon: const Icon(Icons.cut_rounded),
                                    label: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 13),
                                      child: Text('Simulate Cut',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

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
    final cs = Theme.of(context).colorScheme;
    final hasGrna = site.grna != null;
    final gc = site.gcPercent;

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
              Row(
                children: [
                  _BaseBadge(site.pam),
                  const SizedBox(width: kPadSm),
                  Text('Position ${site.start}–${site.end}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const Spacer(),
                  if (site.rank != null)
                    _Badge('#${site.rank}', cs.primary),
                  if (site.recommended == true)
                    const _Badge('Recommended', Colors.green),
                  if (site.recommended == false && hasGrna)
                    const _Badge('Low GC', Colors.orange),
                  if (!hasGrna) const _Badge('No gRNA', Colors.grey),
                ],
              ),
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
                if (site.efficiencyPercent != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Eff ${site.efficiencyPercent!.toStringAsFixed(0)}%  •  '
                      'Spec ${site.specificityPercent?.toStringAsFixed(0) ?? '—'}%  •  '
                      'Safety ${site.safetyPercent?.toStringAsFixed(0) ?? '—'}%',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
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

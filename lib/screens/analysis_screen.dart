// Analysis screen – mutation analysis, protein comparison, summary.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/crispr_provider.dart';
import '../models/crispr_models.dart';
import '../utils/constants.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov   = context.watch<CrisprProvider>();
    final result = prov.compareResult;
    final repair = prov.repairResult;

    if (result == null || repair == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis')),
        body: const Center(child: Text('No analysis data.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'New simulation',
            onPressed: () {
              context.read<CrisprProvider>().reset();
              Navigator.popUntil(context, (r) => r.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kPadMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary banner ────────────────────────────────────────────
            _SummaryBanner(result: result, repairType: repair.repairType),
            const SizedBox(height: kPadMd),

            // ── Mutation alerts ───────────────────────────────────────────
            if (result.frameshift)
              _AlertCard(
                icon: Icons.warning_amber_rounded,
                colour: Colors.deepOrange,
                title: 'Frameshift Mutation',
                subtitle:
                    'The indel size (${result.lengthDiff.abs()} bp) is not '
                    'a multiple of 3. The reading frame is disrupted.',
              ),
            if (result.prematureStop)
              const _AlertCard(
                icon: Icons.block_rounded,
                colour: Colors.red,
                title: 'Premature Stop Codon',
                subtitle:
                    'A stop codon (*) appears earlier in the edited protein, '
                    'truncating the translated product.',
              ),
            if (!result.frameshift && !result.prematureStop)
              const _AlertCard(
                icon: Icons.check_circle_rounded,
                colour: Colors.green,
                title: 'No Major Mutations',
                subtitle:
                    'The edit is in-frame and no premature stop codon was detected.',
              ),
            const SizedBox(height: kPadMd),

            // ── Sequence lengths ──────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(kPadMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sequence Statistics',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: kPadSm),
                    _StatRow('Repair type',        repair.repairType),
                    _StatRow('Original length',    '${result.originalLength} bp'),
                    _StatRow('Edited length',      '${result.editedLength} bp'),
                    _StatRow('Length difference',  '${result.lengthDiff.abs()} bp '
                        '(${result.lengthDiff > 0 ? 'deletion' : result.lengthDiff < 0 ? 'insertion' : 'unchanged'})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: kPadMd),

            // ── Protein comparison ────────────────────────────────────────
            _ProteinCompareCard(result: result),
            const SizedBox(height: kPadMd),

            // ── mRNA comparison ───────────────────────────────────────────
            _SequenceCompareCard(
              title: 'mRNA Comparison',
              original: result.originalMrna,
              edited:   result.editedMrna,
              colour:   Colors.purple,
            ),
            const SizedBox(height: kPadMd),

            // ── Edited sequence export ────────────────────────────────────
            _ExportCard(repair: repair),

            const SizedBox(height: kPadLg),
          ],
        ),
      ),
    );
  }
}

// ─── Summary banner ───────────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  final CompareResult result;
  final String repairType;
  const _SummaryBanner({required this.result, required this.repairType});

  @override
  Widget build(BuildContext context) {
    final hasIssues = result.frameshift || result.prematureStop;
    final colour    = hasIssues ? Colors.deepOrange : Colors.green;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(kPadMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colour.shade700, colour.shade400],
        ),
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Simulation Complete',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 4),
          Text(result.summary,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _Chip(repairType),
              if (result.frameshift) const _Chip('Frameshift'),
              if (result.prematureStop) const _Chip('Stop Codon'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) => Chip(
        label: Text(label,
            style: const TextStyle(
                fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white.withAlpha(50),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
}

// ─── Alert card ───────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final MaterialColor colour;
  final String title;
  final String subtitle;

  const _AlertCard({
    required this.icon,
    required this.colour,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Card(
        color: colour.withAlpha(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius),
          side: BorderSide(color: colour.withAlpha(80)),
        ),
        child: ListTile(
          leading: Icon(icon, color: colour.shade700),
          title: Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: colour.shade800)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        ),
      );
}

// ─── Protein comparison ───────────────────────────────────────────────────────

class _ProteinCompareCard extends StatelessWidget {
  final CompareResult result;
  const _ProteinCompareCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kPadMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Protein Comparison',
                style: Theme.of(context).textTheme.titleSmall),
            const Divider(height: 16),
            const Text('Original Protein:',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green)),
            const SizedBox(height: 4),
            _SeqBox(result.originalProtein, Colors.green.shade50),
            const SizedBox(height: kPadSm),
            const Text('Edited Protein:',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrange)),
            const SizedBox(height: 4),
            _SeqBox(result.editedProtein, Colors.deepOrange.shade50),
          ],
        ),
      ),
    );
  }
}

class _SeqBox extends StatelessWidget {
  final String seq;
  final Color bg;
  const _SeqBox(this.seq, this.bg);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(kPadSm),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          seq.length > 120 ? '${seq.substring(0, 120)}…' : seq,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      );
}

// ─── Sequence compare card ───────────────────────────────────────────────────

class _SequenceCompareCard extends StatelessWidget {
  final String title;
  final String original;
  final String edited;
  final MaterialColor colour;

  const _SequenceCompareCard({
    required this.title,
    required this.original,
    required this.edited,
    required this.colour,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(kPadMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const Divider(height: 16),
              const Text('Original:', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text(
                original.length > 80
                    ? '${original.substring(0, 80)}…'
                    : original,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 8),
              const Text('Edited:', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text(
                edited.length > 80
                    ? '${edited.substring(0, 80)}…'
                    : edited,
                style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: colour.shade700),
              ),
            ],
          ),
        ),
      );
}

// ─── Export card ──────────────────────────────────────────────────────────────

class _ExportCard extends StatelessWidget {
  final RepairResult repair;
  const _ExportCard({required this.repair});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(kPadMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Export', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: kPadSm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final fasta =
                            '>edited_sequence_${repair.repairType}\n'
                            '${repair.repairedSequence}';
                        Clipboard.setData(ClipboardData(text: fasta));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('FASTA copied to clipboard!')),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy FASTA'),
                    ),
                  ),
                  const SizedBox(width: kPadSm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: repair.repairedSequence));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Edited sequence copied to clipboard!')),
                        );
                      },
                      icon: const Icon(Icons.content_copy_rounded, size: 16),
                      label: const Text('Copy Sequence'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

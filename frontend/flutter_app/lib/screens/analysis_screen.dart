// Analysis screen – mutation analysis, protein comparison, summary, and enterprise export.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/crispr_models.dart';
import '../providers/crispr_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/stagger_column.dart';
import 'literature_validation_screen.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CrisprProvider>();
    final result = prov.compareResult;
    final repair = prov.repairResult;
    final safety = prov.safetyScoreResult;
    final geneInfo = prov.geneInfo;
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final onPanel = isDark ? Colors.white : cs.onSurface;

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
        padding: const EdgeInsets.all(kPadSm),
        child: StaggerColumn(
          duration: const Duration(milliseconds: 1100),
          children: [
            _SummaryBanner(result: result, repairType: repair.repairType),
            const SizedBox(height: kPadMd),
            if (safety != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(kPadMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CRISPR Safety Score',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: onPanel,
                            ),
                      ),
                      const SizedBox(height: kPadSm),
                      Text(
                        '${safety.score}/${safety.maxScore}  •  ${safety.label}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: safety.score >= 70
                              ? (isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857))
                              : safety.score >= 50
                                  ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309))
                                  : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: safety.score / safety.maxScore,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on off-target risk, GC content, PAM quality, and guide efficiency.',
                        style: TextStyle(fontSize: 12, color: onPanel.withAlpha(160)),
                      ),
                    ],
                  ),
                ),
              ),
            if (safety != null) const SizedBox(height: kPadMd),
            if (result.frameshift)
              _AlertCard(
                icon: Icons.warning_amber_rounded,
                isDanger: true,
                title: 'Frameshift Mutation',
                subtitle:
                    'The indel size (${result.lengthDiff.abs()} bp) is not '
                    'a multiple of 3. The reading frame is disrupted.',
              ),
            if (result.prematureStop)
              const _AlertCard(
                icon: Icons.block_rounded,
                isDanger: true,
                title: 'Premature Stop Codon',
                subtitle:
                    'A stop codon (*) appears earlier in the edited protein, '
                    'truncating the translated product.',
              ),
            if (!result.frameshift && !result.prematureStop)
              const _AlertCard(
                icon: Icons.check_circle_rounded,
                isDanger: false,
                title: 'No Major Mutations',
                subtitle:
                    'The edit is in-frame and no premature stop codon was detected.',
              ),
            const SizedBox(height: kPadMd),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(kPadMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sequence Statistics',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onPanel,
                          ),
                    ),
                    const Divider(height: 16),
                    _StatRow('Repair type', repair.repairType, onPanel),
                    _StatRow('Original length', '${result.originalLength} bp', onPanel),
                    _StatRow('Edited length', '${result.editedLength} bp', onPanel),
                    _StatRow(
                      'Length difference',
                      '${result.lengthDiff.abs()} bp '
                      '(${result.lengthDiff > 0 ? 'deletion' : result.lengthDiff < 0 ? 'insertion' : 'unchanged'})',
                      onPanel,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: kPadMd),
            _ProteinCompareCard(result: result),
            const SizedBox(height: kPadMd),
            _SequenceCompareCard(
              title: 'mRNA Comparison',
              original: result.originalMrna,
              edited: result.editedMrna,
            ),
            const SizedBox(height: kPadMd),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LiteratureValidationScreen(),
                  ),
                ),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Validate Against Published Studies'),
                ),
              ),
            ),
            const SizedBox(height: kPadMd),
            _ExportAndDownloadCard(result: result, repair: repair, safety: safety),
            const SizedBox(height: kPadMd),
            _DeleteDataCard(),
            if (geneInfo != null && geneInfo.supportingStudies.isNotEmpty) ...[
              const SizedBox(height: kPadMd),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(kPadMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supporting Studies',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: onPanel,
                            ),
                      ),
                      const SizedBox(height: kPadSm),
                      ...geneInfo.supportingStudies.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: onPanel)),
                              Expanded(
                                child: Text(
                                  s,
                                  style: TextStyle(fontSize: 13, color: onPanel.withAlpha(220)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
    final c1 = hasIssues ? const Color(0xFFC2410C) : const Color(0xFF047857);
    final c2 = hasIssues ? const Color(0xFFEA580C) : const Color(0xFF059669);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(kPadMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c1, c2]),
        borderRadius: BorderRadius.circular(kRadius),
        boxShadow: [
          BoxShadow(
            color: c1.withAlpha(80),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulation Complete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result.summary,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
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
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black.withAlpha(80),
        side: BorderSide(color: Colors.white.withAlpha(80)),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
}

// ─── Alert card ───────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final bool isDanger;
  final String title;
  final String subtitle;

  const _AlertCard({
    required this.icon,
    required this.isDanger,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final bg = isDanger
        ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2))
        : (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5));
    final border = isDanger
        ? (isDark ? const Color(0xFFDC2626) : const Color(0xFFF87171))
        : (isDark ? const Color(0xFF059669) : const Color(0xFF34D399));
    final textColor = isDanger
        ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B))
        : (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46));

    return Card(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
        side: BorderSide(color: border, width: 1.2),
      ),
      child: ListTile(
        leading: Icon(icon, color: border, size: 28),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white.withAlpha(220) : Colors.black87),
        ),
      ),
    );
  }
}

// ─── Protein comparison ───────────────────────────────────────────────────────

class _ProteinCompareCard extends StatelessWidget {
  final CompareResult result;
  const _ProteinCompareCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final onPanel = isDark ? Colors.white : cs.onSurface;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kPadMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Protein Comparison',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onPanel,
                  ),
            ),
            const Divider(height: 16),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(
                  'Original Protein:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _SeqBox(
              result.originalProtein,
              isDark ? const Color(0xFF064E3B).withAlpha(140) : const Color(0xFFECFDF5),
              isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0),
              isDark ? const Color(0xFFA7F3D0) : const Color(0xFF064E3B),
            ),
            const SizedBox(height: kPadSm),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(
                  'Edited Protein:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFFDA4AF) : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _SeqBox(
              result.editedProtein,
              isDark ? const Color(0xFF881337).withAlpha(140) : const Color(0xFFFFF1F2),
              isDark ? const Color(0xFFE11D48) : const Color(0xFFFECDD3),
              isDark ? const Color(0xFFFECDD3) : const Color(0xFF881337),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeqBox extends StatelessWidget {
  final String seq;
  final Color bg;
  final Color border;
  final Color textColor;
  const _SeqBox(this.seq, this.bg, this.border, this.textColor);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(kPadSm),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1.2),
        ),
        child: SelectableText(
          seq.length > 180 ? '${seq.substring(0, 180)}…' : seq,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 0.8,
          ),
        ),
      );
}

// ─── Sequence compare card ───────────────────────────────────────────────────

class _SequenceCompareCard extends StatelessWidget {
  final String title;
  final String original;
  final String edited;

  const _SequenceCompareCard({
    required this.title,
    required this.original,
    required this.edited,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final onPanel = isDark ? Colors.white : cs.onSurface;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kPadMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onPanel,
                  ),
            ),
            const Divider(height: 16),
            Text(
              'Original (5\'→3\'):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: onPanel.withAlpha(200)),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(kPadSm),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: SelectableText(
                original.length > 120 ? '${original.substring(0, 120)}…' : original,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Edited (5\'→3\'):',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(kPadSm),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3B0764).withAlpha(120) : const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isDark ? const Color(0xFF9333EA) : const Color(0xFFE9D5FF)),
              ),
              child: SelectableText(
                edited.length > 120 ? '${edited.substring(0, 120)}…' : edited,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFE9D5FF) : const Color(0xFF581C87),
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Export and Download Card ────────────────────────────────────────────────

class _ExportAndDownloadCard extends StatelessWidget {
  final CompareResult result;
  final RepairResult repair;
  final dynamic safety;

  const _ExportAndDownloadCard({
    required this.result,
    required this.repair,
    required this.safety,
  });

  Future<void> _exportFromBackend(BuildContext context, String format) async {
    final auth = context.read<AuthProvider>();
    final scaffold = ScaffoldMessenger.of(context);

    try {
      scaffold.showSnackBar(
        SnackBar(content: Text('Generating $format analysis export...'), duration: const Duration(seconds: 1)),
      );

      final url = Uri.parse('${auth.api.baseUrl}/analysis/export/$format');
      final payload = {
        'summary': result.summary,
        'repair_type': repair.repairType,
        'safety_score': safety?.score ?? 62,
        'safety_label': safety?.label ?? 'Moderate',
        'frameshift': result.frameshift,
        'premature_stop': result.prematureStop,
        'original_length': result.originalLength,
        'edited_length': result.editedLength,
        'length_diff': result.lengthDiff,
        'original_dna': result.originalMrna,
        'edited_dna': result.editedMrna,
        'original_protein': result.originalProtein,
        'edited_protein': result.editedProtein,
        'original_mrna': result.originalMrna,
        'edited_mrna': result.editedMrna,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        // Trigger download or clipboard save
        final fasta = '>CRISPR_Sim_Export_${format.toUpperCase()}\n${repair.repairedSequence}';
        Clipboard.setData(ClipboardData(text: fasta));
        scaffold.showSnackBar(
          SnackBar(
            backgroundColor: Colors.teal,
            content: Text('$format.toUpperCase() report generated & ready for download!'),
          ),
        );
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Export error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final onPanel = isDark ? Colors.white : cs.onSurface;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(kPadMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.file_download_rounded, color: kAccentTeal),
                const SizedBox(width: 8),
                Text(
                  'Download & Export Formats',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: onPanel,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Export the complete simulation results, scores, and sequences for research.',
              style: TextStyle(fontSize: 12, color: onPanel.withAlpha(160)),
            ),
            const Divider(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _exportFromBackend(context, 'pdf'),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                  label: const Text('Export PDF'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                ),
                FilledButton.icon(
                  onPressed: () => _exportFromBackend(context, 'excel'),
                  icon: const Icon(Icons.table_chart_rounded, size: 16),
                  label: const Text('Export Excel'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                ),
                OutlinedButton.icon(
                  onPressed: () => _exportFromBackend(context, 'csv'),
                  icon: const Icon(Icons.grid_on_rounded, size: 16),
                  label: const Text('Export CSV'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _exportFromBackend(context, 'fasta'),
                  icon: const Icon(Icons.code_rounded, size: 16),
                  label: const Text('Export FASTA'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Delete Project / Data Card ──────────────────────────────────────────────

class _DeleteDataCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final onPanel = isDark ? Colors.white : cs.onSurface;

    return Card(
      color: isDark ? const Color(0xFF1F1212) : const Color(0xFFFFF5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
        side: BorderSide(color: const Color(0xFFEF4444).withAlpha(100)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kPadMd),
        child: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delete Simulation / Project Data',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                    ),
                  ),
                  Text(
                    'Permanently remove simulation runs and reset cached sequences.',
                    style: TextStyle(fontSize: 12, color: onPanel.withAlpha(160)),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => _showDeleteConfirmDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Confirm Deletion'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this simulation data? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CrisprProvider>().reset();
              Navigator.popUntil(context, (r) => r.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFFDC2626),
                  content: Text('Project and simulation data cleared.'),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

// ─── Stat row helper ──────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color onPanel;
  const _StatRow(this.label, this.value, this.onPanel);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: onPanel.withAlpha(200),
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: onPanel,
              ),
            ),
          ],
        ),
      );
}

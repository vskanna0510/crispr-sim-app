// Repair Selection screen – choose NHEJ or HDR repair pathway.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crispr_provider.dart';
import '../utils/constants.dart';
import 'analysis_screen.dart';

class RepairSelectionScreen extends StatefulWidget {
  const RepairSelectionScreen({super.key});

  @override
  State<RepairSelectionScreen> createState() => _RepairSelectionScreenState();
}

class _RepairSelectionScreenState extends State<RepairSelectionScreen> {
  String _selected = '';          // 'NHEJ' | 'HDR' | ''
  int _deletionSize = 2;
  final _donorCtrl = TextEditingController();
  int _replacementLen = 0;

  @override
  void dispose() {
    _donorCtrl.dispose();
    super.dispose();
  }

  Future<void> _applyRepair() async {
    final prov = context.read<CrisprProvider>();
    bool ok = false;

    if (_selected == 'NHEJ') {
      ok = await prov.applyNhej(deletionSize: _deletionSize);
    } else if (_selected == 'HDR') {
      final donor = _donorCtrl.text.trim().toUpperCase();
      if (donor.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a donor template sequence.')),
        );
        return;
      }
      ok = await prov.applyHdr(
        donorTemplate:      donor,
        replacementLength:  _replacementLen,
      );
    }

    if (ok && mounted) {
      final analysisOk = await prov.runAnalysis();
      if (analysisOk && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnalysisScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CrisprProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Repair Pathway')),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(kPadMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select DNA Repair Mechanism',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: kPadSm),
                  const Text(
                    'After Cas9 creates a double-strand break, the cell repairs '
                    'the DNA via one of two main pathways.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: kPadMd),

                  // ── NHEJ card ─────────────────────────────────────────────
                  _RepairCard(
                    title: 'NHEJ',
                    subtitle: 'Non-Homologous End Joining',
                    description:
                        'Error-prone repair that introduces random insertions '
                        'or deletions (indels) at the cut site. '
                        'Often disrupts the gene function.',
                    icon: Icons.shuffle_rounded,
                    colour: Colors.orange,
                    selected: _selected == 'NHEJ',
                    onTap: () => setState(() => _selected = 'NHEJ'),
                    child: _selected == 'NHEJ'
                        ? _NhejOptions(
                            deletionSize: _deletionSize,
                            onChanged: (v) =>
                                setState(() => _deletionSize = v),
                          )
                        : null,
                  ),

                  const SizedBox(height: kPadMd),

                  // ── HDR card ──────────────────────────────────────────────
                  _RepairCard(
                    title: 'HDR',
                    subtitle: 'Homology-Directed Repair',
                    description:
                        'Precise repair using a donor template. '
                        'Models intentional gene correction or knock-in.',
                    icon: Icons.edit_note_rounded,
                    colour: Colors.blue,
                    selected: _selected == 'HDR',
                    onTap: () => setState(() => _selected = 'HDR'),
                    child: _selected == 'HDR'
                        ? _HdrOptions(
                            donorCtrl:      _donorCtrl,
                            replacementLen: _replacementLen,
                            onReplChanged:  (v) =>
                                setState(() => _replacementLen = v),
                          )
                        : null,
                  ),

                  const SizedBox(height: kPadLg),
                  if (prov.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: kPadMd),
                      child: Text(prov.error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _selected.isEmpty ? null : _applyRepair,
                      icon: const Icon(Icons.analytics_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Apply & Analyse',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─── Repair pathway card ──────────────────────────────────────────────────────

class _RepairCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color colour;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  const _RepairCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.colour,
    required this.selected,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: selected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
        side: selected
            ? BorderSide(color: colour, width: 2)
            : BorderSide.none,
      ),
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
                  CircleAvatar(
                    backgroundColor: colour.withAlpha(30),
                    child: Icon(icon, color: colour),
                  ),
                  const SizedBox(width: kPadSm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: colour)),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(Icons.check_circle_rounded, color: colour),
                ],
              ),
              const SizedBox(height: kPadSm),
              Text(description,
                  style: TextStyle(fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              if (child != null) ...[
                const Divider(height: 20),
                child!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── NHEJ options ─────────────────────────────────────────────────────────────

class _NhejOptions extends StatelessWidget {
  final int deletionSize;
  final ValueChanged<int> onChanged;

  const _NhejOptions({required this.deletionSize, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Deletion size: $deletionSize bp',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Slider(
          value: deletionSize.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '$deletionSize bp',
          onChanged: (v) => onChanged(v.round()),
        ),
        Text(
          deletionSize % 3 == 0
              ? 'In-frame deletion (multiple of 3) – protein may stay functional'
              : 'Out-of-frame deletion – likely frameshift mutation',
          style: TextStyle(
            fontSize: 11,
            color: deletionSize % 3 == 0 ? Colors.green.shade700 : Colors.red,
          ),
        ),
      ],
    );
  }
}

// ─── HDR options ──────────────────────────────────────────────────────────────

class _HdrOptions extends StatelessWidget {
  final TextEditingController donorCtrl;
  final int replacementLen;
  final ValueChanged<int> onReplChanged;

  const _HdrOptions({
    required this.donorCtrl,
    required this.replacementLen,
    required this.onReplChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Donor Template (A/T/C/G only):',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: donorCtrl,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: InputDecoration(
            hintText: 'GCGCGCGCGCGCGCGCGCGC',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
            isDense: true,
            filled: true,
          ),
        ),
        const SizedBox(height: kPadSm),
        Text('Replacement length: $replacementLen bp',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const Text(
          'Bases to replace at cut site (0 = pure insertion)',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Slider(
          value: replacementLen.toDouble(),
          min: 0,
          max: 20,
          divisions: 20,
          label: '$replacementLen bp',
          onChanged: (v) => onReplChanged(v.round()),
        ),
      ],
    );
  }
}

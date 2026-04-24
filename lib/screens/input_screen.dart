// Input screen – Paste DNA or fetch from NCBI.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crispr_provider.dart';
import '../utils/constants.dart';
import 'dna_viewer_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _pasteCtrl = TextEditingController();
  final _ncbiCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _pasteCtrl.dispose();
    _ncbiCtrl.dispose();
    super.dispose();
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _submitPaste() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<CrisprProvider>();
    final ok = await prov.loadSequence(_pasteCtrl.text.trim());
    if (ok && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DnaViewerScreen()),
      );
    }
  }

  Future<void> _submitNcbi() async {
    final accession = _ncbiCtrl.text.trim();
    if (accession.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an NCBI accession ID')),
      );
      return;
    }
    final prov = context.read<CrisprProvider>();
    final ok   = await prov.fetchNcbiSequence(accession);
    if (ok && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DnaViewerScreen()),
      );
    }
  }

  void _loadDemo() {
    _pasteCtrl.text = kDemoSequence;
    _tabCtrl.animateTo(0);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CrisprProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DNA Input'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(icon: Icon(Icons.paste_rounded),    text: 'Paste'),
            Tab(icon: Icon(Icons.cloud_download_rounded), text: 'NCBI Fetch'),
          ],
        ),
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (prov.error != null) _ErrorBanner(prov.error!),
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _PasteTab(
                        formKey:   _formKey,
                        ctrl:      _pasteCtrl,
                        onSubmit:  _submitPaste,
                        onDemo:    _loadDemo,
                      ),
                      _NcbiTab(
                        ctrl:     _ncbiCtrl,
                        onSubmit: _submitNcbi,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Paste tab ────────────────────────────────────────────────────────────────

class _PasteTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController ctrl;
  final VoidCallback onSubmit;
  final VoidCallback onDemo;

  const _PasteTab({
    required this.formKey,
    required this.ctrl,
    required this.onSubmit,
    required this.onDemo,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kPadMd),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paste DNA Sequence',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Only A, T, C, G characters. Whitespace is ignored.',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: kPadMd),
            TextFormField(
              controller: ctrl,
              maxLines: 10,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'ATGCATGCATGCATGCATGC…',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kRadius)),
                filled: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Sequence is required';
                final clean = v.toUpperCase().replaceAll(RegExp(r'\s'), '');
                final bad = RegExp(r'[^ATCG]').hasMatch(clean);
                if (bad) return 'Sequence contains invalid characters (only A/T/C/G allowed)';
                return null;
              },
            ),
            const SizedBox(height: kPadMd),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onDemo,
                  icon: const Icon(Icons.science_rounded, size: 16),
                  label: const Text('Load Demo (HBB)'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Validate & Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── NCBI tab ────────────────────────────────────────────────────────────────

class _NcbiTab extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSubmit;

  const _NcbiTab({required this.ctrl, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    const examples = [
      ('NM_000518.5', 'HBB – Hemoglobin beta'),
      ('NM_000546.6', 'TP53 – Tumor protein p53'),
      ('NM_007294.4', 'BRCA1 – DNA repair'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(kPadMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fetch from NCBI', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Enter an NCBI nucleotide accession ID. Requires internet access.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: kPadMd),
          TextField(
            controller: ctrl,
            decoration: InputDecoration(
              labelText: 'Accession ID',
              hintText: 'e.g. NM_000518.5',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kRadius)),
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
            ),
          ),
          const SizedBox(height: kPadSm),

          // Quick-fill examples
          const Text('Examples:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 4),
          ...examples.map(
            (e) => ListTile(
              dense: true,
              title: Text(e.$1,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
              subtitle: Text(e.$2, style: const TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right_rounded, size: 18),
              onTap: () => ctrl.text = e.$1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: kPadMd),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.cloud_download_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Fetch Sequence'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.errorContainer,
      padding: const EdgeInsets.all(kPadSm),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: kPadSm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

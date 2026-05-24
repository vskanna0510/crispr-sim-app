// Input screen – Paste DNA or fetch from NCBI.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/crispr_provider.dart';
import '../utils/constants.dart';
import '../widgets/crispr_loading.dart';
import '../widgets/glass_panel.dart';
import '../widgets/interactive_surface.dart';
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
  final _ncbiCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    final ok = await prov.fetchNcbiSequence(accession);
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

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CrisprProvider>();
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            Color.lerp(cs.surface, cs.primaryContainer, 0.4)!,
            Color.lerp(cs.surface, cs.tertiaryContainer, 0.55)!,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary,
                  Color.lerp(cs.primary, cs.secondary, 0.55)!,
                  Color.lerp(cs.secondary, cs.tertiary, 0.35)!,
                ],
              ),
            ),
          ),
          title: const Text('DNA Input'),
          bottom: TabBar(
            controller: _tabCtrl,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withAlpha(50),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: cs.onPrimary,
            unselectedLabelColor: cs.onPrimary.withAlpha(200),
            tabs: const [
              Tab(icon: Icon(Icons.paste_rounded), text: 'Paste'),
              Tab(icon: Icon(Icons.cloud_download_rounded), text: 'NCBI Fetch'),
            ],
          ),
        ),
        body: prov.isLoading
            ? const CrisprLoadingCenter(message: 'Loading sequence…')
            : Column(
                children: [
                  if (prov.error != null) _ErrorBanner(prov.error!),
                  Expanded(
                    child: TabBarView(
                      controller: _tabCtrl,
                      children: [
                        _PasteTab(
                          formKey: _formKey,
                          ctrl: _pasteCtrl,
                          onSubmit: _submitPaste,
                          onDemo: _loadDemo,
                        ),
                        _NcbiTab(
                          ctrl: _ncbiCtrl,
                          onSubmit: _submitNcbi,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

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
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kPadMd),
      child: GlassPanel(
        accentTint: cs.primary,
        borderRadius: 18,
        padding: const EdgeInsets.all(kPadMd),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste DNA Sequence',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Only A, T, C, G characters. Whitespace is ignored.',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: kPadMd),
              TextFormField(
                controller: ctrl,
                maxLines: 10,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'ATGCATGCATGCATGCATGC…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kRadius),
                  ),
                  filled: true,
                  fillColor: cs.surface.withAlpha(180),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Sequence is required';
                  }
                  final clean = v.toUpperCase().replaceAll(RegExp(r'\s'), '');
                  final bad = RegExp(r'[^ATCG]').hasMatch(clean);
                  if (bad) {
                    return 'Sequence contains invalid characters (only A/T/C/G allowed)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: kPadMd),
              Row(
                children: [
                  Expanded(
                    child: InteractiveSurface(
                      onTap: onDemo,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(kRadius),
                          border: Border.all(color: cs.primary, width: 2),
                          color: cs.surface.withAlpha(120),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.science_rounded, color: cs.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Load Demo (HBB)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InteractiveSurface(
                      onTap: onSubmit,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(kRadius),
                          gradient: LinearGradient(
                            colors: [
                              cs.tertiary,
                              Color.lerp(cs.tertiary, cs.secondary, 0.35)!,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.tertiary.withAlpha(100),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: cs.onTertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Validate & Continue',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: cs.onTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(kPadMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassPanel(
            accentTint: cs.secondary,
            borderRadius: 18,
            padding: const EdgeInsets.all(kPadMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fetch from NCBI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter an NCBI nucleotide accession ID. Requires internet access.',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: kPadMd),
                TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    labelText: 'Accession ID',
                    hintText: 'e.g. NM_000518.5',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kRadius),
                    ),
                    prefixIcon: Icon(Icons.search_rounded, color: cs.secondary),
                    filled: true,
                    fillColor: cs.surface.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: kPadMd),
          Text(
            'Examples — tap to autofill',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: cs.secondary,
            ),
          ),
          const SizedBox(height: kPadSm),
          ...examples.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: kPadSm),
              child: InteractiveSurface(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ctrl.text = e.$1;
                },
                child: GlassPanel(
                  accentTint: cs.tertiary,
                  borderRadius: 12,
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(Icons.biotech_rounded, color: cs.tertiary),
                    title: Text(
                      e.$1,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    ),
                    subtitle: Text(e.$2, style: const TextStyle(fontSize: 11)),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: cs.tertiary.withAlpha(200),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: kPadMd),
          SizedBox(
            width: double.infinity,
            child: InteractiveSurface(
              onTap: onSubmit,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kRadius),
                  gradient: LinearGradient(
                    colors: [
                      cs.secondary,
                      Color.lerp(cs.secondary, cs.primary, 0.25)!,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.secondary.withAlpha(110),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_download_rounded, color: cs.onSecondary),
                      const SizedBox(width: 10),
                      Text(
                        'Fetch Sequence',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: cs.onSecondary,
                        ),
                      ),
                    ],
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

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(kPadMd, kPadSm, kPadMd, 0),
      child: GlassPanel(
        borderRadius: 12,
        blurSigma: 14,
        accentTint: cs.error,
        padding: const EdgeInsets.all(kPadSm),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error),
            const SizedBox(width: kPadSm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

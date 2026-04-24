// Home screen – hero landing page with feature highlights.

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero app-bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: cs.primary,
            flexibleSpace: const FlexibleSpaceBar(
              stretchModes: [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              centerTitle: true,
              title: Text('CRISPR-Sim',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              background: _HeroBanner(),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(kPadMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Interactive Gene Editing Simulator',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Simulate CRISPR-Cas9 editing from sequence input to protein-level '
                    'mutation analysis — entirely on your device.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: kPadLg),

                  // ── Feature cards ─────────────────────────────────────────
                  const _FeatureCard(
                    icon: Icons.input_rounded,
                    colour: Color(0xFF1565C0),
                    title: 'Flexible Input',
                    subtitle:
                        'Paste a DNA string, upload a FASTA file, or fetch directly from NCBI.',
                  ),
                  const SizedBox(height: kPadSm),
                  const _FeatureCard(
                    icon: Icons.biotech_rounded,
                    colour: Color(0xFF2E7D32),
                    title: 'Full Pipeline',
                    subtitle:
                        'PAM scanning \u2192 gRNA extraction \u2192 Cas9 cut \u2192 NHEJ/HDR repair.',
                  ),
                  const SizedBox(height: kPadSm),
                  const _FeatureCard(
                    icon: Icons.analytics_rounded,
                    colour: Color(0xFF6A1B9A),
                    title: 'Mutation Analysis',
                    subtitle:
                        'DNA \u2192 mRNA \u2192 Protein translation with frameshift & stop-codon detection.',
                  ),
                  const SizedBox(height: kPadLg),

                  // ── CTA ──────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InputScreen()),
                      ),
                      icon: const Icon(Icons.play_circle_fill_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Start Simulation',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: kPadLg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero banner (ASCII DNA + gradient) ──────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.secondary],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Stylised DNA double-helix in text
            Text(
              '5\'─A─T─G─C─A─G─G─T─3\'\n'
              '   | | | | | | | |\n'
              '3\'─T─A─C─G─T─C─C─A─5\'',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Colors.white.withAlpha(210),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Feature card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color colour;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.colour,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
        side: BorderSide(color: colour.withAlpha(50)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colour.withAlpha(30),
          child: Icon(icon, color: colour),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: kPadMd, vertical: kPadSm),
      ),
    );
  }
}

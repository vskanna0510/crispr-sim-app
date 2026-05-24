// Home screen – hero landing page with feature highlights.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/constants.dart';
import '../widgets/dna_sequencing_helix.dart';
import '../widgets/glass_panel.dart';
import '../widgets/interactive_surface.dart';
import '../widgets/stagger_column.dart';
import 'input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            Color.lerp(cs.surface, cs.primaryContainer, 0.55)!,
            Color.lerp(cs.surface, cs.tertiaryContainer, 0.5)!,
            Color.lerp(cs.secondaryContainer, cs.tertiary, 0.22)!,
          ],
          stops: const [0.0, 0.28, 0.62, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 312,
              pinned: true,
              stretch: true,
              backgroundColor: cs.primary,
              flexibleSpace: const FlexibleSpaceBar(
                stretchModes: [
                  StretchMode.zoomBackground,
                  StretchMode.fadeTitle,
                ],
                centerTitle: true,
                title: Text(
                  'CRISPR-Sim',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                background: _HeroBannerLive(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(kPadMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, child) {
                        return Opacity(
                          opacity: t,
                          child: Transform.translate(
                            offset: Offset(0, 10 * (1 - t)),
                            child: child,
                          ),
                        );
                      },
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [
                              cs.onSurface,
                              Color.lerp(cs.primary, cs.onSurface, 0.35)!,
                              cs.secondary,
                            ],
                          ).createShader(bounds);
                        },
                        child: Text(
                          'Interactive Gene Editing Simulator',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, child) {
                        return Opacity(
                          opacity: t,
                          child: Transform.translate(
                            offset: Offset(0, 12 * (1 - t)),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        'Simulate CRISPR-Cas9 editing from sequence input to protein-level '
                        'mutation analysis — entirely on your device.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: kPadLg),
                    const StaggerColumn(
                      duration: Duration(milliseconds: 1000),
                      children: [
                        _InteractiveFeatureCard(
                          icon: Icons.input_rounded,
                          colour: Color(0xFF42A5F5),
                          title: 'Flexible Input',
                          subtitle:
                              'Paste a DNA string, upload a FASTA file, or fetch directly from NCBI.',
                          hint:
                              'Start from raw sequence or NCBI — we validate and normalize for you.',
                        ),
                        SizedBox(height: kPadSm),
                        _InteractiveFeatureCard(
                          icon: Icons.biotech_rounded,
                          colour: Color(0xFF69F0AE),
                          title: 'Full Pipeline',
                          subtitle:
                              'PAM scanning \u2192 gRNA extraction \u2192 Cas9 cut \u2192 NHEJ/HDR repair.',
                          hint:
                              'Each step is animated so you can feel progression through the edit.',
                        ),
                        SizedBox(height: kPadSm),
                        _InteractiveFeatureCard(
                          icon: Icons.analytics_rounded,
                          colour: Color(0xFFE040FB),
                          title: 'Mutation Analysis',
                          subtitle:
                              'DNA \u2192 mRNA \u2192 Protein translation with frameshift & stop-codon detection.',
                          hint:
                              'See how your edit ripples from DNA through to the protein line.',
                        ),
                        SizedBox(height: kPadLg),
                      ],
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 850),
                      curve: Curves.easeOutBack,
                      builder: (context, t, child) {
                        return Transform.scale(
                          scale: 0.9 + 0.1 * t,
                          child: Opacity(
                            opacity: t.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: _GradientCta(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InputScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: kPadLg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientCta extends StatefulWidget {
  final VoidCallback onPressed;

  const _GradientCta({required this.onPressed});

  @override
  State<_GradientCta> createState() => _GradientCtaState();
}

class _GradientCtaState extends State<_GradientCta>
    with SingleTickerProviderStateMixin {
  late AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, _) {
          final pulse = 0.55 + 0.45 * _glow.value;
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadius + 6),
              boxShadow: [
                BoxShadow(
                  color: Color.lerp(cs.primary, cs.secondary, 0.4)!
                      .withAlpha((90 * pulse).round().clamp(40, 120)),
                  blurRadius: 22 + 8 * pulse,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(kRadius + 6),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kRadius + 6),
                    gradient: LinearGradient(
                      begin: Alignment(-0.9 + _glow.value * 0.3, -1),
                      end: const Alignment(0.9, 1.2),
                      colors: [
                        cs.primary,
                        Color.lerp(cs.primary, cs.secondary, 0.55)!,
                        cs.secondary,
                        Color.lerp(cs.secondary, cs.tertiary, 0.4)!,
                      ],
                      stops: const [0.0, 0.35, 0.72, 1.0],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_fill_rounded,
                          color: cs.onPrimary,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Start Simulation',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: cs.onPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroBannerLive extends StatefulWidget {
  const _HeroBannerLive();

  @override
  State<_HeroBannerLive> createState() => _HeroBannerLiveState();
}

class _HeroBannerLiveState extends State<_HeroBannerLive>
    with SingleTickerProviderStateMixin {
  late AnimationController _shift;

  @override
  void initState() {
    super.initState();
    _shift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _shift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _shift,
      builder: (context, _) {
        final t = _shift.value;
        final wiggle = math.sin(t * math.pi * 2) * 0.04;
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.85 + t + wiggle, -1.1),
                  end: Alignment(0.95 - t * 0.4, 1.05),
                  colors: [
                    cs.primary,
                    const Color(0xFF7C4DFF),
                    Color.lerp(cs.secondary, cs.tertiary, 0.5 + 0.2 * math.sin(t * math.pi))!,
                    cs.secondary,
                    const Color(0xFFFF6E40),
                  ],
                  stops: [
                    0,
                    0.22,
                    0.48 + 0.08 * math.cos(t * math.pi * 2),
                    0.78,
                    1,
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _HeroMeshPainter(phase: t * math.pi * 2),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 36),
                Transform.scale(
                  scale: 1.0 + 0.045 * math.sin(t * math.pi * 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GlassPanel(
                      borderRadius: 16,
                      blurSigma: 12,
                      accentTint: Colors.white,
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 74,
                        height: 74,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.biotech_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '5\'─A─T─G─C─A─G─G─T─3\'\n'
                  '   | | | | | | | |\n'
                  '3\'─T─A─C─G─T─C─C─A─5\'',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.white.withAlpha(215),
                    height: 1.55,
                    shadows: const [
                      Shadow(blurRadius: 8, color: Colors.black26),
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: GlassPanel(
                borderRadius: 14,
                blurSigma: 16,
                accentTint: Color(0xFF00E5FF),
                padding: EdgeInsets.zero,
                child: DnaSequencingHelix(
                  sequence: kDemoShortSequence,
                  height: 92,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroMeshPainter extends CustomPainter {
  final double phase;

  _HeroMeshPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withAlpha(22)
      ..strokeWidth = 1;
    const step = 26.0;
    for (var x = 0.0; x < size.width; x += step) {
      final o = (x / size.width + phase * 0.02) % 1;
      canvas.drawLine(
        Offset(x + o * 8, 0),
        Offset(x + o * 8, size.height),
        p,
      );
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(
        Offset(0, y + math.sin(phase + y * 0.02) * 6),
        Offset(size.width, y + math.sin(phase + y * 0.02) * 6),
        Paint()
          ..color = Colors.white.withAlpha(14)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeroMeshPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _InteractiveFeatureCard extends StatelessWidget {
  final IconData icon;
  final Color colour;
  final String title;
  final String subtitle;
  final String hint;

  const _InteractiveFeatureCard({
    required this.icon,
    required this.colour,
    required this.title,
    required this.subtitle,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tile = GlassPanel(
      borderRadius: kRadius + 4,
      blurSigma: 20,
      accentTint: colour,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colour.withAlpha(100),
            child: Icon(icon, color: colour.computeLuminance() > 0.5 ? Colors.black87 : Colors.white),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          trailing: Icon(
            Icons.touch_app_rounded,
            size: 24,
            color: colour.withAlpha(220),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: kPadMd, vertical: kPadSm),
        ),
      ),
    );

    return InteractiveSurface(
      hoverScale: 1.035,
      onTap: () {
        HapticFeedback.selectionClick();
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          showDragHandle: false,
          builder: (ctx) => Padding(
            padding: EdgeInsets.only(
              left: kPadMd,
              right: kPadMd,
              bottom: MediaQuery.of(ctx).padding.bottom + kPadMd,
            ),
            child: GlassPanel(
              borderRadius: 20,
              blurSigma: 24,
              accentTint: colour,
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colour.withAlpha(140),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colour.withAlpha(90),
                        child: Icon(
                          icon,
                          color: colour.computeLuminance() > 0.5
                              ? Colors.black87
                              : Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colour,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    hint,
                    style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 22),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Got it'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: tile,
    );
  }
}

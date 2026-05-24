// Full-screen launch experience: helix, logo pulse, tagline — then fades to reveal the app.

import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'dna_sequencing_helix.dart';
import 'glass_panel.dart';

class AppBootstrap extends StatefulWidget {
  final Widget child;

  const AppBootstrap({super.key, required this.child});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap>
    with TickerProviderStateMixin {
  late AnimationController _master;
  late Animation<double> _helixOpacity;
  late Animation<double> _helixSlide;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _titleOpacity;
  late Animation<double> _titleSlide;
  late Animation<double> _tagOpacity;
  late Animation<double> _curtain;

  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _helixOpacity = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
    );
    _helixSlide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.0, 0.32, curve: Curves.easeOutCubic),
      ),
    );

    _logoScale = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.12, 0.42, curve: Curves.elasticOut),
      ),
    );
    _logoRotation = Tween<double>(begin: -0.08, end: 0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.12, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _titleOpacity = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.28, 0.48, curve: Curves.easeOut),
    );
    _titleSlide = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.28, 0.52, curve: Curves.easeOutCubic),
      ),
    );

    _tagOpacity = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
    );

    _curtain = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.62, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _master.forward().then((_) {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _master.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_showSplash)
          AnimatedBuilder(
            animation: _master,
            builder: (context, _) {
              final cs = Theme.of(context).colorScheme;
              final curtain = _curtain.value.clamp(0.0, 1.0);
              return IgnorePointer(
                ignoring: curtain < 0.05,
                child: Opacity(
                  opacity: curtain,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primary,
                          cs.secondary,
                          cs.tertiaryContainer.withAlpha(220),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            Opacity(
                              opacity: _helixOpacity.value,
                              child: Transform.translate(
                                offset: Offset(0, _helixSlide.value),
                                child: const GlassPanel(
                                  borderRadius: 16,
                                  blurSigma: 20,
                                  accentTint: Color(0xFF00E5FF),
                                  padding: EdgeInsets.zero,
                                  child: DnaSequencingHelix(
                                    sequence: kDemoShortSequence,
                                    height: 168,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(flex: 1),
                            Transform.rotate(
                              angle: _logoRotation.value,
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(80),
                                          blurRadius: 24,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/app_logo.png',
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 88,
                                        height: 88,
                                        alignment: Alignment.center,
                                        color: Colors.white24,
                                        child: const Icon(
                                          Icons.biotech_rounded,
                                          size: 48,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Opacity(
                              opacity: _titleOpacity.value,
                              child: Transform.translate(
                                offset: Offset(0, _titleSlide.value),
                                child: ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.white.withAlpha(230),
                                        Colors.cyanAccent.shade100,
                                      ],
                                      stops: const [0.0, 0.55, 1.0],
                                    ).createShader(bounds);
                                  },
                                  child: const Text(
                                    'CRISPR-Sim',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Opacity(
                              opacity: _tagOpacity.value,
                              child: Text(
                                'Gene editing. In your hands.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withAlpha(220),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const Spacer(flex: 2),
                            Opacity(
                              opacity: (1 - _curtain.value * 0.3).clamp(0.0, 1.0),
                              child: SizedBox(
                                width: 160,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: const LinearProgressIndicator(
                                    minHeight: 3,
                                    backgroundColor: Colors.white24,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

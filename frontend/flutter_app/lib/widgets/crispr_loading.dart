// Branded loading UI: cycling A/T/G/C helix + optional status line.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CrisprLoadingCenter extends StatefulWidget {
  final String message;

  const CrisprLoadingCenter({
    super.key,
    this.message = 'Processing…',
  });

  @override
  State<CrisprLoadingCenter> createState() => _CrisprLoadingCenterState();
}

class _CrisprLoadingCenterState extends State<CrisprLoadingCenter>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = _c.value * 2 * math.pi;
                return SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(4, (i) {
                      final phase = t + i * math.pi / 2;
                      final scale = 0.65 + 0.35 * math.sin(phase);
                      final colours = [kColourA, kColourT, kColourG, kColourC];
                      final labels = ['A', 'T', 'G', 'C'];
                      final o = 0.55 + 0.45 * ((math.sin(phase) + 1) / 2);
                      return Transform.translate(
                        offset: Offset(
                          math.cos(phase + i) * 22,
                          math.sin(phase * 0.9 + i) * 18,
                        ),
                        child: Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: o.clamp(0.4, 1.0),
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colours[i].withAlpha(40),
                                shape: BoxShape.circle,
                                border: Border.all(color: colours[i], width: 2),
                              ),
                              child: Text(
                                labels[i],
                                style: TextStyle(
                                  color: colours[i],
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(4),
                backgroundColor: cs.surfaceContainerHighest,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

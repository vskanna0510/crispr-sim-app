// Large double-helix + “sequencer” sweep — for DNA viewer / loading.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../utils/constants.dart';

String _complement(String b) {
  switch (b.toUpperCase()) {
    case 'A':
      return 'T';
    case 'T':
      return 'A';
    case 'G':
      return 'C';
    case 'C':
      return 'G';
    default:
      return 'N';
  }
}

/// Animated double helix with base-pair rungs and a scanning highlight (Sanger-style read).
class DnaSequencingHelix extends StatefulWidget {
  final String sequence;
  final double height;

  /// When true, helix slowly “rolls”; when false, only the scanner moves (lighter GPU).
  final bool rotateHelix;

  const DnaSequencingHelix({
    super.key,
    this.sequence = '',
    this.height = 200,
    this.rotateHelix = true,
  });

  @override
  State<DnaSequencingHelix> createState() => _DnaSequencingHelixState();
}

class _DnaSequencingHelixState extends State<DnaSequencingHelix>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final helixPhase =
              widget.rotateHelix ? _c.value * 2 * math.pi * 1.15 : 0.0;
          final scanT = (_c.value * 1.4) % 1.0;
          return CustomPaint(
            painter: _HelixPainter(
              phase: helixPhase,
              scanT: scanT,
              sequence: widget.sequence,
              colorScheme: Theme.of(context).colorScheme,
              brightness: Theme.of(context).brightness,
            ),
          );
        },
      ),
    );
  }
}

class _HelixPainter extends CustomPainter {
  final double phase;
  final double scanT;
  final String sequence;
  final ColorScheme colorScheme;
  final Brightness brightness;

  _HelixPainter({
    required this.phase,
    required this.scanT,
    required this.sequence,
    required this.colorScheme,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final cy = h * 0.52;
    final amp = h * 0.30;
    final waveLen = w / 2.35;
    final nSeg = (w / 4).ceil().clamp(36, 140);
    final rungEvery = (nSeg / 28).ceil().clamp(2, 8);

    final seq = sequence.toUpperCase();
    const demo = 'ATGCGATACCTGGCATTAGC';

    String baseAt(int rungIndex) {
      if (seq.isNotEmpty) {
        return seq[rungIndex % seq.length].toUpperCase();
      }
      return demo[rungIndex % demo.length];
    }

    // Soft vignette background
    final bg = Paint()
      ..shader = RadialGradient(
        colors: [
          colorScheme.primaryContainer.withAlpha(brightness == Brightness.dark ? 38 : 55),
          colorScheme.surfaceContainerHighest.withAlpha(20),
        ],
      ).createShader(Rect.fromCenter(center: Offset(w / 2, cy), width: w, height: h * 1.2));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(14),
      ),
      bg,
    );

    // Backbone paths
    final bbPaint1 = Paint()
      ..color = colorScheme.primary.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    final bbPaint2 = Paint()
      ..color = colorScheme.tertiary.withAlpha(140)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    final path2 = Path();

    for (int i = 0; i <= nSeg; i++) {
      final x = w * i / nSeg;
      final th = 2 * math.pi * x / waveLen + phase;
      final y1 = cy + amp * math.sin(th);
      final y2 = cy - amp * math.sin(th);
      if (i == 0) {
        path1.moveTo(x, y1);
        path2.moveTo(x, y2);
      } else {
        path1.lineTo(x, y1);
        path2.lineTo(x, y2);
      }
    }
    canvas.drawPath(path1, bbPaint1);
    canvas.drawPath(path2, bbPaint2);

    // Base-pair rungs + letter chips (big readable animation)
    for (int i = 0; i <= nSeg; i += rungEvery) {
      final x = w * i / nSeg;
      final th = 2 * math.pi * x / waveLen + phase;
      final y1 = cy + amp * math.sin(th);
      final y2 = cy - amp * math.sin(th);
      final rungIndex = i ~/ rungEvery;
      final b = baseAt(rungIndex);
      final bc = dnaBaseColour(b);
      final partner = _complement(b);

      final scanX = scanT * w;
      final dist = (x - scanX).abs();
      final inBeam = dist < w * 0.07;
      final glow = inBeam ? 1.0 : 0.35 + 0.25 * math.sin(th * 0.5 + rungIndex * 0.3);

      final rungPaint = Paint()
        ..color = bc.withAlpha((180 + 75 * glow).round().clamp(80, 255))
        ..strokeWidth = inBeam ? 3.2 : 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x, y1), Offset(x, y2), rungPaint);

      // Small A·T / G·C labels at rung midpoint when beam passes
      if (inBeam || glow > 0.55) {
        canvas.save();
        canvas.translate(x, (y1 + y2) / 2);
        canvas.scale(math.min(1.05, 0.85 + glow * 0.35));
        final chip = RRect.fromRectAndRadius(
          const Rect.fromLTWH(-11, -9, 22, 18),
          const Radius.circular(5),
        );
        canvas.drawRRect(
          chip,
          Paint()..color = bc.withAlpha((40 + 100 * glow).round().clamp(40, 200)),
        );
        canvas.drawRRect(
          chip,
          Paint()
            ..color = bc.withAlpha(220)
            ..style = PaintingStyle.stroke
            ..strokeWidth = inBeam ? 1.8 : 1.1,
        );
        final tp = TextPainter(
          text: TextSpan(
            text: '$b·$partner',
            style: TextStyle(
              color: Colors.white.withAlpha((200 + 55 * glow).round()),
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }
    }

    // Sequencer sweep band
    final scanX = scanT * w;
    final beamW = w * 0.14;
    final beam = Rect.fromCenter(center: Offset(scanX, cy), width: beamW, height: h * 0.92);
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          colorScheme.primary.withAlpha(45),
          colorScheme.inversePrimary.withAlpha(brightness == Brightness.dark ? 90 : 120),
          colorScheme.primary.withAlpha(45),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(beam);
    canvas.drawRect(beam, beamPaint);

    // Bright core line (laser)
    final corePaint = Paint()
      ..color = colorScheme.onPrimaryContainer.withAlpha(160)
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawLine(Offset(scanX, h * 0.08), Offset(scanX, h * 0.92), corePaint);
    canvas.drawLine(
      Offset(scanX, h * 0.08),
      Offset(scanX, h * 0.92),
      Paint()
        ..color = Colors.white.withAlpha(200)
        ..strokeWidth = 1.2,
    );

    // Direction labels
    final cap = TextPainter(
      text: TextSpan(
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant.withAlpha(180),
        ),
        children: const [
          TextSpan(text: '5′ '),
          TextSpan(
            text: '→',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          TextSpan(text: ' 3′   sequencing…'),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w);
    cap.paint(canvas, Offset(kPadSm, h - cap.height - 6));
  }

  @override
  bool shouldRepaint(covariant _HelixPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.scanT != scanT ||
        oldDelegate.sequence != sequence ||
        oldDelegate.brightness != brightness;
  }
}

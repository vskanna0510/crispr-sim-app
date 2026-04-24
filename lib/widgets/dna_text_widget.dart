// Colour-coded DNA sequence renderer.
//
// A = Blue  | T = Red  | G = Amber  | C = Green
// PAM sites are underlined; the cut position has a red vertical marker.

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/crispr_models.dart';

class DnaTextWidget extends StatelessWidget {
  final String sequence;

  /// Highlight these ranges as PAM sites (bold + tinted background).
  final List<PamSite> pamSites;

  /// Draw a red caret at this position (null = no caret).
  final int? cutPosition;

  /// Maximum characters to render before truncating.
  final int maxChars;

  const DnaTextWidget({
    super.key,
    required this.sequence,
    this.pamSites = const [],
    this.cutPosition,
    this.maxChars = 300,
  });

  bool _isPam(int index) =>
      pamSites.any((p) => index >= p.start && index < p.end);

  @override
  Widget build(BuildContext context) {
    final displaySeq =
        sequence.length > maxChars ? sequence.substring(0, maxChars) : sequence;
    final truncated = sequence.length > maxChars;

    final spans = <InlineSpan>[];

    for (int i = 0; i < displaySeq.length; i++) {
      // Red caret before the cut position
      if (cutPosition != null && i == cutPosition) {
        spans.add(const TextSpan(
          text: '|',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ));
      }

      final base = displaySeq[i];
      final isPam = _isPam(i);
      final colour = dnaBaseColour(base);

      spans.add(TextSpan(
        text: base,
        style: TextStyle(
          color: colour,
          fontWeight: isPam ? FontWeight.bold : FontWeight.normal,
          backgroundColor: isPam
              ? colour.withAlpha(30)
              : Colors.transparent,
          decoration: isPam ? TextDecoration.underline : TextDecoration.none,
          decorationColor: colour,
          fontFamily: 'monospace',
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ));
    }

    if (truncated) {
      spans.add(TextSpan(
        text: '  … (${sequence.length - maxChars} more bp)',
        style: TextStyle(
          color: Colors.grey.shade500,
          fontStyle: FontStyle.italic,
          fontSize: 12,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      softWrap: true,
    );
  }
}

// ─── Compact legend ───────────────────────────────────────────────────────────

class DnaLegend extends StatelessWidget {
  const DnaLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        _LegendItem('A', kColourA),
        _LegendItem('T', kColourT),
        _LegendItem('G', kColourG),
        _LegendItem('C', kColourC),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String base;
  final Color colour;
  const _LegendItem(this.base, this.colour);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14, color: colour),
        const SizedBox(width: 4),
        Text(base, style: TextStyle(fontSize: 12, color: colour, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

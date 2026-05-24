// Colour-coded DNA sequence renderer.
//
// A = Blue  | T = Red  | G = Amber  | C = Green
// PAM sites are underlined; the cut position has a red vertical marker.

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/crispr_models.dart';
import 'dna_spans.dart';

class DnaTextWidget extends StatelessWidget {
  final String sequence;
  final List<PamSite> pamSites;
  final int? cutPosition;
  final int maxChars;

  const DnaTextWidget({
    super.key,
    required this.sequence,
    this.pamSites = const [],
    this.cutPosition,
    this.maxChars = 300,
  });

  @override
  Widget build(BuildContext context) {
    final displaySeq =
        sequence.length > maxChars ? sequence.substring(0, maxChars) : sequence;
    return RichText(
      text: TextSpan(
        children: buildDnaRichTextSpans(
          visibleSeq: displaySeq,
          fullSequenceLength: sequence.length,
          maxChars: maxChars,
          pamSites: pamSites,
          cutPosition: cutPosition,
        ),
      ),
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
        Text(base,
            style: TextStyle(
                fontSize: 12, color: colour, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

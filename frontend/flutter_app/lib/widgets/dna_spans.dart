// Shared RichText span builder for colour-coded DNA (used by static + animated views).

import 'package:flutter/material.dart';
import '../models/crispr_models.dart';
import '../utils/constants.dart';

bool pamCoversIndex(List<PamSite> pamSites, int index) =>
    pamSites.any((p) => index >= p.start && index < p.end);

/// Builds spans for [visibleSeq] (already truncated to what should appear).
/// [fullSequenceLength] and [maxChars] control the trailing "more bp" suffix.
List<InlineSpan> buildDnaRichTextSpans({
  required String visibleSeq,
  required int fullSequenceLength,
  int maxChars = 300,
  List<PamSite> pamSites = const [],
  int? cutPosition,
}) {
  final spans = <InlineSpan>[];

  for (int i = 0; i < visibleSeq.length; i++) {
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

    final base = visibleSeq[i];
    final isPam = pamCoversIndex(pamSites, i);
    final colour = dnaBaseColour(base);

    spans.add(TextSpan(
      text: base,
      style: TextStyle(
        color: colour,
        fontWeight: isPam ? FontWeight.bold : FontWeight.normal,
        backgroundColor: isPam ? colour.withAlpha(30) : Colors.transparent,
        decoration: isPam ? TextDecoration.underline : TextDecoration.none,
        decorationColor: colour,
        fontFamily: 'monospace',
        fontSize: 13,
        letterSpacing: 0.5,
      ),
    ));
  }

  final truncated = fullSequenceLength > maxChars;
  final shownAllOfCap = visibleSeq.length >= (fullSequenceLength > maxChars ? maxChars : fullSequenceLength);
  if (truncated && shownAllOfCap) {
    spans.add(TextSpan(
      text: '  … (${fullSequenceLength - maxChars} more bp)',
      style: TextStyle(
        color: Colors.grey.shade500,
        fontStyle: FontStyle.italic,
        fontSize: 12,
      ),
    ));
  }

  return spans;
}

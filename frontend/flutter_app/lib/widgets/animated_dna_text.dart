// DNA sequence with a “sequencing” style reveal (bases appear progressively).

import 'package:flutter/material.dart';
import '../models/crispr_models.dart';
import 'dna_spans.dart';

class AnimatedDnaTextWidget extends StatefulWidget {
  final String sequence;
  final List<PamSite> pamSites;
  final int? cutPosition;
  final int maxChars;

  const AnimatedDnaTextWidget({
    super.key,
    required this.sequence,
    this.pamSites = const [],
    this.cutPosition,
    this.maxChars = 400,
  });

  @override
  State<AnimatedDnaTextWidget> createState() => _AnimatedDnaTextWidgetState();
}

class _AnimatedDnaTextWidgetState extends State<AnimatedDnaTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  int get _cap =>
      widget.sequence.length > widget.maxChars ? widget.maxChars : widget.sequence.length;

  @override
  void initState() {
    super.initState();
    final ms = (1200 + _cap * 18).clamp(1400, 5600).toInt();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..forward();
  }

  @override
  void didUpdateWidget(AnimatedDnaTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sequence != widget.sequence ||
        oldWidget.maxChars != widget.maxChars) {
      final ms = (1200 + _cap * 18).clamp(1400, 5600).toInt();
      _c.duration = Duration(milliseconds: ms);
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sequence.isEmpty) {
      return const Text('—', style: TextStyle(color: Colors.grey));
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final n = (_cap * Curves.easeOutCubic.transform(_c.value)).ceil();
        final visible = n.clamp(1, _cap);
        final visibleSeq = widget.sequence.substring(0, visible);
        return RichText(
          text: TextSpan(
            children: buildDnaRichTextSpans(
              visibleSeq: visibleSeq,
              fullSequenceLength: widget.sequence.length,
              maxChars: widget.maxChars,
              pamSites: widget.pamSites,
              cutPosition: widget.cutPosition != null &&
                      widget.cutPosition! < visible
                  ? widget.cutPosition
                  : null,
            ),
          ),
          softWrap: true,
        );
      },
    );
  }
}

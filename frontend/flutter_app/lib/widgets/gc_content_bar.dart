// GC-content progress bar widget with ideal-range indicator.

import 'package:flutter/material.dart';

class GcContentBar extends StatelessWidget {
  final double gcPercent;

  const GcContentBar({super.key, required this.gcPercent});

  Color get _barColour {
    if (gcPercent >= 40.0 && gcPercent <= 60.0) return Colors.green.shade600;
    if (gcPercent >= 30.0 && gcPercent <= 70.0) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String get _label {
    if (gcPercent >= 40.0 && gcPercent <= 60.0) return 'Optimal';
    if (gcPercent >= 30.0 && gcPercent <= 70.0) return 'Acceptable';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('GC Content',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Row(
              children: [
                Text(
                  '${gcPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _barColour,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _barColour.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _barColour.withAlpha(80)),
                  ),
                  child: Text(
                    _label,
                    style: TextStyle(
                        fontSize: 11,
                        color: _barColour,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background track
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: gcPercent / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(_barColour),
                minHeight: 10,
              ),
            ),
            // Ideal-range markers at 40 % and 60 %
            ...[0.40, 0.60].map((frac) => FractionallySizedBox(
                  widthFactor: frac,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 2,
                      height: 14,
                      color: Colors.green.shade800.withAlpha(160),
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('0 %', style: _legendStyle),
            Text('Ideal: 40\u201360 %',
                style: _legendStyle.copyWith(color: Colors.green.shade700)),
            const Text('100 %', style: _legendStyle),
          ],
        ),
      ],
    );
  }

  static const _legendStyle = TextStyle(fontSize: 10, color: Colors.grey);
}

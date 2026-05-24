import 'package:flutter/material.dart';

import '../models/crispr_models.dart';
import '../utils/constants.dart';

class GeneInfoCard extends StatelessWidget {
  final GeneInfo info;

  const GeneInfoCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.secondaryContainer.withAlpha(80),
      child: Padding(
        padding: const EdgeInsets.all(kPadMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.biotech_rounded, color: cs.secondary),
                const SizedBox(width: 8),
                Text(
                  'Gene Information',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const Divider(height: 20),
            _row('Gene', info.geneSymbol),
            _row('Name', info.geneName),
            _row('Chromosome', info.chromosome),
            const SizedBox(height: 6),
            Text('Function', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            Text(info.function, style: const TextStyle(fontSize: 13)),
            if (info.associatedDiseases.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Associated diseases',
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: info.associatedDiseases
                    .map((d) => Chip(
                          label: Text(d, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}

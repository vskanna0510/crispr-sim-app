import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/crispr_models.dart';
import '../providers/crispr_provider.dart';
import '../utils/constants.dart';

class CasSystemSelector extends StatelessWidget {
  const CasSystemSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CrisprProvider>();
    final cs = Theme.of(context).colorScheme;
    final systems = prov.casSystems.isNotEmpty
        ? prov.casSystems
        : [
            CasSystemInfo(
              id: 'cas9',
              name: 'Cas9',
              pamMotif: 'NGG',
              grnaLength: 20,
              targetMolecule: 'DNA',
              application: 'DNA editing',
              description: '',
            ),
            CasSystemInfo(
              id: 'cas12a',
              name: 'Cas12a',
              pamMotif: 'TTTV',
              grnaLength: 23,
              targetMolecule: 'DNA',
              application: 'Alternative DNA editing',
              description: '',
            ),
            CasSystemInfo(
              id: 'cas13',
              name: 'Cas13',
              pamMotif: 'Poly-U',
              grnaLength: 22,
              targetMolecule: 'RNA',
              application: 'RNA targeting',
              description: '',
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select CRISPR System',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: kPadSm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: systems.map((s) {
            final selected = prov.casType == s.id;
            return ChoiceChip(
              label: Text(s.name),
              selected: selected,
              onSelected: (_) => prov.setCasType(s.id),
              selectedColor: cs.primaryContainer,
              labelStyle: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? cs.onPrimaryContainer : cs.onSurface,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        Builder(
          builder: (context) {
            final active = systems.firstWhere(
              (s) => s.id == prov.casType,
              orElse: () => systems.first,
            );
            return Text(
              'PAM: ${active.pamMotif}  •  Target: ${active.targetMolecule}  •  ${active.application}',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            );
          },
        ),
      ],
    );
  }
}

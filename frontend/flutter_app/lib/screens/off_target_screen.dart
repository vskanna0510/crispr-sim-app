import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/crispr_provider.dart';
import '../utils/constants.dart';

class OffTargetScreen extends StatelessWidget {
  const OffTargetScreen({super.key});

  Color _riskColor(String risk, ColorScheme cs) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return Colors.red.shade600;
      case 'MODERATE':
        return Colors.amber.shade700;
      default:
        return Colors.green.shade600;
    }
  }

  IconData _riskIcon(String colorKey) {
    switch (colorKey) {
      case 'danger':
        return Icons.dangerous_rounded;
      case 'moderate':
        return Icons.warning_amber_rounded;
      default:
        return Icons.verified_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CrisprProvider>();
    final site = prov.selectedPamSite;
    final ot = prov.offTargetResult;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Off-Target Prediction')),
      body: ot == null || site?.grna == null
          ? const Center(child: Text('Select a guide to assess off-target risk.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(kPadMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(kPadMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Guide RNA',
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 6),
                          SelectableText(
                            site!.grna!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Off-target sites found: ${ot.offTargetCount}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _riskIcon(ot.overallRiskColor),
                                color: _riskColor(ot.overallRisk, cs),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Overall risk: ${ot.overallRisk}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _riskColor(ot.overallRisk, cs),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: kPadMd),
                  ...ot.sites.asMap().entries.map((e) {
                    final i = e.key + 1;
                    final s = e.value;
                    final colour = _riskColor(s.risk, cs);
                    return Card(
                      margin: const EdgeInsets.only(bottom: kPadSm),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colour.withAlpha(40),
                          child: Text('$i',
                              style: TextStyle(
                                  color: colour, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(s.location,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          'Mismatches: ${s.mismatches}  •  Risk: ${s.risk}',
                        ),
                        trailing: Icon(_riskIcon(s.riskColor), color: colour),
                      ),
                    );
                  }),
                  const SizedBox(height: kPadSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _legend(Colors.green, 'Safe'),
                      _legend(Colors.amber, 'Moderate'),
                      _legend(Colors.red, 'Dangerous'),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _legend(Color c, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: c),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}

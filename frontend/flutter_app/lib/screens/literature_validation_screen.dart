import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/crispr_provider.dart';
import '../utils/constants.dart';

class LiteratureValidationScreen extends StatefulWidget {
  const LiteratureValidationScreen({super.key});

  @override
  State<LiteratureValidationScreen> createState() =>
      _LiteratureValidationScreenState();
}

class _LiteratureValidationScreenState extends State<LiteratureValidationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CrisprProvider>().loadLiteratureCases();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CrisprProvider>();
    final result = prov.literatureValidation;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Literature Validation')),
      body: prov.isLoading && result == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(kPadMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compare predictions against published CRISPR outcomes.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: kPadMd),
                  if (prov.literatureCases.isEmpty)
                    const Text('No validation cases loaded.')
                  else
                    ...prov.literatureCases.map(
                      (c) => Card(
                        margin: const EdgeInsets.only(bottom: kPadSm),
                        child: ListTile(
                          title: Text(c.title,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(c.description),
                          trailing: const Icon(Icons.science_outlined),
                          onTap: () => prov.runLiteratureValidation(c.id),
                        ),
                      ),
                    ),
                  if (result != null) ...[
                    const SizedBox(height: kPadLg),
                    Card(
                      color: cs.primaryContainer.withAlpha(120),
                      child: Padding(
                        padding: const EdgeInsets.all(kPadMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(result.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text(
                              'Validation score: ${result.validationScorePercent.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: result.validationScorePercent / 100,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: kPadMd),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(kPadMd),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(1.5),
                            2: FlexColumnWidth(1.5),
                            3: FixedColumnWidth(36),
                          },
                          children: [
                            const TableRow(
                              children: [
                                Text('Parameter',
                                    style: TextStyle(fontWeight: FontWeight.w800)),
                                Text('Literature',
                                    style: TextStyle(fontWeight: FontWeight.w800)),
                                Text('App',
                                    style: TextStyle(fontWeight: FontWeight.w800)),
                                SizedBox(),
                              ],
                            ),
                            ...result.comparisonRows.map(
                              (r) => TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(r.parameter),
                                  ),
                                  Text('${r.literature}'),
                                  Text('${r.application}'),
                                  Icon(
                                    r.match ? Icons.check_circle : Icons.cancel,
                                    color: r.match ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: kPadMd),
                    Text('Supporting studies',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: kPadSm),
                    ...result.supportingStudies.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(s, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

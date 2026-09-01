// User Guide Screen – Interactive step-by-step tutorial, Cas system matrix, and best practices.

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/app_background.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final onPanel = isDark ? Colors.white : cs.onSurface;

    final steps = [
      {
        'step': '1',
        'title': 'Provide or Select Target DNA Sequence',
        'icon': Icons.input_rounded,
        'badge': 'Step 1: Sequence Entry',
        'desc':
            'Choose how you want to provide your wild-type genomic sequence:\n\n'
            '• Manual Sequence Paste: Enter raw standard IUPAC DNA nucleotides (A, T, C, G).\n'
            '• FASTA File Upload: Upload standard FASTA formatted files.\n'
            '• NCBI Accession Lookup: Enter an NCBI Accession number (e.g. NM_000518) to auto-fetch sequence.\n'
            '• Clinical Presets: Select from pre-loaded clinical genes such as HBB (Sickle Cell), BRCA1, or CFTR.',
        'tip': 'Tip: Sequences must be at least 23 bp long to allow space for a 20 bp guide + 3 bp PAM site.',
      },
      {
        'step': '2',
        'title': 'Scan for PAM Motifs & Select sgRNA',
        'icon': Icons.radar_rounded,
        'badge': 'Step 2: PAM Scanning',
        'desc':
            'Choose your Cas endonuclease system and scan the sequence for viable PAM recognition motifs:\n\n'
            '• SpCas9 (Streptococcus pyogenes): Recognizes 5\'-NGG-3\' motifs.\n'
            '• SaCas9 (Staphylococcus aureus): Recognizes 5\'-NNGRRT-3\' motifs for compact AAV delivery.\n'
            '• Cas12a / Cpf1: Recognizes 5\'-TTTV-3\' T-rich PAM motifs for AT-rich genomic regions.\n\n'
            'Inspect GC content (ideal 40–60%), predicted guide efficiency, and off-target risk ratings.',
        'tip': 'Tip: Avoid guides with poly-T stretches (TTTT) as they cause premature RNA polymerase III termination.',
      },
      {
        'step': '3',
        'title': 'Off-Target Analysis & Cleavage Simulation',
        'icon': Icons.content_cut_rounded,
        'badge': 'Step 3: Cleavage Simulation',
        'desc':
            'Once you choose a target PAM site, visualize the double-strand break (DSB) cleavage point:\n\n'
            '• For Cas9: Blunt cut introduced 3 base pairs upstream of the PAM site.\n'
            '• For Cas12a: Staggered cuts generating 5-nucleotide 5\' cohesive overhangs.\n\n'
            'Review potential off-target alignment hits and genomic risk factors.',
        'tip': 'Tip: Mismatches in the proximal "seed region" (1–8 bp adjacent to PAM) drastically reduce cleavage.',
      },
      {
        'step': '4',
        'title': 'Choose Cellular DNA Repair Mechanism',
        'icon': Icons.build_circle_rounded,
        'badge': 'Step 4: DNA Repair',
        'desc':
            'Select how the host cell repairs the double-strand break:\n\n'
            '• Non-Homologous End Joining (NHEJ): Error-prone ligation that introduces random small deletions '
            '(1–10 bp) or insertions (1–3 bp), typically used for gene knockout.\n'
            '• Homology-Directed Repair (HDR): High-fidelity recombination using a custom donor template '
            'to insert specific mutations, correct single-nucleotide variants, or knock in new sequences.',
        'tip': 'Tip: When using HDR, ensure your donor template includes homologous flanking arms of 30–50 bp.',
      },
      {
        'step': '5',
        'title': 'Mutation Impact & Translation Analysis',
        'icon': Icons.biotech_rounded,
        'badge': 'Step 5: Impact Analysis',
        'desc':
            'The engine simulates the biological consequence of the repair:\n\n'
            '• DNA → mRNA Transcription: Translates the repaired strand into mRNA codons.\n'
            '• Protein Translation: Translates codons into an amino acid polypeptide chain.\n'
            '• Frameshift Detection: Identifies whether non-triplet indels altered downstream reading frames.\n'
            '• Premature Stop Codon Detection: Flags early termination codons (*) resulting in truncated proteins.\n'
            '• CRISPR Safety Score: Generates an aggregate score (0–100) evaluating editing fidelity.',
        'tip': 'Tip: Frameshifts near the N-terminus often trigger complete nonsense-mediated decay (NMD).',
      },
      {
        'step': '6',
        'title': 'Export Reports & Literature Validation',
        'icon': Icons.download_done_rounded,
        'badge': 'Step 6: Export & Validation',
        'desc':
            'Export your findings for lab notebooks, grant proposals, or publications:\n\n'
            '• PDF Scientific Report: Formatted multi-page document with clinical metrics & sequence alignment.\n'
            '• Excel Spreadsheet (.xlsx): Multi-sheet workbook with summary, protein, and mRNA tabs.\n'
            '• CSV / FASTA Formats: Raw data for downstream bioinformatics tools.\n'
            '• Literature Validation: Cross-reference findings with real published peer-reviewed CRISPR trials.',
        'tip': 'Tip: All simulation records are automatically saved to your cloud history when enabled.',
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: kDarkTeal,
        foregroundColor: kAccentTeal,
        elevation: 0,
        title: const Text('User Guide'),
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kPadMd, kPadMd + kToolbarHeight, kPadMd, kPadLg),
          children: [
            // Hero Guide Banner
            Container(
              padding: const EdgeInsets.all(kPadMd),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kDarkTeal.withAlpha(240), kDarkTeal],
                ),
                borderRadius: BorderRadius.circular(kRadius),
                border: Border.all(color: kAccentTeal.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_stories_rounded, color: kAccentTeal, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'CRISPR-Sim Interactive Guide',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Master in silico gene editing workflows from sequence intake to protein translation and clinical safety analysis.',
                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kPadLg),

            // Step by step guide cards
            ...steps.map((s) {
              return Padding(
                padding: const EdgeInsets.only(bottom: kPadMd),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(kPadMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: kAccentTeal,
                              child: Text(
                                s['step'] as String,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                s['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: onPanel,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kAccentTeal.withAlpha(35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            s['badge'] as String,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kAccentTeal),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          s['desc'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: onPanel.withAlpha(220),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s['tip'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: onPanel.withAlpha(200),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: kPadMd),

            // Cas Endonuclease Comparison Table
            Row(
              children: [
                const Icon(Icons.grid_view_rounded, color: kAccentTeal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Cas Endonuclease Reference Matrix',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onPanel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kPadSm),
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(kPadMd),
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStatePropertyAll(kAccentTeal.withAlpha(40)),
                  columns: const [
                    DataColumn(label: Text('Cas System', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('PAM Motif', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Guide Length', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Cleavage Cut Pattern', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    DataRow(cells: [
                      const DataCell(Text('SpCas9', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataCell(Text('5\'-NGG-3\' (3\' side)')),
                      const DataCell(Text('20 nt')),
                      DataCell(Text('Blunt cut (-3 bp from PAM)', style: TextStyle(color: onPanel))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('SaCas9', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataCell(Text('5\'-NNGRRT-3\' (3\' side)')),
                      const DataCell(Text('21–24 nt')),
                      DataCell(Text('Blunt cut (-3 bp from PAM)', style: TextStyle(color: onPanel))),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text('Cas12a (Cpf1)', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataCell(Text('5\'-TTTV-3\' (5\' side)')),
                      const DataCell(Text('20–24 nt')),
                      DataCell(Text('Staggered 5-nt overhang (18–23 bp downstream)', style: TextStyle(color: onPanel))),
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: kPadLg),
          ],
        ),
      ),
    );
  }
}

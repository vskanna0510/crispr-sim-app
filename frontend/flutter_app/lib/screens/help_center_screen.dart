// Help Center Screen – FAQ, Glossary, Troubleshooting, and Support.

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/app_background.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _faqs = [
    {
      'category': 'Basics',
      'question': 'What is CRISPR-Cas9 and how does this simulator work?',
      'answer':
          'CRISPR-Cas9 is an RNA-guided gene-editing technology. In this simulator, '
          'you provide a target DNA sequence, select a guide RNA matching a PAM motif, '
          'and simulate DNA double-strand breaks followed by cellular repair (NHEJ or HDR). '
          'The engine translates edited sequences to predict functional impact on mRNA and proteins.',
    },
    {
      'category': 'PAM & Guides',
      'question': 'What is a PAM site and why is it essential?',
      'answer':
          'PAM (Protospacer Adjacent Motif) is a short DNA sequence immediately following the target DNA sequence. '
          'The Cas endonuclease requires a PAM site to bind and initiate cleavage:\n\n'
          '• SpCas9: 5\'-NGG-3\' (Cuts 3 bp upstream)\n'
          '• SaCas9: 5\'-NNGRRT-3\' (Cuts 3 bp upstream)\n'
          '• Cas12a (Cpf1): 5\'-TTTV-3\' (Staggered cut 18-23 bp downstream)',
    },
    {
      'category': 'Repair & Edits',
      'question': 'What is the difference between NHEJ and HDR repair?',
      'answer':
          '• Non-Homologous End Joining (NHEJ): An error-prone repair mechanism that joins broken DNA ends, '
          'frequently introducing small insertions or deletions (indels) that cause frameshifts and gene knockouts.\n\n'
          '• Homology-Directed Repair (HDR): A high-fidelity template-dependent repair pathway that uses a donor DNA '
          'template to introduce precise sequence modifications or gene knock-ins.',
    },
    {
      'category': 'Safety & Off-Target',
      'question': 'How is the CRISPR Safety Score calculated?',
      'answer':
          'The CRISPR Safety Score (0–100) is an aggregate score evaluating:\n'
          '1. GC Content (40–60% optimal for stability and specificity)\n'
          '2. Off-Target Risk (mismatch counts across human genome reference)\n'
          '3. PAM Quality & Target Specificity\n'
          '4. Poly-T Absence (avoids premature termination in transcription)\n\n'
          'Scores ≥ 70 are High Confidence; 50–69 are Moderate; < 50 indicate High Risk.',
    },
    {
      'category': 'Repair & Edits',
      'question': 'What causes a Frameshift Mutation?',
      'answer':
          'A frameshift mutation occurs when an insertion or deletion (indel) size is NOT a multiple of 3. '
          'Because codons are read in triplets, shifting the frame alters all downstream amino acids and '
          'frequently introduces premature stop codons (*), resulting in a truncated, non-functional protein.',
    },
    {
      'category': 'Exports & Reports',
      'question': 'How can I download or export my simulation analysis?',
      'answer':
          'On the Analysis Results screen, scroll to the "Download & Export Formats" section. '
          'You can generate and download:\n'
          '• PDF Report: Full styled scientific analysis document\n'
          '• Excel (.xlsx): Multi-sheet workbook with sequence matrices\n'
          '• CSV File: Machine-readable metric tables\n'
          '• FASTA File: Bioinformatic sequence format for BLAST/benchmarking',
    },
    {
      'category': 'Basics',
      'question': 'Which preset genes are available for testing?',
      'answer':
          'The simulator includes clinically validated preset genes:\n'
          '• HBB (Sickle Cell Disease / Beta-Thalassemia)\n'
          '• BRCA1 (Hereditary Breast and Ovarian Cancer)\n'
          '• CFTR (Cystic Fibrosis delta-F508)\n'
          '• PCSK9 (Cardiovascular / Cholesterol reduction)',
    },
  ];

  final List<Map<String, String>> _glossary = [
    {'term': 'Cas9', 'definition': 'CRISPR associated protein 9; an RNA-guided endonuclease enzyme.'},
    {'term': 'sgRNA', 'definition': 'Single guide RNA; hybrid RNA targeting the specific genomic locus.'},
    {'term': 'PAM', 'definition': 'Protospacer Adjacent Motif; essential recognition sequence for Cas binding.'},
    {'term': 'Indel', 'definition': 'Insertion or Deletion of nucleotides in genomic DNA.'},
    {'term': 'NHEJ', 'definition': 'Non-Homologous End Joining; primary double-strand break repair mechanism.'},
    {'term': 'HDR', 'definition': 'Homology-Directed Repair; precise template-mediated DNA repair pathway.'},
    {'term': 'Frameshift', 'definition': 'Disruption of the triplet codon reading frame caused by non-3n indels.'},
    {'term': 'Stop Codon', 'definition': 'Codon (UAA, UAG, UGA) that signals termination of protein translation.'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredFaqs {
    return _faqs.where((faq) {
      final matchesCat = _selectedCategory == 'All' || faq['category'] == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          faq['question']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq['answer']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final onPanel = isDark ? Colors.white : cs.onSurface;

    final categories = ['All', 'Basics', 'PAM & Guides', 'Repair & Edits', 'Safety & Off-Target', 'Exports & Reports'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: kDarkTeal,
        foregroundColor: kAccentTeal,
        elevation: 0,
        title: const Text('Help Center'),
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kPadMd, kPadMd + kToolbarHeight, kPadMd, kPadLg),
          children: [
            // Search Header Box
            Container(
              padding: const EdgeInsets.all(kPadMd),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kDarkTeal.withAlpha(220), kDarkTeal],
                ),
                borderRadius: BorderRadius.circular(kRadius),
                border: Border.all(color: kAccentTeal.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.help_center_rounded, color: kAccentTeal, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'How can we help you?',
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
                    'Search FAQs, explore the CRISPR glossary, or learn how to use the simulator.',
                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
                  ),
                  const SizedBox(height: kPadMd),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search questions, PAM, HDR, frameshifts...',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(140)),
                      prefixIcon: const Icon(Icons.search_rounded, color: kAccentTeal),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: Colors.white70),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.black.withAlpha(80),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: kAccentTeal.withAlpha(100)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: kAccentTeal, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kPadMd),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSel,
                      label: Text(cat),
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black87 : onPanel,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      selectedColor: kAccentTeal,
                      backgroundColor: onPanel.withAlpha(15),
                      onSelected: (val) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: kPadMd),

            // FAQ Accordion List
            Row(
              children: [
                const Icon(Icons.quiz_rounded, color: kAccentTeal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Frequently Asked Questions (${_filteredFaqs.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onPanel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kPadSm),
            if (_filteredFaqs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'No articles match your search. Try different keywords.',
                    style: TextStyle(color: onPanel.withAlpha(160)),
                  ),
                ),
              )
            else
              ..._filteredFaqs.map(
                (faq) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: kAccentTeal.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.help_outline_rounded, color: kAccentTeal, size: 18),
                      ),
                      title: Text(
                        faq['question']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: onPanel,
                        ),
                      ),
                      subtitle: Text(
                        faq['category']!,
                        style: const TextStyle(fontSize: 11, color: kAccentTeal),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SelectableText(
                              faq['answer']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: onPanel.withAlpha(220),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: kPadLg),

            // CRISPR Terminology Glossary
            Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: kAccentTeal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'CRISPR Genomics Glossary',
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
              child: Padding(
                padding: const EdgeInsets.all(kPadMd),
                child: Column(
                  children: _glossary.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: kAccentTeal.withAlpha(40),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item['term']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: kAccentTeal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['definition']!,
                              style: TextStyle(fontSize: 13, color: onPanel.withAlpha(200)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: kPadLg),

            // Contact & Feedback Card
            Card(
              color: kDarkTeal.withAlpha(150),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadius),
                side: BorderSide(color: kAccentTeal.withAlpha(80)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(kPadMd),
                child: Row(
                  children: [
                    const Icon(Icons.support_agent_rounded, color: kAccentTeal, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Still have questions?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Contact the CRISPR-Sim bioinformatics team for assistance or bug reports.',
                            style: TextStyle(color: Colors.white.withAlpha(190), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.teal,
                            content: Text('Support contact: vskanna2003@gmail.com'),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(backgroundColor: kAccentTeal, foregroundColor: Colors.black87),
                      child: const Text('Contact'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

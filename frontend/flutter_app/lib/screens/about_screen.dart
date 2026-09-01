// About the App Screen – App Identity, Mission, Core Features, Tech Stack, and Developer Credits.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_background.dart';
import '../widgets/dna_sequencing_helix.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final onPanel = isDark ? Colors.white : cs.onSurface;
    final auth = context.watch<AuthProvider>();

    final features = [
      {
        'title': 'Endonuclease Precision Engine',
        'desc': 'Simulates SpCas9 (NGG), SaCas9 (NNGRRT), and Cas12a/Cpf1 (TTTV) cleavage mechanisms with precise nucleotide coordinate mapping.',
        'icon': Icons.precision_manufacturing_rounded,
      },
      {
        'title': 'Dual DNA Repair Modeling',
        'desc': 'Accurately models error-prone Non-Homologous End Joining (NHEJ) indels and high-fidelity Homology-Directed Repair (HDR) donor recombination.',
        'icon': Icons.alt_route_rounded,
      },
      {
        'title': 'Central Dogma Translation',
        'desc': 'Transcribes edited DNA into mRNA codons and translates into polypeptide amino acid chains to identify frameshifts and premature stop codons (*).',
        'icon': Icons.translate_rounded,
      },
      {
        'title': 'CRISPR Safety Score (0–100)',
        'desc': 'Calculates aggregate editing safety based on GC content (40–60%), off-target mismatch penalties, PAM binding kinetics, and poly-T absence.',
        'icon': Icons.security_rounded,
      },
      {
        'title': 'Multi-Format Enterprise Exports',
        'desc': 'Generates publication-ready PDF reports, multi-sheet Excel (.xlsx) workbooks, FASTA files, and CSV data matrices directly from the live API.',
        'icon': Icons.file_download_rounded,
      },
      {
        'title': 'PubMed Literature Validation',
        'desc': 'Cross-references simulated mutations against real peer-reviewed clinical studies and trial benchmarks.',
        'icon': Icons.menu_book_rounded,
      },
    ];

    final techStack = [
      {'name': 'Flutter & Dart', 'role': 'Cross-platform UI (Web, Android, iOS, Desktop)'},
      {'name': 'FastAPI & Python 3.11', 'role': 'Asynchronous High-Performance Bioinformatic REST API'},
      {'name': 'PostgreSQL & SQLite', 'role': 'Relational Persistence with SQLAlchemy ORM'},
      {'name': 'ReportLab & OpenPyXL', 'role': 'Scientific PDF & Multi-Sheet Excel Generation'},
      {'name': 'Google Identity & JWT', 'role': 'OAuth 2.0 Security, BCrypt Hashes & Token Management'},
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: kDarkTeal,
        foregroundColor: kAccentTeal,
        elevation: 0,
        title: const Text('About CRISPR-Sim'),
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kPadMd, kPadMd + kToolbarHeight, kPadMd, kPadLg),
          children: [
            // Hero Header Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: kPadMd),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kDarkTeal.withAlpha(240), const Color(0xFF0F2E2E)],
                ),
                borderRadius: BorderRadius.circular(kRadius),
                border: Border.all(color: kAccentTeal.withAlpha(90)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(90),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const DnaSequencingHelix(height: 70),
                  const SizedBox(height: 12),
                  const Text(
                    'CRISPR-Sim',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Interactive Molecular Gene-Editing Simulator',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kAccentTeal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _Badge('v2.4.0', Icons.verified_rounded),
                      _Badge('Build 2026.09', Icons.build_circle_outlined),
                      _Badge('Academic Edition', Icons.school_rounded),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: kPadLg),

            // Mission Statement
            Card(
              child: Padding(
                padding: const EdgeInsets.all(kPadMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flag_rounded, color: kAccentTeal, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Our Mission',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onPanel,
                              ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Text(
                      'CRISPR-Sim is built to empower researchers, educators, and bioinformatics students '
                      'with a real-time, in silico laboratory environment. '
                      'By bridging theoretical genomics with predictive algorithmic modeling, '
                      'the simulator delivers deep insights into PAM recognition, double-strand break repair kinetics, '
                      'and codon reading frame disruptions.',
                      style: TextStyle(
                        fontSize: 13,
                        color: onPanel.withAlpha(220),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: kPadLg),

            // Key Capabilities Grid
            Row(
              children: [
                const Icon(Icons.star_rounded, color: kAccentTeal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Core Scientific Capabilities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onPanel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kPadSm),
            ...features.map((f) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(kPadMd),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kAccentTeal.withAlpha(35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(f['icon'] as IconData, color: kAccentTeal, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: onPanel,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                f['desc'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: onPanel.withAlpha(180),
                                  height: 1.4,
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

            const SizedBox(height: kPadLg),

            // Technology Stack
            Row(
              children: [
                const Icon(Icons.code_rounded, color: kAccentTeal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Technology & Architecture',
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
                  children: techStack.map((tech) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: kAccentTeal, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tech['name']!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: onPanel,
                                  ),
                                ),
                                Text(
                                  tech['role']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: onPanel.withAlpha(160),
                                  ),
                                ),
                              ],
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

            // System Status Card
            Card(
              color: isDark ? const Color(0xFF132A2A) : const Color(0xFFE6FFFA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadius),
                side: BorderSide(color: kAccentTeal.withAlpha(120)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(kPadMd),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Live API Service: Connected',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF047857),
                            ),
                          ),
                          Text(
                            'Target Endpoint: ${auth.api.baseUrl}',
                            style: TextStyle(
                              fontSize: 11,
                              color: onPanel.withAlpha(160),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: kPadLg),

            // Developer & Lab Credits
            Card(
              child: Padding(
                padding: const EdgeInsets.all(kPadMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_rounded, color: kAccentTeal, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Credits & Attribution',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onPanel,
                              ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: kDarkTeal,
                        child: const Icon(Icons.person_rounded, color: kAccentTeal),
                      ),
                      title: Text(
                        'Sugumaran & CRISPR-Sim Team',
                        style: TextStyle(fontWeight: FontWeight.bold, color: onPanel),
                      ),
                      subtitle: Text(
                        'Lead Developer & Computational Biology Lab\nContact: vskanna2003@gmail.com',
                        style: TextStyle(fontSize: 12, color: onPanel.withAlpha(180)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: kPadMd),

            // Legal & Disclaimer
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'CRISPR-Sim is designed for educational, research, and predictive simulation purposes. '
                  'Laboratory verification is required prior to in vivo or clinical application.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: onPanel.withAlpha(130),
                    height: 1.4,
                  ),
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

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Badge(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccentTeal.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: kAccentTeal),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

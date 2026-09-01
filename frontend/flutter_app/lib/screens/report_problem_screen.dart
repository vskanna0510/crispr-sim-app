// Report a Problem Screen – Bug reporting, simulation error logs, and issue tracking.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_background.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _stepsController = TextEditingController();

  String _category = 'Bug Report';
  String _severity = 'Medium';
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _myTickets = [];
  bool _isLoadingTickets = false;

  final List<String> _categories = [
    'Bug Report',
    'Simulation Error',
    'UI / Visual Glitch',
    'Export & Download Issue',
    'Feature Request',
    'Other Problem',
  ];

  final List<String> _severities = [
    'Low (Minor cosmetic)',
    'Medium (Standard issue)',
    'High (Feature broken)',
    'Critical (App crash/data)',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserTickets();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserTickets() async {
    setState(() => _isLoadingTickets = true);
    try {
      final auth = context.read<AuthProvider>();
      final tickets = await auth.api.fetchUserIssues();
      if (mounted) {
        setState(() {
          _myTickets = tickets;
          _isLoadingTickets = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingTickets = false);
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();
    final scaffold = ScaffoldMessenger.of(context);

    try {
      final result = await auth.api.reportIssue(
        category: _category.toLowerCase().replaceAll(' ', '_'),
        severity: _severity.split(' ').first.toLowerCase(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        stepsToReproduce: _stepsController.text.trim().isEmpty ? null : _stepsController.text.trim(),
        systemInfo: {
          'app_version': 'v2.4.0',
          'platform': 'Web/Desktop/Mobile',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      );

      final ticketId = result['ticket_id'] ?? 'CRISPR-TKT-PENDING';

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      _titleController.clear();
      _descController.clear();
      _stepsController.clear();
      _loadUserTickets();

      _showSuccessDialog(ticketId);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      scaffold.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade800,
          content: Text('Failed to submit report: $e'),
        ),
      );
    }
  }

  void _showSuccessDialog(String ticketId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 26),
            SizedBox(width: 8),
            Text('Report Submitted'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thank you! Your issue report has been logged with our bioinformatics team.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: kAccentTeal.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: kAccentTeal.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Text('Ticket ID: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  SelectableText(
                    ticketId,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: kAccentTeal),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: kAccentTeal, foregroundColor: Colors.black87),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final onPanel = isDark ? Colors.white : cs.onSurface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: kDarkTeal,
        foregroundColor: kAccentTeal,
        elevation: 0,
        title: const Text('Report a Problem'),
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kPadMd, kPadMd + kToolbarHeight, kPadMd, kPadLg),
          children: [
            // Header Banner
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
                      Icon(Icons.bug_report_rounded, color: kAccentTeal, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Submit Bug or Simulation Issue',
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
                    'Help us improve CRISPR-Sim by reporting calculation discrepancies, UI glitches, or feature suggestions.',
                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kPadLg),

            // Form Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(kPadMd),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Problem Details',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: onPanel,
                            ),
                      ),
                      const Divider(height: 16),

                      // Category Dropdown
                      Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: onPanel)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _category,
                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        style: TextStyle(color: onPanel, fontSize: 14),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: onPanel.withAlpha(12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                      const SizedBox(height: kPadMd),

                      // Severity Level
                      Text('Severity Level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: onPanel)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _severity,
                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        style: TextStyle(color: onPanel, fontSize: 14),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: onPanel.withAlpha(12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: _severities.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => _severity = v!),
                      ),
                      const SizedBox(height: kPadMd),

                      // Issue Title
                      Text('Issue Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: onPanel)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: onPanel),
                        decoration: InputDecoration(
                          hintText: 'e.g., Cas12a staggered cut position misaligned',
                          hintStyle: TextStyle(color: onPanel.withAlpha(120)),
                          filled: true,
                          fillColor: onPanel.withAlpha(12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (v) => (v == null || v.trim().length < 3) ? 'Please enter a descriptive title.' : null,
                      ),
                      const SizedBox(height: kPadMd),

                      // Detailed Description
                      Text('Detailed Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: onPanel)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _descController,
                        maxLines: 4,
                        style: TextStyle(color: onPanel),
                        decoration: InputDecoration(
                          hintText: 'Describe what happened, error messages, and what you expected...',
                          hintStyle: TextStyle(color: onPanel.withAlpha(120)),
                          filled: true,
                          fillColor: onPanel.withAlpha(12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (v) => (v == null || v.trim().length < 5) ? 'Please provide detailed description.' : null,
                      ),
                      const SizedBox(height: kPadMd),

                      // Steps to Reproduce
                      Text('Steps to Reproduce (Optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: onPanel)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _stepsController,
                        maxLines: 2,
                        style: TextStyle(color: onPanel),
                        decoration: InputDecoration(
                          hintText: '1. Paste sequence... 2. Select PAM... 3. Click simulate',
                          hintStyle: TextStyle(color: onPanel.withAlpha(120)),
                          filled: true,
                          fillColor: onPanel.withAlpha(12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: kPadLg),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: _isSubmitting ? null : _submitReport,
                          icon: _isSubmitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(_isSubmitting ? 'Submitting Report...' : 'Submit Problem Report'),
                          style: FilledButton.styleFrom(
                            backgroundColor: kAccentTeal,
                            foregroundColor: Colors.black87,
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: kPadLg),

            // Previous Submitted Tickets Section
            if (_myTickets.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.history_rounded, color: kAccentTeal, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Your Submitted Tickets (${_myTickets.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: onPanel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kPadSm),
              ..._myTickets.map((t) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kAccentTeal.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.confirmation_number_outlined, color: kAccentTeal, size: 20),
                      ),
                      title: Text(
                        t['title'] ?? 'Issue Report',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: onPanel),
                      ),
                      subtitle: Text(
                        '${t['ticket_id']} • ${t['severity'].toString().toUpperCase()} • ${t['created_at'].toString().split('T').first}',
                        style: TextStyle(fontSize: 11, color: onPanel.withAlpha(160)),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.teal.withAlpha(40),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.teal.withAlpha(120)),
                        ),
                        child: Text(
                          t['status']?.toString().toUpperCase() ?? 'OPEN',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kAccentTeal),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

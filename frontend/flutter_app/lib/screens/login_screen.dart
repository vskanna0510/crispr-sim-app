import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_background.dart';
import '../widgets/dna_sequencing_helix.dart';
import '../widgets/google_sign_in_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.login(email: _email.text.trim(), password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cs = Theme.of(context).colorScheme;
    final onPanel = cs.brightness == Brightness.dark ? Colors.white : cs.onSurface;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kPadLg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 100,
                      child: DnaSequencingHelix(height: 100),
                    ),
                    const SizedBox(height: kPadMd),
                    Text(
                      'CRISPR-Sim',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: kAccentTeal,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: kPadSm),
                    Text(
                      'Interactive gene-editing simulator',
                      style: TextStyle(color: onPanel.withAlpha(180)),
                    ),
                    const SizedBox(height: kPadLg),
                    AppPanel(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Sign in',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: onPanel,
                                  ),
                            ),
                            const SizedBox(height: kPadSm),
                            Text(
                              'Save simulations and sync with the live database.',
                              style: TextStyle(color: onPanel.withAlpha(200), fontSize: 13),
                            ),
                            const SizedBox(height: kPadLg),
                            const GoogleSignInButton(text: 'Sign in with Google'),
                            const SizedBox(height: kPadMd),
                            Row(
                              children: [
                                Expanded(child: Divider(color: onPanel.withAlpha(50))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'or sign in with email',
                                    style: TextStyle(fontSize: 12, color: onPanel.withAlpha(150)),
                                  ),
                                ),
                                Expanded(child: Divider(color: onPanel.withAlpha(50))),
                              ],
                            ),
                            const SizedBox(height: kPadMd),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: onPanel),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined, color: kAccentTeal),
                                labelStyle: TextStyle(color: onPanel.withAlpha(180)),
                              ),
                              validator: (v) =>
                                  v != null && v.contains('@') ? null : 'Enter a valid email',
                            ),
                            const SizedBox(height: kPadMd),
                            TextFormField(
                              controller: _password,
                              obscureText: true,
                              style: TextStyle(color: onPanel),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline_rounded, color: kAccentTeal),
                                labelStyle: TextStyle(color: onPanel.withAlpha(180)),
                              ),
                              validator: (v) =>
                                  v != null && v.length >= 8 ? null : 'Minimum 8 characters',
                            ),
                            if (auth.error != null) ...[
                              const SizedBox(height: kPadMd),
                              Text(auth.error!, style: TextStyle(color: cs.error)),
                            ],
                            const SizedBox(height: kPadLg),
                            FilledButton(
                              onPressed: auth.isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: kAccentTeal,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Sign in', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              ),
                              child: Text(
                                'Create account',
                                style: TextStyle(color: kAccentTeal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

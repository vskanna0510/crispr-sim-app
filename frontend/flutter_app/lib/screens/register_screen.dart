import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_background.dart';
import '../widgets/google_sign_in_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      email: _email.text.trim(),
      password: _password.text,
      fullName: _name.text.trim().isEmpty ? null : _name.text.trim(),
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cs = Theme.of(context).colorScheme;
    final onPanel = cs.brightness == Brightness.dark ? Colors.white : cs.onSurface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kAccentTeal,
        title: const Text('Create account'),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kPadLg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: AppPanel(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Join CRISPR-Sim',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onPanel,
                              ),
                        ),
                        const SizedBox(height: kPadSm),
                        Text(
                          'Create an account to save scans and simulations.',
                          style: TextStyle(color: onPanel.withAlpha(200), fontSize: 13),
                        ),
                        const SizedBox(height: kPadLg),
                        GoogleSignInButton(
                          text: 'Sign up with Google',
                          onSuccess: () {
                            if (mounted) Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: kPadMd),
                        Row(
                          children: [
                            Expanded(child: Divider(color: onPanel.withAlpha(50))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or sign up with email',
                                style: TextStyle(fontSize: 12, color: onPanel.withAlpha(150)),
                              ),
                            ),
                            Expanded(child: Divider(color: onPanel.withAlpha(50))),
                          ],
                        ),
                        const SizedBox(height: kPadMd),
                        TextFormField(
                          controller: _name,
                          style: TextStyle(color: onPanel),
                          decoration: InputDecoration(
                            labelText: 'Full name (optional)',
                            prefixIcon: Icon(Icons.badge_outlined, color: kAccentTeal),
                            labelStyle: TextStyle(color: onPanel.withAlpha(180)),
                          ),
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
                            labelText: 'Password (min 8 chars)',
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
                              : const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                          child: Text('Already have an account? Sign in', style: TextStyle(color: kAccentTeal)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

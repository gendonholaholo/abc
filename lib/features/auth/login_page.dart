import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'demo@company.com');
  final _passwordCtrl = TextEditingController(text: 'password');

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    ref.listen(sessionProvider, (previous, next) {
      if (next.status == SessionStatus.failure && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('HRIS Attendance',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          value != null && value.contains('@') ? null : 'Email tidak valid',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (value) =>
                          value != null && value.length >= 6 ? null : 'Minimal 6 karakter',
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: session.status == SessionStatus.loading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              await ref.read(sessionProvider.notifier).login((
                                    email: _emailCtrl.text.trim(),
                                    password: _passwordCtrl.text,
                                  ));
                            },
                      icon: const Icon(Icons.login),
                      label: session.status == SessionStatus.loading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Masuk'),
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

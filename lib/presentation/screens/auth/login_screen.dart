import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/utils.dart';
import 'package:nvidiaapp/core/app_routes.dart';
import 'package:nvidiaapp/core/di.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;

  @override
  void initState() {
    super.initState();
    authController.clearMessages();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    debugPrint('[AUTH] tombol Masuk ditekan');
    if (!_form.currentState!.validate()) {
      debugPrint('[AUTH] form tidak lolos validasi');
      return;
    }
    final ok = await authController.login(_email.text, _password.text);
    if (ok && mounted) {
      debugPrint('[AUTH] pindah ke ${Routes.home}');
      Get.offAllNamed(Routes.home);
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: authController,
                builder: (context, _) => Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Masuk', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      const Text('Masuk untuk mulai mencatat uang sakumu.'),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Isi email yang valid' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _password,
                        obscureText: _hide,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Kata sandi',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _hide = !_hide),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Isi kata sandi' : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 16),
                      if (authController.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(authController.error!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ),
                      if (authController.info != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(authController.info!),
                        ),
                      FilledButton(
                        onPressed: authController.loading ? null : _submit,
                        child: authController.loading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Masuk'),
                      ),
                      TextButton(
                        onPressed: authController.loading
                            ? null
                            : () => Navigator.of(context).pushNamed(Routes.register),
                        child: const Text('Belum punya akun? Daftar'),
                      ),
                    ],
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

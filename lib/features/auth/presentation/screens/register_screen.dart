import 'package:flutter/material.dart';
import 'package:nvidiaapp/core/di.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
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
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final ok = await authController.register(_name.text, _email.text, _password.text);
    if (!ok || !mounted) return;
    final info = authController.info;
    // Kembali ke layar awal. Kalau sesi sudah ada, AuthGate langsung menampilkan Home.
    Navigator.of(context).popUntil((r) => r.isFirst);
    if (info != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(info)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
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
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Isi namamu' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'Isi email yang valid' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _password,
                        obscureText: _hide,
                        decoration: InputDecoration(
                          labelText: 'Kata sandi (minimal 6 karakter)',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _hide = !_hide),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 16),
                      if (authController.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(authController.error!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ),
                      FilledButton(
                        onPressed: authController.loading ? null : _submit,
                        child: authController.loading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Buat akun'),
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

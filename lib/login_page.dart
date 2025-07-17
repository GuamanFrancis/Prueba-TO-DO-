import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onRegisterTap;
  const LoginPage({super.key, required this.onRegisterTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;

  void _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = await AuthService().signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null && !user.emailVerified) {
        setState(() {
          _error = 'Debes verificar tu correo antes de iniciar sesión.';
        });
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _resendVerification() async {
    try {
      await AuthService().registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      setState(() {
        _error = 'Correo de verificación reenviado. Revisa tu bandeja de entrada.';
      });
    } catch (e) {
      setState(() { _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: const Text('Iniciar sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, color: Colors.deepPurple, size: 48),
                    const SizedBox(height: 12),
                    const Text('Bienvenido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.deepPurple)),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      if (_error!.contains('verificar tu correo'))
                        TextButton(
                          onPressed: _resendVerification,
                          child: const Text('Reenviar correo de verificación'),
                        ),
                    ],
                    const SizedBox(height: 24),
                    _loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: _login,
                              icon: const Icon(Icons.login),
                              label: const Text('Iniciar sesión', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                    TextButton(
                      onPressed: widget.onRegisterTap,
                      child: const Text('¿No tienes cuenta? Regístrate'),
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

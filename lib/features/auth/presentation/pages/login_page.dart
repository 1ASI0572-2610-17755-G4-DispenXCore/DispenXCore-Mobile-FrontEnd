import 'package:dispenxcore_frontend/features/auth/domain/entities/user.dart';
import 'package:dispenxcore_frontend/features/auth/domain/usecases/login_user.dart';
import 'package:dispenxcore_frontend/features/auth/presentation/widgets/text_field.dart';
import 'package:flutter/foundation.dart'; // necesario para kDebugMode
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
 
class LoginPage extends StatefulWidget {
  final LoginUser loginUser;
 
  const LoginPage({super.key, required this.loginUser});
 
  @override
  State<LoginPage> createState() => _LoginPageState();
}
 
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
 
  bool _passwordVisible = false;
  bool _isLoading = false;
 
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
    return null;
  }
 
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
 
  // ============================================================
  // ACCESO RAPIDO — SOLO DESARROLLO
  // Rellena las credenciales del admin del db.json y hace login.
  //
  // ANTES DE PRESENTAR O SUBIR A PRODUCCION:
  //   1. Elimina este método _quickAccess()
  //   2. Elimina el import de 'package:flutter/foundation.dart'
  //   3. Elimina el bloque marcado "BOTON ACCESO RAPIDO" en build()
  // ============================================================
  Future<void> _quickAccess() async {
    _emailController.text = 'admin@gmail.com';
    _passwordController.text = 'admin1234';
    await _login();
  }
  // ============================================================
  // FIN ACCESO RAPIDO
  // ============================================================
 
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
 
    setState(() => _isLoading = true);
 
    try {
      final session = await widget.loginUser.call(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
 
      if (!mounted) return;
 
      // Navega según el role del usuario
      switch (session.user.role) {
        case Role.admin:
          Navigator.pushReplacementNamed(context, '/main');
          break;
        case Role.user:
          Navigator.pushReplacementNamed(context, '/main');
          break;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 20,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                IconTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboard: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                IconTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_outlined,
                  controller: _passwordController,
                  obscureText: true,
                  showVisibilityToggle: true,
                  isPasswordVisible: _passwordVisible,
                  togglePasswordVisibility: () {
                    setState(() => _passwordVisible = !_passwordVisible);
                  },
                  validator: _validatePassword,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      disabledBackgroundColor: const Color(0xFFBDBDBD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Arimo',
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontFamily: 'Arimo',
                    ),
                    children: [
                      TextSpan(
                        text: 'Register',
                        style: const TextStyle(
                          color: Color(0xFF006AFF),
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pushNamed(context, '/register'),
                      ),
                    ],
                  ),
                ),
 
                // ============================================================
                // BOTON ACCESO RAPIDO — SOLO DESARROLLO
                // Solo aparece en debug mode (flutter run).
                // En release build desaparece solo por kDebugMode,
                // pero de igual forma elimínalo antes de presentar.
                //
                // PARA ELIMINAR — borrar desde aquí:
                // ============================================================
                if (kDebugMode) ...[
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading ? null : _quickAccess,
                    child: const Text(
                      'Acceso directo (dev)',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontFamily: 'Arimo',
                      ),
                    ),
                  ),
                ],
                // ============================================================
                // hasta aquí (inclusive este comentario)
                // ============================================================
 
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
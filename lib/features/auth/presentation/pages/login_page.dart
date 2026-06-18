import 'package:dispenxcore_frontend/features/auth/domain/entities/user.dart';
import 'package:dispenxcore_frontend/features/auth/domain/usecases/login_user.dart';
import 'package:dispenxcore_frontend/features/auth/presentation/widgets/text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final LoginUser loginUser;
  const LoginPage({super.key, required this.loginUser});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  static const _teal = Color(0xFF009688);

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email requerido';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Email inválido';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Contraseña requerida';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  // ============================================================
  // ACCESO RAPIDO — SOLO DESARROLLO. Eliminar antes de producción.
  // ============================================================
  Future<void> _quickAccess() async {
    _emailController.text = 'admin@gmail.com';
    _passwordController.text = 'admin1234';
    await _login();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final session = await widget.loginUser.call(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;
      switch (session.user.role) {
        case Role.admin:
        case Role.user:
          Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Imagen / gradiente de cabecera ──────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.42,
            child: _HeaderBackground(),
          ),

          // ── Branding sobre la imagen ─────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DispenXCore',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Icon(Icons.language_rounded, color: Colors.white, size: 22),
                ],
              ),
            ),
          ),

          // ── Card blanca desde abajo ───────────────────────────
          Positioned(
            top: size.height * 0.34,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label
                      const Text(
                        'LOGIN',
                        style: TextStyle(
                          color: _teal,
                          fontSize: 12,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Login Account',
                        style: TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 24,
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enter your personal information to access\nyour dashboard.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontFamily: 'Arimo',
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Email
                      IconTextField(
                        label: 'Email*',
                        hint: 'your@email.com',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboard: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),

                      // Password
                      IconTextField(
                        label: 'Password*',
                        hint: '••••••••',
                        icon: Icons.lock_outlined,
                        controller: _passwordController,
                        obscureText: true,
                        showVisibilityToggle: true,
                        isPasswordVisible: _passwordVisible,
                        togglePasswordVisibility: () =>
                            setState(() => _passwordVisible = !_passwordVisible),
                        validator: _validatePassword,
                      ),

                      // Remember me + Forgot password
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (v) =>
                                  setState(() => _rememberMe = v ?? false),
                              activeColor: _teal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              side: const BorderSide(
                                  color: Color(0xFFD1D5DB), width: 1.5),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Remember me',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontFamily: 'Arimo',
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 13,
                                color: _teal,
                                fontFamily: 'Arimo',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      // Login button — pill style
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _teal,
                            disabledBackgroundColor: const Color(0xFFBDBDBD),
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Arimo',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_forward_rounded,
                                        color: Colors.white, size: 18),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Divider
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: Color(0xFFE5E7EB))),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                                fontFamily: 'Arimo',
                              ),
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: Color(0xFFE5E7EB))),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Don't have account
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                              fontFamily: 'Arimo',
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: const TextStyle(
                                  color: _teal,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () =>
                                      Navigator.pushNamed(context, '/register'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Social buttons
                      Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              label: 'Google',
                              icon: Icons.g_mobiledata_rounded,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SocialButton(
                              label: 'Apple',
                              icon: Icons.apple_rounded,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Footer
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 11,
                              fontFamily: 'Arimo',
                            ),
                            children: [
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()..onTap = () {},
                              ),
                              const TextSpan(text: '  •  '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: const TextStyle(
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()..onTap = () {},
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Dev access
                      if (kDebugMode) ...[
                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFF3F4F6)),
                        Center(
                          child: TextButton(
                            onPressed: _isLoading ? null : _quickAccess,
                            child: const Text(
                              'Acceso directo (dev)',
                              style: TextStyle(
                                color: Color(0xFFD1D5DB),
                                fontSize: 11,
                                fontFamily: 'Arimo',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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

// ── Fondo de cabecera ─────────────────────────────────────────
class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen real
        Image.asset(
          'assets/login_bg.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        // Capa oscura superior para que el texto "DispenXCore" sea legible
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x88000000), Colors.transparent],
            ),
          ),
        ),
        // Degradado blanco inferior para la transición suave a la card
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.white],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Botón de red social ───────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF374151)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

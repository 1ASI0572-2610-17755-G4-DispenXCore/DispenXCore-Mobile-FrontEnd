import 'package:dispenxcore_frontend/features/auth/domain/usecases/register_user.dart';
import 'package:dispenxcore_frontend/features/auth/presentation/widgets/text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final RegisterUser registerUser;
  const RegisterPage({super.key, required this.registerUser});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;
  bool _termsAccepted = false;
  bool _isLoading = false;

  static const _teal = Color(0xFF009688);

  String? _validateRequired(String? v) {
    if (v == null || v.isEmpty) return 'Campo requerido';
    return null;
  }

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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Debes aceptar los términos y condiciones'),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.registerUser.call(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Cuenta creada. Inicia sesión.'),
        backgroundColor: const Color(0xFF009688),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ));
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + language toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Color(0xFF374151)),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LangChip(label: 'EN', selected: true),
                          _LangChip(label: 'ES', selected: false),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // JOIN US label
                const Text(
                  'JOIN US',
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
                  'Create Account',
                  style: TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 24,
                    fontFamily: 'Arimo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter your personal information to get started.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    fontFamily: 'Arimo',
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // First + Last name
                Row(
                  children: [
                    Expanded(
                      child: IconTextField(
                        label: 'First Name*',
                        hint: 'John',
                        icon: Icons.person_outline,
                        controller: _firstNameController,
                        keyboard: TextInputType.name,
                        validator: _validateRequired,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: IconTextField(
                        label: 'Last Name*',
                        hint: 'Doe',
                        icon: Icons.person_outline,
                        controller: _lastNameController,
                        keyboard: TextInputType.name,
                        validator: _validateRequired,
                      ),
                    ),
                  ],
                ),

                IconTextField(
                  label: 'Email*',
                  hint: 'name@example.com',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboard: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),

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

                const SizedBox(height: 14),

                // Terms
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _termsAccepted,
                        onChanged: (v) =>
                            setState(() => _termsAccepted = v ?? false),
                        activeColor: _teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        side: const BorderSide(
                            color: Color(0xFFD1D5DB), width: 1.5),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 13,
                            fontFamily: 'Arimo',
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'I accept the '),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: const TextStyle(
                                color: _teal,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            const TextSpan(text: '\nand privacy policy.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // Register button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Arimo',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Divider
                const Divider(color: Color(0xFFE5E7EB)),

                const SizedBox(height: 16),

                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontFamily: 'Arimo',
                      ),
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: const TextStyle(
                            color: _teal,
                            fontWeight: FontWeight.w700,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap =
                                () => Navigator.pushNamed(context, '/login'),
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
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _LangChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF009688) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'Arimo',
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

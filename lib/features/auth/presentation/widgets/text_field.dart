import 'package:flutter/material.dart';

class IconTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;
  final bool obscureText;
  final bool showVisibilityToggle;
  final bool? isPasswordVisible;
  final VoidCallback? togglePasswordVisibility;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const IconTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.obscureText = false,
    this.showVisibilityToggle = false,
    this.isPasswordVisible,
    this.togglePasswordVisibility,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 13,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            obscureText: obscureText && !(isPasswordVisible ?? false),
            validator: validator,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 15,
              fontFamily: 'Arimo',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 15,
                fontFamily: 'Arimo',
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF009688), width: 1.6),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.6),
              ),
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
              suffixIcon: showVisibilityToggle
                  ? IconButton(
                      icon: Icon(
                        (isPasswordVisible ?? false)
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: togglePasswordVisibility,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget customTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  required IconData? prefixIcon,
  Widget? suffixIcon,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: Color(0xff1e1e1e)),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    ),
  );
}

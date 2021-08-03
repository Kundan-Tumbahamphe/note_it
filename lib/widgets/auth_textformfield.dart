import 'package:flutter/material.dart';

class AuthTextFormField extends StatelessWidget {
  final String label;
  final bool obscure;
  final IconData prefixIconData;
  final IconData suffixIcon;
  final Function suffixIconOnTap;
  final TextInputType type;
  final TextEditingController controller;
  final Function validator;
  final Function onSaved;

  AuthTextFormField({
    @required this.label,
    @required this.obscure,
    @required this.prefixIconData,
    @required this.type,
    @required this.validator,
    @required this.onSaved,
    this.controller,
    this.suffixIcon,
    this.suffixIconOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: Colors.black,
        accentColor: Colors.white,
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        onSaved: onSaved,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          prefixIcon: Icon(prefixIconData),
          suffixIcon: GestureDetector(
            onTap: suffixIconOnTap,
            child: Icon(suffixIcon),
          ),
        ),
        obscureText: obscure,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:tija/constants/app_color.dart';
import 'package:tija/constants/app_theme.dart';

class InputField extends StatefulWidget {
  final bool isReadOnly;
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

  const InputField({
    super.key,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.isReadOnly = false,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          readOnly: widget.isReadOnly,
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: TextStyle(
            fontSize: 14,
            color: theme.primaryText,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: theme.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            filled: false,
            fillColor: theme.inputFilledColor,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    splashRadius: 20,
                    icon: Icon(
                      _obscureText ? Iconsax.eye_slash : Iconsax.eye,
                      color: const Color(0xFFAAAAAA),
                      size: 20,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            // --- key fix: collapse the reserved error line entirely ---
            isDense: true,
            errorStyle: const TextStyle(fontSize: 0, height: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
              // borderSide: const BorderSide(color: Color(0xFFAAAAAA), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              // borderSide: BorderSide.none,
              borderSide: const BorderSide(
                color: Color.fromARGB(68, 170, 170, 170),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColor.defaultSecondaryColor,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:autovitae/utils/colors.dart';
import 'package:autovitae/utils/font.dart';
import 'package:flutter/services.dart';

class TxtffCustom extends StatelessWidget {
  final String label;
  final double screenWidth;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCounter;
  final int maxLength;
  final Function(String)? onChanged;

  const TxtffCustom({
    super.key,
    required this.label,
    required this.screenWidth,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters = const [],
    this.showCounter = true,
    this.maxLength = 100,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: maxLength,
      controller: controller,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      cursorColor: AppColors.white,
      decoration: InputDecoration(
        counterText: showCounter ? null : '',
        labelText: label,
        labelStyle: AppTextStyles.caption,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

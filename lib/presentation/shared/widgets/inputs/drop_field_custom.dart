import 'package:autovitae/core/theme/app_colors.dart';
import 'package:autovitae/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';

class DbffCustom extends StatelessWidget {
  final String label;
  final Color? color;
  final String? value;
  final List<String> items;
  final String? Function(String?)? validator;
  final ValueChanged<String?> onChanged;
  final bool enable;
  const DbffCustom({
    super.key,
    required this.label,
    this.color,
    this.value,
    required this.items,
    this.validator,
    required this.onChanged,
    required this.enable,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      dropdownColor: AppColors.white,
      initialValue: value,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (newValue) {
        onChanged(newValue);
      },
      validator: validator,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          enabled: enable,
          value: item,
          child: Text(item),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: color ?? AppColors.white,
        labelStyle: AppTextStyles.caption,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.background),
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

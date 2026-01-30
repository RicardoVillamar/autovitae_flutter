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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<String>(
      dropdownColor: colorScheme.surfaceContainer,
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
        fillColor: color ?? colorScheme.surfaceContainerLow,
        labelStyle: textTheme.bodySmall,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
    );
  }
}

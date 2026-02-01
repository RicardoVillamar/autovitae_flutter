import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar una fila de información con etiqueta y valor
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Widget? leadingIcon;
  final Widget? trailingWidget;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.labelStyle,
    this.valueStyle,
    this.leadingIcon,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: labelStyle ?? textTheme.bodyMedium,
            ),
          ],
        ),
        trailingWidget ??
            Text(
              value,
              style: valueStyle ??
                  textTheme.bodyLarge?.copyWith(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    color: valueColor,
                  ),
            ),
      ],
    );
  }
}

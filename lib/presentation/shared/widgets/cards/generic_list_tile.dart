import 'package:flutter/material.dart';

class GenericListTile extends StatelessWidget {
  final Widget leadingIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? leadingBackgroundColor;
  final bool isThreeLine;
  final VoidCallback? onTap;

  const GenericListTile({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leadingBackgroundColor,
    this.isThreeLine = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: leadingBackgroundColor?.withValues(alpha: 0.1) ??
                colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: leadingIcon,
        ),
        title: Text(
          title,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(subtitle!, style: textTheme.bodySmall),
              )
            : null,
        trailing: trailing,
        isThreeLine: isThreeLine,
      ),
    );
  }
}

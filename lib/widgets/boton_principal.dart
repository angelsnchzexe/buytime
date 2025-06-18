import 'package:flutter/material.dart';

class BotonPrincipal extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String text;
  final bool enabled;

  const BotonPrincipal({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color borderColor = enabled ? theme.colorScheme.primary : Colors.grey.shade400;
    final Color textColor = enabled ? theme.colorScheme.primary : Colors.grey;
    final Color iconColor = textColor;

    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, color: iconColor),
      label: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: borderColor),
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

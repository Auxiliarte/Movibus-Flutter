import 'package:flutter/material.dart';

class MenuItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool expanded;
  final VoidCallback onTap;

  const MenuItemTile({
    super.key,
    required this.icon,
    required this.title,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(title, style: TextStyle(color: theme.colorScheme.onSurface)),
      trailing: Icon(
        expanded ? Icons.expand_less : Icons.keyboard_arrow_right,
        color: theme.iconTheme.color,
      ),
      onTap: onTap,
    );
  }
}

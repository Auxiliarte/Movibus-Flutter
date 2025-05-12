import 'package:flutter/material.dart';
import 'package:movibus/providers/themeprovider.dart';
import 'package:provider/provider.dart';

class PreferencesSwitches extends StatelessWidget {
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationToggle;

  const PreferencesSwitches({
    super.key,
    required this.notificationsEnabled,
    required this.onNotificationToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode_outlined),
          title: const Text("Modo oscuro"),
          value: isDarkMode,
          onChanged: (val) => themeProvider.toggleTheme(val),
        ),
        SwitchListTile(
          secondary: Icon(
            Icons.notifications_outlined,
            color: theme.iconTheme.color,
          ),
          title: Text(
            "Notificaciones",
            style: TextStyle(color: theme.iconTheme.color),
          ),
          value: notificationsEnabled,
          onChanged: onNotificationToggle,
        ),
      ],
    );
  }
}

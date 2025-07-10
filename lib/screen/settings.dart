import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, bool> expandStates = {
    'informacion': false,
    'contrasena': false,
    'correo': false,
    'mas': true,
    'soporte': false,
    'terminos': false,
  };

  int _currentIndex = 2;
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/routesHistory');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/settings');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  void toggle(String key) {
    setState(() {
      expandStates[key] = !(expandStates[key] ?? false);
    });
  }

  Widget buildOption(
    String title,
    String key,
    ThemeData theme, {
    bool removeIcon = false,
    double fontSize = 18,
  }) {
    final isExpanded = expandStates[key] ?? false;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: isExpanded ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          trailing:
              removeIcon
                  ? null
                  : Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_right,
                    color: textColor,
                  ),
          onTap: () => toggle(key),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Text(
              'Contenido desplegado...',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            // Encabezado
            Container(
              color: theme.secondaryHeaderColor,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: theme.iconTheme.color,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    "Configuración",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48), // Para alinear con el ícono
                ],
              ),
            ),

            // Suscripción Premium
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ), // Margen lateral
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suscripción Premium',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Actualiza para obtener más opciones',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/king.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Configuración de la cuenta",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Quicksand',
                ),
              ),
            ),

            const SizedBox(height: 16),
            buildOption(
              "Información personal",
              "informacion",
              theme,
              fontSize: 17,
            ),
            buildOption("Contraseña", "contrasena", theme, fontSize: 17),
            buildOption("Correo", "correo", theme, fontSize: 17),

            Column(
              children: [
                buildOption("Más", "mas", theme, removeIcon: true),
                if (expandStates['mas'] ?? false) ...[
                  const SizedBox(height: 8),
                  buildOption("Soporte", "soporte", theme, fontSize: 17),
                  buildOption(
                    "Términos y condiciones",
                    "terminos",
                    theme,
                    fontSize: 16,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 32),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/Welcome');
                },
                child: Text(
                  'Finalizar sesión',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

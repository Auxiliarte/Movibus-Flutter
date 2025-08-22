import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
// import 'package:url_launcher/url_launcher.dart'; // Para futuro uso

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, bool> expandStates = {
    'informacion': false,
    'correo': false,
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
    switch (key) {
      case 'informacion':
        Navigator.pushNamed(context, '/EditProfilePersonal');
        break;
      case 'correo':
        Navigator.pushNamed(context, '/EditProfileMail');
        break;
      case 'terminos':
        // Abrir términos y condiciones en navegador
        _launchTermsAndConditions();
        break;
      default:
        setState(() {
          expandStates[key] = !(expandStates[key] ?? false);
        });
    }
  }

  void _launchTermsAndConditions() async {
    const url = 'https://app.moventra.com.mx/terminos-condiciones';
    try {
      // Para Flutter web o plataformas que soporten url_launcher
      // await launchUrl(Uri.parse(url));
      // Por ahora, mostramos un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Abriendo: $url'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      print('Error al abrir URL: $e');
    }
  }

  Widget buildOption(
    String title,
    String key,
    ThemeData theme, {
    bool removeIcon = false,
    double fontSize = 18,
  }) {
    final textColor = theme.textTheme.bodyMedium?.color;

    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing:
          removeIcon
              ? null
              : Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: textColor,
              ),
      onTap: () => toggle(key),
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

            const SizedBox(height: 20),

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
            buildOption("Correo", "correo", theme, fontSize: 17),
            buildOption(
              "Términos y condiciones",
              "terminos",
              theme,
              fontSize: 16,
            ),

            const SizedBox(height: 32),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/Welcome');
                },
                child: Text(
                  'Cerrar sesión',
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

import 'package:flutter/material.dart';
import 'package:movibus/themes/app_colors.dart';
import 'package:movibus/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/themeprovider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool showFavoritos = false;
  bool showEstadisticas = false;
  bool notificationsEnabled = false;

  int _currentIndex = 3;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con fondo morado (usa cardColor)
            Container(
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(color: theme.cardColor),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/Avatars.png'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Juan Pérez",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      "Administrador",
                      style: TextStyle(color: Colors.white60),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text("Editar perfil"),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Título "Biblioteca" sin fondo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Biblioteca",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextDisabled,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Contenedor para la sección de "Biblioteca" (Menú)
            Container(
              color: theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuItem(
                    icon: Icons.favorite_border,
                    title: "Favoritos",
                    expanded: showFavoritos,
                    onTap: () => setState(() => showFavoritos = !showFavoritos),
                  ),
                  if (showFavoritos)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: const [
                          ListTile(
                            title: Text(
                              "Artículo 1",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              "Artículo 2",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildMenuItem(
                    icon: Icons.bar_chart_outlined,
                    title: "Estadísticas",
                    expanded:
                        false, // Ya no es necesario, pero si lo pide el widget, pon false
                    onTap: () => Navigator.pushNamed(context, '/statistics'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Título "Preferencias" sin fondo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Preferencias",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextDisabled,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Contenedor para la sección de "Preferencias" (Switches)
            Container(
              color: theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    onChanged: (val) {
                      setState(() => notificationsEnabled = val);
                    },
                  ),
                ],
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      trailing: Icon(
        expanded ? Icons.expand_less : Icons.expand_more,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTap,
    );
  }
}

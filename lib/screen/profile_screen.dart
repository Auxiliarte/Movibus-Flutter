import 'package:flutter/material.dart';
import 'package:moventra/themes/app_colors.dart';
import 'package:moventra/widgets/custom_bottom_nav_bar.dart';
import 'package:moventra/widgets/profile/menu_item_tile.dart';
import 'package:moventra/widgets/profile/preferences_switches.dart';
import 'package:moventra/widgets/profile/profile_header.dart';
import 'package:moventra/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool showFavoritos = false;
  bool notificationsEnabled = false;
  int _currentIndex = 3;
  final AuthService _authService = AuthService();

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/routesHistory');
        break;
      case 2:
        Navigator.pushNamed(context, '/settings');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/Welcome', 
                  (route) => false
                );
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileHeader(),
            const SizedBox(height: 10),
            const _SectionTitle(title: "Biblioteca"),
            const SizedBox(height: 10),
            Container(
              color: theme.colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MenuItemTile(
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
                  MenuItemTile(
                    icon: Icons.bar_chart_outlined,
                    title: "Estadísticas",
                    expanded: false,
                    onTap: () => Navigator.pushNamed(context, '/statistics'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const _SectionTitle(title: "Preferencias"),
            const SizedBox(height: 10),
            Container(
              color: theme.colorScheme.surface,
              child: PreferencesSwitches(
                notificationsEnabled: notificationsEnabled,
                onNotificationToggle: (val) {
                  setState(() => notificationsEnabled = val);
                },
              ),
            ),
            const SizedBox(height: 10),
            const _SectionTitle(title: "Cuenta"),
            const SizedBox(height: 10),
            Container(
              color: theme.colorScheme.surface,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Cerrar sesión",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _showLogoutDialog(),
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
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextDisabled,
        ),
      ),
    );
  }
}

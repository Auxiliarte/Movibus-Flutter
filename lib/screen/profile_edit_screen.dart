import 'package:flutter/material.dart';
import 'package:moventra/themes/app_colors.dart';
import 'package:moventra/widgets/custom_bottom_nav_bar.dart';
import 'package:moventra/widgets/profile/menu_item_tile.dart';
import 'package:moventra/widgets/profile/preferences_switches.dart';
import 'package:moventra/widgets/profile/profile_edit_menu.dart';
import 'package:moventra/widgets/profile/profile_header_edit.dart';

class ProfileEditMenu extends StatefulWidget {
  const ProfileEditMenu({super.key});

  @override
  State<ProfileEditMenu> createState() => _ProfileEditMenuState();
}

class _ProfileEditMenuState extends State<ProfileEditMenu> {
  bool showFavoritos = false;
  bool notificationsEnabled = false;
  int _currentIndex = 3;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileEditheader(),
            Container(
              width: double.infinity,
              height: 2,
              color: const Color(0xFFDDDCDC),
            ),
            const AccountMenuSection(),
            const SizedBox(height: 10),
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

class _SectionTitle extends StatefulWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  State<_SectionTitle> createState() => _SectionTitleState();
}

class _SectionTitleState extends State<_SectionTitle> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        widget.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextDisabled,
        ),
      ),
    );
  }
}

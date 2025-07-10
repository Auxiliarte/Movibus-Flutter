import 'package:flutter/material.dart';
import 'package:movibus/widgets/custom_bottom_nav_bar.dart';
import 'package:movibus/widgets/profile/profile_edit_form.dart';

class ProfileEditpersonal extends StatefulWidget {
  const ProfileEditpersonal({super.key});

  @override
  State<ProfileEditpersonal> createState() => _ProfileEditpersonalState();
}

class _ProfileEditpersonalState extends State<ProfileEditpersonal> {
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
      body: ListView(
        children: [
          Container(
            color: theme.secondaryHeaderColor,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_left),
                  color: theme.iconTheme.color,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  "Información Personal",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 2,
            color: const Color(0xFFDDDCDC),
          ),
          const EditPersonalInfoForm(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

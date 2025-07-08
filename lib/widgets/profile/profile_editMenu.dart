import 'package:flutter/material.dart';

class AccountMenuSection extends StatelessWidget {
  const AccountMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              "Cuenta",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          _MenuItemTile(
            icon: Icons.person_outline,
            title: "Información personal",
            onTap: () => Navigator.pushNamed(context, '/EditProfilePersonal'),
          ),
          _MenuItemTile(
            icon: Icons.lock_outline,
            title: "Contraseña",
            onTap: () => Navigator.pushNamed(context, '/EditProfilePass'),
          ),
          _MenuItemTile(
            icon: Icons.email_outlined,
            title: "Correo",
            onTap: () => Navigator.pushNamed(context, '/EditProfileMail'),
          ),

          const SizedBox(height: 24),

          // Cerrar sesión
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: Colors.red),
            title: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Welcome');
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              child: const Text(
                "Cerrar sesión",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItemTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(
        Icons.keyboard_arrow_right,
        size: 20,
        color: Color.fromARGB(255, 164, 163, 163),
      ),
      onTap: onTap,
    );
  }
}

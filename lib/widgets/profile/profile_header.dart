import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
    );
  }
}

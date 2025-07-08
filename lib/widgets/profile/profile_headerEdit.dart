import 'package:flutter/material.dart';

class ProfileEditheader extends StatelessWidget {
  const ProfileEditheader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(left: 30, top: 60, right: 30, bottom: 30),
      color: theme.secondaryHeaderColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/Avatars.png'),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Juan Pérez",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                "Administrador",
                style: TextStyle(
                  fontSize: 15,
                  decoration: TextDecoration.none,
                  color: Color.fromARGB(255, 120, 120, 120),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

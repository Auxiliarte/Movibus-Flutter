import 'package:flutter/material.dart';

class Step3Content extends StatelessWidget {
  final bool aceptaNotificaciones;
  final bool aceptaPromos;
  final ValueChanged<bool?> onChangedNotificaciones;
  final ValueChanged<bool?> onChangedPromos;

  const Step3Content({
    Key? key,
    required this.aceptaNotificaciones,
    required this.aceptaPromos,
    required this.onChangedNotificaciones,
    required this.onChangedPromos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Image.asset(
            'assets/Illustration.png',
            width: 350,
            height: 350,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recibir notificaciones',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
              ),
            ),
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: aceptaNotificaciones,
                onChanged: onChangedNotificaciones,
                activeColor: const Color(0xFFA13CF2),
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
        const Divider(color: Color(0xFFDDDDDD), thickness: 1, height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recibir promociones',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
              ),
            ),
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: aceptaPromos,
                onChanged: onChangedPromos,
                activeColor: const Color(0xFFA13CF2),
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

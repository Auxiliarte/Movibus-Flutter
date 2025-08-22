import 'package:flutter/material.dart';

class Step2Content extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmationController;

  const Step2Content({
    Key? key,
    required this.passwordController,
    required this.passwordConfirmationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• Mínimo 8 caracteres\n'
          '• Al menos una letra mayúscula\n'
          '• Al menos una letra minúscula\n'
          '• Al menos un número\n'
          '• Al menos un carácter especial (@, #, \$, etc.)',
          style: TextStyle(
            fontSize: 16,
            height: 1.3,
            fontFamily: 'Quicksand',
            color: Color(0xFF8C8C8C),
          ),
        ),
        const SizedBox(height: 24),

        // Campo de contraseña
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color.fromARGB(255, 180, 180, 180)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color.fromARGB(255, 180, 180, 180)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFFA13CF2), width: 2),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Campo de confirmación de contraseña
        TextField(
          controller: passwordConfirmationController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirmar contraseña',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color.fromARGB(255, 180, 180, 180)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color.fromARGB(255, 180, 180, 180)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFFA13CF2), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

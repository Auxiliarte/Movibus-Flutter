import 'package:flutter/material.dart';

class PasswordRequirementField extends StatelessWidget {
  const PasswordRequirementField({super.key});

  @override
  Widget build(BuildContext context) {
    const fieldTextStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,

      fontFamily: 'Quicksand',
    );

    InputDecoration customDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: fieldTextStyle,
        hintStyle: fieldTextStyle,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Por favor, ingresa tu contraseña actual y una nueva que cumpla con los siguientes requisitos:',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Quicksand',

              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),

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
          const SizedBox(height: 30),

          // Contraseña
          TextField(
            obscureText: true,
            style: fieldTextStyle,
            decoration: customDecoration('Contraseña'),
          ),
          const SizedBox(height: 20),

          // Nueva contraseña
          TextField(
            obscureText: true,
            style: fieldTextStyle,
            decoration: customDecoration('Nueva contraseña'),
          ),
          const SizedBox(height: 150),

          // Botón Guardar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA13CF2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

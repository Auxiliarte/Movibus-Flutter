import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ConnectedAppsSection extends StatelessWidget {
  const ConnectedAppsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input de correo
          TextField(
            readOnly: true,
            controller: TextEditingController(text: 'josa1758@gmail.com'),
            decoration: InputDecoration(
              labelText: 'Correo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Apps conectadas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'Quicksand',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Permitiste que estas apps inicien sesión en tu cuenta de Moventra.',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Quicksand',
              color: Color(0xFF777777),
            ),
          ),
          const SizedBox(height: 20),

          // Lista de apps con  los iconos
          _buildAppRow(
            icon: _buildCircleIcon(
              icon: Image.asset(
                'assets/Icon/icons-google.png',
                height: 20,
                width: 20,
              ),
              backgroundColor: const Color(0xFFF2F1F1),
            ),
            name: "Google",
            isConnected: true,
          ),
          _buildAppRow(
            icon: _buildCircleIcon(
              icon: Image.asset(
                'assets/Icon/icons-facebook.png',
                height: 20,
                width: 20,
              ),
              backgroundColor: Colors.blue,
            ),
            name: "Facebook",
            isConnected: false,
          ),
          _buildAppRow(
            icon: _buildCircleIcon(
              icon: const FaIcon(
                FontAwesomeIcons.apple,
                size: 20,
                color: Colors.white,
              ),
              backgroundColor: Colors.black,
            ),
            name: "Apple",
            isConnected: false,
          ),
          _buildAppRow(
            icon: _buildCircleIcon(
              icon: const FaIcon(
                FontAwesomeIcons.twitter,
                size: 20,
                color: Colors.white,
              ),
              backgroundColor: Colors.lightBlue,
            ),
            name: "Twitter",
            isConnected: false,
          ),

          const SizedBox(height: 130),

          // Botón guardar
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
                "Guardar",
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

  Widget _buildCircleIcon({
    required Widget icon,
    Color backgroundColor = Colors.blue,
  }) {
    return Container(
      height: 35,
      width: 35,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: icon,
    );
  }

  Widget _buildAppRow({
    required Widget icon,
    required String name,
    required bool isConnected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 15, fontFamily: 'Quicksand'),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color:
                  isConnected
                      ? const Color(0xFFE5D6FB)
                      : const Color(0xFFF2EDFA),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              isConnected ? 'Desconectar' : 'Conectar',
              style: TextStyle(
                fontSize: 14,
                color:
                    isConnected
                        ? const Color(0xFFA13CF2)
                        : const Color(0xFF9C6CD8),
                fontWeight: FontWeight.w600,
                fontFamily: 'Quicksand',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

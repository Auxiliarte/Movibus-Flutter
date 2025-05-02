import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, bool> expandStates = {
    'informacion': false,
    'contrasena': false,
    'correo': false,
    'mas': true,
    'soporte': false,
    'terminos': false,
  };

  int _currentIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/Welcome');
    }
  }

  void toggle(String key) {
    setState(() {
      expandStates[key] = !(expandStates[key] ?? false);
    });
  }

  Widget buildOption(String title, String key, {bool removeIcon = false}) {
    final isExpanded = expandStates[key] ?? false;
    final isActive = isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Quicksand',
              color: Colors.black,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          trailing:
              removeIcon
                  ? null
                  : Icon(
                    isActive
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_right,
                    color: isActive ? Colors.black : Colors.grey,
                  ),
          onTap: () => toggle(key),
        ),
        if (isExpanded)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: const Text(
              'Contenido desplegado...',
              style: TextStyle(fontFamily: 'Quicksand', color: Colors.grey),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.grey,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Text(
                  "Configuración",
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  width: 48,
                ), // Para alinear con el ícono de cerrar
              ],
            ),

            const SizedBox(height: 16),

            // Suscripción Premium
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF7257FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Suscripción Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Actualiza para obtener más opciones',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/king.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Configuración de la cuenta",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
              ),
            ),

            const SizedBox(height: 16),
            buildOption("Información personal", "informacion"),
            buildOption("Contraseña", "contrasena"),
            buildOption("Correo", "correo"),

            Column(
              children: [
                buildOption("Más", "mas", removeIcon: true),
                if (expandStates['mas'] ?? false) ...[
                  const SizedBox(height: 8),
                  buildOption("Soporte", "soporte"),
                  buildOption("Términos y condiciones", "terminos"),
                ],
              ],
            ),

            const SizedBox(height: 32),

            Center(
              child: TextButton(
                onPressed: () {
                  // Aquí va tu lógica para cerrar sesión
                },
                child: const Text(
                  'Finalizar sesión',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

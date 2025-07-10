import 'package:flutter/material.dart';

class HelpModal extends StatefulWidget {
  final bool isVisible;

  const HelpModal({
    super.key,
    required this.isVisible,
  });

  @override
  State<HelpModal> createState() => _HelpModalState();
}

class _HelpModalState extends State<HelpModal> {
  int _currentStep = 0;
  final int _totalSteps = 4;

  final List<HelpStep> _steps = [
    HelpStep(
      title: '¡Bienvenido a Movibus!',
      description: 'Te ayudaremos a planificar tu viaje en transporte público de San Luis Potosí.',
      icon: Icons.directions_bus,
      color: Colors.blue,
    ),
    HelpStep(
      title: 'Ubicación Actual',
      description: 'Usa el botón de ubicación actual (📍) para encontrar rápidamente tu posición, o escribe tu dirección manualmente.',
      icon: Icons.my_location,
      color: Colors.green,
    ),
    HelpStep(
      title: 'Selección desde Mapa',
      description: 'Si no encuentras tu dirección, puedes seleccionarla directamente desde el mapa tocando la opción "Selecciónala desde el mapa".',
      icon: Icons.map,
      color: Colors.orange,
    ),
    HelpStep(
      title: 'Destino y Rutas',
      description: 'Una vez que selecciones tu destino, verás automáticamente las mejores rutas disponibles para llegar a tu destino.',
      icon: Icons.route,
      color: Colors.purple,
    ),
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _skipTutorial() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight * 0.9,
              minHeight: 200,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con progreso
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _steps[_currentStep].color.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _skipTutorial,
                            child: const Text(
                              'Saltar',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Text(
                            '${_currentStep + 1} de $_totalSteps',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Barra de progreso
                      LinearProgressIndicator(
                        value: (_currentStep + 1) / _totalSteps,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(_steps[_currentStep].color),
                      ),
                    ],
                  ),
                ),
                // Contenido del step
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icono
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: _steps[_currentStep].color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Icon(
                            _steps[_currentStep].icon,
                            size: 36,
                            color: _steps[_currentStep].color,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Título
                        Text(
                          _steps[_currentStep].title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        // Descripción
                        Text(
                          _steps[_currentStep].description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                // Botones de navegación
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón anterior
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: _previousStep,
                          child: const Text(
                            'Anterior',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      else
                        const SizedBox(width: 80),
                      // Botón siguiente/finalizar
                      ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _steps[_currentStep].color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          _currentStep == _totalSteps - 1 ? '¡Comenzar!' : 'Siguiente',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class HelpStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  HelpStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

// Widget para mostrar el botón de ayuda
class HelpButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HelpButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      child: const Icon(Icons.help_outline),
    );
  }
} 
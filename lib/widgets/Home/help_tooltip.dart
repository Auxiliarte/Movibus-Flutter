import 'package:flutter/material.dart';

class HelpTooltip extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;

  const HelpTooltip({
    super.key,
    required this.message,
    this.icon = Icons.help_outline,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer.withOpacity(0.3);
    final txtColor = textColor ?? theme.colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: txtColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: txtColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeHelpSection extends StatelessWidget {
  final bool showHelp;

  const HomeHelpSection({
    super.key,
    this.showHelp = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showHelp) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 16),
        const HelpTooltip(
          message: '💡 Consejo: Usa el botón de ubicación actual para encontrar rápidamente tu posición',
          icon: Icons.lightbulb_outline,
        ),
        const SizedBox(height: 8),
        const HelpTooltip(
          message: '🗺️ Si no encuentras tu dirección, puedes seleccionarla desde el mapa',
          icon: Icons.map_outlined,
        ),
        const SizedBox(height: 8),
        const HelpTooltip(
          message: '🚌 Una vez que selecciones origen y destino, verás las mejores rutas disponibles',
          icon: Icons.directions_bus_outlined,
        ),
      ],
    );
  }
} 
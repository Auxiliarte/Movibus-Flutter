import 'package:flutter/material.dart';
import '../../services/location_service.dart';

class EnhancedSearchInput extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final bool showLocationButton;
  final Function(double, double)? onLocationSelected;

  const EnhancedSearchInput({
    Key? key,
    required this.hint,
    required this.controller,
    this.onChanged,
    this.showLocationButton = false,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  State<EnhancedSearchInput> createState() => _EnhancedSearchInputState();
}

class _EnhancedSearchInputState extends State<EnhancedSearchInput> {
  bool isLoadingLocation = false;

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        // Obtener dirección desde coordenadas
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (address != null) {
          widget.controller.text = address;
          widget.onChanged?.call(address);
        }

        // Notificar las coordenadas si se proporciona el callback
        widget.onLocationSelected?.call(position.latitude, position.longitude);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error obteniendo ubicación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        if (widget.showLocationButton) ...[
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: isLoadingLocation ? null : getCurrentLocation,
              icon: isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location, color: Colors.white),
              tooltip: 'Usar ubicación actual',
            ),
          ),
        ],
      ],
    );
  }
} 
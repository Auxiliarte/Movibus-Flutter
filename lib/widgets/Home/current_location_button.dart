import 'package:flutter/material.dart';
import '../../services/location_service.dart';

class CurrentLocationButton extends StatefulWidget {
  final Function(String address, double lat, double lng) onLocationUpdated;
  final String currentAddress;

  const CurrentLocationButton({
    super.key,
    required this.onLocationUpdated,
    this.currentAddress = '',
  });

  @override
  State<CurrentLocationButton> createState() => _CurrentLocationButtonState();
}

class _CurrentLocationButtonState extends State<CurrentLocationButton> {
  bool _isUpdating = false;

  Future<void> _updateCurrentLocation() async {
    setState(() => _isUpdating = true);
    
    try {
      final locationData = await LocationService.getCurrentLocationWithAddress();
      if (locationData != null) {
        widget.onLocationUpdated(
          locationData['address'] ?? '',
          locationData['latitude']!,
          locationData['longitude']!,
        );
        
        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ubicación actualizada'),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Mostrar mensaje de error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No se pudo obtener la ubicación actual'),
              backgroundColor: Colors.red.shade600,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error actualizando ubicación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isUpdating ? null : _updateCurrentLocation,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isUpdating)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.my_location,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text(
                  _isUpdating ? 'Actualizando...' : 'Usar ubicación actual',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
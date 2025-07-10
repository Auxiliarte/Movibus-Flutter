import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/location_service.dart';

class MapLocationPicker extends StatefulWidget {
  final Function(String address, double lat, double lng) onLocationSelected;
  final String initialAddress;

  const MapLocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialAddress = '',
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(22.1565, -100.9855); // Centro de San Luis Potosí
  LatLng? _selectedLocation;
  bool _isLoading = false;
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);
    
    try {
      // Intentar obtener ubicación actual
      final currentLocation = await LocationService.getCurrentLocationWithAddress();
      if (currentLocation != null) {
        setState(() {
          _center = LatLng(
            currentLocation['latitude']!,
            currentLocation['longitude']!,
          );
          _selectedLocation = _center;
          _selectedAddress = currentLocation['address'] ?? '';
        });
      }
    } catch (e) {
      print('Error inicializando ubicación: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _selectedLocation = position.target;
    });
  }

  Future<void> _onCameraIdle() async {
    if (_selectedLocation != null) {
      setState(() => _isLoading = true);
      
      try {
        final address = await LocationService.getAddressFromCoordinates(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        );
        
        setState(() {
          _selectedAddress = address ?? '';
        });
      } catch (e) {
        print('Error obteniendo dirección: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      widget.onLocationSelected(
        _selectedAddress,
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar ubicación'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: _confirmLocation,
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.0,
            ),
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                      infoWindow: InfoWindow(
                        title: 'Ubicación seleccionada',
                        snippet: _selectedAddress,
                      ),
                    ),
                  }
                : {},
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ubicación seleccionada:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedAddress.isNotEmpty 
                        ? _selectedAddress 
                        : 'Mueve el mapa para seleccionar una ubicación',
                    style: TextStyle(
                      color: _selectedAddress.isNotEmpty 
                          ? Colors.black87 
                          : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  if (_selectedLocation != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Coordenadas: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
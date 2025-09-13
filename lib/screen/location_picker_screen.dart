import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../services/region_service.dart';

class LocationPickerScreen extends StatefulWidget {
  final String title;
  final String? initialAddress;

  const LocationPickerScreen({
    super.key,
    required this.title,
    this.initialAddress,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoading = true;
  String? _error;

  // Obtener coordenadas del centro de la región actual
  static LatLng get _regionCenter {
    final region = RegionService.currentRegion;
    return LatLng(region.centerLatitude, region.centerLongitude);
  }

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Intentar obtener ubicación actual
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _getAddressFromLocation(_selectedLocation!);
      } else {
        // Usar centro de la región actual como fallback
        setState(() {
          _selectedLocation = _regionCenter;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _selectedLocation = _regionCenter;
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLocation(LatLng location) async {
    try {
      setState(() {
        _selectedAddress = 'Obteniendo dirección...';
      });

      // Intentar obtener la dirección real usando el servicio de geocoding
      final address = await LocationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (address != null && address.isNotEmpty) {
        setState(() {
          _selectedAddress = address;
        });
      } else {
        // Si no se puede obtener la dirección, mostrar una ubicación aproximada
        setState(() {
          _selectedAddress = 'Ubicación aproximada (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _selectedAddress = 'Ubicación seleccionada (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})';
      });
    }
  }


  void _onCameraMove(CameraPosition position) {
    // Actualizar ubicación en tiempo real mientras se mueve la cámara
    if (_mapController != null) {
      _mapController!.getLatLng(ScreenCoordinate(
        x: (MediaQuery.of(context).size.width / 2).round(), // Centro horizontal
        y: (MediaQuery.of(context).size.height / 2).round(), // Centro vertical
      )).then((center) {
        if (center != null && mounted) {
          setState(() {
            _selectedLocation = center;
          });
        }
      });
    }
  }

  void _onCameraIdle() {
    // Actualizar la dirección cuando la cámara se detiene
    if (_selectedLocation != null) {
      _getAddressFromLocation(_selectedLocation!);
    }
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      Navigator.pop(context, {
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'address': _selectedAddress ?? 'Ubicación seleccionada',
      });
    }
  }

  void _useCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        final newLocation = LatLng(position.latitude, position.longitude);
        setState(() {
          _selectedLocation = newLocation;
          _isLoading = false;
        });
        
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newLocation, 15),
        );
        
        _getAddressFromLocation(newLocation);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener ubicación actual: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _useCurrentLocation,
            icon: const Icon(Icons.my_location),
            tooltip: 'Usar ubicación actual',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa
          if (_selectedLocation != null)
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _selectedLocation!,
                zoom: 15,
              ),
              onTap: (LatLng location) {
                // Tap deshabilitado, ahora usamos puntero fijo
              },
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              markers: {}, // Sin marcadores, usamos puntero fijo
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),

          // Puntero fijo en el centro del mapa
          if (_selectedLocation != null && !_isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 48,
                    color: Colors.red,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  Container(
                    width: 4,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),

          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Información de ubicación seleccionada
          if (_selectedLocation != null && !_isLoading)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ubicación del puntero',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAddress ?? 'Mueve el mapa para seleccionar ubicación',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mueve el mapa para elegir tu ubicación exacta',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Botón de confirmar
          if (_selectedLocation != null && !_isLoading)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirmar ubicación',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Mensaje de error
          if (_error != null)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error: $_error',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
} 
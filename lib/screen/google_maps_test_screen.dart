import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsTestScreen extends StatefulWidget {
  const GoogleMapsTestScreen({super.key});

  @override
  State<GoogleMapsTestScreen> createState() => _GoogleMapsTestScreenState();
}

class _GoogleMapsTestScreenState extends State<GoogleMapsTestScreen> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(22.1565, -100.9855); // San Luis Potosí
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addTestMarkers();
  }

  void _addTestMarkers() {
    setState(() {
      _markers = {
        // Marcador de origen (azul)
        Marker(
          markerId: const MarkerId('origin'),
          position: const LatLng(22.1565, -100.9855),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Origen',
            snippet: 'Mi ubicación actual',
          ),
        ),
        // Marcador de destino (rojo)
        Marker(
          markerId: const MarkerId('destination'),
          position: const LatLng(22.117307, -100.9434772),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: 'Destino',
            snippet: 'Aristóteles 100',
          ),
        ),
      };
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    print('🗺️ Google Maps created successfully');
    _mapController = controller;
  }

  void _onMapTap(LatLng location) {
    print('🗺️ Map tapped at: ${location.latitude}, ${location.longitude}');
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('tap_${DateTime.now().millisecondsSinceEpoch}'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Punto seleccionado',
            snippet: '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
          ),
        ),
      );
    });
  }

  void _centerMap() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: const LatLng(22.115, -100.985),
            northeast: const LatLng(22.157, -100.943),
          ),
          50.0,
        ),
      );
    }
  }

  void _clearMarkers() {
    setState(() {
      _markers = _markers.where((marker) => 
        marker.markerId.value == 'origin' || 
        marker.markerId.value == 'destination'
      ).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba Google Maps'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: _centerMap,
            tooltip: 'Centrar mapa',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearMarkers,
            tooltip: 'Limpiar marcadores',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información de prueba
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prueba de Google Maps',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Marcador azul: Origen\n• Marcador rojo: Destino\n• Toca el mapa para agregar marcadores verdes\n• Usa los botones de la barra superior',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          // Mapa
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 13,
                  ),
                  onTap: _onMapTap,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: true,
                  compassEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                ),
              ),
            ),
          ),
          
          // Botones de control
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Regresar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Google Maps funciona correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Probar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

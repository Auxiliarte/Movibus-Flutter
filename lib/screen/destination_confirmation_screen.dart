import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DestinationConfirmationScreen extends StatefulWidget {
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final String? originAddress;
  final String? destinationAddress;

  const DestinationConfirmationScreen({
    super.key,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    this.originAddress,
    this.destinationAddress,
  });

  @override
  State<DestinationConfirmationScreen> createState() => _DestinationConfirmationScreenState();
}

class _DestinationConfirmationScreenState extends State<DestinationConfirmationScreen> {
  GoogleMapController? _mapController;
  late double _destinationLat;
  late double _destinationLng;
  String? _destinationAddress;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _destinationLat = widget.destinationLat;
    _destinationLng = widget.destinationLng;
    _destinationAddress = widget.destinationAddress;
  }

  void _onMapCreated(GoogleMapController controller) {
    print('🗺️ Google Maps created successfully');
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
    
    // Centrar el mapa para mostrar ambos puntos
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_mapController != null && mounted) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(_getBounds(), 50.0),
        );
      }
    });
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _destinationLat = location.latitude;
      _destinationLng = location.longitude;
      _destinationAddress = 'Ubicación seleccionada';
    });
  }

  void _confirmSelection() {
    Navigator.of(context).pop({
      'latitude': _destinationLat,
      'longitude': _destinationLng,
      'address': _destinationAddress ?? 'Ubicación seleccionada',
      'autoSearch': true, // Indicar que se debe buscar rutas automáticamente
    });
  }

  void _cancelSelection() {
    Navigator.of(context).pop(null);
  }

  LatLngBounds _getBounds() {
    final origin = LatLng(widget.originLat, widget.originLng);
    final destination = LatLng(_destinationLat, _destinationLng);
    
    final southwest = LatLng(
      [widget.originLat, _destinationLat].reduce((a, b) => a < b ? a : b),
      [widget.originLng, _destinationLng].reduce((a, b) => a < b ? a : b),
    );
    
    final northeast = LatLng(
      [widget.originLat, _destinationLat].reduce((a, b) => a > b ? a : b),
      [widget.originLng, _destinationLng].reduce((a, b) => a > b ? a : b),
    );
    
    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  void _centerMap() {
    if (_mapController != null && _isMapReady) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(_getBounds(), 50.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirma tu destino'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _cancelSelection,
        ),
        actions: [
          if (_isMapReady)
            IconButton(
              icon: const Icon(Icons.center_focus_strong),
              onPressed: _centerMap,
              tooltip: 'Centrar mapa',
            ),
        ],
      ),
      body: Column(
        children: [
          // Información de origen y destino
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Origen
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Origen',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.originAddress ?? 'Mi ubicación actual',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Línea conectora
                Container(
                  height: 20,
                  width: 2,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.only(left: 5),
                ),
                
                const SizedBox(height: 8),
                
                // Destino
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Destino',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _destinationAddress ?? 'Ubicación seleccionada',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Mapa
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        (widget.originLat + _destinationLat) / 2,
                        (widget.originLng + _destinationLng) / 2,
                      ),
                      zoom: 13,
                    ),
                    onTap: _onMapTap,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    markers: {
                      // Marcador de origen
                      Marker(
                        markerId: const MarkerId('origin'),
                        position: LatLng(widget.originLat, widget.originLng),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                        infoWindow: InfoWindow(
                          title: 'Origen',
                          snippet: widget.originAddress ?? 'Mi ubicación actual',
                        ),
                      ),
                      // Marcador de destino
                      Marker(
                        markerId: const MarkerId('destination'),
                        position: LatLng(_destinationLat, _destinationLng),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        infoWindow: InfoWindow(
                          title: 'Destino',
                          snippet: _destinationAddress ?? 'Ubicación seleccionada',
                        ),
                      ),
                    },
                  ),
                  if (!_isMapReady)
                    Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Botones de acción
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelSelection,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                    child: const Text('Confirmar Destino'),
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

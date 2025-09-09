import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_suggestion_model.dart';

class FullScreenMapModal extends StatefulWidget {
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final VoidCallback onFitBounds;
  final RouteSuggestionModel routeSuggestion;
  final double userLatitude;
  final double userLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final Stream<Set<Marker>>? markersStream;

  const FullScreenMapModal({
    Key? key,
    required this.initialCameraPosition,
    required this.markers,
    required this.polylines,
    required this.onFitBounds,
    required this.routeSuggestion,
    required this.userLatitude,
    required this.userLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    this.markersStream,
  }) : super(key: key);

  @override
  State<FullScreenMapModal> createState() => _FullScreenMapModalState();
}

class _FullScreenMapModalState extends State<FullScreenMapModal> {
  bool _isFullScreen = false;
  Set<Marker> _currentMarkers = {};

  @override
  void initState() {
    super.initState();
    _currentMarkers = widget.markers;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _isFullScreen ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Barra superior con controles
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Botón de cerrar
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: const CircleBorder(),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Título
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mapa de Ruta',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.routeSuggestion.subirEn.estacion} → ${widget.routeSuggestion.bajarseEn.estacion}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Botón de pantalla completa
                IconButton(
                  onPressed: _toggleFullScreen,
                  icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: const CircleBorder(),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Botón de centrar mapa
                IconButton(
                  onPressed: _fitBounds,
                  icon: const Icon(Icons.center_focus_strong),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
          
          // Mapa
          Expanded(
            child: widget.markersStream != null
                ? StreamBuilder<Set<Marker>>(
                    stream: widget.markersStream,
                    initialData: widget.markers,
                    builder: (context, snapshot) {
                      final markers = snapshot.data ?? _currentMarkers;
                      return GoogleMap(
                        initialCameraPosition: widget.initialCameraPosition,
                        markers: markers,
                        polylines: widget.polylines,
                        onMapCreated: (GoogleMapController controller) {
                          _fitBounds();
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        mapType: MapType.normal,
                        compassEnabled: true,
                        trafficEnabled: false,
                      );
                    },
                  )
                : GoogleMap(
                    initialCameraPosition: widget.initialCameraPosition,
                    markers: _currentMarkers,
                    polylines: widget.polylines,
                    onMapCreated: (GoogleMapController controller) {
                      _fitBounds();
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    mapType: MapType.normal,
                    compassEnabled: true,
                    trafficEnabled: false,
                  ),
          ),
          
          // Panel inferior con información (solo si no está en pantalla completa)
          if (!_isFullScreen) _buildInfoPanel(),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Información de la ruta
          Row(
            children: [
              Icon(
                Icons.directions_bus,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.routeSuggestion.routeName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  'Activa',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Leyenda del mapa
          Text(
            'Leyenda:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              _buildLegendItem(Colors.green, 'Caminando'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.blue, 'En autobús'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.red, 'Ubicación actual'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _fitBounds() {
    widget.onFitBounds();
  }
}

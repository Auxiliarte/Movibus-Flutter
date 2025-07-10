import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_suggestion_model.dart';
import '../themes/app_colors.dart';

class RouteDetailScreen extends StatefulWidget {
  final RouteSuggestionModel routeSuggestion;
  final String destinationAddress;
  final double userLatitude;
  final double userLongitude;

  const RouteDetailScreen({
    Key? key,
    required this.routeSuggestion,
    required this.destinationAddress,
    required this.userLatitude,
    required this.userLongitude,
  }) : super(key: key);

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeMap();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeMap() {
    // Debug: Imprimir coordenadas para verificar
    print('🗺️ Inicializando mapa con coordenadas:');
    print('👤 Usuario: ${widget.userLatitude}, ${widget.userLongitude}');
    print('🚌 Estación partida: ${widget.routeSuggestion.departureStation.latitude}, ${widget.routeSuggestion.departureStation.longitude}');
    print('🏁 Estación llegada: ${widget.routeSuggestion.arrivalStation.latitude}, ${widget.routeSuggestion.arrivalStation.longitude}');
    
    _markers = {
      // Marcador de ubicación del usuario
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(widget.userLatitude, widget.userLongitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'Tu ubicación',
          snippet: 'Punto de partida',
        ),
      ),
      // Marcador de estación de partida
      Marker(
        markerId: const MarkerId('departure_station'),
        position: LatLng(
          widget.routeSuggestion.departureStation.latitude,
          widget.routeSuggestion.departureStation.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: widget.routeSuggestion.departureStation.name,
          snippet: 'Estación de partida',
        ),
      ),
      // Marcador de estación de llegada
      Marker(
        markerId: const MarkerId('arrival_station'),
        position: LatLng(
          widget.routeSuggestion.arrivalStation.latitude,
          widget.routeSuggestion.arrivalStation.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: widget.routeSuggestion.arrivalStation.name,
          snippet: 'Estación de llegada',
        ),
      ),
      // Marcador del destino final (usando las coordenadas del destino)
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(
          widget.routeSuggestion.arrivalStation.latitude + 0.001, // Pequeño offset para distinguir
          widget.routeSuggestion.arrivalStation.longitude + 0.001,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(
          title: 'Destino',
          snippet: widget.destinationAddress,
        ),
      ),
    };

    // Agregar marcadores de estaciones intermedias
    for (int i = 0; i < widget.routeSuggestion.intermediateStations.length; i++) {
      final station = widget.routeSuggestion.intermediateStations[i];
      _markers.add(
        Marker(
          markerId: MarkerId('intermediate_${station.id}'),
          position: LatLng(station.latitude, station.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow: InfoWindow(
            title: station.name,
            snippet: 'Estación intermedia',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Ruta'),
        backgroundColor: AppColors.lightPrimaryButton,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header con información general
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightPrimaryButton,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.routeSuggestion.routeName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.routeSuggestion.estimatedTotalTime.toStringAsFixed(1)} min total',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.directions_walk, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.routeSuggestion.totalWalkingDistance.toStringAsFixed(0)}m caminando',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.lightPrimaryButton,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.lightPrimaryButton,
              tabs: const [
                Tab(text: 'Instrucciones'),
                Tab(text: 'Mapa'),
                Tab(text: 'Detalles'),
              ],
            ),
          ),
          
          // Contenido de los tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInstructionsTab(),
                _buildMapTab(),
                _buildDetailsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección 1: Caminar a la estación de partida
          _buildInstructionCard(
            icon: Icons.directions_walk,
            title: 'Caminar a la estación',
            subtitle: widget.routeSuggestion.departureStation.name,
            details: [
              'Distancia: ${widget.routeSuggestion.departureStation.distanceFromUser?.toStringAsFixed(0) ?? "N/A"} metros',
              'Tiempo estimado: ${widget.routeSuggestion.departureStation.walkingTimeMinutes?.toStringAsFixed(1) ?? "N/A"} minutos',
            ],
            color: Colors.blue,
          ),
          
          const SizedBox(height: 16),
          
          // Sección 2: Tomar el autobús
          _buildInstructionCard(
            icon: Icons.directions_bus,
            title: 'Tomar el autobús',
            subtitle: widget.routeSuggestion.routeName,
            details: [
              'Dirección: ${widget.routeSuggestion.direction == "forward" ? "Hacia adelante" : "Hacia atrás"}',
              'Estaciones: ${widget.routeSuggestion.stationsCount} paradas',
              'Tiempo estimado: ${widget.routeSuggestion.estimatedBusTimeFormatted}',
            ],
            color: Colors.green,
          ),
          
          const SizedBox(height: 16),
          
          // Sección 3: Caminar al destino
          _buildInstructionCard(
            icon: Icons.directions_walk,
            title: 'Caminar al destino',
            subtitle: widget.destinationAddress,
            details: [
              'Distancia: ${widget.routeSuggestion.arrivalStation.distanceToDestination?.toStringAsFixed(0) ?? "N/A"} metros',
              'Tiempo estimado: ${widget.routeSuggestion.arrivalStation.walkingTimeMinutes?.toStringAsFixed(1) ?? "N/A"} minutos',
            ],
            color: Colors.orange,
          ),
          
          const SizedBox(height: 20),
          
          // Botón de acción
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Aquí se podría abrir Google Maps o la app de navegación
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidad de navegación próximamente'),
                  ),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Abrir Navegación'),
                              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimaryButton,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              (widget.userLatitude + widget.routeSuggestion.departureStation.latitude + widget.routeSuggestion.arrivalStation.latitude) / 3,
              (widget.userLongitude + widget.routeSuggestion.departureStation.longitude + widget.routeSuggestion.arrivalStation.longitude) / 3,
            ),
            zoom: 12,
          ),
          markers: _markers,
          polylines: _polylines,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _fitBounds();
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de la ruta
          _buildDetailCard(
            title: 'Información de la Ruta',
            children: [
              _buildDetailRow('Nombre', widget.routeSuggestion.routeName),
              _buildDetailRow('Descripción', widget.routeSuggestion.routeDescription),
              _buildDetailRow('Total de estaciones', '${widget.routeSuggestion.totalStations}'),
              _buildDetailRow('Puntuación', '${(widget.routeSuggestion.score * 100).toStringAsFixed(0)}%'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Estación de partida
          _buildDetailCard(
            title: 'Estación de Partida',
            children: [
              _buildDetailRow('Nombre', widget.routeSuggestion.departureStation.name),
              _buildDetailRow('Orden', '${widget.routeSuggestion.departureStation.order}'),
              _buildDetailRow('Distancia desde ti', '${widget.routeSuggestion.departureStation.distanceFromUser?.toStringAsFixed(0) ?? "N/A"} m'),
              _buildDetailRow('Tiempo caminando', '${widget.routeSuggestion.departureStation.walkingTimeMinutes?.toStringAsFixed(1) ?? "N/A"} min'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Estación de llegada
          _buildDetailCard(
            title: 'Estación de Llegada',
            children: [
              _buildDetailRow('Nombre', widget.routeSuggestion.arrivalStation.name),
              _buildDetailRow('Orden', '${widget.routeSuggestion.arrivalStation.order}'),
              _buildDetailRow('Distancia al destino', '${widget.routeSuggestion.arrivalStation.distanceToDestination?.toStringAsFixed(0) ?? "N/A"} m'),
              _buildDetailRow('Tiempo caminando', '${widget.routeSuggestion.arrivalStation.walkingTimeMinutes?.toStringAsFixed(1) ?? "N/A"} min'),
            ],
          ),
          
          if (widget.routeSuggestion.intermediateStations.isNotEmpty) ...[
            const SizedBox(height: 16),
            
            // Estaciones intermedias
            _buildDetailCard(
              title: 'Estaciones Intermedias',
              children: widget.routeSuggestion.intermediateStations.map((station) {
                return _buildDetailRow(
                  'Estación ${station.order}',
                  station.name,
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Resumen del viaje
          _buildDetailCard(
            title: 'Resumen del Viaje',
            children: [
              _buildDetailRow('Tiempo total', '${widget.routeSuggestion.estimatedTotalTime.toStringAsFixed(1)} min'),
              _buildDetailRow('Tiempo en autobús', '${widget.routeSuggestion.estimatedBusTimeFormatted}'),
              _buildDetailRow('Distancia caminando', '${widget.routeSuggestion.totalWalkingDistance.toStringAsFixed(0)} m'),
              _buildDetailRow('Dirección', widget.routeSuggestion.direction == "forward" ? "Hacia adelante" : "Hacia atrás"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> details,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...details.map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      detail,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _fitBounds() {
    if (_mapController == null || _markers.isEmpty) return;

    print('🗺️ Ajustando vista del mapa...');
    
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final marker in _markers) {
      print('📍 Marcador ${marker.markerId.value}: ${marker.position.latitude}, ${marker.position.longitude}');
      minLat = min(minLat, marker.position.latitude);
      maxLat = max(maxLat, marker.position.latitude);
      minLng = min(minLng, marker.position.longitude);
      maxLng = max(maxLng, marker.position.longitude);
    }

    print('🗺️ Bounds: SW(${minLat}, ${minLng}) NE(${maxLat}, ${maxLng})');

    // Verificar que las coordenadas son válidas
    if (minLat == double.infinity || maxLat == -double.infinity || 
        minLng == double.infinity || maxLng == -double.infinity) {
      print('❌ Coordenadas inválidas, usando posición por defecto');
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          const LatLng(22.1565, -100.9855), // San Luis Potosí centro
          12,
        ),
      );
      return;
    }

    // Agregar padding para asegurar que todos los marcadores sean visibles
    final latPadding = (maxLat - minLat) * 0.1;
    final lngPadding = (maxLng - minLng) * 0.1;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - latPadding, minLng - lngPadding),
          northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
        ),
        50, // padding adicional
      ),
    );
  }
} 
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_suggestion_model.dart';
import '../themes/app_colors.dart';
import '../services/driver_tracking_service.dart';
import '../widgets/Home/bus_tracking_widget.dart';
import '../widgets/Home/station_eta_widget.dart';

class RouteDetailScreen extends StatefulWidget {
  final RouteSuggestionModel routeSuggestion;
  final String destinationAddress;
  final double userLatitude;
  final double userLongitude;
  final double destinationLatitude;
  final double destinationLongitude;

  const RouteDetailScreen({
    super.key,
    required this.routeSuggestion,
    required this.destinationAddress,
    required this.userLatitude,
    required this.userLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
  });

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
    _tabController = TabController(length: 4, vsync: this);
    _initializeMap();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeMap() {
    
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
          title: widget.routeSuggestion.departureStation.displayName,
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
          title: widget.routeSuggestion.arrivalStation.displayName,
          snippet: 'Estación de llegada',
        ),
      ),
      // Marcador del destino final
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(
          widget.destinationLatitude,
          widget.destinationLongitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(
          title: 'Destino',
          snippet: widget.destinationAddress,
        ),
      ),
    };

    // Agregar marcadores de estaciones intermedias (solo si tienen coordenadas válidas)
    for (int i = 0; i < widget.routeSuggestion.intermediateStations.length; i++) {
      final station = widget.routeSuggestion.intermediateStations[i];
      if (station.latitude != 0.0 && station.longitude != 0.0) {
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

    // --- POLILÍNEAS ---
    _polylines = {};

    // 1. Trayecto caminando (usuario -> estación de partida)
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('walk_to_departure'),
        color: Colors.blue,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        points: [
          LatLng(widget.userLatitude, widget.userLongitude),
          LatLng(widget.routeSuggestion.departureStation.latitude, widget.routeSuggestion.departureStation.longitude),
        ],
      ),
    );

    // 2. Trayecto en autobús (estación de partida -> intermedias -> estación de llegada)
    final busRoutePoints = <LatLng>[];
    busRoutePoints.add(LatLng(widget.routeSuggestion.departureStation.latitude, widget.routeSuggestion.departureStation.longitude));
    for (final station in widget.routeSuggestion.intermediateStations) {
      if (station.latitude != 0.0 && station.longitude != 0.0) {
        busRoutePoints.add(LatLng(station.latitude, station.longitude));
      }
    }
    busRoutePoints.add(LatLng(widget.routeSuggestion.arrivalStation.latitude, widget.routeSuggestion.arrivalStation.longitude));
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('bus_route'),
        color: Colors.green,
        width: 6,
        points: busRoutePoints,
      ),
    );

    // 3. Trayecto caminando (estación de llegada -> destino)
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('walk_to_destination'),
        color: Colors.orange,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        points: [
          LatLng(widget.routeSuggestion.arrivalStation.latitude, widget.routeSuggestion.arrivalStation.longitude),
          LatLng(widget.destinationLatitude, widget.destinationLongitude),
        ],
      ),
    );
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
                Tab(text: 'Tracking'),
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
              _buildTrackingTab(),
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
            subtitle: widget.routeSuggestion.departureStation.displayName,
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(Colors.blue, isDashed: true),
              const SizedBox(width: 4),
              const Text('Camina a la estación', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
              _buildLegendDot(Colors.green),
              const SizedBox(width: 4),
              const Text('Trayecto en bus', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
              _buildLegendDot(Colors.orange, isDashed: true),
              const SizedBox(width: 4),
              const Text('Camina al destino', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 12),
              _buildLegendDot(Colors.red),
              const SizedBox(width: 4),
              const Text('Autobús', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FutureBuilder<Map<String, dynamic>>(
                future: DriverTrackingService.getDriverTrackingByRoute(widget.routeSuggestion.routeId),
                builder: (context, snapshot) {
                  Set<Marker> markers = Set.from(_markers);
                  
                  // Agregar marcador del autobús si hay tracking disponible
                  if (snapshot.hasData) {
                    final trackingData = snapshot.data!;
                    final formattedInfo = DriverTrackingService.formatTrackingInfo(trackingData);
                    
                    if (formattedInfo['hasActiveDriver'] && formattedInfo['currentLocation'] != null) {
                      final currentLocation = formattedInfo['currentLocation'];
                      markers.add(
                        Marker(
                          markerId: const MarkerId('bus_location'),
                          position: LatLng(
                            currentLocation['latitude'],
                            currentLocation['longitude'],
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                          infoWindow: InfoWindow(
                            title: 'Autobús en ruta',
                            snippet: 'Chofer: ${formattedInfo['driverName']}',
                          ),
                        ),
                      );
                    }
                  }
                  
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        (widget.userLatitude + widget.routeSuggestion.departureStation.latitude + widget.routeSuggestion.arrivalStation.latitude + widget.destinationLatitude) / 4,
                        (widget.userLongitude + widget.routeSuggestion.departureStation.longitude + widget.routeSuggestion.arrivalStation.longitude + widget.destinationLongitude) / 4,
                      ),
                      zoom: 12,
                    ),
                    markers: markers,
                    polylines: _polylines,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      _fitBounds();
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget de tracking del autobús
          BusTrackingWidget(
            routeId: widget.routeSuggestion.routeId,
            routeName: widget.routeSuggestion.routeName,
          ),
          
          const SizedBox(height: 24),
          
          // Lista de estaciones con tiempos estimados
          FutureBuilder<Map<String, dynamic>>(
            future: DriverTrackingService.getDriverTrackingByRoute(widget.routeSuggestion.routeId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return StationListWithETA(
                  stations: _getAllStations(),
                  isLoading: true,
                );
              }
              
              if (snapshot.hasError) {
                return StationListWithETA(
                  stations: _getAllStations(),
                  trackingInfo: null,
                  isLoading: false,
                );
              }
              
              final trackingData = snapshot.data;
              final formattedInfo = trackingData != null 
                  ? DriverTrackingService.formatTrackingInfo(trackingData)
                  : null;
              
              return StationListWithETA(
                stations: _getAllStations(),
                trackingInfo: formattedInfo,
                isLoading: false,
              );
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAllStations() {
    final stations = <Map<String, dynamic>>[];
    
    // Agregar estación de partida
    stations.add({
      'id': widget.routeSuggestion.departureStation.id,
      'name': widget.routeSuggestion.departureStation.name,
      'latitude': widget.routeSuggestion.departureStation.latitude,
      'longitude': widget.routeSuggestion.departureStation.longitude,
      'order': widget.routeSuggestion.departureStation.order,
    });
    
    // Agregar estaciones intermedias
    for (final station in widget.routeSuggestion.intermediateStations) {
      stations.add({
        'id': station.id,
        'name': station.name,
        'latitude': station.latitude,
        'longitude': station.longitude,
        'order': station.order,
      });
    }
    
    // Agregar estación de llegada
    stations.add({
      'id': widget.routeSuggestion.arrivalStation.id,
      'name': widget.routeSuggestion.arrivalStation.name,
      'latitude': widget.routeSuggestion.arrivalStation.latitude,
      'longitude': widget.routeSuggestion.arrivalStation.longitude,
      'order': widget.routeSuggestion.arrivalStation.order,
    });
    
    // Ordenar por orden
    stations.sort((a, b) => a['order'].compareTo(b['order']));
    
    return stations;
  }

  Widget _buildLegendDot(Color color, {bool isDashed = false}) {
    return Container(
      width: 18,
      height: 8,
      decoration: BoxDecoration(
        color: isDashed ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(4),
        border: isDashed ? Border.all(color: color, width: 2) : null,
      ),
      child: isDashed
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) =>
                  Container(width: 2, height: 8, color: color)),
            )
          : null,
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
              _buildDetailRow('Total de paradas', '${widget.routeSuggestion.totalStations}'),
              _buildDetailRow('Puntuación', '${(widget.routeSuggestion.score * 100).toStringAsFixed(0)}%'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Estado del autobús en tiempo real
          FutureBuilder<Map<String, dynamic>>(
            future: DriverTrackingService.getDriverTrackingByRoute(widget.routeSuggestion.routeId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildDetailCard(
                  title: 'Estado del Autobús',
                  children: [
                    _buildDetailRow('Estado', 'Cargando...'),
                  ],
                );
              }
              
              if (snapshot.hasError) {
                return _buildDetailCard(
                  title: 'Estado del Autobús',
                  children: [
                    _buildDetailRow('Estado', 'Error de conexión'),
                    _buildDetailRow('Mensaje', 'No se pudo obtener información'),
                  ],
                );
              }
              
              final trackingData = snapshot.data;
              final formattedInfo = trackingData != null 
                  ? DriverTrackingService.formatTrackingInfo(trackingData)
                  : null;
              
              if (formattedInfo == null || !formattedInfo['hasActiveDriver']) {
                return _buildDetailCard(
                  title: 'Estado del Autobús',
                  children: [
                    _buildDetailRow('Estado', 'Sin autobús activo'),
                    _buildDetailRow('Mensaje', formattedInfo?['message'] ?? 'No hay autobús en esta ruta'),
                  ],
                );
              }
              
              return _buildDetailCard(
                title: 'Estado del Autobús',
                children: [
                  _buildDetailRow('Estado', formattedInfo['status']),
                  _buildDetailRow('Chofer', formattedInfo['driverName']),
                  if (formattedInfo['nearestStation'] != null) ...[
                    _buildDetailRow('Estación más cercana', formattedInfo['nearestStation']['name']),
                    _buildDetailRow('Distancia', '${formattedInfo['nearestStation']['distance'].toStringAsFixed(0)}m'),
                  ],
                  if (formattedInfo['estimatedArrivalNext'] != null) ...[
                    _buildDetailRow('Próxima llegada', _formatEstimatedTime(formattedInfo['estimatedArrivalNext'])),
                  ],
                  if (formattedInfo['lastUpdated'] != null) ...[
                    _buildDetailRow('Última actualización', _formatLastUpdated(formattedInfo['lastUpdated'])),
                  ],
                ],
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Estación de partida
          _buildDetailCard(
            title: 'Estación de Partida',
            children: [
              _buildDetailRow('Nombre', widget.routeSuggestion.departureStation.displayName),
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
              _buildDetailRow('Nombre', widget.routeSuggestion.arrivalStation.displayName),
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
                  station.displayName,
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, color: color, size: 28),
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
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...details.map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            detail,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimaryButton,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _fitBounds() {
    if (_mapController == null || _markers.isEmpty) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    // Filtrar solo marcadores con coordenadas válidas (no 0.0, 0.0)
    final validMarkers = _markers.where((marker) {
      return marker.position.latitude != 0.0 && marker.position.longitude != 0.0;
    }).toList();

    if (validMarkers.isEmpty) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          const LatLng(22.1565, -100.9855), // San Luis Potosí centro
          12,
        ),
      );
      return;
    }

    for (final marker in validMarkers) {
      minLat = min(minLat, marker.position.latitude);
      maxLat = max(maxLat, marker.position.latitude);
      minLng = min(minLng, marker.position.longitude);
      maxLng = max(maxLng, marker.position.longitude);
    }

    // Verificar que las coordenadas son válidas
    if (minLat == double.infinity || maxLat == -double.infinity || 
        minLng == double.infinity || maxLng == -double.infinity) {
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

  String _formatEstimatedTime(String estimatedArrival) {
    try {
      final dateTime = DateTime.parse(estimatedArrival);
      final now = DateTime.now();
      final difference = dateTime.difference(now);
      
      if (difference.inMinutes < 1) {
        return 'Llegando...';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min';
      } else {
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        return '${hours}h ${minutes}min';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatLastUpdated(String lastUpdated) {
    try {
      final dateTime = DateTime.parse(lastUpdated);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'Hace un momento';
      } else if (difference.inMinutes < 60) {
        return 'Hace ${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return 'Hace ${difference.inHours}h';
      } else {
        return 'Hace ${difference.inDays} días';
      }
    } catch (e) {
      return 'N/A';
    }
  }
} 
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_suggestion_model.dart';
import '../themes/app_colors.dart';
import '../services/driver_tracking_service.dart';
import '../widgets/Home/bus_tracking_widget.dart';
import '../widgets/Home/station_eta_widget.dart';
import '../widgets/full_screen_map_modal.dart';
import 'navigation_screen.dart';

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
  Timer? _trackingTimer;
  Map<String, dynamic>? _currentTrackingInfo;
  LatLng? _lastDriverLocation;
  final StreamController<Set<Marker>> _markersStreamController = StreamController<Set<Marker>>.broadcast();
  DateTime? _lastLocationUpdate;
  int _consecutiveSameLocationCount = 0;
  bool _hasApiError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeMap();
    _startTrackingUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController?.dispose();
    _trackingTimer?.cancel();
    _markersStreamController.close();
    super.dispose();
  }

  void _initializeMap() {
    _markers = {};

    // Agregar marcadores base
    _markers.add(
      Marker(
        markerId: const MarkerId('departure_station'),
        position: LatLng(
          widget.routeSuggestion.departureStation.latitude,
          widget.routeSuggestion.departureStation.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Inicio',
          snippet: widget.routeSuggestion.departureStation.displayName,
        ),
      ),
    );

    // Agregar marcador de estación de llegada
    _markers.add(
      Marker(
        markerId: const MarkerId('arrival_station'),
        position: LatLng(
          widget.routeSuggestion.arrivalStation.latitude,
          widget.routeSuggestion.arrivalStation.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Fin',
          snippet: widget.destinationAddress,
        ),
      ),
    );

    // Agregar marcador de transbordo si existe
    if (widget.routeSuggestion.transbordo != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('transfer_station'),
          position: LatLng(
            widget.routeSuggestion.transbordo!.latitudOrigen,
            widget.routeSuggestion.transbordo!.longitudOrigen,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
          infoWindow: InfoWindow(
            title: 'Transbordo',
            snippet: '${widget.routeSuggestion.transbordo!.estacionOrigen} → ${widget.routeSuggestion.transbordo!.estacionDestino}',
          ),
        ),
      );
    }

    // --- POLILÍNEAS ---
    _polylines = {};

    if (widget.routeSuggestion.tipo == 'transbordo') {
      // --- RUTA CON TRANSBORDO ---

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

      // 2. Primera ruta en autobús (estación de partida -> estación de transbordo)
      if (widget.routeSuggestion.transbordo != null && widget.routeSuggestion.trayectos != null) {
        final firstRoutePoints = <LatLng>[];

        // Agregar estación de partida
        firstRoutePoints.add(LatLng(widget.routeSuggestion.departureStation.latitude, widget.routeSuggestion.departureStation.longitude));

        // Agregar todas las estaciones intermedias de la primera ruta
        for (final estacion in widget.routeSuggestion.trayectos!.primeraRuta.estaciones) {
          if (estacion.latitud != 0.0 && estacion.longitud != 0.0) {
            firstRoutePoints.add(LatLng(estacion.latitud, estacion.longitud));
          }
        }

        // Agregar estación de transbordo (origen)
        firstRoutePoints.add(LatLng(
          widget.routeSuggestion.transbordo!.latitudOrigen,
          widget.routeSuggestion.transbordo!.longitudOrigen,
        ));

        _polylines.add(
          Polyline(
            polylineId: const PolylineId('first_bus_route'),
            color: Colors.green,
            width: 6,
            points: firstRoutePoints,
          ),
        );
      }

      // 3. Trayecto caminando en transbordo (estación transbordo origen -> estación transbordo destino)
      if (widget.routeSuggestion.transbordo != null) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('transfer_walk'),
            color: Colors.purple,
            width: 4,
            patterns: [PatternItem.dash(15), PatternItem.gap(8)],
            points: [
              LatLng(widget.routeSuggestion.transbordo!.latitudOrigen, widget.routeSuggestion.transbordo!.longitudOrigen),
              LatLng(widget.routeSuggestion.transbordo!.latitudDestino, widget.routeSuggestion.transbordo!.longitudDestino),
            ],
          ),
        );
      }

      // 4. Segunda ruta en autobús (estación transbordo destino -> estación de llegada)
      if (widget.routeSuggestion.transbordo != null && widget.routeSuggestion.trayectos != null) {
        final secondRoutePoints = <LatLng>[];

        // Agregar estación de transbordo (destino)
        secondRoutePoints.add(LatLng(
          widget.routeSuggestion.transbordo!.latitudDestino,
          widget.routeSuggestion.transbordo!.longitudDestino,
        ));

        // Agregar todas las estaciones intermedias de la segunda ruta
        for (final estacion in widget.routeSuggestion.trayectos!.segundaRuta.estaciones) {
          if (estacion.latitud != 0.0 && estacion.longitud != 0.0) {
            secondRoutePoints.add(LatLng(estacion.latitud, estacion.longitud));
          }
        }

        // Agregar estación de llegada
        secondRoutePoints.add(LatLng(widget.routeSuggestion.arrivalStation.latitude, widget.routeSuggestion.arrivalStation.longitude));

        _polylines.add(
          Polyline(
            polylineId: const PolylineId('second_bus_route'),
            color: Colors.teal,
            width: 6,
            points: secondRoutePoints,
          ),
        );
      }

      // 5. Trayecto caminando final (estación de llegada -> destino)
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

    } else {
      // --- RUTA DIRECTA ---

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

      // Usar estaciones específicas del trayecto si están disponibles
      if (widget.routeSuggestion.trayecto != null) {
        // Usar las estaciones específicas de la API
        for (final estacion in widget.routeSuggestion.trayecto!.estaciones) {
          if (estacion.latitud != 0.0 && estacion.longitud != 0.0) {
            busRoutePoints.add(LatLng(estacion.latitud, estacion.longitud));
          }
        }
      } else {
        // Fallback: usar estaciones intermedias generales
        for (final station in widget.routeSuggestion.intermediateStations) {
          if (station.latitude != 0.0 && station.longitude != 0.0) {
            busRoutePoints.add(LatLng(station.latitude, station.longitude));
          }
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles de la Ruta',
          overflow: TextOverflow.ellipsis,
        ),
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
                  overflow: TextOverflow.ellipsis,
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
                      '${(widget.routeSuggestion.totalWalkingDistance / 1000).toStringAsFixed(1)}km caminando',
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
            subtitle: widget.routeSuggestion.departureStation.displayName,
            details: [
              if (widget.routeSuggestion.departureStation.distanceFromUser != null)
                'Distancia: ${widget.routeSuggestion.departureStation.distanceFromUser!.toStringAsFixed(0)} metros',
              if (widget.routeSuggestion.departureStation.walkingTimeMinutes != null)
                'Tiempo estimado: ${widget.routeSuggestion.departureStation.walkingTimeMinutes!.toStringAsFixed(1)} minutos',
              if (widget.routeSuggestion.departureStation.distanceFromUser == null && widget.routeSuggestion.departureStation.walkingTimeMinutes == null)
                'Información en proceso...',
            ],
            color: Colors.blue,
          ),
          
          const SizedBox(height: 16),
          
          // Sección 2: Tomar el autobús
          _buildInstructionCard(
            icon: Icons.directions_bus,
            title: widget.routeSuggestion.tipo == 'transbordo' ? 'Primera ruta' : 'Tomar el autobús',
            subtitle: widget.routeSuggestion.tipo == 'transbordo'
                ? (widget.routeSuggestion.primeraRuta ?? 'Ruta no especificada')
                : widget.routeSuggestion.routeName,
            details: [
              'Estaciones: ${widget.routeSuggestion.stationsCount} paradas',
              'Tiempo estimado: ${widget.routeSuggestion.estimatedBusTimeFormatted}',
            ],
            color: Colors.green,
          ),
          
          const SizedBox(height: 16),

          // Sección 3: Transbordo (solo si es un transbordo)
          if (widget.routeSuggestion.transbordo != null) ...[
            _buildInstructionCard(
              icon: Icons.swap_horiz,
              title: 'Transbordo',
              subtitle: '${widget.routeSuggestion.transbordo!.estacionOrigen} → ${widget.routeSuggestion.transbordo!.estacionDestino}',
              details: [
                'Distancia: ${widget.routeSuggestion.transbordo!.distanciaCaminando}',
                'Tiempo estimado: ${widget.routeSuggestion.transbordo!.tiempoCaminando}',
                'Segunda ruta: ${widget.routeSuggestion.segundaRuta ?? 'No especificada'}',
              ],
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
          ],

          // Sección 4: Caminar al destino
          _buildInstructionCard(
            icon: Icons.directions_walk,
            title: 'Caminar al destino',
            subtitle: widget.destinationAddress,
            details: [
              if (widget.routeSuggestion.arrivalStation.distanceToDestination != null)
                'Distancia: ${widget.routeSuggestion.arrivalStation.distanceToDestination!.toStringAsFixed(0)} metros',
              if (widget.routeSuggestion.arrivalStation.walkingTimeMinutes != null)
                'Tiempo estimado: ${widget.routeSuggestion.arrivalStation.walkingTimeMinutes!.toStringAsFixed(1)} minutos',
              if (widget.routeSuggestion.arrivalStation.distanceToDestination == null && widget.routeSuggestion.arrivalStation.walkingTimeMinutes == null)
                'Información en proceso...',
            ],
            color: Colors.orange,
          ),
          
          const SizedBox(height: 20),

        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 4),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: widget.routeSuggestion.tipo == 'transbordo' ? [
              // Leyenda para transbordos
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendDot(Colors.blue, isDashed: true),
                  const SizedBox(width: 4),
                  const Text('Camina', style: TextStyle(fontSize: 11)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendDot(Colors.green),
                  const SizedBox(width: 4),
                  const Text('1ª Ruta', style: TextStyle(fontSize: 11)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendDot(Colors.purple, isDashed: true),
                  const SizedBox(width: 4),
                  const Text('Transbordo', style: TextStyle(fontSize: 11)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendDot(Colors.teal),
                  const SizedBox(width: 4),
                  const Text('2ª Ruta', style: TextStyle(fontSize: 11)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendDot(Colors.orange, isDashed: true),
                  const SizedBox(width: 4),
                  const Text('Camina', style: TextStyle(fontSize: 11)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendDot(Colors.red),
                  const SizedBox(width: 4),
                  const Text('Estación', style: TextStyle(fontSize: 11)),
                ],
              ),
            ] : [
              // Leyenda para rutas directas
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendDot(Colors.blue, isDashed: true),
                  const SizedBox(width: 4),
                  const Text('Camina', style: TextStyle(fontSize: 11)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendDot(Colors.green),
                  const SizedBox(width: 4),
                  const Text('Autobús', style: TextStyle(fontSize: 11)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendDot(Colors.orange, isDashed: true),
                  const SizedBox(width: 4),
                  const Text('Camina', style: TextStyle(fontSize: 11)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendDot(Colors.red),
                  const SizedBox(width: 4),
                  const Text('Estación', style: TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
        // Widget de estado del conductor
        _buildDriverStatusWidget(),
        Expanded(
          child: Column(
            children: [
              // Mapa interactivo
              Container(
                height: 300,
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
                            (widget.userLatitude + widget.routeSuggestion.departureStation.latitude + widget.routeSuggestion.arrivalStation.latitude + widget.destinationLatitude) / 4,
                            (widget.userLongitude + widget.routeSuggestion.departureStation.longitude + widget.routeSuggestion.arrivalStation.longitude + widget.destinationLongitude) / 4,
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
                        zoomControlsEnabled: true,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                      ),
                ),
              ),
              
              // Sección de instrucciones y botón empezar
              Expanded(
                child: _buildMapInstructions(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapInstructions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de instrucciones
          Text(
            'Instrucciones de la ruta',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Lista de instrucciones
          Expanded(
            child: ListView(
              children: _buildRouteInstructions(),
            ),
          ),
          
          // Botón empezar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton.icon(
              onPressed: () => _startNavigation(),
              icon: const Icon(Icons.navigation, color: Colors.white),
              label: const Text(
                'Empezar navegación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimaryButton,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRouteInstructions() {
    List<Widget> instructions = [];
    
    // Instrucción inicial: caminar al punto de partida
    instructions.add(_buildInstructionStep(
      icon: Icons.directions_walk,
      iconColor: Colors.green,
      title: 'Caminar hasta la parada',
      subtitle: 'Ve hasta ${widget.routeSuggestion.subirEn.estacion}',
      distance: widget.routeSuggestion.subirEn.distanciaCaminando,
      time: widget.routeSuggestion.subirEn.tiempoCaminando,
      isCompleted: false,
    ));
    
    if (widget.routeSuggestion.tipo == 'transbordo') {
      // Ruta con transbordo
      instructions.add(_buildInstructionStep(
        icon: Icons.directions_bus,
        iconColor: Colors.blue,
        title: 'Tomar ${widget.routeSuggestion.primeraRuta}',
        subtitle: 'Dirección: ${widget.routeSuggestion.trayectos?.primeraRuta.direccion ?? "ida"}',
        distance: null,
        time: null,
        isCompleted: false,
      ));
      
      if (widget.routeSuggestion.transbordo != null) {
        instructions.add(_buildInstructionStep(
          icon: Icons.transfer_within_a_station,
          iconColor: Colors.orange,
          title: 'Transbordo',
          subtitle: 'De ${widget.routeSuggestion.transbordo!.estacionOrigen} a ${widget.routeSuggestion.transbordo!.estacionDestino}',
          distance: widget.routeSuggestion.transbordo!.distanciaCaminando,
          time: widget.routeSuggestion.transbordo!.tiempoCaminando,
          isCompleted: false,
        ));
      }
      
      instructions.add(_buildInstructionStep(
        icon: Icons.directions_bus,
        iconColor: Colors.blue,
        title: 'Tomar ${widget.routeSuggestion.segundaRuta}',
        subtitle: 'Dirección: ${widget.routeSuggestion.trayectos?.segundaRuta.direccion ?? "ida"}',
        distance: null,
        time: null,
        isCompleted: false,
      ));
    } else {
      // Ruta directa
      instructions.add(_buildInstructionStep(
        icon: Icons.directions_bus,
        iconColor: Colors.blue,
        title: 'Tomar ${widget.routeSuggestion.ruta}',
        subtitle: 'Dirección: ${widget.routeSuggestion.direction}',
        distance: null,
        time: widget.routeSuggestion.tiempoEnCamion,
        isCompleted: false,
      ));
    }
    
    // Instrucción final: caminar al destino
    instructions.add(_buildInstructionStep(
      icon: Icons.directions_walk,
      iconColor: Colors.green,
      title: 'Caminar hasta el destino',
      subtitle: 'Desde ${widget.routeSuggestion.bajarseEn.estacion}',
      distance: widget.routeSuggestion.bajarseEn.distanciaCaminando,
      time: widget.routeSuggestion.bajarseEn.tiempoCaminando,
      isCompleted: false,
    ));
    
    return instructions;
  }

  Widget _buildInstructionStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? distance,
    String? time,
    required bool isCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green.shade700 : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                if (distance != null || time != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (distance != null) ...[
                        Icon(Icons.straighten, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                      if (distance != null && time != null) ...[
                        const SizedBox(width: 8),
                        Text('•', style: TextStyle(color: Colors.grey.shade400)),
                        const SizedBox(width: 8),
                      ],
                      if (time != null) ...[
                        Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Estado
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 20,
            ),
        ],
      ),
    );
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
              _buildDetailRow('Tipo', widget.routeSuggestion.tipo == 'transbordo' ? 'Transbordo' : 'Ruta Directa'),
              _buildDetailRow('Descripción', widget.routeSuggestion.routeDescription),
              if (widget.routeSuggestion.tipo == 'transbordo') ...[
                _buildDetailRow('Primera ruta', widget.routeSuggestion.primeraRuta ?? 'No especificada'),
                _buildDetailRow('Segunda ruta', widget.routeSuggestion.segundaRuta ?? 'No especificada'),
              ],
              _buildDetailRow('Total de paradas', '${widget.routeSuggestion.stationsCount}'),
              _buildDetailRow('Puntuación', '${(widget.routeSuggestion.score * 100).toStringAsFixed(0)}%'),
            ],
          ),

          // Información de transbordo (si existe)
          if (widget.routeSuggestion.transbordo != null) ...[
            const SizedBox(height: 16),
            _buildDetailCard(
              title: 'Información del Transbordo',
              children: [
                _buildDetailRow('Estación origen', widget.routeSuggestion.transbordo!.estacionOrigen),
                _buildDetailRow('Estación destino', widget.routeSuggestion.transbordo!.estacionDestino),
                _buildDetailRow('Distancia caminando', widget.routeSuggestion.transbordo!.distanciaCaminando),
                _buildDetailRow('Tiempo caminando', widget.routeSuggestion.transbordo!.tiempoCaminando),
              ],
            ),
          ],
          
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
                    _buildDetailRow('Estación más cercana', 'Estación ${formattedInfo['nearestStation']['id']}'),
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
              if (widget.routeSuggestion.departureStation.distanceFromUser != null)
                _buildDetailRow('Distancia desde ti', '${widget.routeSuggestion.departureStation.distanceFromUser!.toStringAsFixed(0)} m'),
              if (widget.routeSuggestion.departureStation.walkingTimeMinutes != null)
                _buildDetailRow('Tiempo caminando', '${widget.routeSuggestion.departureStation.walkingTimeMinutes!.toStringAsFixed(1)} min'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Estación de llegada
          _buildDetailCard(
            title: 'Estación de Llegada',
            children: [
              _buildDetailRow('Nombre', widget.routeSuggestion.arrivalStation.displayName),
              _buildDetailRow('Orden', '${widget.routeSuggestion.arrivalStation.order}'),
              if (widget.routeSuggestion.arrivalStation.distanceToDestination != null)
                _buildDetailRow('Distancia al destino', '${widget.routeSuggestion.arrivalStation.distanceToDestination!.toStringAsFixed(0)} m'),
              if (widget.routeSuggestion.arrivalStation.walkingTimeMinutes != null)
                _buildDetailRow('Tiempo caminando', '${widget.routeSuggestion.arrivalStation.walkingTimeMinutes!.toStringAsFixed(1)} min'),
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
              _buildDetailRow('Distancia caminando', '${(widget.routeSuggestion.totalWalkingDistance / 1000).toStringAsFixed(1)} km'),
              _buildDetailRow('Total de paradas', '${widget.routeSuggestion.stationsCount}'),
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
                    overflow: TextOverflow.ellipsis,
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
              overflow: TextOverflow.ellipsis,
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
              overflow: TextOverflow.ellipsis,
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

  void _startTrackingUpdates() {
    // Actualizar inmediatamente
    _updateTrackingInfo();
    
    // Configurar actualización periódica cada 5 segundos
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _updateTrackingInfo();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _updateTrackingInfo() async {
    try {
      final trackingData = await DriverTrackingService.getDriverTrackingByRoute(widget.routeSuggestion.routeId);
      
      if (mounted) {
        setState(() {
          _hasApiError = false;
          _currentTrackingInfo = trackingData;
        });
        _processDriverLocation(trackingData);
      }
    } catch (e) {
      print('❌ Error actualizando tracking: $e');
      if (mounted) {
        setState(() {
          _hasApiError = true;
        });
      }
    }
  }

  void _processDriverLocation(Map<String, dynamic> trackingData) {
    print('🔍 _processDriverLocation called');
    print('🔍 trackingData: $trackingData');
    
    final activeDriver = trackingData['active_driver'];
    print('🔍 activeDriver from trackingData: $activeDriver');
    
    final hasActiveDriver = trackingData['has_active_driver'];
    print('🔍 has_active_driver from trackingData: $hasActiveDriver');
    
    if (activeDriver == null || hasActiveDriver != true) {
      print('❌ No active driver in trackingData');
      return;
    }

    final currentLocation = activeDriver['current_location'];
    if (currentLocation == null) return;

    final newLocation = LatLng(
      currentLocation['latitude'],
      currentLocation['longitude'],
    );

    // Verificar si la ubicación ha cambiado
    bool locationChanged = false;
    if (_lastDriverLocation == null) {
      locationChanged = true;
    } else {
      // Calcular distancia entre ubicaciones (en metros)
      final distance = _calculateDistance(_lastDriverLocation!, newLocation);
      locationChanged = distance > 5.0; // Cambio si se movió más de 5 metros
    }

    if (locationChanged) {
      _consecutiveSameLocationCount = 0;
      _lastLocationUpdate = DateTime.now();
    } else {
      _consecutiveSameLocationCount++;
    }

    _lastDriverLocation = newLocation;
    _updateMapMarkers();
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Radio de la Tierra en metros
    final double lat1Rad = point1.latitude * (pi / 180);
    final double lat2Rad = point2.latitude * (pi / 180);
    final double deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    final double deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  void _updateMapMarkers() {
    print('🔍 _updateMapMarkers called');
    print('🔍 _currentTrackingInfo: $_currentTrackingInfo');
    
    if (_currentTrackingInfo == null) {
      print('❌ _currentTrackingInfo is null');
      return;
    }
    
    final hasActiveDriver = _currentTrackingInfo!['has_active_driver'];
    print('🔍 has_active_driver: $hasActiveDriver');
    
    if (hasActiveDriver != true) {
      print('❌ No active driver');
      return;
    }

    final activeDriver = _currentTrackingInfo!['active_driver'];
    print('🔍 activeDriver: $activeDriver');
    
    if (activeDriver == null) {
      print('❌ activeDriver is null');
      return;
    }

    final currentLocation = activeDriver['current_location'];
    print('🔍 currentLocation: $currentLocation');
    
    if (currentLocation == null) {
      print('❌ currentLocation is null');
      return;
    }

    // Remover marcador anterior del autobús si existe
    _markers.removeWhere((marker) => marker.markerId.value == 'bus_location');
    
    // Determinar el color del marcador basado en el estado
    BitmapDescriptor markerIcon;
    String statusMessage = '';
    
    if (_hasApiError) {
      markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      statusMessage = 'Sin conexión - Posible batería agotada';
    } else if (_consecutiveSameLocationCount >= 6) { // 30 segundos sin movimiento
      markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      statusMessage = 'Conductor estacionado';
    } else {
      markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      statusMessage = 'En movimiento';
    }
    
    // Agregar nuevo marcador del autobús
    final newMarker = Marker(
      markerId: const MarkerId('bus_location'),
      position: LatLng(
        currentLocation['latitude'],
        currentLocation['longitude'],
      ),
      icon: markerIcon,
      infoWindow: InfoWindow(
        title: 'Autobús en ruta',
        snippet: '${activeDriver['driver_name']}\n$statusMessage',
      ),
    );
    
    _markers.add(newMarker);
    print('✅ Marcador agregado: ${newMarker.position}');
    print('✅ Total marcadores: ${_markers.length}');

    // Actualizar el mapa si está disponible
    print('✅ Actualizando mapa con setState');
    setState(() {
      // Esto forzará la actualización del mapa
    });
    
    // Enviar actualización al stream para el modal
    if (!_markersStreamController.isClosed) {
      _markersStreamController.add(Set<Marker>.from(_markers));
    }
  }

  Widget _buildDriverStatusWidget() {
    if (_currentTrackingInfo == null || _currentTrackingInfo!['has_active_driver'] != true) {
      return const SizedBox.shrink();
    }

    final activeDriver = _currentTrackingInfo!['active_driver'];
    if (activeDriver == null) return const SizedBox.shrink();

    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusSubtext = '';

    if (_hasApiError) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
      statusText = 'Sin conexión con el conductor';
      statusSubtext = 'Posible batería agotada o sin señal';
    } else if (_consecutiveSameLocationCount >= 6) {
      statusColor = Colors.amber;
      statusIcon = Icons.pause_circle_outline;
      statusText = 'Conductor estacionado';
      statusSubtext = 'El conductor no se ha movido en los últimos ${_consecutiveSameLocationCount * 5} segundos';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.directions_bus;
      statusText = 'Conductor en movimiento';
      statusSubtext = 'Ubicación actualizada hace ${_getTimeSinceLastUpdate()}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (statusSubtext.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    statusSubtext,
                    style: TextStyle(
                      color: statusColor.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeSinceLastUpdate() {
    if (_lastLocationUpdate == null) return '0 segundos';
    
    final now = DateTime.now();
    final difference = now.difference(_lastLocationUpdate!);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} segundos';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutos';
    } else {
      return '${difference.inHours} horas';
    }
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

  void _startNavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationScreen(
          routeSuggestion: widget.routeSuggestion,
          destinationAddress: widget.destinationAddress,
          userLatitude: widget.userLatitude,
          userLongitude: widget.userLongitude,
          destinationLatitude: widget.destinationLatitude,
          destinationLongitude: widget.destinationLongitude,
          initialMarkers: _markers,
          initialPolylines: _polylines,
        ),
      ),
    );
  }

} 
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_suggestion_model.dart';
import '../themes/app_colors.dart';
import '../services/location_service.dart';

class NavigationScreen extends StatefulWidget {
  final RouteSuggestionModel routeSuggestion;
  final String destinationAddress;
  final double userLatitude;
  final double userLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final Set<Marker> initialMarkers;
  final Set<Polyline> initialPolylines;

  const NavigationScreen({
    Key? key,
    required this.routeSuggestion,
    required this.destinationAddress,
    required this.userLatitude,
    required this.userLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.initialMarkers,
    required this.initialPolylines,
  }) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  int _currentStepIndex = 0;
  List<NavigationStep> _navigationSteps = [];
  Timer? _locationTimer;
  LatLng? _currentUserLocation;

  @override
  void initState() {
    super.initState();
    _markers = Set<Marker>.from(widget.initialMarkers);
    _polylines = Set<Polyline>.from(widget.initialPolylines);
    _buildNavigationSteps();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _buildNavigationSteps() {
    _navigationSteps = [];
    
    // Paso 1: Caminar hasta la parada
    _navigationSteps.add(NavigationStep(
      type: NavigationStepType.walk,
      icon: Icons.directions_walk,
      iconColor: Colors.green,
      title: 'Caminar hasta la parada',
      subtitle: 'Ve hasta ${widget.routeSuggestion.subirEn.estacion}',
      distance: widget.routeSuggestion.subirEn.distanciaCaminando,
      time: widget.routeSuggestion.subirEn.tiempoCaminando,
      location: LatLng(
        widget.routeSuggestion.subirEn.latitud ?? 0.0,
        widget.routeSuggestion.subirEn.longitud ?? 0.0,
      ),
    ));
    
    if (widget.routeSuggestion.tipo == 'transbordo') {
      // Ruta con transbordo
      _navigationSteps.add(NavigationStep(
        type: NavigationStepType.bus,
        icon: Icons.directions_bus,
        iconColor: Colors.blue,
        title: 'Tomar ${widget.routeSuggestion.primeraRuta}',
        subtitle: 'Dirección: ${widget.routeSuggestion.trayectos?.primeraRuta.direccion ?? "ida"}',
        distance: null,
        time: null,
        location: LatLng(
          widget.routeSuggestion.subirEn.latitud ?? 0.0,
          widget.routeSuggestion.subirEn.longitud ?? 0.0,
        ),
      ));
      
      if (widget.routeSuggestion.transbordo != null) {
        _navigationSteps.add(NavigationStep(
          type: NavigationStepType.transfer,
          icon: Icons.transfer_within_a_station,
          iconColor: Colors.orange,
          title: 'Transbordo',
          subtitle: 'De ${widget.routeSuggestion.transbordo!.estacionOrigen} a ${widget.routeSuggestion.transbordo!.estacionDestino}',
          distance: widget.routeSuggestion.transbordo!.distanciaCaminando,
          time: widget.routeSuggestion.transbordo!.tiempoCaminando,
          location: LatLng(
            widget.routeSuggestion.transbordo!.latitudOrigen,
            widget.routeSuggestion.transbordo!.longitudOrigen,
          ),
        ));
        
        _navigationSteps.add(NavigationStep(
          type: NavigationStepType.bus,
          icon: Icons.directions_bus,
          iconColor: Colors.blue,
          title: 'Tomar ${widget.routeSuggestion.segundaRuta}',
          subtitle: 'Dirección: ${widget.routeSuggestion.trayectos?.segundaRuta.direccion ?? "ida"}',
          distance: null,
          time: null,
          location: LatLng(
            widget.routeSuggestion.transbordo!.latitudDestino,
            widget.routeSuggestion.transbordo!.longitudDestino,
          ),
        ));
      }
    } else {
      // Ruta directa
      _navigationSteps.add(NavigationStep(
        type: NavigationStepType.bus,
        icon: Icons.directions_bus,
        iconColor: Colors.blue,
        title: 'Tomar ${widget.routeSuggestion.ruta}',
        subtitle: 'Dirección: ${widget.routeSuggestion.direction}',
        distance: null,
        time: widget.routeSuggestion.tiempoEnCamion,
        location: LatLng(
          widget.routeSuggestion.subirEn.latitud ?? 0.0,
          widget.routeSuggestion.subirEn.longitud ?? 0.0,
        ),
      ));
    }
    
    // Paso final: Caminar hasta el destino
    _navigationSteps.add(NavigationStep(
      type: NavigationStepType.walk,
      icon: Icons.directions_walk,
      iconColor: Colors.green,
      title: 'Caminar hasta el destino',
      subtitle: 'Desde ${widget.routeSuggestion.bajarseEn.estacion}',
      distance: widget.routeSuggestion.bajarseEn.distanciaCaminando,
      time: widget.routeSuggestion.bajarseEn.tiempoCaminando,
      location: LatLng(
        widget.destinationLatitude,
        widget.destinationLongitude,
      ),
    ));
  }

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final position = await LocationService.getCurrentLocation();
        if (position != null) {
          setState(() {
            _currentUserLocation = LatLng(position.latitude, position.longitude);
          });
          _updateUserLocationMarker();
          _checkStepProgress();
        }
      } catch (e) {
        print('Error obteniendo ubicación: $e');
      }
    });
  }

  void _updateUserLocationMarker() {
    if (_currentUserLocation == null) return;
    
    // Remover marcador anterior del usuario
    _markers.removeWhere((marker) => marker.markerId.value == 'user_current');
    
    // Agregar nuevo marcador del usuario
    _markers.add(Marker(
      markerId: const MarkerId('user_current'),
      position: _currentUserLocation!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(
        title: 'Tu ubicación',
        snippet: 'Ubicación actual',
      ),
    ));
    
    // Centrar mapa en la ubicación actual
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_currentUserLocation!),
    );
  }

  void _checkStepProgress() {
    if (_currentUserLocation == null || _currentStepIndex >= _navigationSteps.length) return;
    
    final currentStep = _navigationSteps[_currentStepIndex];
    final distance = _calculateDistance(_currentUserLocation!, currentStep.location);
    
    // Si está cerca del objetivo del paso actual (menos de 50 metros)
    if (distance < 50) {
      _completeCurrentStep();
    }
  }

  void _completeCurrentStep() {
    if (_currentStepIndex < _navigationSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      
      // Mostrar notificación del siguiente paso
      _showStepNotification();
    } else {
      // Navegación completada
      _completeNavigation();
    }
  }

  void _showStepNotification() {
    final nextStep = _navigationSteps[_currentStepIndex];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Siguiente: ${nextStep.title}'),
        backgroundColor: AppColors.lightPrimaryButton,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _completeNavigation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Navegación completada!'),
        content: const Text('Has llegado a tu destino.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.of(context).pop(); // Cerrar navegación
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
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
    final double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navegación'),
        backgroundColor: AppColors.lightPrimaryButton,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Finalizar navegación'),
                  content: const Text('¿Estás seguro de que quieres finalizar la navegación?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cerrar diálogo
                        Navigator.of(context).pop(); // Cerrar navegación
                      },
                      child: const Text('Finalizar'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mapa de navegación
          Expanded(
            flex: 3,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.userLatitude, widget.userLongitude),
                zoom: 16,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              tiltGesturesEnabled: true,
              rotateGesturesEnabled: true,
              mapType: MapType.normal,
            ),
          ),
          
          // Panel de instrucciones
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _buildNavigationPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationPanel() {
    if (_navigationSteps.isEmpty) return const SizedBox();
    
    final currentStep = _navigationSteps[_currentStepIndex];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Paso actual
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: currentStep.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  currentStep.icon,
                  color: currentStep.iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentStep.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentStep.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (currentStep.distance != null || currentStep.time != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (currentStep.distance != null) ...[
                            Icon(Icons.straighten, size: 16, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              currentStep.distance!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (currentStep.distance != null && currentStep.time != null) ...[
                            const SizedBox(width: 12),
                            Text('•', style: TextStyle(color: Colors.grey.shade400)),
                            const SizedBox(width: 12),
                          ],
                          if (currentStep.time != null) ...[
                            Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              currentStep.time!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress bar
          Row(
            children: [
              Text(
                'Paso ${_currentStepIndex + 1} de ${_navigationSteps.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Text(
                '${((_currentStepIndex / _navigationSteps.length) * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.lightPrimaryButton,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _currentStepIndex / _navigationSteps.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightPrimaryButton),
          ),
          
          const SizedBox(height: 20),
          
          // Botones de acción
          Row(
            children: [
              if (_currentStepIndex > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentStepIndex = (_currentStepIndex - 1).clamp(0, _navigationSteps.length - 1);
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Anterior'),
                  ),
                ),
              if (_currentStepIndex > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _completeCurrentStep,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: Text(
                    _currentStepIndex < _navigationSteps.length - 1 ? 'Siguiente' : 'Finalizar',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NavigationStep {
  final NavigationStepType type;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? distance;
  final String? time;
  final LatLng location;

  NavigationStep({
    required this.type,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.distance,
    this.time,
    required this.location,
  });
}

enum NavigationStepType {
  walk,
  bus,
  transfer,
}

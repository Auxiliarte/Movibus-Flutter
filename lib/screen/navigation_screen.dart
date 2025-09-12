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
  double _currentBearing = 0.0;
  bool _followBearing = true; // Seguir dirección del usuario por defecto

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
    // Obtener ubicación inicial inmediatamente
    _getCurrentLocation();
    
    // Actualizar ubicación cada 3 segundos para navegación en tiempo real
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _getCurrentLocation();
    });
  }

  void _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        final newLocation = LatLng(position.latitude, position.longitude);
        
        // Solo actualizar si la ubicación ha cambiado significativamente (más de 5 metros)
        if (_currentUserLocation == null || 
            _calculateDistance(_currentUserLocation!, newLocation) > 5) {
          
          // Calcular bearing (dirección hacia donde se mueve)
          if (_currentUserLocation != null) {
            _currentBearing = _calculateBearing(_currentUserLocation!, newLocation);
          }
          
          setState(() {
            _currentUserLocation = newLocation;
          });
          _updateUserLocationMarker();
          _checkStepProgress();
          _updateMapCamera();
        }
      }
    } catch (e) {
      print('Error obteniendo ubicación: $e');
    }
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final lat1Rad = start.latitude * (pi / 180);
    final lat2Rad = end.latitude * (pi / 180);
    final deltaLngRad = (end.longitude - start.longitude) * (pi / 180);
    
    final y = sin(deltaLngRad) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(deltaLngRad);
    
    final bearingRad = atan2(y, x);
    final bearingDeg = (bearingRad * (180 / pi) + 360) % 360;
    
    return bearingDeg;
  }

  void _updateMapCamera() {
    if (_currentUserLocation == null || _mapController == null) return;
    
    // Seguir al usuario con la cámara
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentUserLocation!,
          zoom: 17, // Zoom más cercano para navegación
          bearing: _followBearing ? _currentBearing : 0, // Orientar según preferencia del usuario
          tilt: _followBearing ? 45 : 0, // Vista 3D solo cuando sigue bearing
        ),
      ),
    );
  }

  void _updateUserLocationMarker() {
    if (_currentUserLocation == null) return;
    
    // Remover marcador anterior del usuario
    _markers.removeWhere((marker) => marker.markerId.value == 'user_current');
    
    // Agregar nuevo marcador del usuario con icono distintivo para navegación
    _markers.add(Marker(
      markerId: const MarkerId('user_current'),
      position: _currentUserLocation!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(
        title: '📍 Tu ubicación actual',
        snippet: 'Navegando - Paso ${_currentStepIndex + 1} de ${_navigationSteps.length}',
      ),
    ));
    
    setState(() {
      // Actualizar markers en el estado
    });
  }

  void _checkStepProgress() {
    if (_currentUserLocation == null || _currentStepIndex >= _navigationSteps.length) return;
    
    final currentStep = _navigationSteps[_currentStepIndex];
    final distance = _calculateDistance(_currentUserLocation!, currentStep.location);
    
    // Diferentes distancias según el tipo de paso
    double thresholdDistance = 50; // Default: 50 metros
    
    switch (currentStep.type) {
      case NavigationStepType.walk:
        thresholdDistance = 30; // 30 metros para caminar
        break;
      case NavigationStepType.bus:
        thresholdDistance = 100; // 100 metros para estaciones de autobús
        break;
      case NavigationStepType.transfer:
        thresholdDistance = 50; // 50 metros para transbordos
        break;
    }
    
    // Si está cerca del objetivo del paso actual
    if (distance < thresholdDistance) {
      _showArrivalNotification(currentStep, distance);
      _completeCurrentStep();
    } else if (distance < thresholdDistance * 2) {
      // Notificación de proximidad (cuando está cerca pero no ha llegado)
      _showProximityNotification(currentStep, distance);
    }
  }

  void _showArrivalNotification(NavigationStep step, double distance) {
    String message = '';
    switch (step.type) {
      case NavigationStepType.walk:
        message = '¡Has llegado! Ahora ${step.title.toLowerCase()}';
        break;
      case NavigationStepType.bus:
        message = '¡Estación alcanzada! ${step.title}';
        break;
      case NavigationStepType.transfer:
        message = '¡Punto de transbordo alcanzado!';
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  int _lastNotifiedStep = -1;
  
  void _showProximityNotification(NavigationStep step, double distance) {
    // Evitar spam de notificaciones - solo mostrar una vez por paso
    if (_lastNotifiedStep == _currentStepIndex) return;
    _lastNotifiedStep = _currentStepIndex;
    
    String message = 'Te acercas a tu destino (${distance.round()}m)';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.near_me, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.lightPrimaryButton,
        duration: const Duration(seconds: 2),
      ),
    );
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
      body: SafeArea(
        child: Column(
          children: [
            // Mapa de navegación
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  GoogleMap(
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
                  
                  // Botón para alternar modo de navegación
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: _followBearing ? AppColors.lightPrimaryButton : Colors.white,
                      foregroundColor: _followBearing ? Colors.white : AppColors.lightPrimaryButton,
                      elevation: 4,
                      onPressed: () {
                        setState(() {
                          _followBearing = !_followBearing;
                        });
                        _updateMapCamera();
                      },
                      tooltip: _followBearing ? 'Vista norte arriba' : 'Seguir dirección',
                      child: Icon(
                        _followBearing ? Icons.navigation : Icons.north,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Panel de instrucciones
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4, // Máximo 40% de la pantalla
                minHeight: 200, // Mínimo para mostrar información básica
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: _buildNavigationPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationPanel() {
    if (_navigationSteps.isEmpty) return const SizedBox();
    
    final currentStep = _navigationSteps[_currentStepIndex];
    final distanceToTarget = _currentUserLocation != null 
        ? _calculateDistance(_currentUserLocation!, currentStep.location)
        : 0.0;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de distancia en tiempo real
          if (_currentUserLocation != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightPrimaryButton.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.navigation, size: 16, color: AppColors.lightPrimaryButton),
                  const SizedBox(width: 6),
                  Text(
                    '${distanceToTarget.round()}m restantes',
                    style: TextStyle(
                      color: AppColors.lightPrimaryButton,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Paso actual
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: currentStep.iconColor.withValues(alpha: 0.1),
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
          
          const SizedBox(height: 16),
          
          // Próximo paso (si existe)
          if (_currentStepIndex < _navigationSteps.length - 1) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    _navigationSteps[_currentStepIndex + 1].icon,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Después:',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _navigationSteps[_currentStepIndex + 1].title,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                    ),
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

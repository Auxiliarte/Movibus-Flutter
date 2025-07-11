import 'package:flutter/material.dart';
import '../services/location_api_service.dart';
import '../services/location_service.dart';
import '../widgets/Home/nearest_station_widget.dart';
import '../widgets/Home/route_suggestions_widget.dart';
import '../widgets/location_permission_test.dart';

class LocationTestScreen extends StatefulWidget {
  const LocationTestScreen({super.key});

  @override
  State<LocationTestScreen> createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  Map<String, dynamic>? allRoutesData;
  Map<String, dynamic>? trackingData;
  bool isLoadingRoutes = false;
  bool isLoadingTracking = false;
  String? error;
  


  @override
  void initState() {
    super.initState();
    _loadAllRoutes();
  }

  Future<void> _loadAllRoutes() async {
    setState(() {
      isLoadingRoutes = true;
      error = null;
    });

    try {
      final result = await LocationApiService.getAllRoutes();
      setState(() {
        allRoutesData = result;
        isLoadingRoutes = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoadingRoutes = false;
      });
    }
  }

  Future<void> _loadTrackingInfo(int routeId) async {
    setState(() {
      isLoadingTracking = true;
      error = null;
    });

    try {
      final result = await LocationApiService.getTrackingInfo(routeId);
      setState(() {
        trackingData = result;
        isLoadingTracking = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoadingTracking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de API de Ubicación'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Widget de test de permisos
          const LocationPermissionTest(),
          
          const SizedBox(height: 20),
          
          // Widget de estación más cercana
          const NearestStationWidget(),
          
          const SizedBox(height: 20),
          
          // Widget de rutas sugeridas con coordenadas de ejemplo
          RouteSuggestionsWidget(
            destinationAddress: 'Centro de San Luis Potosí',
            destinationLatitude: 22.1540,
            destinationLongitude: -100.9715,
          ),
          
          const SizedBox(height: 20),
          
          // Sección de todas las rutas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Todas las Rutas',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: isLoadingRoutes ? null : _loadAllRoutes,
                        child: isLoadingRoutes
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Actualizar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isLoadingRoutes)
                    const Center(child: CircularProgressIndicator())
                  else if (error != null)
                    Text('Error: $error', style: const TextStyle(color: Colors.red))
                  else if (allRoutesData != null)
                    _buildRoutesList()
                  else
                    const Text('Presiona "Actualizar" para cargar las rutas'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Sección de tracking
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de Tracking',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isLoadingTracking)
                    const Center(child: CircularProgressIndicator())
                  else if (trackingData != null)
                    _buildTrackingInfo()
                  else
                    const Text('Selecciona una ruta para ver el tracking'),
                  const SizedBox(height: 16),
                  if (allRoutesData != null && allRoutesData!['data'] != null)
                    _buildTrackingButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesList() {
    final routes = allRoutesData!['data'] as List;
    
    return Column(
      children: routes.map((route) {
        return ListTile(
          title: Text(route['name']),
          subtitle: Text(route['description'] ?? 'Sin descripción'),
          trailing: Text('${route['total_stations']} paradas'),
          onTap: () => _loadTrackingInfo(route['id']),
        );
      }).toList(),
    );
  }

  Widget _buildTrackingInfo() {
    final data = trackingData!['data'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ruta: ${data['route_name']}'),
        const SizedBox(height: 8),
        Text('Estación actual: ${data['current_station']}'),
        const SizedBox(height: 4),
        Text('Próxima estación: ${data['next_station']}'),
        const SizedBox(height: 4),
        Text('Llegada estimada: ${data['estimated_arrival']}'),
        const SizedBox(height: 4),
        Text('Buses asignados: ${data['buses_assigned']}'),
        const SizedBox(height: 4),
        Text('Conductores asignados: ${data['drivers_assigned']}'),
        const SizedBox(height: 4),
        Text('Estado: ${data['status']}'),
        const SizedBox(height: 4),
        Text('Última actualización: ${data['last_updated']}'),
      ],
    );
  }

  Widget _buildTrackingButtons() {
    final routes = allRoutesData!['data'] as List;
    
    return Wrap(
      spacing: 8,
      children: routes.take(3).map((route) {
        return ElevatedButton(
          onPressed: () => _loadTrackingInfo(route['id']),
          child: Text('Ruta ${route['id']}'),
        );
      }).toList(),
    );
  }
} 
import 'package:flutter/material.dart';
import '../../services/location_api_service.dart';
import '../../services/location_service.dart';
import '../../models/station_model.dart';
import 'package:geolocator/geolocator.dart';

class NearestStationWidget extends StatefulWidget {
  final double? userLatitude;
  final double? userLongitude;
  final String? userAddress;

  const NearestStationWidget({
    super.key,
    this.userLatitude,
    this.userLongitude,
    this.userAddress,
  });

  @override
  _NearestStationWidgetState createState() => _NearestStationWidgetState();
}

class _NearestStationWidgetState extends State<NearestStationWidget> {
  Map<String, dynamic>? nearestStationData;
  bool isLoading = false;
  String? error;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Auto-buscar si tenemos coordenadas del usuario
    if (widget.userLatitude != null && widget.userLongitude != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        findNearestStation();
      });
    }
  }

  @override
  void didUpdateWidget(NearestStationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si las coordenadas del usuario cambiaron, buscar nueva estación
    if ((widget.userLatitude != oldWidget.userLatitude || 
         widget.userLongitude != oldWidget.userLongitude) &&
        widget.userLatitude != null && widget.userLongitude != null) {
      findNearestStation();
    }
  }

  Future<void> findNearestStation() async {
    setState(() {
      isLoading = true;
      error = null;
      _hasSearched = true;
    });

    try {
      double latitude, longitude;
      
      // Usar coordenadas del widget si están disponibles, sino obtener ubicación actual
      if (widget.userLatitude != null && widget.userLongitude != null) {
        latitude = widget.userLatitude!;
        longitude = widget.userLongitude!;
      } else {
        // Intentar obtener ubicación con el nuevo método
        final position = await _getLocationWithPermissionRequest();
        if (position == null) {
          throw Exception('No se pudo obtener la ubicación actual');
        }
        latitude = position.latitude;
        longitude = position.longitude;
      }

      // Buscar estación más cercana
      final result = await LocationApiService.findNearestStation(
        latitude: latitude,
        longitude: longitude,
      );

      setState(() {
        nearestStationData = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = _formatErrorMessage(e.toString());
        isLoading = false;
      });
    }
  }

  Future<Position?> _getLocationWithPermissionRequest() async {
    try {
      // Usar directamente el método getCurrentLocation que ya maneja los permisos
      return await LocationService.getCurrentLocation();
    } catch (e) {
      print('Error en _getLocationWithPermissionRequest: $e');
      rethrow;
    }
  }

  String _formatErrorMessage(String error) {
    if (error.contains('Permisos de ubicación denegados')) {
      return 'Para usar esta función, necesitas permitir el acceso a tu ubicación.\n\nVe a Configuración > Privacidad y Seguridad > Ubicación > Moventra y selecciona "Mientras usas la app".';
    } else if (error.contains('servicios de ubicación están deshabilitados')) {
      return 'Los servicios de ubicación están deshabilitados en tu dispositivo.\n\nVe a Configuración > Privacidad y Seguridad > Ubicación y habilita "Servicios de ubicación".';
    } else if (error.contains('timeout')) {
      return 'Tiempo de espera agotado al obtener la ubicación.\n\nVerifica que el GPS esté habilitado y que tengas buena señal.';
    } else {
      return error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Parada Más Cercana',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : findNearestStation,
                  icon: isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh, size: 16),
                  label: Text(isLoading ? 'Buscando...' : 'Actualizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            
            // Mostrar ubicación del usuario si está disponible
            if (widget.userAddress != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_pin,
                      color: theme.colorScheme.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Desde: ${widget.userAddress}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            if (isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Buscando estación más cercana...'),
                  ],
                ),
              )
            else if (error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Error al buscar estación',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error!,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (error!.contains('Configuración')) ...[
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await LocationService.openAppSettings();
                        },
                        icon: const Icon(Icons.settings, size: 16),
                        label: const Text('Abrir Configuración'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            else if (nearestStationData != null)
              _buildStationInfo()
            else if (_hasSearched)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No se encontró una estación cercana. Intenta con otra ubicación.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estación más cercana',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Presiona "Actualizar" para encontrar la parada más cercana a tu ubicación',
                            style: theme.textTheme.bodySmall,
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
    );
  }

  Widget _buildStationInfo() {
    final theme = Theme.of(context);
    final data = nearestStationData!['data'];
    final station = data['nearest_station'];
    final route = data['route'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
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
                      'Estación ${station['id']}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.route,
                    color: theme.colorScheme.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      route['name'] ?? 'Ruta sin nombre',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.straighten,
                    color: theme.colorScheme.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${station['distance_meters']?.toStringAsFixed(0) ?? '0'} metros',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.stop_circle,
                    color: theme.colorScheme.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${route['total_stations']} paradas en total',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
} 
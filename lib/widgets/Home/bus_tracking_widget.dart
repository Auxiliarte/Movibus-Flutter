import 'package:flutter/material.dart';
import '../../services/driver_tracking_service.dart';
import '../../themes/app_colors.dart';

class BusTrackingWidget extends StatefulWidget {
  final int routeId;
  final String routeName;

  const BusTrackingWidget({
    super.key,
    required this.routeId,
    required this.routeName,
  });

  @override
  State<BusTrackingWidget> createState() => _BusTrackingWidgetState();
}

class _BusTrackingWidgetState extends State<BusTrackingWidget> {
  Map<String, dynamic>? _trackingInfo;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTrackingInfo();
    // Actualizar cada 30 segundos
    _startPeriodicUpdate();
  }

  void _startPeriodicUpdate() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadTrackingInfo();
        _startPeriodicUpdate();
      }
    });
  }

  Future<void> _loadTrackingInfo() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final trackingData = await DriverTrackingService.getDriverTrackingByRoute(widget.routeId);
      final formattedInfo = DriverTrackingService.formatTrackingInfo(trackingData);

      setState(() {
        _trackingInfo = formattedInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('❌ Error cargando tracking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_hasError) {
      return _buildErrorCard();
    }

    if (_trackingInfo == null || !_trackingInfo!['hasActiveDriver']) {
      return _buildNoBusCard();
    }

    return _buildTrackingCard();
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightPrimaryButton),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buscando autobús...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Actualizando información en tiempo real',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
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

  Widget _buildErrorCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red[50],
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[700],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error de conexión',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                  Text(
                    'No se pudo obtener información del autobús',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadTrackingInfo,
              icon: const Icon(Icons.refresh),
              color: Colors.red[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoBusCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange[50],
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.directions_bus_outlined,
              color: Colors.orange[700],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sin autobús activo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                  Text(
                    _trackingInfo?['message'] ?? 'No hay autobús en esta ruta actualmente',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _loadTrackingInfo,
              icon: const Icon(Icons.refresh),
              color: Colors.orange[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingCard() {
    final info = _trackingInfo!;
    final currentLocation = info['currentLocation'];
    final nearestStation = info['nearestStation'];
    final estimatedArrival = info['estimatedArrivalNext'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.green[50],
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del chofer
            Row(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: Colors.green[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Autobús en ruta',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        'Chofer: ${info['driverName']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    info['status'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Información de ubicación actual
            if (currentLocation != null) ...[
              _buildInfoRow(
                icon: Icons.location_on,
                title: 'Ubicación actual',
                subtitle: '${currentLocation['latitude'].toStringAsFixed(4)}, ${currentLocation['longitude'].toStringAsFixed(4)}',
                color: Colors.blue[700]!,
              ),
              const SizedBox(height: 8),
            ],

            // Estación más cercana
            if (nearestStation != null) ...[
              _buildInfoRow(
                icon: Icons.place,
                title: 'Estación más cercana',
                subtitle: '${nearestStation['name']} (${nearestStation['distance'].toStringAsFixed(0)}m)',
                color: Colors.purple[700]!,
              ),
              const SizedBox(height: 8),
            ],

            // Tiempo estimado de llegada
            if (estimatedArrival != null) ...[
              _buildInfoRow(
                icon: Icons.access_time,
                title: 'Próxima llegada',
                subtitle: _formatEstimatedTime(estimatedArrival),
                color: Colors.orange[700]!,
              ),
              const SizedBox(height: 8),
            ],

            // Última actualización
            if (info['lastUpdated'] != null) ...[
              _buildInfoRow(
                icon: Icons.update,
                title: 'Última actualización',
                subtitle: _formatLastUpdated(info['lastUpdated']),
                color: Colors.grey[700]!,
              ),
            ],

            const SizedBox(height: 12),
            
            // Botón de actualizar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _loadTrackingInfo,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Actualizar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
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
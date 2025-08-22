import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class StationETAWidget extends StatelessWidget {
  final String stationName;
  final String estimatedTime;
  final bool isCurrentStation;
  final bool isNextStation;
  final VoidCallback? onTap;

  const StationETAWidget({
    super.key,
    required this.stationName,
    required this.estimatedTime,
    this.isCurrentStation = false,
    this.isNextStation = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getBorderColor(),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icono de estación
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getStationIcon(),
                  color: _getIconColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Información de la estación
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stationName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(),
                      ),
                    ),
                    if (isCurrentStation || isNextStation) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusBackgroundColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isCurrentStation ? 'ESTACIÓN ACTUAL' : 'PRÓXIMA',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getStatusTextColor(),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Tiempo estimado
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    estimatedTime,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _getTimeColor(),
                    ),
                  ),
                  Text(
                    'Tiempo estimado',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCardColor() {
    if (isCurrentStation) {
      return Colors.green[50]!;
    } else if (isNextStation) {
      return Colors.blue[50]!;
    } else {
      return Colors.white;
    }
  }

  Color _getIconBackgroundColor() {
    if (isCurrentStation) {
      return Colors.green[100]!;
    } else if (isNextStation) {
      return Colors.blue[100]!;
    } else {
      return Colors.grey[100]!;
    }
  }

  Color _getIconColor() {
    if (isCurrentStation) {
      return Colors.green[700]!;
    } else if (isNextStation) {
      return Colors.blue[700]!;
    } else {
      return Colors.grey[600]!;
    }
  }

  IconData _getStationIcon() {
    if (isCurrentStation) {
      return Icons.location_on;
    } else if (isNextStation) {
      return Icons.navigation;
    } else {
      return Icons.place;
    }
  }

  Color _getTextColor() {
    if (isCurrentStation) {
      return Colors.green[800]!;
    } else if (isNextStation) {
      return Colors.blue[800]!;
    } else {
      return Colors.black87;
    }
  }

  Color _getStatusBackgroundColor() {
    if (isCurrentStation) {
      return Colors.green[200]!;
    } else if (isNextStation) {
      return Colors.blue[200]!;
    } else {
      return Colors.grey[200]!;
    }
  }

  Color _getStatusTextColor() {
    if (isCurrentStation) {
      return Colors.green[800]!;
    } else if (isNextStation) {
      return Colors.blue[800]!;
    } else {
      return Colors.grey[600]!;
    }
  }

  Color _getTimeColor() {
    if (isCurrentStation) {
      return Colors.green[700]!;
    } else if (isNextStation) {
      return Colors.blue[700]!;
    } else {
      return AppColors.lightPrimaryButton;
    }
  }

  Color _getBorderColor() {
    if (isCurrentStation) {
      return Colors.green[200]!;
    } else if (isNextStation) {
      return Colors.blue[200]!;
    } else {
      return Colors.grey[200]!;
    }
  }
}

class StationListWithETA extends StatefulWidget {
  final List<Map<String, dynamic>> stations;
  final Map<String, dynamic>? trackingInfo;
  final bool isLoading;

  const StationListWithETA({
    super.key,
    required this.stations,
    this.trackingInfo,
    this.isLoading = false,
  });

  @override
  State<StationListWithETA> createState() => _StationListWithETAState();
}

class _StationListWithETAState extends State<StationListWithETA> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingStations();
    }

    if (widget.stations.isEmpty) {
      return _buildEmptyStations();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Paradas de la ruta',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...widget.stations.asMap().entries.map((entry) {
          final index = entry.key;
          final station = entry.value;
          final isCurrentStation = _isCurrentStation(station);
          final isNextStation = _isNextStation(station);
          final estimatedTime = _getEstimatedTimeForStation(station);

          return StationETAWidget(
            stationName: 'Estación ${station['id']}',
            estimatedTime: estimatedTime,
            isCurrentStation: isCurrentStation,
            isNextStation: isNextStation,
            onTap: () => _onStationTap(station),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLoadingStations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Paradas de la ruta',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...List.generate(3, (index) => _buildLoadingStation()),
      ],
    );
  }

  Widget _buildLoadingStation() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 16,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStations() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.place_outlined,
                  size: 40,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay estaciones disponibles',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta ruta no tiene estaciones configuradas',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isCurrentStation(Map<String, dynamic> station) {
    if (widget.trackingInfo == null || !widget.trackingInfo!['hasActiveDriver']) {
      return false;
    }

    final nearestStation = widget.trackingInfo!['nearestStation'];
    return nearestStation != null && nearestStation['station_id'] == station['id'];
  }

  bool _isNextStation(Map<String, dynamic> station) {
    if (widget.trackingInfo == null || !widget.trackingInfo!['hasActiveDriver']) {
      return false;
    }

    final nearestStation = widget.trackingInfo!['nearestStation'];
    if (nearestStation == null) return false;

    final currentOrder = nearestStation['order'];
    final stationOrder = station['order'];

    // La siguiente estación es la que tiene order + 1
    return stationOrder == currentOrder + 1;
  }

  String _getEstimatedTimeForStation(Map<String, dynamic> station) {
    if (widget.trackingInfo == null || !widget.trackingInfo!['hasActiveDriver']) {
      return 'N/A';
    }

    final currentLocation = widget.trackingInfo!['currentLocation'];
    final nearestStation = widget.trackingInfo!['nearestStation'];
    
    if (currentLocation == null || nearestStation == null) {
      return 'N/A';
    }

    // Si es la estación actual
    if (_isCurrentStation(station)) {
      return 'Llegando...';
    }

    // Si es la siguiente estación
    if (_isNextStation(station)) {
      final estimatedArrival = widget.trackingInfo!['estimatedArrivalNext'];
      if (estimatedArrival != null) {
        return _formatEstimatedTime(estimatedArrival);
      }
    }

    // Para otras estaciones, calcular basándose en la distancia
    final currentOrder = nearestStation['order'];
    final stationOrder = station['order'];
    final stationsDifference = (stationOrder - currentOrder).abs();
    
    // Estimación: 3 minutos por estación
    final estimatedMinutes = stationsDifference * 3;
    
    if (estimatedMinutes < 60) {
      return '${estimatedMinutes} min';
    } else {
      final hours = estimatedMinutes ~/ 60;
      final minutes = estimatedMinutes % 60;
      return '${hours}h ${minutes}min';
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

  void _onStationTap(Map<String, dynamic> station) {
    // Aquí puedes agregar lógica para mostrar más detalles de la estación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estación: ${station['id']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 
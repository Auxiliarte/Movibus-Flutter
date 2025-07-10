import 'package:flutter/material.dart';
import '../../services/location_api_service.dart';
import '../../services/location_service.dart';
import '../../models/route_suggestion_model.dart';

class RouteSuggestionsWidget extends StatefulWidget {
  final String? destinationAddress;
  final double? destinationLatitude;
  final double? destinationLongitude;

  const RouteSuggestionsWidget({
    super.key,
    this.destinationAddress,
    this.destinationLatitude,
    this.destinationLongitude,
  });

  @override
  _RouteSuggestionsWidgetState createState() => _RouteSuggestionsWidgetState();
}

class _RouteSuggestionsWidgetState extends State<RouteSuggestionsWidget> {
  List<RouteSuggestionModel>? routeSuggestions;
  bool isLoading = false;
  String? error;

  Future<void> findRouteSuggestions() async {
    if (widget.destinationLatitude == null || widget.destinationLongitude == null) {
      setState(() {
        error = 'Destino no especificado';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Obtener ubicación actual
      final position = await LocationService.getCurrentLocation();
      
      if (position != null) {
        // Buscar sugerencias de rutas
        final result = await LocationApiService.suggestRoute(
          userLatitude: position.latitude,
          userLongitude: position.longitude,
          destinationLatitude: widget.destinationLatitude!,
          destinationLongitude: widget.destinationLongitude!,
          maxWalkingDistance: 1500, // 1.5 km máximo caminando
        );

        if (result['status'] == 'success') {
          final suggestions = (result['data']['all_suggestions'] as List)
              .map((suggestion) => RouteSuggestionModel.fromJson(suggestion))
              .toList();

          setState(() {
            routeSuggestions = suggestions;
            isLoading = false;
          });
        } else {
          setState(() {
            error = result['message'] ?? 'Error al obtener sugerencias';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-buscar sugerencias si tenemos destino
    if (widget.destinationLatitude != null && widget.destinationLongitude != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        findRouteSuggestions();
      });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.route,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rutas Sugeridas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (widget.destinationLatitude != null && widget.destinationLongitude != null)
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : findRouteSuggestions,
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
            if (widget.destinationAddress != null) ...[
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
                      Icons.location_on,
                      color: theme.colorScheme.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Destino: ${widget.destinationAddress}',
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
                    Text('Buscando rutas sugeridas...'),
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
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error: $error',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              )
            else if (routeSuggestions != null && routeSuggestions!.isNotEmpty)
              _buildSuggestionsList()
            else if (routeSuggestions != null && routeSuggestions!.isEmpty)
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
                        'No se encontraron rutas sugeridas para este destino',
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
                      child: Text(
                        'Especifica un destino para ver rutas sugeridas',
                        style: theme.textTheme.bodyMedium,
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

  Widget _buildSuggestionsList() {
    return Column(
      children: routeSuggestions!.take(3).map((suggestion) {
        return _buildSuggestionCard(suggestion);
      }).toList(),
    );
  }

  Widget _buildSuggestionCard(RouteSuggestionModel suggestion) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  suggestion.routeName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${suggestion.score.toStringAsFixed(1)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.departure_board,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion.departureStation.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: theme.colorScheme.secondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion.arrivalStation.name,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: theme.colorScheme.secondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${suggestion.estimatedBusTimeFormatted} en bus',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.directions_walk,
                color: theme.colorScheme.secondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${suggestion.totalWalkingDistance.toStringAsFixed(0)}m caminando',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: theme.colorScheme.secondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Total: ${suggestion.estimatedTotalTime.toStringAsFixed(1)} min',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implementar ver detalles de la ruta
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Detalles'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implementar seleccionar esta ruta
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Seleccionar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
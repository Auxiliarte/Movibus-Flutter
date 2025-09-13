import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/region_model.dart';
import '../services/region_service.dart';
import '../services/location_service.dart';
import '../themes/app_colors.dart';

class SmartRegionDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRegionChanged;
  final bool autoDetect;

  const SmartRegionDetector({
    super.key,
    required this.child,
    this.onRegionChanged,
    this.autoDetect = true,
  });

  @override
  State<SmartRegionDetector> createState() => _SmartRegionDetectorState();
}

class _SmartRegionDetectorState extends State<SmartRegionDetector> {
  RegionModel? _suggestedRegion;
  bool _isDetecting = false;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoDetect) {
      _detectCurrentRegion();
    }
  }

  Future<void> _detectCurrentRegion() async {
    if (_isDetecting || _isDismissed) return;

    setState(() {
      _isDetecting = true;
    });

    try {
      final position = await LocationService.getCurrentLocation(
        autoSuggestRegionChange: false, // Evitar duplicar logs
      );

      if (position != null && mounted) {
        final suggestedRegion = RegionService.suggestRegionChange(
          position.latitude,
          position.longitude,
        );

        if (suggestedRegion != null && mounted) {
          setState(() {
            _suggestedRegion = suggestedRegion;
          });
        }
      }
    } catch (e) {
      print('❌ Error detectando región: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner de sugerencia de región
        if (_suggestedRegion != null && !_isDismissed) 
          _buildRegionSuggestionBanner(),
        
        // Contenido principal
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildRegionSuggestionBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withOpacity(0.1),
                AppColors.primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con icono y título
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.location_city,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🌍 ¿Estás en ${_suggestedRegion!.displayName}?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Detectamos que podrías estar en ${_suggestedRegion!.displayName}, ${_suggestedRegion!.country}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _dismiss,
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información adicional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cambiar tu región mejorará los resultados de búsqueda de lugares y rutas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _dismiss,
                    child: Text(
                      'Ahora no',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _changeRegion,
                    icon: const Icon(Icons.location_on, size: 18),
                    label: const Text('Cambiar región'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  void _dismiss() {
    setState(() {
      _isDismissed = true;
    });
  }

  Future<void> _changeRegion() async {
    if (_suggestedRegion == null) return;

    try {
      final success = await RegionService.changeRegion(_suggestedRegion!);
      
      if (success && mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Región cambiada a ${_suggestedRegion!.displayName}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Ver configuración',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/regionSettings');
              },
            ),
          ),
        );

        // Notificar al padre
        widget.onRegionChanged?.call();

        // Ocultar el banner
        setState(() {
          _isDismissed = true;
        });
      } else if (mounted) {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Error al cambiar región'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Método público para forzar detección
  void detectRegion() {
    _detectCurrentRegion();
  }

  // Método público para resetear el estado
  void reset() {
    setState(() {
      _isDismissed = false;
      _suggestedRegion = null;
    });
  }
}

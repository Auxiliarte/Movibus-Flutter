import 'package:flutter/material.dart';
import '../models/region_model.dart';
import '../services/region_service.dart';
import '../themes/app_colors.dart';

class RegionSuggestionBanner extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final VoidCallback? onRegionChanged;

  const RegionSuggestionBanner({
    super.key,
    this.latitude,
    this.longitude,
    this.onRegionChanged,
  });

  @override
  State<RegionSuggestionBanner> createState() => _RegionSuggestionBannerState();
}

class _RegionSuggestionBannerState extends State<RegionSuggestionBanner> {
  RegionModel? _suggestedRegion;
  bool _isDismissed = false;
  bool _isChanging = false;

  @override
  void initState() {
    super.initState();
    _checkForRegionSuggestion();
  }

  @override
  void didUpdateWidget(RegionSuggestionBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || 
        oldWidget.longitude != widget.longitude) {
      _checkForRegionSuggestion();
    }
  }

  void _checkForRegionSuggestion() {
    if (widget.latitude != null && widget.longitude != null) {
      final suggestion = RegionService.suggestRegionChange(
        widget.latitude!,
        widget.longitude!,
      );
      
      if (suggestion != null && !_isDismissed) {
        setState(() {
          _suggestedRegion = suggestion;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_suggestedRegion == null || _isDismissed) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade50,
                Colors.blue.shade100,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.blue.shade200,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Estás en ${_suggestedRegion!.displayName}?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        Text(
                          'Detectamos que podrías estar en ${_suggestedRegion!.displayName}, ${_suggestedRegion!.country}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _dismiss,
                    icon: Icon(
                      Icons.close,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _dismiss,
                    child: Text(
                      'No, gracias',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isChanging ? null : _changeRegion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isChanging
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Cambiar región',
                            style: TextStyle(fontWeight: FontWeight.w600),
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

    setState(() {
      _isChanging = true;
    });

    try {
      final success = await RegionService.changeRegion(_suggestedRegion!);
      
      if (success && mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Región cambiada a ${_suggestedRegion!.displayName}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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
          const SnackBar(
            content: Text('Error al cambiar región'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
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
    } finally {
      if (mounted) {
        setState(() {
          _isChanging = false;
        });
      }
    }
  }
}

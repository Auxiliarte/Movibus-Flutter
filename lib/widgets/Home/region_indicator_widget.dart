import 'package:flutter/material.dart';
import '../../services/region_service.dart';
import '../../themes/app_colors.dart';
import '../region_selector_widget.dart';

class RegionIndicatorWidget extends StatefulWidget {
  final VoidCallback? onRegionChanged;

  const RegionIndicatorWidget({
    super.key,
    this.onRegionChanged,
  });

  @override
  State<RegionIndicatorWidget> createState() => _RegionIndicatorWidgetState();
}

class _RegionIndicatorWidgetState extends State<RegionIndicatorWidget> {
  @override
  Widget build(BuildContext context) {
    final currentRegion = RegionService.currentRegion;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showRegionSelector,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.location_city,
                    color: AppColors.primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentRegion.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${currentRegion.state}, ${currentRegion.country}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRegionSelector() {
    showRegionSelectorModal(context).then((selectedRegion) {
      if (selectedRegion != null && mounted) {
        setState(() {
          // El estado se actualizará automáticamente porque RegionService
          // maneja el cambio de región internamente
        });
        
        // Notificar al padre que la región cambió
        widget.onRegionChanged?.call();
      }
    });
  }
}

// Widget compacto para mostrar solo la región actual
class CompactRegionIndicator extends StatelessWidget {
  final VoidCallback? onTap;

  const CompactRegionIndicator({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentRegion = RegionService.currentRegion;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.primaryColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              currentRegion.displayName,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primaryColor,
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

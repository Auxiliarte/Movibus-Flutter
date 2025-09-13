import 'package:flutter/material.dart';
import '../models/region_model.dart';
import '../services/region_service.dart';
import '../themes/app_colors.dart';

class RegionSelectorWidget extends StatefulWidget {
  final Function(RegionModel)? onRegionChanged;
  final bool showAsModal;
  final bool showCurrentFirst;

  const RegionSelectorWidget({
    super.key,
    this.onRegionChanged,
    this.showAsModal = false,
    this.showCurrentFirst = true,
  });

  @override
  State<RegionSelectorWidget> createState() => _RegionSelectorWidgetState();
}

class _RegionSelectorWidgetState extends State<RegionSelectorWidget> {
  RegionModel _selectedRegion = RegionService.currentRegion;
  List<RegionModel> _regions = [];
  List<RegionModel> _filteredRegions = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRegions();
    _searchController.addListener(_filterRegions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRegions() {
    setState(() {
      _regions = RegionService.getAvailableRegions();
      _filteredRegions = List.from(_regions);
      
      // Poner la región actual al principio si está habilitado
      if (widget.showCurrentFirst) {
        _filteredRegions.removeWhere((region) => region.id == _selectedRegion.id);
        _filteredRegions.insert(0, _selectedRegion);
      }
    });
  }

  void _filterRegions() {
    final query = _searchController.text;
    setState(() {
      _filteredRegions = RegionService.searchRegions(query);
      
      // Mantener la región actual al principio si está habilitado
      if (widget.showCurrentFirst && query.isEmpty) {
        _filteredRegions.removeWhere((region) => region.id == _selectedRegion.id);
        _filteredRegions.insert(0, _selectedRegion);
      }
    });
  }

  Future<void> _selectRegion(RegionModel region) async {
    if (region.id == _selectedRegion.id) return;

    setState(() {
      _isLoading = true;
    });

    final success = await RegionService.changeRegion(region);
    
    if (success && mounted) {
      setState(() {
        _selectedRegion = region;
        _isLoading = false;
      });

      // Notificar el cambio
      widget.onRegionChanged?.call(region);

      // Si es modal, cerrar
      if (widget.showAsModal) {
        Navigator.of(context).pop(region);
      }

      // Mostrar mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Región cambiada a ${region.displayName}'),
          backgroundColor: AppColors.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cambiar región'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAsModal) {
      return _buildModalContent();
    } else {
      return _buildInlineContent();
    }
  }

  Widget _buildModalContent() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Seleccionar Región',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSearchField(),
              ],
            ),
          ),
          // Lista de regiones
          Expanded(child: _buildRegionsList()),
        ],
      ),
    );
  }

  Widget _buildInlineContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField(),
        const SizedBox(height: 16),
        _buildRegionsList(),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar región...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: widget.showAsModal ? Colors.white : Colors.grey[100],
      ),
    );
  }

  Widget _buildRegionsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredRegions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No se encontraron regiones',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: !widget.showAsModal,
      itemCount: _filteredRegions.length,
      itemBuilder: (context, index) {
        final region = _filteredRegions[index];
        final isSelected = region.id == _selectedRegion.id;
        final isCurrent = region.id == RegionService.currentRegion.id;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: isSelected ? 4 : 1,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.location_city,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    region.displayName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primaryColor : Colors.black87,
                    ),
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Actual',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              '${region.state}, ${region.country}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColor,
                  )
                : const Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.grey,
                  ),
            onTap: () => _selectRegion(region),
          ),
        );
      },
    );
  }
}

// Widget para mostrar la región actual de forma compacta
class CurrentRegionDisplay extends StatelessWidget {
  final VoidCallback? onTap;
  final bool showChangeButton;

  const CurrentRegionDisplay({
    super.key,
    this.onTap,
    this.showChangeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentRegion = RegionService.currentRegion;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.location_city,
              color: Colors.white,
              size: 20,
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
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${currentRegion.state}, ${currentRegion.country}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (showChangeButton)
            TextButton(
              onPressed: onTap,
              child: Text(
                'Cambiar',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Función helper para mostrar el selector como modal
Future<RegionModel?> showRegionSelectorModal(BuildContext context) {
  return showModalBottomSheet<RegionModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const RegionSelectorWidget(showAsModal: true),
  );
}

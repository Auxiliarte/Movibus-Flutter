import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import '../../services/places_service.dart';

class SimpleLocationPicker extends StatefulWidget {
  final Function(String address, double lat, double lng) onLocationSelected;
  final String initialAddress;

  const SimpleLocationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialAddress = '',
  });

  @override
  State<SimpleLocationPicker> createState() => _SimpleLocationPickerState();
}

class _SimpleLocationPickerState extends State<SimpleLocationPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  String _selectedAddress = '';
  double? _selectedLat;
  double? _selectedLng;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialAddress;
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _isLoading = true);
    
    try {
      final locationData = await LocationService.getCurrentLocationWithAddress();
      if (locationData != null) {
        setState(() {
          _selectedAddress = locationData['address'] ?? '';
          _selectedLat = locationData['latitude'];
          _selectedLng = locationData['longitude'];
        });
      }
    } catch (e) {
      print('Error cargando ubicación actual: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Usar el servicio de Places para buscar
      final places = await PlacesService.searchPlacesByText(query);
      setState(() {
        _suggestions = places;
      });
    } catch (e) {
      print('Error buscando lugares: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectLocation(Map<String, dynamic> location) {
    setState(() {
      _selectedAddress = location['address'];
      _selectedLat = location['lat'];
      _selectedLng = location['lng'];
      _searchController.text = location['address'];
    });
  }

  void _confirmLocation() {
    if (_selectedLat != null && _selectedLng != null) {
      widget.onLocationSelected(_selectedAddress, _selectedLat!, _selectedLng!);
      Navigator.of(context).pop();
    }
  }

  void _useCurrentLocation() async {
    setState(() => _isLoading = true);
    
    try {
      final locationData = await LocationService.getCurrentLocationWithAddress();
      if (locationData != null) {
        widget.onLocationSelected(
          locationData['address'] ?? '',
          locationData['latitude']!,
          locationData['longitude']!,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar ubicación'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedLat != null && _selectedLng != null)
            TextButton(
              onPressed: _confirmLocation,
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchPlaces,
              decoration: InputDecoration(
                hintText: 'Buscar dirección...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isLoading 
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16, 
                          height: 16, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        ),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Botón de ubicación actual
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _useCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Usar ubicación actual'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Lista de sugerencias
          Expanded(
            child: _suggestions.isNotEmpty
                ? ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.blue),
                        title: Text(suggestion['name']),
                        subtitle: Text(suggestion['address']),
                        onTap: () => _selectLocation(suggestion),
                      );
                    },
                  )
                : _selectedAddress.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.blue.shade600),
                                const SizedBox(width: 8),
                                const Text(
                                  'Ubicación seleccionada:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(_selectedAddress),
                            if (_selectedLat != null && _selectedLng != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Coordenadas: ${_selectedLat!.toStringAsFixed(6)}, ${_selectedLng!.toStringAsFixed(6)}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : const Center(
                        child: Text(
                          'Busca una dirección o usa tu ubicación actual',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import '../../services/places_service.dart';
import '../../services/location_service.dart';

class PlaceAutocompleteField extends StatefulWidget {
  final String hint;
  final void Function(String name, double lat, double lng) onPlaceSelected;
  final TextEditingController? controller;
  final bool isOrigin; // Para diferenciar entre origen y destino

  const PlaceAutocompleteField({
    super.key,
    required this.hint,
    required this.onPlaceSelected,
    this.controller,
    this.isOrigin = false,
  });

  @override
  State<PlaceAutocompleteField> createState() => _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState extends State<PlaceAutocompleteField> {
  final FocusNode _focusNode = FocusNode();
  List<PlacePrediction> _suggestions = [];
  bool _isLoading = false;
  String _lastInput = '';
  late TextEditingController _controller;
  bool _showMapOption = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    
    // Mostrar opción de mapa si no hay texto y es el campo de origen
    if (widget.isOrigin) {
      _showMapOption = true;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onChanged(String value) async {
    print('🔍 PlaceAutocompleteField - _onChanged called with value: "$value"');
    print('🔍 isOrigin: ${widget.isOrigin}');
    
    if (value == _lastInput) {
      print('🔍 Value unchanged, skipping...');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _lastInput = value;
      _showMapOption = value.isEmpty && widget.isOrigin;
    });

    if (value.isEmpty) {
      print('🔍 Value is empty, clearing suggestions');
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    try {
      print('🔍 Calling PlacesService.searchPlaces with: "$value"');
      
      // Buscar tanto lugares geográficos como establecimientos
      final geocodeResults = await PlacesService.searchPlaces(value);
      final establishmentResults = await PlacesService.searchEstablishments(value);
      
      // Combinar y ordenar resultados
      final allResults = <PlacePrediction>[];
      allResults.addAll(establishmentResults); // Establecimientos primero
      allResults.addAll(geocodeResults); // Lugares geográficos después
      
      print('🔍 Geocode results: ${geocodeResults.length}');
      print('🔍 Establishment results: ${establishmentResults.length}');
      print('🔍 Total results: ${allResults.length}');
      
      setState(() {
        _suggestions = allResults;
        _isLoading = false;
      });
      
      print('🔍 Suggestions updated: ${_suggestions.length} items');
    } catch (e) {
      print('❌ Error in _onChanged: $e');
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _onSuggestionTap(PlacePrediction prediction) async {
    print('🎯 PlaceAutocompleteField - _onSuggestionTap called');
    print('🎯 Selected prediction: ${prediction.description}');
    print('🎯 Place ID: ${prediction.placeId}');
    
    try {
      print('🎯 Getting place details...');
      final details = await PlacesService.getPlaceDetails(prediction.placeId);
      
      if (details != null && details.latitude != null && details.longitude != null) {
        print('🎯 Place details obtained successfully');
        print('🎯 Name: ${details.name}');
        print('🎯 Lat: ${details.latitude}, Lng: ${details.longitude}');
        
        final displayName = details.name.isNotEmpty ? details.name : prediction.description;
        _controller.text = displayName;
        widget.onPlaceSelected(displayName, details.latitude!, details.longitude!);
        
        setState(() {
          _suggestions = [];
          _showMapOption = false;
        });
        _focusNode.unfocus();
        
        print('🎯 Selection completed successfully');
      } else {
        print('❌ Place details are null or missing coordinates');
      }
    } catch (e) {
      print('❌ Error in _onSuggestionTap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener detalles del lugar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        final displayName = address ?? 'Mi ubicación actual';
        _controller.text = displayName;
        widget.onPlaceSelected(displayName, position.latitude, position.longitude);
        
        setState(() {
          _suggestions = [];
          _showMapOption = false;
        });
        _focusNode.unfocus();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener ubicación actual: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectFromMap() async {
    final result = await Navigator.pushNamed(
      context,
      '/locationPicker',
      arguments: {
        'title': widget.hint,
        'initialAddress': _controller.text,
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      final latitude = result['latitude'] as double;
      final longitude = result['longitude'] as double;
      final address = result['address'] as String;

      _controller.text = address;
      widget.onPlaceSelected(address, latitude, longitude);
      
      setState(() {
        _suggestions = [];
        _showMapOption = false;
      });
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          onTap: () {
            setState(() {
              _showMapOption = _controller.text.isEmpty && widget.isOrigin;
            });
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.place, color: Colors.grey),
            suffixIcon: _isLoading ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 16, 
                height: 16, 
                child: CircularProgressIndicator(strokeWidth: 2)
              ),
            ) : widget.isOrigin && _controller.text.isEmpty ? IconButton(
              icon: const Icon(Icons.my_location, color: Colors.blue),
              onPressed: _useCurrentLocation,
              tooltip: 'Usar ubicación actual',
            ) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        
        // Opción de seleccionar desde el mapa
        if (_showMapOption && widget.isOrigin)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: _selectFromMap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.map,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '¿No encuentras tu dirección? Selecciónala desde el mapa',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue.shade600,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Lista de sugerencias
        if (_suggestions.isNotEmpty && _focusNode.hasFocus)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                final description = suggestion.description ?? '';
                
                return Container(
                  decoration: BoxDecoration(
                    border: index < _suggestions.length - 1 
                      ? Border(bottom: BorderSide(color: Colors.grey.shade100))
                      : null,
                  ),
                  child: ListTile(
                    leading: Icon(
                      _getIconForPlaceType(suggestion.types?.firstOrNull),
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    title: Text(
                      _getMainText(description),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      _getSecondaryText(description),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () => _onSuggestionTap(suggestion),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  IconData _getIconForPlaceType(String? type) {
    switch (type) {
      case 'establishment':
        return Icons.store;
      case 'route':
        return Icons.route;
      case 'street_address':
        return Icons.location_on;
      case 'sublocality':
        return Icons.location_city;
      case 'premise':
        return Icons.home;
      case 'point_of_interest':
        return Icons.place;
      default:
        return Icons.place;
    }
  }

  String _getMainText(String description) {
    // Extraer la parte principal del texto (antes de la coma)
    final parts = description.split(',');
    return parts.first.trim();
  }

  String _getSecondaryText(String description) {
    // Extraer la parte secundaria (después de la primera coma)
    final parts = description.split(',');
    if (parts.length > 1) {
      return parts.skip(1).take(2).join(', ').trim();
    }
    return '';
  }
} 
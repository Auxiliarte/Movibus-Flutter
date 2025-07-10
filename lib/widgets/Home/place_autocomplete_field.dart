import 'package:flutter/material.dart';
import '../../services/places_service.dart';
import '../../services/location_service.dart';
import 'map_location_picker.dart';

class PlaceAutocompleteField extends StatefulWidget {
  final String hint;
  final void Function(String name, double lat, double lng) onPlaceSelected;
  final TextEditingController? controller;
  final bool autoDetectLocation;
  final bool showCurrentLocationButton;

  const PlaceAutocompleteField({
    super.key,
    required this.hint,
    required this.onPlaceSelected,
    this.controller,
    this.autoDetectLocation = false,
    this.showCurrentLocationButton = false,
  });

  @override
  State<PlaceAutocompleteField> createState() => _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState extends State<PlaceAutocompleteField> {
  final FocusNode _focusNode = FocusNode();
  List<PlacePrediction> _suggestions = [];
  bool _isLoading = false;
  bool _isDetectingLocation = false;
  bool _showSuggestions = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    
    if (widget.autoDetectLocation) {
      _detectCurrentLocation();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isDetectingLocation = true);
    
    try {
      final locationData = await LocationService.getCurrentLocationWithAddress();
      if (locationData != null) {
        _controller.text = locationData['address'] ?? '';
        widget.onPlaceSelected(
          locationData['address'] ?? '',
          locationData['latitude']!,
          locationData['longitude']!,
        );
      }
    } catch (e) {
      print('Error detectando ubicación actual: $e');
    } finally {
      setState(() => _isDetectingLocation = false);
    }
  }

  Future<void> _onChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuggestions = true;
    });
    
    try {
      final results = await PlacesService.searchPlaces(value);
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _onSuggestionTap(PlacePrediction prediction) async {
    setState(() => _isLoading = true);
    
    try {
      final details = await PlacesService.getPlaceDetails(prediction.placeId);
      if (details != null && details.latitude != null && details.longitude != null) {
        _controller.text = details.name.isNotEmpty ? details.name : prediction.description;
        widget.onPlaceSelected(_controller.text, details.latitude!, details.longitude!);
        setState(() {
          _suggestions = [];
          _showSuggestions = false;
        });
        _focusNode.unfocus();
      }
    } catch (e) {
      print('Error seleccionando lugar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openMapPicker() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
          initialAddress: _controller.text,
          onLocationSelected: (address, lat, lng) {
            _controller.text = address;
            widget.onPlaceSelected(address, lat, lng);
          },
        ),
      ),
    );
  }

  void _useCurrentLocation() async {
    setState(() => _isDetectingLocation = true);
    
    try {
      final locationData = await LocationService.getCurrentLocationWithAddress();
      if (locationData != null) {
        _controller.text = locationData['address'] ?? '';
        widget.onPlaceSelected(
          locationData['address'] ?? '',
          locationData['latitude']!,
          locationData['longitude']!,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() => _isDetectingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de texto principal
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          onTap: () {
            if (_controller.text.isNotEmpty) {
              setState(() => _showSuggestions = true);
            }
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: _isDetectingLocation 
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 16, 
                      height: 16, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    ),
                  )
                : const Icon(Icons.place, color: Colors.grey),
            suffixIcon: _isLoading 
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 16, 
                      height: 16, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: _openMapPicker,
                    tooltip: 'Seleccionar desde mapa',
                  ),
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

        // Botón de ubicación actual (solo para origen)
        if (widget.showCurrentLocationButton)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isDetectingLocation ? null : _useCurrentLocation,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isDetectingLocation)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          Icons.my_location,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _isDetectingLocation ? 'Detectando...' : 'Usar ubicación actual',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Sugerencias de autocompletado
        if (_showSuggestions && _suggestions.isNotEmpty)
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

        // Opción de mapa cuando no hay sugerencias pero hay texto
        if (_showSuggestions && _suggestions.isEmpty && _controller.text.isNotEmpty)
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
            child: ListTile(
              leading: const Icon(Icons.map, color: Colors.blue),
              title: const Text(
                'Seleccionar desde mapa',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'No se encontraron resultados. Usa el mapa para seleccionar la ubicación.',
                style: TextStyle(fontSize: 12),
              ),
              onTap: _openMapPicker,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      default:
        return Icons.place;
    }
  }

  String _getMainText(String description) {
    final parts = description.split(',');
    return parts.first.trim();
  }

  String _getSecondaryText(String description) {
    final parts = description.split(',');
    if (parts.length > 1) {
      return parts.skip(1).take(2).join(', ').trim();
    }
    return '';
  }
} 
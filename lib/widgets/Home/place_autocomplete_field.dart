import 'package:flutter/material.dart';
import '../../services/places_service.dart';

class PlaceAutocompleteField extends StatefulWidget {
  final String hint;
  final void Function(String name, double lat, double lng) onPlaceSelected;
  final TextEditingController? controller;

  const PlaceAutocompleteField({
    super.key,
    required this.hint,
    required this.onPlaceSelected,
    this.controller,
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

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  Future<void> _onChanged(String value) async {
    if (value == _lastInput) return;
    setState(() {
      _isLoading = true;
      _lastInput = value;
    });
    final results = await PlacesService.searchPlaces(value);
    setState(() {
      _suggestions = results;
      _isLoading = false;
    });
  }

  Future<void> _onSuggestionTap(PlacePrediction prediction) async {
    final details = await PlacesService.getPlaceDetails(prediction.placeId);
    if (details != null && details.latitude != null && details.longitude != null) {
      _controller.text = details.name.isNotEmpty ? details.name : prediction.description;
      widget.onPlaceSelected(_controller.text, details.latitude!, details.longitude!);
      setState(() {
        _suggestions = [];
      });
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.place, color: Colors.grey),
            suffixIcon: _isLoading ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
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
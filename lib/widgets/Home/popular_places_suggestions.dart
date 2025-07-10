import 'package:flutter/material.dart';
import '../../services/places_service.dart';

class PopularPlacesSuggestions extends StatefulWidget {
  final Function(String name, double lat, double lng) onPlaceSelected;

  const PopularPlacesSuggestions({
    super.key,
    required this.onPlaceSelected,
  });

  @override
  State<PopularPlacesSuggestions> createState() => _PopularPlacesSuggestionsState();
}

class _PopularPlacesSuggestionsState extends State<PopularPlacesSuggestions> {
  List<PlacePrediction> _popularPlaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPopularPlaces();
  }

  Future<void> _loadPopularPlaces() async {
    try {
      final places = await PlacesService.getPopularPlaces();
      setState(() {
        _popularPlaces = places;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onPlaceTap(PlacePrediction prediction) async {
    final details = await PlacesService.getPlaceDetails(prediction.placeId);
    if (details != null && details.latitude != null && details.longitude != null) {
      widget.onPlaceSelected(
        details.name.isNotEmpty ? details.name : prediction.description,
        details.latitude!,
        details.longitude!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_popularPlaces.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Lugares populares',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _popularPlaces.length,
              itemBuilder: (context, index) {
                final place = _popularPlaces[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => _onPlaceTap(place),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getIconForPlaceType(place.types?.firstOrNull),
                                  color: Colors.blue.shade600,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getMainText(place.description),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getSecondaryText(place.description),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
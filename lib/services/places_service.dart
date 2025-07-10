import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacePrediction {
  final String placeId;
  final String description;
  final List<String>? types;

  PlacePrediction({
    required this.placeId,
    required this.description,
    this.types,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      types: json['types'] != null 
        ? List<String>.from(json['types'])
        : null,
    );
  }
}

class PlaceDetails {
  final String name;
  final double? latitude;
  final double? longitude;

  PlaceDetails({
    required this.name,
    this.latitude,
    this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final location = geometry?['location'];
    
    return PlaceDetails(
      name: json['name'] ?? '',
      latitude: location?['lat']?.toDouble(),
      longitude: location?['lng']?.toDouble(),
    );
  }
}

class PlacesService {
  static const String apiKey = "AIzaSyA2NeKAZRdbRsy6cSj52TJRGJdf5wtlSA4";

  // Buscar lugares basándose en el texto ingresado
  static Future<List<PlacePrediction>> searchPlaces(String input) async {
    if (input.isEmpty) return [];
    
    // Agregar "San Luis Potosí" al input para limitar las búsquedas a SLP
    String searchInput = input;
    if (!input.toLowerCase().contains('san luis potosí') && 
        !input.toLowerCase().contains('slp')) {
      searchInput = '$input, San Luis Potosí, SLP';
    }
    
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(searchInput)}'
          '&key=$apiKey'
          '&language=es'
          '&components=country:mx'
          '&types=establishment|geocode|route'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          final results = predictions
              .map((p) => PlacePrediction.fromJson(p))
              .where((prediction) {
                final description = prediction.description.toLowerCase();
                return description.contains('san luis potosí') || 
                       description.contains('slp') ||
                       description.contains('potosí');
              })
              .toList();
          return results;
        }
      }
    } catch (e) {
      print('Error buscando lugares: $e');
    }
    
    return [];
  }

  // Obtener detalles de un lugar específico
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&key=$apiKey'
          '&language=es'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return PlaceDetails.fromJson(data['result']);
        }
      }
    } catch (e) {
      print('Error obteniendo detalles del lugar: $e');
    }
    
    return null;
  }
} 
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
    if (input.isEmpty || input.length < 2) return [];
    
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
          '&types=establishment|geocode|route|street_address|sublocality'
          '&sessiontoken=1234567890' // Token de sesión para mejorar resultados
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Manejar diferentes estados de respuesta
        switch (data['status']) {
          case 'OK':
            final predictions = data['predictions'] as List;
            final results = predictions
                .map((p) => PlacePrediction.fromJson(p))
                .where((prediction) {
                  final description = prediction.description.toLowerCase();
                  return description.contains('san luis potosí') || 
                         description.contains('slp') ||
                         description.contains('potosí');
                })
                .take(5) // Limitar a 5 resultados para mejor UX
                .toList();
            return results;
            
          case 'ZERO_RESULTS':
            print('No se encontraron resultados para: $input');
            return [];
            
          case 'OVER_QUERY_LIMIT':
            print('Límite de consultas excedido');
            return [];
            
          case 'REQUEST_DENIED':
            print('Solicitud denegada - verificar API key');
            return [];
            
          case 'INVALID_REQUEST':
            print('Solicitud inválida');
            return [];
            
          default:
            print('Error desconocido en Places API: ${data['status']}');
            return [];
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error buscando lugares: $e');
      return [];
    }
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
          '&fields=name,geometry'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        switch (data['status']) {
          case 'OK':
            return PlaceDetails.fromJson(data['result']);
            
          case 'NOT_FOUND':
            print('Lugar no encontrado: $placeId');
            return null;
            
          case 'ZERO_RESULTS':
            print('No se encontraron detalles para: $placeId');
            return null;
            
          default:
            print('Error obteniendo detalles: ${data['status']}');
            return null;
        }
      } else {
        print('Error HTTP en detalles: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error obteniendo detalles del lugar: $e');
      return null;
    }
  }

  // Buscar lugares cercanos a una ubicación
  static Future<List<PlacePrediction>> searchNearbyPlaces(
    double latitude, 
    double longitude, 
    String type, 
    {int radius = 5000}
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=$latitude,$longitude'
          '&radius=$radius'
          '&type=$type'
          '&key=$apiKey'
          '&language=es'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results.map((place) {
            return PlacePrediction(
              placeId: place['place_id'] ?? '',
              description: place['name'] ?? '',
              types: place['types'] != null 
                ? List<String>.from(place['types'])
                : null,
            );
          }).toList();
        }
      }
    } catch (e) {
      print('Error buscando lugares cercanos: $e');
    }
    
    return [];
  }

  // Buscar lugares por texto con geocoding
  static Future<List<Map<String, dynamic>>> searchPlacesByText(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?address=${Uri.encodeComponent(query + ", San Luis Potosí, SLP")}'
          '&key=$apiKey'
          '&language=es'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results.map((result) {
            final location = result['geometry']['location'];
            return {
              'name': result['formatted_address'],
              'address': result['formatted_address'],
              'lat': location['lat'].toDouble(),
              'lng': location['lng'].toDouble(),
            };
          }).toList();
        }
      }
    } catch (e) {
      print('Error buscando lugares por texto: $e');
    }
    
    return [];
  }

  // Buscar lugares populares en San Luis Potosí
  static Future<List<PlacePrediction>> getPopularPlaces() async {
    try {
      // Lugares populares en SLP
      final popularPlaces = [
        'Walmart San Luis Potosí',
        'Plaza de Armas San Luis Potosí',
        'Hospital Central San Luis Potosí',
        'Universidad Autónoma de San Luis Potosí',
        'Centro Histórico San Luis Potosí',
      ];

      List<PlacePrediction> results = [];
      
      for (String place in popularPlaces) {
        final predictions = await searchPlaces(place);
        if (predictions.isNotEmpty) {
          results.add(predictions.first);
        }
      }
      
      return results;
    } catch (e) {
      print('Error obteniendo lugares populares: $e');
      return [];
    }
  }
} 
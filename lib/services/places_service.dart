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
  final String? formattedAddress;

  PlaceDetails({
    required this.name,
    this.latitude,
    this.longitude,
    this.formattedAddress,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final location = geometry?['location'];
    
    return PlaceDetails(
      name: json['name'] ?? '',
      latitude: location?['lat']?.toDouble(),
      longitude: location?['lng']?.toDouble(),
      formattedAddress: json['formatted_address'],
    );
  }
}

class PlacesService {
  static const String apiKey = "AIzaSyA2NeKAZRdbRsy6cSj52TJRGJdf5wtlSA4";
  
  // Coordenadas aproximadas del centro de San Luis Potosí
  static const double _slpCenterLat = 22.1565;
  static const double _slpCenterLng = -100.9855;
  static const int _slpRadius = 50000; // 50km de radio

  // Buscar lugares basándose en el texto ingresado, limitado a San Luis Potosí
  static Future<List<PlacePrediction>> searchPlaces(String input) async {
    print('🌍 PlacesService.searchPlaces called with input: "$input"');
    
    if (input.isEmpty) {
      print('🌍 Input is empty, returning empty list');
      return [];
    }
    
    try {
      // Agregar "San Luis Potosí" al input para limitar las búsquedas a SLP
      String searchInput = input;
      if (!input.toLowerCase().contains('san luis potosí') && 
          !input.toLowerCase().contains('slp') &&
          !input.toLowerCase().contains('potosí')) {
        searchInput = '$input, San Luis Potosí, SLP';
      }
      
      // Construir la consulta con restricciones específicas para SLP
      final queryParams = {
        'input': searchInput,
        'key': apiKey,
        'language': 'es',
        'components': 'country:mx',
        'types': 'geocode',
        'location': '$_slpCenterLat,$_slpCenterLng',
        'radius': _slpRadius.toString(),
        'strictbounds': 'true',
      };

      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        queryParams,
      );

      print('🌍 Making request to: ${uri.toString()}');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('🌍 Request timeout');
          throw Exception('Tiempo de espera agotado al buscar lugares');
        },
      );

      print('🌍 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🌍 API Status: ${data['status']}');
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          print('🌍 Raw predictions count: ${predictions.length}');
          
          final results = predictions
              .map((p) => PlacePrediction.fromJson(p))
              .where((prediction) {
                // Filtrar solo resultados de San Luis Potosí
                final description = prediction.description.toLowerCase();
                final isSLP = description.contains('san luis potosí') || 
                       description.contains('slp') ||
                       description.contains('potosí') ||
                       description.contains('san luis');
                
                print('🌍 Checking prediction: "${prediction.description}" - isSLP: $isSLP');
                return isSLP;
              })
              .toList();
          
          print('🌍 Filtered results count: ${results.length}');
          
          // Ordenar por relevancia (establecimientos primero, luego direcciones)
          results.sort((a, b) {
            final aTypes = a.types ?? [];
            final bTypes = b.types ?? [];
            
            // Priorizar establecimientos sobre direcciones
            if (aTypes.contains('establishment') && !bTypes.contains('establishment')) return -1;
            if (!aTypes.contains('establishment') && bTypes.contains('establishment')) return 1;
            
            return 0;
          });
          
          print('🌍 Final results count: ${results.length}');
          for (var result in results) {
            print('🌍 Result: ${result.description}');
          }
          
          return results;
        } else if (data['status'] == 'ZERO_RESULTS') {
          print('🌍 No results found');
          return [];
        } else {
          print('❌ Error en Places API: ${data['status']} - ${data['error_message'] ?? 'Sin mensaje'}');
          return [];
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error buscando lugares: $e');
      return [];
    }
  }

  // Obtener detalles de un lugar específico
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    print('📍 PlacesService.getPlaceDetails called with placeId: $placeId');
    
    try {
      final queryParams = {
        'place_id': placeId,
        'key': apiKey,
        'language': 'es',
        'fields': 'name,geometry,formatted_address',
      };

      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        queryParams,
      );

      print('📍 Making request to: ${uri.toString()}');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado al obtener detalles');
        },
      );

      print('📍 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📍 API Status: ${data['status']}');
        
        if (data['status'] == 'OK') {
          print('📍 Raw response data: ${json.encode(data['result'])}');
          
          final placeDetails = PlaceDetails.fromJson(data['result']);
          print('📍 Parsed place details:');
          print('📍   Name: ${placeDetails.name}');
          print('📍   Latitude: ${placeDetails.latitude}');
          print('📍   Longitude: ${placeDetails.longitude}');
          print('📍   Address: ${placeDetails.formattedAddress}');
          
          return placeDetails;
        } else {
          print('❌ Error en Place Details API: ${data['status']} - ${data['error_message'] ?? 'Sin mensaje'}');
          return null;
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error obteniendo detalles del lugar: $e');
      return null;
    }
  }

  // Buscar establecimientos específicos
  static Future<List<PlacePrediction>> searchEstablishments(String input) async {
    print('🏪 PlacesService.searchEstablishments called with input: "$input"');
    
    if (input.isEmpty) return [];
    
    try {
      // Agregar "San Luis Potosí" al input para limitar las búsquedas a SLP
      String searchInput = input;
      if (!input.toLowerCase().contains('san luis potosí') && 
          !input.toLowerCase().contains('slp') &&
          !input.toLowerCase().contains('potosí')) {
        searchInput = '$input, San Luis Potosí, SLP';
      }
      
      final queryParams = {
        'input': searchInput,
        'key': apiKey,
        'language': 'es',
        'components': 'country:mx',
        'types': 'establishment',
        'location': '$_slpCenterLat,$_slpCenterLng',
        'radius': _slpRadius.toString(),
      };

      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        queryParams,
      );

      print('🏪 Making establishment request to: ${uri.toString()}');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('🏪 Request timeout');
          throw Exception('Tiempo de espera agotado al buscar establecimientos');
        },
      );

      print('🏪 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🏪 API Status: ${data['status']}');
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          print('🏪 Establishments found: ${predictions.length}');
          
          final results = predictions
              .map((p) => PlacePrediction.fromJson(p))
              .where((prediction) {
                final description = prediction.description.toLowerCase();
                final isSLP = description.contains('san luis potosí') || 
                       description.contains('slp') ||
                       description.contains('potosí') ||
                       description.contains('san luis');
                
                print('🏪 Checking establishment: "${prediction.description}" - isSLP: $isSLP');
                return isSLP;
              })
              .toList();
          
          print('🏪 Filtered establishments: ${results.length}');
          return results;
        } else if (data['status'] == 'ZERO_RESULTS') {
          print('🏪 No establishments found');
          return [];
        } else {
          print('❌ Error en Establishments API: ${data['status']} - ${data['error_message'] ?? 'Sin mensaje'}');
          return [];
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error buscando establecimientos: $e');
      return [];
    }
  }

  // Buscar lugares cercanos a una ubicación específica
  static Future<List<PlacePrediction>> searchNearbyPlaces(
    double latitude,
    double longitude,
    String query,
  ) async {
    if (query.isEmpty) return [];
    
    try {
      final queryParams = {
        'location': '$latitude,$longitude',
        'radius': '5000', // 5km
        'keyword': query,
        'key': apiKey,
        'language': 'es',
        'types': 'establishment|geocode',
      };

      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/nearbysearch/json',
        queryParams,
      );

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado al buscar lugares cercanos');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results.map((r) => PlacePrediction(
            placeId: r['place_id'] ?? '',
            description: r['name'] ?? '',
            types: r['types'] != null ? List<String>.from(r['types']) : null,
          )).toList();
        }
      }
    } catch (e) {
      print('Error buscando lugares cercanos: $e');
    }
    
    return [];
  }
} 
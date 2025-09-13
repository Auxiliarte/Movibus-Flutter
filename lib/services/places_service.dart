import 'dart:convert';
import 'package:http/http.dart' as http;
import 'region_service.dart';
import '../models/region_model.dart';

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

  // Buscar lugares basándose en el texto ingresado, usando la región actual
  static Future<List<PlacePrediction>> searchPlaces(String input, {bool autoDetectRegion = true}) async {
    print('🌍 PlacesService.searchPlaces called with input: "$input"');
    
    if (input.isEmpty) {
      print('🌍 Input is empty, returning empty list');
      return [];
    }
    
    try {
      // Formatear input para la región actual
      final searchInput = RegionService.formatSearchInput(input);
      
      // Obtener configuración de la región actual
      final regionConfig = RegionService.getPlacesApiConfig();
      
      print('🌍 Searching with region: ${RegionService.currentRegion.displayName}');
      print('🌍 Search location: ${regionConfig['location']}');
      print('🌍 Search components: ${regionConfig['components']}');
      
      // Construir la consulta con restricciones específicas para la región actual
      final queryParams = {
        'input': searchInput,
        'key': apiKey,
        'language': regionConfig['language']!,
        'components': regionConfig['components']!,
        'types': 'address|street_address|route|sublocality|premise', // Priorizar direcciones y calles
        'location': regionConfig['location']!,
        'radius': regionConfig['radius']!,
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
                // Filtrar solo resultados de la región actual O detectar cambio de región automáticamente
                final description = prediction.description.toLowerCase();
                final currentRegion = RegionService.currentRegion;
                final isCurrentRegion = currentRegion.containsRegionTerms(description);
                
                print('🌍 Checking prediction: "${prediction.description}" - isCurrentRegion: $isCurrentRegion');
                
                if (!isCurrentRegion && autoDetectRegion) {
                  // Intentar detectar si los resultados son de otra región conocida
                  final detectedRegion = _detectRegionFromDescription(description);
                  if (detectedRegion != null && detectedRegion.id != currentRegion.id) {
                    print('💡 Detected different region in results: ${detectedRegion.displayName}');
                    print('💡 Consider changing region for better results');
                    
                    // Por ahora, permitir estos resultados pero con advertencia
                    return true;
                  }
                }
                
                return isCurrentRegion;
              })
              .toList();
          
          print('🌍 Filtered results count: ${results.length}');
          
          // Ordenar por relevancia (direcciones primero, luego establecimientos)
          results.sort((a, b) {
            final aTypes = a.types ?? [];
            final bTypes = b.types ?? [];
            
            // Priorizar direcciones y calles sobre establecimientos
            final aIsAddress = aTypes.contains('address') || 
                              aTypes.contains('street_address') || 
                              aTypes.contains('route') ||
                              aTypes.contains('premise');
            final bIsAddress = bTypes.contains('address') || 
                              bTypes.contains('street_address') || 
                              bTypes.contains('route') ||
                              bTypes.contains('premise');
            
            if (aIsAddress && !bIsAddress) return -1;
            if (!aIsAddress && bIsAddress) return 1;
            
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
      // Formatear input para la región actual
      final searchInput = RegionService.formatSearchInput(input);
      
      // Obtener configuración de la región actual
      final regionConfig = RegionService.getPlacesApiConfig();
      
      final queryParams = {
        'input': searchInput,
        'key': apiKey,
        'language': regionConfig['language']!,
        'components': regionConfig['components']!,
        'types': 'establishment',
        'location': regionConfig['location']!,
        'radius': regionConfig['radius']!,
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
                final currentRegion = RegionService.currentRegion;
                final isCurrentRegion = currentRegion.containsRegionTerms(description);
                
                print('🏪 Checking establishment: "${prediction.description}" - isCurrentRegion: $isCurrentRegion');
                return isCurrentRegion;
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

  // Buscar direcciones específicas con números de casa
  static Future<List<PlacePrediction>> searchAddresses(String input) async {
    print('🏠 PlacesService.searchAddresses called with input: "$input"');
    
    if (input.isEmpty) return [];
    
    try {
      // Formatear input para la región actual
      final searchInput = RegionService.formatSearchInput(input);
      
      // Obtener configuración de la región actual
      final regionConfig = RegionService.getPlacesApiConfig();
      
      final queryParams = {
        'input': searchInput,
        'key': apiKey,
        'language': regionConfig['language']!,
        'components': regionConfig['components']!,
        'types': 'street_address|premise|subpremise', // Solo direcciones específicas
        'location': regionConfig['location']!,
        'radius': regionConfig['radius']!,
        'strictbounds': 'true',
      };

      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        queryParams,
      );

      print('🏠 Making address request to: ${uri.toString()}');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('🏠 Request timeout');
          throw Exception('Tiempo de espera agotado al buscar direcciones');
        },
      );

      print('🏠 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🏠 API Status: ${data['status']}');
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          print('🏠 Addresses found: ${predictions.length}');
          
          final results = predictions
              .map((p) => PlacePrediction.fromJson(p))
              .where((prediction) {
                final description = prediction.description.toLowerCase();
                final currentRegion = RegionService.currentRegion;
                final isCurrentRegion = currentRegion.containsRegionTerms(description);
                
                print('🏠 Checking address: "${prediction.description}" - isCurrentRegion: $isCurrentRegion');
                return isCurrentRegion;
              })
              .toList();
          
          print('🏠 Filtered addresses: ${results.length}');
          return results;
        } else if (data['status'] == 'ZERO_RESULTS') {
          print('🏠 No addresses found');
          return [];
        } else {
          print('❌ Error en Addresses API: ${data['status']} - ${data['error_message'] ?? 'Sin mensaje'}');
          return [];
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error buscando direcciones: $e');
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

  // Método helper para detectar región desde descripción de lugar
  static RegionModel? _detectRegionFromDescription(String description) {
    final lowerDescription = description.toLowerCase();
    
    // Buscar en todas las regiones disponibles
    for (final region in RegionService.getAvailableRegions()) {
      if (region.containsRegionTerms(lowerDescription)) {
        return region;
      }
    }
    
    return null;
  }
} 
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationApiService {
  static const String baseUrl = 'https://app.moventra.com.mx/api';
  
  // Verificar si el endpoint existe
  static Future<bool> checkEndpoint(String endpoint) async {
    try {
      print('🔍 Checking endpoint: $baseUrl$endpoint');
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      print('🔍 Endpoint status: ${response.statusCode}');
      return response.statusCode != 404;
    } catch (e) {
      print('🔍 Endpoint check failed: $e');
      return false;
    }
  }
  
  // Encontrar estación más cercana
  static Future<Map<String, dynamic>> findNearestStation({
    required double latitude,
    required double longitude,
    int? routeId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/location/nearest-station'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          if (routeId != null) 'route_id': routeId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Sugerir rutas basándose en ubicación y destino
  static Future<Map<String, dynamic>> suggestRoute({
    required double userLatitude,
    required double userLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    int? maxWalkingDistance,
  }) async {
    print('🚌 LocationApiService.suggestRoute called');
    print('🚌 User location: ($userLatitude, $userLongitude)');
    print('🚌 Destination: ($destinationLatitude, $destinationLongitude)');
    print('🚌 Max walking distance: $maxWalkingDistance');
    
    final url = '$baseUrl/location/suggest-route';
    print('🚌 Making request to: $url');
    
    final requestBody = {
      'user_latitude': userLatitude,
      'user_longitude': userLongitude,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      if (maxWalkingDistance != null) 'max_walking_distance': maxWalkingDistance,
    };
    
    print('🚌 Request body: ${jsonEncode(requestBody)}');
    
    // Verificar si el endpoint existe
    print('🔍 Checking if endpoint exists...');
    final endpointExists = await checkEndpoint('/location/suggest-route');
    if (!endpointExists) {
      print('❌ Endpoint /location/suggest-route does not exist (404)');
      throw Exception('Endpoint no disponible: /location/suggest-route');
    }
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('🚌 Response status: ${response.statusCode}');
      print('🚌 Response body: ${response.body}');

      // Handle both 200 (success) and 404 (no routes found) as valid responses
      if (response.statusCode == 200 || response.statusCode == 404) {
        final result = jsonDecode(response.body);
        print('🚌 Successfully parsed response');
        return result;
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Error response: ${response.body}');
        throw Exception('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Exception in suggestRoute: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todas las rutas
  static Future<Map<String, dynamic>> getAllRoutes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/location/routes'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estaciones de una ruta
  static Future<Map<String, dynamic>> getRouteStations(int routeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/location/route/$routeId/stations'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener información de tracking
  static Future<Map<String, dynamic>> getTrackingInfo(int routeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/location/route/$routeId/tracking'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 
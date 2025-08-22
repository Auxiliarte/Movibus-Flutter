import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationApiService {
  static const String baseUrl = 'https://app.moventra.com.mx/api';
  static const Duration timeout = Duration(seconds: 15);
  
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
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Tiempo de espera agotado. Verifica tu conexión a internet.');
      }
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
      'enable_transfers': true,
      if (maxWalkingDistance != null) 'max_walking_distance': maxWalkingDistance,
    };
    
    print('🚌 Request body: ${jsonEncode(requestBody)}');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(timeout);

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
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception in suggestRoute: $e');
      if (e.toString().contains('timeout')) {
        throw Exception('Tiempo de espera agotado. Verifica tu conexión a internet.');
      }
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener todas las rutas
  static Future<Map<String, dynamic>> getAllRoutes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/location/routes'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Tiempo de espera agotado. Verifica tu conexión a internet.');
      }
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estaciones de una ruta
  static Future<Map<String, dynamic>> getRouteStations(int routeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/location/route/$routeId/stations'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Tiempo de espera agotado. Verifica tu conexión a internet.');
      }
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener información de tracking
  static Future<Map<String, dynamic>> getTrackingInfo(int routeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/location/route/$routeId/tracking'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Tiempo de espera agotado. Verifica tu conexión a internet.');
      }
      throw Exception('Error de conexión: $e');
    }
  }
} 
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationApiService {
  static const String baseUrl = 'https://app.moventra.com.mx/api';
  
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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/location/suggest-route'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_latitude': userLatitude,
          'user_longitude': userLongitude,
          'destination_latitude': destinationLatitude,
          'destination_longitude': destinationLongitude,
          if (maxWalkingDistance != null) 'max_walking_distance': maxWalkingDistance,
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
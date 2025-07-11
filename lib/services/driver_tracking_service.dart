import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class DriverTrackingService {
  static const String baseUrl = 'https://app.moventra.com.mx/api';

  /// Obtiene el tracking público de todos los choferes activos
  static Future<Map<String, dynamic>> getPublicTracking({int? routeId}) async {
    try {
      String url = '$baseUrl/tracking/drivers';
      if (routeId != null) {
        url += '?route_id=$routeId';
      }

      print('📡 Solicitando tracking público desde: $url');

      final response = await http.get(Uri.parse(url));

      print('🔄 Código de respuesta: ${response.statusCode}');
      print('📦 Respuesta completa: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        } else {
          throw Exception("❌ Error en la respuesta: ${data['message']}");
        }
      } else {
        throw Exception("❌ Error al obtener tracking: ${response.body}");
      }
    } catch (e) {
      print('❌ Error en getPublicTracking: $e');
      rethrow;
    }
  }

  /// Obtiene el tracking de un chofer específico por ruta
  static Future<Map<String, dynamic>> getDriverTrackingByRoute(int routeId) async {
    try {
      final url = '$baseUrl/tracking/route/$routeId';
      print('📡 Solicitando tracking de ruta $routeId desde: $url');

      final response = await http.get(Uri.parse(url));

      print('🔄 Código de respuesta: ${response.statusCode}');
      print('📦 Respuesta completa: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['data'];
        } else {
          throw Exception("❌ Error en la respuesta: ${data['message']}");
        }
      } else {
        throw Exception("❌ Error al obtener tracking de ruta: ${response.body}");
      }
    } catch (e) {
      print('❌ Error en getDriverTrackingByRoute: $e');
      rethrow;
    }
  }

  /// Calcula el tiempo estimado de llegada a una estación específica
  static String calculateEstimatedArrival({
    required Map<String, dynamic> driverLocation,
    required Map<String, dynamic> stationLocation,
    required double driverSpeed, // en km/h
  }) {
    try {
      // Calcular distancia entre chofer y estación
      final distance = _calculateDistance(
        driverLocation['latitude'],
        driverLocation['longitude'],
        stationLocation['latitude'],
        stationLocation['longitude'],
      );

      // Calcular tiempo estimado (asumiendo velocidad constante)
      final timeInMinutes = (distance / 1000) / (driverSpeed / 60);
      
      if (timeInMinutes < 1) {
        return 'Llegando...';
      } else if (timeInMinutes < 60) {
        return '${timeInMinutes.round()} min';
      } else {
        final hours = (timeInMinutes / 60).floor();
        final minutes = (timeInMinutes % 60).round();
        return '${hours}h ${minutes}min';
      }
    } catch (e) {
      print('❌ Error calculando tiempo estimado: $e');
      return 'N/A';
    }
  }

  /// Calcula la distancia entre dos puntos usando la fórmula de Haversine
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radio de la Tierra en metros

    final latDelta = _degreesToRadians(lat2 - lat1);
    final lonDelta = _degreesToRadians(lon2 - lon1);

    final a = sin(latDelta / 2) * sin(latDelta / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(lonDelta / 2) * sin(lonDelta / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distancia en metros
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  /// Formatea la información de tracking para mostrar en la UI
  static Map<String, dynamic> formatTrackingInfo(Map<String, dynamic> trackingData) {
    try {
      final activeDriver = trackingData['active_driver'];
      
      if (activeDriver == null) {
        return {
          'hasActiveDriver': false,
          'message': 'No hay autobús activo en esta ruta',
        };
      }

      final currentLocation = activeDriver['current_location'];
      final nearestStation = activeDriver['nearest_station'];
      final journeyInfo = activeDriver['journey_info'];

      return {
        'hasActiveDriver': true,
        'driverName': activeDriver['driver_name'] ?? 'Chofer',
        'currentLocation': currentLocation,
        'nearestStation': nearestStation,
        'journeyInfo': journeyInfo,
        'lastUpdated': activeDriver['last_updated'],
        'estimatedArrivalNext': journeyInfo['estimated_arrival_next'],
        'status': 'En ruta',
      };
    } catch (e) {
      print('❌ Error formateando tracking info: $e');
      return {
        'hasActiveDriver': false,
        'message': 'Error al obtener información de tracking',
      };
    }
  }
} 
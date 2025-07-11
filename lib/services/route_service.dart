import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_model.dart';

class RouteService {
  static Future<List<RouteModel>> fetchRoutes(String baseUrl) async {
    final url = Uri.parse('$baseUrl/rutas');
    print('📡 Solicitando rutas desde: $url');

    final response = await http.get(url);

    print('🔄 Código de respuesta: ${response.statusCode}');
    print('📦 Respuesta completa: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['routes'] as List)
          .map((json) => RouteModel.fromJson(json))
          .toList();
    } else {
      throw Exception("❌ Error al cargar rutas: ${response.body}");
    }
  }

  // Nuevo método para obtener todas las rutas básicas
  static Future<List<RouteBasicModel>> fetchAllRoutes(String baseUrl) async {
    final url = Uri.parse('$baseUrl/location/routes');
    print('📡 Solicitando todas las rutas desde: $url');

    final response = await http.get(url);

    print('🔄 Código de respuesta: ${response.statusCode}');
    print('📦 Respuesta completa: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        return (data['data'] as List)
            .map((json) => RouteBasicModel.fromJson(json))
            .toList();
      } else {
        throw Exception("❌ Error en la respuesta: ${data['message']}");
      }
    } else {
      throw Exception("❌ Error al cargar rutas: ${response.body}");
    }
  }

  // Nuevo método para obtener estaciones de una ruta específica
  static Future<RouteStationsResponse> fetchRouteStations(String baseUrl, int routeId) async {
    final url = Uri.parse('$baseUrl/location/route/$routeId/stations');
    print('📡 Solicitando estaciones de la ruta $routeId desde: $url');

    final response = await http.get(url);

    print('🔄 Código de respuesta: ${response.statusCode}');
    print('📦 Respuesta completa: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('🔍 Datos parseados: $data');
      
      if (data['status'] == 'success') {
        print('🔍 Estaciones en data: ${data['data']['stations']}');
        return RouteStationsResponse.fromJson(data['data']);
      } else {
        throw Exception("❌ Error en la respuesta: ${data['message']}");
      }
    } else {
      throw Exception("❌ Error al cargar paradas: ${response.body}");
    }
  }
}

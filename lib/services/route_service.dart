import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_model.dart';
import 'region_service.dart';

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

  // Método mejorado para obtener rutas por región usando la ruta específica
  static Future<List<RouteBasicModel>> fetchAllRoutes(String baseUrl, {String? regionId}) async {
    final currentRegion = regionId ?? RegionService.currentRegion.id;
    final url = Uri.parse('$baseUrl/location/routes/$currentRegion');
    
    print('📡 Solicitando rutas para región: $currentRegion');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final routes = (data['data'] as List)
            .map((json) => RouteBasicModel.fromJson(json))
            .toList();
        
        print('✅ Cargadas ${routes.length} rutas para región $currentRegion');
        
        return routes;
      } else {
        throw Exception("❌ Error en la respuesta: ${data['message']}");
      }
    } else {
      throw Exception("❌ Error al cargar rutas: ${response.body}");
    }
  }

  // Método para obtener regiones disponibles desde el backend
  static Future<List<Map<String, dynamic>>> fetchAvailableRegions(String baseUrl) async {
    final url = Uri.parse('$baseUrl/location/regions');
    print('📡 Solicitando regiones disponibles desde: $url');

    final response = await http.get(url);

    print('🔄 Código de respuesta: ${response.statusCode}');
    print('📦 Respuesta completa: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final regions = (data['data'] as List)
            .map((json) => json as Map<String, dynamic>)
            .toList();
        
        print('✅ Cargadas ${regions.length} regiones disponibles');
        return regions;
      } else {
        throw Exception("❌ Error en la respuesta: ${data['message']}");
      }
    } else {
      throw Exception("❌ Error al cargar regiones: ${response.body}");
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

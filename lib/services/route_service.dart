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
        final allRoutes = (data['data'] as List)
            .map((json) => RouteBasicModel.fromJson(json))
            .toList();
        
        // Filtrar rutas por región actual
        return _filterRoutesByRegion(allRoutes);
      } else {
        throw Exception("❌ Error en la respuesta: ${data['message']}");
      }
    } else {
      throw Exception("❌ Error al cargar rutas: ${response.body}");
    }
  }

  // Método para filtrar rutas por región
  static List<RouteBasicModel> _filterRoutesByRegion(List<RouteBasicModel> routes) {
    final currentRegion = RegionService.currentRegion;
    print('🌍 Filtrando rutas para la región: ${currentRegion.displayName}');

    // Si no hay rutas, retornar lista vacía
    if (routes.isEmpty) {
      print('📦 No hay rutas para filtrar');
      return routes;
    }

    // Filtrar rutas basándose en la región actual
    // Esto podría mejorarse con información de región en el modelo de ruta
    final filteredRoutes = routes.where((route) {
      // Por ahora, filtrar basándose en el nombre de la ruta o cualquier campo disponible
      // En una implementación real, las rutas deberían tener un campo de región
      
      // Verificar si la ruta contiene términos de la región actual
      final routeName = route.name.toLowerCase();
      final routeDescription = route.description.toLowerCase();
      
      // Buscar términos de la región en el nombre o descripción de la ruta
      final containsRegionTerms = currentRegion.searchTerms.any((term) => 
        routeName.contains(term.toLowerCase()) || 
        routeDescription.contains(term.toLowerCase())
      );

      if (containsRegionTerms) {
        print('✅ Ruta ${route.name} incluida para ${currentRegion.displayName}');
        return true;
      }

      // Si no hay términos específicos, incluir todas las rutas por defecto
      // Esto mantiene compatibilidad hasta que se implemente filtrado por región en el backend
      print('⚠️ Ruta ${route.name} incluida por defecto (sin filtro regional específico)');
      return true;
    }).toList();

    print('📊 Rutas filtradas: ${filteredRoutes.length} de ${routes.length}');
    return filteredRoutes;
  }

  // Método para obtener rutas por región específica (para uso futuro)
  static Future<List<RouteBasicModel>> fetchRoutesByRegion(String baseUrl, String regionId) async {
    final url = Uri.parse('$baseUrl/location/routes?region=$regionId');
    print('📡 Solicitando rutas para región $regionId desde: $url');

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

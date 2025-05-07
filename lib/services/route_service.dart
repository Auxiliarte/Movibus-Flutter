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
}

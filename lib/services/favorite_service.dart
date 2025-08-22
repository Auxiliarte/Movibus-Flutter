import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/favorite_location.dart';
import 'auth_service.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final AuthService _authService = AuthService();

  String getBackendUrl() {
    if (Platform.isAndroid) {
      return 'https://app.moventra.com.mx/api';
    } else {
      return 'https://app.moventra.com.mx/api';
    }
  }

  Future<String?> _getAuthToken() async {
    return await _authService.getToken();
  }

  Map<String, String> _getAuthHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Future<List<FavoriteLocation>> getFavorites() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await http.get(
        Uri.parse('${getBackendUrl()}/favorites'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final favorites = data['data'] as List;
          return favorites.map((json) => FavoriteLocation.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Error al obtener favoritos');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Usuario no autenticado');
      } else {
        throw Exception('Error al obtener favoritos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener favoritos: $e');
    }
  }

  Future<FavoriteLocation> getFavorite(int id) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await http.get(
        Uri.parse('${getBackendUrl()}/favorites/$id'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return FavoriteLocation.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Error al obtener favorito');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Ubicación favorita no encontrada');
      } else {
        throw Exception('Error al obtener favorito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener favorito: $e');
    }
  }

  Future<FavoriteLocation> createFavorite({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await http.post(
        Uri.parse('${getBackendUrl()}/favorites'),
        headers: _getAuthHeaders(token),
        body: json.encode({
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return FavoriteLocation.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Error al crear favorito');
        }
      } else if (response.statusCode == 409) {
        throw Exception('Ya existe una ubicación favorita con ese nombre');
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Datos de entrada inválidos');
      } else {
        throw Exception('Error al crear favorito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al crear favorito: $e');
    }
  }

  Future<bool> deleteFavorite(int id) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await http.delete(
        Uri.parse('${getBackendUrl()}/favorites/$id'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      } else if (response.statusCode == 404) {
        throw Exception('Ubicación favorita no encontrada');
      } else {
        throw Exception('Error al eliminar favorito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al eliminar favorito: $e');
    }
  }
}

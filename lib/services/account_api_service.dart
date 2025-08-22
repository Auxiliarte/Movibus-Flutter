// services/account_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account_status.dart';

class AccountApiService {
  static String get baseUrl {
    // Obtener URL base de la aplicación
    return 'https://app.moventra.com.mx/api';
  }

  Future<Map<String, dynamic>> deactivateAccount({
    required String password,
    String? reason,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/account/deactivate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'password': password,
          if (reason != null) 'reason': reason,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error al desactivar cuenta: $e');
    }
  }

  Future<AccountStatus> getAccountStatus(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/account/status'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AccountStatus.fromJson(data['data']);
      } else {
        throw Exception('Error al obtener estado de cuenta');
      }
    } catch (e) {
      throw Exception('Error al obtener estado de cuenta: $e');
    }
  }

  Future<Map<String, dynamic>> reactivateAccount({
    required int userId,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/account/reactivate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error al reactivar cuenta: $e');
    }
  }

  Future<Map<String, dynamic>> getInactiveUsers({
    required String token,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/account/inactive-users?page=$page&per_page=$perPage'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error al obtener usuarios inactivos: $e');
    }
  }
}

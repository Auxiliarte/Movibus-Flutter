// services/profile_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class ProfileApiService {
  static String get baseUrl {
    // Obtener URL base de la aplicación
    return 'https://app.moventra.com.mx/api';
  }

  Future<UserProfile> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/account/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UserProfile.fromJson(data['data']);
      } else {
        throw Exception('Error al obtener perfil');
      }
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    String? lastName,
    String? phone,
    String? birthDate,
    String? rfc,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (lastName != null) body['last_name'] = lastName;
      if (phone != null) body['phone'] = phone;
      if (birthDate != null) body['birth_date'] = birthDate;
      if (rfc != null) body['rfc'] = rfc;

      final response = await http.put(
        Uri.parse('$baseUrl/account/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfilePhoto({
    required String token,
    required File imageFile,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/account/profile/photo'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_photo',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error al actualizar foto de perfil: $e');
    }
  }

  Future<Map<String, dynamic>> deleteProfilePhoto(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/account/profile/photo'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error al eliminar foto de perfil: $e');
    }
  }
}

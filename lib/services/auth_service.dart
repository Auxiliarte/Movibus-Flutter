import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String getBackendUrl() {
    if (Platform.isAndroid) {
      return 'https://app.moventra.com.mx/api';
    } else {
      return 'https://app.moventra.com.mx/api';
    }
  }

  // Verificar si hay una sesión activa
  Future<bool> hasActiveSession() async {
    final token = await _secureStorage.read(key: 'auth_token');
    final rememberSession = await _secureStorage.read(key: 'remember_session');
    
    print('🔍 Verificando sesión - Token: ${token != null ? 'Sí' : 'No'} - Recordar: $rememberSession');
    
    if (token == null || rememberSession != 'true') {
      print('❌ No hay sesión activa - Token: ${token != null} - Recordar: $rememberSession');
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('${getBackendUrl()}/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('🌐 Verificación backend - Status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error verificando sesión: $e');
      return false;
    }
  }

  // Obtener el token actual
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Guardar token y preferencia de recordar sesión
  Future<void> saveSession(String token, bool rememberSession) async {
    print('🔐 Guardando sesión - Token: ${token.substring(0, 20)}... - Recordar: $rememberSession');
    await _secureStorage.write(key: 'auth_token', value: token);
    
    if (rememberSession) {
      await _secureStorage.write(key: 'remember_session', value: 'true');
      print('✅ Sesión guardada con recordar sesión');
    } else {
      await _secureStorage.delete(key: 'remember_session');
      print('✅ Sesión guardada sin recordar sesión');
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'remember_session');
  }

  // Verificar si el usuario marcó "recordar sesión"
  Future<bool> shouldRememberSession() async {
    final rememberSession = await _secureStorage.read(key: 'remember_session');
    return rememberSession == 'true';
  }

  // Método de debug para verificar el estado del almacenamiento
  Future<void> debugStorage() async {
    final token = await _secureStorage.read(key: 'auth_token');
    final rememberSession = await _secureStorage.read(key: 'remember_session');
    
    print('🔍 DEBUG STORAGE:');
    print('  - Token: ${token != null ? 'Sí (${token.substring(0, 20)}...)' : 'No'}');
    print('  - Recordar sesión: $rememberSession');
  }
} 
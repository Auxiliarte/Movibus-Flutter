import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:movibus/auth/login_screen.dart';
import 'package:movibus/screen/home_screen.dart';
import 'package:movibus/services/auth_service.dart';
import 'welcome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final AuthService _authService = AuthService();

  String getBackendUrl() {
    return _authService.getBackendUrl();
  }

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    print('🚀 Iniciando verificación de sesión...');
    await _authService.debugStorage(); // Debug del estado actual
    final hasActiveSession = await _authService.hasActiveSession();
    
    if (hasActiveSession) {
      print('✅ Sesión activa encontrada - Yendo al Home');
      _goToHome();
    } else {
      print('❌ No hay sesión activa - Yendo al Welcome');
      // Verificar si hay un token pero no está marcado como "recordar sesión"
      final token = await _secureStorage.read(key: 'auth_token');
      if (token != null) {
        print('🧹 Limpiando token sin recordar sesión');
        // Limpiar token si no está marcado como recordar sesión
        await _authService.logout();
      }
      _goToWelcome();
    }
  }

  void _goToWelcome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'dart:io' show Platform;

class LocationService {
  // Solicitar permisos de ubicación
  static Future<bool> requestLocationPermission() async {
    try {
      // En iOS, primero verificamos el estado actual
      final status = await permission_handler.Permission.location.status;
      
      if (status.isDenied) {
        // Solicitar permiso
        final result = await permission_handler.Permission.location.request();
        return result.isGranted;
      } else if (status.isPermanentlyDenied) {
        // El usuario denegó permanentemente, abrir configuración
        await openAppSettings();
        return false;
      } else if (status.isRestricted) {
        // Restringido por configuración del dispositivo
        return false;
      }
      
      return status.isGranted;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  // Verificar si los permisos están concedidos
  static Future<bool> hasLocationPermission() async {
    try {
      final status = await permission_handler.Permission.location.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }

  // Obtener ubicación actual con mejor manejo de errores
  static Future<Position?> getCurrentLocation() async {
    try {
      // Verificar permisos primero
      final hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        // Intentar solicitar permisos
        final granted = await requestLocationPermission();
        if (!granted) {
          throw Exception('Permisos de ubicación denegados. Por favor, habilita los permisos de ubicación en Configuración > Privacidad y Seguridad > Ubicación > Movibus');
        }
      }

      // Verificar si el GPS está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están deshabilitados. Por favor, habilita la ubicación en Configuración > Privacidad y Seguridad > Ubicación');
      }

      // Verificar permisos de ubicación específicos de Geolocator
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados por el sistema');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados permanentemente. Por favor, habilita los permisos en Configuración > Privacidad y Seguridad > Ubicación > Movibus');
      }

      // Obtener ubicación con timeout más largo para iOS
      final timeout = Platform.isIOS ? const Duration(seconds: 15) : const Duration(seconds: 10);
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeout,
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      if (e.toString().contains('timeout')) {
        throw Exception('Tiempo de espera agotado al obtener la ubicación. Verifica que el GPS esté habilitado y que tengas buena señal.');
      } else if (e.toString().contains('denied')) {
        throw Exception('Permisos de ubicación denegados. Ve a Configuración > Privacidad y Seguridad > Ubicación > Movibus y selecciona "Mientras usas la app"');
      } else {
        throw Exception('Error obteniendo ubicación: $e');
      }
    }
  }

  // Calcular distancia entre dos puntos
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Obtener dirección desde coordenadas
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Por ahora, retornamos las coordenadas como string
      // En una implementación futura se puede integrar con un servicio de geocoding
      return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      return null;
    }
  }

  // Método para abrir configuración de la app
  static Future<void> openAppSettings() async {
    await permission_handler.openAppSettings();
  }
} 
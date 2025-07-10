import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _googleApiKey = "AIzaSyA2NeKAZRdbRsy6cSj52TJRGJdf5wtlSA4";

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

  // Obtener dirección desde coordenadas usando Google Geocoding API
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=$latitude,$longitude'
          '&key=$_googleApiKey'
          '&language=es'
          '&result_type=street_address|route|premise|establishment'
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final formattedAddress = result['formatted_address'];
          
          // Filtrar solo direcciones de San Luis Potosí
          if (formattedAddress.toLowerCase().contains('san luis potosí') ||
              formattedAddress.toLowerCase().contains('slp')) {
            return formattedAddress;
          } else {
            // Si no es de SLP, devolver solo la parte principal
            final addressComponents = result['address_components'] as List;
            final streetNumber = addressComponents.firstWhere(
              (component) => component['types'].contains('street_number'),
              orElse: () => {'long_name': ''},
            )['long_name'];
            
            final route = addressComponents.firstWhere(
              (component) => component['types'].contains('route'),
              orElse: () => {'long_name': ''},
            )['long_name'];
            
            if (streetNumber.isNotEmpty && route.isNotEmpty) {
              return '$route $streetNumber, San Luis Potosí, SLP';
            } else if (route.isNotEmpty) {
              return '$route, San Luis Potosí, SLP';
            }
          }
        }
      }
      
      // Fallback: devolver coordenadas formateadas
      return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      print('Error obteniendo dirección: $e');
      // Fallback: devolver coordenadas formateadas
      return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    }
  }

  // Obtener coordenadas desde dirección usando Google Geocoding API
  static Future<Map<String, double>?> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?address=${Uri.encodeComponent(address)}'
          '&key=$_googleApiKey'
          '&language=es'
          '&components=country:mx|administrative_area:San Luis Potosí'
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final geometry = result['geometry'];
          final location = geometry['location'];
          
          return {
            'latitude': location['lat'].toDouble(),
            'longitude': location['lng'].toDouble(),
          };
        }
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo coordenadas: $e');
      return null;
    }
  }

  // Método para abrir configuración de la app
  static Future<void> openAppSettings() async {
    await permission_handler.openAppSettings();
  }
} 
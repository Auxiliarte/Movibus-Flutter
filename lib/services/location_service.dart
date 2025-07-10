import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static const String _googleMapsApiKey = "AIzaSyA2NeKAZRdbRsy6cSj52TJRGJdf5wtlSA4";

  // Solicitar permisos de ubicación
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Verificar si los permisos están concedidos
  static Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // Obtener ubicación actual
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Permisos de ubicación denegados');
      }

      // Verificar si el GPS está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están deshabilitados');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
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
          '&key=$_googleMapsApiKey'
          '&language=es'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          return result['formatted_address'];
        }
      }
    } catch (e) {
      print('Error obteniendo dirección: $e');
    }
    
    // Fallback: retornar coordenadas como string
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  // Obtener coordenadas desde dirección usando Google Geocoding API
  static Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?address=${Uri.encodeComponent(address)}'
          '&key=$_googleMapsApiKey'
          '&language=es'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final location = result['geometry']['location'];
          return {
            'latitude': location['lat'].toDouble(),
            'longitude': location['lng'].toDouble(),
          };
        }
      }
    } catch (e) {
      print('Error obteniendo coordenadas: $e');
    }
    
    return null;
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

  // Verificar si las coordenadas están en San Luis Potosí
  static bool isInSanLuisPotosi(double latitude, double longitude) {
    // Aproximadamente los límites de San Luis Potosí
    return latitude >= 22.0 && latitude <= 22.3 && 
           longitude >= -101.0 && longitude <= -100.9;
  }

  // Obtener ubicación actual con dirección
  static Future<Map<String, dynamic>?> getCurrentLocationWithAddress() async {
    try {
      final position = await getCurrentLocation();
      if (position != null) {
        final address = await getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'address': address,
          'accuracy': position.accuracy,
          'timestamp': position.timestamp,
        };
      }
    } catch (e) {
      print('Error obteniendo ubicación con dirección: $e');
    }
    
    return null;
  }
} 
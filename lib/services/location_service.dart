import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'region_service.dart';

class LocationService {
  static const String _googleApiKey = "AIzaSyA2NeKAZRdbRsy6cSj52TJRGJdf5wtlSA4";

  // Solicitar permisos de ubicación con mejor manejo para iOS
  static Future<bool> requestLocationPermission() async {
    try {
      print('🔍 Iniciando solicitud de permisos de ubicación...');
      
      // En iOS, primero verificamos el estado actual
      final status = await permission_handler.Permission.location.status;
      print('📱 Estado actual de permisos: $status');
      
      if (status.isDenied) {
        print('🚫 Permisos denegados, solicitando...');
        // Solicitar permiso
        final result = await permission_handler.Permission.location.request();
        print('✅ Resultado de solicitud: $result');
        return result.isGranted;
      } else if (status.isPermanentlyDenied) {
        print('🚫 Permisos denegados permanentemente');
        // El usuario denegó permanentemente, abrir configuración
        await openAppSettings();
        return false;
      } else if (status.isRestricted) {
        print('🚫 Permisos restringidos por configuración del dispositivo');
        // Restringido por configuración del dispositivo
        return false;
      } else if (status.isLimited) {
        print('⚠️ Permisos limitados (solo mientras usa la app)');
        return true; // En iOS, limited significa que funciona mientras usa la app
      }
      
      print('✅ Permisos ya concedidos');
      return status.isGranted;
    } catch (e) {
      print('❌ Error requesting location permission: $e');
      return false;
    }
  }

  // Verificar si los permisos están concedidos
  static Future<bool> hasLocationPermission() async {
    try {
      if (Platform.isIOS) {
        // En iOS, usar Geolocator para verificar permisos
        final permission = await Geolocator.checkPermission();
        print('🔍 Verificando permisos con Geolocator: $permission');
        return permission == LocationPermission.whileInUse || 
               permission == LocationPermission.always;
      } else {
        // En Android, usar permission_handler
        final status = await permission_handler.Permission.location.status;
        print('🔍 Verificando permisos con permission_handler: $status');
        return status.isGranted || status.isLimited;
      }
    } catch (e) {
      print('❌ Error checking location permission: $e');
      return false;
    }
  }

  // Obtener ubicación actual con mejor manejo de errores para iOS
  static Future<Position?> getCurrentLocation({bool autoSuggestRegionChange = true}) async {
    try {
      print('📍 Iniciando obtención de ubicación...');
      
      Position? position;
      
      if (Platform.isIOS) {
        // En iOS, usar solo Geolocator
        position = await _getCurrentLocationIOS();
      } else {
        // En Android, usar el flujo completo
        position = await _getCurrentLocationAndroid();
      }

      // Verificar si necesita cambio de región automáticamente
      if (position != null && autoSuggestRegionChange) {
        final suggestedRegion = RegionService.suggestRegionChange(
          position.latitude, 
          position.longitude
        );
        
        if (suggestedRegion != null) {
          // Cambiar automáticamente la región si es diferente
          if (suggestedRegion.id != RegionService.currentRegion.id) {
            print('🔄 Cambiando región automáticamente: ${RegionService.currentRegion.displayName} → ${suggestedRegion.displayName}');
            await RegionService.changeRegion(suggestedRegion);
          }
        }
      }

      return position;
    } catch (e) {
      print('❌ Error obteniendo ubicación: $e');
      if (e.toString().contains('timeout')) {
        throw Exception('Tiempo de espera agotado al obtener la ubicación. Verifica que el GPS esté habilitado y que tengas buena señal.');
      } else if (e.toString().contains('denied')) {
        throw Exception('Permisos de ubicación denegados. Ve a Configuración > Privacidad y Seguridad > Ubicación > Moventra y selecciona "Mientras usas la app"');
      } else {
        throw Exception('Error obteniendo ubicación: $e');
      }
    }
  }

  // Método específico para iOS
  static Future<Position?> _getCurrentLocationIOS() async {
    // Verificar si el GPS está habilitado
    print('🔍 Verificando servicios de ubicación...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('📡 Servicios de ubicación: $serviceEnabled');
    
    if (!serviceEnabled) {
      print('❌ Servicios de ubicación deshabilitados');
      throw Exception('Los servicios de ubicación están deshabilitados. Por favor, habilita la ubicación en Configuración > Privacidad y Seguridad > Ubicación');
    }

    // Verificar permisos de ubicación específicos de Geolocator
    print('🔍 Verificando permisos de Geolocator...');
    LocationPermission permission = await Geolocator.checkPermission();
    print('📱 Permisos de Geolocator: $permission');
    
    if (permission == LocationPermission.denied) {
      print('🚫 Permisos denegados en Geolocator, solicitando...');
      permission = await Geolocator.requestPermission();
      print('✅ Resultado de solicitud Geolocator: $permission');
      
      if (permission == LocationPermission.denied) {
        print('❌ Permisos denegados por el sistema');
        throw Exception('Permisos de ubicación denegados por el sistema');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('❌ Permisos denegados permanentemente');
      throw Exception('Permisos de ubicación denegados permanentemente. Por favor, habilita los permisos en Configuración > Privacidad y Seguridad > Ubicación > Moventra');
    }

    // Obtener ubicación con timeout más largo para iOS
    final timeout = const Duration(seconds: 20);
    print('⏱️ Timeout configurado: ${timeout.inSeconds} segundos');
    
    print('📍 Obteniendo posición actual...');
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: timeout,
    );
    
    print('✅ Ubicación obtenida: ${position.latitude}, ${position.longitude}');
    return position;
  }

  // Método específico para Android
  static Future<Position?> _getCurrentLocationAndroid() async {
    // Verificar permisos primero
    final hasPermission = await hasLocationPermission();
    print('🔐 Permisos verificados: $hasPermission');
    
    if (!hasPermission) {
      print('🚫 Sin permisos, solicitando...');
      // Intentar solicitar permisos
      final granted = await requestLocationPermission();
      if (!granted) {
        print('❌ Permisos no concedidos');
        throw Exception('Permisos de ubicación denegados. Por favor, habilita los permisos de ubicación en Configuración > Privacidad y Seguridad > Ubicación > Moventra');
      }
    }

    // Verificar si el GPS está habilitado
    print('🔍 Verificando servicios de ubicación...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('📡 Servicios de ubicación: $serviceEnabled');
    
    if (!serviceEnabled) {
      print('❌ Servicios de ubicación deshabilitados');
      throw Exception('Los servicios de ubicación están deshabilitados. Por favor, habilita la ubicación en Configuración > Privacidad y Seguridad > Ubicación');
    }

    // Verificar permisos de ubicación específicos de Geolocator
    print('🔍 Verificando permisos de Geolocator...');
    LocationPermission permission = await Geolocator.checkPermission();
    print('📱 Permisos de Geolocator: $permission');
    
    if (permission == LocationPermission.denied) {
      print('🚫 Permisos denegados en Geolocator, solicitando...');
      permission = await Geolocator.requestPermission();
      print('✅ Resultado de solicitud Geolocator: $permission');
      
      if (permission == LocationPermission.denied) {
        print('❌ Permisos denegados por el sistema');
        throw Exception('Permisos de ubicación denegados por el sistema');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('❌ Permisos denegados permanentemente');
      throw Exception('Permisos de ubicación denegados permanentemente. Por favor, habilita los permisos en Configuración > Privacidad y Seguridad > Ubicación > Moventra');
    }

    // Obtener ubicación con timeout
    final timeout = const Duration(seconds: 10);
    print('⏱️ Timeout configurado: ${timeout.inSeconds} segundos');
    
    print('📍 Obteniendo posición actual...');
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: timeout,
    );
    
    print('✅ Ubicación obtenida: ${position.latitude}, ${position.longitude}');
    return position;
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
    double longitude, {
    bool autoSuggestRegionChange = true,
  }) async {
    try {
      // Verificar si necesita cambio de región antes de hacer la consulta
      if (autoSuggestRegionChange) {
        final suggestedRegion = RegionService.suggestRegionChange(latitude, longitude);
        if (suggestedRegion != null) {
          print('💡 Coordenadas ($latitude, $longitude) están en ${suggestedRegion.displayName}');
          print('💡 Considera cambiar la región para mejores resultados de búsqueda');
        }
      }

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
          
          // Verificar si la dirección está dentro de la región actual
          final currentRegion = RegionService.currentRegion;
          
          // Verificar si las coordenadas están dentro de la región actual
          final isWithinCurrentRegion = RegionService.isWithinCurrentRegion(latitude, longitude);
          
          if (isWithinCurrentRegion && currentRegion.containsRegionTerms(formattedAddress)) {
            // Si está dentro de la región actual y contiene términos de la región, devolver tal como viene
            return formattedAddress;
          } else if (isWithinCurrentRegion) {
            // Si está dentro de la región pero no contiene términos, agregar información de región
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
              return '$route $streetNumber, ${currentRegion.displayName}, ${currentRegion.state}';
            } else if (route.isNotEmpty) {
              return '$route, ${currentRegion.displayName}, ${currentRegion.state}';
            }
          } else {
            // Si está fuera de la región actual, devolver la dirección real tal como viene de Google
            return formattedAddress;
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
          '&components=country:${RegionService.currentRegion.countryCode}|administrative_area:${RegionService.currentRegion.state}'
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

  // Método específico para iOS que fuerza la solicitud de permisos
  static Future<bool> forceRequestLocationPermission() async {
    try {
      print('🔍 Forzando solicitud de permisos de ubicación...');
      
      if (Platform.isIOS) {
        // En iOS, usar Geolocator directamente para solicitar permisos
        LocationPermission permission = await Geolocator.checkPermission();
        print('📱 Permisos actuales de Geolocator: $permission');
        
        if (permission == LocationPermission.denied) {
          print('🚫 Permisos denegados, solicitando...');
          permission = await Geolocator.requestPermission();
          print('✅ Resultado de solicitud Geolocator: $permission');
        }
        
        return permission == LocationPermission.whileInUse || 
               permission == LocationPermission.always;
      } else {
        // En Android, usar el método normal
        return await requestLocationPermission();
      }
    } catch (e) {
      print('❌ Error forzando solicitud de permisos: $e');
      return false;
    }
  }

  // Método para verificar si los servicios de ubicación están habilitados
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('❌ Error verificando servicios de ubicación: $e');
      return false;
    }
  }

  // Método para obtener el estado actual de los permisos
  static Future<String> getLocationPermissionStatus() async {
    try {
      if (Platform.isIOS) {
        final permission = await Geolocator.checkPermission();
        switch (permission) {
          case LocationPermission.denied:
            return 'Denegado';
          case LocationPermission.deniedForever:
            return 'Denegado Permanentemente';
          case LocationPermission.whileInUse:
            return 'Concedido - Mientras usa app';
          case LocationPermission.always:
            return 'Concedido - Siempre';
          case LocationPermission.unableToDetermine:
            return 'No se puede determinar';
        }
      } else {
        final status = await permission_handler.Permission.location.status;
        switch (status) {
          case permission_handler.PermissionStatus.denied:
            return 'Denegado';
          case permission_handler.PermissionStatus.granted:
            return 'Concedido';
          case permission_handler.PermissionStatus.restricted:
            return 'Restringido';
          case permission_handler.PermissionStatus.limited:
            return 'Limitado';
          case permission_handler.PermissionStatus.permanentlyDenied:
            return 'Denegado Permanentemente';
          default:
            return 'Desconocido';
        }
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
} 
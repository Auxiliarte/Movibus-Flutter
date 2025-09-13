import 'package:shared_preferences/shared_preferences.dart';
import '../models/region_model.dart';

class RegionService {
  static const String _regionKey = 'selected_region_id';
  static RegionModel? _currentRegion;

  // Obtener la región actual
  static RegionModel get currentRegion {
    return _currentRegion ?? RegionModel.sanLuisPotosi;
  }

  // Verificar si hay una región seleccionada
  static bool get hasSelectedRegion => _currentRegion != null;

  // Inicializar el servicio de regiones
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRegionId = prefs.getString(_regionKey);
      
      if (savedRegionId != null) {
        _currentRegion = RegionModel.getById(savedRegionId);
        print('🌍 Región cargada: ${_currentRegion?.displayName ?? 'No encontrada'}');
      } else {
        // Si no hay región guardada, usar San Luis Potosí por defecto
        _currentRegion = RegionModel.sanLuisPotosi;
        await saveSelectedRegion(_currentRegion!);
        print('🌍 Usando región por defecto: ${_currentRegion!.displayName}');
      }
    } catch (e) {
      print('❌ Error inicializando RegionService: $e');
      _currentRegion = RegionModel.sanLuisPotosi;
    }
  }

  // Guardar región seleccionada
  static Future<bool> saveSelectedRegion(RegionModel region) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_regionKey, region.id);
      _currentRegion = region;
      print('✅ Región guardada: ${region.displayName}');
      return true;
    } catch (e) {
      print('❌ Error guardando región: $e');
      return false;
    }
  }

  // Cambiar región actual
  static Future<bool> changeRegion(RegionModel region) async {
    if (region.id == _currentRegion?.id) {
      return true; // No hay cambio
    }

    final success = await saveSelectedRegion(region);
    if (success) {
      print('🔄 Región cambiada a: ${region.displayName}');
      // Aquí podrías emitir eventos para notificar a otros servicios
      _notifyRegionChange(region);
    }
    return success;
  }

  // Obtener todas las regiones disponibles
  static List<RegionModel> getAvailableRegions() {
    return RegionModel.availableRegions.where((region) => region.isActive).toList();
  }

  // Buscar regiones por texto
  static List<RegionModel> searchRegions(String query) {
    if (query.isEmpty) return getAvailableRegions();

    final lowerQuery = query.toLowerCase();
    return getAvailableRegions().where((region) {
      return region.displayName.toLowerCase().contains(lowerQuery) ||
             region.state.toLowerCase().contains(lowerQuery) ||
             region.country.toLowerCase().contains(lowerQuery) ||
             region.searchTerms.any((term) => term.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Detectar región basada en coordenadas
  static RegionModel? detectRegionFromCoordinates(double latitude, double longitude) {
    const double tolerance = 0.5; // Tolerancia en grados

    for (final region in getAvailableRegions()) {
      final latDiff = (latitude - region.centerLatitude).abs();
      final lngDiff = (longitude - region.centerLongitude).abs();

      if (latDiff <= tolerance && lngDiff <= tolerance) {
        print('🌍 Región detectada: ${region.displayName} para coordenadas ($latitude, $longitude)');
        return region;
      }
    }
    
    print('🌍 No se detectó región para coordenadas ($latitude, $longitude)');
    return null;
  }

  // Sugerir cambio de región si las coordenadas están en otra región
  static RegionModel? suggestRegionChange(double latitude, double longitude) {
    final detectedRegion = detectRegionFromCoordinates(latitude, longitude);
    
    if (detectedRegion != null && detectedRegion.id != currentRegion.id) {
      print('💡 Sugerencia: cambiar de ${currentRegion.displayName} a ${detectedRegion.displayName}');
      return detectedRegion;
    }
    
    return null;
  }

  // Cambio automático de región basado en coordenadas (opcional)
  static Future<bool> autoChangeRegionIfNeeded(double latitude, double longitude, {bool force = false}) async {
    final suggestedRegion = suggestRegionChange(latitude, longitude);
    
    if (suggestedRegion != null) {
      if (force) {
        // Cambio automático forzado
        print('🔄 Cambiando automáticamente a ${suggestedRegion.displayName}');
        return await changeRegion(suggestedRegion);
      } else {
        // Solo sugerir, no cambiar automáticamente
        print('💡 Región sugerida: ${suggestedRegion.displayName} (usar force=true para cambio automático)');
        return false;
      }
    }
    
    return false; // No hay cambio necesario
  }

  // Cambio inteligente de región para búsquedas
  static Future<bool> smartRegionChangeForSearch(double? latitude, double? longitude) async {
    if (latitude == null || longitude == null) return false;
    
    final suggestedRegion = suggestRegionChange(latitude, longitude);
    
    if (suggestedRegion != null) {
      print('🤖 Cambio automático de región para mejorar búsquedas');
      print('🤖 Cambiando de ${currentRegion.displayName} a ${suggestedRegion.displayName}');
      
      final success = await changeRegion(suggestedRegion);
      if (success) {
        print('✅ Región cambiada exitosamente para búsquedas');
        await incrementCurrentRegionUsage();
      }
      return success;
    }
    
    return false;
  }

  // Verificar si unas coordenadas están dentro de la región actual
  static bool isWithinCurrentRegion(double latitude, double longitude) {
    final region = currentRegion;
    const double radiusInDegrees = 0.45; // Aproximadamente 50km

    final latDiff = (latitude - region.centerLatitude).abs();
    final lngDiff = (longitude - region.centerLongitude).abs();

    return latDiff <= radiusInDegrees && lngDiff <= radiusInDegrees;
  }

  // Obtener información de configuración para Google Places API
  static Map<String, String> getPlacesApiConfig() {
    final region = currentRegion;
    return {
      'location': '${region.centerLatitude},${region.centerLongitude}',
      'radius': region.searchRadius.toString(),
      'components': 'country:${region.countryCode}',
      'language': 'es',
    };
  }

  // Formatear entrada de búsqueda para la región actual
  static String formatSearchInput(String input) {
    return currentRegion.formatSearchInput(input);
  }

  // Verificar si un texto contiene términos de la región actual
  static bool containsCurrentRegionTerms(String text) {
    return currentRegion.containsRegionTerms(text);
  }

  // Limpiar datos guardados
  static Future<void> clearSavedRegion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_regionKey);
      _currentRegion = RegionModel.sanLuisPotosi;
      print('🧹 Región guardada limpiada');
    } catch (e) {
      print('❌ Error limpiando región guardada: $e');
    }
  }

  // Notificar cambio de región (para futuras implementaciones con streams)
  static void _notifyRegionChange(RegionModel newRegion) {
    // Aquí podrías implementar un stream controller para notificar cambios
    // Por ahora solo imprimimos el cambio
    print('🔔 Notificando cambio de región a: ${newRegion.displayName}');
  }

  // Obtener estadísticas de uso de regiones
  static Future<Map<String, int>> getRegionUsageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, int> stats = {};
      
      for (final region in getAvailableRegions()) {
        final key = 'region_usage_${region.id}';
        stats[region.id] = prefs.getInt(key) ?? 0;
      }
      
      return stats;
    } catch (e) {
      print('❌ Error obteniendo estadísticas de regiones: $e');
      return {};
    }
  }

  // Incrementar contador de uso de región actual
  static Future<void> incrementCurrentRegionUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'region_usage_${currentRegion.id}';
      final currentCount = prefs.getInt(key) ?? 0;
      await prefs.setInt(key, currentCount + 1);
    } catch (e) {
      print('❌ Error incrementando uso de región: $e');
    }
  }
}

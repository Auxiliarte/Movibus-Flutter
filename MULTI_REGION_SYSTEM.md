# 🌍 Sistema Multi-Región - Movibus Flutter

Este documento describe la implementación del sistema multi-región que permite a la aplicación Movibus funcionar en múltiples ciudades y países, reemplazando la configuración hardcodeada específica para San Luis Potosí.

## 🎯 Objetivo

Transformar la aplicación de una implementación específica para San Luis Potosí a un sistema flexible que pueda funcionar en múltiples regiones, permitiendo:

- Selección dinámica de región por parte del usuario
- Búsquedas de lugares específicas por región
- Mapas centrados en la región seleccionada
- Filtrado de rutas por región
- Persistencia de la región seleccionada

## 🏗️ Arquitectura Implementada

### 1. Modelo de Región (`RegionModel`)

**Ubicación:** `lib/models/region_model.dart`

Modelo que encapsula toda la información necesaria para una región:

```dart
class RegionModel {
  final String id;              // Identificador único
  final String name;            // Nombre interno
  final String displayName;     // Nombre para mostrar
  final String country;         // País
  final String countryCode;     // Código de país (ISO)
  final String state;           // Estado/Provincia
  final double centerLatitude;  // Latitud del centro
  final double centerLongitude; // Longitud del centro
  final int searchRadius;       // Radio de búsqueda en metros
  final double defaultZoom;     // Zoom por defecto del mapa
  final List<String> searchTerms; // Términos para filtrar búsquedas
  final bool isActive;          // Si la región está activa
}
```

**Regiones Predefinidas:**
- San Luis Potosí, México
- Guadalajara, Jalisco
- Ciudad de México
- Monterrey, Nuevo León
- Puebla, Puebla

### 2. Servicio de Regiones (`RegionService`)

**Ubicación:** `lib/services/region_service.dart`

Servicio centralizado que maneja toda la lógica relacionada con regiones:

#### Funcionalidades Principales:

- **Inicialización:** Carga la región guardada o usa SLP por defecto
- **Persistencia:** Guarda/carga la región seleccionada usando SharedPreferences
- **Gestión:** Cambio de región con notificaciones
- **Configuración:** Proporciona configuraciones específicas para APIs
- **Búsqueda:** Búsqueda y filtrado de regiones disponibles

#### Métodos Clave:

```dart
// Inicializar el servicio
static Future<void> initialize()

// Obtener región actual
static RegionModel get currentRegion

// Cambiar región
static Future<bool> changeRegion(RegionModel region)

// Configuración para Google Places API
static Map<String, String> getPlacesApiConfig()

// Formatear entrada de búsqueda
static String formatSearchInput(String input)
```

### 3. Widget Selector de Región (`RegionSelectorWidget`)

**Ubicación:** `lib/widgets/region_selector_widget.dart`

Widget reutilizable para selección de regiones con dos modos:

#### Modo Inline:
```dart
RegionSelectorWidget(
  onRegionChanged: (region) => handleRegionChange(region),
)
```

#### Modo Modal:
```dart
showRegionSelectorModal(context).then((region) {
  if (region != null) handleRegionChange(region);
});
```

#### Características:
- Búsqueda en tiempo real
- Interfaz intuitiva con iconos
- Indicador de región actual
- Soporte para temas claro/oscuro

### 4. Pantalla de Configuración (`RegionSettingsScreen`)

**Ubicación:** `lib/screen/region_settings_screen.dart`

Pantalla completa para gestión de regiones que incluye:

- **Tarjeta de región actual** con información detallada
- **Explicación** de qué hace el cambio de región
- **Selector interactivo** de regiones
- **Estadísticas de uso** (opcional)

### 5. Indicador de Región (`RegionIndicatorWidget`)

**Ubicación:** `lib/widgets/Home/region_indicator_widget.dart`

Widget compacto para mostrar la región actual en la interfaz principal:

```dart
// Indicador completo
RegionIndicatorWidget(
  onRegionChanged: () => refreshData(),
)

// Indicador compacto
CompactRegionIndicator(
  onTap: () => showRegionSelector(),
)
```

## 🔧 Servicios Actualizados

### 1. PlacesService

**Cambios realizados:**
- Eliminadas coordenadas hardcodeadas de San Luis Potosí
- Uso dinámico de `RegionService.getPlacesApiConfig()`
- Filtrado automático por región actual
- Formateo dinámico de búsquedas con `RegionService.formatSearchInput()`

**Métodos actualizados:**
- `searchPlaces()`
- `searchEstablishments()`
- `searchAddresses()`

### 2. LocationService

**Cambios realizados:**
- Filtrado de direcciones por región actual
- Componentes de geocodificación dinámicos
- Formateo de direcciones específico por región

### 3. RouteService

**Cambios realizados:**
- Filtrado de rutas por región (basado en términos de búsqueda)
- Método `_filterRoutesByRegion()` para filtrado inteligente
- Soporte para futuras implementaciones de filtrado por región en backend

## 🗺️ Pantallas de Mapa Actualizadas

Todas las pantallas que usan Google Maps fueron actualizadas para usar coordenadas dinámicas:

### Pantallas Modificadas:
- `location_picker_screen.dart`
- `home_screen.dart`
- `route_detail_screen.dart`
- `route_stations_map_screen.dart`
- `google_maps_test_screen.dart`

### Cambios Realizados:
- Reemplazadas coordenadas hardcodeadas con `RegionService.currentRegion`
- Uso dinámico de zoom por defecto
- Centrado automático en la región seleccionada

## 🚀 Inicialización

### En `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar el servicio de regiones
  await RegionService.initialize();
  
  runApp(MyApp());
}
```

### Rutas Agregadas:
- `/regionSettings` → `RegionSettingsScreen`

## 💾 Persistencia de Datos

### SharedPreferences
- **Clave:** `selected_region_id`
- **Valor:** ID de la región seleccionada
- **Estadísticas:** `region_usage_{regionId}` para contadores de uso

### Comportamiento:
1. **Primera vez:** Usa San Luis Potosí por defecto
2. **Cambio de región:** Guarda inmediatamente la nueva selección
3. **Reinicio de app:** Carga la última región seleccionada

## 🎨 Integración de UI

### Temas
- Agregado `AppColors.primaryColor` getter para compatibilidad
- Soporte completo para temas claro/oscuro
- Iconos y colores consistentes en toda la aplicación

### Experiencia de Usuario
- **Transiciones suaves** entre regiones
- **Feedback visual** con SnackBars
- **Indicadores claros** de región actual
- **Búsqueda intuitiva** de regiones

## 📊 Beneficios de la Implementación

### Para Usuarios:
- ✅ Flexibilidad para usar la app en múltiples ciudades
- ✅ Búsquedas más precisas y relevantes
- ✅ Mapas centrados correctamente
- ✅ Rutas específicas de su región

### Para Desarrolladores:
- ✅ Código más mantenible y escalable
- ✅ Fácil agregar nuevas regiones
- ✅ Configuración centralizada
- ✅ Separación clara de responsabilidades

### Para el Negocio:
- ✅ Expansión a nuevos mercados simplificada
- ✅ Personalización por región
- ✅ Datos de uso por región
- ✅ Escalabilidad internacional

## 🔮 Futuras Mejoras

### Backend Integration
- Endpoint para obtener regiones dinámicamente
- Filtrado de rutas por región en el servidor
- Sincronización de configuraciones regionales

### Funcionalidades Avanzadas
- Detección automática de región por GPS
- Regiones personalizadas por usuario
- Configuraciones específicas por región (idioma, moneda, etc.)
- Analytics detallados por región

### Optimizaciones
- Cache de búsquedas por región
- Precarga de datos regionales
- Compresión de configuraciones

## 🧪 Testing

### Casos de Prueba Recomendados:
1. **Cambio de región** - Verificar persistencia y actualización de UI
2. **Búsquedas** - Confirmar filtrado correcto por región
3. **Mapas** - Validar centrado automático
4. **Rutas** - Verificar filtrado de rutas por región
5. **Persistencia** - Confirmar carga correcta al reiniciar app

### Regiones de Prueba:
- San Luis Potosí (región por defecto)
- Ciudad de México (región grande)
- Guadalajara (región media)
- Monterrey (región industrial)
- Puebla (región histórica)

## 📝 Notas de Implementación

### Compatibilidad Hacia Atrás:
- La región por defecto sigue siendo San Luis Potosí
- Todas las funcionalidades existentes se mantienen
- No se requieren cambios en bases de datos existentes

### Configuración Actual:
- 5 regiones predefinidas en México
- Radio de búsqueda: 50km (80km para CDMX)
- Zoom por defecto: 12.0 (11.0 para CDMX)
- Persistencia automática habilitada

Este sistema proporciona una base sólida para la expansión geográfica de Movibus, manteniendo la simplicidad de uso mientras ofrece flexibilidad técnica para futuras mejoras y expansiones.

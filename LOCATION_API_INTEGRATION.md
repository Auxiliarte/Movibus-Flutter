# 📱 Integración de API de Ubicación y Tracking - Movibus Flutter

Esta documentación explica la integración completa de la API de ubicación y tracking de Moventra con la aplicación Flutter Movibus.

## 🚀 Características Implementadas

### ✅ Funcionalidades Principales
- **Estación Más Cercana**: Encuentra la estación más cercana a la ubicación del usuario
- **Sugerencias de Rutas**: Sugiere las mejores rutas basándose en ubicación y destino
- **Información de Tracking**: Obtiene información en tiempo real de las rutas
- **Gestión de Ubicación**: Manejo de permisos y obtención de ubicación del dispositivo
- **Interfaz de Usuario**: Widgets modernos y responsivos para todas las funcionalidades

### 📱 Widgets Creados
1. **NearestStationWidget**: Muestra la estación más cercana con información detallada
2. **RouteSuggestionsWidget**: Presenta sugerencias de rutas con tiempos y distancias
3. **EnhancedSearchInput**: Campo de búsqueda mejorado con botón de ubicación actual

## 🏗️ Arquitectura de la Integración

### 📁 Estructura de Archivos

```
lib/
├── services/
│   ├── location_api_service.dart      # Servicio para llamadas a la API
│   └── location_service.dart          # Servicio de ubicación del dispositivo
├── models/
│   ├── station_model.dart             # Modelo de estación
│   └── route_suggestion_model.dart    # Modelo de sugerencia de ruta
├── widgets/Home/
│   ├── nearest_station_widget.dart    # Widget de estación más cercana
│   ├── route_suggestions_widget.dart  # Widget de sugerencias de rutas
│   └── enhanced_search_input.dart     # Campo de búsqueda mejorado
├── screen/
│   ├── home_screen.dart               # Pantalla principal actualizada
│   └── location_test_screen.dart      # Pantalla de pruebas
└── main.dart                          # Configuración de rutas
```

### 🔧 Servicios Implementados

#### LocationApiService
```dart
// Endpoints disponibles:
- findNearestStation()     // POST /location/nearest-station
- suggestRoute()           // POST /location/suggest-route
- getAllRoutes()           // GET /location/routes
- getRouteStations()       // GET /location/route/{id}/stations
- getTrackingInfo()        // GET /location/route/{id}/tracking
```

#### LocationService
```dart
// Funcionalidades:
- requestLocationPermission()    // Solicitar permisos
- getCurrentLocation()           // Obtener ubicación actual
- calculateDistance()            // Calcular distancias
- getAddressFromCoordinates()    // Geocoding inverso
```

## 🎯 Uso en la Aplicación

### 1. Pantalla Principal (HomeScreen)
- **Estación Más Cercana**: Widget siempre visible que permite encontrar la estación más cercana
- **Búsqueda Mejorada**: Campo de origen con botón de ubicación actual
- **Sugerencias de Rutas**: Se muestran automáticamente cuando se especifica un destino

### 2. Pantalla de Pruebas (LocationTestScreen)
- **Acceso**: Botón de ubicación en la esquina superior derecha del home
- **Funcionalidades**: Prueba completa de todos los endpoints de la API
- **Debugging**: Muestra información detallada de respuestas y errores

## 🔌 Configuración de Dependencias

### pubspec.yaml
```yaml
dependencies:
  geolocator: ^10.1.0          # Ubicación del dispositivo
  permission_handler: ^11.0.1   # Gestión de permisos
  http: ^0.13.0                # Llamadas HTTP (ya existía)
```

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<application
    android:usesCleartextTraffic="true"
    ...>
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Esta app necesita acceso a la ubicación para encontrar la estación más cercana y sugerir rutas</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Esta app necesita acceso a la ubicación para encontrar la estación más cercana y sugerir rutas</string>
```

## 🌐 Configuración de API

### Base URL
```dart
static const String baseUrl = 'https://app.moventra.com.mx/api';
```

### Endpoints Implementados

#### 1. Encontrar Estación Más Cercana
```dart
POST /location/nearest-station
{
  "latitude": 22.1497,
  "longitude": -100.9764,
  "route_id": 6  // Opcional
}
```

#### 2. Sugerir Rutas
```dart
POST /location/suggest-route
{
  "user_latitude": 22.1497,
  "user_longitude": -100.9764,
  "destination_latitude": 22.1540,
  "destination_longitude": -100.9715,
  "max_walking_distance": 1500
}
```

#### 3. Obtener Todas las Rutas
```dart
GET /location/routes
```

#### 4. Obtener Estaciones de Ruta
```dart
GET /location/route/{routeId}/stations
```

#### 5. Información de Tracking
```dart
GET /location/route/{routeId}/tracking
```

## 🎨 Características de UI/UX

### Diseño Responsivo
- **Cards modernas** con bordes redondeados
- **Iconografía consistente** para mejor comprensión
- **Estados de carga** con indicadores visuales
- **Manejo de errores** con mensajes informativos

### Interacciones
- **Botones de acción** claros y accesibles
- **Feedback visual** para todas las acciones
- **Tooltips informativos** para mejor usabilidad
- **Estados de carga** para operaciones asíncronas

## 🧪 Pruebas y Debugging

### Pantalla de Pruebas
Accede a `/locationTest` para probar todas las funcionalidades:

1. **Estación Más Cercana**: Prueba con ubicación real
2. **Sugerencias de Rutas**: Con coordenadas de ejemplo
3. **Todas las Rutas**: Lista completa de rutas disponibles
4. **Tracking en Tiempo Real**: Información de tracking por ruta

### Logs y Debugging
- **Errores de red**: Mostrados en SnackBars
- **Errores de ubicación**: Mensajes descriptivos
- **Estados de carga**: Indicadores visuales
- **Respuestas de API**: Mostradas en la pantalla de pruebas

## 🔄 Flujo de Datos

### 1. Obtención de Ubicación
```
Usuario presiona botón → Solicitar permisos → Obtener GPS → Geocoding inverso → Mostrar dirección
```

### 2. Búsqueda de Estación Cercana
```
Ubicación actual → API call → Procesar respuesta → Mostrar información de estación
```

### 3. Sugerencias de Rutas
```
Origen + Destino → API call → Procesar sugerencias → Mostrar opciones ordenadas
```

## 🚨 Manejo de Errores

### Tipos de Errores Manejados
- **Permisos denegados**: Mensaje claro con instrucciones
- **GPS deshabilitado**: Solicitud de habilitar servicios de ubicación
- **Errores de red**: Timeout y problemas de conectividad
- **Errores de API**: Respuestas de error del servidor

### Estrategias de Recuperación
- **Reintentos automáticos** para errores temporales
- **Fallbacks** a datos locales cuando sea posible
- **Mensajes informativos** para guiar al usuario
- **Opciones de configuración** para ajustar parámetros

## 🔮 Próximas Mejoras

### Funcionalidades Planificadas
- [ ] **Geocoding directo** para destinos ingresados manualmente
- [ ] **Caché local** de rutas y estaciones
- [ ] **Notificaciones push** para llegadas de buses
- [ ] **Mapa interactivo** con estaciones y rutas
- [ ] **Historial de búsquedas** con favoritos
- [ ] **Modo offline** con datos sincronizados

### Optimizaciones Técnicas
- [ ] **Lazy loading** para listas grandes
- [ ] **Compresión de datos** para reducir uso de red
- [ ] **Background location** para tracking continuo
- [ ] **Analytics** de uso de funcionalidades
- [ ] **A/B testing** para optimizar UX

## 📞 Soporte y Mantenimiento

### Monitoreo
- **Logs de errores** para identificar problemas
- **Métricas de rendimiento** para optimizaciones
- **Feedback de usuarios** para mejoras continuas

### Actualizaciones
- **Versiones de API** compatibles con cambios
- **Dependencias** actualizadas regularmente
- **Documentación** mantenida al día

---

## 🎉 ¡Integración Completada!

La integración de la API de ubicación y tracking está completamente funcional y lista para producción. Todos los endpoints están implementados, la UI es moderna y responsiva, y el manejo de errores es robusto.

**Para probar**: Ejecuta la aplicación y presiona el botón de ubicación en la pantalla principal, o navega directamente a `/locationTest` para ver todas las funcionalidades en acción. 
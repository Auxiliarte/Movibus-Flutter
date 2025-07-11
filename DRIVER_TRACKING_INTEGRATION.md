# Integración del Sistema de Tracking de Choferes

## Descripción General

Este documento describe la integración del sistema de tracking en tiempo real de choferes en la aplicación móvil de Flutter. El sistema permite a los usuarios ver la ubicación actual del autobús, el tiempo estimado de llegada a cada estación y el estado del trayecto.

## Componentes del Sistema

### 1. Servicio de Tracking (`DriverTrackingService`)

**Archivo:** `lib/services/driver_tracking_service.dart`

#### Funcionalidades principales:

- **`getPublicTracking()`**: Obtiene el tracking público de todos los choferes activos
- **`getDriverTrackingByRoute(routeId)`**: Obtiene el tracking específico de una ruta
- **`calculateEstimatedArrival()`**: Calcula el tiempo estimado de llegada a una estación
- **`formatTrackingInfo()`**: Formatea la información de tracking para la UI

#### Endpoints utilizados:

```dart
// Tracking público
GET /api/tracking/drivers?route_id={routeId}

// Tracking por ruta específica
GET /api/tracking/route/{routeId}
```

### 2. Widget de Tracking del Autobús (`BusTrackingWidget`)

**Archivo:** `lib/widgets/Home/bus_tracking_widget.dart`

#### Características:

- **Actualización automática**: Se actualiza cada 30 segundos
- **Estados visuales**: 
  - Cargando (spinner)
  - Error de conexión (rojo)
  - Sin autobús activo (naranja)
  - Autobús en ruta (verde)
- **Información mostrada**:
  - Nombre del chofer
  - Ubicación actual
  - Estación más cercana
  - Tiempo estimado de llegada
  - Última actualización

### 3. Widget de Estaciones con ETA (`StationListWithETA`)

**Archivo:** `lib/widgets/Home/station_eta_widget.dart`

#### Funcionalidades:

- **Lista de estaciones**: Muestra todas las estaciones de la ruta
- **Tiempos estimados**: Calcula y muestra el tiempo de llegada a cada estación
- **Estados visuales**:
  - Estación actual (verde)
  - Próxima estación (azul)
  - Otras estaciones (gris)
- **Información detallada**: Distancia, tiempo caminando, orden de estación

## Integración en la Pantalla de Detalles de Ruta

### Nuevo Tab "Tracking"

La pantalla `RouteDetailScreen` ahora incluye un nuevo tab dedicado al tracking en tiempo real:

```dart
Widget _buildTrackingTab() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // Widget de tracking del autobús
        BusTrackingWidget(
          routeId: widget.routeSuggestion.routeId,
          routeName: widget.routeSuggestion.routeName,
        ),
        
        // Lista de estaciones con tiempos estimados
        FutureBuilder<Map<String, dynamic>>(
          future: DriverTrackingService.getDriverTrackingByRoute(widget.routeSuggestion.routeId),
          builder: (context, snapshot) {
            // Lógica de construcción de la lista de estaciones
          },
        ),
      ],
    ),
  );
}
```

### Mejoras en el Tab "Mapa"

El mapa ahora incluye:

- **Marcador del autobús**: Punto rojo que muestra la ubicación actual del autobús
- **Leyenda actualizada**: Incluye el símbolo del autobús
- **Información en tiempo real**: El marcador se actualiza automáticamente

### Mejoras en el Tab "Detalles"

El tab de detalles ahora incluye:

- **Sección de estado del autobús**: Información en tiempo real del chofer y el trayecto
- **Datos dinámicos**: Estado, chofer, estación más cercana, tiempo estimado

## Flujo de Datos

### 1. Inicialización
```dart
// Al cargar la pantalla
FutureBuilder<Map<String, dynamic>>(
  future: DriverTrackingService.getDriverTrackingByRoute(routeId),
  builder: (context, snapshot) {
    // Manejo de estados: loading, error, success
  },
)
```

### 2. Actualización Periódica
```dart
// En BusTrackingWidget
void _startPeriodicUpdate() {
  Future.delayed(const Duration(seconds: 30), () {
    if (mounted) {
      _loadTrackingInfo();
      _startPeriodicUpdate();
    }
  });
}
```

### 3. Formateo de Datos
```dart
// Formateo de información de tracking
final formattedInfo = DriverTrackingService.formatTrackingInfo(trackingData);

// Cálculo de tiempos estimados
String estimatedTime = _formatEstimatedTime(estimatedArrival);
```

## Estados del Sistema

### 1. Sin Autobús Activo
- **Color**: Naranja
- **Mensaje**: "Sin autobús activo"
- **Acción**: Botón de actualizar disponible

### 2. Autobús en Ruta
- **Color**: Verde
- **Información**: Ubicación, chofer, estación más cercana
- **Actualización**: Automática cada 30 segundos

### 3. Error de Conexión
- **Color**: Rojo
- **Mensaje**: "Error de conexión"
- **Acción**: Botón de reintentar

### 4. Cargando
- **Indicador**: Spinner
- **Mensaje**: "Buscando autobús..."

## Cálculo de Tiempos Estimados

### Fórmula de Distancia (Haversine)
```dart
static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // Radio de la Tierra en metros
  
  final latDelta = _degreesToRadians(lat2 - lat1);
  final lonDelta = _degreesToRadians(lon2 - lon1);
  
  final a = sin(latDelta / 2) * sin(latDelta / 2) +
      cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
      sin(lonDelta / 2) * sin(lonDelta / 2);
  
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  
  return earthRadius * c; // Distancia en metros
}
```

### Estimación de Tiempo
- **Estación actual**: "Llegando..."
- **Próxima estación**: Basado en `estimatedArrivalNext` del backend
- **Otras estaciones**: 3 minutos por estación de diferencia

## Configuración del Backend

### Endpoints Requeridos

1. **Tracking Público**
   ```
   GET /api/tracking/drivers
   GET /api/tracking/drivers?route_id={routeId}
   ```

2. **Tracking por Ruta**
   ```
   GET /api/tracking/route/{routeId}
   ```

### Estructura de Respuesta Esperada

```json
{
  "status": "success",
  "message": "Tracking de ruta obtenido",
  "data": {
    "route": {
      "id": 1,
      "name": "Ruta Centro",
      "description": "Ruta del centro de la ciudad"
    },
    "stations": [...],
    "active_driver": {
      "driver_id": 1,
      "driver_name": "Juan Pérez",
      "current_location": {
        "latitude": 22.1565,
        "longitude": -100.9855,
        "speed": 25.5,
        "heading": 90,
        "timestamp": "2024-01-15T10:30:00Z"
      },
      "nearest_station": {
        "station_id": 5,
        "name": "Estación Central",
        "distance": 150.5
      },
      "journey_info": {
        "started_at": "2024-01-15T10:00:00Z",
        "estimated_arrival_next": "2024-01-15T10:35:00Z"
      },
      "last_updated": "2024-01-15T10:30:00Z"
    }
  }
}
```

## Consideraciones de Rendimiento

### 1. Actualización Periódica
- **Intervalo**: 30 segundos
- **Cancelación**: Se cancela cuando el widget se desmonta
- **Optimización**: Solo actualiza si el widget está montado

### 2. Manejo de Errores
- **Timeouts**: Manejo de errores de red
- **Fallbacks**: Información por defecto cuando no hay datos
- **Reintentos**: Botones para reintentar la conexión

### 3. Caché
- **Datos**: No se cachean localmente (siempre datos frescos)
- **Configuración**: URL del backend configurada en el servicio

## Próximas Mejoras

### 1. Notificaciones Push
- Alertas cuando el autobús está cerca
- Notificaciones de retrasos o cambios

### 2. Tracking en Segundo Plano
- Actualización continua incluso con la app cerrada
- Widgets del sistema operativo

### 3. Historial de Trayectos
- Guardar información de trayectos completados
- Estadísticas de uso

### 4. Optimización de Red
- WebSockets para actualizaciones en tiempo real
- Compresión de datos
- Caché inteligente

## Pruebas

### Casos de Prueba Recomendados

1. **Sin conexión a internet**
2. **Backend no disponible**
3. **Sin autobús activo en la ruta**
4. **Autobús en movimiento**
5. **Cambio de estación actual**
6. **Actualización automática**

### Datos de Prueba

```json
{
  "route_id": 1,
  "driver_location": {
    "latitude": 22.1565,
    "longitude": -100.9855
  },
  "nearest_station": {
    "id": 5,
    "name": "Estación Central",
    "distance": 150
  }
}
```

## Conclusión

La integración del sistema de tracking proporciona a los usuarios información valiosa en tiempo real sobre la ubicación y el estado de los autobuses. Esto mejora significativamente la experiencia del usuario al permitir una mejor planificación de sus viajes.

El sistema está diseñado para ser robusto, escalable y fácil de mantener, con una clara separación de responsabilidades entre los diferentes componentes. 
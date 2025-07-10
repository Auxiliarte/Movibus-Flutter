# 🏙️ Búsqueda de Lugares - San Luis Potosí

Esta documentación explica la integración de búsqueda de lugares específica para San Luis Potosí, SLP, usando la API de Google Places.

## 🎯 Características Implementadas

### ✅ Funcionalidades Principales
- **Búsqueda Localizada**: Todas las búsquedas se limitan a San Luis Potosí, SLP
- **Autocompletado Inteligente**: Sugerencias en tiempo real mientras el usuario escribe
- **Filtrado Geográfico**: Solo muestra lugares dentro de la zona de SLP
- **Coordenadas Automáticas**: Obtiene automáticamente lat/lng al seleccionar un lugar
- **UI Mejorada**: Diseño moderno con iconos y información detallada

### 📍 Zona de Cobertura
- **Ciudad**: San Luis Potosí, SLP
- **Estado**: San Luis Potosí
- **País**: México
- **Radio de Búsqueda**: 20km desde el centro de la ciudad

## 🏗️ Arquitectura

### 📁 Archivos Creados/Modificados

```
lib/
├── services/
│   └── places_service.dart           # Servicio de Google Places API
├── widgets/Home/
│   └── place_autocomplete_field.dart # Widget de búsqueda con autocompletado
└── screen/
    └── home_screen.dart              # Pantalla principal actualizada
```

### 🔧 Servicios Implementados

#### PlacesService
```dart
// Clases principales:
- PlacePrediction: Predicción de lugar con placeId y descripción
- PlaceDetails: Detalles completos con coordenadas

// Métodos disponibles:
- searchPlaces(input): Busca lugares en SLP
- getPlaceDetails(placeId): Obtiene coordenadas del lugar
```

## 🌐 Configuración de API

### Google Places API
- **API Key**: `AIzaSyA2NeKAZRdbRsy6cSj52TJRGJdf5wtlSA4`
- **Endpoint**: `https://maps.googleapis.com/maps/api/place/`
- **Servicios**: Autocomplete + Place Details

### Parámetros de Búsqueda
```dart
// Configuración específica para SLP:
- language: "es"                    // Español
- components: "country:mx"          // México
- types: "establishment|geocode|route"  // Establecimientos, direcciones, rutas
- input: "$input, San Luis Potosí, SLP"  // Forzar búsqueda en SLP
```

## 🎨 Widget de Búsqueda

### PlaceAutocompleteField
```dart
PlaceAutocompleteField(
  hint: "¿Dónde te encuentras?",
  controller: _fromController,
  onPlaceSelected: (name, lat, lng) {
    // Manejar selección del lugar
    setState(() {
      _fromLatitude = lat;
      _fromLongitude = lng;
    });
  },
)
```

### Características del Widget
- **Autocompletado en tiempo real**
- **Iconos por tipo de lugar** (establecimiento, ruta, dirección)
- **Información estructurada** (título y subtítulo)
- **Estados de carga** con indicadores visuales
- **Filtrado automático** por zona de SLP

## 🔍 Tipos de Lugares Soportados

### 1. Establecimientos (establishment)
- **Icono**: 🏪 (store)
- **Ejemplos**: Restaurantes, tiendas, hospitales, escuelas
- **Búsqueda**: "Walmart", "McDonald's", "Hospital Central"

### 2. Rutas (route)
- **Icono**: 🛣️ (route)
- **Ejemplos**: Avenidas, calles, carreteras
- **Búsqueda**: "Av. Carranza", "Blvd. Salvador Nava"

### 3. Direcciones (geocode)
- **Icono**: 📍 (location_on)
- **Ejemplos**: Direcciones específicas, intersecciones
- **Búsqueda**: "Carranza 500", "Centro Histórico"

## 🎯 Uso en la Aplicación

### 1. Campo de Origen
```dart
PlaceAutocompleteField(
  hint: "¿Dónde te encuentras?",
  controller: _fromController,
  onPlaceSelected: (name, lat, lng) {
    setState(() {
      _fromLatitude = lat;
      _fromLongitude = lng;
      _checkInputs();
    });
  },
)
```

### 2. Campo de Destino
```dart
PlaceAutocompleteField(
  hint: "¿A dónde vas?",
  controller: _toController,
  onPlaceSelected: (name, lat, lng) {
    setState(() {
      _toLatitude = lat;
      _toLongitude = lng;
      _checkInputs();
    });
  },
)
```

### 3. Activación de Sugerencias de Rutas
Cuando ambos campos tienen coordenadas válidas, se activa automáticamente la sugerencia de rutas usando la API de Moventra.

## 🔧 Filtrado de Resultados

### Lógica de Filtrado
```dart
// Solo mostrar lugares de San Luis Potosí
return response.predictions.where((prediction) {
  final description = prediction.description.toLowerCase();
  return description.contains('san luis potosí') || 
         description.contains('slp') ||
         description.contains('potosí');
}).toList();
```

### Ejemplos de Resultados Filtrados
✅ **Aceptados**:
- "Walmart, Av. Carranza, San Luis Potosí, SLP"
- "Hospital Central, SLP"
- "Plaza de Armas, Centro Histórico, San Luis Potosí"

❌ **Rechazados**:
- "Walmart, Monterrey, NL"
- "Hospital General, Guadalajara, Jalisco"

## 🎨 Características de UI/UX

### Diseño Visual
- **Bordes redondeados** (12px radius)
- **Sombras suaves** para profundidad
- **Colores consistentes** con el tema de la app
- **Espaciado adecuado** entre elementos

### Estados Interactivos
- **Normal**: Campo de texto con borde gris
- **Foco**: Borde azul con ancho aumentado
- **Carga**: Indicador de progreso en el sufijo
- **Sugerencias**: Lista desplegable con scroll

### Información Mostrada
- **Título**: Nombre principal del lugar
- **Subtítulo**: Dirección y zona
- **Icono**: Tipo de lugar (establecimiento, ruta, etc.)

## 🚀 Flujo de Usuario

### 1. Búsqueda de Origen
```
Usuario escribe → Autocompletado → Selecciona lugar → Coordenadas guardadas
```

### 2. Búsqueda de Destino
```
Usuario escribe → Autocompletado → Selecciona lugar → Coordenadas guardadas
```

### 3. Activación de Rutas
```
Ambas coordenadas → Validación → API de rutas → Sugerencias mostradas
```

## 🔧 Configuración Técnica

### Dependencias
```yaml
dependencies:
  http: ^0.13.0  # Para llamadas a Google Places API
```

### Permisos
```xml
<!-- Android -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- iOS -->
<!-- No se requieren permisos adicionales -->
```

## 🧪 Pruebas

### Casos de Prueba
1. **Búsqueda de establecimiento**: "Walmart" → Debe mostrar Walmart de SLP
2. **Búsqueda de ruta**: "Carranza" → Debe mostrar Av. Carranza de SLP
3. **Búsqueda de dirección**: "Centro" → Debe mostrar lugares del centro de SLP
4. **Filtrado geográfico**: "Monterrey" → No debe mostrar resultados

### Validación de Coordenadas
- **Latitud**: Entre 22.0 y 22.3 (zona de SLP)
- **Longitud**: Entre -101.0 y -100.9 (zona de SLP)

## 🔮 Próximas Mejoras

### Funcionalidades Planificadas
- [ ] **Historial de búsquedas** frecuentes
- [ ] **Favoritos** de lugares
- [ ] **Búsqueda por voz** para lugares
- [ ] **Mapa visual** de la zona de búsqueda
- [ ] **Categorías** de lugares (restaurantes, hospitales, etc.)

### Optimizaciones
- [ ] **Caché local** de búsquedas frecuentes
- [ ] **Debounce** para reducir llamadas a la API
- [ ] **Compresión** de respuestas
- [ ] **Offline mode** con datos sincronizados

---

## 🎉 ¡Integración Completada!

La búsqueda de lugares específica para San Luis Potosí está completamente funcional y optimizada para la zona. Los usuarios pueden buscar fácilmente tanto su origen como su destino, y las coordenadas se obtienen automáticamente para la sugerencia de rutas.

**Para probar**: Ejecuta la aplicación y prueba buscar lugares como "Walmart", "Hospital Central", o "Plaza de Armas" en los campos de origen y destino. 
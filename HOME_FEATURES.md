# Funcionalidades del Home Screen - Movibus

## Descripción General

El Home Screen de Movibus está diseñado para proporcionar una experiencia de usuario intuitiva y eficiente para planificar viajes en transporte público en San Luis Potosí, SLP.

## Características Principales

### 1. Autocompletado Inteligente de Ubicaciones

- **Búsqueda específica para San Luis Potosí**: Todos los resultados están limitados a la ciudad de San Luis Potosí
- **Autocompletado en tiempo real**: Mientras el usuario escribe, se muestran sugerencias relevantes
- **Filtrado por tipo de lugar**: Establecimientos, direcciones, rutas y puntos de interés
- **Ordenamiento inteligente**: Los establecimientos aparecen primero, seguidos por direcciones

### 2. Selección de Ubicación Actual

- **Botón de ubicación actual**: Permite obtener automáticamente la ubicación del usuario
- **Integración con GPS**: Utiliza el GPS del dispositivo para obtener coordenadas precisas
- **Manejo de permisos**: Solicita permisos de ubicación de forma amigable
- **Geocoding automático**: Convierte coordenadas en direcciones legibles

### 3. Selección desde Mapa

- **Pantalla de mapa interactiva**: Permite seleccionar ubicación tocando el mapa
- **Centrado en San Luis Potosí**: El mapa se centra automáticamente en SLP
- **Marcador visual**: Muestra claramente la ubicación seleccionada
- **Confirmación de ubicación**: Botón para confirmar la selección

### 4. Estación Más Cercana

- **Búsqueda automática**: Encuentra la estación más cercana a la ubicación del usuario
- **Información detallada**: Muestra nombre, ruta, distancia y número de estaciones
- **Actualización en tiempo real**: Se actualiza cuando cambia la ubicación del usuario
- **Integración con API**: Utiliza la API de Moventra para obtener datos reales

### 5. Rutas Sugeridas

- **Cálculo inteligente**: Encuentra las mejores rutas basándose en origen y destino
- **Múltiples opciones**: Muestra hasta 3 rutas sugeridas
- **Información completa**: Tiempo estimado, distancia caminando, estaciones de salida y llegada
- **Puntuación de calidad**: Cada ruta tiene una puntuación basada en eficiencia

### 6. Sistema de Ayuda

- **Consejos contextuales**: Muestra ayuda relevante para nuevos usuarios
- **Ocultación automática**: La ayuda se oculta cuando el usuario interactúa
- **Información clara**: Explica cómo usar cada funcionalidad

## Flujo de Usuario

### Escenario 1: Usuario Nuevo
1. El usuario abre la aplicación
2. Se muestra la sección de ayuda con consejos
3. El usuario puede usar el botón de ubicación actual o escribir manualmente
4. Si no encuentra su dirección, puede seleccionarla desde el mapa
5. Una vez seleccionado origen y destino, se muestran las rutas sugeridas

### Escenario 2: Usuario Recurrente
1. El usuario abre la aplicación
2. La ubicación actual se obtiene automáticamente
3. El usuario selecciona su destino
4. Se muestran inmediatamente las rutas sugeridas
5. El usuario puede seleccionar una ruta y ver detalles

## Tecnologías Utilizadas

### APIs y Servicios
- **Google Places API**: Para autocompletado y búsqueda de lugares
- **Google Geocoding API**: Para convertir coordenadas en direcciones
- **Google Maps API**: Para la pantalla de selección de mapa
- **Moventra API**: Para datos de estaciones y rutas

### Dependencias Flutter
- `google_maps_flutter`: Para mostrar mapas interactivos
- `geolocator`: Para obtener ubicación del dispositivo
- `permission_handler`: Para manejar permisos de ubicación
- `http`: Para llamadas a APIs externas

## Configuración Requerida

### Android
- Permisos de ubicación en `AndroidManifest.xml`
- API Key de Google Maps configurada

### iOS
- Permisos de ubicación en `Info.plist`
- API Key de Google Maps configurada

## Mejoras Futuras

1. **Historial de búsquedas**: Guardar ubicaciones frecuentes
2. **Favoritos**: Permitir marcar ubicaciones como favoritas
3. **Notificaciones**: Alertas sobre horarios de buses
4. **Rutas en tiempo real**: Información actualizada de buses
5. **Modo offline**: Funcionalidad básica sin conexión

## Consideraciones de UX

- **Feedback visual**: Indicadores de carga y estados de error
- **Manejo de errores**: Mensajes claros cuando algo falla
- **Accesibilidad**: Soporte para lectores de pantalla
- **Rendimiento**: Optimización para dispositivos de gama baja
- **Internacionalización**: Preparado para múltiples idiomas 
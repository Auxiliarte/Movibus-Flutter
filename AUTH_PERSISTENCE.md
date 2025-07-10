# Persistencia de Autenticación - Moventra

## Resumen de Cambios

Se ha implementado un sistema completo de persistencia de autenticación para la aplicación Moventra, que permite a los usuarios mantener su sesión activa entre cierres de la aplicación.

## Características Implementadas

### 1. Servicio de Autenticación Centralizado (`lib/services/auth_service.dart`)

- **Singleton Pattern**: Garantiza una única instancia del servicio
- **Gestión de Tokens**: Almacenamiento seguro de tokens de autenticación
- **Verificación de Sesión**: Validación automática de sesiones activas
- **Limpieza de Datos**: Métodos para cerrar sesión y limpiar datos

### 2. Persistencia Mejorada

#### En Login (`lib/auth/login_screen.dart`)
- **Token siempre guardado**: Se guarda el token en cada login exitoso
- **Preferencia de "Recordar Sesión"**: Controla si la sesión persiste entre cierres
- **Verificación automática**: Si hay una sesión activa, redirige al home

#### En Splash Screen (`lib/splash_screen.dart`)
- **Verificación inteligente**: Usa el servicio de autenticación para validar sesiones
- **Limpieza automática**: Elimina tokens inválidos o no recordados
- **Navegación optimizada**: Redirige según el estado de la sesión

### 3. Interfaz de Usuario Mejorada

#### Pantalla de Welcome (`lib/welcome.dart`)
- **Botón principal**: "Iniciar sesión" ahora es el botón principal (más grande)
- **Botón secundario**: "Registrate" es ahora un botón outline más pequeño
- **Jerarquía visual**: Mejor flujo de usuario para usuarios existentes

#### Pantalla de Perfil (`lib/screen/profile_screen.dart`)
- **Opción de cerrar sesión**: Nueva sección "Cuenta" con opción de logout
- **Confirmación**: Diálogo de confirmación antes de cerrar sesión
- **Navegación limpia**: Al cerrar sesión, limpia el stack de navegación

## Flujo de Autenticación

### 1. Inicio de Aplicación
```
SplashScreen → Verificar sesión activa
├── Sesión válida → HomeScreen
└── Sin sesión → WelcomeScreen
```

### 2. Login
```
LoginScreen → Autenticación exitosa
├── Guardar token
├── Guardar preferencia "recordar sesión"
└── Navegar a HomeScreen
```

### 3. Cerrar Sesión
```
ProfileScreen → Opción "Cerrar sesión"
├── Confirmación
├── Limpiar datos de sesión
└── Navegar a WelcomeScreen
```

## Almacenamiento Seguro

### Claves utilizadas:
- `auth_token`: Token de autenticación JWT
- `remember_session`: Preferencia de recordar sesión ("true"/null)

### Seguridad:
- Uso de `flutter_secure_storage` para almacenamiento encriptado
- Validación de tokens con el backend
- Limpieza automática de datos inválidos

## Configuración de Backend

### URLs por plataforma:
- **Android**: `http://10.0.2.2:8000/api`
- **iOS/Web**: `https://app.moventra.com.mx/api`

### Endpoints utilizados:
- `POST /login`: Autenticación de usuario
- `GET /user`: Verificación de token válido

## Beneficios

1. **Experiencia de Usuario**: No requiere login repetitivo
2. **Seguridad**: Tokens almacenados de forma segura
3. **Flexibilidad**: Usuario puede elegir si recordar sesión
4. **Mantenibilidad**: Código centralizado y reutilizable
5. **Robustez**: Manejo de errores y casos edge

## Próximos Pasos Sugeridos

1. **Refresh Tokens**: Implementar renovación automática de tokens
2. **Biometría**: Agregar autenticación biométrica opcional
3. **Múltiples Cuentas**: Soporte para cambiar entre cuentas
4. **Analytics**: Tracking de eventos de autenticación
5. **Testing**: Pruebas unitarias para el servicio de autenticación 
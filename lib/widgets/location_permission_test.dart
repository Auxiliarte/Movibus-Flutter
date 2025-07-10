import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import '../services/location_service.dart';

class LocationPermissionTest extends StatefulWidget {
  const LocationPermissionTest({super.key});

  @override
  State<LocationPermissionTest> createState() => _LocationPermissionTestState();
}

class _LocationPermissionTestState extends State<LocationPermissionTest> {
  String permissionStatus = 'No verificado';
  String locationServiceStatus = 'No verificado';
  String locationResult = 'No probado';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    await _checkPermissionStatus();
    await _checkLocationService();
  }

  Future<void> _checkPermissionStatus() async {
    try {
      final status = await permission_handler.Permission.location.status;
      setState(() {
        permissionStatus = _getPermissionStatusText(status);
      });
    } catch (e) {
      setState(() {
        permissionStatus = 'Error: $e';
      });
    }
  }

  Future<void> _checkLocationService() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      setState(() {
        locationServiceStatus = isEnabled ? 'Habilitado' : 'Deshabilitado';
      });
    } catch (e) {
      setState(() {
        locationServiceStatus = 'Error: $e';
      });
    }
  }

  String _getPermissionStatusText(permission_handler.PermissionStatus status) {
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

  Future<void> _requestPermission() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await LocationService.requestLocationPermission();
      setState(() {
        permissionStatus = result ? 'Concedido' : 'Denegado';
      });
      
      if (result) {
        await _testLocation();
      }
    } catch (e) {
      setState(() {
        permissionStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _testLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        locationResult = 'Éxito: ${position?.latitude.toStringAsFixed(6)}, ${position?.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() {
        locationResult = 'Error: $e';
      });
    }
  }

  Future<void> _openSettings() async {
    await permission_handler.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Test de Permisos de Ubicación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Estado de permisos
            _buildStatusRow('Permisos:', permissionStatus),
            const SizedBox(height: 8),
            
            // Estado del servicio de ubicación
            _buildStatusRow('Servicio de Ubicación:', locationServiceStatus),
            const SizedBox(height: 8),
            
            // Resultado de la ubicación
            _buildStatusRow('Ubicación:', locationResult),
            const SizedBox(height: 16),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _requestPermission,
                    child: const Text('Solicitar Permiso'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testLocation,
                    child: const Text('Probar Ubicación'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _checkInitialStatus,
                    child: const Text('Verificar Estado'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _openSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Abrir Configuración'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    Color statusColor = Colors.grey;
    if (value.contains('Concedido') || value.contains('Habilitado') || value.contains('Éxito')) {
      statusColor = Colors.green;
    } else if (value.contains('Denegado') || value.contains('Deshabilitado') || value.contains('Error')) {
      statusColor = Colors.red;
    } else if (value.contains('No')) {
      statusColor = Colors.orange;
    }

    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: statusColor),
          ),
        ),
      ],
    );
  }
} 
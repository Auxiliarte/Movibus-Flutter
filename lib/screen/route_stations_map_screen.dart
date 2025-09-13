import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/route_model.dart';
import '../services/route_service.dart';
import '../services/region_service.dart';
import '../themes/app_colors.dart';

class RouteStationsMapScreen extends StatefulWidget {
  final RouteBasicModel route;

  const RouteStationsMapScreen({
    super.key,
    required this.route,
  });

  @override
  State<RouteStationsMapScreen> createState() => _RouteStationsMapScreenState();
}

class _RouteStationsMapScreenState extends State<RouteStationsMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<StationModel> _stations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRouteStations();
  }

  String getBackendUrl() {
    if (Platform.isAndroid) {
      return 'https://app.moventra.com.mx/api';
    } else {
      return 'https://app.moventra.com.mx/api';
    }
  }

  Future<void> _loadRouteStations() async {
    try {
      print('🔄 Cargando paradas para la ruta ${widget.route.id}');
      final response = await RouteService.fetchRouteStations(
        getBackendUrl(),
        widget.route.id,
      );
      
      print('✅ Paradas cargadas: ${response.stations.length}');
      
      setState(() {
        _stations = response.stations;
        _markers = _createMarkers(response.stations);
        _polylines = _createPolylines(response.stations);
        _isLoading = false;
      });

      // Centrar el mapa en las estaciones
      if (_stations.isNotEmpty && _mapController != null) {
        _fitBounds();
      }
    } catch (e) {
      print('❌ Error al cargar estaciones: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Set<Marker> _createMarkers(List<StationModel> stations) {
    return stations.where((station) {
      // Solo mostrar estación de inicio y fin para vista más limpia
      return station.order == 0 || station.order == stations.length - 1;
    }).map((station) {
      return Marker(
        markerId: MarkerId('station_${station.id}'),
        position: LatLng(station.latitude, station.longitude),
        infoWindow: InfoWindow(
          title: station.order == 0 ? 'Inicio' : 'Fin',
          snippet: station.displayName,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          station.order == 0
            ? BitmapDescriptor.hueGreen  // Estación de inicio
            : BitmapDescriptor.hueRed,  // Estación de fin
        ),
      );
    }).toSet();
  }

  Set<Polyline> _createPolylines(List<StationModel> stations) {
    if (stations.length < 2) return {};

    return {
      Polyline(
        polylineId: const PolylineId('route_path'),
        color: Colors.blue,
        width: 4,
        points: stations.map((station) {
          return LatLng(station.latitude, station.longitude);
        }).toList(),
      ),
    };
  }

  void _fitBounds() {
    if (_stations.isEmpty) return;

    double minLat = _stations.first.latitude;
    double maxLat = _stations.first.latitude;
    double minLng = _stations.first.longitude;
    double maxLng = _stations.first.longitude;

    for (final station in _stations) {
      minLat = min(minLat, station.latitude);
      maxLat = max(maxLat, station.latitude);
      minLng = min(minLng, station.longitude);
      maxLng = max(maxLng, station.longitude);
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.01, minLng - 0.01),
          northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
        ),
        50.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.route.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2196F3)),
            onPressed: _loadRouteStations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando paradas...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar estaciones',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.textTheme.headlineSmall?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRouteStations,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Información de la ruta
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.route,
                              color: Color(0xFF2196F3),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.route.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_stations.length} paradas',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Lista de estaciones
                    Expanded(
                      child: Row(
                        children: [
                          // Mapa
                          Expanded(
                            flex: 2,
                            child: GoogleMap(
                              onMapCreated: (controller) {
                                _mapController = controller;
                                if (_stations.isNotEmpty) {
                                  _fitBounds();
                                }
                              },
                              initialCameraPosition: CameraPosition(
                                target: LatLng(RegionService.currentRegion.centerLatitude, RegionService.currentRegion.centerLongitude), // Centro de región actual
                                zoom: RegionService.currentRegion.defaultZoom,
                              ),
                              markers: _markers,
                              polylines: _polylines,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                            ),
                          ),
                          
                          // Lista de estaciones
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.list,
                                          color: Color(0xFF2196F3),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Paradas',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2196F3),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${_stations.length}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _stations.length,
                                      itemBuilder: (context, index) {
                                        final station = _stations[index];
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.grey[100]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            leading: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: index == 0
                                                    ? Colors.green
                                                    : index == _stations.length - 1
                                                        ? Colors.red
                                                        : const Color(0xFF2196F3),
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${index + 1}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              station.displayName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Text(
                                              'Estación ${station.order + 1}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            onTap: () {
                                              _mapController?.animateCamera(
                                                CameraUpdate.newLatLngZoom(
                                                  LatLng(station.latitude, station.longitude),
                                                  16,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
} 
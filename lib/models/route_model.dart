import 'location_model.dart';

class RouteModel {
  final int id;
  final String nombre;
  final String? busNombre;
  final List<LocationModel> locations;

  RouteModel({
    required this.id,
    required this.nombre,
    this.busNombre,
    required this.locations,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'],
      nombre: json['nombre'],
      busNombre: json['bus'] != null ? json['bus']['nombre'] : null,
      locations: (json['locations'] as List)
          .map((loc) => LocationModel.fromJson(loc))
          .toList(),
    );
  }
}

// Nuevo modelo para la API de rutas básicas
class RouteBasicModel {
  final int id;
  final String name;
  final String description;
  final int totalStations;
  final String createdAt;

  RouteBasicModel({
    required this.id,
    required this.name,
    required this.description,
    required this.totalStations,
    required this.createdAt,
  });

  factory RouteBasicModel.fromJson(Map<String, dynamic> json) {
    return RouteBasicModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Ruta sin nombre',
      description: json['description'] ?? 'Sin descripción',
      totalStations: json['total_stations'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}

// Modelo para estaciones de una ruta
class StationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int order;

  StationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.order,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Parseando estación: $json');
    try {
      return StationModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Estación sin nombre',
        latitude: (json['latitude'] ?? 0.0).toDouble(),
        longitude: (json['longitude'] ?? 0.0).toDouble(),
        order: json['order'] ?? 0,
      );
    } catch (e) {
      print('❌ Error parseando estación: $e');
      print('❌ JSON problemático: $json');
      rethrow;
    }
  }
}

// Modelo para respuesta de estaciones de una ruta
class RouteStationsResponse {
  final RouteBasicModel route;
  final List<StationModel> stations;

  RouteStationsResponse({
    required this.route,
    required this.stations,
  });

  factory RouteStationsResponse.fromJson(Map<String, dynamic> json) {
    return RouteStationsResponse(
      route: RouteBasicModel.fromJson(json['route']),
      stations: (json['stations'] as List)
          .map((station) => StationModel.fromJson(station))
          .toList(),
    );
  }
}

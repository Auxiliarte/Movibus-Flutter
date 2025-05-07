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

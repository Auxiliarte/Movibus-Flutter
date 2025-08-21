class StationModel {
  final int id;
  final String? name; // Cambiar a nullable
  final double latitude;
  final double longitude;
  final int order;
  final double? distanceMeters;
  final double? distanceKm;
  final double? distanceFromUser;
  final double? distanceToDestination;
  final double? walkingTimeMinutes;

  StationModel({
    required this.id,
    this.name, // Cambiar a opcional
    required this.latitude,
    required this.longitude,
    required this.order,
    this.distanceMeters,
    this.distanceKm,
    this.distanceFromUser,
    this.distanceToDestination,
    this.walkingTimeMinutes,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'],
      name: json['name'], // Permitir null
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      order: json['order'],
      distanceMeters: json['distance_meters']?.toDouble(),
      distanceKm: json['distance_km']?.toDouble(),
      distanceFromUser: json['distance_from_user']?.toDouble(),
      distanceToDestination: json['distance_to_destination']?.toDouble(),
      walkingTimeMinutes: json['walking_time_minutes']?.toDouble(),
    );
  }

  // Método para obtener el nombre de la estación o un valor por defecto
  String get displayName {
    return name ?? 'Estación ${id}';
  }
} 
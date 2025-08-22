class StationModel {
  final int id;
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

  // Método para obtener el identificador de la estación
  String get displayName {
    if (distanceMeters != null && walkingTimeMinutes != null) {
      return 'Estación $id (${distanceMeters!.toStringAsFixed(0)}m, ${walkingTimeMinutes!.toStringAsFixed(0)}min)';
    }
    return 'Estación $id';
  }
} 
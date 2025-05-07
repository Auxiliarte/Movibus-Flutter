class LocationModel {
  final String? name;
  final double latitude;
  final double longitude;
  final int order;

  LocationModel({
    this.name,
    required this.latitude,
    required this.longitude,
    required this.order,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'],
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      order: json['order'],
    );
  }

}

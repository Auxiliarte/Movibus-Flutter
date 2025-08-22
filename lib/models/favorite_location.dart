class FavoriteLocation {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;

  const FavoriteLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.createdAt,
  });

  factory FavoriteLocation.fromJson(Map<String, dynamic> json) {
    return FavoriteLocation(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  FavoriteLocation copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return FavoriteLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'FavoriteLocation(id: $id, name: $name, address: $address, lat: $latitude, lng: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteLocation &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        latitude.hashCode ^
        longitude.hashCode;
  }
}

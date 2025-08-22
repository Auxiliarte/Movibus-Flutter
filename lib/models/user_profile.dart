// models/user_profile.dart
class UserProfile {
  final int id;
  final String name;
  final String? lastName;
  final String email;
  final String? phone;
  final String? birthDate;
  final String? rfc;
  final bool isDriver;
  final bool isActive;
  final String? profilePhotoUrl;
  final Concesionario? concesionario;
  final String createdAt;
  final String? emailVerifiedAt;

  UserProfile({
    required this.id,
    required this.name,
    this.lastName,
    required this.email,
    this.phone,
    this.birthDate,
    this.rfc,
    required this.isDriver,
    required this.isActive,
    this.profilePhotoUrl,
    this.concesionario,
    required this.createdAt,
    this.emailVerifiedAt,
  });

  String get fullName {
    if (lastName != null && lastName!.isNotEmpty) {
      return '$name $lastName';
    }
    return name;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lastName: json['last_name'],
      email: json['email'] ?? '',
      phone: json['phone'],
      birthDate: json['birth_date'],
      rfc: json['rfc'],
      isDriver: json['is_driver'] ?? false,
      isActive: json['is_active'] ?? true,
      profilePhotoUrl: json['profile_photo_url'],
      concesionario: json['concesionario'] != null
          ? Concesionario.fromJson(json['concesionario'])
          : null,
      createdAt: json['created_at'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
    );
  }
}

class Concesionario {
  final int id;
  final String name;

  Concesionario({
    required this.id,
    required this.name,
  });

  factory Concesionario.fromJson(Map<String, dynamic> json) {
    return Concesionario(
      id: json['id'],
      name: json['name'],
    );
  }
}

// models/account_status.dart
class AccountStatus {
  final int userId;
  final String email;
  final String name;
  final bool isActive;
  final String? deactivatedAt;
  final String createdAt;

  AccountStatus({
    required this.userId,
    required this.email,
    required this.name,
    required this.isActive,
    this.deactivatedAt,
    required this.createdAt,
  });

  factory AccountStatus.fromJson(Map<String, dynamic> json) {
    return AccountStatus(
      userId: json['user_id'],
      email: json['email'],
      name: json['name'],
      isActive: json['is_active'],
      deactivatedAt: json['deactivated_at'],
      createdAt: json['created_at'],
    );
  }
}

class InactiveUser {
  final int id;
  final String name;
  final String email;
  final String deactivatedAt;
  final String createdAt;

  InactiveUser({
    required this.id,
    required this.name,
    required this.email,
    required this.deactivatedAt,
    required this.createdAt,
  });

  factory InactiveUser.fromJson(Map<String, dynamic> json) {
    return InactiveUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      deactivatedAt: json['deactivated_at'],
      createdAt: json['created_at'],
    );
  }
}

enum UserRole {
  patient,
  staff,
  admin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'staff':
        return UserRole.staff;
      case 'admin':
        return UserRole.admin;
      case 'patient':
      default:
        return UserRole.patient;
    }
  }

  String get value {
    switch (this) {
      case UserRole.staff:
        return 'staff';
      case UserRole.admin:
        return 'admin';
      case UserRole.patient:
        return 'patient';
    }
  }
}

class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String nationalId;
  final UserRole role;
  final String? hospitalId;
  final String? departmentId;
  final String? fcmToken;
  final DateTime createdAt;

  UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.role,
    this.hospitalId,
    this.departmentId,
    this.fcmToken,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? nationalId,
    UserRole? role,
    String? hospitalId,
    String? departmentId,
    String? fcmToken,
  }) {
    return UserEntity(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      role: role ?? this.role,
      hospitalId: hospitalId ?? this.hospitalId,
      departmentId: departmentId ?? this.departmentId,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}

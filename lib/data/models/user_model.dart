import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String nationalId;
  final String role;
  final String? hospitalId;
  final String? departmentId;
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
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

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      nationalId: map['nationalId'] ?? '',
      role: map['role'] ?? 'patient',
      hospitalId: map['hospitalId'],
      departmentId: map['departmentId'],
      fcmToken: map['fcmToken'],
      createdAt: parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'nationalId': nationalId,
      'role': role,
      'hospitalId': hospitalId,
      'departmentId': departmentId,
      'fcmToken': fcmToken,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      nationalId: nationalId,
      role: UserRole.fromString(role),
      hospitalId: hospitalId,
      departmentId: departmentId,
      fcmToken: fcmToken,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      nationalId: entity.nationalId,
      role: entity.role.value,
      hospitalId: entity.hospitalId,
      departmentId: entity.departmentId,
      fcmToken: entity.fcmToken,
      createdAt: entity.createdAt,
    );
  }
}

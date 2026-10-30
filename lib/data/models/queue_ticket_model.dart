import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/queue_ticket_entity.dart';

class QueueTicketModel {
  final String id;
  final String patientId;
  final String patientName;
  final String nationalId;
  final String hospitalId;
  final String hospitalNameAr;
  final String hospitalNameEn;
  final String departmentId;
  final String departmentNameAr;
  final String departmentNameEn;
  final int ticketNumber;
  final String status;
  final DateTime createdAt;
  final DateTime? checkedInAt;
  final DateTime? calledAt;
  final DateTime? completedAt;

  QueueTicketModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.nationalId,
    required this.hospitalId,
    required this.hospitalNameAr,
    required this.hospitalNameEn,
    required this.departmentId,
    required this.departmentNameAr,
    required this.departmentNameEn,
    required this.ticketNumber,
    required this.status,
    required this.createdAt,
    this.checkedInAt,
    this.calledAt,
    this.completedAt,
  });

  factory QueueTicketModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return QueueTicketModel(
      id: id,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      nationalId: map['nationalId'] ?? '',
      hospitalId: map['hospitalId'] ?? '',
      hospitalNameAr: map['hospitalNameAr'] ?? '',
      hospitalNameEn: map['hospitalNameEn'] ?? '',
      departmentId: map['departmentId'] ?? '',
      departmentNameAr: map['departmentNameAr'] ?? '',
      departmentNameEn: map['departmentNameEn'] ?? '',
      ticketNumber: map['ticketNumber'] ?? 0,
      status: map['status'] ?? 'waiting',
      createdAt: parseDate(map['createdAt']),
      checkedInAt: parseNullableDate(map['checkedInAt']),
      calledAt: parseNullableDate(map['calledAt']),
      completedAt: parseNullableDate(map['completedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'nationalId': nationalId,
      'hospitalId': hospitalId,
      'hospitalNameAr': hospitalNameAr,
      'hospitalNameEn': hospitalNameEn,
      'departmentId': departmentId,
      'departmentNameAr': departmentNameAr,
      'departmentNameEn': departmentNameEn,
      'ticketNumber': ticketNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'checkedInAt': checkedInAt?.toIso8601String(),
      'calledAt': calledAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  QueueTicketEntity toEntity() {
    return QueueTicketEntity(
      id: id,
      patientId: patientId,
      patientName: patientName,
      nationalId: nationalId,
      hospitalId: hospitalId,
      hospitalNameAr: hospitalNameAr,
      hospitalNameEn: hospitalNameEn,
      departmentId: departmentId,
      departmentNameAr: departmentNameAr,
      departmentNameEn: departmentNameEn,
      ticketNumber: ticketNumber,
      status: QueueStatus.fromString(status),
      createdAt: createdAt,
      checkedInAt: checkedInAt,
      calledAt: calledAt,
      completedAt: completedAt,
    );
  }

  factory QueueTicketModel.fromEntity(QueueTicketEntity entity) {
    return QueueTicketModel(
      id: entity.id,
      patientId: entity.patientId,
      patientName: entity.patientName,
      nationalId: entity.nationalId,
      hospitalId: entity.hospitalId,
      hospitalNameAr: entity.hospitalNameAr,
      hospitalNameEn: entity.hospitalNameEn,
      departmentId: entity.departmentId,
      departmentNameAr: entity.departmentNameAr,
      departmentNameEn: entity.departmentNameEn,
      ticketNumber: entity.ticketNumber,
      status: entity.status.value,
      createdAt: entity.createdAt,
      checkedInAt: entity.checkedInAt,
      calledAt: entity.calledAt,
      completedAt: entity.completedAt,
    );
  }
}

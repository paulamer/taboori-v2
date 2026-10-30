/// Bed entity representing a single bed in a hospital ward/room.
/// Part of the hierarchy: Hospital → Department → Ward → Bed
enum BedStatus {
  available,
  occupied,
  reserved,
  cleaning,
  maintenance,
  unavailable,
}

extension BedStatusX on BedStatus {
  String get labelAr => switch (this) {
        BedStatus.available => 'متاح',
        BedStatus.occupied => 'مشغول',
        BedStatus.reserved => 'محجوز',
        BedStatus.cleaning => 'تنظيف',
        BedStatus.maintenance => 'صيانة',
        BedStatus.unavailable => 'غير متاح',
      };

  String get labelEn => switch (this) {
        BedStatus.available => 'Available',
        BedStatus.occupied => 'Occupied',
        BedStatus.reserved => 'Reserved',
        BedStatus.cleaning => 'Cleaning',
        BedStatus.maintenance => 'Maintenance',
        BedStatus.unavailable => 'Unavailable',
      };

  String label(String locale) => locale == 'ar' ? labelAr : labelEn;

  bool get isUsable => this == BedStatus.available;
}

enum BedType {
  general,
  icu,
  incubator,
  ventilator,
  emergency,
}

extension BedTypeX on BedType {
  String get labelAr => switch (this) {
        BedType.general => 'عام',
        BedType.icu => 'عناية مركزة',
        BedType.incubator => 'حضّانة',
        BedType.ventilator => 'تنفس صناعي',
        BedType.emergency => 'طوارئ',
      };

  String get labelEn => switch (this) {
        BedType.general => 'General',
        BedType.icu => 'ICU',
        BedType.incubator => 'Incubator',
        BedType.ventilator => 'Ventilator',
        BedType.emergency => 'Emergency',
      };

  String label(String locale) => locale == 'ar' ? labelAr : labelEn;
}

class BedEntity {
  final String id;
  final String hospitalId;
  final String departmentId;
  final String wardId;
  final String roomNumber;
  final String bedNumber;
  final BedType type;
  final BedStatus status;
  final String? patientId;
  final String? patientName;
  final DateTime? assignedAt;
  final String? notes;

  const BedEntity({
    required this.id,
    required this.hospitalId,
    required this.departmentId,
    required this.wardId,
    required this.roomNumber,
    required this.bedNumber,
    required this.type,
    required this.status,
    this.patientId,
    this.patientName,
    this.assignedAt,
    this.notes,
  });

  bool get isAvailable => status == BedStatus.available;
  bool get isOccupied => status == BedStatus.occupied;

  BedEntity copyWith({
    String? id,
    String? hospitalId,
    String? departmentId,
    String? wardId,
    String? roomNumber,
    String? bedNumber,
    BedType? type,
    BedStatus? status,
    String? patientId,
    String? patientName,
    DateTime? assignedAt,
    String? notes,
  }) {
    return BedEntity(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      departmentId: departmentId ?? this.departmentId,
      wardId: wardId ?? this.wardId,
      roomNumber: roomNumber ?? this.roomNumber,
      bedNumber: bedNumber ?? this.bedNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      assignedAt: assignedAt ?? this.assignedAt,
      notes: notes ?? this.notes,
    );
  }
}

/// Summary metrics for bed occupancy within a scope (department, hospital, etc.)
class BedOccupancySummary {
  final int total;
  final int available;
  final int occupied;
  final int reserved;
  final int cleaning;
  final int maintenance;
  final int unavailable;

  const BedOccupancySummary({
    required this.total,
    required this.available,
    required this.occupied,
    required this.reserved,
    required this.cleaning,
    required this.maintenance,
    required this.unavailable,
  });

  double get occupancyRate =>
      total > 0 ? (occupied + reserved) / total : 0.0;

  String get occupancyPercent =>
      '${(occupancyRate * 100).toStringAsFixed(0)}%';

  bool get isHighOccupancy => occupancyRate >= 0.85;
  bool get isCritical => occupancyRate >= 0.95;

  factory BedOccupancySummary.fromBeds(List<BedEntity> beds) {
    return BedOccupancySummary(
      total: beds.length,
      available: beds.where((b) => b.status == BedStatus.available).length,
      occupied: beds.where((b) => b.status == BedStatus.occupied).length,
      reserved: beds.where((b) => b.status == BedStatus.reserved).length,
      cleaning: beds.where((b) => b.status == BedStatus.cleaning).length,
      maintenance: beds.where((b) => b.status == BedStatus.maintenance).length,
      unavailable: beds.where((b) => b.status == BedStatus.unavailable).length,
    );
  }
}

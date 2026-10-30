enum QueueStatus {
  waiting,
  active,
  completed,
  absent,
  cancelled;

  static QueueStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return QueueStatus.active;
      case 'completed':
        return QueueStatus.completed;
      case 'absent':
        return QueueStatus.absent;
      case 'cancelled':
        return QueueStatus.cancelled;
      case 'waiting':
      default:
        return QueueStatus.waiting;
    }
  }

  String get value {
    switch (this) {
      case QueueStatus.active:
        return 'active';
      case QueueStatus.completed:
        return 'completed';
      case QueueStatus.absent:
        return 'absent';
      case QueueStatus.cancelled:
        return 'cancelled';
      case QueueStatus.waiting:
        return 'waiting';
    }
  }
}

class QueueTicketEntity {
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
  final QueueStatus status;
  final DateTime createdAt;
  final DateTime? checkedInAt;
  final DateTime? calledAt;
  final DateTime? completedAt;

  QueueTicketEntity({
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

  String getHospitalName(String locale) => locale == 'en' ? hospitalNameEn : hospitalNameAr;
  String getDepartmentName(String locale) => locale == 'en' ? departmentNameEn : departmentNameAr;

  bool get isWaiting => status == QueueStatus.waiting;
  bool get isActive => status == QueueStatus.active;
  bool get isCompleted => status == QueueStatus.completed;
  bool get isAbsent => status == QueueStatus.absent;
  bool get isCancelled => status == QueueStatus.cancelled;
  bool get isCheckedIn => checkedInAt != null;

  QueueTicketEntity copyWith({
    QueueStatus? status,
    DateTime? checkedInAt,
    DateTime? calledAt,
    DateTime? completedAt,
  }) {
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
      status: status ?? this.status,
      createdAt: createdAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      calledAt: calledAt ?? this.calledAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

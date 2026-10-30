import '../../domain/entities/department_entity.dart';

class DepartmentModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final int currentNumber;
  final int lastNumber;
  final int averageWaitMinutes;
  final bool isActive;

  DepartmentModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.currentNumber,
    required this.lastNumber,
    required this.averageWaitMinutes,
    required this.isActive,
  });

  factory DepartmentModel.fromMap(Map<String, dynamic> map, String id) {
    return DepartmentModel(
      id: id,
      nameAr: map['nameAr'] ?? '',
      nameEn: map['nameEn'] ?? '',
      currentNumber: map['currentNumber'] ?? 0,
      lastNumber: map['lastNumber'] ?? 0,
      averageWaitMinutes: map['averageWaitMinutes'] ?? 10,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'currentNumber': currentNumber,
      'lastNumber': lastNumber,
      'averageWaitMinutes': averageWaitMinutes,
      'isActive': isActive,
    };
  }

  DepartmentEntity toEntity() {
    return DepartmentEntity(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      currentNumber: currentNumber,
      lastNumber: lastNumber,
      averageWaitMinutes: averageWaitMinutes,
      isActive: isActive,
    );
  }

  factory DepartmentModel.fromEntity(DepartmentEntity entity) {
    return DepartmentModel(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      currentNumber: entity.currentNumber,
      lastNumber: entity.lastNumber,
      averageWaitMinutes: entity.averageWaitMinutes,
      isActive: entity.isActive,
    );
  }
}

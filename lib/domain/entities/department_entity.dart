class DepartmentEntity {
  final String id;
  final String nameAr;
  final String nameEn;
  final int currentNumber;
  final int lastNumber;
  final int averageWaitMinutes;
  final bool isActive;

  DepartmentEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.currentNumber,
    required this.lastNumber,
    required this.averageWaitMinutes,
    required this.isActive,
  });

  String getName(String locale) => locale == 'en' ? nameEn : nameAr;

  int get waitingCount => lastNumber - currentNumber >= 0 ? lastNumber - currentNumber : 0;
  int get estimatedWaitMinutesForNew => waitingCount * averageWaitMinutes;

  DepartmentEntity copyWith({
    String? nameAr,
    String? nameEn,
    int? currentNumber,
    int? lastNumber,
    int? averageWaitMinutes,
    bool? isActive,
  }) {
    return DepartmentEntity(
      id: id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      currentNumber: currentNumber ?? this.currentNumber,
      lastNumber: lastNumber ?? this.lastNumber,
      averageWaitMinutes: averageWaitMinutes ?? this.averageWaitMinutes,
      isActive: isActive ?? this.isActive,
    );
  }
}

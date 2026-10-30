class BedCapacity {
  final int total;
  final int available;

  const BedCapacity({
    required this.total,
    required this.available,
  });

  int get occupied => total - available;
  double get occupancyRate => total > 0 ? (occupied / total) : 0.0;

  BedCapacity copyWith({int? total, int? available}) {
    return BedCapacity(
      total: total ?? this.total,
      available: available ?? this.available,
    );
  }
}

class HospitalEntity {
  final String id;
  final String nameAr;
  final String nameEn;
  final String governorate;
  final String addressAr;
  final double latitude;
  final double longitude;
  final BedCapacity icu;
  final BedCapacity incubator;
  final BedCapacity ventilator;
  final BedCapacity general;
  final DateTime lastUpdated;

  HospitalEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.governorate,
    required this.addressAr,
    required this.latitude,
    required this.longitude,
    required this.icu,
    required this.incubator,
    required this.ventilator,
    required this.general,
    required this.lastUpdated,
  });

  String getName(String locale) => locale == 'en' ? nameEn : nameAr;

  HospitalEntity copyWith({
    String? nameAr,
    String? nameEn,
    String? governorate,
    String? addressAr,
    double? latitude,
    double? longitude,
    BedCapacity? icu,
    BedCapacity? incubator,
    BedCapacity? ventilator,
    BedCapacity? general,
    DateTime? lastUpdated,
  }) {
    return HospitalEntity(
      id: id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      governorate: governorate ?? this.governorate,
      addressAr: addressAr ?? this.addressAr,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      icu: icu ?? this.icu,
      incubator: incubator ?? this.incubator,
      ventilator: ventilator ?? this.ventilator,
      general: general ?? this.general,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

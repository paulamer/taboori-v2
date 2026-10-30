import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/hospital_entity.dart';

class HospitalModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String governorate;
  final String addressAr;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> icu;
  final Map<String, dynamic> incubator;
  final Map<String, dynamic> ventilator;
  final Map<String, dynamic> general;
  final DateTime lastUpdated;

  HospitalModel({
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

  factory HospitalModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    Map<String, dynamic> parseBed(dynamic val) {
      if (val is Map) {
        return {
          'total': val['total'] ?? 0,
          'available': val['available'] ?? 0,
        };
      }
      return {'total': 0, 'available': 0};
    }

    return HospitalModel(
      id: id,
      nameAr: map['nameAr'] ?? '',
      nameEn: map['nameEn'] ?? '',
      governorate: map['governorate'] ?? '',
      addressAr: map['addressAr'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      icu: parseBed(map['beds']?['icu']),
      incubator: parseBed(map['beds']?['incubator']),
      ventilator: parseBed(map['beds']?['ventilator']),
      general: parseBed(map['beds']?['general']),
      lastUpdated: parseDate(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'governorate': governorate,
      'addressAr': addressAr,
      'latitude': latitude,
      'longitude': longitude,
      'beds': {
        'icu': icu,
        'incubator': incubator,
        'ventilator': ventilator,
        'general': general,
      },
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  HospitalEntity toEntity() {
    return HospitalEntity(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      governorate: governorate,
      addressAr: addressAr,
      latitude: latitude,
      longitude: longitude,
      icu: BedCapacity(
        total: icu['total'] ?? 0,
        available: icu['available'] ?? 0,
      ),
      incubator: BedCapacity(
        total: incubator['total'] ?? 0,
        available: incubator['available'] ?? 0,
      ),
      ventilator: BedCapacity(
        total: ventilator['total'] ?? 0,
        available: ventilator['available'] ?? 0,
      ),
      general: BedCapacity(
        total: general['total'] ?? 0,
        available: general['available'] ?? 0,
      ),
      lastUpdated: lastUpdated,
    );
  }

  factory HospitalModel.fromEntity(HospitalEntity entity) {
    return HospitalModel(
      id: entity.id,
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      governorate: entity.governorate,
      addressAr: entity.addressAr,
      latitude: entity.latitude,
      longitude: entity.longitude,
      icu: {'total': entity.icu.total, 'available': entity.icu.available},
      incubator: {'total': entity.incubator.total, 'available': entity.incubator.available},
      ventilator: {'total': entity.ventilator.total, 'available': entity.ventilator.available},
      general: {'total': entity.general.total, 'available': entity.general.available},
      lastUpdated: entity.lastUpdated,
    );
  }
}

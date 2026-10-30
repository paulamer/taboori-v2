import 'dart:async';
import '../../domain/entities/hospital_entity.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/hospital_model.dart';

class MockHospitalRepository implements HospitalRepository {
  final LocalDataSource _localDataSource;
  
  // Cache of hospitals and departments in memory for simulated live changes
  final List<HospitalEntity> _hospitals = [];
  final Map<String, List<DepartmentEntity>> _departments = {};
  
  // Stream controllers to broadcast updates
  final Map<String, StreamController<HospitalEntity>> _hospitalStreamers = {};
  final Map<String, StreamController<List<DepartmentEntity>>> _deptStreamers = {};

  MockHospitalRepository(this._localDataSource);

  Future<void> _ensureInitialized() async {
    if (_hospitals.isNotEmpty) return;
    
    final cached = await _localDataSource.getCachedHospitals();
    if (cached.isNotEmpty) {
      _hospitals.addAll(cached.map((h) => h.toEntity()));
    } else {
      // Seed default Egyptian hospitals
      _hospitals.addAll([
        HospitalEntity(
          id: 'hosp_1',
          nameAr: 'مستشفى قصر العيني الجامعي',
          nameEn: 'Al-Qasr Al-Aini University Hospital',
          governorate: 'القاهرة',
          addressAr: 'شارع القصر العيني، المنيل، القاهرة',
          latitude: 30.0315,
          longitude: 31.2269,
          icu: const BedCapacity(total: 25, available: 4),
          incubator: const BedCapacity(total: 15, available: 2),
          ventilator: const BedCapacity(total: 12, available: 1),
          general: const BedCapacity(total: 300, available: 45),
          lastUpdated: DateTime.now(),
        ),
        HospitalEntity(
          id: 'hosp_2',
          nameAr: 'مستشفى أبو الريش للأطفال',
          nameEn: 'Abu El-Reesh Pediatrics Hospital',
          governorate: 'القاهرة',
          addressAr: 'السيدة زينب، القاهرة',
          latitude: 30.0271,
          longitude: 31.2285,
          icu: const BedCapacity(total: 10, available: 0), // Full ICU
          incubator: const BedCapacity(total: 35, available: 5),
          ventilator: const BedCapacity(total: 8, available: 0),
          general: const BedCapacity(total: 150, available: 20),
          lastUpdated: DateTime.now(),
        ),
        HospitalEntity(
          id: 'hosp_3',
          nameAr: 'مستشفى الدمرداش',
          nameEn: 'Demerdash Hospital',
          governorate: 'القاهرة',
          addressAr: 'شارع رمسيس، العباسية، القاهرة',
          latitude: 30.0765,
          longitude: 31.2778,
          icu: const BedCapacity(total: 30, available: 8),
          incubator: const BedCapacity(total: 20, available: 3),
          ventilator: const BedCapacity(total: 15, available: 4),
          general: const BedCapacity(total: 400, available: 92),
          lastUpdated: DateTime.now(),
        ),
        HospitalEntity(
          id: 'hosp_4',
          nameAr: 'المستشفى الميري الجامعي بالأسكندرية',
          nameEn: 'Alexandria Main University Hospital',
          governorate: 'الإسكندرية',
          addressAr: 'الأزاريطة، وسط البلد، الإسكندرية',
          latitude: 31.2066,
          longitude: 29.9085,
          icu: const BedCapacity(total: 20, available: 2),
          incubator: const BedCapacity(total: 12, available: 0),
          ventilator: const BedCapacity(total: 10, available: 1),
          general: const BedCapacity(total: 280, available: 35),
          lastUpdated: DateTime.now(),
        ),
        HospitalEntity(
          id: 'hosp_5',
          nameAr: 'مستشفى حميات العباسية',
          nameEn: 'Abbasia Fever Hospital',
          governorate: 'القاهرة',
          addressAr: 'شارع امتداد رمسيس، العباسية، القاهرة',
          latitude: 30.0658,
          longitude: 31.2941,
          icu: const BedCapacity(total: 15, available: 1),
          incubator: const BedCapacity(total: 5, available: 1),
          ventilator: const BedCapacity(total: 10, available: 2),
          general: const BedCapacity(total: 200, available: 50),
          lastUpdated: DateTime.now(),
        ),
      ]);
      await _localDataSource.cacheHospitals(
        _hospitals.map((h) => HospitalModel.fromEntity(h)).toList(),
      );
    }

    // Seed departments for each hospital
    for (var hosp in _hospitals) {
      _departments[hosp.id] = [
        DepartmentEntity(
          id: 'dept_er',
          nameAr: 'قسم الطوارئ والاستقبال',
          nameEn: 'Emergency Room & Reception (ER)',
          currentNumber: 15,
          lastNumber: 22,
          averageWaitMinutes: 5,
          isActive: true,
        ),
        DepartmentEntity(
          id: 'dept_cardio',
          nameAr: 'عيادة أمراض القلب والأوعية الدموية',
          nameEn: 'Cardiology Clinic',
          currentNumber: 4,
          lastNumber: 9,
          averageWaitMinutes: 15,
          isActive: true,
        ),
        DepartmentEntity(
          id: 'dept_pediatrics',
          nameAr: 'عيادة طب الأطفال وحديثي الولادة',
          nameEn: 'Pediatrics Clinic',
          currentNumber: 8,
          lastNumber: 15,
          averageWaitMinutes: 10,
          isActive: true,
        ),
        DepartmentEntity(
          id: 'dept_surgery',
          nameAr: 'عيادة الجراحة العامة',
          nameEn: 'General Surgery Clinic',
          currentNumber: 2,
          lastNumber: 5,
          averageWaitMinutes: 20,
          isActive: true,
        ),
      ];
    }
  }

  @override
  Future<List<HospitalEntity>> getHospitals() async {
    await _ensureInitialized();
    return _hospitals;
  }

  @override
  Stream<HospitalEntity> streamHospital(String hospitalId) async* {
    await _ensureInitialized();
    final index = _hospitals.indexWhere((h) => h.id == hospitalId);
    if (index != -1) {
      yield _hospitals[index];
    }
    _hospitalStreamers.putIfAbsent(hospitalId, () => StreamController<HospitalEntity>.broadcast());
    yield* _hospitalStreamers[hospitalId]!.stream;
  }

  @override
  Future<List<DepartmentEntity>> getDepartments(String hospitalId) async {
    await _ensureInitialized();
    return _departments[hospitalId] ?? [];
  }

  @override
  Stream<List<DepartmentEntity>> streamDepartments(String hospitalId) async* {
    await _ensureInitialized();
    yield _departments[hospitalId] ?? [];
    _deptStreamers.putIfAbsent(hospitalId, () => StreamController<List<DepartmentEntity>>.broadcast());
    yield* _deptStreamers[hospitalId]!.stream;
  }

  @override
  Future<void> updateBedCapacity(
    String hospitalId, {
    int? icuAvailable,
    int? incubatorAvailable,
    int? ventilatorAvailable,
    int? generalAvailable,
  }) async {
    await _ensureInitialized();
    final idx = _hospitals.indexWhere((h) => h.id == hospitalId);
    if (idx != -1) {
      var h = _hospitals[idx];
      _hospitals[idx] = h.copyWith(
        icu: icuAvailable != null ? h.icu.copyWith(available: icuAvailable) : h.icu,
        incubator: incubatorAvailable != null ? h.incubator.copyWith(available: incubatorAvailable) : h.incubator,
        ventilator: ventilatorAvailable != null ? h.ventilator.copyWith(available: ventilatorAvailable) : h.ventilator,
        general: generalAvailable != null ? h.general.copyWith(available: generalAvailable) : h.general,
        lastUpdated: DateTime.now(),
      );

      // Save to Hive
      await _localDataSource.cacheHospitals(
        _hospitals.map((item) => HospitalModel.fromEntity(item)).toList(),
      );

      // Notify streams
      _hospitalStreamers[hospitalId]?.add(_hospitals[idx]);
    }
  }

  @override
  Future<void> updateDepartmentQueue(
    String hospitalId,
    String departmentId, {
    int? currentNumber,
    int? lastNumber,
  }) async {
    await _ensureInitialized();
    final depts = _departments[hospitalId];
    if (depts != null) {
      final idx = depts.indexWhere((d) => d.id == departmentId);
      if (idx != -1) {
        final d = depts[idx];
        depts[idx] = d.copyWith(
          currentNumber: currentNumber ?? d.currentNumber,
          lastNumber: lastNumber ?? d.lastNumber,
        );

        // Notify streams
        _deptStreamers[hospitalId]?.add(depts);
      }
    }
  }
}

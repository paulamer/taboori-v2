import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/hospital_entity.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/hospital_model.dart';
import '../models/department_model.dart';

class FirebaseHospitalRepository implements HospitalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalDataSource _localDataSource;

  FirebaseHospitalRepository(this._localDataSource);

  @override
  Future<List<HospitalEntity>> getHospitals() async {
    try {
      var snapshot = await _firestore.collection('hospitals').get();
      
      // Auto-seed if database is empty (e.g. brand new Firebase project)
      if (snapshot.docs.isEmpty) {
        await _seedDefaultHospitals();
        snapshot = await _firestore.collection('hospitals').get();
      }

      final models = snapshot.docs.map((doc) => HospitalModel.fromMap(doc.data(), doc.id)).toList();
      
      // Cache locally
      await _localDataSource.cacheHospitals(models);
      
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      // Offline fallback
      final cached = await _localDataSource.getCachedHospitals();
      return cached.map((c) => c.toEntity()).toList();
    }
  }

  Future<void> _seedDefaultHospitals() async {
    final batch = _firestore.batch();
    
    final hospitals = [
      HospitalModel(
        id: 'hosp_1',
        nameAr: 'مستشفى قصر العيني الجامعي',
        nameEn: 'Al-Qasr Al-Aini University Hospital',
        governorate: 'القاهرة',
        addressAr: 'شارع القصر العيني، المنيل، القاهرة',
        latitude: 30.0315,
        longitude: 31.2269,
        icu: {'total': 25, 'available': 4},
        incubator: {'total': 15, 'available': 2},
        ventilator: {'total': 12, 'available': 1},
        general: {'total': 300, 'available': 45},
        lastUpdated: DateTime.now(),
      ),
      HospitalModel(
        id: 'hosp_2',
        nameAr: 'مستشفى أبو الريش للأطفال',
        nameEn: 'Abu El-Reesh Pediatrics Hospital',
        governorate: 'القاهرة',
        addressAr: 'السيدة زينب، القاهرة',
        latitude: 30.0271,
        longitude: 31.2285,
        icu: {'total': 10, 'available': 0},
        incubator: {'total': 35, 'available': 5},
        ventilator: {'total': 8, 'available': 0},
        general: {'total': 150, 'available': 20},
        lastUpdated: DateTime.now(),
      ),
      HospitalModel(
        id: 'hosp_3',
        nameAr: 'مستشفى الدمرداش',
        nameEn: 'Demerdash Hospital',
        governorate: 'القاهرة',
        addressAr: 'شارع رمسيس، العباسية، القاهرة',
        latitude: 30.0765,
        longitude: 31.2778,
        icu: {'total': 30, 'available': 8},
        incubator: {'total': 20, 'available': 3},
        ventilator: {'total': 15, 'available': 4},
        general: {'total': 400, 'available': 92},
        lastUpdated: DateTime.now(),
      ),
      HospitalModel(
        id: 'hosp_4',
        nameAr: 'المستشفى الميري الجامعي بالأسكندرية',
        nameEn: 'Alexandria Main University Hospital',
        governorate: 'الإسكندرية',
        addressAr: 'الأزاريطة، وسط البلد، الإسكندرية',
        latitude: 31.2066,
        longitude: 29.9085,
        icu: {'total': 20, 'available': 2},
        incubator: {'total': 12, 'available': 0},
        ventilator: {'total': 10, 'available': 1},
        general: {'total': 280, 'available': 35},
        lastUpdated: DateTime.now(),
      ),
      HospitalModel(
        id: 'hosp_5',
        nameAr: 'مستشفى حميات العباسية',
        nameEn: 'Abbasia Fever Hospital',
        governorate: 'القاهرة',
        addressAr: 'شارع امتداد رمسيس، العباسية، القاهرة',
        latitude: 30.0658,
        longitude: 31.2941,
        icu: {'total': 15, 'available': 1},
        incubator: {'total': 5, 'available': 1},
        ventilator: {'total': 10, 'available': 2},
        general: {'total': 200, 'available': 50},
        lastUpdated: DateTime.now(),
      ),
    ];

    for (var h in hospitals) {
      final hospRef = _firestore.collection('hospitals').doc(h.id);
      batch.set(hospRef, h.toMap());

      // Seed departments
      final depts = [
        {'id': 'dept_er', 'nameAr': 'قسم الطوارئ والاستقبال', 'nameEn': 'Emergency Room & Reception (ER)', 'currentNumber': 15, 'lastNumber': 22, 'averageWaitMinutes': 5, 'isActive': true},
        {'id': 'dept_cardio', 'nameAr': 'عيادة أمراض القلب والأوعية الدموية', 'nameEn': 'Cardiology Clinic', 'currentNumber': 4, 'lastNumber': 9, 'averageWaitMinutes': 15, 'isActive': true},
        {'id': 'dept_pediatrics', 'nameAr': 'عيادة طب الأطفال وحديثي الولادة', 'nameEn': 'Pediatrics Clinic', 'currentNumber': 8, 'lastNumber': 15, 'averageWaitMinutes': 10, 'isActive': true},
        {'id': 'dept_surgery', 'nameAr': 'عيادة الجراحة العامة', 'nameEn': 'General Surgery Clinic', 'currentNumber': 2, 'lastNumber': 5, 'averageWaitMinutes': 20, 'isActive': true},
      ];

      for (var d in depts) {
        final deptRef = hospRef.collection('departments').doc(d['id'] as String);
        batch.set(deptRef, {
          'nameAr': d['nameAr'],
          'nameEn': d['nameEn'],
          'currentNumber': d['currentNumber'],
          'lastNumber': d['lastNumber'],
          'averageWaitMinutes': d['averageWaitMinutes'],
          'isActive': d['isActive'],
        });
      }
    }

    await batch.commit();
  }

  @override
  Stream<HospitalEntity> streamHospital(String hospitalId) {
    return _firestore
        .collection('hospitals')
        .doc(hospitalId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            throw Exception('Hospital not found');
          }
          final model = HospitalModel.fromMap(snapshot.data()!, snapshot.id);
          return model.toEntity();
        });
  }

  @override
  Future<List<DepartmentEntity>> getDepartments(String hospitalId) async {
    final snapshot = await _firestore
        .collection('hospitals')
        .doc(hospitalId)
        .collection('departments')
        .get();
    return snapshot.docs
        .map((doc) => DepartmentModel.fromMap(doc.data(), doc.id).toEntity())
        .toList();
  }

  @override
  Stream<List<DepartmentEntity>> streamDepartments(String hospitalId) {
    return _firestore
        .collection('hospitals')
        .doc(hospitalId)
        .collection('departments')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => DepartmentModel.fromMap(doc.data(), doc.id).toEntity())
              .toList();
        });
  }

  @override
  Future<void> updateBedCapacity(
    String hospitalId, {
    int? icuAvailable,
    int? incubatorAvailable,
    int? ventilatorAvailable,
    int? generalAvailable,
  }) async {
    final Map<String, dynamic> updates = {};
    if (icuAvailable != null) updates['beds.icu.available'] = icuAvailable;
    if (incubatorAvailable != null) updates['beds.incubator.available'] = incubatorAvailable;
    if (ventilatorAvailable != null) updates['beds.ventilator.available'] = ventilatorAvailable;
    if (generalAvailable != null) updates['beds.general.available'] = generalAvailable;
    
    updates['lastUpdated'] = FieldValue.serverTimestamp();

    await _firestore.collection('hospitals').doc(hospitalId).update(updates);
  }

  @override
  Future<void> updateDepartmentQueue(
    String hospitalId,
    String departmentId, {
    int? currentNumber,
    int? lastNumber,
  }) async {
    final Map<String, dynamic> updates = {};
    if (currentNumber != null) updates['currentNumber'] = currentNumber;
    if (lastNumber != null) updates['lastNumber'] = lastNumber;

    await _firestore
        .collection('hospitals')
        .doc(hospitalId)
        .collection('departments')
        .doc(departmentId)
        .update(updates);
  }
}

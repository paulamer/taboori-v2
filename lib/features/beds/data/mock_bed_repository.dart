import '../domain/bed_entity.dart';

/// Mock bed repository providing realistic fictional Egyptian hospital bed data
/// for demo mode and graduation presentations.
class MockBedRepository {
  List<BedEntity>? _cachedBeds;

  Future<List<BedEntity>> getAllBeds() async {
    _cachedBeds ??= _generateDemoBeds();
    return _cachedBeds!;
  }

  Future<List<BedEntity>> getBedsByHospital(String hospitalId) async {
    final all = await getAllBeds();
    return all.where((b) => b.hospitalId == hospitalId).toList();
  }

  Future<List<BedEntity>> getBedsByDepartment(
      String hospitalId, String departmentId) async {
    final all = await getAllBeds();
    return all
        .where((b) => b.hospitalId == hospitalId && b.departmentId == departmentId)
        .toList();
  }

  Future<BedOccupancySummary> getOccupancySummary(String hospitalId,
      [String? departmentId]) async {
    final beds = departmentId != null
        ? await getBedsByDepartment(hospitalId, departmentId)
        : await getBedsByHospital(hospitalId);
    return BedOccupancySummary.fromBeds(beds);
  }

  Future<BedEntity> updateBedStatus(String bedId, BedStatus newStatus,
      {String? patientId, String? patientName}) async {
    final beds = await getAllBeds();
    final idx = beds.indexWhere((b) => b.id == bedId);
    if (idx == -1) throw Exception('Bed not found: $bedId');

    final updated = beds[idx].copyWith(
      status: newStatus,
      patientId: newStatus == BedStatus.occupied ? patientId : null,
      patientName: newStatus == BedStatus.occupied ? patientName : null,
      assignedAt: newStatus == BedStatus.occupied ? DateTime.now() : null,
    );
    _cachedBeds![idx] = updated;
    return updated;
  }

  Future<List<BedEntity>> findAvailableBeds({
    String? hospitalId,
    String? departmentId,
    BedType? type,
  }) async {
    final all = await getAllBeds();
    return all.where((b) {
      if (!b.isAvailable) return false;
      if (hospitalId != null && b.hospitalId != hospitalId) return false;
      if (departmentId != null && b.departmentId != departmentId) return false;
      if (type != null && b.type != type) return false;
      return true;
    }).toList();
  }

  /// Generate realistic demo beds for 3 fictional Egyptian hospitals
  List<BedEntity> _generateDemoBeds() {
    final beds = <BedEntity>[];
    int counter = 0;

    // Hospital data: (id, departments with bed configs)
    final hospitals = {
      'hosp_shoubra': {
        'dept_emergency': _DeptBeds('طوارئ', [
          _WardBeds('A', BedType.emergency, 8, [0, 1, 2, 3, 4, 5]),
          _WardBeds('B', BedType.emergency, 6, [0, 1, 2, 3]),
        ]),
        'dept_icu': _DeptBeds('عناية مركزة', [
          _WardBeds('ICU-1', BedType.icu, 10, [0, 1, 2, 3, 4, 5, 6, 7]),
        ]),
        'dept_internal': _DeptBeds('باطنة', [
          _WardBeds('C', BedType.general, 12, [0, 1, 2, 3, 4, 5, 6]),
          _WardBeds('D', BedType.general, 10, [0, 1, 2, 3, 4]),
        ]),
        'dept_surgery': _DeptBeds('جراحة', [
          _WardBeds('S-1', BedType.general, 8, [0, 1, 2, 3, 4]),
        ]),
        'dept_pediatrics': _DeptBeds('أطفال', [
          _WardBeds('P-1', BedType.general, 6, [0, 1, 2]),
          _WardBeds('P-2', BedType.incubator, 8, [0, 1, 2, 3, 4, 5]),
        ]),
      },
      'hosp_matariya': {
        'dept_emergency': _DeptBeds('طوارئ', [
          _WardBeds('A', BedType.emergency, 10, [0, 1, 2, 3, 4, 5, 6]),
        ]),
        'dept_icu': _DeptBeds('عناية مركزة', [
          _WardBeds('ICU-1', BedType.icu, 8, [0, 1, 2, 3, 4, 5, 6]),
        ]),
        'dept_internal': _DeptBeds('باطنة', [
          _WardBeds('C', BedType.general, 14, [0, 1, 2, 3, 4, 5, 6, 7]),
        ]),
      },
      'hosp_nasr_city': {
        'dept_emergency': _DeptBeds('طوارئ', [
          _WardBeds('A', BedType.emergency, 6, [0, 1, 2, 3]),
        ]),
        'dept_icu': _DeptBeds('عناية مركزة', [
          _WardBeds('ICU-1', BedType.icu, 6, [0, 1, 2, 3, 4]),
        ]),
        'dept_pediatrics': _DeptBeds('أطفال', [
          _WardBeds('P-1', BedType.incubator, 6, [0, 1, 2, 3]),
        ]),
      },
    };

    final statuses = [
      BedStatus.occupied,
      BedStatus.cleaning,
      BedStatus.maintenance,
      BedStatus.reserved,
    ];

    final patientNames = [
      'محمد أحمد',
      'فاطمة علي',
      'عمر حسن',
      'نورا سعيد',
      'أحمد محمود',
      'سارة إبراهيم',
      'حسين كمال',
      'مريم عبدالله',
    ];

    for (final hospEntry in hospitals.entries) {
      for (final deptEntry in hospEntry.value.entries) {
        for (final ward in deptEntry.value.wards) {
          for (int i = 0; i < ward.totalBeds; i++) {
            final isOccupied = ward.occupiedIndices.contains(i);
            BedStatus status;
            String? patientId;
            String? patientName;

            if (isOccupied) {
              // Distribute some non-available statuses
              if (i == ward.occupiedIndices.last && ward.occupiedIndices.length > 2) {
                status = statuses[counter % statuses.length];
              } else {
                status = BedStatus.occupied;
              }
              if (status == BedStatus.occupied) {
                patientId = 'patient_${counter}';
                patientName = patientNames[counter % patientNames.length];
              }
            } else {
              status = BedStatus.available;
            }

            beds.add(BedEntity(
              id: 'bed_${counter++}',
              hospitalId: hospEntry.key,
              departmentId: deptEntry.key,
              wardId: ward.wardName,
              roomNumber: ward.wardName,
              bedNumber: '${ward.wardName}-${i + 1}',
              type: ward.type,
              status: status,
              patientId: patientId,
              patientName: patientName,
              assignedAt: status == BedStatus.occupied
                  ? DateTime.now().subtract(Duration(hours: counter * 3))
                  : null,
            ));
          }
        }
      }
    }
    return beds;
  }
}

class _DeptBeds {
  final String name;
  final List<_WardBeds> wards;
  const _DeptBeds(this.name, this.wards);
}

class _WardBeds {
  final String wardName;
  final BedType type;
  final int totalBeds;
  final List<int> occupiedIndices;
  const _WardBeds(this.wardName, this.type, this.totalBeds, this.occupiedIndices);
}

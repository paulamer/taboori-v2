import '../entities/hospital_entity.dart';
import '../entities/department_entity.dart';

abstract class HospitalRepository {
  Future<List<HospitalEntity>> getHospitals();
  Stream<HospitalEntity> streamHospital(String hospitalId);
  Future<List<DepartmentEntity>> getDepartments(String hospitalId);
  Stream<List<DepartmentEntity>> streamDepartments(String hospitalId);
  Future<void> updateBedCapacity(
    String hospitalId, {
    int? icuAvailable,
    int? incubatorAvailable,
    int? ventilatorAvailable,
    int? generalAvailable,
  });
  Future<void> updateDepartmentQueue(
    String hospitalId,
    String departmentId, {
    int? currentNumber,
    int? lastNumber,
  });
}

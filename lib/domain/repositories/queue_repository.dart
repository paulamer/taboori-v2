import '../entities/queue_ticket_entity.dart';

abstract class QueueRepository {
  Future<QueueTicketEntity> bookQueueTicket({
    required String patientId,
    required String patientName,
    required String nationalId,
    required String hospitalId,
    required String hospitalNameAr,
    required String hospitalNameEn,
    required String departmentId,
    required String departmentNameAr,
    required String departmentNameEn,
  });
  Stream<List<QueueTicketEntity>> streamPatientTickets(String patientId);
  Stream<QueueTicketEntity> streamTicket(String ticketId);
  Stream<List<QueueTicketEntity>> streamDepartmentTickets(String hospitalId, String departmentId);
  Future<void> updateTicketStatus(String ticketId, QueueStatus status);
  Future<void> checkInTicket(String ticketId);
}

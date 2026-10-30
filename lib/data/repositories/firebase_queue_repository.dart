import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/queue_ticket_entity.dart';
import '../../domain/repositories/queue_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/queue_ticket_model.dart';

class FirebaseQueueRepository implements QueueRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalDataSource _localDataSource;

  FirebaseQueueRepository(this._localDataSource);

  @override
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
  }) async {
    final ticketRef = _firestore.collection('queues').doc();
    final deptRef = _firestore
        .collection('hospitals')
        .doc(hospitalId)
        .collection('departments')
        .doc(departmentId);

    return await _firestore.runTransaction<QueueTicketEntity>((transaction) async {
      final deptSnapshot = await transaction.get(deptRef);
      if (!deptSnapshot.exists) {
        throw Exception('Department document not found at: ${deptRef.path}. Please ensure your database is seeded.');
      }

      final data = deptSnapshot.data();
      final currentLastNumber = data?['lastNumber'] ?? 0;
      final newTicketNumber = currentLastNumber + 1;

      // Update last number in department
      transaction.update(deptRef, {'lastNumber': newTicketNumber});

      final model = QueueTicketModel(
        id: ticketRef.id,
        patientId: patientId,
        patientName: patientName,
        nationalId: nationalId,
        hospitalId: hospitalId,
        hospitalNameAr: hospitalNameAr,
        hospitalNameEn: hospitalNameEn,
        departmentId: departmentId,
        departmentNameAr: departmentNameAr,
        departmentNameEn: departmentNameEn,
        ticketNumber: newTicketNumber,
        status: 'waiting',
        createdAt: DateTime.now(),
      );

      // Create ticket document
      transaction.set(ticketRef, model.toMap());

      return model.toEntity();
    }).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Booking timed out. Please check your internet connection.'),
    );
  }

  @override
  Stream<List<QueueTicketEntity>> streamPatientTickets(String patientId) {
    return _firestore
        .collection('queues')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
          final models = snapshot.docs
              .map((doc) => QueueTicketModel.fromMap(doc.data(), doc.id))
              .toList();
          
          // Sort in memory to avoid needing a Firestore Index
          models.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Cache locally
          _localDataSource.cacheTickets(models);

          return models.map((m) => m.toEntity()).toList();
        });
  }

  @override
  Stream<QueueTicketEntity> streamTicket(String ticketId) {
    return _firestore
        .collection('queues')
        .doc(ticketId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            throw Exception('Ticket not found');
          }
          return QueueTicketModel.fromMap(snapshot.data()!, snapshot.id).toEntity();
        });
  }

  @override
  Stream<List<QueueTicketEntity>> streamDepartmentTickets(String hospitalId, String departmentId) {
    return _firestore
        .collection('queues')
        .where('hospitalId', isEqualTo: hospitalId)
        .where('departmentId', isEqualTo: departmentId)
        .snapshots()
        .map((snapshot) {
          final tickets = snapshot.docs
              .map((doc) => QueueTicketModel.fromMap(doc.data(), doc.id).toEntity())
              .toList();
          
          // Sort in memory to avoid needing a Firestore Index
          tickets.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          
          return tickets;
        });
  }

  @override
  Future<void> updateTicketStatus(String ticketId, QueueStatus status) async {
    final Map<String, dynamic> updates = {'status': status.value};
    
    if (status == QueueStatus.active) {
      updates['calledAt'] = FieldValue.serverTimestamp();
      
      // We also update department current serving number in a batch or separately
      final doc = await _firestore.collection('queues').doc(ticketId).get();
      if (doc.exists && doc.data() != null) {
        final ticket = QueueTicketModel.fromMap(doc.data()!, doc.id);
        await _firestore
            .collection('hospitals')
            .doc(ticket.hospitalId)
            .collection('departments')
            .doc(ticket.departmentId)
            .update({'currentNumber': ticket.ticketNumber});
      }
    } else if (status == QueueStatus.completed) {
      updates['completedAt'] = FieldValue.serverTimestamp();
    }

    await _firestore.collection('queues').doc(ticketId).update(updates);
  }

  @override
  Future<void> checkInTicket(String ticketId) async {
    await _firestore.collection('queues').doc(ticketId).update({
      'checkedInAt': FieldValue.serverTimestamp(),
    });
  }
}

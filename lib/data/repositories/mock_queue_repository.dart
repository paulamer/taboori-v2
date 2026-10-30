import 'dart:async';
import '../../domain/entities/queue_ticket_entity.dart';
import '../../domain/repositories/queue_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/queue_ticket_model.dart';
import 'mock_hospital_repository.dart';

class MockQueueRepository implements QueueRepository {
  final LocalDataSource _localDataSource;
  final MockHospitalRepository _mockHospitalRepository;
  
  final List<QueueTicketEntity> _tickets = [];
  final StreamController<List<QueueTicketEntity>> _patientTicketsController = StreamController<List<QueueTicketEntity>>.broadcast();
  final Map<String, StreamController<QueueTicketEntity>> _ticketStreamers = {};
  final Map<String, StreamController<List<QueueTicketEntity>>> _deptTicketStreamers = {};

  MockQueueRepository(this._localDataSource, this._mockHospitalRepository) {
    _init();
  }

  void _init() async {
    final cached = await _localDataSource.getCachedTickets();
    if (cached.isNotEmpty) {
      _tickets.addAll(cached.map((t) => t.toEntity()));
    }
    _patientTicketsController.add(_tickets);
  }

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
    await Future.delayed(const Duration(milliseconds: 500));

    // Get current department queue number
    final depts = await _mockHospitalRepository.getDepartments(hospitalId);
    final dept = depts.firstWhere((d) => d.id == departmentId);
    final newTicketNum = dept.lastNumber + 1;

    // Update the hospital department queue
    await _mockHospitalRepository.updateDepartmentQueue(
      hospitalId,
      departmentId,
      lastNumber: newTicketNum,
    );

    final ticket = QueueTicketEntity(
      id: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      patientName: patientName,
      nationalId: nationalId,
      hospitalId: hospitalId,
      hospitalNameAr: hospitalNameAr,
      hospitalNameEn: hospitalNameEn,
      departmentId: departmentId,
      departmentNameAr: departmentNameAr,
      departmentNameEn: departmentNameEn,
      ticketNumber: newTicketNum,
      status: QueueStatus.waiting,
      createdAt: DateTime.now(),
    );

    _tickets.add(ticket);
    await _saveToLocalCache();
    
    // Broadcast updates
    _patientTicketsController.add(_tickets);
    _ticketStreamers[ticket.id]?.add(ticket);
    _broadcastDeptTickets(hospitalId, departmentId);

    return ticket;
  }

  @override
  Stream<List<QueueTicketEntity>> streamPatientTickets(String patientId) async* {
    yield _tickets.where((t) => t.patientId == patientId).toList();
    yield* _patientTicketsController.stream.map(
      (list) => list.where((t) => t.patientId == patientId).toList(),
    );
  }

  @override
  Stream<QueueTicketEntity> streamTicket(String ticketId) async* {
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      yield _tickets[idx];
    }
    
    _ticketStreamers.putIfAbsent(ticketId, () => StreamController<QueueTicketEntity>.broadcast());
    yield* _ticketStreamers[ticketId]!.stream;
  }

  @override
  Stream<List<QueueTicketEntity>> streamDepartmentTickets(String hospitalId, String departmentId) async* {
    yield _tickets.where((t) => t.hospitalId == hospitalId && t.departmentId == departmentId).toList();
    
    final key = '${hospitalId}_$departmentId';
    _deptTicketStreamers.putIfAbsent(key, () => StreamController<List<QueueTicketEntity>>.broadcast());
    yield* _deptTicketStreamers[key]!.stream;
  }

  @override
  Future<void> updateTicketStatus(String ticketId, QueueStatus status) async {
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      var ticket = _tickets[idx];
      
      DateTime? calledAt = ticket.calledAt;
      DateTime? completedAt = ticket.completedAt;

      if (status == QueueStatus.active) {
        calledAt = DateTime.now();
        // Also automatically update the hospital department's current calling number
        await _mockHospitalRepository.updateDepartmentQueue(
          ticket.hospitalId,
          ticket.departmentId,
          currentNumber: ticket.ticketNumber,
        );
      } else if (status == QueueStatus.completed) {
        completedAt = DateTime.now();
      }

      _tickets[idx] = ticket.copyWith(
        status: status,
        calledAt: calledAt,
        completedAt: completedAt,
      );

      await _saveToLocalCache();

      // Notify streams
      _patientTicketsController.add(_tickets);
      _ticketStreamers[ticketId]?.add(_tickets[idx]);
      _broadcastDeptTickets(ticket.hospitalId, ticket.departmentId);
    }
  }

  @override
  Future<void> checkInTicket(String ticketId) async {
    final idx = _tickets.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      final ticket = _tickets[idx];
      if (ticket.checkedInAt == null) {
        _tickets[idx] = QueueTicketEntity(
          id: ticket.id,
          patientId: ticket.patientId,
          patientName: ticket.patientName,
          nationalId: ticket.nationalId,
          hospitalId: ticket.hospitalId,
          hospitalNameAr: ticket.hospitalNameAr,
          hospitalNameEn: ticket.hospitalNameEn,
          departmentId: ticket.departmentId,
          departmentNameAr: ticket.departmentNameAr,
          departmentNameEn: ticket.departmentNameEn,
          ticketNumber: ticket.ticketNumber,
          status: ticket.status,
          createdAt: ticket.createdAt,
          checkedInAt: DateTime.now(),
          calledAt: ticket.calledAt,
          completedAt: ticket.completedAt,
        );

        await _saveToLocalCache();

        // Notify streams
        _patientTicketsController.add(_tickets);
        _ticketStreamers[ticketId]?.add(_tickets[idx]);
        _broadcastDeptTickets(ticket.hospitalId, ticket.departmentId);
      }
    }
  }

  void _broadcastDeptTickets(String hospitalId, String departmentId) {
    final key = '${hospitalId}_$departmentId';
    if (_deptTicketStreamers.containsKey(key)) {
      final filtered = _tickets.where((t) => t.hospitalId == hospitalId && t.departmentId == departmentId).toList();
      _deptTicketStreamers[key]!.add(filtered);
    }
  }

  Future<void> _saveToLocalCache() async {
    await _localDataSource.cacheTickets(
      _tickets.map((t) => QueueTicketModel.fromEntity(t)).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../data/datasources/local_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/hospital_entity.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/entities/queue_ticket_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../data/repositories/mock_hospital_repository.dart';
import '../../data/repositories/mock_queue_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/firebase_hospital_repository.dart';
import '../../data/repositories/firebase_queue_repository.dart';

// --- Local Data Source Provider ---
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
});

// --- Settings Providers (Locale & Theme) ---
class LocaleNotifier extends StateNotifier<String> {
  final LocalDataSource _localDataSource;
  LocaleNotifier(this._localDataSource) : super(_localDataSource.getLocale());

  void setLocale(String locale) {
    _localDataSource.saveLocale(locale);
    state = locale;
  }

  void toggleLocale() {
    final next = state == 'ar' ? 'en' : 'ar';
    setLocale(next);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  final local = ref.watch(localDataSourceProvider);
  return LocaleNotifier(local);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final LocalDataSource _localDataSource;
  ThemeNotifier(this._localDataSource)
      : super(_localDataSource.isDarkMode() ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() {
    final isDark = state == ThemeMode.dark;
    _localDataSource.saveThemeMode(!isDark);
    state = isDark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final local = ref.watch(localDataSourceProvider);
  return ThemeNotifier(local);
});

// --- Firebase Capability Check: Safely detects if Firebase Cloud is connected ---
final isFirebaseAvailableProvider = Provider<bool>((ref) {
  try {
    return Firebase.apps.isNotEmpty; // Returns true if Firebase initialized without timeout
  } catch (_) {
    return false; // Returns false if offline or Firebase unavailable
  }
});

// --- Repository Injection: Dynamic Dependency Injection (Clean Architecture) ---
// Injects FirebaseAuthRepository if online, or MockAuthRepository if offline
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final isFirebase = ref.watch(isFirebaseAvailableProvider); // Watch connection status
  final local = ref.watch(localDataSourceProvider);          // Inject Hive local cache
  if (isFirebase) {
    return FirebaseAuthRepository(local); // Production Firebase Auth implementation
  } else {
    return MockAuthRepository(local);     // In-memory Mock Auth implementation
  }
});

// Injects FirebaseHospitalRepository if online, or MockHospitalRepository if offline
final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  final isFirebase = ref.watch(isFirebaseAvailableProvider); // Watch connection status
  final local = ref.watch(localDataSourceProvider);          // Inject Hive local cache
  if (isFirebase) {
    return FirebaseHospitalRepository(local); // Production Firestore hospitals & beds
  } else {
    return MockHospitalRepository(local);     // In-memory Mock hospitals & beds
  }
});

// Injects FirebaseQueueRepository if online, or MockQueueRepository if offline
final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  final isFirebase = ref.watch(isFirebaseAvailableProvider); // Watch connection status
  final local = ref.watch(localDataSourceProvider);          // Inject Hive local cache
  if (isFirebase) {
    return FirebaseQueueRepository(local); // Production Firestore queue tickets stream
  } else {
    final hospRepo = ref.watch(hospitalRepositoryProvider) as MockHospitalRepository;
    return MockQueueRepository(local, hospRepo); // In-memory Mock queue tickets stream
  }
});

// --- Reactive Streams Providers: Real-time Live Updates without manual refresh ---
// Listens to user authentication state changes (Logged in, Logged out)
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final repo = ref.watch(authRepositoryProvider); // Depend on active Auth Repository
  return repo.authStateChanges();                 // Broadcast stream of current user
});

// Real-time stream of all tickets belonging to a specific patient National ID
final currentPatientTicketsProvider = StreamProvider.family<List<QueueTicketEntity>, String>((ref, patientId) {
  final repo = ref.watch(queueRepositoryProvider); // Depend on active Queue Repository
  return repo.streamPatientTickets(patientId);
});

final currentTicketProvider = StreamProvider.family<QueueTicketEntity, String>((ref, ticketId) {
  final repo = ref.watch(queueRepositoryProvider);
  return repo.streamTicket(ticketId);
});

final departmentTicketsProvider = StreamProvider.family<List<QueueTicketEntity>, (String, String)>((ref, arg) {
  final repo = ref.watch(queueRepositoryProvider);
  return repo.streamDepartmentTickets(arg.$1, arg.$2);
});

final hospitalStreamProvider = StreamProvider.family<HospitalEntity, String>((ref, hospitalId) {
  final repo = ref.watch(hospitalRepositoryProvider);
  return repo.streamHospital(hospitalId);
});

final departmentsStreamProvider = StreamProvider.family<List<DepartmentEntity>, String>((ref, hospitalId) {
  final repo = ref.watch(hospitalRepositoryProvider);
  return repo.streamDepartments(hospitalId);
});

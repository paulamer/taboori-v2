import 'dart:async';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/user_model.dart';

class MockAuthRepository implements AuthRepository {
  final LocalDataSource _localDataSource;
  final StreamController<UserEntity?> _authController = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  MockAuthRepository(this._localDataSource) {
    _init();
  }

  Future<void> _init() async {
    final cached = await _localDataSource.getUserSession();
    if (cached != null) {
      _currentUser = cached.toEntity();
    }
    _authController.add(_currentUser);
  }

  @override
  Stream<UserEntity?> authStateChanges() async* {
    yield _currentUser;
    yield* _authController.stream;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserEntity> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulating network lag
    
    // Simulate finding standard users based on email contents
    String name = 'أحمد محمد';
    UserRole role = UserRole.patient;
    String? hospitalId;
    String? departmentId;
    String nationalId = '29508230101234';

    if (email.contains('staff')) {
      role = UserRole.staff;
      name = 'د. سارة أحمد';
      hospitalId = 'hosp_1'; // Al-Qasr Al-Aini
      departmentId = 'dept_cardio';
    } else if (email.contains('admin')) {
      role = UserRole.admin;
      name = 'المفتش الوزاري / وزارة الصحة';
    }

    final user = UserEntity(
      uid: 'mock_uid_${email.split('@')[0]}',
      name: name,
      email: email,
      phone: '01012345678',
      nationalId: nationalId,
      role: role,
      hospitalId: hospitalId,
      departmentId: departmentId,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    await _localDataSource.saveUserSession(UserModel.fromEntity(user));
    _authController.add(_currentUser);
    return user;
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String nationalId,
    required UserRole role,
    String? hospitalId,
    String? departmentId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final user = UserEntity(
      uid: 'mock_uid_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      nationalId: nationalId,
      role: role,
      hospitalId: hospitalId,
      departmentId: departmentId,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    await _localDataSource.saveUserSession(UserModel.fromEntity(user));
    _authController.add(_currentUser);
    return user;
  }

  @override
  Future<void> signOut() async {
    await _localDataSource.clearUserSession();
    _currentUser = null;
    _authController.add(null);
  }
}

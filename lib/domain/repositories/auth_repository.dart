import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String nationalId,
    required UserRole role,
    String? hospitalId,
    String? departmentId,
  });
  Future<void> signOut();
  Stream<UserEntity?> authStateChanges();
}

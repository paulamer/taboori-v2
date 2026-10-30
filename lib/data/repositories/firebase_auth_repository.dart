import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/user_model.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalDataSource _localDataSource;

  FirebaseAuthRepository(this._localDataSource);

  @override
  Stream<UserEntity?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      print('🔑 FirebaseAuth authStateChanges: fbUser = ${fbUser?.uid}');
      if (fbUser == null) {
        print('🔑 fbUser is null, clearing local user session');
        await _localDataSource.clearUserSession();
        return null;
      }
      try {
        print('🔑 fbUser is NOT null (${fbUser.uid}). Querying Firestore users collection...');
        final doc = await _firestore
            .collection('users')
            .doc(fbUser.uid)
            .get()
            .timeout(const Duration(seconds: 4));
        print('🔑 Firestore users query complete. Document exists = ${doc.exists}');
        if (doc.exists && doc.data() != null) {
          final model = UserModel.fromMap(doc.data()!, fbUser.uid);
          await _localDataSource.saveUserSession(model);
          return model.toEntity();
        } else {
          print('🔑 Document does not exist or has no data. Checking local fallback...');
          final local = await _localDataSource.getUserSession();
          if (local != null && local.uid == fbUser.uid) {
            print('🔑 Local fallback session found: ${local.email}');
            return local.toEntity();
          }
          print('🔑 No local session matched. Returning null.');
          return null;
        }
      } catch (e) {
        print('🔑 Firestore query failed or timed out: $e. Using local session fallback...');
        final local = await _localDataSource.getUserSession();
        if (local != null && local.uid == fbUser.uid) {
          print('🔑 Local session fallback successful: ${local.email}');
          return local.toEntity();
        }
        print('🔑 Local session fallback failed. Returning null.');
        return null;
      }
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser == null) return null;
    final local = await _localDataSource.getUserSession();
    if (local != null && local.uid == fbUser.uid) {
      return local.toEntity();
    }
    // Fetch fresh
    try {
      final doc = await _firestore.collection('users').doc(fbUser.uid).get();
      if (doc.exists && doc.data() != null) {
        final model = UserModel.fromMap(doc.data()!, fbUser.uid);
        await _localDataSource.saveUserSession(model);
        return model.toEntity();
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<UserEntity> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('User data not found in Firestore.');
    }

    final model = UserModel.fromMap(doc.data()!, uid);
    await _localDataSource.saveUserSession(model);
    return model.toEntity();
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
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final userModel = UserModel(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      nationalId: nationalId,
      role: role.value,
      hospitalId: hospitalId,
      departmentId: departmentId,
      createdAt: DateTime.now(),
    );

    // Save to Firestore
    await _firestore.collection('users').doc(uid).set(userModel.toMap());
    
    // Save locally
    await _localDataSource.saveUserSession(userModel);

    return userModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _localDataSource.clearUserSession();
  }
}

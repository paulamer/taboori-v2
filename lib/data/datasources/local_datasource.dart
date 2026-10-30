import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/hospital_model.dart';
import '../models/queue_ticket_model.dart';

class LocalDataSource {
  static const String _userBoxName = 'user_box';
  static const String _hospitalsBoxName = 'hospitals_box';
  static const String _ticketsBoxName = 'tickets_box';
  static const String _settingsBoxName = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_userBoxName);
    await Hive.openBox(_hospitalsBoxName);
    await Hive.openBox(_ticketsBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  // --- Auth Session ---
  Future<void> saveUserSession(UserModel user) async {
    final box = Hive.box(_userBoxName);
    await box.put('current_user', jsonEncode(user.toMap()));
  }

  Future<UserModel?> getUserSession() async {
    final box = Hive.box(_userBoxName);
    final data = box.get('current_user');
    if (data != null) {
      final decoded = jsonDecode(data);
      // Wait, user session in Hive doesn't have ID, wait: we can pass uid as ID.
      // Let's store UID inside the map or retrieve it.
      // In UserModel.toMap we save name, email, phone, etc. Let's make sure uid is saved.
      // Actually, UserModel has uid. Let's write a toMap() that includes it or we map it properly.
      // Let's check: UserModel.fromMap takes dynamic map, string id.
      // So we can save the UID in the map for Hive and read it.
      final map = Map<String, dynamic>.from(decoded);
      final uid = map['uid'] ?? 'cached_user_id';
      return UserModel.fromMap(map, uid);
    }
    return null;
  }

  Future<void> clearUserSession() async {
    final box = Hive.box(_userBoxName);
    await box.delete('current_user');
  }

  // --- Hospitals Cache ---
  Future<void> cacheHospitals(List<HospitalModel> hospitals) async {
    final box = Hive.box(_hospitalsBoxName);
    final maps = hospitals.map((h) {
      final map = h.toMap();
      map['id'] = h.id; // ensure ID is preserved
      return jsonEncode(map);
    }).toList();
    await box.put('hospitals_list', maps);
  }

  Future<List<HospitalModel>> getCachedHospitals() async {
    final box = Hive.box(_hospitalsBoxName);
    final List<dynamic>? list = box.get('hospitals_list');
    if (list != null) {
      return list.map((item) {
        final decoded = jsonDecode(item as String);
        final map = Map<String, dynamic>.from(decoded);
        final id = map['id'] ?? '';
        return HospitalModel.fromMap(map, id);
      }).toList();
    }
    return [];
  }

  // --- Tickets Cache ---
  Future<void> cacheTickets(List<QueueTicketModel> tickets) async {
    final box = Hive.box(_ticketsBoxName);
    final maps = tickets.map((t) {
      final map = t.toMap();
      map['id'] = t.id;
      return jsonEncode(map);
    }).toList();
    await box.put('tickets_list', maps);
  }

  Future<List<QueueTicketModel>> getCachedTickets() async {
    final box = Hive.box(_ticketsBoxName);
    final List<dynamic>? list = box.get('tickets_list');
    if (list != null) {
      return list.map((item) {
        final decoded = jsonDecode(item as String);
        final map = Map<String, dynamic>.from(decoded);
        final id = map['id'] ?? '';
        return QueueTicketModel.fromMap(map, id);
      }).toList();
    }
    return [];
  }

  // --- Settings (Locale & Theme) ---
  Future<void> saveLocale(String locale) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('locale', locale);
  }

  String getLocale() {
    final box = Hive.box(_settingsBoxName);
    return box.get('locale', defaultValue: 'ar') as String;
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('isDarkMode', isDarkMode);
  }

  bool isDarkMode() {
    final box = Hive.box(_settingsBoxName);
    return box.get('isDarkMode', defaultValue: false) as bool;
  }

  // --- Onboarding ---
  Future<void> saveOnboardingComplete() async {
    final box = Hive.box(_settingsBoxName);
    await box.put('onboarding_complete', true);
  }

  bool isOnboardingComplete() {
    final box = Hive.box(_settingsBoxName);
    return box.get('onboarding_complete', defaultValue: false) as bool;
  }

  // --- Simple Mode (Elderly Accessibility) ---
  Future<void> saveSimpleMode(bool enabled) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('simple_mode', enabled);
  }

  bool isSimpleMode() {
    final box = Hive.box(_settingsBoxName);
    return box.get('simple_mode', defaultValue: false) as bool;
  }
}

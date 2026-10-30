import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SmartNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await _plugin.initialize(settings: initSettings);
      _isInitialized = true;
      debugPrint('🔔 SmartNotificationService initialized successfully.');
    } catch (e) {
      debugPrint('⚠️ SmartNotificationService initialization warning: $e');
    }
  }

  /// Sends the revolutionary "Leave Home Now" smart notification to the patient's phone
  static Future<void> showLeaveNowNotification({
    required int ticketNumber,      // Unique ticket sequence number (e.g. 14)
    required String clinicName,     // Target clinic name (e.g. Internal Medicine)
    required int peopleAhead,       // Count of patients waiting ahead
    required int estimatedMinutes,  // Calculated transit countdown in minutes
    required String locale,         // Language setting ('ar' or 'en')
  }) async {
    final isAr = locale == 'ar';    // Check if Arabic is selected
    // Construct localized high-urgency title
    final title = isAr
        ? '🚨 انزل دلوقتي! موعد تحركك حان (تذكرة #$ticketNumber)'
        : '🚨 Leave Home Now! Your Turn is Approaching (#$ticketNumber)';

    // Construct localized explanatory body with live metrics
    final body = isAr
        ? 'عيادة $clinicName: متبقي أمامك $peopleAhead مرضى فقط (~$estimatedMinutes دقيقة). تحرك الآن لتصل في موعدك وتتجنب الزحام!'
        : '$clinicName Clinic: Only $peopleAhead patients ahead (~$estimatedMinutes mins). Head out now to arrive right on time!';

    try {
      await initialize(); // Ensure native channel is registered before firing

      // Configure Android notification channel with maximum priority, chime sound & haptic vibration
      const androidDetails = AndroidNotificationDetails(
        'taboori_smart_transit',                            // Unique channel ID
        'Smart Transit & Queue Alerts',                     // User-visible channel name
        channelDescription: 'Alerts patient when to leave home based on queue progression',
        importance: Importance.max,                         // Pop-up heads-up banner on screen
        priority: Priority.high,                            // High priority delivery
        playSound: true,                                    // Play audible notification ringtone
        enableVibration: true,                              // Trigger phone vibration motor
      );

      const details = NotificationDetails(android: androidDetails); // Encapsulate Android specs

      // Fire local notification to Android notification tray
      await _plugin.show(
        id: ticketNumber.hashCode % 100000,                  // Unique notification ID per ticket
        title: title,                                       // Notification banner title
        body: body,                                         // Notification detailed description
        notificationDetails: details,                       // Channel properties
      );
    } catch (e) {
      debugPrint('⚠️ Error displaying local notification: $e'); // Log exception safely without crash
    }
  }

  /// Sends a critical "Now Serving" notification when patient's ticket is called
  static Future<void> showYourTurnNotification({
    required int ticketNumber,
    required String clinicName,
    required String locale,
  }) async {
    final isAr = locale == 'ar';
    final title = isAr
        ? '🏥 دورك الآن! تفضل بالدخول (تذكرة #$ticketNumber)'
        : '🏥 Your Turn Now! Enter Clinic (#$ticketNumber)';

    final body = isAr
        ? 'تم استدعاء تذكرتك في $clinicName. تفضل بالتوجه لغرفة الكشف فوراً.'
        : 'Your ticket has been called at $clinicName. Please enter the examination room.';

    try {
      await initialize();

      const androidDetails = AndroidNotificationDetails(
        'taboori_call_alerts',
        'Turn Call Alerts',
        channelDescription: 'Alerts patient when their ticket is called by the doctor',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const details = NotificationDetails(android: androidDetails);

      await _plugin.show(
        id: (ticketNumber.hashCode + 1) % 100000,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint('⚠️ Error displaying turn notification: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taboori/presentation/shared/providers.dart';
import 'package:taboori/features/settings/presentation/simple_mode.dart';
import 'package:taboori/core/theme/app_theme.dart';
import 'package:taboori/core/utils/national_id_parser.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    final isAr = locale == 'ar';
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الإعدادات' : 'Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Appearance Section ──
          _SectionHeader(title: isAr ? 'المظهر والواجهة' : 'Appearance & UI'),

          // Simple Mode
          const SimpleModeToggle(),
          const Divider(height: 1),

          // Dark Mode
          SwitchListTile(
            title: Text(
              isAr ? 'الوضع الداكن' : 'Dark Mode',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              isAr ? 'تقليل إجهاد العين في الإضاءة المنخفضة' : 'Reduce eye strain in low light',
            ),
            secondary: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? Colors.amber : Colors.grey,
              size: 28,
            ),
            value: isDark,
            onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          const Divider(height: 1),

          // Language
          ListTile(
            leading: const Icon(Icons.language_rounded, size: 28),
            title: Text(
              isAr ? 'اللغة' : 'Language',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(isAr ? 'العربية (Arabic)' : 'English (الإنجليزية)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context, ref, isAr),
          ),

          const SizedBox(height: 16),

          // ── Emergency & Safety Section ──
          _SectionHeader(title: isAr ? 'الطوارئ والسلامة' : 'Emergency & Safety'),

          ListTile(
            leading: const Icon(Icons.emergency_rounded, size: 28, color: Colors.red),
            title: Text(
              isAr ? 'طوارئ الإسعاف المصرية (123)' : 'Egyptian Ambulance Service (123)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
            ),
            subtitle: Text(
              isAr ? 'الخط الساخن المباشر للإسعاف وحالات الطوارئ الحرجة' : 'Direct emergency hotline for urgent medical triage',
            ),
            trailing: const Icon(Icons.phone_in_talk, color: Colors.red),
            onTap: () => _showEmergencyDialog(context, isAr),
          ),

          const SizedBox(height: 16),

          // ── Account Section ──
          _SectionHeader(title: isAr ? 'الحساب والأمان' : 'Account & Security'),

          ListTile(
            leading: const Icon(Icons.person_outline_rounded, size: 28),
            title: Text(
              isAr ? 'بيانات الحساب الشخصي' : 'Account Profile',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(isAr ? 'عرض الرقم القومي وبيانات التسجيل' : 'View National ID and account details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showProfileDialog(context, ref, isAr),
          ),
          const Divider(height: 1),

          // Notifications
          ListTile(
            leading: const Icon(Icons.notifications_outlined, size: 28),
            title: Text(
              isAr ? 'إشعارات نداء الدور' : 'Queue Call Notifications',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(isAr ? 'تنبيهات صوتية واهتزاز عند حلول دورك' : 'Sound & vibration alert when called'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showNotificationsDialog(context, isAr),
          ),

          const SizedBox(height: 16),

          // ── About Section ──
          _SectionHeader(title: isAr ? 'عن التطبيق والمشروع' : 'About Project'),

          ListTile(
            leading: Icon(Icons.local_hospital_rounded,
                size: 28, color: AppTheme.primaryTealLight),
            title: const Text(
              'طابوري — Taboori',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              isAr
                  ? 'نظام إدارة طوابير العيادات وأسرة المستشفيات\nالإصدار 1.0.0 (2026)'
                  : 'Outpatient Queue & Hospital Bed Allocation\nVersion 1.0.0 (2026)',
            ),
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.school_rounded, size: 28),
            title: Text(
              isAr ? 'مشروع تخرج' : 'Graduation Project',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              isAr
                  ? 'كلية الهندسة بشبرا — جامعة بنها\nقسم هندسة الاتصالات والحاسبات\n2025-2026'
                  : 'Faculty of Engineering at Shoubra — Benha University\nCommunication & Computer Engineering\n2025-2026',
            ),
            isThreeLine: true,
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.group_rounded, size: 28),
            title: Text(
              isAr ? 'فريق العمل' : 'Team',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              isAr
                  ? 'بولا عامر • ريتاج • أحمد محمد • عمر محمد\nإشراف: د. صباح سعد'
                  : 'Paula Amer • Retaj • Ahmed Mohamed • Omar Mohamed\nSupervisor: Dr. Sabah Saad',
            ),
          ),

          const SizedBox(height: 24),

          // ── Logout ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref, isAr),
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: Text(
                isAr ? 'تسجيل الخروج' : 'Logout',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.emergency_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(isAr ? 'طوارئ الإسعاف (123)' : 'Emergency Hotline (123)'),
          ],
        ),
        content: Text(
          isAr
              ? 'هل تحتاج للاتصال الفوري بهيئة الإسعاف المصرية (123) لحالة حرجة؟'
              : 'Do you need to immediately dial the Egyptian Ambulance Service (123) for an emergency?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إغلاق' : 'Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAr ? 'جاري الاتصال بالطوارئ: 123' : 'Calling Emergency: 123'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            icon: const Icon(Icons.phone),
            label: Text(isAr ? 'اتصال 123' : 'Call 123'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context, WidgetRef ref, bool isAr) {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAr ? 'لا يوجد مستخدم مسجل حالياً' : 'No user currently signed in')),
      );
      return;
    }

    final idDetails = NationalIdParser.parse(user.nationalId);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'بيانات الحساب الشخصي' : 'Account Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileRow(label: isAr ? 'الاسم' : 'Name', value: user.name),
            _ProfileRow(label: isAr ? 'البريد' : 'Email', value: user.email),
            _ProfileRow(label: isAr ? 'الهاتف' : 'Phone', value: user.phone),
            _ProfileRow(label: isAr ? 'الرقم القومي' : 'National ID', value: user.nationalId),
            _ProfileRow(label: isAr ? 'نوع الحساب' : 'Role', value: user.role.name.toUpperCase()),
            if (idDetails != null) ...[
              const Divider(height: 16),
              _ProfileRow(label: isAr ? 'المحافظة' : 'Governorate', value: idDetails.governorateAr),
              _ProfileRow(label: isAr ? 'النوع' : 'Gender', value: idDetails.genderAr),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'تم' : 'Done'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context, bool isAr) {
    bool soundEnabled = true;
    bool vibrationEnabled = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isAr ? 'تنبيهات نداء الدور' : 'Queue Alert Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text(isAr ? 'تنبيه صوتي (Chime)' : 'Audio Chime Alert'),
                subtitle: Text(isAr ? 'رنين صوتي عند تقدم دورك' : 'Play chime sound when called'),
                value: soundEnabled,
                onChanged: (v) => setDialogState(() => soundEnabled = v),
              ),
              SwitchListTile(
                title: Text(isAr ? 'الاهتزاز (Vibration)' : 'Haptic Vibration'),
                subtitle: Text(isAr ? 'اهتزاز الهاتف عند النداء' : 'Vibrate phone when called'),
                value: vibrationEnabled,
                onChanged: (v) => setDialogState(() => vibrationEnabled = v),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isAr ? 'تم حفظ إعدادات التنبيهات' : 'Alert preferences saved')),
                );
              },
              child: Text(isAr ? 'حفظ' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'اختر اللغة' : 'Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('العربية (Arabic)'),
              trailing: isAr ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale('ar');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('English (الإنجليزية)'),
              trailing: !isAr ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale('en');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'تسجيل الخروج' : 'Logout'),
        content: Text(isAr ? 'هل أنت متأكد من تسجيل الخروج؟' : 'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authRepositoryProvider).signOut();
              context.go('/auth');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isAr ? 'خروج' : 'Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

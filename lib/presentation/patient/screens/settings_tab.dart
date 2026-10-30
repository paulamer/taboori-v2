import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers.dart';
import '../../../features/settings/presentation/simple_mode.dart';
import 'leave_now_screen.dart';

class SettingsTab extends ConsumerWidget {
  final VoidCallback? onNavigateToFamily;

  const SettingsTab({Key? key, this.onNavigateToFamily}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isAr = locale == 'ar';
    final isSimple = ref.watch(simpleModeProvider);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Title with Version Tag
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? 'الإعدادات' : 'Settings',
                      style: GoogleFonts.cairo(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F7F4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF0D7A68).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'v2.0.0 Pro',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0D7A68),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  children: [
                    // 1. Simple Senior Mode Card
                    _buildSettingsCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? 'الوضع البسيط (كبار السن)' : 'Simple Mode (Seniors)',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAr ? 'خط وأزرار أكبر وإلغاء التعقيد' : 'Larger fonts & buttons for seniors',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: isSimple,
                            activeTrackColor: const Color(0xFF0D7A68).withValues(alpha: 0.5),
                            activeThumbColor: const Color(0xFF0D7A68),
                            onChanged: (val) {
                              ref.read(simpleModeProvider.notifier).toggle();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2. Language Card (Segmented Control)
                    _buildSettingsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'اللغة' : 'Language',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 48,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                // English Button
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      ref.read(localeProvider.notifier).setLocale('en');
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: !isAr ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: !isAr
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.04),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'English',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: !isAr ? const Color(0xFF0D7A68) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Arabic Button
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      ref.read(localeProvider.notifier).setLocale('ar');
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isAr ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: isAr
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.04),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'العربية',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isAr ? const Color(0xFF0D7A68) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Family Account Card
                    _buildSettingsCard(
                      onTap: onNavigateToFamily,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F7F4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.people_alt_rounded, color: Color(0xFF0D7A68), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'حساب العائلة الموحد' : 'Unified Family Account',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isAr ? 'تابع أدوار والديك وأطفالك' : 'Track queue for parents and kids',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isAr ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. Test Notification Card
                    _buildSettingsCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LeaveNowScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFD97706), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'تجربة إشعار انزل دلوقتي' : 'Test "Leave Now" Alert',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isAr ? 'تأكد إن صوت التنبيه واهتزاز الهاتف يعمل' : 'Ensure sound & alert works',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isAr ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: const Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. Red Emergency Button
                    GestureDetector(
                      onTap: () => _callAmbulance(context, isAr),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626), // Emergency Red
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? 'اتصال بالإسعاف 123' : 'Call Ambulance 123',
                                    style: GoogleFonts.cairo(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    isAr ? 'للحالات الحرجة والطارئة فقط' : 'For critical emergencies only',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.phone_in_talk_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 6. Project & Team Information
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.school_rounded, color: Color(0xFF0D7A68), size: 22),
                              const SizedBox(width: 8),
                              Text(
                                isAr ? 'مشروع تخرج 2026' : 'Graduation Project 2026',
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0D7A68),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isAr
                                ? 'كلية الهندسة بشبرا — جامعة بنها\nقسم هندسة الاتصالات والحاسبات'
                                : 'Faculty of Engineering at Shoubra — Benha University\nCommunication & Computer Engineering',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              color: const Color(0xFF475569),
                              height: 1.4,
                            ),
                          ),
                          const Divider(height: 20, color: Color(0xFFF1F5F9)),
                          Text(
                            isAr ? 'إشراف الأستاذة الدكتورة:' : 'Academic Supervisor:',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            isAr ? 'أ.د. صباح سعد' : 'Prof. Dr. Sabah Saad',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isAr ? 'فريق العمل الطلابي:' : 'Student Development Team:',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            isAr
                                ? '• بولا عامر جرجس (Paula Amer)\n• ريتاج (Retaj)\n• أحمد محمد (Ahmed Mohamed)\n• عمر محمد (Omar Mohamed)'
                                : '• Paula Amer Gerges\n• Retaj\n• Ahmed Mohamed\n• Omar Mohamed',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              height: 1.5,
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Logout Button
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(authRepositoryProvider).signOut();
                        context.go('/auth');
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                      label: Text(
                        isAr ? 'تسجيل الخروج' : 'Logout',
                        style: GoogleFonts.cairo(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  void _callAmbulance(BuildContext context, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.emergency_rounded, color: Colors.red),
              const SizedBox(width: 8),
              Text(isAr ? 'طوارئ الإسعاف (123)' : 'Emergency Hotline (123)'),
            ],
          ),
          content: Text(
            isAr
                ? 'هل ترغب بالاتصال الفوري بهيئة الإسعاف المصرية (123)؟'
                : 'Do you want to immediately call the Egyptian Ambulance Service (123)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
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
              label: Text(isAr ? 'اتصال الآن' : 'Call Now'),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

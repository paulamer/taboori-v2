import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../presentation/shared/providers.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _slideCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    // Fade-in for the whole hero block
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    // Slide-up for logo + title
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    // Pulse for the cross icon
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.elasticOut));

    // Start animations
    Future.delayed(const Duration(milliseconds: 150), () {
      _fadeCtrl.forward();
      _slideCtrl.forward();
    });

    // Auto-navigate after 2.8s
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      final authState = ref.read(authStateProvider);
      final user = authState.value;
      if (user != null) {
        context.go('/patient');
      }
      // else stay — user taps "ابدأ الآن" manually
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isAr = locale == 'ar';

    return Scaffold(
      backgroundColor: AppTheme.primaryTealLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Bar with Language Switcher Pill
              Row(
                mainAxisAlignment:
                    isAr ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        ref.read(localeProvider.notifier).toggleLocale(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      isAr ? 'English' : 'عربي',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // Animated Center Logo & App Identity
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      children: [
                        // Animated Logo Box
                        ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: AppTheme.primaryTealLight,
                                      width: 3.5),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 46,
                                  color: AppTheme.primaryTealLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Title "طابوري"
                        Text(
                          isAr ? 'طابوري' : 'Taboori',
                          style: GoogleFonts.cairo(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Version Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'v2.0',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            isAr
                                ? 'احجز دورك في العيادة وأنت في بيتك،\nوانزل لما دورك يقرّب'
                                : 'Book your clinic turn from home,\nand head out when your turn is close',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.92),
                              height: 1.55,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Feature pills row
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            _featurePill(
                                icon: Icons.notifications_active_rounded,
                                label: isAr ? 'تنبيه ذكي' : 'Smart Alert'),
                            _featurePill(
                                icon: Icons.qr_code_2_rounded,
                                label: isAr ? 'كود QR' : 'QR Code'),
                            _featurePill(
                                icon: Icons.people_rounded,
                                label: isAr ? 'إدارة العائلة' : 'Family'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 4),

              // Bottom "ابدأ الآن" Button — fades in
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          final authState = ref.read(authStateProvider);
                          final user = authState.value;
                          if (user != null) {
                            context.go('/patient');
                          } else {
                            context.go('/auth');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryTealLight,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          isAr ? 'ابدأ الآن' : 'Get Started',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryTealLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isAr
                          ? 'بالتسجيل أنت توافق على الشروط وسياسة الخصوصية'
                          : 'By continuing, you agree to Terms & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featurePill(
      {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

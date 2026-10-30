import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/datasources/local_datasource.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.local_hospital_rounded,
      titleAr: 'مرحباً بك في طابوري',
      titleEn: 'Welcome to Taboori',
      descAr: 'تطبيق ذكي لإدارة طوابير المستشفيات الحكومية المصرية\nوإدارة الأسرة والموارد الطبية',
      descEn: 'Smart queue & bed management for Egyptian government hospitals',
      color: Color(0xFF0D9488),
    ),
    _OnboardingPage(
      icon: Icons.confirmation_number_rounded,
      titleAr: 'احجز دورك من بيتك',
      titleEn: 'Book Your Turn from Home',
      descAr: 'اختر المستشفى والقسم واحجز رقمك في الطابور\nبدون ما تروح تستنى في المستشفى',
      descEn: 'Choose your hospital & department, get your queue number remotely',
      color: Color(0xFF0891B2),
    ),
    _OnboardingPage(
      icon: Icons.qr_code_rounded,
      titleAr: 'تذكرة رقمية بكود QR',
      titleEn: 'Digital QR Ticket',
      descAr: 'تذكرتك على موبايلك — فقط اعرضها عند الوصول\nوهيتم تسجيل حضورك تلقائياً',
      descEn: 'Your ticket on your phone — just show it at arrival for instant check-in',
      color: Color(0xFF7C3AED),
    ),
    _OnboardingPage(
      icon: Icons.timer_rounded,
      titleAr: 'تابع دورك لحظة بلحظة',
      titleEn: 'Track Your Queue Live',
      descAr: 'اعرف كام واحد قبلك والوقت المتوقع\nوهنبعتلك إشعار لما دورك يقرب',
      descEn: 'See how many are ahead and your estimated wait time',
      color: Color(0xFFEA580C),
    ),
    _OnboardingPage(
      icon: Icons.hotel_rounded,
      titleAr: 'معلومات الأسرة المتاحة',
      titleEn: 'Available Bed Info',
      descAr: 'اعرف أماكن الأسرة المتاحة في العناية المركزة\nوالحضّانات والتنفس الصناعي',
      descEn: 'Find available ICU, incubator & ventilator beds across hospitals',
      color: Color(0xFF059669),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    // Save that onboarding is complete
    final ds = LocalDataSource();
    await ds.saveOnboardingComplete();
    if (!mounted) return;
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'تخطي',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _buildPage(_pages[i]),
              ),
            ),

            // Dots + Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page dots
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? _pages[_currentPage].color
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Start button
                  FilledButton.icon(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: _pages[_currentPage].color,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    icon: Icon(isLast ? Icons.check : Icons.arrow_back),
                    label: Text(
                      isLast ? 'ابدأ الآن' : 'التالي',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 60, color: page.color),
          ),
          const SizedBox(height: 40),
          Text(
            page.titleAr,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            page.titleEn,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            page.descAr,
            style: const TextStyle(fontSize: 16, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String titleAr;
  final String titleEn;
  final String descAr;
  final String descEn;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.titleAr,
    required this.titleEn,
    required this.descAr,
    required this.descEn,
    required this.color,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/national_id_parser.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/user_entity.dart';
import '../shared/providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  final _nationalIdController = TextEditingController(text: '30205121401234');
  final _phoneController = TextEditingController(text: '01098765432');
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  NationalIdDetails? _extractedDetails;
  bool _isValidId = false;

  // OTP Step
  bool _showOtpStep = false;
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  int _resendCountdown = 30;
  bool _canResend = false;

  late final AnimationController _slideCtrl;

  @override
  void initState() {
    super.initState();
    _checkId(_nationalIdController.text);
    _nationalIdController.addListener(() {
      _checkId(_nationalIdController.text);
    });

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _checkId(String rawText) {
    final clean = rawText.replaceAll(' ', '').trim();
    if (clean.length == 14 && NationalIdParser.validate(clean)) {
      final details = NationalIdParser.parse(clean);
      setState(() {
        _isValidId = true;
        _extractedDetails = details;
      });
    } else {
      setState(() {
        _isValidId = false;
        _extractedDetails = null;
      });
    }
  }

  @override
  void dispose() {
    _nationalIdController.dispose();
    _phoneController.dispose();
    _slideCtrl.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startOtpStep() {
    setState(() {
      _showOtpStep = true;
      _resendCountdown = 30;
      _canResend = false;
    });
    _slideCtrl.forward(from: 0);
    _startCountdown();
    // Auto-focus first OTP box
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) _otpFocusNodes[0].requestFocus();
    });
  }

  void _startCountdown() async {
    for (int i = 30; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _resendCountdown = i;
        if (i == 0) _canResend = true;
      });
    }
  }

  Future<void> _submitLogin(
      {UserRole role = UserRole.patient, String? customName}) async {
    setState(() => _isLoading = true);
    final rawId = _nationalIdController.text.replaceAll(' ', '').trim();
    final phone = _phoneController.text.trim();

    final authRepo = ref.read(authRepositoryProvider);
    try {
      String name = customName ??
          (_extractedDetails?.genderAr == 'أنثى' ? 'مريم أحمد' : 'بولا عامر');
      if (role == UserRole.staff) {
        name = 'د. سارة أحمد';
      } else if (role == UserRole.admin) {
        name = 'مفتش وزارة الصحة';
      }

      await authRepo.register(
        name: name,
        email: '${role.name}_${rawId.substring(rawId.length - 4)}@taboori.com',
        password: 'password123',
        phone: phone.isNotEmpty ? phone : '01012345678',
        nationalId: rawId.isNotEmpty ? rawId : '30205121401234',
        role: role,
        hospitalId: role == UserRole.staff ? 'hosp_1' : null,
        departmentId: role == UserRole.staff ? 'dept_cardio' : null,
      );

      if (mounted) {
        switch (role) {
          case UserRole.staff:
            context.go('/staff');
            break;
          case UserRole.admin:
            context.go('/admin');
            break;
          case UserRole.patient:
            context.go('/patient');
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isAr = locale == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: IconButton(
                        icon: Icon(
                          _showOtpStep
                              ? Icons.arrow_back_ios_new_rounded
                              : Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                        onPressed: () {
                          if (_showOtpStep) {
                            setState(() => _showOtpStep = false);
                            _slideCtrl.reverse();
                          } else {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
                          }
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(localeProvider.notifier).toggleLocale(),
                      child: Text(
                        isAr ? 'English' : 'عربي',
                        style: TextStyle(
                          color: AppTheme.primaryTealLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Step Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    _stepDot(1, active: true, done: _showOtpStep),
                    Expanded(
                        child: Container(
                            height: 2,
                            color: _showOtpStep
                                ? AppTheme.primaryTealLight
                                : const Color(0xFFE2E8F0))),
                    _stepDot(2, active: _showOtpStep, done: false),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Form Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: _showOtpStep
                      ? _buildOtpStep(isAr)
                      : _buildIdStep(isAr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepDot(int step, {required bool active, required bool done}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active || done
            ? AppTheme.primaryTealLight
            : const Color(0xFFE2E8F0),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            : Text(
                step.toString(),
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
      ),
    );
  }

  Widget _buildIdStep(bool isAr) {
    return SingleChildScrollView(
      key: const ValueKey('id_step'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            Text(
              isAr ? 'أدخل رقمك القومي' : 'Enter Your National ID',
              style: GoogleFonts.cairo(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAr
                  ? '14 رقماً كما هو مكتوب في البطاقة. نستخدمه للتحقق من هويتك فقط.'
                  : '14 digits as written on your ID. Used for verification only.',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            Text(
              isAr ? 'الرقم القومي' : 'National ID',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),

            // National ID Input
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isValidId
                      ? AppTheme.primaryTealLight
                      : const Color(0xFFCBD5E1),
                  width: _isValidId ? 2 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isValidId
                        ? AppTheme.primaryTealLight.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextFormField(
                controller: _nationalIdController,
                keyboardType: TextInputType.number,
                maxLength: 14,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.5,
                  color: const Color(0xFF0F172A),
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            if (_isValidId) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF0D7A68), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    isAr
                        ? 'رقم صحيح — تم استخراج بياناتك تلقائياً'
                        : 'Valid ID — Your details extracted automatically',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0D7A68),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildExtractedColumn(
                        label: isAr ? 'المحافظة' : 'Governorate',
                        value: _extractedDetails?.governorateAr ?? 'القليوبية',
                      ),
                    ),
                    Container(
                        width: 1,
                        height: 40,
                        color: const Color(0xFFE2E8F0)),
                    Expanded(
                      child: _buildExtractedColumn(
                        label: isAr ? 'تاريخ الميلاد' : 'Birth Date',
                        value: _extractedDetails != null
                            ? '${_extractedDetails!.birthDate.year}/${_extractedDetails!.birthDate.month.toString().padLeft(2, '0')}/${_extractedDetails!.birthDate.day.toString().padLeft(2, '0')}'
                            : '2002/05/12',
                      ),
                    ),
                    Container(
                        width: 1,
                        height: 40,
                        color: const Color(0xFFE2E8F0)),
                    Expanded(
                      child: _buildExtractedColumn(
                        label: isAr ? 'النوع' : 'Gender',
                        value: _extractedDetails?.genderAr ?? 'ذكر',
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            Text(
              isAr ? 'رقم الموبايل' : 'Mobile Number',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFCBD5E1), width: 1.2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
                decoration: const InputDecoration(
                  hintText: '01xxxxxxxxx',
                  hintStyle:
                      TextStyle(color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Quick Test Chips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr
                        ? '⚡ اختبار سريع (لجنة التحكيم):'
                        : '⚡ Quick Demo (Examination):',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ActionChip(
                        avatar:
                            const Text('👤', style: TextStyle(fontSize: 13)),
                        label: Text(
                          isAr ? 'بولا عامر (مريض)' : 'Paula (Patient)',
                          style: GoogleFonts.cairo(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () => _submitLogin(
                            role: UserRole.patient,
                            customName: 'بولا عامر'),
                      ),
                      ActionChip(
                        avatar:
                            const Text('🩺', style: TextStyle(fontSize: 13)),
                        label: Text(
                          isAr ? 'د. سارة (طبيبة)' : 'Dr. Sara (Doctor)',
                          style: GoogleFonts.cairo(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () =>
                            _submitLogin(role: UserRole.staff),
                      ),
                      ActionChip(
                        avatar:
                            const Text('🏛️', style: TextStyle(fontSize: 13)),
                        label: Text(
                          isAr ? 'مفتش الوزارة' : 'Ministry Admin',
                          style: GoogleFonts.cairo(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () =>
                            _submitLogin(role: UserRole.admin),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Send OTP Button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startOtpStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTealLight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        isAr
                            ? 'إرسال كود التحقق'
                            : 'Send Verification Code',
                        style: GoogleFonts.cairo(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpStep(bool isAr) {
    return SingleChildScrollView(
      key: const ValueKey('otp_step'),
      padding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            isAr ? 'أدخل كود التحقق' : 'Enter Verification Code',
            style: GoogleFonts.cairo(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAr
                ? 'تم إرسال كود مكوّن من 6 أرقام إلى رقم ${_phoneController.text.trim()}'
                : 'A 6-digit code was sent to ${_phoneController.text.trim()}',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 36),

          // 6-box OTP input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (i) {
              return SizedBox(
                width: 46,
                height: 56,
                child: TextField(
                  controller: _otpControllers[i],
                  focusNode: _otpFocusNodes[i],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppTheme.primaryTealLight, width: 2),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && i < 5) {
                      _otpFocusNodes[i + 1].requestFocus();
                    } else if (val.isEmpty && i > 0) {
                      _otpFocusNodes[i - 1].requestFocus();
                    }
                    // Auto-submit when all 6 filled
                    final otp = _otpControllers
                        .map((c) => c.text)
                        .join();
                    if (otp.length == 6) {
                      _submitLogin(role: UserRole.patient);
                    }
                  },
                ),
              );
            }),
          ),

          const SizedBox(height: 32),

          // Resend countdown
          Center(
            child: _canResend
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _canResend = false;
                      });
                      _startCountdown();
                    },
                    child: Text(
                      isAr ? 'إعادة إرسال الكود' : 'Resend Code',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTealLight,
                      ),
                    ),
                  )
                : Text(
                    isAr
                        ? 'إعادة الإرسال بعد $_resendCountdown ثانية'
                        : 'Resend in $_resendCountdown s',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
          ),

          const SizedBox(height: 24),

          // Demo hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isAr
                  ? '💡 للتجربة: أدخل أي 6 أرقام للدخول الفوري'
                  : '💡 For demo: type any 6 digits to enter instantly',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _submitLogin(role: UserRole.patient),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTealLight,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      isAr ? 'تأكيد الدخول' : 'Confirm & Login',
                      style: GoogleFonts.cairo(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildExtractedColumn(
      {required String label, required String value}) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 12, color: const Color(0xFF64748B))),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'leave_now_screen.dart';

class TicketTab extends StatefulWidget {
  final String ticketNumber;
  final String hospitalName;
  final String clinicName;
  final int patientsAhead;
  final int estimatedMinutes;
  final VoidCallback? onTriggerAlert;

  const TicketTab({
    Key? key,
    this.ticketNumber = 'A-14',
    this.hospitalName = 'مستشفى بنها الجامعي',
    this.clinicName = 'عيادة الباطنة',
    this.patientsAhead = 4,
    this.estimatedMinutes = 30,
    this.onTriggerAlert,
  }) : super(key: key);

  @override
  State<TicketTab> createState() => _TicketTabState();
}

class _TicketTabState extends State<TicketTab> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late int _remainingMinutes;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _remainingMinutes = widget.estimatedMinutes;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Live countdown simulation (decrementing every 60s)
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted && _remainingMinutes > 1) {
        setState(() {
          _remainingMinutes--;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _shareTicket(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'مشاركة بيانات التذكرة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'رقم ${widget.ticketNumber} • ${widget.clinicName} • ${widget.hospitalName}',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.copy_rounded, color: Color(0xFF0D7A68)),
                ),
                title: Text('نسخ كود التذكرة والبيانات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم نسخ بيانات التذكرة ${widget.ticketNumber} بنجاح!'),
                      backgroundColor: const Color(0xFF0D7A68),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.share_rounded, color: Color(0xFF0284C7)),
                ),
                title: Text('إرسال عبر واتساب أو الرسائل', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('جاري فتح قائمة المشاركة...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Queue progress calculation (e.g. assume total 15, current is 11 done, 4 ahead)
    final double queueProgress = (10 / (10 + widget.patientsAhead)).clamp(0.1, 1.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D7A68), // Full Dark Teal Screen
        body: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar: "تذكرتي" and "تحديث مباشر"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تذكرتي',
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    // Live pulsing update badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B5E50),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) => Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF34D399)
                                    .withValues(alpha: 0.5 + 0.5 * _pulseController.value),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تحديث مباشر',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content List
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                  child: Column(
                    children: [
                      // 2. Main Big White Ticket Card with Queue Progress
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'رقم دورك',
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      widget.ticketNumber,
                                      style: GoogleFonts.cairo(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF0D7A68),
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                // Queue Progress Mini Gauge
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F7F4),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'حالة الطابور',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0D7A68),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              value: queueProgress,
                                              backgroundColor: Colors.teal.shade100,
                                              color: const Color(0xFF0D7A68),
                                              strokeWidth: 4.5,
                                            ),
                                            Text(
                                              '${(queueProgress * 100).toInt()}%',
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF0D7A68),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${widget.clinicName} • [${widget.hospitalName}]',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // QR Code
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: QrImageView(
                                  data: 'TABOORI:${widget.ticketNumber}:${widget.hospitalName}',
                                  version: QrVersions.auto,
                                  size: 145.0,
                                  gapless: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            Text(
                              'اعرض الرمز على موظف العيادة عند الوصول',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Share Ticket Action Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _shareTicket(context),
                                icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF0D7A68)),
                                label: Text(
                                  'مشاركة تفاصيل التذكرة',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: const Color(0xFF0D7A68),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF0D7A68), width: 1.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 3. Middle Two Side-by-Side Cards
                      Row(
                        children: [
                          // Left: Estimated Time
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'الوقت المتوقع',
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_remainingMinutes دقيقة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Right: Ahead in line
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.people_alt_rounded, size: 14, color: Color(0xFF64748B)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'قبلك في الدور',
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.patientsAhead} مرضى',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 4. Bottom Location Card
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F7F4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.explore_outlined,
                                color: Color(0xFF0D7A68),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'مبنى العيادات (ب) • الدور الثاني • عيادة 204',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'أقرب مصعد: بجوار البوابة الرئيسية',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 5. Test/Simulate "انزل دلوقتي" Alert Button
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LeaveNowScreen(
                                  ticketNumber: widget.ticketNumber,
                                  patientsAhead: widget.patientsAhead,
                                  commuteMinutes: _remainingMinutes,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
                          label: Text(
                            '🔔 تجربة تنبيه: "انزل دلوقتي، دورك قرّب"',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white70, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

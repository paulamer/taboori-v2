import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaveNowScreen extends StatefulWidget {
  final String ticketNumber;
  final int patientsAhead;
  final int commuteMinutes;
  final VoidCallback? onImLeaving;
  final VoidCallback? onViewRoute;

  const LeaveNowScreen({
    Key? key,
    this.ticketNumber = 'A-14',
    this.patientsAhead = 4,
    this.commuteMinutes = 30,
    this.onImLeaving,
    this.onViewRoute,
  }) : super(key: key);

  @override
  State<LeaveNowScreen> createState() => _LeaveNowScreenState();
}

class _LeaveNowScreenState extends State<LeaveNowScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B201D), // Dark Forest Theme
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              children: [
                // 1. Top Push Notification Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Timestamp
                      Text(
                        'الآن',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Notification Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'طابوري',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'انزل دلوقتي، دورك قرّب',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'فاضل قدامك ${widget.patientsAhead} مرضى، والمشوار ${widget.commuteMinutes} دقيقة',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // App Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D7A68),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_box_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // 2. Center Ring & Pulsing Bell Icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF133E36).withValues(alpha: 0.5),
                        ),
                        child: Center(
                          child: Container(
                            width: 105,
                            height: 105,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0D7A68),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications_active_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // 3. Big Headline
                Text(
                  'انزل دلوقتي',
                  style: GoogleFonts.cairo(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'ميعاد تحركك جه. لو نزلت الآن هتوصل قبل دورك بدقائق',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // 5. Side-by-side Stats Pill Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Patients ahead
                    Container(
                      width: 130,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF152F2A),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'قدامك',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.patientsAhead} مرضى',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Your ticket number
                    Container(
                      width: 130,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF152F2A),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'رقمك',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.ticketNumber,
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 4),

                // 6. Mint Button: أنا نازل
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.onImLeaving != null) {
                        widget.onImLeaving!();
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم تأكيد تحركك! جاري إشعار موظف الاستقبال باقترابك.',
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: const Color(0xFF0D7A68),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5EEAD4), // Mint
                      foregroundColor: const Color(0xFF0B201D),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'أنا نازل',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0B201D),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 7. Text Button: عرض الطريق على الخريطة
                TextButton(
                  onPressed: () {
                    if (widget.onViewRoute != null) {
                      widget.onViewRoute!();
                    } else {
                      _showRouteDialog(context);
                    }
                  },
                  child: Text(
                    'عرض الطريق على الخريطة',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRouteDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'خط السير إلى المستشفى',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.my_location, color: Colors.blue),
                title: Text('موقعك الحالي', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                subtitle: Text('شارع الجامعة، بنها', style: GoogleFonts.cairo(fontSize: 12)),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 28),
                child: Icon(Icons.arrow_downward, size: 18, color: Colors.grey),
              ),
              ListTile(
                leading: const Icon(Icons.local_hospital, color: Color(0xFF0D7A68)),
                title: Text('مستشفى بنها الجامعي', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                subtitle: Text('المسافة: 1.2 كم • الوقت المتوقع: 6 دقائق بالسيارة', style: GoogleFonts.cairo(fontSize: 12)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.navigation),
                  label: Text('بدء الملاحة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0D7A68),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

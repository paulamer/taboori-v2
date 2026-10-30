import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hospital_details_screen.dart';

class HomeTab extends StatefulWidget {
  final String patientName;
  final Function(int commuteMinutes)? onBookingCompleted;

  const HomeTab({
    Key? key,
    this.patientName = 'بولا عامر',
    this.onBookingCompleted,
  }) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _activeFilter = 'all'; // 'all' | 'near' | 'available'
  late final AnimationController _liveCtrl;

  final List<Map<String, dynamic>> _hospitals = [
    {
      'name': 'مستشفى بنها الجامعي',
      'address': 'شارع فريد ندا، بنها',
      'distance': '1.2 كم',
      'distanceNum': 1.2,
      'depts': '12 تخصص',
      'status': 'متاح',
      'isAvailable': true,
      'queueLabel': 'هادي الآن 🟢',
      'queueColor': Color(0xFF0D7A68),
      'queueBg': Color(0xFFE6F7F4),
      'waitMinutes': 18,
    },
    {
      'name': 'مستشفى شبرا العام',
      'address': 'شارع شيكولاني، شبرا، القاهرة',
      'distance': '3.5 كم',
      'distanceNum': 3.5,
      'depts': '8 تخصصات',
      'status': 'زحام',
      'isAvailable': false,
      'queueLabel': 'زحمة الآن 🔴',
      'queueColor': Color(0xFFDC2626),
      'queueBg': Color(0xFFFEE2E2),
      'waitMinutes': 55,
    },
    {
      'name': 'مستشفى القاهرة التخصصي',
      'address': 'ميدان الجيزة، القاهرة',
      'distance': '5.8 كم',
      'distanceNum': 5.8,
      'depts': '15 تخصص',
      'status': 'متاح',
      'isAvailable': true,
      'queueLabel': 'هادي الآن 🟢',
      'queueColor': Color(0xFF0D7A68),
      'queueBg': Color(0xFFE6F7F4),
      'waitMinutes': 22,
    },
  ];

  @override
  void initState() {
    super.initState();
    _liveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _liveCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredHospitals {
    final query = _searchController.text.trim().toLowerCase();
    return _hospitals.where((h) {
      final matchesSearch = query.isEmpty ||
          (h['name'] as String).toLowerCase().contains(query) ||
          (h['depts'] as String).toLowerCase().contains(query);
      final matchesFilter = _activeFilter == 'all' ||
          (_activeFilter == 'near' && (h['distanceNum'] as double) <= 3.0) ||
          (_activeFilter == 'available' && (h['isAvailable'] as bool));
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar: Greeting & 123 Button
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أهلاً بك',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.patientName,
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),

                    // Emergency 123
                    GestureDetector(
                      onTap: () => _callAmbulance(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626)
                                  .withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_in_talk_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '123',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Search Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.015),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.cairo(fontSize: 14),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن مستشفى أو تخصص',
                            hintStyle: GoogleFonts.cairo(
                              color: const Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                            suffixIcon: const Icon(Icons.search_rounded,
                                color: Color(0xFF64748B)),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 3. Filter Chips Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip(
                                label: 'الكل',
                                value: 'all',
                                icon: Icons.apps_rounded),
                            const SizedBox(width: 8),
                            _filterChip(
                                label: 'الأقرب',
                                value: 'near',
                                icon: Icons.near_me_rounded),
                            const SizedBox(width: 8),
                            _filterChip(
                                label: 'متاح الآن',
                                value: 'available',
                                icon: Icons.check_circle_outline_rounded),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 4. Map Preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                    painter: _MapCanvasPainter()),
                              ),
                              Positioned(
                                top: 18,
                                right: 24,
                                child:
                                    _buildMapDistanceBadge('1.2 كم'),
                              ),
                              Center(
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF2563EB)
                                        .withValues(alpha: 0.2),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            const Color(0xFF2563EB),
                                        border: Border.all(
                                            color: Colors.white,
                                            width: 2.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 40,
                                left: 30,
                                child:
                                    _buildMapDistanceBadge('3.5 كم'),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 14,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'موقعك الحالي',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // 5. Section Title
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'أقرب المستشفيات',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          // Live indicator
                          AnimatedBuilder(
                            animation: _liveCtrl,
                            builder: (ctx, _) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F7F4),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF0D7A68)
                                          .withValues(
                                              alpha: 0.5 +
                                                  0.5 *
                                                      _liveCtrl.value),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'مباشر',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0D7A68),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 6. Hospital Cards
                      if (_filteredHospitals.isEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'لا توجد نتائج',
                              style: GoogleFonts.cairo(
                                  color: const Color(0xFF94A3B8)),
                            ),
                          ),
                        )
                      else
                        ..._filteredHospitals.map((hosp) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HospitalDetailsScreen(
                                    hospitalName: hosp['name'],
                                    hospitalAddress: hosp['address'],
                                    distanceKm: hosp['distanceNum'],
                                    onBookingCompleted:
                                        widget.onBookingCompleted,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.015),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                              0xFFE6F7F4),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  14),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons
                                                .local_hospital_rounded,
                                            color: Color(0xFF0D7A68),
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              hosp['name'],
                                              style:
                                                  GoogleFonts.cairo(
                                                fontSize: 15,
                                                fontWeight:
                                                    FontWeight.w800,
                                                color: const Color(
                                                    0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${hosp['distance']} • ${hosp['depts']} • انتظار ${hosp['waitMinutes']} د',
                                              style:
                                                  GoogleFonts.cairo(
                                                fontSize: 12,
                                                color: const Color(
                                                    0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Queue status badge
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5),
                                        decoration: BoxDecoration(
                                          color:
                                              hosp['queueBg'] as Color,
                                          borderRadius:
                                              BorderRadius.circular(
                                                  12),
                                        ),
                                        child: Text(
                                          hosp['queueLabel'],
                                          style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color:
                                                hosp['queueColor']
                                                    as Color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 16),
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

  Widget _filterChip(
      {required String label,
      required String value,
      required IconData icon}) {
    final isActive = _activeFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0D7A68)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? const Color(0xFF0D7A68)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isActive
                    ? Colors.white
                    : const Color(0xFF64748B)),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? Colors.white
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapDistanceBadge(String text) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D7A68),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _callAmbulance(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.emergency_rounded, color: Colors.red),
              const SizedBox(width: 8),
              Text('طوارئ الإسعاف (123)',
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'هل ترغب بالاتصال الفوري بهيئة الإسعاف المصرية (123)؟',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'جاري الاتصال بهيئة الإسعاف المصرية: 123'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              icon: const Icon(Icons.phone),
              label: const Text('اتصال الآن'),
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE2EFE9);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = const Color(0xFFC8DDD5)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    // Horizontal main road
    canvas.drawLine(
      Offset(-20, size.height * 0.5),
      Offset(size.width + 20, size.height * 0.5),
      roadPaint,
    );
    // Diagonal 1
    canvas.drawLine(
      Offset(-20, size.height * 0.2),
      Offset(size.width + 20, size.height * 0.8),
      roadPaint,
    );
    // Diagonal 2
    canvas.drawLine(
      Offset(size.width * 0.8, -20),
      Offset(size.width * 0.1, size.height + 20),
      roadPaint,
    );
    // Vertical spine
    canvas.drawLine(
      Offset(size.width * 0.45, -20),
      Offset(size.width * 0.35, size.height + 20),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

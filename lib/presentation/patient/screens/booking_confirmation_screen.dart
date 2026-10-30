import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String hospitalName;
  final String clinicName;
  final String doctorName;
  final String dateString;
  final double distanceKm;
  final Function(int selectedCommuteMinutes)? onConfirm;

  const BookingConfirmationScreen({
    Key? key,
    this.hospitalName = 'مستشفى بنها الجامعي',
    this.clinicName = 'الباطنة',
    this.doctorName = 'د. محمد إبراهيم',
    this.dateString = 'اليوم، الثلاثاء 6 أكتوبر',
    this.distanceKm = 1.2,
    this.onConfirm,
  }) : super(key: key);

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  int _selectedMinutes = 30; // Default 30 minutes as in screenshot
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar with Back Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'تأكيد الحجز',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Summary Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow('المستشفى', widget.hospitalName),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _buildSummaryRow('العيادة', widget.clinicName),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _buildSummaryRow('الطبيب', widget.doctorName),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _buildSummaryRow('اليوم', widget.dateString),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 2. Commute Question Section
                      Text(
                        'المشوار للمستشفى بياخد قد إيه؟',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'هنبعتلك تنبيه قبل دورك بالوقت ده عشان تنزل في المعاد',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3. Duration Selector Options (15, 30, 45 mins)
                      Row(
                        children: [
                          Expanded(child: _buildDurationOption(15)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDurationOption(30)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDurationOption(45)),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 4. GPS Distance Estimate Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF), // Soft light blue
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'تم تقدير المسافة من موقعك الحالي: ${widget.distanceKm} كم',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E40AF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Bottom Confirmation Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() => _isLoading = true);
                            await Future.delayed(const Duration(milliseconds: 600));
                            if (mounted) {
                              setState(() => _isLoading = false);
                              if (widget.onConfirm != null) {
                                widget.onConfirm!(_selectedMinutes);
                              }
                              Navigator.pop(context, true);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D7A68),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'تأكيد وإصدار التذكرة',
                            style: GoogleFonts.cairo(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(int minutes) {
    final isSelected = _selectedMinutes == minutes;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedMinutes = minutes);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D7A68) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D7A68) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0D7A68).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$minutes دقيقة',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }
}

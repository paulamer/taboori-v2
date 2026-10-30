import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'booking_confirmation_screen.dart';

class HospitalDetailsScreen extends StatefulWidget {
  final String hospitalName;
  final String hospitalAddress;
  final double distanceKm;
  final Function(int commuteMinutes)? onBookingCompleted;

  const HospitalDetailsScreen({
    Key? key,
    this.hospitalName = 'مستشفى بنها الجامعي',
    this.hospitalAddress = 'شارع فريد ندا، بنها',
    this.distanceKm = 1.2,
    this.onBookingCompleted,
  }) : super(key: key);

  @override
  State<HospitalDetailsScreen> createState() => _HospitalDetailsScreenState();
}

class _HospitalDetailsScreenState extends State<HospitalDetailsScreen> {
  String _selectedSpecialty = 'باطنة';
  int _selectedDoctorIndex = 0;

  final List<String> _specialties = [
    'باطنة',
    'أطفال',
    'عظام',
    'أنف وأذن',
    'جلدية',
  ];

  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'د. محمد إبراهيم',
      'clinic': 'عيادة الباطنة',
      'hours': 'من 9 صباحاً إلى 2 ظهراً',
      'status': 'مفتوحة',
      'isOpen': true,
      'waitingCount': 5,
      'waitTime': '25 دقيقة',
    },
    {
      'name': 'د. سارة أحمد',
      'clinic': 'عيادة الباطنة',
      'hours': 'من 3 عصراً إلى 7 مساءً',
      'status': 'لاحقاً',
      'isOpen': false,
      'waitingCount': 0,
      'waitTime': 'تبدأ 3 عصراً',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            // 1. Header Dark Teal Banner
            Container(
              padding: const EdgeInsets.only(top: 48, bottom: 24, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF0D7A68),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.hospitalName,
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.hospitalAddress} • ${widget.distanceKm} كم منك',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Specialty Title
                    Text(
                      'اختر التخصص',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Specialty Filter Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _specialties.map((spec) {
                        final isSel = _selectedSpecialty == spec;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedSpecialty = spec);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF0D7A68) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSel ? const Color(0xFF0D7A68) : const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Text(
                              spec,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 4. Doctor/Clinic Cards
                    ...List.generate(_doctors.length, (index) {
                      final doc = _doctors[index];
                      final isSelected = _selectedDoctorIndex == index;
                      final isOpen = doc['isOpen'] as bool;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedDoctorIndex = index);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF0D7A68) : const Color(0xFFE2E8F0),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Title & Badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${doc['clinic']} — ${doc['name']}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isOpen ? const Color(0xFFE6F7F4) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      doc['status'],
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isOpen ? const Color(0xFF0D7A68) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doc['hours'],
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                              ),

                              if (isOpen) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'في الانتظار',
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                color: const Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${doc['waitingCount']} مرضى',
                                              style: GoogleFonts.cairo(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'الانتظار المتوقع',
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                color: const Color(0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              doc['waitTime'],
                                              style: GoogleFonts.cairo(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // 5. Bottom "احجز دورك" Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    final selectedDoc = _doctors[_selectedDoctorIndex];
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingConfirmationScreen(
                          hospitalName: widget.hospitalName,
                          clinicName: _selectedSpecialty,
                          doctorName: selectedDoc['name'],
                          distanceKm: widget.distanceKm,
                          onConfirm: (minutes) {
                            if (widget.onBookingCompleted != null) {
                              widget.onBookingCompleted!(minutes);
                            }
                          },
                        ),
                      ),
                    );

                    if (result == true && mounted) {
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
                  child: Text(
                    'احجز دورك',
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
    );
  }
}

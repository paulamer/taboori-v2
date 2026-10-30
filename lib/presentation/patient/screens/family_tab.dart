import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/national_id_parser.dart';

class FamilyTab extends StatefulWidget {
  final Function(String memberName, String ticketNum)? onSelectTicket;

  const FamilyTab({Key? key, this.onSelectTicket}) : super(key: key);

  @override
  State<FamilyTab> createState() => _FamilyTabState();
}

class _FamilyTabState extends State<FamilyTab> {
  final List<Map<String, dynamic>> _members = [
    {
      'name': 'بولا عامر (أنا)',
      'relation': 'صاحب الحساب',
      'nationalId': '30205121401234',
      'icon': '👤',
      'activeTicket': 'A-14',
      'clinic': 'عيادة الباطنة • مستشفى بنها الجامعي',
      'status': 'دورك يقترب (فاضل 4)',
      'isLive': true,
    },
    {
      'name': 'الحاج أحمد عامر (والدي)',
      'relation': 'كبار سن • إعفاء طوابير',
      'nationalId': '25611020109876',
      'icon': '👴',
      'activeTicket': 'C-03',
      'clinic': 'عيادة القلب والأوعية • مستشفى قصر العيني',
      'status': 'في الانتظار (فاضل 2)',
      'isLive': true,
    },
    {
      'name': 'يوسف بولا عامر (طفلي)',
      'relation': 'تأمين صحي مدرسي',
      'nationalId': '31908220104321',
      'icon': '🧒',
      'activeTicket': null,
      'clinic': 'لا توجد تذكرة نشطة اليوم',
      'status': 'غير محجوز',
      'isLive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حساب العائلة',
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'إدارة ومتابعة أدوار أفراد أسرتك بسهولة',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add_rounded, size: 16),
                      label: Text('إضافة فرد', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: _showAddMemberSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D7A68),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final m = _members[index];
                    final hasTicket = m['activeTicket'] != null;

                    return GestureDetector(
                      onTap: () {
                        if (hasTicket && widget.onSelectTicket != null) {
                          widget.onSelectTicket!(m['name'], m['activeTicket']);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: hasTicket ? const Color(0xFF0D7A68).withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
                            width: hasTicket ? 1.5 : 1,
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
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      m['icon'],
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m['name'],
                                        style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        '${m['relation']} • ${m['nationalId']}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasTicket)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6F7F4),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      m['activeTicket'],
                                      style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF0D7A68),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: hasTicket ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: hasTicket ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    hasTicket ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                                    size: 18,
                                    color: hasTicket ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${m['clinic']} — ${m['status']}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: hasTicket ? const Color(0xFF15803D) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  if (hasTicket)
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 13,
                                      color: Color(0xFF16A34A),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMemberSheet() {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();
    String selectedRelation = 'والد / والدة';
    String? parsedGender;
    String? parsedGov;
    bool isValid = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
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
                  const SizedBox(height: 16),
                  Text(
                    'إضافة فرد جديد للأسرة',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اربط بطاقة الرقم القومي لحجز الأدوار نيابة عنه',
                    style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'الاسم رباعي',
                      labelStyle: GoogleFonts.cairo(fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: idCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 14,
                    onChanged: (val) {
                      final clean = val.replaceAll(' ', '').trim();
                      if (clean.length == 14 && NationalIdParser.validate(clean)) {
                        final parsed = NationalIdParser.parse(clean);
                        setSheetState(() {
                          isValid = parsed != null;
                          parsedGender = parsed?.genderAr;
                          parsedGov = parsed?.governorateAr;
                        });
                      } else {
                        setSheetState(() {
                          isValid = false;
                          parsedGender = null;
                          parsedGov = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'الرقم القومي (14 رقم)',
                      counterText: '',
                      labelStyle: GoogleFonts.cairo(fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                      suffixIcon: isValid ? const Icon(Icons.check_circle, color: Color(0xFF0D7A68)) : null,
                    ),
                  ),
                  if (isValid) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F7F4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'تم التحقق: $parsedGov • $parsedGender',
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0D7A68)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text('صلة القرابة:', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['والد / والدة', 'ابن / ابنة', 'زوج / زوجة', 'كبار سن (إعفاء)'].map((rel) {
                      final isSel = selectedRelation == rel;
                      return ChoiceChip(
                        label: Text(rel, style: GoogleFonts.cairo(fontSize: 12)),
                        selected: isSel,
                        selectedColor: const Color(0xFFE6F7F4),
                        onSelected: (val) {
                          if (val) setSheetState(() => selectedRelation = rel);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isNotEmpty) {
                        setState(() {
                          _members.add({
                            'name': nameCtrl.text.trim(),
                            'relation': selectedRelation,
                            'nationalId': idCtrl.text.trim().isNotEmpty ? idCtrl.text.trim() : '30000000000000',
                            'icon': selectedRelation.contains('طفل') || selectedRelation.contains('ابن') ? '🧒' : (selectedRelation.contains('كبار') ? '👴' : '👥'),
                            'activeTicket': null,
                            'clinic': 'لا توجد تذكرة نشطة',
                            'status': 'غير محجوز',
                            'isLive': false,
                          });
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تمت إضافة ${nameCtrl.text.trim()} إلى حساب العائلة!'),
                            backgroundColor: const Color(0xFF0D7A68),
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0D7A68),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('حفظ في العائلة', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

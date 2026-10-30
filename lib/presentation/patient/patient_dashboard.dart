import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/user_entity.dart';
import '../shared/providers.dart';
import 'screens/home_tab.dart';
import 'screens/ticket_tab.dart';
import 'screens/family_tab.dart';
import 'screens/settings_tab.dart';

class PatientDashboard extends ConsumerStatefulWidget {
  final UserEntity user;
  const PatientDashboard({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends ConsumerState<PatientDashboard> {
  int _currentIndex = 0;
  String _activeTicketNumber = 'A-14';
  int _patientsAhead = 4;
  int _commuteMinutes = 30;
  String _hospitalName = 'مستشفى بنها الجامعي';
  String _clinicName = 'عيادة الباطنة';

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isAr = locale == 'ar';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Widget> pages = [
      HomeTab(
        patientName: widget.user.name.isNotEmpty ? widget.user.name : 'بولا عامر',
        onBookingCompleted: (commuteMinutes) {
          setState(() {
            _commuteMinutes = commuteMinutes;
            _patientsAhead = 4;
            _activeTicketNumber = 'A-14';
            _currentIndex = 1; // Switch to Ticket tab
          });
        },
      ),
      TicketTab(
        ticketNumber: _activeTicketNumber,
        hospitalName: _hospitalName,
        clinicName: _clinicName,
        patientsAhead: _patientsAhead,
        estimatedMinutes: _commuteMinutes,
      ),
      FamilyTab(
        onSelectTicket: (memberName, ticketNum) {
          setState(() {
            _activeTicketNumber = ticketNum;
            _currentIndex = 1;
          });
        },
      ),
      SettingsTab(
        onNavigateToFamily: () {
          setState(() {
            _currentIndex = 2; // Switch to Family tab
          });
        },
      ),
    ];

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                (states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF0D7A68)
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  );
                },
              ),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                (states) {
                  final isSelected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    size: 24,
                    color: isSelected
                        ? const Color(0xFF0D7A68)
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  );
                },
              ),
            ),
            child: NavigationBar(
              height: 68,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded, color: Color(0xFF0D7A68)),
                  label: isAr ? 'الرئيسية' : 'Home',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.confirmation_number_outlined),
                  selectedIcon: const Icon(Icons.confirmation_number_rounded, color: Color(0xFF0D7A68)),
                  label: isAr ? 'تذكرتي' : 'My Ticket',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people_outline_rounded),
                  selectedIcon: const Icon(Icons.people_rounded, color: Color(0xFF0D7A68)),
                  label: isAr ? 'العائلة' : 'Family',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.wb_sunny_outlined),
                  selectedIcon: const Icon(Icons.wb_sunny_rounded, color: Color(0xFF0D7A68)),
                  label: isAr ? 'الإعدادات' : 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

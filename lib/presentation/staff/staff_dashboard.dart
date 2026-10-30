import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/hospital_entity.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/entities/queue_ticket_entity.dart';
import '../shared/providers.dart';

class StaffDashboard extends ConsumerStatefulWidget {
  final UserEntity user;
  const StaffDashboard({Key? key, required this.user}) : super(key: key);

  @override
  ConsumerState<StaffDashboard> createState() => _StaffDashboardState();
}


class _StaffDashboardState extends ConsumerState<StaffDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _manualTicketIdController = TextEditingController();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _manualTicketIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isRtl = locale == 'ar';
    
    // Check if staff has assigned hospital and department
    final hospitalId = widget.user.hospitalId ?? '';
    final deptId = widget.user.departmentId ?? '';

    if (hospitalId.isEmpty || deptId.isEmpty) {
      return Scaffold(
        body: Center(child: Text(locale == 'ar' ? 'خطأ: لم يتم تعيين مستشفى أو قسم!' : 'Error: No hospital or department assigned!')),
      );
    }

    // Watch hospital stream
    final hospitalStream = ref.watch(hospitalStreamProvider(hospitalId));
    // Watch departments stream
    final departmentsStream = ref.watch(departmentsStreamProvider(hospitalId));
    // Watch tickets for this department
    final ticketsStream = ref.watch(departmentTicketsProvider((hospitalId, deptId)));

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('staffDashboard', locale)),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: const Icon(Icons.queue_play_next), text: AppStrings.get('queueStatus', locale)),
              Tab(icon: const Icon(Icons.hotel), text: AppStrings.get('bedManagement', locale)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              tooltip: isRtl ? 'الإعدادات' : 'Settings',
              onPressed: () => GoRouter.of(context).push('/settings'),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Queue Board
            _buildQueueTab(context, hospitalId, deptId, departmentsStream, ticketsStream, locale),
            // Tab 2: Bed Manager
            _buildBedsTab(context, hospitalId, hospitalStream, locale),
          ],
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton.extended(
                onPressed: () => _openScannerDialog(context, locale),
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(locale == 'ar' ? 'تسجيل دخول' : 'Check-In'),
              )
            : null,
      ),
    );
  }

  Widget _buildQueueTab(
    BuildContext context,
    String hospitalId,
    String deptId,
    AsyncValue<List<DepartmentEntity>> deptsAsync,
    AsyncValue<List<QueueTicketEntity>> ticketsAsync,
    String locale,
  ) {
    return deptsAsync.when(
      data: (depts) {
        final dept = depts.firstWhere((d) => d.id == deptId);
        
        return ticketsAsync.when(
          data: (tickets) {
            // Filter tickets: Checked-in vs in transit
            final waitingTickets = tickets.where((t) => t.isWaiting && t.checkedInAt != null).toList();
            final inTransitTickets = tickets.where((t) => t.isWaiting && t.checkedInAt == null).toList();
            final activeTickets = tickets.where((t) => t.isActive).toList();

            // Find current active patient ticket
            final currentTicket = activeTickets.isNotEmpty ? activeTickets.first : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dept Banner
                  Text(
                    dept.getName(locale),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Call Next Patient Area
                  _buildCallNextWidget(context, dept, currentTicket, waitingTickets, locale),
                  const SizedBox(height: 24),

                  // Section 1: Checked-in patients (inside clinic)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locale == 'ar' ? 'المرضى الحاضرين بالعيادة (تم مسح الـ QR):' : 'Checked-in patients waiting:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${waitingTickets.length}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (waitingTickets.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          locale == 'ar' ? 'لا يوجد مرضى حاضرين بالعيادة حالياً.' : 'No checked-in patients waiting.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: waitingTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = waitingTickets[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withValues(alpha: 0.15),
                              child: Text(
                                ticket.ticketNumber.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ),
                            title: Text(ticket.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${AppStrings.get('nationalId', locale)}: ${ticket.nationalId}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                locale == 'ar' ? 'حاضر بالعيادة ✓' : 'Checked In ✓',
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  // Section 2: Booked & In Transit patients (on their way)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locale == 'ar' ? 'المرضى المحجوز لهم إلكترونياً (في الطريق):' : 'Booked patients in transit:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${inTransitTickets.length}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (inTransitTickets.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          locale == 'ar' ? 'لا توجد حجوزات في الطريق حالياً.' : 'No in-transit bookings.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: inTransitTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = inTransitTickets[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.amber.withValues(alpha: 0.15),
                              child: Text(
                                ticket.ticketNumber.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800]),
                              ),
                            ),
                            title: Text(ticket.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${AppStrings.get('nationalId', locale)}: ${ticket.nationalId}'),
                            trailing: ElevatedButton.icon(
                              onPressed: () => _processCheckIn(ticket.id, locale),
                              icon: const Icon(Icons.check, size: 14),
                              label: Text(locale == 'ar' ? 'تسجيل حضور' : 'Check-In'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) {
            debugPrint('❌ Error loading tickets: $err\n$stack');
            final errStr = err.toString();
            final isIndexError = errStr.contains('FAILED_PRECONDITION') || errStr.contains('index');
            
            return GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  isIndexError
                      ? (locale == 'ar' 
                          ? 'تهيئة قاعدة البيانات جارية حالياً، يرجى الانتظار دقيقة...' 
                          : 'Database index is currently building on Google servers. Please wait a minute...')
                      : (locale == 'ar'
                          ? 'حدث خطأ أثناء تحميل التذاكر: ${errStr.split('\n').first}'
                          : 'Error loading tickets: ${errStr.split('\n').first}'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) {
        debugPrint('❌ Error loading department: $err\n$stack');
        final errStr = err.toString();
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              locale == 'ar'
                  ? 'حدث خطأ أثناء تحميل القسم: ${errStr.split('\n').first}'
                  : 'Error loading department: ${errStr.split('\n').first}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallNextWidget(
    BuildContext context, 
    DepartmentEntity dept, 
    QueueTicketEntity? currentTicket, 
    List<QueueTicketEntity> waitingTickets,
    String locale,
  ) {
    final primary = Theme.of(context).colorScheme.primary;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale == 'ar' ? 'المستدعى حالياً' : 'Now Serving',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              Text(
                '${locale == 'ar' ? 'إجمالي الحجز اليوم' : 'Total Issued'}: ${dept.lastNumber}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (currentTicket != null) ...[
            Text(
              currentTicket.patientName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${AppStrings.get('ticketNumber', locale)}: ${currentTicket.ticketNumber}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary),
            ),
            const SizedBox(height: 20),
            
            // Serve Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ref.read(queueRepositoryProvider).updateTicketStatus(
                          currentTicket.id,
                          QueueStatus.completed,
                        ),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: Text(AppStrings.get('markCompleted', locale)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ref.read(queueRepositoryProvider).updateTicketStatus(
                          currentTicket.id,
                          QueueStatus.absent,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      foregroundColor: Colors.red,
                      elevation: 0,
                    ),
                    child: Text(AppStrings.get('markAbsent', locale)),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              locale == 'ar' ? 'لا يوجد مريض تحت المعاينة' : 'No Patient in Service',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: waitingTickets.isEmpty
                  ? null
                  : () {
                      // Call next ticket
                      final nextTicket = waitingTickets.first;
                      ref.read(queueRepositoryProvider).updateTicketStatus(
                            nextTicket.id,
                            QueueStatus.active,
                          );
                    },
              child: Text(AppStrings.get('callNext', locale)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBedsTab(
    BuildContext context,
    String hospitalId,
    AsyncValue<HospitalEntity> hospitalAsync,
    String locale,
  ) {
    return hospitalAsync.when(
      data: (hospital) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                hospital.getName(locale),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                AppStrings.get('updateBedCount', locale),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),

              // Stepper widgets for beds
              _buildBedCounter(
                context, 
                Icons.hotel, 
                AppStrings.get('icuBeds', locale), 
                hospital.icu.available, 
                hospital.icu.total, 
                (newVal) => ref.read(hospitalRepositoryProvider).updateBedCapacity(hospitalId, icuAvailable: newVal),
              ),
              _buildBedCounter(
                context, 
                Icons.child_care, 
                AppStrings.get('incubators', locale), 
                hospital.incubator.available, 
                hospital.incubator.total, 
                (newVal) => ref.read(hospitalRepositoryProvider).updateBedCapacity(hospitalId, incubatorAvailable: newVal),
              ),
              _buildBedCounter(
                context, 
                Icons.medical_services, 
                AppStrings.get('ventilators', locale), 
                hospital.ventilator.available, 
                hospital.ventilator.total, 
                (newVal) => ref.read(hospitalRepositoryProvider).updateBedCapacity(hospitalId, ventilatorAvailable: newVal),
              ),
              _buildBedCounter(
                context, 
                Icons.nights_stay, 
                AppStrings.get('generalBeds', locale), 
                hospital.general.available, 
                hospital.general.total, 
                (newVal) => ref.read(hospitalRepositoryProvider).updateBedCapacity(hospitalId, generalAvailable: newVal),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.push('/beds/$hospitalId?staff=true'),
                icon: const Icon(Icons.grid_view_rounded),
                label: Text(locale == 'ar' ? 'عرض خريطة الأسرة وبنك الدم التفصيلية' : 'Open Detailed Bed & Blood Grid'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error loading bed status: $err'),
    );
  }

  Widget _buildBedCounter(
    BuildContext context, 
    IconData icon, 
    String label, 
    int available, 
    int total, 
    Function(int) onChanged,
  ) {
    final locale = ref.watch(localeProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '${AppStrings.get('available', locale)}: $available / $total',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            
            // Stepper controls
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: available > 0 ? () => onChanged(available - 1) : null,
                ),
                Text(
                  available.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: available < total ? () => onChanged(available + 1) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openScannerDialog(BuildContext context, String locale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Container(
                    width: 40,
                    height: 4,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.get('receptionScanner', locale),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // QR Scanner frame OR simulated fallback
                  if (_isScanning)
                    SizedBox(
                      height: 250,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: MobileScanner(
                          onDetect: (capture) async {
                            final List<Barcode> barcodes = capture.barcodes;
                            if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                              final ticketId = barcodes.first.rawValue!;
                              setModalState(() {
                                _isScanning = false;
                              });
                              _processCheckIn(ticketId, locale);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              setModalState(() {
                                _isScanning = true;
                              });
                            },
                            child: Text(locale == 'ar' ? 'فتح الكاميرا والمسح' : 'Open Camera Scanner'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  
                  // Manual input divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(locale == 'ar' ? 'أو أدخل رقم الحجز يدوياً' : 'Or enter ticket ID manually', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ticket ID Text field
                  TextFormField(
                    controller: _manualTicketIdController,
                    decoration: InputDecoration(
                      labelText: locale == 'ar' ? 'معرف التذكرة (Id)' : 'Ticket ID',
                      prefixIcon: const Icon(Icons.keyboard),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final ticketId = _manualTicketIdController.text.trim();
                      if (ticketId.isNotEmpty) {
                        _processCheckIn(ticketId, locale);
                        Navigator.pop(context);
                      }
                    },
                    child: Text(AppStrings.get('confirm', locale)),
                  ),
                ],
              ),
            ),
          );
          },
        );
      },
    );
  }

  void _processCheckIn(String ticketId, String locale) async {
    try {
      await ref.read(queueRepositoryProvider).checkInTicket(ticketId);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('scanSuccess', locale)),
          backgroundColor: Colors.green,
        ),
      );
      _manualTicketIdController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.get('scanError', locale)}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

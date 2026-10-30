import 'package:flutter/material.dart';
import 'package:taboori/features/beds/domain/bed_entity.dart';
import 'package:taboori/features/beds/data/mock_bed_repository.dart';

/// Bed management dashboard — shows occupancy overview and individual beds
/// Used by Staff and Inspector roles
class BedManagementScreen extends StatefulWidget {
  final String hospitalId;
  final String? departmentId;
  final bool isStaffMode; // staff can edit, inspector is read-only

  const BedManagementScreen({
    super.key,
    required this.hospitalId,
    this.departmentId,
    this.isStaffMode = false,
  });

  @override
  State<BedManagementScreen> createState() => _BedManagementScreenState();
}

class _BedManagementScreenState extends State<BedManagementScreen> {
  final _repo = MockBedRepository();
  List<BedEntity> _beds = [];
  BedOccupancySummary? _summary;
  BedType? _typeFilter;
  BedStatus? _statusFilter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBeds();
  }

  Future<void> _loadBeds() async {
    setState(() => _loading = true);
    final beds = widget.departmentId != null
        ? await _repo.getBedsByDepartment(widget.hospitalId, widget.departmentId!)
        : await _repo.getBedsByHospital(widget.hospitalId);
    final summary = BedOccupancySummary.fromBeds(beds);
    if (!mounted) return;
    setState(() {
      _beds = beds;
      _summary = summary;
      _loading = false;
    });
  }

  List<BedEntity> get _filteredBeds {
    return _beds.where((b) {
      if (_typeFilter != null && b.type != _typeFilter) return false;
      if (_statusFilter != null && b.status != _statusFilter) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأسرة'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBeds,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBeds,
              child: CustomScrollView(
                slivers: [
                  // Occupancy Summary Cards
                  if (_summary != null)
                    SliverToBoxAdapter(
                      child: _buildOccupancySummary(theme),
                    ),

                  // Critical Blood & Rare Plasma Emergency Grid
                  SliverToBoxAdapter(
                    child: _buildBloodBankSection(theme),
                  ),

                  // Filter Chips
                  SliverToBoxAdapter(
                    child: _buildFilters(theme),
                  ),

                  // Beds Grid
                  _filteredBeds.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bed_rounded, size: 64,
                                    color: theme.colorScheme.outline),
                                const SizedBox(height: 16),
                                Text('لا توجد أسرة مطابقة',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.outline,
                                    )),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _buildBedCard(_filteredBeds[index], theme),
                              childCount: _filteredBeds.length,
                            ),
                          ),
                        ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
      floatingActionButton: widget.isStaffMode
          ? FloatingActionButton.extended(
              onPressed: () => _showSmartBedSearch(context),
              icon: const Icon(Icons.search),
              label: const Text('بحث عن سرير متاح'),
            )
          : null,
    );
  }

  Widget _buildOccupancySummary(ThemeData theme) {
    final s = _summary!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.isCritical
            ? Colors.red.shade50
            : s.isHighOccupancy
                ? Colors.orange.shade50
                : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: s.isCritical
              ? Colors.red.shade200
              : s.isHighOccupancy
                  ? Colors.orange.shade200
                  : Colors.teal.shade200,
        ),
      ),
      child: Column(
        children: [
          // Occupancy percentage header
          Row(
            children: [
              Icon(
                s.isCritical
                    ? Icons.warning_rounded
                    : Icons.hotel_rounded,
                color: s.isCritical
                    ? Colors.red
                    : s.isHighOccupancy
                        ? Colors.orange
                        : Colors.teal,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نسبة الإشغال: ${s.occupancyPercent}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (s.isCritical)
                      Text(
                        '⚠️ إشغال حرج — قد تحتاج لتحويل المرضى',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade700,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Metrics row
          Row(
            children: [
              _buildMetricChip('إجمالي', '${s.total}', Colors.blueGrey, theme),
              _buildMetricChip('متاح', '${s.available}', Colors.green, theme),
              _buildMetricChip('مشغول', '${s.occupied}', Colors.red, theme),
              _buildMetricChip('محجوز', '${s.reserved}', Colors.orange, theme),
            ],
          ),
          if (s.cleaning > 0 || s.maintenance > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  _buildMetricChip(
                      'تنظيف', '${s.cleaning}', Colors.blue, theme),
                  _buildMetricChip(
                      'صيانة', '${s.maintenance}', Colors.grey, theme),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(
      String label, String value, Color color, ThemeData theme) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodBankSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.12),
            Colors.deepOrange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bloodtype, color: Colors.red, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'شبكة فصائل الدم وبلازما الطوارئ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red),
                    ),
                    Text(
                      'مخزون الرعاية الحرجة وبنك الدم الإقليمي',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  '● متصل لحظياً',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBloodUnitBadge('O-', '3 أكياس', isCritical: true),
              _buildBloodUnitBadge('AB-', '2 كيس', isCritical: true),
              _buildBloodUnitBadge('B-', '5 أكياس', isCritical: false),
              _buildBloodUnitBadge('A+', '14 كيس', isCritical: false),
              _buildBloodUnitBadge('بلازما', '8 وحدات', isCritical: false),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🩸 جاري إرسال طلب استعجال أكياس O- من بنك الدم المركزي بالعجوزة...'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  icon: const Icon(Icons.call_made, size: 14),
                  label: const Text('طلب نقل دم عاجل (العجوزة)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBloodUnitBadge(String type, String count, {required bool isCritical}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCritical ? Colors.red : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            type,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isCritical ? Colors.red : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isCritical ? FontWeight.bold : FontWeight.normal,
              color: isCritical ? Colors.red[700] : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('الكل'),
                  selected: _typeFilter == null,
                  onSelected: (_) => setState(() => _typeFilter = null),
                ),
                const SizedBox(width: 8),
                ...BedType.values.map((t) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(t.labelAr),
                        selected: _typeFilter == t,
                        onSelected: (_) =>
                            setState(() => _typeFilter = _typeFilter == t ? null : t),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Status filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('كل الحالات'),
                  selected: _statusFilter == null,
                  onSelected: (_) => setState(() => _statusFilter = null),
                ),
                const SizedBox(width: 8),
                ...BedStatus.values.map((s) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(s.labelAr),
                        selected: _statusFilter == s,
                        onSelected: (_) => setState(
                            () => _statusFilter = _statusFilter == s ? null : s),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBedCard(BedEntity bed, ThemeData theme) {
    final color = _statusColor(bed.status);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showBedDetails(bed),
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(100)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              bed.isOccupied ? Icons.person_rounded : Icons.bed_rounded,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              bed.bedNumber,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                bed.status.labelAr,
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
              ),
            ),
            if (bed.patientName != null) ...[
              const SizedBox(height: 2),
              Text(
                bed.patientName!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(BedStatus status) => switch (status) {
        BedStatus.available => Colors.green,
        BedStatus.occupied => Colors.red,
        BedStatus.reserved => Colors.orange,
        BedStatus.cleaning => Colors.blue,
        BedStatus.maintenance => Colors.grey,
        BedStatus.unavailable => Colors.black45,
      };

  void _showBedDetails(BedEntity bed) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bed_rounded, color: _statusColor(bed.status), size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'سرير ${bed.bedNumber}',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(bed.status).withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bed.status.labelAr,
                    style: TextStyle(
                      color: _statusColor(bed.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _detailRow('النوع', bed.type.labelAr),
            _detailRow('العنبر', bed.wardId),
            _detailRow('الغرفة', bed.roomNumber),
            if (bed.patientName != null) _detailRow('المريض', bed.patientName!),
            if (bed.assignedAt != null)
              _detailRow('تاريخ الدخول',
                  '${bed.assignedAt!.day}/${bed.assignedAt!.month}/${bed.assignedAt!.year}'),
            if (bed.notes != null) _detailRow('ملاحظات', bed.notes!),
            if (widget.isStaffMode) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (bed.isOccupied)
                      FilledButton.icon(
                        onPressed: () => _updateStatus(bed, BedStatus.cleaning),
                        icon: const Icon(Icons.logout),
                        label: const Text('إخلاء السرير'),
                      ),
                    if (bed.status == BedStatus.cleaning)
                      FilledButton.icon(
                        onPressed: () => _updateStatus(bed, BedStatus.available),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('جاهز للاستخدام'),
                      ),
                    if (bed.isAvailable)
                      FilledButton.icon(
                        onPressed: () => _updateStatus(bed, BedStatus.occupied),
                        icon: const Icon(Icons.person_add),
                        label: const Text('تسكين مريض'),
                      ),
                    if (bed.isAvailable)
                      OutlinedButton.icon(
                        onPressed: () => _updateStatus(bed, BedStatus.maintenance),
                        icon: const Icon(Icons.build),
                        label: const Text('صيانة'),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BedEntity bed, BedStatus newStatus) async {
    Navigator.pop(context);
    await _repo.updateBedStatus(bed.id, newStatus);
    _loadBeds();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث سرير ${bed.bedNumber} → ${newStatus.labelAr}'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _showSmartBedSearch(BuildContext context) async {
    final available = await _repo.findAvailableBeds(
      hospitalId: widget.hospitalId,
      departmentId: widget.departmentId,
    );
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔍 أسرة متاحة (${available.length})',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (available.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'لا توجد أسرة متاحة حالياً',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: available.length,
                  itemBuilder: (_, i) {
                    final bed = available[i];
                    return ListTile(
                      leading: Icon(Icons.bed_rounded, color: Colors.green),
                      title: Text('سرير ${bed.bedNumber}'),
                      subtitle: Text('${bed.type.labelAr} — عنبر ${bed.wardId}'),
                      trailing: widget.isStaffMode
                          ? IconButton(
                              icon: const Icon(Icons.person_add, color: Colors.teal),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _updateStatus(bed, BedStatus.occupied);
                              },
                            )
                          : null,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

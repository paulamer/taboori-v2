import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/glass_card.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/hospital_entity.dart';
import '../shared/providers.dart';

class AdminDashboard extends ConsumerWidget {
  final UserEntity user;
  const AdminDashboard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isRtl = locale == 'ar';

    final hospitalRepo = ref.watch(hospitalRepositoryProvider);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('adminDashboard', locale)),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              tooltip: isRtl ? 'الإعدادات' : 'Settings',
              onPressed: () => GoRouter.of(context).push('/settings'),
            ),
          ],
        ),
        body: FutureBuilder<List<HospitalEntity>>(
          future: hospitalRepo.getHospitals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading analytics: ${snapshot.error}'));
            }

            final list = snapshot.data ?? [];

            // Aggregate metrics
            int totalHospitals = list.length;
            int totalIcuBeds = 0;
            int availableIcuBeds = 0;
            int totalIncubators = 0;
            int availableIncubators = 0;

            for (var h in list) {
              totalIcuBeds += h.icu.total;
              availableIcuBeds += h.icu.available;
              totalIncubators += h.incubator.total;
              availableIncubators += h.incubator.available;
            }

            int occupiedIcu = totalIcuBeds - availableIcuBeds;
            double icuOccupancyRate = totalIcuBeds > 0 ? (occupiedIcu / totalIcuBeds) * 100 : 0.0;

            int occupiedIncubators = totalIncubators - availableIncubators;
            double incubatorOccupancyRate = totalIncubators > 0 ? (occupiedIncubators / totalIncubators) * 100 : 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ministry Alert Banner
                  _buildAlertBanner(locale),
                  const SizedBox(height: 20),

                  // High-level summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context, 
                          totalHospitals.toString(), 
                          AppStrings.get('totalHospitals', locale), 
                          Icons.local_hospital,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context, 
                          '${icuOccupancyRate.toStringAsFixed(1)}%', 
                          AppStrings.get('bedOccupancy', locale), 
                          Icons.pie_chart,
                          color: icuOccupancyRate > 80 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Bed Occupancy Chart Card
                  Text(
                    AppStrings.get('bedOccupancy', locale),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildBedOccupancyChartCard(context, icuOccupancyRate, incubatorOccupancyRate, locale),
                  const SizedBox(height: 24),

                  // Wait times by department Chart Card
                  Text(
                    AppStrings.get('averageWaitTimes', locale),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildWaitTimesChartCard(context, locale),
                  const SizedBox(height: 24),

                  // Governorate Breakdown Table
                  Text(
                    AppStrings.get('governorateStats', locale),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildGovTable(context, list, locale),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlertBanner(String locale) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.get('criticalAlert', locale),
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, {Color? color}) {
    final primary = color ?? Theme.of(context).colorScheme.primary;
    
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 28, color: primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primary),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBedOccupancyChartCard(
    BuildContext context, 
    double icuRate, 
    double incubatorRate, 
    String locale,
  ) {
    final isAr = locale == 'ar';
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    Widget text;
                    if (value == 0) {
                      text = Text(isAr ? 'عناية مركزة' : 'ICU', style: const TextStyle(fontSize: 10));
                    } else {
                      text = Text(isAr ? 'حضانات' : 'Incubator', style: const TextStyle(fontSize: 10));
                    }
                    return SideTitleWidget(meta: meta, child: text);
                  },
                ),
              ),
            ),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: icuRate,
                    color: icuRate > 80 ? Colors.red : Colors.teal,
                    width: 32,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: incubatorRate,
                    color: incubatorRate > 80 ? Colors.red : Colors.green,
                    width: 32,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitTimesChartCard(BuildContext context, String locale) {
    final isAr = locale == 'ar';
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    Widget text;
                    switch (value.toInt()) {
                      case 0:
                        text = Text(isAr ? 'طوارئ' : 'ER', style: const TextStyle(fontSize: 9));
                        break;
                      case 1:
                        text = Text(isAr ? 'قلب' : 'Cardio', style: const TextStyle(fontSize: 9));
                        break;
                      case 2:
                        text = Text(isAr ? 'أطفال' : 'Peds', style: const TextStyle(fontSize: 9));
                        break;
                      case 3:
                        text = Text(isAr ? 'جراحة' : 'Surgery', style: const TextStyle(fontSize: 9));
                        break;
                      default:
                        text = const Text('');
                    }
                    return SideTitleWidget(meta: meta, child: text);
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 8),   // ER: 8 mins
                  FlSpot(1, 25),  // Cardio: 25 mins
                  FlSpot(2, 18),  // Pediatrics: 18 mins
                  FlSpot(3, 30),  // Surgery: 30 mins
                ],
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGovTable(BuildContext context, List<HospitalEntity> list, String locale) {
    // Group totals by governorate
    final Map<String, List<HospitalEntity>> groups = {};
    for (var h in list) {
      groups.putIfAbsent(h.governorate, () => []).add(h);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          columnSpacing: 16,
          columns: [
            DataColumn(label: Text(locale == 'ar' ? 'المحافظة' : 'Gov', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(locale == 'ar' ? 'المستشفيات' : 'Hosp', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(locale == 'ar' ? 'العناية' : 'ICU', style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(locale == 'ar' ? 'الحضانات' : 'Incubator', style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: groups.entries.map((entry) {
            final gov = entry.key;
            final govHospitals = entry.value;

            int icuAvail = 0;
            int icuTotal = 0;
            int incAvail = 0;
            int incTotal = 0;

            for (var h in govHospitals) {
              icuAvail += h.icu.available;
              icuTotal += h.icu.total;
              incAvail += h.incubator.available;
              incTotal += h.incubator.total;
            }

            return DataRow(
              cells: [
                DataCell(Text(gov, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(govHospitals.length.toString())),
                DataCell(Text('$icuAvail / $icuTotal')),
                DataCell(Text('$incAvail / $incTotal')),
              ],
            );
          }).toList(),
        ),
      ),
    ),
        const SizedBox(height: 16),
        Text(
          locale == 'ar' ? 'فحص تفاصيل أسرة المستشفيات وبنك الدم:' : 'Inspect Hospital Beds & Blood Bank:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...list.map((hosp) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.local_hospital, color: Colors.teal),
            title: Text(hosp.getName(locale), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('${hosp.governorate} • ' + (locale == 'ar' ? 'عناية متاحة: ' : 'ICU Avail: ') + '${hosp.icu.available}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.teal),
            onTap: () => context.push('/beds/${hosp.id}?staff=false'),
          ),
        )),
      ],
    );
  }
}

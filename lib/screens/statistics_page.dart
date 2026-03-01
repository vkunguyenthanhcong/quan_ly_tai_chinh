import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quan_ly_chi_tieu/core/theme/app_colors.dart';
import '../services/statistic_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final service = StatisticService();

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Thống kê",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: "Chi tiêu"),
            Tab(text: "Thu nhập"),
          ],
        ),
      ),
      body: Column(
        children: [
          _monthYearFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _StatisticTab(
                  type: 'expense',
                  month: selectedMonth,
                  year: selectedYear,
                  service: service,
                ),
                _StatisticTab(
                  type: 'income',
                  month: selectedMonth,
                  year: selectedYear,
                  service: service,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }

  Widget _monthYearFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _box(
            DropdownButton<int>(
              value: selectedMonth,
              underline: const SizedBox(),
              dropdownColor: AppColors.surface,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              items: List.generate(12, (i) {
                final m = i + 1;
                return DropdownMenuItem(
                  value: m,
                  child: Text("Tháng $m"),
                );
              }),
              onChanged: (v) => setState(() => selectedMonth = v!),
            ),
          ),
          _box(
            DropdownButton<int>(
              value: selectedYear,
              underline: const SizedBox(),
              dropdownColor: AppColors.surface,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              items: List.generate(5, (i) {
                final y = DateTime.now().year - i;
                return DropdownMenuItem(
                  value: y,
                  child: Text("$y"),
                );
              }),
              onChanged: (v) => setState(() => selectedYear = v!),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticTab extends StatelessWidget {
  final String type;
  final int month;
  final int year;
  final StatisticService service;

  const _StatisticTab({
    required this.type,
    required this.month,
    required this.year,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: service.loadStatistic(type: type, month: month, year: year),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.accent,
            ),
          );
        }

        final data = snapshot.data as StatisticResult;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type == 'expense' ? "Chi tiêu" : "Thu nhập",
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _money(data.total),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: 200, child: BarChart(_bar(data.barData))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _card(
              child: Row(
                children: [
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: PieChart(_pie(data.pieData)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(child: _legend(data.pieData)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  String _money(int v) =>
      "${v.toString().replaceAllMapped(RegExp(r'(\\d)(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]}.')} đ";

  BarChartData _bar(Map<int, int> data) {
    final maxY = data.isEmpty
        ? 1000
        : data.values.reduce((a, b) => a > b ? a : b) * 1.2;

    final barColor =
        type == 'expense' ? AppColors.expense : AppColors.income;

    return BarChartData(
      maxY: maxY.toDouble(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(show: false),
      barGroups: data.entries.map((e) {
        return BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: e.value.toDouble(),
              width: 16,
              borderRadius: BorderRadius.circular(6),
              color: barColor,
            ),
          ],
        );
      }).toList(),
    );
  }

  PieChartData _pie(Map<String, int> data) {
    final total = data.values.fold(0, (a, b) => a + b);

    final colors = [
      AppColors.accent,
      AppColors.income,
      AppColors.expense,
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];

    int index = 0;

    return PieChartData(
      centerSpaceRadius: 50,
      sections: data.entries.map((e) {
        final percent = total == 0 ? 0 : (e.value / total * 100).round();
        final color = colors[index % colors.length];
        index++;

        return PieChartSectionData(
          value: e.value.toDouble(),
          title: '$percent%',
          color: color,
          radius: 50,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      }).toList(),
    );
  }

  Widget _legend(Map<String, int> data) {
    final colors = [
      AppColors.accent,
      AppColors.income,
      AppColors.expense,
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];

    int index = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.keys.map((k) {
        final color = colors[index % colors.length];
        index++;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(
                k,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
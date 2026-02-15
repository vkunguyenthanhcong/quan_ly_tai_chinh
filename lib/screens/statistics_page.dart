import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
      backgroundColor: const Color(0xFF121826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121826),
        centerTitle: true,
        title: const Text("Thống kê", style: TextStyle(fontWeight: FontWeight.w700),),
        bottom: TabBar(
          controller: _tabController,
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

  Widget _monthYearFilter() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _box(
            DropdownButton<int>(
              value: selectedMonth,
              underline: const SizedBox(),
              dropdownColor: const Color(0xFF1E2538),
              items: List.generate(12, (i) {
                final m = i + 1;
                return DropdownMenuItem(
                  value: m,
                  child: Text("Tháng $m",
                      style: const TextStyle(color: Colors.white)),
                );
              }),
              onChanged: (v) => setState(() => selectedMonth = v!),
            ),
          ),
          _box(
            DropdownButton<int>(
              value: selectedYear,
              underline: const SizedBox(),
              dropdownColor: const Color(0xFF1E2538),
              items: List.generate(5, (i) {
                final y = DateTime.now().year - i;
                return DropdownMenuItem(
                  value: y,
                  child: Text("$y",
                      style: const TextStyle(color: Colors.white)),
                );
              }),
              onChanged: (v) => setState(() => selectedYear = v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2538),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
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
      future: service.loadStatistic(
        type: type,
        month: month,
        year: year,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString(),
                style: const TextStyle(color: Colors.red)),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data as StatisticResult;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            Text(
              "${type == 'expense' ? 'Chi tiêu' : 'Thu nhập'}   ${_money(data.total)}",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 220, child: BarChart(_bar(data.barData))),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: PieChart(_pie(data.pieData)),
                  ),
                  const SizedBox(width: 20),
                  _legend(data.pieData),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _money(int v) =>
      "${v.toString().replaceAllMapped(RegExp(r'(\\d)(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]}.')} VND";

  BarChartData _bar(Map<int, int> data) {
    final maxY = data.isEmpty
        ? 1000
        : data.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return BarChartData(
      maxY: maxY.toDouble(),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: data.entries
          .map((e) => BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.toDouble(),
                    width: 14,
                    color: Colors.cyanAccent,
                  ),
                ],
              ))
          .toList(),
    );
  }

  PieChartData _pie(Map<String, int> data) {
    final total = data.values.fold(0, (a, b) => a + b);
    return PieChartData(
      centerSpaceRadius: 70,
      sections: data.entries.map((e) {
        final percent =
            total == 0 ? 0 : (e.value / total * 100).round();
        return PieChartSectionData(
          value: e.value.toDouble(),
          title: '$percent%',
          color: Colors.primaries[
              e.key.hashCode % Colors.primaries.length],
          radius: 30,
          titleStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        );
      }).toList(),
    );
  }

  Widget _legend(Map<String, int> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.keys.map((k) {
        final color =
            Colors.primaries[k.hashCode % Colors.primaries.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(k,
                  style:
                      const TextStyle(color: Colors.white70)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

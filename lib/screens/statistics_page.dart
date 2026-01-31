import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121826),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Thống kê",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Chi tiêu"),
            Tab(text: "Thu nhập"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          StatisticContent(
            title: "Chi tiêu",
            total: "-10,000,000 VND",
          ),
          StatisticContent(
            title: "Thu nhập",
            total: "+60,000,000 VND",
          ),
        ],
      ),
    );
  }
}

/// ================= CONTENT =================

class StatisticContent extends StatelessWidget {
  final String title;
  final String total;

  const StatisticContent({
    super.key,
    required this.title,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "$title   $total",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 16),

        /// ===== BAR CHART =====
        const Text(
          "Thống kê theo tháng",
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: BarChart(barChartData()),
        ),

        const SizedBox(height: 32),

        /// ===== PIE CHART =====
        Text(
          "So sánh các loại ${title.toLowerCase()}",
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: PieChart(pieChartData()),
        ),
      ],
    );
  }
}

/// ================= BAR CHART =================

BarChartData barChartData() {
  return BarChartData(
    backgroundColor: const Color(0xFF121826),
    gridData: FlGridData(show: false),
    borderData: FlBorderData(show: false),
    titlesData: FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          getTitlesWidget: (value, _) {
            if (value == 0) return const SizedBox();
            return Text(
              value >= 1000000
                  ? "${(value / 1000000).toInt()}M"
                  : "${(value / 1000).toInt()}k",
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, _) {
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "${value.toInt()}Jan",
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            );
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    barGroups: [
      barItem(1, 200000),
      barItem(2, 600000),
      barItem(3, 800000),
      barItem(11, 150000),
      barItem(16, 400000),
      barItem(18, 700000),
      barItem(20, 900000),
    ],
  );
}

BarChartGroupData barItem(int x, double y) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y,
        width: 12,
        color: Colors.cyanAccent,
        borderRadius: BorderRadius.circular(4),
      ),
    ],
  );
}

/// ================= PIE CHART =================

PieChartData pieChartData() {
  return PieChartData(
    sectionsSpace: 2,
    centerSpaceRadius: 50,
    sections: [
      pieItem(40, Colors.cyan, "40%"),
      pieItem(23, Colors.purple, "23%"),
      pieItem(20, Colors.pink, "20%"),
      pieItem(47, Colors.orange, "47%"),
    ],
  );
}

PieChartSectionData pieItem(
  double value,
  Color color,
  String label,
) {
  return PieChartSectionData(
    value: value,
    color: color,
    title: label,
    radius: 60,
    titleStyle: const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  );
}

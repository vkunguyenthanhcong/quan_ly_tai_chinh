import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/transaction_service.dart';

class OverviewChart extends StatelessWidget {
  const OverviewChart({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TransactionService();
    final year = DateTime.now().year;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: service.getMonthlySummary(year),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading();
        }

        if (snapshot.hasError) {
          return _error(snapshot.error.toString());
        }

        final data = snapshot.data!;

        final incomeSpots = <FlSpot>[];
        final expenseSpots = <FlSpot>[];

        for (final m in data) {
          final month = m['month'] as int;
          final income = (m['income'] as int) / 1_000_000;
          final expense = (m['expense'] as int) / 1_000_000;

          incomeSpots.add(FlSpot(month.toDouble(), income));
          expenseSpots.add(FlSpot(month.toDouble(), expense));
        }

        return _chart(incomeSpots, expenseSpots);
      },
    );
  }

  // ================= CHART =================

  Widget _chart(List<FlSpot> income, List<FlSpot> expense) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF5A5E66),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              _Legend(color: Colors.pinkAccent, text: "Thu nhập"),
              SizedBox(width: 16),
              _Legend(color: Colors.green, text: "Chi tiêu"),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 12,
                minY: 0,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (v, _) =>
                          Text("${v.toInt()}M",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 10)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, _) =>
                          Text("T${v.toInt()}",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 10)),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: income,
                    isCurved: true,
                    color: Colors.pinkAccent,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: expense,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATES =================

  Widget _loading() => Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF5A5E66),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const CircularProgressIndicator(),
      );

  Widget _error(String text) => Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF5A5E66),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: const TextStyle(color: Colors.red)),
      );
}

// ================= LEGEND =================

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

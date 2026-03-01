import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quan_ly_chi_tieu/core/theme/app_colors.dart';
import '../services/transaction_service.dart';
class OverviewChart extends StatelessWidget {
  const OverviewChart({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TransactionService();
    final year = DateTime.now().year;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: service.getYearSummary(year),
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
    height: 200,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 30,
          offset: const Offset(0, 20),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tổng quan năm",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: const [
            _Legend(color: AppColors.expense, text: "Chi tiêu"),
            SizedBox(width: 16),
            _Legend(color: AppColors.income, text: "Thu nhập"),
          ],
        ),

        const SizedBox(height: 16),

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
                    getTitlesWidget: (v, _) => Text(
                      "${v.toInt()}M",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (v, _) => Text(
                      "T${v.toInt()}",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),

              lineBarsData: [

                /// INCOME LINE
                LineChartBarData(
                  spots: income,
                  isCurved: true,
                  color: AppColors.income,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.income.withOpacity(0.3),
                        AppColors.income.withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                /// EXPENSE LINE
                LineChartBarData(
                  spots: expense,
                  isCurved: true,
                  color: AppColors.expense,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.expense.withOpacity(0.3),
                        AppColors.expense.withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const CircularProgressIndicator(
          color: AppColors.accent,
        ),
      );

  Widget _error(String text) => Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: const TextStyle(color: AppColors.expense),
        ),
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
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
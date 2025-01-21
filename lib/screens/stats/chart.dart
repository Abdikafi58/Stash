import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expense_data/expense_data.dart';

class MyChart extends StatelessWidget {
  final List<Expense> expenses;
  final List<Expense> income;
  final String view;

  const MyChart({
    super.key,
    required this.expenses,
    required this.income,
    required this.view,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY() * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            fitInsideVertically: true,
            fitInsideHorizontally: true,
            tooltipMargin: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipBorder: BorderSide(color: Colors.grey.shade300),
            getTooltipColor: (group) => Colors.blueGrey.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String label = _getLabelsForView()[group.x.toInt()];
              return BarTooltipItem(
                '$label\n${rod.toY.toInt()}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) {
                return Text(
                  '${(value * 1000).toInt()}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final labels = _getLabelsForView();
                return Text(
                  labels[value.toInt() % labels.length],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        barGroups: _buildBarGroups(),
      ),
    );
  }

  double _getMaxY() {
    final allAmounts = [
      ...expenses.map((e) => e.amount.toDouble()),
      ...income.map((e) => e.amount.toDouble())
    ];
    final maxAmount = allAmounts.isNotEmpty ? allAmounts.reduce((a, b) => a > b ? a : b) : 1000;
    return maxAmount / 1000;
  }

  List<BarChartGroupData> _buildBarGroups() {
    final expenseSpots = expenses.asMap().entries.map((entry) {
      final index = entry.key;
      final amount = entry.value.amount.toDouble();
      return FlSpot(index.toDouble(), amount / 1000);
    }).toList();

    final incomeSpots = income.asMap().entries.map((entry) {
      final index = entry.key;
      final amount = entry.value.amount.toDouble();
      return FlSpot(index.toDouble(), amount / 1000);
    }).toList();

    return [
      BarChartGroupData(
        x: 0,
        barsSpace: 10,
        barRods: expenseSpots.map((spot) {
          return BarChartRodData(
            toY: spot.y,
            color: Colors.red,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          );
        }).toList(),
      ),
      BarChartGroupData(
        x: 1,
        barsSpace: 10,
        barRods: incomeSpots.map((spot) {
          return BarChartRodData(
            toY: spot.y,
            color: Colors.green,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          );
        }).toList(),
      ),
    ];
  }

  List<String> _getLabelsForView() {
    switch (view) {
      case 'Weekly':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'Monthly':
        return List.generate(30, (index) => 'Day ${index + 1}');
      case 'Yearly':
        return [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
      default: 
        return ['1', '2', '3', '4', '5', '6', '7'];
    }
  }
}

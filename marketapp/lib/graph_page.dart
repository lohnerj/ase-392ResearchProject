import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Stateless widget to display a price graph
class GraphPage extends StatelessWidget {
  final List<double> prices;

  // Constructor to initialize prices
  const GraphPage({super.key, required this.prices});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Price Graph"), // Title of the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          height: 400, // Set the height of the graph
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: prices.reduce(max) *
                  1.2, // Ensure there's some space above the highest bar
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      // Display labels for the bottom axis
                      switch (value.toInt()) {
                        case 0:
                          return const Text('Recent',
                              style:
                                  TextStyle(fontSize: 10, color: Colors.red));
                        case 1:
                          return const Text('Lowest',
                              style:
                                  TextStyle(fontSize: 10, color: Colors.red));
                        case 2:
                          return const Text('Highest Buy Order',
                              style:
                                  TextStyle(fontSize: 10, color: Colors.red));
                        case 3:
                          return const Text('Average',
                              style:
                                  TextStyle(fontSize: 10, color: Colors.red));
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Hide top titles
                ),
                rightTitles: const AxisTitles(
                  sideTitles:
                      SideTitles(showTitles: false), // Hide right titles
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: prices.reduce(max) / 5, // Increase intervals
                    getTitlesWidget: (value, meta) => Text('${value.toInt()}',
                        style: const TextStyle(color: Colors.red)),
                    reservedSize: 40, // Reserve space for labels
                  ),
                ),
              ),
              barGroups: prices
                  .asMap()
                  .map((index, value) => MapEntry(
                      index,
                      BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            color: Colors.red,
                            width: 15, // Set the bar width
                          ),
                        ],
                      )))
                  .values
                  .toList(),
              gridData: const FlGridData(show: true), // Display grid lines
              borderData: FlBorderData(show: true), // Display border
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesChartWidget extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> chartData;
  final String title;

  const SalesChartWidget({
    super.key,
    required this.chartData,
    required this.title,
  });

  @override
  State<SalesChartWidget> createState() => _SalesChartWidgetState();
}

class _SalesChartWidgetState extends State<SalesChartWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int touchedIndex = -1;
  int selectedView = 0; // 0: Daily, 1: Weekly, 2: Monthly

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _switchView(int viewIndex) {
    setState(() {
      selectedView = viewIndex;
      _animationController.reset();
      _animationController.forward();
    });
  }

  List<Map<String, dynamic>> get currentData {
    switch (selectedView) {
      case 0:
        return widget.chartData['daily']!;
      case 1:
        return widget.chartData['weekly']!;
      case 2:
        return widget.chartData['monthly']!;
      default:
        return widget.chartData['daily']!;
    }
  }

  String get currentTitle {
    switch (selectedView) {
      case 0:
        return 'Daily Sales';
      case 1:
        return 'Weekly Sales';
      case 2:
        return 'Monthly Sales';
      default:
        return 'Daily Sales';
    }
  }

  Color get primaryColor {
    switch (selectedView) {
      case 0:
        return Colors.purple;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  Color get secondaryColor {
    switch (selectedView) {
      case 0:
        return Colors.deepPurple;
      case 1:
        return Colors.indigo;
      case 2:
        return Colors.teal;
      default:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chartData['daily']!.isEmpty && widget.chartData['weekly']!.isEmpty && widget.chartData['monthly']!.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No sales data available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 450,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Type Selector - Centered
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildViewButton('Daily', 0),
                  const SizedBox(width: 8),
                  _buildViewButton('Weekly', 1),
                  const SizedBox(width: 8),
                  _buildViewButton('Monthly', 2),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: _getMaxSales() / 4,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[200],
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey[200],
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: _getInterval(),
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value.toInt() >= 0 && value.toInt() < currentData.length) {
                              final period = currentData[value.toInt()]['period'] as String;
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  period,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              );
                            }
                            return const SideTitleWidget(
                              axisSide: AxisSide.bottom,
                              child: Text(''),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: _getMaxSales() / 4,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                '\$${value.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            );
                          },
                          reservedSize: 42,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    minX: 0,
                    maxX: (currentData.length - 1).toDouble(),
                    minY: 0,
                    maxY: _getMaxSales() * 1.1,
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getSpots(),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            secondaryColor,
                          ],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: touchedIndex == index ? 6 : 4,
                              color: primaryColor,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.3),
                              secondaryColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(String label, int viewIndex) {
    final isSelected = selectedView == viewIndex;
    Color buttonColor;
    
    switch (viewIndex) {
      case 0:
        buttonColor = Colors.purple;
        break;
      case 1:
        buttonColor = Colors.blue;
        break;
      case 2:
        buttonColor = Colors.green;
        break;
      default:
        buttonColor = Colors.purple;
    }
    
    return GestureDetector(
      onTap: () => _switchView(viewIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? buttonColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? buttonColor : buttonColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : buttonColor,
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return currentData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final sales = (data['sales'] as num).toDouble();
      // Ensure sales is never negative and apply animation
      final animatedSales = (sales >= 0 ? sales : 0) * _animation.value;
      return FlSpot(
        index.toDouble(),
        animatedSales,
      );
    }).toList();
  }

  double _getMaxSales() {
    if (currentData.isEmpty) return 100;
    
    // Filter out negative values and get the maximum
    final positiveSales = currentData
        .map((data) => (data['sales'] as num).toDouble())
        .where((sales) => sales >= 0)
        .toList();
    
    if (positiveSales.isEmpty) return 100;
    
    final maxSales = positiveSales.reduce((a, b) => a > b ? a : b);
    return maxSales > 0 ? maxSales : 100;
  }

  double _getInterval() {
    if (currentData.length < 10) {
      return 1.0;
    } else if (currentData.length < 20) {
      return 2.0;
    } else {
      return 5.0;
    }
  }
}
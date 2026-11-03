import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

export 'package:fl_chart/fl_chart.dart'
    show LineChartBarData, FlDotData, FlDotCirclePainter;

// ─── Thin wrappers that mirror the FlutterFlow chart API ──────────────────

class FFLineChartData {
  final List<double> xData;
  final List<double> yData;
  final LineChartBarData settings;

  const FFLineChartData({
    required this.xData,
    required this.yData,
    required this.settings,
  });
}

class ChartStylingInfo {
  final Color backgroundColor;
  final bool showBorder;

  const ChartStylingInfo({
    this.backgroundColor = Colors.transparent,
    this.showBorder = false,
  });
}

class AxisBounds {
  final double? minX, minY, maxX, maxY;
  const AxisBounds({this.minX, this.minY, this.maxX, this.maxY});
}

class AxisLabelInfo {
  final double reservedSize;
  const AxisLabelInfo({this.reservedSize = 0});
}

class FlutterFlowLineChart extends StatelessWidget {
  const FlutterFlowLineChart({
    super.key,
    required this.data,
    required this.chartStylingInfo,
    required this.axisBounds,
    required this.xLabels,
    required this.xAxisLabelInfo,
    required this.yAxisLabelInfo,
  });

  final List<FFLineChartData> data;
  final ChartStylingInfo chartStylingInfo;
  final AxisBounds axisBounds;
  final List<String> xLabels;
  final AxisLabelInfo xAxisLabelInfo;
  final AxisLabelInfo yAxisLabelInfo;

  @override
  Widget build(BuildContext context) {
    final lineBarsData = data.map((d) {
      final spots = List.generate(
        d.xData.length,
        (i) => FlSpot(d.xData[i], i < d.yData.length ? d.yData[i] : 0),
      );
      return d.settings.copyWith(spots: spots);
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: lineBarsData,
        backgroundColor: chartStylingInfo.backgroundColor,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: chartStylingInfo.showBorder),
        minX: axisBounds.minX,
        minY: axisBounds.minY,
        maxX: axisBounds.maxX,
        maxY: axisBounds.maxY,
      ),
    );
  }
}

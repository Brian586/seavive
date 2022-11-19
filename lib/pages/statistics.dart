import 'package:flutter/material.dart';
import 'package:seavive/commonFunctions/loadJson.dart';
import 'package:seavive/models/Vive.dart';
import 'package:seavive/widgets/ProgressWidget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {

  bool loading = false;
  TooltipBehavior? _tooltipBehavior;
  List<ChartSampleData> pollutionToKenya = [];
  List<ChartSampleData> pollutionFromKenya = [];

  @override
  void initState() {
    super.initState();

    _tooltipBehavior =
        TooltipBehavior(enable: true, header: '', canShowMarker: false);

    loadData();
  }

  loadData()async {
    setState(() {
      loading = true;
    });

    final jsonResult = await LoadJsonData().getJsonData(context: context, library: "assets/data/data.json");

    print(jsonResult["Kenya"]["to"]["to"]);


    for (var countryMap in jsonResult["Kenya"]["to"]["to"]) {
      pollutionFromKenya.add(ChartSampleData(x: countryMap["name"], y: countryMap["perc"]));
    }

    for (var countryMap in jsonResult["Kenya"]["from"]["from"]) {
      pollutionToKenya.add(ChartSampleData(x: countryMap["name"], y: countryMap["perc"]));
    }

    setState(() {
      loading = false;
    });
  }

  /// The method returns line series to chart.
  List<LineSeries<Vive, dynamic>> _getDefaultLineSeries() {
    return <LineSeries<Vive, dynamic>>[
      LineSeries<Vive, dynamic>(
          animationDuration: 2500,
          dataSource: vives,
          xValueMapper: (Vive vive, _) => vive.temperature,
          yValueMapper: (Vive vive, _) => vive.population,
          width: 2,
          color: Colors.blue,
          name: "Population",
          markerSettings: const MarkerSettings(isVisible: true))
    ];
  }

  /// Get default column series
  List<ColumnSeries<ChartSampleData, String>> _getDefaultColumnSeries() {
    return <ColumnSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
        dataSource: pollutionFromKenya,
        xValueMapper: (ChartSampleData sales, _) => sales.x as String,
        yValueMapper: (ChartSampleData sales, _) => sales.y,
        dataLabelSettings: const DataLabelSettings(
            isVisible: true, textStyle: TextStyle(fontSize: 10)),
      )
    ];
  }

  /// Get default column series
  List<ColumnSeries<ChartSampleData, String>> _getColumnSeries() {
    return <ColumnSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
        dataSource: pollutionToKenya,
        color: Colors.orange,
        xValueMapper: (ChartSampleData sales, _) => sales.x as String,
        yValueMapper: (ChartSampleData sales, _) => sales.y,
        dataLabelSettings: const DataLabelSettings(
            isVisible: true, textStyle: TextStyle(fontSize: 10)),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insights"),
      ),
      body: loading ? circularProgress() : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SfCartesianChart(
              plotAreaBorderWidth: 0,
              title: ChartTitle(text: 'Fish Population'),
              legend: Legend(
                  isVisible: true,
                  overflowMode: LegendItemOverflowMode.wrap),
              primaryXAxis: CategoryAxis(
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  //interval: 2,
                  majorGridLines: const MajorGridLines(width: 0)),
              primaryYAxis: NumericAxis(
                  maximum: 1000,
                  minimum: 0,
                  interval: 50,
                  labelFormat: '{value}',
                  axisLine: const AxisLine(width: 0),
                  majorTickLines:
                  const MajorTickLines(color: Colors.transparent)),
              series: _getDefaultLineSeries(),
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
            const SizedBox(height: 20.0,),
            Text("Ocean Pollution", style: Theme.of(context).textTheme.headline5,),
            const SizedBox(height: 20.0,),
            const Text("Pollution from other countries"),
            SfCartesianChart(
              plotAreaBorderWidth: 0,
              title: ChartTitle(
                  text: 'To Kenya'),
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(width: 0),
                  maximum: 45,
                  minimum: 0,
                  interval: 5,
                  labelFormat: '{value}%',
                  majorTickLines: const MajorTickLines(size: 0)),
              series: _getDefaultColumnSeries(),
              tooltipBehavior: _tooltipBehavior,
          ),

            const SizedBox(height: 20.0,),
            const Text("Pollution from Kenya"),
            SfCartesianChart(
              plotAreaBorderWidth: 0,
              title: ChartTitle(
                  text: 'To Other Countries'),
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(width: 0),
                  maximum: 20,
                  minimum: 0,
                  interval: 1,
                  labelFormat: '{value}%',
                  majorTickLines: const MajorTickLines(size: 0)),
              series: _getColumnSeries(),
              tooltipBehavior: _tooltipBehavior,
            ),
            const SizedBox(height: 50.0,),
          ],
        ),
      ),
    );
  }


}

class ChartSampleData {
  final String? x;
  final double? y;

  ChartSampleData({this.x, this.y});
}

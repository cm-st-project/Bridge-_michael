import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logs/sports_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SportLogsPage extends StatefulWidget {
  const SportLogsPage({Key? key, required this.selectedSport})
      : super(key: key);

  final String selectedSport;

  @override
  State<SportLogsPage> createState() => _SportLogsPageState();
}

class _SportLogsPageState extends State<SportLogsPage> {
  var logs;
  Map<String, List<SportFieldData>> chartData = {};
  bool _isLoading = true;
  String selectedSwimmingStyle = swimmingStyles[1];

  @override
  void initState() {
    super.initState();
    loadUserSports();
  }

  // Load user information from SharedPreferences
  Future<void> loadUserSports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (widget.selectedSport == 'Swimming') {
      String jsonLogs = prefs.getString(widget.selectedSport) ?? '{}';
      setState(() {
        logs = jsonDecode(jsonLogs);
        print(logs);
      });
      updateSwimmingChartData();
    } else if (widget.selectedSport == 'Golf') {
      String jsonLogs = prefs.getString(widget.selectedSport) ?? '{}';
      setState(() {
        logs = jsonDecode(jsonLogs);

        print(logs);
      });
      getGolfChartData();
    }
  }

  void updateSwimmingChartData() {
    setState(() {
      chartData = {};
      _isLoading = true;
    });
    if (logs.containsKey(selectedSwimmingStyle)) {
      Map dateMap = logs[selectedSwimmingStyle];
      dateMap.forEach((date, fieldMap) {
        fieldMap.forEach((field, value) {
          List<SportFieldData>? Data = [];
          var ssData = SportFieldData(
              DateTime.parse(date), double.parse(fieldMap[field]));
          if (chartData.containsKey(field)) {
            Data = chartData[field];
          }
          Data!.add(ssData);
          chartData[field] = Data;
        });
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void getGolfChartData() {
    setState(() {
      chartData = {};
      _isLoading = true;
    });

    Map dateMap = logs;
    dateMap.forEach((date, fieldMap) {
      fieldMap.forEach((field, value) {
        List<SportFieldData>? Data = [];
        var ssData =
            SportFieldData(DateTime.parse(date), double.parse(fieldMap[field]));
        if (chartData.containsKey(field)) {
          Data = chartData[field];
        }
        Data!.add(ssData);
        chartData[field] = Data;
      });
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(124, 147, 195, 1.0),
        title: Text('${widget.selectedSport} Logs'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : chartData.isEmpty
              ? Center(
                  child: Text('No Logs'),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.selectedSport == 'Swimming')
                        DropdownButton<String>(
                          value: selectedSwimmingStyle,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSwimmingStyle = newValue!;
                              updateSwimmingChartData(); // Reload data for the selected swimming style
                            });
                          },
                          items: swimmingStyles
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),


                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                // Loop through each key in chartData
                                for (String field in chartData.keys)
                                  Card(
                                    child: Column(
                                      children: [
                                        Text(
                                          field, // Display the field name as text
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 230,
                                          child: SfCartesianChart(
                                            // Define the primary X axis as DateTimeAxis
                                            primaryXAxis: DateTimeAxis(),
                                            // Add a line series to the chart
                                            series:<CartesianSeries>[
                                              LineSeries<SportFieldData,
                                                  DateTime>(
                                                // Bind dataSource to the corresponding key in chartData
                                                dataSource:
                                                    chartData[field] ?? [],
                                                // Map x-values from date and y-values from corresponding field in your SportFieldData class
                                                xValueMapper:
                                                    (SportFieldData data, _) =>
                                                        data.date,
                                                yValueMapper:
                                                    (SportFieldData data, _) =>
                                                        data.value,
                                                color: Colors.blue,
                                                // Customize marker settings if needed
                                                markerSettings: MarkerSettings(
                                                  shape: DataMarkerType.circle,
                                                  isVisible: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class SportFieldData {
  SportFieldData(this.date, this.value);

  final DateTime date;
  final double value;
}

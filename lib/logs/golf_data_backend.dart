import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class GolfDataBackendPage extends StatefulWidget {
  const GolfDataBackendPage({super.key});

  @override
  State<GolfDataBackendPage> createState() => _GolfDataBackendPageState();
}

class _GolfDataBackendPageState extends State<GolfDataBackendPage> {
  String result = '';
  String averageScore = '';
  String averageDistance = '';
  String fairwayAvg = '';
  String greenInRegAvg = '';
  String greenInRegOnFairwayAvg = '';
  String greenInRegOffAvg = '';
  String birdieConversionAvg = '';
  String puttsHoleAvg = '';
  String puttsAvg = '';
  String threePuttsAvg = '';
  String scramblingAttemptAvg = '';
  String scramblingAttemptBunkerAvg = '';
  String scramblingAttemptRoughAvg = '';
  List<Map<String, dynamic>> logs = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? logsJson = prefs.getString('Golf');

    if (logsJson != null) {
      dynamic decodedData = jsonDecode(logsJson);

      if (decodedData is Map<String, dynamic>) {
        setState(() {
          logs = decodedData.entries
              .map((entry) => {
                    'logDate': entry.key as String,
                    ...entry.value as Map<String, dynamic>,
                  })
              .toList();
        });
      } else if (decodedData is List) {
        setState(() {
          logs = List<Map<String, dynamic>>.from(decodedData);
        });
      }
    }
  }

  Future<void> _saveLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Golf', jsonEncode(logs));
  }

  Future<void> _deleteLog(int index) async {
    setState(() {
      logs.removeAt(index);
    });
    await _saveLogs();
  }

  Future<void> _predict() async {
    setState(() {
      isLoading = true;
    });

    final double? input1 = double.tryParse(averageDistance);
    final double? input2 = double.tryParse(fairwayAvg);
    final double? input3 = double.tryParse(greenInRegAvg);
    final double? input4 = double.tryParse(greenInRegOnFairwayAvg);
    final double? input5 = double.tryParse(greenInRegOnFairwayAvg);
    final double? input6 = double.tryParse(birdieConversionAvg);
    final double? input7 = double.tryParse(puttsAvg);
    final double? input8 = double.tryParse(threePuttsAvg);
    final double? input9 = double.tryParse(scramblingAttemptAvg);
    final double? input10 = double.tryParse(scramblingAttemptBunkerAvg);
    final double? input11 = double.tryParse(scramblingAttemptRoughAvg);

    if ([input1, input2, input3, input4, input5, input6, input7, input8, input9, input10, input11]
        .contains(null)) {
      setState(() {
        result = "Please enter valid numbers for all fields.";
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$URL/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'inputs': [
            input1,
            input2,
            input3,
            input4,
            input5,
            input6,
            input7,
            input8,
            input9,
            input10,
            input11
          ],
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          result =
              'Predicted Golf Performance: ${data['prediction'].toStringAsFixed(2)}';
          isLoading = false;
        });
      } else {
        setState(() {
          result = "Error: ${response.reasonPhrase}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: Could not connect to server.";
        isLoading = false;
      });
    }
  }

  Future<void> calculateAverages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? logsJson = prefs.getString('Golf');

    if (logsJson == null) {
      setState(() {
        averageScore = "No data";
        averageDistance = "No data";
        fairwayAvg = "No data";
        greenInRegAvg = "No data";
        greenInRegOnFairwayAvg = "No data";
        puttsAvg = "No data";
        threePuttsAvg = "No data";
        scramblingAttemptAvg = "No data";
        scramblingAttemptBunkerAvg = "No data";
        birdieConversionAvg = "No data";
        puttsHoleAvg = "No data";
        greenInRegOffAvg = "No data";
        scramblingAttemptRoughAvg = "No data";
      });
      return;
    }

    dynamic logsData = jsonDecode(logsJson);
    if (logsData is Map<String, dynamic>) {
      processLogsForAverages(logsData);
    } else if (logsData is List) {
      for (var entry in logsData) {
        if (entry is Map<String, dynamic>) {
          processLogsForAverages(entry);
        }
      }
    }
  }

  void processLogsForAverages(Map<String, dynamic> logs) {
    List<double> scores = [];
    List<double> drive_distances = [];
    List<double> fairway_hit = [];
    List<double> green_in_regulation = [];
    List<double> green_in_regulation_on = [];
    List<double> birdie_conversion = [];
    List<double> number_of_putts = [];
    List<double> number_of_3putts = [];
    List<double> scrambling_attempt = [];
    List<double> scrambling_attempt_bunker = [];

    logs.forEach((key, value) {
      if (value.containsKey('Score')) {
        scores.add(double.tryParse(value['Score']) ?? 0.0);
      }
      if (value.containsKey('Drive Distance')) {
        drive_distances.add(double.tryParse(value['Drive Distance']) ?? 0.0);
      }
      if (value.containsKey('Fairway Hit')) {
        fairway_hit
            .add((double.tryParse(value['Fairway Hit']) ?? 0.0) / 14 * 100);
      }
      if (value.containsKey('Green in regulation')) {
        green_in_regulation.add(
            (double.tryParse(value['Green in regulation']) ?? 0.0) / 18 * 100);
      }
      if (value.containsKey('Green in Regulation on the fairway')) {
        green_in_regulation_on.add(
            (double.tryParse(value['Green in Regulation on the fairway']) ??
                    0.0) /
                (double.tryParse(value['Fairway Hit']) ?? 1.0) *
                100);
      }
      if (value.containsKey('# of Birdies')) {
        birdie_conversion.add((double.tryParse(value['# of Birdies']) ?? 0.0) /
            (double.tryParse(value['Green in regulation']) ?? 1.0) *
            100);
      }
      if (value.containsKey('# of Putts')) {
        number_of_putts.add(double.tryParse(value['# of Putts']) ?? 0.0);
      }
      if (value.containsKey('# of 3 Putts')) {
        number_of_3putts.add(double.tryParse(value['# of 3 Putts']) ?? 0.0);
      }
      if (value.containsKey('Scrambling Attempts') &&
          value.containsKey('Scrambling Success')) {
        scrambling_attempt.add(
            (double.tryParse(value['Scrambling Success']) ?? 0.0) /
                (double.tryParse(value['Scrambling Attempts']) ?? 1.0) *
                100);
      }
      if (value.containsKey('Scrambling Attempts in Bunker') &&
          value.containsKey('Scrambling Success in Bunker')) {
        scrambling_attempt_bunker.add(
            (double.tryParse(value['Scrambling Success in Bunker']) ?? 0.0) /
                (double.tryParse(value['Scrambling Attempts in Bunker']) ?? 1.0) *
                100);
      }
    });

    setState(() {
      averageScore = scores.isNotEmpty
          ? (scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(2)
          : 'No data';
      averageDistance = drive_distances.isNotEmpty
          ? (drive_distances.reduce((a, b) => a + b) / drive_distances.length)
              .toStringAsFixed(2)
          : 'No data';
      fairwayAvg = fairway_hit.isNotEmpty
          ? (fairway_hit.reduce((a, b) => a + b) / fairway_hit.length)
              .toStringAsFixed(2)
          : 'No data';
      greenInRegAvg = green_in_regulation.isNotEmpty
          ? (green_in_regulation.reduce((a, b) => a + b) / green_in_regulation.length)
              .toStringAsFixed(2)
          : 'No data';
      greenInRegOnFairwayAvg = green_in_regulation_on.isNotEmpty
          ? (green_in_regulation_on.reduce((a, b) => a + b) / green_in_regulation_on.length)
              .toStringAsFixed(2)
          : 'No data';
      birdieConversionAvg = birdie_conversion.isNotEmpty
          ? (birdie_conversion.reduce((a, b) => a + b) / birdie_conversion.length)
              .toStringAsFixed(2)
          : 'No data';
      puttsAvg = number_of_putts.isNotEmpty
          ? (number_of_putts.reduce((a, b) => a + b) / number_of_putts.length)
              .toStringAsFixed(2)
          : 'No data';
      threePuttsAvg = number_of_3putts.isNotEmpty
          ? (number_of_3putts.reduce((a, b) => a + b) / number_of_3putts.length)
              .toStringAsFixed(2)
          : 'No data';
      scramblingAttemptAvg = scrambling_attempt.isNotEmpty
          ? (scrambling_attempt.reduce((a, b) => a + b) / scrambling_attempt.length)
              .toStringAsFixed(2)
          : 'No data';
      scramblingAttemptBunkerAvg = scrambling_attempt_bunker.isNotEmpty
          ? (scrambling_attempt_bunker.reduce((a, b) => a + b) / scrambling_attempt_bunker.length)
              .toStringAsFixed(2)
          : 'No data';
    });
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.black12, width: 0.6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Golf Performance Data',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Prediction Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _predict,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: const Color.fromARGB(255, 171, 240, 167),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Predict"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: calculateAverages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Calculate Averages"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // --- Prediction Result ---
            if (result.isNotEmpty)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ),

            const SizedBox(height: 25),

            // --- Averages Section ---
            const Text(
              "Performance Averages",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            const SizedBox(height: 12),

            _buildStatCard('Average Score', averageScore),
            _buildStatCard('Average Drive Distance', averageDistance),
            _buildStatCard('Fairway Hit (%)', fairwayAvg),
            _buildStatCard('Green in Regulation (%)', greenInRegAvg),
            _buildStatCard('GIR on Fairway (%)', greenInRegOnFairwayAvg),
            _buildStatCard('Birdie Conversion (%)', birdieConversionAvg),
            _buildStatCard('Putts per Hole', puttsAvg),
            _buildStatCard('3-Putts Average', threePuttsAvg),
            _buildStatCard('Scrambling (%)', scramblingAttemptAvg),
            _buildStatCard('Scrambling (Bunker) (%)', scramblingAttemptBunkerAvg),

            const SizedBox(height: 30),

            const Text(
              "Logged Rounds",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            const SizedBox(height: 12),

            logs.isEmpty
                ? const Center(
                    child: Text(
                      'No log entries available.',
                      style:
                          TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: logs.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border:
                              Border.all(color: Colors.black12, width: 0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date: ${log["logDate"].substring(0, 16)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                          fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Score: ${log["Score"] ?? "-"}  |  Putts: ${log["# of Putts"] ?? "-"}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54),
                                    ),
                                  ]),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.black54, size: 20),
                                  onPressed: () {
                                    // Add edit dialog here
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () => _deleteLog(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

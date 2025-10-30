import 'dart:convert';
import 'package:app_v1/logs/swimming_logs.dart';
import 'package:flutter/material.dart';
import '../profile/profile.dart';
import '../evaluateYourLevel/initial_questions_golf.dart';
import '/route.dart';
import 'package:app_v1/logs/logging_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../unusedFiles/logging_display.dart';
import '../unusedFiles/logging_record_backup.dart';
import '../unusedFiles/sport_logs.dart';
import 'golf_data_backend.dart';

class MySportsScreenPage extends StatefulWidget {
  const MySportsScreenPage({super.key});

  @override
  State<MySportsScreenPage> createState() => _MySportsScreenPageState();
}

class _MySportsScreenPageState extends State<MySportsScreenPage> {
  List<String> sports = [];
  late String selectedSports = sports.isNotEmpty ? sports.first : '';
  double progressValue = 0.3;
  int _num_logs = 0;

  @override
  void initState() {
    super.initState();
    _loadInfo();
    _loadLogs();
  }

  Future<void> _loadInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.containsKey('sports')) sports = prefs.getStringList('sports')!;
      sports.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      selectedSports = prefs.getString('selected_sport') ??
          (sports.isNotEmpty ? sports.first : '');
    });
  }

  Future<void> _loadLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('sports')) {
      sports = prefs.getStringList('sports')!;
      for (var sport in sports) {
        String jsonlogs = prefs.getString(sport) ?? '{}';
        Map logs = jsonDecode(jsonlogs);
        _num_logs += logs.length;
      }
    }
  }

  Future<void> saveUserSports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_sport', selectedSports);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "My Sports",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Summary Row ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard(
                  title: "Logs Recorded",
                  value: _num_logs.toString(),
                  color: const Color.fromARGB(255, 172, 225, 236),
                ),
                SizedBox(width: 10),
                _buildActionCard(
                  title: "Add Log",
                  subtitle: "Record new session",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoggingRecordPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- Section Title ---
            const Text(
              "Sports Logs",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // --- List of Sports ---
            Expanded(
              child: ListView.builder(
                itemCount: sports.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black, width: 3.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      title: Text(
                        sports[index],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.black87,
                        size: 20,
                      ),
                      onTap: () {
                        selectedSports = sports[index];
                        saveUserSports();

                        if (selectedSports == 'Golf') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const GolfDataBackendPage()),
                          );
                        } else if (selectedSports == 'Swimming') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SwimmingLogsPage()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const GolfDataBackendPage()),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Reusable Summary Card (e.g., Logs Recorded) ---
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Reusable Action Card (Add Log) ---
  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Add Log",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color.fromARGB(255, 223, 111, 111)
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

import 'package:app_v1/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'question_long_choice.dart';

class QuestionLongTestPage extends StatefulWidget {
  const QuestionLongTestPage({super.key});

  @override
  State<QuestionLongTestPage> createState() => _QuestionLongTestPageState();
}

class _QuestionLongTestPageState extends State<QuestionLongTestPage> {
  final List<Map<String, String>> data = [
    {"Category": "Muscular Strength", "Test/Measurement": "Max Bench Press (lbs)"},
    {"Category": "Muscular Endurance", "Test/Measurement": "Push-Up Test"},
    {"Category": "", "Test/Measurement": "Sit-Up Test (1 min)"},
    {"Category": "", "Test/Measurement": "Planks Test"},
    {"Category": "Muscular Power", "Test/Measurement": "Vertical Jump Height"},
    {"Category": "Agility", "Test/Measurement": "100 Meter Sprint"},
    {"Category": "", "Test/Measurement": "400 Meter Time"},
    {"Category": "", "Test/Measurement": "1 Mile Run"},
    {"Category": "Flexibility", "Test/Measurement": "Sit and Reach Test"},
    {"Category": "Reaction Time Test", "Test/Measurement": "Hand Reaction Time"},
  ];

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, List<Map<String, String>>> _groupedData = {};
  final Color themeColor = const Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    for (var row in data) {
      _controllers[row['Test/Measurement']!] = TextEditingController();
    }

    for (var row in data) {
      final category = row['Category']!.isEmpty ? "Other" : row['Category']!;
      _groupedData.putIfAbsent(category, () => []);
      _groupedData[category]!.add(row);
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> testList = data.map((e) => e['Test/Measurement']!).toList();
    List<String> inputList = _controllers.values.map((c) => c.text).toList();

    await prefs.setStringList('Long Test', testList);
    await prefs.setStringList('Long Test Input', inputList);
    await prefs.setBool('Long Test Check', true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Results saved successfully!"),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInstructions(BuildContext context, String test) {
    final Map<String, String> instructions = {
      "Max Bench Press (lbs)": "Record your maximum single-rep bench press weight.",
      "Push-Up Test": "Perform as many push-ups as possible without resting.",
      "Sit-Up Test (1 min)": "Count how many sit-ups you can complete in one minute.",
      "Planks Test": "Hold a proper plank position for as long as possible.",
      "Vertical Jump Height": "Measure your maximum jump height difference from standing reach.",
      "100 Meter Sprint": "Record your best time for a 100m sprint.",
      "400 Meter Time": "Run 400m and record your time.",
      "1 Mile Run": "Run one mile and record the total time.",
      "Sit and Reach Test": "Measure how far beyond your toes you can reach while seated.",
      "Hand Reaction Time": "Use an online or physical test to measure your reaction time.",
    };

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Instructions",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(instructions[test] ?? "No instructions available."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF90CAF9);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Physical Test",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 10),
              ..._groupedData.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.0),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: ExpansionTile(
                    iconColor: Colors.black54,
                    collapsedIconColor: Colors.black54,
                    tilePadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    title: Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    children: entry.value.map((row) {
                      final label = row['Test/Measurement']!;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: borderColor.withOpacity(0.4), width: 1),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info_outline_rounded,
                                      size: 20, color: Colors.grey),
                                  onPressed: () =>
                                      _showInstructions(context, label),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _controllers[label],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "Enter result",
                                hintStyle: const TextStyle(
                                    color: Colors.black38, fontSize: 14),
                                filled: true,
                                fillColor: themeColor.withOpacity(0.5),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 10),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: borderColor.withOpacity(0.4),
                                      width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: borderColor, width: 1.5),
                                ),
                              ),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
              const SizedBox(height: 25),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveData,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    "Save Results",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: borderColor,
                    foregroundColor: Colors.black,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        side: BorderSide(color: borderColor, width: 1.5)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

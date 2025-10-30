import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:app_v1/logs/sports_data.dart';

class LoggingRecordPage extends StatefulWidget {
  const LoggingRecordPage({super.key});

  @override
  State<LoggingRecordPage> createState() => _LoggingRecordPageState();
}

class _LoggingRecordPageState extends State<LoggingRecordPage>
    with SingleTickerProviderStateMixin {
  String selectedSport = 'Golf';
  String selectedSwimmingStyle = '';
  Map<String, TextEditingController> textcontroller = {};

  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _initializeTextControllers();
  }

  void _initializeTextControllers() {
    for (var field in sportsFields[selectedSport]!) {
      textcontroller[field] = TextEditingController();
    }
  }

  Future<void> saveLog() async {
    await addGolfLog();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log Added Successfully!'),
        backgroundColor: Colors.black87,
      ),
    );
  }

  Future<void> addGolfLog() async {
    DateTime date = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = {};

    String jsonLog = prefs.getString(selectedSport) ?? '{}';
    dynamic decodedLog = jsonDecode(jsonLog);
    Map<String, dynamic> logs = {};

    if (decodedLog is Map) {
      logs = Map<String, dynamic>.from(decodedLog);
    }

    for (var field in sportsFields[selectedSport]!) {
      data[field] = textcontroller[field]!.text;
    }

    logs[date.toString()] = data;
    prefs.setString(selectedSport, jsonEncode(logs));
  }

  @override
  void dispose() {
    for (var c in textcontroller.values) {
      c.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Add Log',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage("assets/sports_background9.jpg"),
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
          Container(
            color: Colors.white,
          ),
          // Main Content
          FadeTransition(
            opacity: _fadeIn,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 55,),
                  _buildDropdownContainer(
                    width,
                    label: "Select Sport",
                    value: selectedSport,
                    items: sportsFields.keys.toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSport = value!;
                        selectedSwimmingStyle = '';
                        _initializeTextControllers();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (selectedSport == 'Swimming')
                    _buildDropdownContainer(
                      width,
                      label: "Select Swimming Style",
                      value: selectedSwimmingStyle.isEmpty
                          ? null
                          : selectedSwimmingStyle,
                      items: swimmingStyles,
                      onChanged: (value) {
                        setState(() {
                          selectedSwimmingStyle = value!;
                        });
                      },
                    ),
                  const SizedBox(height: 25),
                  _buildInputCard(),
                  const SizedBox(height: 40),
                  _buildAddButton(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownContainer(double width,
      {required String label,
      required String? value,
      required List<String> items,
      required Function(String?) onChanged}) {
    return Container(
      width: width * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
         border: Border.all(
            color: Colors.black,
            width: 2.5,
          ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(label, style: const TextStyle(color: Colors.black54)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Color.fromARGB(255, 174, 75, 75)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 235, 235, 235).withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: sportsFields[selectedSport]!.map((field) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: textcontroller[field],
              decoration: InputDecoration(
                labelText: field,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.black, width: 1.4),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 0, 0, 0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: saveLog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: const Text(
          "Add Log",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

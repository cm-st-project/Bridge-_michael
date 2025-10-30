import 'package:flutter/material.dart';
import '../profile/profile.dart';
import 'initial_questions_golf.dart';
import 'package:app_v1/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_v1/Setting_Buttons/sports_setting.dart';
import '../constants.dart';

class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key});

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  List<String>? sportsTC = [];
  String? _choice;
  String? _level;

  Future<void> loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sportsTC = prefs.getStringList('sports');
    });
  }

  Future<void> saveUserSports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selected_sport1', _choice ?? '');
    prefs.setString('selected_level', _level ?? '');
  }

  Future<void> PageAdvanced() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("SelectionPageChoice", _choice!);
    prefs.setString("SelectionPageLevel", _level!);
  }

  Future<bool> hasSports() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('sports');
  }

  void _showAlertDialogue() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please Update Your Settings'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SportsSettingPage()))
                          .then((value) {
                        loadUserInfo();
                        Navigator.pop(context);
                      });
                    },
                    child: const Text(
                      "You need to select a sport.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    hasSports().then((value) {
      if (value) {
        loadUserInfo();
      } else {
        _showAlertDialogue();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Evaluate Your Level",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Personalize your performance insights",
                  style: TextStyle(
                    color:  Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- Sport Selection Card ---
              _buildCard(
                title: "Select Your Sport",
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color.fromARGB(31, 98, 185, 219)),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  hint: Text(
                    _choice ?? "Choose a sport",
                    style: TextStyle(
                        fontSize: 15, color:  Color.fromARGB(255, 117, 202, 232), fontWeight: FontWeight.w500),
                  ),
                  items: sportsTC?.map((String value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _choice = val);
                  },
                ),
              ),

              const SizedBox(height: 20),

              // --- Level Selection Card ---
              _buildCard(
                title: "Select Your Level",
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  hint: Text(
                    _level ?? "Choose your level",
                    style: TextStyle(
                        fontSize: 15, color:  Color.fromARGB(255, 117, 202, 232), fontWeight: FontWeight.w500),
                  ),
                  items: ["Beginner", "Intermediate", "Advanced"]
                      .map((String value) => DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _level = val);
                  },
                ),
              ),

              const SizedBox(height: 40),

              // --- Next Button ---
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_choice == null || _level == null) {
                      _showValidationDialog(context);
                    } else {
                      PageAdvanced();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const InitialQuestionsGolfPage()),
                      );
                      saveUserSports();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(250, 55),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Card Builder ---
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
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
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // --- Validation Alert ---
  void _showValidationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Please Select Your Sport and Level',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Make sure both fields are filled before continuing.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

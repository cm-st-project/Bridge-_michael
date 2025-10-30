import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenderSettingPage extends StatefulWidget {
  const GenderSettingPage({super.key});

  @override
  State<GenderSettingPage> createState() => _GenderSettingPageState();
}

class _GenderSettingPageState extends State<GenderSettingPage> {
  final List<String> genders = ["Male", "Female", "Others"];
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGender = prefs.getString('selected_gender') ?? genders.first;
    });
  }

  Future<void> _saveUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_gender', selectedGender!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Gender updated successfully!"),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Edit Gender",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/sports_background24.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.55)),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select your gender",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "This helps us personalize your training and recommendations.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Gender dropdown inside card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedGender,
                      dropdownColor: Colors.white,
                      decoration: const InputDecoration(
                        labelText: "Gender",
                        labelStyle: TextStyle(color: Colors.black54),
                        prefixIcon: Icon(Icons.person_outline, color: Colors.black),
                        border: InputBorder.none,
                      ),
                      items: genders
                          .map((String gender) => DropdownMenuItem<String>(
                                value: gender,
                                child: Text(
                                  gender,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedGender = newValue!;
                        });
                      },
                    ),
                  ),

                  const Spacer(),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: selectedGender == null ? null : _saveUserInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        shadowColor: Colors.white30,
                        elevation: 4,
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

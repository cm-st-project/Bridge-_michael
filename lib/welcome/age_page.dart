import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../route.dart';
import 'welcome_page.dart';
import 'height_weight_page.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

class AgePage extends StatefulWidget {
  const AgePage({super.key});
  @override
  State<AgePage> createState() => _AgePageState();
}

int selectedAge = 6;
final List<int> ages = List.generate(35, (i) => i + 6);

class _AgePageState extends State<AgePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('Age', selectedAge);
    await prefs.setBool('welcomeCompleted', true);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HeightWeightPage(),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surface;
    final fg = theme.colorScheme.onSurface;
    final muted = fg.withOpacity(.6);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Top Section ---
                // --- Top Section ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (true)
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon:
                                const Icon(Icons.arrow_back_ios_new, size: 20),
                            padding: EdgeInsets.only(right: 40),
                            constraints: const BoxConstraints(),
                          ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: 0.17,
                              minHeight: 3,
                              backgroundColor: fg.withOpacity(.08),
                              valueColor: AlwaysStoppedAnimation<Color>(fg),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "What is your age",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Enter your age to provide accurate sport recommendations.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 17),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),

                // --- Middle Input Field ---
                SizedBox(
                  height: 200,
                  child: CupertinoPicker(
                    backgroundColor: Colors.white,
                    itemExtent: 40,
                    selectionOverlay: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.black, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 0.05, sigmaY: 0.05),
                          child: Container(
                            color: Colors.white
                                .withOpacity(0.1), // semi-transparent glass
                          ),
                        ),
                      ),
                    ),
                    scrollController:
                        FixedExtentScrollController(initialItem: 2),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedAge = ages[index];
                      });
                    },
                    children: ages
                        .map(
                          (age) => Center(
                            child: Text(
                              age.toString(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SizedBox(
                  height: 85,
                ),

                // --- Bottom Button ---
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _continue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // ← button background
                      foregroundColor: Colors.white, // ← text/icon color
                      disabledBackgroundColor: Colors.black, // optional
                      disabledForegroundColor: Colors.white, // optional
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // ← ensures white text explicitly
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

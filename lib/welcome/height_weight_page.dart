import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'age_page.dart';
import 'gender_page.dart';

class HeightWeightPage extends StatefulWidget {
  const HeightWeightPage({super.key});

  @override
  State<HeightWeightPage> createState() => _HeightWeightPageState();
}

class _HeightWeightPageState extends State<HeightWeightPage> {
  int selectedFeet = 5;
  int selectedInches = 6;
  int selectedWeight = 150;

  final List<int> feetList = List.generate(4, (i) => i + 4); // 4–7 ft
  final List<int> inchList = List.generate(12, (i) => i); // 0–11 in
  final List<int> weightList = List.generate(251, (i) => i + 50); // 50–300 lb

  Future<void> _continue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('HeightFeet', selectedFeet);
    await prefs.setInt('HeightInches', selectedInches);
    await prefs.setInt('Weight', selectedWeight);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GenderPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical -
                  62, // top and bottom padding
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Top Section ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                            padding: EdgeInsets.zero,
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: 0.5,
                                minHeight: 3,
                                backgroundColor: fg.withOpacity(.08),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(fg),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Height & weight",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "This will help personalize your sport recommendations.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),

                  // --- Summary Display ---
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        "$selectedFeet ft $selectedInches in • $selectedWeight lb",
                        key: ValueKey<String>(
                            "$selectedFeet-$selectedInches-$selectedWeight"),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- Middle Picker Section ---
                  SizedBox(
                    height: 160,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            backgroundColor: Colors.white,
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                              initialItem: feetList.indexOf(selectedFeet),
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedFeet = feetList[index];
                              });
                            },
                            children: feetList
                                .map((ft) => Center(
                                      child: Text(
                                        "$ft ft",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            backgroundColor: Colors.white,
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                              initialItem: inchList.indexOf(selectedInches),
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedInches = inchList[index];
                              });
                            },
                            children: inchList
                                .map((inch) => Center(
                                      child: Text(
                                        "$inch in",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            backgroundColor: Colors.white,
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                              initialItem: weightList.indexOf(selectedWeight),
                            ),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                selectedWeight = weightList[index];
                              });
                            },
                            children: weightList
                                .map((w) => Center(
                                      child: Text(
                                        "$w lb",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),

                  // --- Bottom Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:app_v1/welcome/summary_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_v1/setting.dart';

class SportPage extends StatefulWidget {
  const SportPage({super.key});

  @override
  State<SportPage> createState() => _SportPageState();
}

class _SportPageState extends State<SportPage> {
  final Set<String> selectedSports = {}; // can hold multiple
  final List<Map<String, String>> sports = [
    // {"name": "Basketball", "emoji": "🏀"},
    {"name": "Soccer", "emoji": "⚽️"},
    {"name": "Golf", "emoji": "⛳️"},
    // {"name": "Tennis", "emoji": "🎾"},
    // {"name": "Track & Field", "emoji": "🏃‍♂️"},
    // {"name": "Baseball", "emoji": "⚾️"},
    {"name": "Swimming", "emoji": "🏊‍♂️"},
    {"name": "Other", "emoji": ""}
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedSports();
  }

  Future<void> _loadSelectedSports() async {
    final prefs = await SharedPreferences.getInstance();
    final existingSports = prefs.getStringList('sports') ?? [];
    setState(() {
      selectedSports.addAll(existingSports);
    });
  }

  Future<void> _saveSports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('sports', selectedSports.toList());
  }

  Future<void> _continue() async {
    if (selectedSports.isEmpty) return;
    await _saveSports();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SummaryPage()),
    );
  }

  Widget sportButton(String sportText, String emoji) {
    final isSelected = selectedSports.contains(sportText);
    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) {
          selectedSports.remove(sportText);
        } else {
          selectedSports.add(sportText);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(sportText),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.check, color: Colors.white, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Progress & Back
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
                        value: 0.83,
                        minHeight: 3,
                        backgroundColor: fg.withOpacity(.08),
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title & Subtitle
              Text(
                "Select your sports",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Choose any sports you play",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 60),

              // Sport Buttons
              Expanded(
                child: ListView.builder(
                  itemCount: sports.length,
                  itemBuilder: (context, index) {
                    final sport = sports[index];
                    return sportButton(sport['name']!, sport['emoji']!);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedSports.isEmpty ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    selectedSports.isEmpty
                        ? "Save"
                        : "Save (${selectedSports.length} selected)",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

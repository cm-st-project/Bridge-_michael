import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SportsSettingPage extends StatefulWidget {
  const SportsSettingPage({super.key});

  @override
  State<SportsSettingPage> createState() => _SportsSettingPageState();
}

class _SportsSettingPageState extends State<SportsSettingPage> {
  final Set<String> selectedSports = {};
  final List<Map<String, String>> sports = [
    {"name": "Basketball", "emoji": "🏀"},
    {"name": "Soccer", "emoji": "⚽️"},
    {"name": "Golf", "emoji": "⛳️"},
    {"name": "Tennis", "emoji": "🎾"},
    {"name": "Track & Field", "emoji": "🏃‍♂️"},
    {"name": "Baseball", "emoji": "⚾️"},
    {"name": "Swimming", "emoji": "🏊‍♂️"},
  ];

  bool _loading = true;

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
      _loading = false;
    });
  }

  Future<void> _saveSports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('sports', selectedSports.toList());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sports updated successfully!"),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
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
          border: Border.all(color: Colors.black, width: 2.5),
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
      appBar: AppBar(
        title: const Text("Edit Sports"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select the sports you play",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Your selection helps us tailor recommendations and logs.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Sport list
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

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _saveSports,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: Text(
                          "Save (${selectedSports.length} selected)",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
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

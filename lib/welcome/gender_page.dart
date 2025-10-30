import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'info_page.dart';

// import 'activity_level_page.dart'; // TODO: Create this next

class GenderPage extends StatefulWidget {
  const GenderPage({super.key});

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  String? selectedGender;

  Future<void> _continue() async {
    if (selectedGender == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Gender', selectedGender!);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InfoPage()),
    );
  }

  Widget genderButton(String genderText) {
    final isSelected = selectedGender == genderText;
    return GestureDetector(
      onTap: () => setState(() => selectedGender = genderText),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
                    color: Colors.black.withOpacity(0),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
            child: Text(genderText),
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
                        value: 0.34,
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
                "Choose your Gender",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "This will be used to calibrate your custom plan.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 140),

              // Gender Buttons
              genderButton("Male"),
              genderButton("Female"),
              genderButton("Other"),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: selectedGender == null ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16),
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

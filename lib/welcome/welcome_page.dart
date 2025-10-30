import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../route.dart';
import 'age_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Name', _nameCtrl.text.trim());
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgePage(),
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
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
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
                              value: 0.0,
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
                      "Welcome",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "What is your name?",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "We’ll personalize your experience. You can change this later in Profile.",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                            color: Colors.black, 
                            fontSize: 16,
                            ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),

                // --- Middle Input Field ---
                TextFormField(
                  controller: _nameCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Your name',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600, // ← sets hint text color
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200, // lighter background
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 24, // controls height
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter a name'
                      : null,
                ),
                SizedBox(
                  height: 35,
                ),

                // --- Bottom Button ---
                SizedBox(
                  width: double.infinity,
                  height: 56,
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

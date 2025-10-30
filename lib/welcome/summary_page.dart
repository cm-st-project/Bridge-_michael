import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_v1/home.dart';
import 'package:app_v1/route.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  AnimationController? _heartbeatController;
  AnimationController? _dotController;
  Animation<double>? _fadeIn;
  Animation<double>? _heartbeat;
  Map<String, dynamic> userData = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _fadeIn = CurvedAnimation(parent: _controller!, curve: Curves.easeInOut);

    _heartbeat = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _heartbeatController!, curve: Curves.easeInOut),
    );

    _initialized = true;
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = {
        "Name": prefs.getString('Name') ?? "—",
        "Age": prefs.getInt('Age')?.toString() ?? "—",
        "Gender": prefs.getString('Gender') ?? "—",
      };
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _heartbeatController?.dispose();
    _dotController?.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.black),
      ),
    );

    // Save "welcomeCompleted = true"
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('welcomeCompleted', false);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pop(context); // remove loading dialog

    // Navigate to main home page and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RoutePage()),
      (route) => false,
    );
  }

  Widget loadingDots() {
    if (_dotController == null) return const SizedBox();
    return AnimatedBuilder(
      animation: _dotController!,
      builder: (_, __) {
        int active = (_dotController!.value * 3).floor() % 3;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == active ? Colors.black : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    final theme = Theme.of(context);
    final fg = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Progress bar
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: 1.0,
                        minHeight: 3,
                        backgroundColor: fg.withOpacity(.08),
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // Animated glowing circle
              AnimatedBuilder(
                animation: _controller!,
                builder: (_, __) {
                  return Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          const Color.fromARGB(255, 126, 168, 234)
                              .withOpacity(0.4 + 0.3 * _controller!.value),
                          const Color.fromARGB(255, 107, 226, 247).withOpacity(
                              0.4 + 0.3 * (1 - _controller!.value)),
                        ],
                      ),
                    ),
                    child: Center(
                      child: ScaleTransition(
                        scale: _heartbeat!,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.favorite_rounded,
                              color: Colors.redAccent,
                              size: 54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              const Text(
                "Time to Perform",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              loadingDots(),
              const SizedBox(height: 30),

              // Frosted summary
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: userData.entries
                      .map((e) => Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: Colors.black, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  e.key,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  e.value.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 30),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    "Finish",
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

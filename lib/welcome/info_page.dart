import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sports_page.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation =
        CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic);
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('infoPageCompleted', true);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SportPage()), // replace with next page
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top Bar & Progress ---
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
                        value: 0.67,
                        minHeight: 3,
                        backgroundColor: fg.withOpacity(.08),
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Title ---
              Text(
                "Track your performance",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Data-driven insights help to improve your performance over time.",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 60),

              // --- Graph Section ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, // pure white background
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: Colors.black, width: 3), // bold black border
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your performance",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_animation != null)
                      AnimatedBuilder(
                        animation: _animation!,
                        builder: (_, __) => AspectRatio(
                          aspectRatio: 1.6,
                          child: CustomPaint(
                            painter:
                                _PerformanceGraphPainter(_animation!.value),
                          ),
                        ),
                      )
                    else
                      const SizedBox(
                        height: 150,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),

              const Spacer(),

              // --- Continue Button ---
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

// --- Custom Graph Painter ---
class _PerformanceGraphPainter extends CustomPainter {
  final double progress;
  _PerformanceGraphPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint perfPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, 0),
        [Colors.black87, Colors.black],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final Paint avgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, 0),
        [Colors.blue.shade200, Colors.blueAccent],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final Paint bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [Colors.white, Colors.grey.shade200],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      bgPaint,
    );

    final pathPerf = Path();
    final pathAvg = Path();

    pathPerf.moveTo(0, size.height * 0.8);
    pathPerf.cubicTo(
      size.width * 0.3 * progress,
      size.height * 0.7,
      size.width * 0.6 * progress,
      size.height * 0.4,
      size.width * progress,
      size.height * 0.25,
    );

    pathAvg.moveTo(0, size.height * 0.5);
    pathAvg.cubicTo(
      size.width * 0.2 * progress,
      size.height * 0.35,
      size.width * 0.6 * progress,
      size.height * 0.8,
      size.width * progress,
      size.height * 0.45,
    );

    canvas.drawPath(pathAvg, avgPaint);
    canvas.drawPath(pathPerf, perfPaint);

    final pointPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(0, size.height * 0.8), 4, pointPaint);
    canvas.drawCircle(
        Offset(size.width * progress, size.height * 0.25), 4, pointPaint);

    final textPainter1 = TextPainter(
      text: const TextSpan(
        text: "Your performance",
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textPainter2 = TextPainter(
      text: const TextSpan(
        text: "Average athlete",
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.blueAccent),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter1.paint(canvas, Offset(size.width * 0.6, size.height * 0.22));
    textPainter2.paint(canvas, Offset(size.width * 0.6, size.height * 0.46));

    final monthStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    final tp1 = TextPainter(
        text: TextSpan(text: " ", style: monthStyle),
        textDirection: TextDirection.ltr)
      ..layout();
    final tp2 = TextPainter(
        text: TextSpan(text: " ", style: monthStyle),
        textDirection: TextDirection.ltr)
      ..layout();
    tp1.paint(canvas, Offset(0, size.height - 20));
    tp2.paint(canvas, Offset(size.width - tp2.width, size.height - 20));
  }

  @override
  bool shouldRepaint(covariant _PerformanceGraphPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

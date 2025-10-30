import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import 'dart:async';

class QuestionLongOtherPage extends StatefulWidget {
  const QuestionLongOtherPage({super.key});

  @override
  State<QuestionLongOtherPage> createState() => _QuestionLongOtherPageState();
}

class _QuestionLongOtherPageState extends State<QuestionLongOtherPage>
    with SingleTickerProviderStateMixin {
  late final OpenAI _openAI;
  String? GPTresponse;
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  List<String> questions = [
    "Do you have any chronic health conditions that impact your ability to participate in sports?",
    "How easy is it for you to access sports facilities or gyms in your area?",
    "How accessible is sports training or coaching in your location?",
    "How would you rate your living environment in terms of supporting your sports activities, on a scale of 1 to 10?",
    "How does your current living condition affect your ability to train regularly?",
    "Do you receive regular physiotherapy or medical support for sports-related issues?",
    "Do you prefer participating in individual sports or team sports?",
    "Do you prefer engaging in competitive sports or recreational activities?",
    "Do you prefer physical contact in your preferred sport or activity?",
    "Do you prefer indoor or outdoor sports?",
    "Do you prefer a competitive environment?",
    "Do you enjoy sports that require a high level of technical skill or strategy?",
    "Do you prefer sports that emphasize endurance or physical strength?",
    "How important is the social aspect of the sport to you, such as teamwork or communication?",
    "How significant is the popularity of the sport in your decision to pursue it?"
    // "How often do you participate in competitive sports events or matches?", 
    //// "How many opportunities do you have to progress to higher levels of competition?", 
    ///// "How would you rate your exposure to global sports competition on a scale of 1 to 10?", 
    ///// "How easy is it for you to secure funding or financial support for your training?", 
    ///// "How well do you manage to balance sports training with other life priorities?", 
    ///// "How consistent is your training routine over time, on a scale of 1 to 10?", 
    //// "How much support do you receive in terms of resources or facilities for training?",
  ];

  List<TextEditingController> answersController = [];

  void _initializeControllers() {
    answersController =
        List.generate(questions.length, (index) => TextEditingController());
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('Long Other', questions);
    await prefs.setStringList(
        'Long Other Input',
        answersController.map((controller) => controller.text).toList());
    await prefs.setBool('Long Other Check', true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Responses saved successfully!"),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var c in answersController) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primary = const Color(0xFF9ED6FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Preferences & Conditions',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.4,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: !isLoading
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: questions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Question ${index + 1}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  questions[index],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                      height: 1.3),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: answersController[index],
                                  decoration: InputDecoration(
                                    hintText: "Type your answer...",
                                    hintStyle: const TextStyle(
                                        color: Colors.black38, fontSize: 14),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: primary, width: 1.4),
                                    ),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32)),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text("Save Responses"),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.black,
                  ),
                ),
        ),
      ),
    );
  }
}

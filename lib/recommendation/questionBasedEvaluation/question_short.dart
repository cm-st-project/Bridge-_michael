import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'question_short_display.dart';

class QuestionShortPage extends StatefulWidget {
  const QuestionShortPage({super.key});

  @override
  State<QuestionShortPage> createState() => _QuestionShortPageState();
}

class _QuestionShortPageState extends State<QuestionShortPage>
    with SingleTickerProviderStateMixin {
  late final OpenAI _openAI;
  String? GPTresponse;
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  List<String> questions = [
    "How would you rate your muscle definition on a scale of 1 to 10, with 10 being very defined?",
    "What is your height in feet and inches?",
    "What is your current weight in pounds?",
    "How would you describe your ability to quickly change direction while running or moving?", 
    // "How would you rate your hand-eye coordination on a scale of 1 to 10, with 10 being excellent?", 
    //// "How would you rate your overall speed and agility on a scale of 1 to 10, with 10 being very fast and agile?", 
    ///// "How well can you maintain balance while moving or performing complex tasks?", 
    ///// "How quickly can you react to sudden changes or surprises, on a scale of 1 to 10?", 
    ///// "How would you rate your ability to track and follow moving objects, such as a ball or a runner, on a scale of 1 to 10?",
    /// // "How would you describe your overall cardiovascular endurance?", 
    /// // "How would you rate your ability to stay focused on a single task or goal without getting distracted, on a scale of 1 to 10?", 
    /// // "How would you rate your ability to quickly adapt to new skills or techniques on a scale of 1 to 10?", 
    /// // "How would you describe your overall strength compared to others your age?", 
    /// // "How would you rate your range of motion in your joints on a scale of 1 to 10, with 10 being very flexible?", 
    /// // "How would you describe your ability to control and coordinate fine movements, such as typing or playing a musical instrument?", 
    /// // "How would you rate your overall muscular strength on a scale of 1 to 10, with 10 being very strong?", 
    /// // "How well do you handle intense physical activity or exercise without getting tired quickly?", 
    /// // "How stable are your joints during physical activities, on a scale of 1 to 10, with 10 being very stable?",
    ///  // "How would you rate your aerobic capacity (endurance in activities like running or swimming) on a scale of 1 to 10?", 
    /// // "How would you rate your anaerobic threshold (ability to perform high-intensity activities) on a scale of 1 to 10?", 
    /// // "How would you rate your resilience (ability to bounce back from setbacks) on a scale of 1 to 10?", 
    /// // "How do you handle pressure during important events or competitions?", 
    /// // "How confident are you in your abilities when performing in front of others, on a scale of 1 to 10?", 
    /// // "How motivated are you to achieve your sports goals, on a scale of 1 to 10?",
    ///  // "How committed are you to your training routine, on a scale of 1 to 10?", 
    /// // "How well do you set and follow through with goals, on a scale of 1 to 10?", 
    /// // "How would you rate your ability to stay focused during training and competition, on a scale of 1 to 10?", 
    /// "How well do you prepare mentally before a competition or important event, on a scale of 1 to 10?", 
    /// "How do you manage distractions or interruptions during performance or training?", 
    /// "How would you rate your perseverance in overcoming challenges or difficulties in sports, on a scale of 1 to 10?", 
    /// "How quickly do you pick up new techniques or skills in sports or physical activities, on a scale of 1 to 10?", 
    /// "How often do you consume a balanced diet that supports your physical activities?", 
    /// "How well do you manage injury risks and recovery from injuries?", 
    /// // "How would you rate your current fitness level on a scale of 1 to 10?", 
    /// // "How do chronic health conditions impact your ability to participate in sports?", 
    /// // "How well do you understand the nutritional needs of your body for optimal performance?", 
    /// // "How easy is it for you to access sports facilities or gyms in your area?", 
    /// // "How accessible is sports training or coaching in your location?", 
    /// // "How would you rate your living environment in terms of supporting your sports activities, on a scale of 1 to 10?",
    ///  // "How does your current living condition affect your ability to train regularly?", 
    /// // "How supportive is your living situation for pursuing sports development opportunities?", 
    /// // "Do you have access to a sports psychologist or mental health support for athletes?", 
    /// // "Do you receive regular physiotherapy or medical support for sports-related issues?", 
    /// // "How often do you participate in competitive sports events or matches?", 
    /// // "How many opportunities do you have to progress to higher levels of competition?", 
    /// // "How would you rate your exposure to global sports competition on a scale of 1 to 10?", 
    /// // "How easy is it for you to secure funding or financial support for your training?", 
    /// // "How well do you manage to balance sports training with other life priorities?",
    ///  // "How consistent is your training routine over time, on a scale of 1 to 10?",
    ///  // "How much support do you receive in terms of resources or facilities for training?",
    ///  // "Do you prefer participating in individual sports or team sports?", 
    /// // "Do you prefer engaging in competitive sports or recreational activities?", 
    /// // "How important is physical contact in your preferred sport or activity?", 
    /// "Do you prefer indoor or outdoor sports?", 
    /// "How important is having access to a competitive environment for you?", 
    /// "Do you enjoy sports that require a high level of technical skill or strategy?", 
    /// "Do you prefer sports that emphasize endurance or physical strength?", 
    /// "How important is the social aspect of the sport to you, such as teamwork or communication?", 
    /// "How significant is the popularity of the sport in your decision to pursue it?"
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
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    for (var c in answersController) {
      c.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  List<String> getAnswers() {
    return answersController
        .map((controller) => controller.text.trim())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    int answeredCount = answersController
        .where((controller) => controller.text.trim().isNotEmpty)
        .length;
    double progress = answeredCount / questions.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Quick Evaluation",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.black,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "$answeredCount of ${questions.length} questions answered",
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),

              // Questions List
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
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
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            questions[index],
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: answersController[index],
                            decoration: InputDecoration(
                              hintText: "Type your answer...",
                              hintStyle: const TextStyle(
                                  color: Colors.black38, fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.black12, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.black, width: 1.2),
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

              const SizedBox(height: 12),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          List<String> savedAnswers = getAnswers();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionShortDisplayPage(
                                questions: questions,
                                answers: savedAnswers,
                              ),
                            ),
                          ).then((value) => Navigator.pop(context));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Get Suggestion",
                          style: TextStyle(
                            fontSize: 16,
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

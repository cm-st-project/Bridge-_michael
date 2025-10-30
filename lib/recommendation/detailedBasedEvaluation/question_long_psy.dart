import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import 'dart:async';

class QuestionLongPsyPage extends StatefulWidget {
  const QuestionLongPsyPage({super.key});

  @override
  State<QuestionLongPsyPage> createState() => _QuestionLongPsyPageState();
}

class _QuestionLongPsyPageState extends State<QuestionLongPsyPage>
    with SingleTickerProviderStateMixin {
  late final OpenAI _openAI;
  String? GPTresponse;
  bool isLoading = false;

  List<String> questions = [
    // Section 1
    "I am able to adapt when changes occur.",
    "I can deal with whatever comes my way.",
    "I try to see the humorous side of things when I am faced with problems.",
    "Having to cope with stress can make me stronger.",
    "I tend to bounce back after illness, injury or other hardships.",
    "I believe I can achieve my goals, even if there are obstacles.",
    // Section 2
    "I remain positive and enthusiastic during competition, no matter how badly things are going.",
    "I stay calm and relaxed during competition.",
    "I can quickly bounce back from mistakes during competition.",
    "I keep my emotions under control, even when things are not going well.",
    "I perform well under pressure.",
    "I thrive on challenging situations during competition.",
    "I am at my best when the pressure is on.",
    "I set specific goals for myself to achieve during competition.",
    "I have a specific plan for how I want to achieve my goals in competition.",
    "I maintain focus on my goals during competition.",
    "I mentally prepare myself for each competition.",
    "I block out distractions and focus on what I am doing during competition.",
    "I am good at keeping my concentration on the competition.",
    "I do not worry about performing poorly.",
    "I do not get anxious before a competition.",
    "I am not concerned about others watching me during competition.",
    "I do not worry about making mistakes during competition.",
    "I feel confident in my ability to perform well during competition.",
    "I believe in my ability to reach my goals.",
    "I am willing to put in the time and effort to improve my skills.",
    "I accept constructive criticism from coaches.",
    "I am open to new techniques or strategies suggested by my coaches.",
    // Section 3
    // "I play sport for the pleasure I feel in living exciting experiences",
    // "I play sport because I used to have good reasons for doing it, but now I am asking myself if I should continue doing it",
    // "I play sport for the pleasure of discovering new training techniques",
    // "I have the impression of being incapable of succeeding in this sport",
    // "I play sport because it allows me to be well regarded by people that I know",
    // "I play sport to meet people",
    // "I play sport because I feel a lot of personal satisfaction while mastering certain difficult training techniques",
    // "I play sport because it is absolutely necessary to do sports if one wants to be in shape",
    // "I play sport for the prestige of being an athlete",
    // "I play sport for the pleasure I feel while improving some of my weak points",
    // "I play sport for the excitement I feel when I am really involved in the activity",
    // "I must do sports to feel good myself",
    // "I play sport because people around me think it is important to be in shape",
    // "I play sport because it is a good way to learn lots of things which could be useful to me in other areas of my life",
    // "I play sport for the intense emotions I feel doing a sport that I like",
    // "I play sport for the pleasure that I feel while executing certain difficult movements",
    // "I play sport because I would feel bad if I was not taking time to do it",
    // "I play sport to show others how good I am at my sport",
    // "I play sport because to maintain good relationships with my friends",
    // "I play sport because I like the feeling of being totally immersed in the activity",
  ];

  List<String> options = [
    "Not true at all.",
    "Rarely true.",
    "Sometimes true.",
    "Often true.",
    "True nearly all the time."
  ];

  late List<String?> selectedAnswers;

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(questions.length, null);
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('Long Psy', questions);
    await prefs.setStringList(
        'Long Psy Input',
        selectedAnswers
            .where((answer) => answer != null)
            .map((answer) => answer!)
            .toList());
    await prefs.setBool('Long Psy Check', true);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Responses saved successfully!"),
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Widget buildQuestionList(int start, int end) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: end - start,
      separatorBuilder: (_, __) => const Divider(height: 8, color: Colors.transparent),
      itemBuilder: (context, index) {
        int actualIndex = start + index;
        return Container(
          padding: const EdgeInsets.all(14),
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
                questions[actualIndex],
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedAnswers[actualIndex],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF81D4FA), width: 1.5),
                  ),
                ),
                hint: const Text("Select your answer"),
                onChanged: (value) {
                  setState(() {
                    selectedAnswers[actualIndex] = value;
                  });
                },
                items: options
                    .map((option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int section1End = 6;
    int section2End = section1End + 22;
    int section3End = questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Psychological Evaluation',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.4,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: !isLoading
            ? ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ExpansionTile(
                      title: const Text(
                        "Section 1: Resilience & Adaptability",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      children: [buildQuestionList(0, section1End)],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ExpansionTile(
                      title: const Text(
                        "Section 2: Competitive Mindset & Focus",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      children: [buildQuestionList(section1End, section2End)],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ExpansionTile(
                      title: const Text(
                        "Section 3: Motivation & Enjoyment in Sports",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      children: [buildQuestionList(section2End, section3End)],
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton.icon(
                    onPressed: _saveData,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text(
                      "Save Responses",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF81D4FA),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2.5,
                ),
              ),
      ),
    );
  }
}

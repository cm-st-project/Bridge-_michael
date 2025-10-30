import 'package:app_v1/constants.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'initial_questions_golf_display.dart';

class InitialQuestionsGolfPage extends StatefulWidget {
  const InitialQuestionsGolfPage({super.key});

  @override
  State<InitialQuestionsGolfPage> createState() =>
      _InitialQuestionsGolfPageState();
}

class _InitialQuestionsGolfPageState extends State<InitialQuestionsGolfPage> {
  late final OpenAI _openAI;
  String? GPTresponse;
  List<String> questions = [];
  List<TextEditingController> answersController = [];
  bool isLoading = true;

  Future<void> _handleInitialMessage() async {
    final prefs = await SharedPreferences.getInstance();
    String userPrompt =
        'I play ${prefs.getString('selected_sport1')}. I am a ${prefs.getString('selected_level')} athlete.';
    String instructionPrompt =
        "Can you ask me 4 questions based on my information that will help accurately determine my level and biggest weakness? Return only JSON like this: {questions: <list of questions>}.";

    final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {"role": "user", "content": userPrompt},
        {"role": "system", "content": instructionPrompt},
      ],
    );

    try {
      ChatCTResponse? response =
          await _openAI.onChatCompletion(request: request);
      String result = response!.choices.first.message!.content.trim();
      getQuestions(result);
    } catch (e) {
      print("Error: $e");
      showAlertDialogue(context);
    }
  }

  void getQuestions(String results) {
    setState(() {
      try {
        Map<String, dynamic> resultMap =
            Map<String, dynamic>.from(json.decode(results));
        questions = List<String>.from(resultMap['questions']);
        answersController =
            List.generate(questions.length, (_) => TextEditingController());
        isLoading = false;
      } catch (e) {
        print("JSON Parse Error: $e");
        showAlertDialogue(context);
      }
    });
  }

  List<String> getAnswers() =>
      answersController.map((controller) => controller.text).toList();

  Future<void> showAlertDialogue(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Error fetching questions"),
          content: const Text("Would you like to try again?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleInitialMessage();
              },
              child: const Text("Retry"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _openAI = OpenAI.instance.build(
      token: dotenv.env['OPENAI_API_KEY'],
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 30)),
    );
    _handleInitialMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Skill Evaluation",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: isLoading
          ? _buildLoadingScreen()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Answer a few quick questions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "This helps us understand your performance level and strengths.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Question Cards
                  ListView.builder(
                    itemCount: questions.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Q${index + 1}",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              questions[index],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: answersController[index],
                              decoration: InputDecoration(
                                hintText: "Type your answer here...",
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 25),

                  // Continue Button
                  ElevatedButton(
                    onPressed: () {
                      List<String> savedAnswers = getAnswers();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InitialQuestionsGolfDisplayPage(
                            questions: questions,
                            answers: savedAnswers,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }

  // --- Loading Screen with Progress Bar ---
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Setting up your custom evaluation...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey[300],
              color: Colors.black,
              minHeight: 5,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Analyzing your profile...",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

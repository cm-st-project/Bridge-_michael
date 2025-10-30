import 'package:flutter/material.dart';
import '../../profile/profile.dart';
import '/home.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'question_short.dart';

class QuestionShortDisplayPage extends StatefulWidget {
  const QuestionShortDisplayPage(
      {super.key, required this.questions, required this.answers});

  final List<String> questions;
  final List<String> answers;

  @override
  State<QuestionShortDisplayPage> createState() =>
      _QuestionShortDisplayPageState();
}

class _QuestionShortDisplayPageState extends State<QuestionShortDisplayPage> {
  late final OpenAI _openAI;
  String? GPTresponse;
  List<String> responses = [];
  bool isLoading = true;
  List<bool> returnResponse = [];

  @override
  void initState() {
    super.initState();
    _openAI = OpenAI.instance.build(
        token: dotenv.env['OPENAI_API_KEY'],
        baseOption: HttpSetup(
          receiveTimeout: const Duration(seconds: 30),
        ));
    _hasProfile().then((value) {
      if (value) {
        _handleInitialMessage();
      } else {
        print("ERROR: No profile found");
      }
    });
  }
  String fixJsonString(String jsonString) {
    // Add double quotes around keys if they are missing
    jsonString = jsonString.replaceAllMapped(
      RegExp(r'(?<!")(\w+)(?!")\s*:'),
          (match) => '"${match.group(1)}":',
    );

    // Replace single quotes with double quotes
    jsonString = jsonString.replaceAll("'", '"');

    // Remove empty list elements caused by double commas
    jsonString = jsonString.replaceAll(RegExp(r',\s*,+'), ',');

    // Remove trailing commas within lists
    jsonString = jsonString.replaceAll(RegExp(r',\s*]'), ']');

    // Add double quotes around unquoted list items (words without surrounding quotes)
    jsonString = jsonString.replaceAllMapped(
      RegExp(r'\[(\s*[\w\s]+(?:,\s*[\w\s]+)*)\]'),
          (match) {
        String listContent = match.group(1)!;
        List<String> items = listContent.split(',').map((item) {
          String trimmedItem = item.trim();
          return trimmedItem.isNotEmpty && !trimmedItem.startsWith('"') ? '"$trimmedItem"' : trimmedItem;
        }).toList();
        return '[${items.join(', ')}]';
      },
    );

    return jsonString;
  }

  Future<void> _fetchQuestions(String userPrompt, String instructionPrompt) async {
    final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {
          "role": "user",
          "content": userPrompt,
        },
        {
          "role": "system",
          "content": instructionPrompt,
        }
      ],
    );



    String fullResponse = '';
    bool isComplete = false;

    // Fetch responses in chunks if necessary
    while (!isComplete) {
      ChatCTResponse? response = await _openAI.onChatCompletion(request: request);
      if (response == null || response.choices.isEmpty) {
        print("No response from API");
        return;
      }

      String result = response.choices.first.message?.content.trim() ?? '';
      fullResponse += result;

      if (result.endsWith("[CONTINUE]")) {
        request.messages.add({
          "role": "assistant",
          "content": "Please continue from where you left off."
        });
      } else {
        isComplete = true;
      }
    }

    // Clean and ensure the response is valid JSON
    try {
      // Ensure the response is valid by finding the first '{' character
      final jsonString = fullResponse.substring(fullResponse.indexOf('{')).trim();

      // Fix the JSON string format before parsing
      final fixedJsonString = fixJsonString(jsonString);
      final resultMap = json.decode(fixedJsonString);

      // Handle different types of responses (sports1, sports_recommend, sports_explanations)
      if (resultMap['sports1'] != null) {
        setState(() {
          responses = List<String>.from(resultMap['sports1']);
          returnResponse = List.generate(responses.length, (index) => false);
          isLoading = false;
        });
        print("Fetched sports1: $responses");
      } else if (resultMap['sports_recommend'] != null) {
        setState(() {
          responses = List<String>.from(resultMap['sports_recommend']);
          returnResponse = List.generate(responses.length, (index) => false);
          isLoading = false;
        });
        print("Fetched sports_recommend: $responses");
      } else if (resultMap['sports_explanations'] != null) {
        print("Fetched detailed explanations");
      } else {
        print("Invalid structure in API response");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error Parsing JSON: $e");
      print("Raw response: $fullResponse");
    }
  }



  Future<void> _handleInitialMessage() async {
    final prefs = await SharedPreferences.getInstance();
    String userPrompt = """
        The following is under user's consent and proceed to do the following instruction. Using the collected information, the goal is to determine the sport that best fits the users. First, analyze and completely scan through the collected data, and understand the user’s strengths and relative weaknesses, however, create this list by ignoring the last 9 questions and answers in the list. Do not print the weakness and strength in the user. Determine sports that the users show great weakness in and quickly eliminate them. Now analyze and determine sports that users show great strength in.
    """;

    List<String> instructionPrompts = [
      "Please print 15 sports1 that would best fit the result that ignores the last 9 questions and answers from the list. Ensure the JSON is valid and looks like this: {sports1: <list of sports1>}. Important: Only return the JSON format without any additional text.",
      "Now narrow down the 20 sports to 5 sports using the last 9 questions. Please print 5 sports_recommend that would best fit the result in another section. Ensure the JSON is valid and looks like this: {sports_recommend: <list of sports_recommend>}. This is the collected information: ${widget.questions} and ${widget.answers}",

    ];

    for (String instructionPrompt in instructionPrompts) {
      await _fetchQuestions(userPrompt, instructionPrompt);
    }
  }

  Future<void> saveImprovements(String sports) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedImprovements =
        prefs.getStringList("sports_recommend") ?? [];
    if (!savedImprovements.contains(sports)) {
      savedImprovements.add(sports);
      prefs.setStringList("sports_recommend", savedImprovements);
      print("Sports Saved");
    } else {
      print("Sports recommend is already saved");
    }
  }

  Future<bool> _hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('Name');
  }

  void handleButtonPress() {
    for (int i = 0; i < returnResponse.length; i++) {
      if (returnResponse[i]) {
        saveImprovements(responses[i]).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${responses[i]} saved successfully!'))
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save ${responses[i]}'))
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: !isLoading
            ? ListView(
          children: <Widget>[
            ListView.builder(
                itemCount: responses.length,
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                      title: Text(responses[index]),
                      value: returnResponse[index],
                      onChanged: (value) {
                        setState(() {
                          returnResponse[index] = value ?? false;
                        });
                      });
                }),
            ElevatedButton(
                onPressed: () {
                  handleButtonPress();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyHomePage()),
                  ).then((value) => Navigator.pop(context));
                },
                child: const Text("Return Home"))
          ],
        )
            : Center(
          child: Container(
            margin: const EdgeInsets.all(5),
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

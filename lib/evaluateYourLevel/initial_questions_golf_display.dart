import 'package:app_v1/constants.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InitialQuestionsGolfDisplayPage extends StatefulWidget {
  const InitialQuestionsGolfDisplayPage(
      {super.key, required this.questions, required this.answers});

  final List<String> questions;
  final List<String> answers;

  @override
  State<InitialQuestionsGolfDisplayPage> createState() =>
      _InitialQuestionsGolfDisplayPageState();
}

class _InitialQuestionsGolfDisplayPageState
    extends State<InitialQuestionsGolfDisplayPage> {
  late final OpenAI _openAI;
  String? GPTresponse;
  List<String> responses = [];
  bool isLoading = true;
  List<bool> return_response = [];

  Future<void> _handleInitialMessage() async {
    final prefs = await SharedPreferences.getInstance();
    String userPrompt =
        ' I play ${prefs.getString('selected_sport1')}. I am a ${prefs.getString('selected_level')}.';
    String instructionPrompt =
        "Base off the ${widget.questions} and ${widget.answers} received, provide three aspects of my game that I should be improving on. Please make sure that you only return a JSON format that look like this: {Improvements: <list of improvements>}. Ensure the JSON is valid and do not write anything before or after the JSON structure provided.";
    print(instructionPrompt);
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
    ChatCTResponse? response1 =
        await _openAI.onChatCompletion(request: request);
    String result = response1!.choices.first.message!.content.trim();
    print(result);
    setState(() {
      try {
        Map<String, dynamic> resultMap =
            Map<String, dynamic>.from(json.decode(result));
        responses = List<String>.from(resultMap['Improvements']);
        return_response = List.generate(responses.length, (index) => false);
        isLoading = false;
        print(responses);
      } catch (e) {
        print("Error Parsing JSON $e");
      }
    });
    // print(result);
  }

  void handleButtonPress() {
    for (int i = 0; i < return_response.length; i++) {
      saveImprovements(responses[i]);
    }
  }

  Future<void> saveImprovements(String Sports) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedImprovements = prefs.getStringList("Improvements") ?? [];
    if (!savedImprovements.contains(Sports)) {
      savedImprovements.add(Sports);
      prefs.setStringList("Improvements", savedImprovements);
      print("Improvement Saved");
    } else {
      print("Improvement is already saved");
    }
  }

  // Future<bool> _hasProfile() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.containsKey('Name');
  // }

  @override
  void initState() {
    _openAI = OpenAI.instance.build(
        token: dotenv.env['OPENAI_API_KEY'],
        baseOption: HttpSetup(
          receiveTimeout: const Duration(seconds: 30),
        ));
    // _hasProfile().then((value) {
    //   if (value) {_handleInitialMessage()
    //     ;
    //   } else {
    //     print("ERROR");
    //   }
    // });
    _handleInitialMessage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: !isLoading
            ? ListView(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 5,
                    child: ListView.builder(
                        itemCount: responses.length,
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                              title: Text(responses[index]),
                              value: return_response[index],
                              onChanged: (value) {
                                setState(() {
                                  return_response[index] = value ?? false;
                                  handleButtonPress();
                                });
                              });
                        }),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        handleButtonPress();
                        Navigator.pop(context);
                      },
                      child: const Text("Return Home"))
                ],
              )
            : Center(
                child: Container(
                  margin: const EdgeInsets.all(5),
                  child: CircularProgressIndicator(),
                ),
              ),
      ),
    );
  }
}

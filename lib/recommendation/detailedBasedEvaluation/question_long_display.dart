import 'package:app_v1/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuestionLongDisplayPage extends StatefulWidget {
  const QuestionLongDisplayPage();

  @override
  State<QuestionLongDisplayPage> createState() =>
      _QuestionLongDisplayPageState();
}

class _QuestionLongDisplayPageState extends State<QuestionLongDisplayPage> {
  late final OpenAI _openAI;
  String? GPTresponse;
  Map<String, List<String>> responsesMap = {};
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
    jsonString = jsonString.replaceAllMapped(
      RegExp(r'(?<!")(\w+)(?!")\s*:'),
      (match) => '"${match.group(1)}":',
    );
    jsonString = jsonString.replaceAll("'", '"');
    jsonString = jsonString.replaceAll(RegExp(r',\s*,+'), ',');
    jsonString = jsonString.replaceAll(RegExp(r'\[\s*,+'), '[');
    jsonString = jsonString.replaceAll(RegExp(r',\s*]'), ']');
    jsonString = jsonString.replaceAll(RegExp(r',\s*}'), '}');
    jsonString = jsonString.replaceAllMapped(
      RegExp(r'\[(\s*[\w\s]+(?:,\s*[\w\s]+)*)\]'),
      (match) {
        String listContent = match.group(1)!;
        List<String> items = listContent.split(',').map((item) {
          String trimmedItem = item.trim();
          return trimmedItem.isNotEmpty && !trimmedItem.startsWith('"')
              ? '"$trimmedItem"'
              : trimmedItem;
        }).toList();
        return '[${items.join(', ')}]';
      },
    );
    if (jsonString.contains('{') && !jsonString.contains('}')) {
      jsonString += '}';
    }
    return jsonString;
  }

  String cleanJsonString(String jsonString) {
    jsonString = jsonString.replaceAll(RegExp(r'```(\w+)?'), '').trim();
    jsonString = jsonString.replaceAll(RegExp(r',\s*}'), '}');
    jsonString = jsonString.replaceAll(RegExp(r',\s*]'), ']');
    return jsonString;
  }

  Future<void> _saveResponsesToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    responsesMap.forEach((key, value) {
      prefs.setStringList(key, value);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved successfully!')),
    );
  }

  Future<void> _fetchQuestions(
      String userPrompt, String instructionPrompt) async {
    final request = ChatCompleteText(
      model: Gpt4OChatModel(),
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

    while (!isComplete) {
      ChatCTResponse? response =
          await _openAI.onChatCompletion(request: request);
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

    try {
      final jsonString =
          fullResponse.substring(fullResponse.indexOf('{')).trim();
      final fixedJsonString = fixJsonString(jsonString);
      final cleanedJsonString = cleanJsonString(fixedJsonString);
      print("Cleaned JSON: $cleanedJsonString");
      final resultMap = json.decode(cleanedJsonString);

      if (resultMap is! Map) {
        throw FormatException("Parsed JSON is not a Map.");
      }

      setState(() {
        isLoading = false;
        for (var key in resultMap.keys) {
          var value = resultMap[key];
          if (value is List) {
            responsesMap[key] = List<String>.from(value);
          } else {
            print("Unexpected value for key $key: $value");
          }
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error Parsing JSON: \$e");
      print("Raw response: \$fullResponse");
    }
  }

  void createFinalSportsList() {
    List<String> finalSports = [];

    List<String> psyStrengthSports = responsesMap['psyStrengthSports'] ?? [];
    List<String> bodySports = responsesMap['bodySports'] ?? [];
    List<String> physicalStrengthSports =
        responsesMap['physicalStrengthSports'] ?? [];

    // Helper function to add sports to finalSports without duplicates
    void addUniqueSports(List<String> sportsList) {
      for (var sport in sportsList) {
        if (!finalSports.contains(sport)) {
          finalSports.add(sport);
        }
      }
    }

    // Add sports from each list to finalSports, avoiding duplicates
    addUniqueSports(psyStrengthSports);
    addUniqueSports(bodySports);
    addUniqueSports(physicalStrengthSports);

    // Update responsesMap to include finalSports for displaying on screen
    responsesMap['finalSports'] = finalSports;

    // Print the finalSports list
    print('Final Sports List: $finalSports');
  }

// Example usage within the class where responsesMap is defined
  void handleFinalSports() {
    createFinalSportsList();
  }

  Future<void> _handleInitialMessage() async {
    final prefs = await SharedPreferences.getInstance();
    String userPrompt = """
    
This is the collected information for sportsTest: ${prefs.getStringList("Long Test")} and ${prefs.getStringList('Long Test Input')}. 
This is the collected information for psychologicalTest: ${prefs.getStringList("Long Psy")} and ${prefs.getStringList('Long Psy Input')}.
This is the collected information for questionsTest: ${prefs.getStringList("Long Other")} and ${prefs.getStringList('Long Other Input')}. 

The goal of using these collected pieces of information is to determine the sport that best fits the users. First, completely scan through and analyze the collected data for sportTest. There are two different things: Category and Test. Categories are Muscular Strength, Muscular Endurance, Muscular Power, Agility and Speed, Aerobic Capacity, Flexibility, Balance and Stability, and Reaction Time. These are the overall physical description for the user. For each category, there are related tests under it. For example, the Max Bench Press is under the Muscular Strength category. For tests with no input value for the user’s performance, remove the test and the input so it does not affect the calculation.  Find the categories that each test belongs to based on the collected data from the user. For each test, find the worst, average, and best performance for individuals of the user’s age and gender. Scores of 1, 50, and 100 should represent the worst, average, and best possible performance respectively for the user’s age and gender for each test. For time-based tests (like sprint times, and reaction times), ensure lower times are scored higher (faster times result in higher scores). For other tests (like strength, and flexibility), higher values result in higher scores. Now compare all three baseline, scores of 1, 50, 100, to the user’s performance. Determine the user’s score out of 100 on each test score compared to the worst, average, and best baseline test performance, which are 1, 50, and 100 respectively. After calculating scores, review them to ensure accuracy, and make sure each one of them is in the range of 1-100. If they are not or have any errors, redo everything. For every input of time, recheck the score and make sure if less than average time is a better result or a worse result, and the scores are valid. 
After everything is checked to be correct, create the list overallScores with each overall score for EACH CATEGORY stored in it. The list should contain actual numerical values (e.g., [85, 75, 90]). Categories include Muscular Strength, Muscular Endurance, Muscular Power, Agility and Speed, Aerobic Capacity, Flexibility, Balance and Stability, and Reaction Time.
Important: All responses must be returned in valid JSON format without any placeholders or descriptive text. Use actual numerical values for lists. (Ex. {"overallScores": [85, 75, 90, 80, 70, 60, 65, 95]})
Next, analyze all the categories' scores in overallScores to find categories at which the user shows relative strength (categories with higher scores) and relative weakness (categories with lower scores). Create the following lists:
bodySports: Store at 6-10 sports that suit the user's weight and height very well. These should be a immediate matches. If user is close to the ideal height for a certain sport, include that sport here (Should be almost the ideal perfect height for it, anything other than that shouldn't be considered). If user is close to the ideal weight for a certain sport, include that sport should be here (Should be almost the ideal perfect weight for it, anything other than that shouldn't be considered). For example, if user is not high enough, Basketball shouldn't be here, but if user is high enough, Basketball should be here. Ensure bodySports is returned in valid JSON format with real values. 
physicalStrengthSports: Create a list of 6-10 different sports that were included in bodySports that suit the user based on their relative strengths (categories with higher scores). Ensure that only sports with high scores in certain categories are here. For example, if user shows high score in a certain category, sports that focuses a lot on that category should be here. 
NEXT STEP: Completely analyze the collected data for psychologicalTest. These questions are derived from the Connor-Davidson and Athletic Coping Skills Inventory (ACSI-28). Create 7 categories based on these questions, similar to the physical categories. Remove questions with no input values. For each question response, assign a score between 0 (worst) and 100 (best). Calculate category scores and create the list psyCat containing the category names and psyCatScores containing their scores. (ex. {"psyCat": ["Stress Management", "Self-Confidence", "Focus"]} , {"psyCatScores": [75, 60, 85]})
psyStrengthSports: Create a list storing 3-5 sports that do not suit the user based on Strength in psychological scores (categories that shows high score). For example, if user shows relative high score in stress management, sports that is requires stress management should be included here, but if user does not show a very high score, no sports that require good stress management should be here then. 
LAST STEP: Analyze the user's health, living, economic, and overall conditions to create conditionSports that are not suitable. There shouldn't be a lot of sports. Only add sports if the user is restricted by it.(For example, add sports if user has a bad health condition, lives in poverty, or something similar) Then modify the finalSports by removing that are listed in conditionSports. (for example, if conditionSports has a certain, and finalSports also has that, remove it from finalSports).
Finally, based on user preferences, narrow down to 7-9 sports that the user likes the most. Create the prefSports that stores it. This list does not have any restrictions. Can be anything that user likes. 
Important Notes:
Every output must be returned in valid JSON format.
Do not use placeholders like <list of overallScores>
Ensure every list has a value in it. 
For scoring, do not make everything above 50 percent unless the user is excelled at everything. For example, usually there should be at least one category in physical and psychological that has a score of below 50. 
Ensure that all responses are concise and only contain the JSON without any additional explanations or formatting.
  """;
    List<String> instructionPrompts = [
      "Next, please print the overallScores for EACH CATEGORY, only output the value of the overallScores. Ensure the JSON is valid and looks like this: {overallScores: <list of overallScores>}. Only return the JSON, without any additional text or formatting (such as code block backticks).",
      "Next, please print the bodySports for the user, only output the value of the bodySports. Ensure the JSON is valid and looks like this: {bodySports: <list of bodySports>}. Only return the JSON, without any additional text or formatting (such as code block backticks).",
      "Next, please print the physicalStrengthSports for the user, only print the value of the physicalStrengthSports. Ensure the JSON is valid and looks like this: {physicalStrengthSports: <list of physicalStrengthSports>}. Only return the JSON, without any additional text or formatting (such as code block backticks).",
      "Next, please print the psyCat for the user, only output the value of the psyCat. Ensure the JSON is valid and looks like this: {psyCat: <list of psyCat>}. Only return the JSON, without any additional text or formatting (such as code block backticks).",
      "Next, please print the psyCatScores for the user, only output the value of the psyCatScores. Ensure the JSON is valid and looks like this: {psyCaScores: <list of psyCatScores>}. Only return the JSON, without any additional text or formatting (such as code block backticks).",
      "Next, please print the psyStrengthSports for the user, only output the value of the psyStrengthSports. Ensure the JSON is valid and looks like this: {psyStrengthSports: <list of psyStrengthSports>}. Only return the JSON, without any additional text or formatting (such as code block backticks).",
      "Next, please print the conditionSports for the user, only output the value of the conditionSports. Ensure the JSON is valid and looks like this: {conditionSports: <list of conditionSports>}. Only return the JSON, without any additional text or formatting (such as code block backticks).",
      "Next, please print the prefSports for the user, only output the value of the prefSports. Ensure the JSON is valid and looks like this: {prefSports: <list of prefSports>}. Only return the JSON, without any additional text or formatting (such as code block backticks).",
    ];

    for (String instructionPrompt in instructionPrompts) {
      await _fetchQuestions(userPrompt, instructionPrompt);
    }
    handleFinalSports();
  }

  Future<bool> _hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('Name');
  }

  void handleButtonPress() {
    for (int i = 0; i < returnResponse.length; i++) {
      if (returnResponse[i]) {
        saveImprovements(responsesMap.values.expand((x) => x).toList()[i])
            .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  '${responsesMap.values.expand((x) => x).toList()[i]} saved successfully!')));
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Failed to save ${responsesMap.values.expand((x) => x).toList()[i]}')));
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: color1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: !isLoading
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // Top row for finalSports and prefSports
                    if (responsesMap.containsKey('finalSports') &&
                        responsesMap.containsKey('prefSports'))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: 300,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recommended Sports',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...responsesMap['finalSports']!
                                    .map((item) => Text(item))
                                    .toList(),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.45,
                            height: 300,
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sports that you perferred',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...responsesMap['prefSports']!
                                    .map((item) => Text(item))
                                    .toList(),
                              ],
                            ),
                          ),
                        ],
                      ),

                    // Second row for radar charts (overallScores and psyCatScores)
                    if (responsesMap.containsKey('overallScores') &&
                        responsesMap.containsKey('psyCatScores'))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.465,
                            padding: const EdgeInsets.all(0),
                            height: 280,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Physical Scores',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  height: 220,
                                  child: RadarChart(
                                    RadarChartData(
                                      dataSets: [
                                        RadarDataSet(
                                          fillColor:
                                              Colors.green.withOpacity(0.5),
                                          borderColor: Colors.green,
                                          entryRadius: 4.0,
                                          dataEntries:
                                              responsesMap['overallScores']!
                                                  .map((score) => RadarEntry(
                                                      value:
                                                          double.parse(score)))
                                                  .toList(),
                                        ),
                                      ],
                                      titleTextStyle: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      getTitle: (index, angle) {
                                        // Assuming the order of scores corresponds to the categories
                                        List<String> categories = [
                                          'Muscular Strength',
                                          'Muscular Endurance',
                                          'Muscular Power',
                                          'Agility and Speed',
                                          'Aerobic Capacity',
                                          'Flexibility',
                                          'Balance and Stability',
                                          'Reaction Time'
                                        ];
                                        return RadarChartTitle(
                                            text: categories.length > index
                                                ? categories[index]
                                                : '');
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.465,
                            padding: const EdgeInsets.all(0),
                            height: 280,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Psychological Scores',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                                SizedBox(height: 8),
                                SizedBox(
                                  height: 220,
                                  child: RadarChart(
                                    RadarChartData(
                                      dataSets: [
                                        RadarDataSet(
                                          fillColor:
                                              Colors.blue.withOpacity(0.5),
                                          borderColor: Colors.blue,
                                          entryRadius: 4.0,
                                          dataEntries:
                                              responsesMap['psyCatScores']!
                                                  .map((score) => RadarEntry(
                                                      value:
                                                          double.parse(score)))
                                                  .toList(),
                                        ),
                                      ],
                                      titleTextStyle: TextStyle(
                                          fontSize: 6,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                      getTitle: (index, angle) {
                                        List<String> psyCategories =
                                            responsesMap['psyCat'] ?? [];
                                        // return psyCategories.length > index
                                        //     ? psyCategories[index]
                                        //     : '';
                                        return RadarChartTitle(
                                            text: psyCategories.length > index
                                                ? psyCategories[index]
                                                : '');
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    // Bottom section for other lists (bodySports, conditionSports, psyStrengthSports)
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        for (String key in responsesMap.keys)
                          if (key != 'overallScores' &&
                              key != 'psyCatScores' &&
                              key != 'psyCat' &&
                              key != 'finalSports' &&
                              key != 'prefSports')
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    key,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  SizedBox(height: 8),
                                  ...responsesMap[key]!
                                      .map((item) => Text(item))
                                      .toList(),
                                ],
                              ),
                            ),
                        ElevatedButton(
                          onPressed: _saveResponsesToPreferences,
                          child: Text('Save Data'),
                        ),
                      ],
                    ),
                  ],
                ),
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

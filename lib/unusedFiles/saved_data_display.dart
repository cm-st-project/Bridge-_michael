import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'package:app_v1/home.dart';

class SavedDataDisplayPage extends StatefulWidget {
  const SavedDataDisplayPage({Key? key}) : super(key: key);

  @override
  _SavedDataDisplayPageState createState() => _SavedDataDisplayPageState();
}

class _SavedDataDisplayPageState extends State<SavedDataDisplayPage> {
  Color color = Colors.white;
  Color color6 = Color(0xFF72f6fb);

  Map<String, List<String>> savedDataMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    Map<String, List<String>> dataMap = {};

    // Only load the keys that are displayed in the QuestionLongDisplayPage
    List<String> keysToLoad = [
      'finalSports',
      'prefSports',
      'overallScores',
      'psyCatScores',
      'psyCat',
      'bodySports',
      'physicalStrengthSports',
      'psyStrengthSports',
      'conditionSports'
    ];

    for (String key in keys) {
      if (keysToLoad.contains(key)) {
        try {
          List<String>? value = prefs.getStringList(key);
          if (value != null) {
            dataMap[key] = value;
          }
        } catch (e) {
          print("Error loading key $key: $e");
        }
      }
    }

    setState(() {
      savedDataMap = dataMap;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Your Sports', style: TextStyle(color: Colors.white)),
        backgroundColor: color2,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : savedDataMap.isEmpty
              ? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info, size: 50),
                  SizedBox(height: 20),
                  Text('No saved data found', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 100),
                ],
              ))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Top row for finalSports and prefSports
                      if (savedDataMap.containsKey('finalSports') &&
                          savedDataMap.containsKey('prefSports'))
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContainer(
                              title: 'Final Sports',
                              description:
                                  "Sports that best match the user's profile.",
                              items: savedDataMap['finalSports']!,
                              backgroundColor: color6,
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                height: 175,
                                width: double.infinity,
                                child: Wrap(
                                  spacing: 10.0,
                                  runSpacing: 10.0,
                                  children: savedDataMap['finalSports']!
                                      .map((item) => SizedBox(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4 -
                                                5,
                                            child: Text(item,
                                                textAlign: TextAlign.center),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildContainer(
                              title: 'Preferred Sports',
                              description:
                                  "Sports that the user personally prefers the most.",
                              items: savedDataMap['prefSports']!,
                              backgroundColor: color,
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                height: 175,
                                width: double.infinity,
                                child: Wrap(
                                  spacing: 10.0,
                                  runSpacing: 10.0,
                                  children: savedDataMap['prefSports']!
                                      .map((item) => SizedBox(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4 -
                                                5,
                                            child: Text(item,
                                                textAlign: TextAlign.center),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 16),

                      // Radar chart for overallScores
                      if (savedDataMap.containsKey('overallScores'))
                        _buildRadarChartContainer(
                          title: 'Physical Scores',
                          description: "User's physical profile",
                          scores: savedDataMap['overallScores']!,
                          categories: [
                            'Muscular Strength',
                            'Muscular Endurance',
                            'Muscular Power',
                            'Agility and Speed',
                            'Aerobic Capacity',
                            'Flexibility',
                            'Balance and Stability',
                            'Reaction Time'
                          ],
                          fillColor: Colors.green.withOpacity(0.5),
                          borderColor: Colors.green,
                        ),

                      SizedBox(height: 16),

                      // Radar chart for psyCatScores
                      if (savedDataMap.containsKey('psyCatScores'))
                        _buildRadarChartContainer(
                          title: 'Psychological Scores',
                          description: "User's psychological profile",
                          scores: savedDataMap['psyCatScores']!,
                          categories: savedDataMap['psyCat'] ?? [],
                          fillColor: Colors.blue.withOpacity(0.5),
                          borderColor: Colors.blue,
                        ),

                      SizedBox(height: 16),

                      // Bottom section for bodySports and physicalStrengthSports
                      if (savedDataMap.containsKey('bodySports') &&
                          savedDataMap.containsKey('physicalStrengthSports'))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContainer(
                              title: 'Body Type',
                              description:
                                  "Sports that suit the user's height and weight",
                              items: savedDataMap['bodySports']!,
                              backgroundColor: Colors.white,
                              widthFactor: 0.45,
                            ),
                            _buildContainer(
                              title: 'Physical',
                              description:
                                  "Sports match the user's physical strength",
                              items: savedDataMap['physicalStrengthSports']!,
                              backgroundColor: Colors.white,
                              widthFactor: 0.45,
                            ),
                          ],
                        ),

                      SizedBox(height: 16),

                      // Bottom section for psyStrengthSports and conditionSports
                      if (savedDataMap.containsKey('psyStrengthSports') &&
                          savedDataMap.containsKey('conditionSports'))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContainer(
                              title: 'Psychological',
                              description:
                                  "Sports match the user's psychological strengths",
                              items: savedDataMap['psyStrengthSports']!,
                              backgroundColor: Colors.white,
                              widthFactor: 0.45,
                            ),
                            _buildContainer(
                              title: 'Condition',
                              description:
                                  "Sports not suitable for the user based on health, economic, or living conditions.",
                              items: savedDataMap['conditionSports']!,
                              backgroundColor: Colors.white,
                              widthFactor: 0.45,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildContainer({
    required String title,
    required String description,
    required List<String> items,
    required Color backgroundColor,
    double widthFactor = 1.0,
    Widget? child, // Add this parameter
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 8),
          if (child != null) child,
          // Add this line to include the child if provided
        ],
      ),
    );
  }

  Widget _buildRadarChartContainer({
    required String title,
    required String description,
    required List<String> scores,
    required List<String> categories,
    required Color fillColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      height: 350,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor: fillColor,
                    borderColor: borderColor,
                    entryRadius: 4.0,
                    dataEntries: scores
                        .map((score) => RadarEntry(value: double.parse(score)))
                        .toList(),
                  ),
                ],
                titleTextStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                getTitle: (index, angle) {
                  // return categories.length > index ? categories[index] : '';
                  return RadarChartTitle(
                      text: categories.length > index ? categories[index] : '');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

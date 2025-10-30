import 'package:flutter/material.dart';
import '../profile/profile.dart';
import '../evaluateYourLevel/initial_questions_golf.dart';
import '../evaluateYourLevel/evaluateYourLevel.dart';
import '../recommendation/recommend_choice.dart';
import 'golf_tips.dart';
import 'machine_learning.dart';
import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Page',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      // Adjust the radius here
                      color: Color.fromRGBO(204, 179, 255, 1.0),
                    ),
                    child: SizedBox(
                      height: 200,
                      width: 335,
                      child: ListView(
                        children: [
                          // TipsPage(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35.0, top: 65.0, bottom: 10),
              // Custom padding for left and top
              child: Align(
                alignment: Alignment.centerLeft,
                // Aligns the text to the start (left)
                child: Text(
                  "Information",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            Container(
              width: 375.0,
              height: 400.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 10, top: 0, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SelectionPage(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: Size(170, 255),
                                  backgroundColor: Color.fromRGBO(255, 194, 102, 1),
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  "",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only( bottom: 5, right: 10),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecommendChoicePagePage(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size(140, 175),
                              backgroundColor: Color.fromRGBO(153, 204, 255, 1), // Background color
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10, right: 10),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecommendChoicePagePage(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              minimumSize: Size(140, 75),
                              backgroundColor: Color.fromRGBO(255, 153, 255, 1), // Background color
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

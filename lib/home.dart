import 'package:flutter/material.dart';
import 'evaluateYourLevel/evaluateYourLevel.dart';
import 'recommendation/recommend_choice.dart';
import 'unusedFiles/saved_data_display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0; // Initially selected date is today
  List<Map<String, dynamic>> days = [];

  Color color = Colors.white;
  Color color1 = Color(0xFF0B132B);
  Color color2 = Color(0xFF1C2541);
  Color color3 = Color(0xFF3C75C6);
  Color color4 = Color(0xFF9ED6FF);
  Color color5 = Color(0xFF56F4DC);
  Color color6 = Color(0xFF72f6fb);
  Color color7 = Color(0xFF060A18);
  Color color8 = Color(0xFF3a506b);
  Color color9 = Color(0xFFC91818);
  Color color10 = Color(0xFFFF4D4F);
  Color color11 = Color(0xFFFF7275);
  Color color12 = Color(0xFFFFC4AB);
  Color color13 = Color(0xFFFF8C8C);
  Color color14 = Color(0xFFa31414);
  Color color15 = Color(0xFF9BE4E3);

  List<Color> colors = [
    Color(0xFFFF4D4F),
    Color(0xFFFF7275),
    Color(0xFFFFC4AB),
  ];

  List<Color> colors2 = [
    Colors.black54,
    Colors.black54,
    Colors.black54,
  ];

  List<String>? sportsTC = [];
  String _name = "";

  Future<void> loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sportsTC = prefs.getStringList('sports');
      _name = (prefs.getString("Name") ?? '');
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    generateDates();
  }

  void generateDates() {
    DateTime now = DateTime.now(); // Get the current date
    DateTime monday = now.subtract(Duration(
        days: now.weekday - 1)); // Calculate Monday of the current week

    for (int i = 0; i < 7; i++) {
      DateTime currentDate = monday.add(Duration(days: i));
      String dayName =
          DateFormat('E').format(currentDate); // Get the day name (e.g., Mon)
      String dayNumber =
          DateFormat('d').format(currentDate); // Get the day number (e.g., 23)
      bool isToday = currentDate.day == now.day &&
          currentDate.month == now.month &&
          currentDate.year == now.year;
      days.add({
        'day': dayName,
        'date': dayNumber,
        'isToday': isToday,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            // Height when expanded
            floating: true,
            // Make the AppBar float as you scroll
            snap: true,
            // Snap the AppBar when scrolling stops
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.black,
            // Remove shadow
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Background image for AppBar
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45),
                      image: DecorationImage(
                        image: AssetImage("assets/sports_background8.jpg"),
                        // Your image path
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.25),
                          // Adjust the opacity here
                          BlendMode.darken, // Mode to blend the image and color
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row with profile icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Profile Icon
                              SizedBox(
                                height: 30,
                              )
                            ],
                          ),

                          // Redzone Logo and Countdown
                          Padding(
                            padding: const EdgeInsets.only(top: 40.0, left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello ${_name}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                // Countdown Timer
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Let's Start",
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding:
                      EdgeInsets.only(left: 30, right: 10, bottom: 10, top: 30),
                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        padding: EdgeInsets.only(left: 0, right: 5),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: days.length,
                          itemBuilder: (context, index) {
                            bool isToday = days[index]['isToday'];
                            return GestureDetector(
                              onTap: isToday
                                  ? () {
                                      setState(() {
                                        selectedIndex =
                                            index; // Update selected date only if it is today
                                      });
                                    }
                                  : null, // Disable onTap for other days
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 0), // Spacing
                                    Container(
                                      width: 44.5,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: isToday ? Colors.black : Colors.white,
                                        // Only today is black
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: isToday ? Colors.black : Colors.black,
                                          width: 2.5,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            days[index]['day'],
                                            style: TextStyle(
                                              color: isToday
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            days[index]['date'],
                                            style: TextStyle(
                                              color: isToday
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 375.0,
                        height: 400.0,
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 10,
                                        top: 20,
                                        bottom: 10,
                                        right: 10),
                                    decoration: BoxDecoration(
                                      color: color1,
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/sports_background4.jpg"),
                                        // Replace with your image path
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.43),
                                          // Adjust the opacity here
                                          BlendMode
                                              .darken, // Mode to blend the image and color
                                        ), // This adjusts how the image fits the container
                                      ),
                                    ),
                                    height: 280,
                                    width: 180,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(
                                              left: 4,
                                              top: 0,
                                              bottom: 12,
                                              right: 0),
                                          child: Text(
                                            'Evaluation',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              if (sportsTC != null)
                                                for (int index = 0;
                                                    index < sportsTC!.length;
                                                    index++) ...[
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8,
                                                        horizontal: 5),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            sportsTC![index],
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: color,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 4,
                                                                  vertical: 0),
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  colors[index],
                                                            ),
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.5),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            'Saved',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(
                                                    thickness: 1.5,
                                                    color: Colors.grey[300],
                                                    height: 0,
                                                  ),
                                                ]
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SelectionPage(),
                                              ),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            shadowColor: color,
                                            minimumSize: Size(150, 40),
                                            backgroundColor: color,
                                            elevation: 0,
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            side: BorderSide(
                                                color: Colors.white, width: 0),
                                          ),
                                          child: const Text(
                                            "Evaluate Your Level",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.only(bottom: 8, right: 10),
                                    height: 280,
                                    width: 170,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/sports_background10.jpg"),
                                        // Replace with your image path
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.2),
                                          // Adjust the opacity here
                                          BlendMode
                                              .darken, // Mode to blend the image and color
                                        ), // This adjusts how the image fits the container
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          // Shadow color
                                          spreadRadius: 5,
                                          // How much the shadow spreads
                                          blurRadius: 7,
                                          // How blurry the shadow is
                                          offset: Offset(0,
                                              3), // Position of the shadow (x, y)
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 15, left: 15, right: 15),
                                          child: Text(
                                            'Find Your Sports',
                                            style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 22,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                          child: Column(
                                            children: [

                                              TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => SavedDataDisplayPage(),

                                                    ),
                                                  );
                                                  // Add navigation or action for second button
                                                },
                                                style: TextButton.styleFrom(
                                                  minimumSize: Size(160, 40),
                                                  backgroundColor: color,
                                                  side: BorderSide(color: color3, width: 1.5),
                                                  textStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Your Saved Data",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => RecommendChoicePagePage(),

                                                    ),
                                                  );
                                                },
                                                style: TextButton.styleFrom(
                                                  minimumSize: Size(160, 40),
                                                  backgroundColor: color,
                                                  side: BorderSide(color: color3, width: 1.5),
                                                  textStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Get Recommendations",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                  ),
                                  // Container(
                                  //     margin:
                                  //         EdgeInsets.only(bottom: 10, right: 8),
                                  //     width: 170,
                                  //     decoration: BoxDecoration(
                                  //       color: color2,
                                  //       border: Border.all(
                                  //         color: color3,
                                  //         width: 0,
                                  //       ),
                                  //       borderRadius: BorderRadius.circular(16),
                                  //       // image: DecorationImage(
                                  //       //   image: AssetImage("assets/sports_background9.jpg"), // Replace with your image path
                                  //       //   fit: BoxFit.cover,
                                  //       //   colorFilter: ColorFilter.mode(
                                  //       //     Colors.black.withOpacity(0.40), // Adjust the opacity here
                                  //       //     BlendMode.darken, // Mode to blend the image and color
                                  //       //   ), // This adjusts how the image fits the container
                                  //       // ),
                                  //       boxShadow: [
                                  //         BoxShadow(
                                  //           color: Colors.grey.withOpacity(0.5),
                                  //           spreadRadius: 5,
                                  //           blurRadius: 7,
                                  //           offset: Offset(0,
                                  //               3), // Position of the shadow (x, y)
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     child: Column(
                                  //         crossAxisAlignment:
                                  //             CrossAxisAlignment.center,
                                  //         mainAxisAlignment:
                                  //             MainAxisAlignment.center,
                                  //         children: [
                                  //           TextButton(
                                  //             onPressed: () {
                                  //               Navigator.push(
                                  //                 context,
                                  //                 MaterialPageRoute(
                                  //                   builder: (context) =>
                                  //                       SavedDataDisplayPage(),
                                  //                 ),
                                  //               );
                                  //             },
                                  //             style: TextButton.styleFrom(
                                  //               minimumSize: Size(168, 43),
                                  //               maximumSize: Size(170, 45),
                                  //               textStyle: TextStyle(
                                  //                 fontSize: 16,
                                  //                 fontWeight: FontWeight.bold,
                                  //               ),
                                  //             ),
                                  //             child: Text(
                                  //               textAlign: TextAlign.right,
                                  //               "Prediction",
                                  //               style: TextStyle(
                                  //                 fontSize: 15,
                                  //                 color: Colors.white,
                                  //                 fontWeight: FontWeight.bold,
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ])),
                                ],
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
        ],
      ),
    );
  }
}

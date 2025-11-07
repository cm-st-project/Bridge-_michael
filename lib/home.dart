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
  int selectedIndex = 0;
  List<Map<String, dynamic>> days = [];

  Color color = Colors.white;
  Color color1 = const Color(0xFF0B132B);
  Color color2 = const Color(0xFF1C2541);
  Color color3 = const Color(0xFF3C75C6);
  Color color4 = const Color(0xFF9ED6FF);
  Color color5 = const Color(0xFF56F4DC);
  Color color6 = const Color(0xFF72f6fb);
  Color color7 = const Color(0xFF060A18);
  Color color8 = const Color(0xFF3a506b);
  Color color9 = const Color(0xFFC91818);
  Color color10 = const Color(0xFFFF4D4F);
  Color color11 = const Color(0xFFFF7275);
  Color color12 = const Color(0xFFFFC4AB);
  Color color13 = const Color(0xFFFF8C8C);
  Color color14 = const Color(0xFFa31414);
  Color color15 = const Color(0xFF9BE4E3);

  List<Color> colors = [
    const Color(0xFFFF4D4F),
    const Color(0xFFFF7275),
    const Color(0xFFFFC4AB),
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
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    for (int i = 0; i < 7; i++) {
      DateTime currentDate = monday.add(Duration(days: i));
      String dayName = DateFormat('E').format(currentDate);
      String dayNumber = DateFormat('d').format(currentDate);
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
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 2,
            shadowColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45),
                      image: DecorationImage(
                        image: const AssetImage("assets/sports_background8.jpg"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.25),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.only(top: 40.0, left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello $_name",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
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
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, bottom: 10, top: 30),
                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        padding: const EdgeInsets.only(left: 0, right: 5),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: days.length,
                          itemBuilder: (context, index) {
                            bool isToday = days[index]['isToday'];
                            return GestureDetector(
                              onTap: isToday
                                  ? () {
                                      setState(() {
                                        selectedIndex = index;
                                      });
                                    }
                                  : null,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 44.5,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? Colors.black
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Colors.black,
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
                      const SizedBox(height: 20),

                      // --- Fixed overflow-free layout section ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildLeftCard(context)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildRightCard(context)),
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

  Widget _buildLeftCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, top: 20, bottom: 10, right: 10),
      decoration: BoxDecoration(
        color: color1,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: const AssetImage("assets/sports_background4.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.43),
            BlendMode.darken,
          ),
        ),
      ),
      height: 280,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.only(left: 4, bottom: 12, right: 0, top: 0),
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
                  for (int index = 0; index < sportsTC!.length; index++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              sportsTC![index],
                              style: TextStyle(
                                fontSize: 14,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 0),
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(color: colors[index]),
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Saved',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
                MaterialPageRoute(builder: (context) => const SelectionPage()),
              );
            },
            style: TextButton.styleFrom(
              shadowColor: color,
              minimumSize: const Size(150, 40),
              backgroundColor: color,
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.white, width: 0),
            ),
            child: const Text(
              "Evaluate Levels",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightCard(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: const AssetImage("assets/sports_background10.jpg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.2),
            BlendMode.darken,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
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
            margin:
                const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedDataDisplayPage(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(160, 40),
                    backgroundColor: color,
                    side: BorderSide(color: color3, width: 1.5),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Your Saved Data",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const RecommendChoicePagePage(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(160, 40),
                    backgroundColor: color,
                    side: BorderSide(color: color3, width: 1.5),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Recommendation",
                    style: TextStyle(fontSize: 14, color: Colors.black),
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

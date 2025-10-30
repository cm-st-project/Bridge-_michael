import 'package:flutter/material.dart';
import 'route.dart';
import 'profile/profile.dart';
import 'home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'unusedFiles/logging_display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_v1/logs/my_sports_screen.dart';
import 'unusedFiles/statistics.dart';
import 'welcome/welcome_page.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  int pageIndex = 0;
  List<Widget> pages = [
    const MyHomePage(),
    const MySportsScreenPage(),
    const ProfilePage(),
  ];
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          pages[pageIndex], // Main content
          Positioned(
              left: 10,
              right: 10,
              bottom: 20,
              child: Padding(
                padding: EdgeInsets.only(bottom: 30, top: 0),
                child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Align(
                          alignment: Alignment.center,
                          child: BottomNavigationBar(
                            backgroundColor: Colors.black,
                            type: BottomNavigationBarType.fixed, // Ensures items are evenly spaced
                            selectedFontSize: 0, // Adjust font size for selected items
                            unselectedFontSize: 0,
                            showSelectedLabels: false, // Hide labels
                            showUnselectedLabels: false,
                            items: <BottomNavigationBarItem>[
                              BottomNavigationBarItem(
                                icon: Container(
                                  decoration: BoxDecoration(
                                    // color: pageIndex == 0 ? Colors.white : Colors.transparent, // Highlight the selected icon with a white background
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.home_outlined,
                                    size: 32,
                                    // color: pageIndex == 0 ? Colors.black : Colors.white, // Adjust icon color
                                  ),
                                ),
                                label: "Home",
                              ),

                              BottomNavigationBarItem(
                                icon: Container(
                                  decoration: BoxDecoration(
                                    // color: pageIndex == 2 ? Colors.white : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 32,
                                    // color: pageIndex == 2 ? Colors.black : Colors.white,
                                  ),
                                ),
                                label: "Log",
                              ),
                              BottomNavigationBarItem(
                                icon: Container(
                                  decoration: BoxDecoration(
                                    // color: pageIndex == 3 ? Colors.white : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 32,
                                    // color: pageIndex == 3 ? Colors.black : Colors.white,
                                  ),
                                ),
                                label: "Profile",
                              ),
                              
                            ],
                            currentIndex: pageIndex,
                            unselectedItemColor: Colors.grey,
                            selectedItemColor: color,
                            onTap: (int index) {
                              setState(() {
                                pageIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                    )),
              )),
        ],
      ),
    );
  }
}

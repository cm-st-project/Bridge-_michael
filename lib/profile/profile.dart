import 'package:flutter/material.dart';
import '/route.dart';
import 'profile_edit.dart';
import '/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String>? sportsTC = [];
  String _name = "";
  String _bio = "";
  String _username = "";
  String _profileImage = 'assets/profile.png';
  int? selectedSportIndex;

  File? _image;
  late SharedPreferences prefs;

  final List<String> _avatars = [
    'assets/profile.png',
    'assets/profile1.jpg',
    'assets/profile2.jpg',
    'assets/profile3.jpg',
  ];

  final List<String> golfDrills = [
    'Putting Drills',
    '60 Yard Course Practice',
    'Driving Accuracy Drill',
  ];
  final List<String> swimmingDrills = [
    'Freestyle',
    'Backstroke',
    'Breaststroke',
  ];
  final List<String> runDrills = [
    'Sun Salutation',
    'Warrior Poses',
    'Balance Practice',
  ];

  List<String> _getDrillsForSport(int index) {
    String selectedSport = sportsTC![index];
    if (selectedSport == 'Golf') return golfDrills;
    if (selectedSport == 'Run') return runDrills;
    if (selectedSport == 'Swimming') return swimmingDrills;
    return [];
  }

  @override
  void initState() {
    super.initState();
    _loadInfo();
    _loadUserSport();
  }

  Future<void> _loadInfo() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString("Name") ?? 'User';
      _bio = prefs.getString("Bio") ?? '';
      _username = prefs.getString("Username") ?? '@username';
      _profileImage = _avatars[prefs.getInt("AvatarIndex") ?? 0];
    });
  }

  Future<void> _loadUserSport() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sportsTC = prefs.getStringList('sports') ?? [];
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _image = File(image.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()),
              ).then((_) => _loadUserSport());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadInfo();
          await _loadUserSport();
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // --- Profile Header ---
              Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : AssetImage(_profileImage) as ImageProvider,
                      ),
                      // Positioned(
                      //   right: 4,
                      //   bottom: 4,
                      //   child: GestureDetector(
                      //     onTap: _pickImage,
                      //     child: Container(
                      //       padding: const EdgeInsets.all(6),
                      //       decoration: BoxDecoration(
                      //         color: Colors.black,
                      //         shape: BoxShape.circle,
                      //       ),
                      //       child: const Icon(Icons.camera_alt_rounded,
                      //           color: Colors.white, size: 18),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _username,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileEditPage()),
                      ).then((_) => _loadInfo());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      "Edit Profile",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- Sports Section ---
              if (sportsTC != null && sportsTC!.isNotEmpty) ...[
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Your Sports",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: sportsTC!.asMap().entries.map((entry) {
                      int index = entry.key;
                      String sport = entry.value;
                      bool selected = selectedSportIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedSportIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.black,
                              width: 2.5,
                            ),
                          ),
                          child: Text(
                            sport,
                            style: TextStyle(
                              color: selected
                                  ? const Color.fromARGB(255, 153, 213, 235)
                                  : Colors.black87,
                              fontWeight:
                                  selected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 25),

              // --- Drills Section ---
              if (selectedSportIndex != null) ...[
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Suggested Drills",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _getDrillsForSport(selectedSportIndex!).length,
                    itemBuilder: (context, i) {
                      String drill = _getDrillsForSport(selectedSportIndex!)[i];
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.black12,),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            drill,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

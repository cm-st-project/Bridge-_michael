import 'package:flutter/material.dart';
import '../profile/profile.dart';
import '../evaluateYourLevel/initial_questions_golf.dart';
import 'package:app_v1/unusedFiles/logging_display.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class LoggingRecordBackUpPage extends StatefulWidget {
  const LoggingRecordBackUpPage({super.key});

  @override
  State<LoggingRecordBackUpPage> createState() => _LoggingRecordBackUpPageState();
}

class _LoggingRecordBackUpPageState extends State<LoggingRecordBackUpPage> {
  late DateTime log_date;
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _resultController = TextEditingController();
  bool _showCalender = false;

  Future<void> DateSelect() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  List<String> sports = [];
  late String selected_sports = '';

  Future<void> loadUserSports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.containsKey('sports')) sports = prefs.getStringList('sports')!;
      selected_sports = prefs.getString('selected_sport') ??
          (sports.isNotEmpty ? sports.first : '');
    });
  }

  Future<void> saveLogInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonlog = prefs.getString(selected_sports) ?? '[]';
    List logs = jsonDecode(jsonlog);
    Map data = {
      'logDate': _dateController.text,
      'logTime': _timeController.text,
      'logResult': _resultController.text,
    };
    logs.add(data);
    prefs.setString(selected_sports, jsonEncode(logs));
    print("Log is added");
  }

  @override
  void initState() {
    super.initState();
    loadUserSports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: 500.0,
                height: 100.0,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Log #",
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ])),
            const Divider(
              height: 5,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: Colors.black,
            ),
            Container(
                width: 500.0,
                height: 400.0,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 300.0,
                          height: 500.0,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 7,
                                        child: TextField(
                                          keyboardType: TextInputType.text,
                                          controller: _dateController,
                                          decoration: InputDecoration(
                                              labelText: "Enter Log Date",
                                              hintText: "Log Date",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              )),
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          icon: Icon(Icons.calendar_month),
                                          onPressed: () {
                                            setState(() {
                                              if (_dateController
                                                  .text.isEmpty) {
                                                _dateController.text =
                                                    DateTime.now()
                                                        .toString()
                                                        .substring(0, 10);
                                              }
                                              _showCalender = !_showCalender;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _showCalender
                                    ? SizedBox(
                                        height: 100,
                                        child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.date,
                                          initialDateTime: DateTime.now(),
                                          onDateTimeChanged:
                                              (DateTime newDateTime) {
                                            setState(() {
                                              _dateController.text = newDateTime
                                                  .toString()
                                                  .substring(0, 10);
                                            });
                                          },
                                        ),
                                      )
                                    : SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 7,
                                        child: TextField(
                                          keyboardType: TextInputType.text,
                                          controller: _timeController,
                                          decoration: InputDecoration(
                                              labelText: "Enter Log Time",
                                              hintText: "Log Time",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              )),
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          icon: Icon(Icons.timer),
                                          onPressed: () async {
                                            TimeOfDay? pickedTime =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );
                                            if (pickedTime != null) {
                                              setState(() {
                                                _timeController.text =
                                                    pickedTime.format(context);
                                              });
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, right: 37),
                                  child: Column(
                                    children: [
                                      DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          labelText: "Sport",
                                          hintText: "Select Sport",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        value: selected_sports.isNotEmpty
                                            ? selected_sports
                                            : null,
                                        items: sports.map((String sport) {
                                          return DropdownMenuItem<String>(
                                            value: sport,
                                            child: Text(sport),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            selected_sports = newValue!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(top: 10, right: 37),
                                  child: Column(
                                    children: [
                                      TextField(
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          labelText: "Other",
                                          hintText: "Other",
                                        ),
                                        controller: _resultController,
                                      ),
                                    ],
                                  ),
                                ),
                              ])),
                    ])),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                alignment: Alignment.center,
              ),
              onPressed: () {
                print("save");
                Navigator.pop(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoggingDisplayPage(
                              selected_sports: selected_sports,
                            )));
                saveLogInfo();
              },
              child: const Text(
                "Save",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

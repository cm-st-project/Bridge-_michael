import 'dart:convert';
import 'package:flutter/material.dart';
import '../profile/profile.dart';
import '../evaluateYourLevel/initial_questions_golf.dart';
import '/route.dart';
import 'package:app_v1/logs/logging_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logs/my_sports_screen.dart';

class LoggingDisplayPage extends StatefulWidget {
  const LoggingDisplayPage({super.key, required this.selected_sports});

  final String selected_sports;

  @override
  State<LoggingDisplayPage> createState() => _LoggingDisplayPageState();
}

class _LoggingDisplayPageState extends State<LoggingDisplayPage> {
  List logs = [];
  late SharedPreferences prefs;

  Future<void> _loadInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.containsKey(widget.selected_sports));
    String jsonlogs = prefs.getString(widget.selected_sports) ?? '[]';
    setState(() {
      logs = jsonDecode(jsonlogs);
    });
  }
  Future<void> _saveLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.selected_sports, jsonEncode(logs));
  }


  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Card(
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                Container(
                    width: 500,
                    height: 50,
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: 100,
                            width: 250,
                            color: Colors.white,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("LOG NUMBER"),
                                ])),

                      ],
                    )),
                const Divider(
                  height: 20,
                  thickness: 2,
                  indent: 10,
                  endIndent: 0,
                  color: Colors.black,
                ),
                Expanded(
                    // Text('${widget.selected_sports} logs'.toUpperCase()),
                    child: logs.isNotEmpty
                        ? ListView.separated(
                            itemCount: logs.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                child: ListTile(
                                  title: Text('${logs[index]["logDate"]}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,  // This ensures the row takes only as much space as its children need.
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          print("edit log");
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          setState(() {
                                            logs.removeAt(index);
                                          });
                                          await _saveLogs();
                                          print("delete log");
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 150,
                              ),
                              Center(
                                  child: Text(
                                'No log entries detected',
                                style: TextStyle(fontSize: 25),
                              )),
                            ],
                          ),

                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

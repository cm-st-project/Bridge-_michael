import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SwimmingLogsPage extends StatefulWidget {
  const SwimmingLogsPage({super.key});

  @override
  State<SwimmingLogsPage> createState() => _SwimmingLogsPageState();
}

class _SwimmingLogsPageState extends State<SwimmingLogsPage> {
  Map<String, Map<String, dynamic>> logs = {};

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? logsJson = prefs.getString('Swimming');
    print(logsJson);

    if (logsJson != null) {
      setState(() {
        logs = Map<String, Map<String, dynamic>>.from(jsonDecode(logsJson));
      });
    }
  }

  Future<void> _saveLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Swimming', jsonEncode(logs));
  }

  void _editLog(String logDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Map<String, dynamic> log = logs[logDate]!;
        TextEditingController dateController =
            TextEditingController(text: logDate);
        List<TextEditingController> controllers = [];
        for (var field in log.keys) {
          controllers.add(TextEditingController(text: log[field].toString()));
        }

        return AlertDialog(
          title: Text('Edit Log'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Date'),
                ),
                for (var i = 0; i < controllers.length; i++)
                  TextField(
                    controller: controllers[i],
                    decoration:
                        InputDecoration(labelText: log.keys.elementAt(i)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                Map<String, dynamic> updatedLog = {};
                for (var i = 0; i < controllers.length; i++) {
                  updatedLog[log.keys.elementAt(i)] = controllers[i].text;
                }
                setState(() {
                  logs[logDate] = updatedLog;
                });
                _saveLogs();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteLog(String logDate) async {
    setState(() {
      logs.remove(logDate);
    });
    await _saveLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Swimming Logs'),
        backgroundColor: Colors.teal,
      ),
      body: logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info,
                    size: 50,
                    color: Colors.grey,
                  ),
                  Text(
                    'No logs available.',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: logs.keys.length,
                itemBuilder: (context, index) {
                  String logDate = logs.keys.elementAt(index);
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        'Log Date: $logDate',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // subtitle: Text('Details: ${logs[logDate]}'),
                      //use ExpansionTile for details
                      subtitle: ExpansionTile(
                        title: Text('Details',
                            style: TextStyle(fontStyle: FontStyle.italic)),
                        children: [
                          for (var field in logs[logDate]!.keys)
                            ListTile(
                              title: Text(
                                  '$field: ${logs[logDate]![field].toString()}'),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editLog(logDate);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await _deleteLog(logDate);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

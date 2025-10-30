import 'package:flutter/material.dart';
import '../profile/profile.dart';
import '../evaluateYourLevel/initial_questions_golf.dart';
import '../evaluateYourLevel/evaluateYourLevel.dart';
import '../recommendation/recommend_choice.dart';
import 'golf_tips.dart';
import '../home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MachineLearningPage extends StatefulWidget {
  const MachineLearningPage({super.key});

  @override
  State<MachineLearningPage> createState() => _MachineLearningPageState();
}

class _MachineLearningPageState extends State<MachineLearningPage> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();

  String result = '';
  bool isLoading = false;

  Future<void> _predict() async {
    setState(() {
      isLoading = true;
    });

    // Retrieve the user input from the text fields
    final double? input1 = double.tryParse(_controller1.text);
    final double? input2 = double.tryParse(_controller2.text);
    final double? input3 = double.tryParse(_controller3.text);
    final double? input4 = double.tryParse(_controller4.text);

    // Check if any of the inputs are invalid
    if (input1 == null || input2 == null || input3 == null || input4 == null) {
      setState(() {
        result = "Please enter valid numbers for all fields.";
        isLoading = false;
      });
      return;
    }

    // Send the request to the Flask server
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'inputs': [input1, input2, input3, input4], // Send inputs in a list
        }),
      );

      // If the server responded successfully
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          result = 'Prediction: ${data['prediction']}';  // Display the prediction
          isLoading = false;
        });
      } else {
        setState(() {
          result = "Error: ${response.reasonPhrase}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: Could not connect to the server.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Machine Learning Model Prediction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Input fields
              TextField(
                controller: _controller1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Input 1'),
              ),
              TextField(
                controller: _controller2,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Input 2'),
              ),
              TextField(
                controller: _controller3,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Input 3'),
              ),
              TextField(
                controller: _controller4,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Input 4'),
              ),
              const SizedBox(height: 20),

              // Button to trigger the prediction
              ElevatedButton(
                onPressed: isLoading ? null : _predict,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Predict'),
              ),

              const SizedBox(height: 20),

              // Display the result
              Text(result, style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
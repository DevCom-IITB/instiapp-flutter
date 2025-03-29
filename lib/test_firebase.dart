import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  print("Starting application...");
  WidgetsFlutterBinding.ensureInitialized();
  print("Flutter binding initialized");
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = "Initializing...";
  
  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }
  
  Future<void> _initializeFirebase() async {
    try {
      setState(() {
        _status = "Loading Firebase...";
      });
      try {
        await Firebase.initializeApp();
        setState(() {
          _status = "Firebase initialized successfully!";
        });
      } catch (e) {
        setState(() {
          _status = "Error initializing Firebase: $e";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Unexpected error: $e";
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Firebase Debug')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_status, style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _initializeFirebase,
                  child: Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
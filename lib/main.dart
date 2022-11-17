import 'package:fatty/auth.dart';
import 'package:fatty/steps_display.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:io' show Platform;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(useMaterial3: true),
      home: const MyHomePage(title: 'Fatty'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _steps = 0;
  int _totalSteps = 0;
  bool authorized = false;
  HealthFactory health = HealthFactory();
  List<HealthDataType> types = [HealthDataType.STEPS];

  _MyHomePageState() {
    getHealthData();
  }

  Future<bool> authorize() async {
    if (authorized) {
      return true;
    }

    authorized = await health.requestAuthorization(types);
    if (!authorized) {
      showSnackbar('Please grant permission to access health data');
      return false;
    }
    return true;
  }

  void getHealthData() async {
    if (!await authorize()) {
      return;
    }

    var now = DateTime.now();
    var today = await health.getTotalStepsInInterval(DateTime(now.year, now.month, now.day), now);
    var total = await health.getTotalStepsInInterval(DateTime(2022, 9, 1), now);

    setState(() {
      _steps = today ?? 0;
      _totalSteps = total ?? 0;
    });
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void login() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // body: Column(
      //   children: <Widget>[
      //     StepsDisplay(steps: _steps, label: 'Steps today'),
      //     StepsDisplay(steps: _totalSteps, label: 'Total steps'),
      //     ElevatedButton(onPressed: login, child: const Text('Login')),
      //   ],
      // ),
      body: const SocialAuth(),
      floatingActionButton: FloatingActionButton(
        onPressed: getHealthData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

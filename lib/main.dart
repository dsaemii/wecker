import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String now = "00:00";
  String alarm = "00:00";
  String alarmnow = "not now";
  Timer? timer;


  void setTime() {
    setState(() {
      DateTime today = DateTime.now();
      String hour = today.hour.toString().padLeft(2, '0');
      String minute = today.minute.toString().padLeft(2, '0');
      now = "$hour:$minute";
    });
  }

  void checkAlarm() {
    DateTime nowTime = DateTime.now();
    int nowHour = nowTime.hour;
    int nowMinute = nowTime.minute;

    List<String> alarmParts = alarm.split(':');
    int alarmHour = int.parse(alarmParts[0]);
    int alarmMinute = int.parse(alarmParts[1]);

    if (nowHour == alarmHour && nowMinute == alarmMinute) {
      setState(() {
        alarmnow = "now";
      });
    } else {
      setState(() {
        alarmnow = "not now";
      });
    }
  }

  // timer function
  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setTime();
      checkAlarm();
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _showEditDialog() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input, // set to input (text) entry mode
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          // override the default 12-hour format
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        alarm = selectedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              now,
              style: TextStyle(fontSize: 95),
            ),
            Text(
              alarm,
              style: TextStyle(fontSize: 25),
              ),
            Text(alarmnow),
            FloatingActionButton(
              onPressed: _showEditDialog,
              backgroundColor: Colors.white,
              // hforegroundColor: Colors.black,
              elevation: 0,
              child:
                /*'einstellen',
                style: TextStyle(fontSize: 24),*/
                const Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }
  /*floatingActionButton: FloatingActionButton(
        onPressed: _showEditDialog,
        tooltip: 'Edit Alarm',
        child: const Icon(Icons.edit),
      ),
    );
  }*/
}

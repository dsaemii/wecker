import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
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
  // alarm
  String now = "00:00";
  String alarm = "00:00";
  String alarmnow = "not now";
  Timer? timer;
  // position
  bool isFlat = false;
  double sensorX = 0.0;
  // color
  Color backgroundColor = Colors.white;


  // gyroscope listener
  void _handleGyroscopeEvents() {
    gyroscopeEvents.listen((GyroscopeEvent event) {
      // nur x relevant
      bool flat = false;
      double x =  event.x * 9.81 * 100;

      if (x < 20 && x > -17) {
        flat = true;
      } else {
        flat = false;
      }

      setState(() {
        sensorX = x;
        isFlat = flat;
        backgroundColor = isFlat ? Colors.black : Colors.white;
      });
    });
  }

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
    _handleGyroscopeEvents();
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
          // override default 12-hour format
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
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              now,
              style: TextStyle(
                fontSize: 95,
                color: isFlat ? Colors.white : Colors.black,
              ),
            ),
            Text(
              alarm,
              style: TextStyle(
                fontSize: 25,
                color: isFlat ? Colors.white : Colors.black,
              ),
            ),
            Text(alarmnow, style: TextStyle(color: isFlat ? Colors.white : Colors.black,)),
            
            AnimatedOpacity(
              opacity: isFlat ? 0.0 : 1.0,
              duration: Duration(milliseconds: 1),
              child: FloatingActionButton (
                onPressed: _showEditDialog,
                backgroundColor: Colors.white,
                elevation: 0,
                child: const Icon(Icons.edit),
            ),
            ),
            Text(
              'X: ' + sensorX.toStringAsFixed(4) + ' m/s²',
              style: TextStyle(
                fontSize: 25,
                color: isFlat ? Colors.white : Colors.black,
                ),
            ),
            Text(
              isFlat ? "liegt" : "steht",
              style: TextStyle(
                fontSize: 25,
                color: isFlat ? Colors.white : Colors.black,
                ),
            )
          ],
        ),
      ),
    );
  }
}

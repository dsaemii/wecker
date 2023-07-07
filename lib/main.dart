import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';
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
  bool isAlarm= false;
  bool alarmRang = false;
  Timer? timer;
  // position
  bool isFlat = false;
  double sensorX = 0.0;
  double sensorY = 0.0;
  // color
  Color backgroundColor = Colors.white;
  // gyroscope
  List<GyroscopeEvent> eventList = [];
  final Duration measurementDuration = Duration(seconds: 1);
  final int maxEventCount = 100;

  // alarm vibration
  void startVibration() {
    if (isAlarm && !alarmRang) {
      Vibration.vibrate(pattern: [500, 1000], intensities: [128]);
    }
  }

  void getAverageRotationRates() {
    double totalXRotationRate = 0.0;
    double totalYRotationRate = 0.0;

    if (eventList.isNotEmpty) {
      for (var event in eventList) {
        totalXRotationRate += event.x;
        totalYRotationRate += event.y;
      }

      double averageXRotationRate = totalXRotationRate / eventList.length;
      double averageYRotationRate = totalYRotationRate / eventList.length;

      sensorX = averageXRotationRate;
      sensorY = averageYRotationRate;
    }
  }

  // gyroscope listener
  void _handleGyroscopeEvents() {
    gyroscopeEvents.listen((GyroscopeEvent event) {
      eventList.add(event);

      if (eventList.length > maxEventCount) {
        eventList.removeAt(0);
      }
      
      bool flat = false;

      getAverageRotationRates();
      double treshold = 0.01;

      if (sensorX < treshold && sensorX < treshold) {
        flat = true;
      }

      setState(() {
        isFlat = flat;
        if (!isFlat && isAlarm) {
          Vibration.cancel();
          setState(() {
          alarmRang = true;
        });
        }
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

    if (nowHour == alarmHour && nowMinute == alarmMinute && !alarmRang) {
      setState(() {
        isAlarm = true;
      });
      startVibration();
    } else {
      setState(() {
        isAlarm = false;
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
        alarmRang = false;
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
            /* uncomement to show 'isAlarm' state
            Text(
              isAlarm.toString(),
              style:
                TextStyle(
                  color: isFlat ? Colors.white : Colors.black,
                ),
            ), */
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
            /* uncomment to show sensor data and 'isFlat' state
            Text(
              'X: ' + sensorX.toStringAsFixed(4) + ' m/s²',
              style: TextStyle(
                fontSize: 25,
                color: isFlat ? Colors.white : Colors.black,
                ),
            ),
            Text(
              'Y: ' + sensorY.toStringAsFixed(4) + ' m/s²',
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
            ) */
          ],
        ),
      ),
    );
  }
}

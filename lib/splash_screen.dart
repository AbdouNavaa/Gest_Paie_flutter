import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/header_widget.dart';
import 'auth/login.dart';
import 'constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = 'SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static var countdownDuration = Duration(minutes: 10);
  static var countdownDuration1 = Duration(minutes: 10);
  Duration duration = Duration();
  Duration duration1 = Duration();
  Timer? timer;
  Timer? timer1;
  bool countDown = true;
  bool countDown1 = true;

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 5));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())),
    );
  }
  @override
  void initState() {
    _navigateToNextScreen();

    var hours1;
    var mints1;
    var secs1;
    hours1 = int.parse("00");
    mints1 = int.parse("00");
    secs1 = int.parse("05");
    countdownDuration1 =
        Duration(hours: hours1, minutes: mints1, seconds: secs1);
    startTimer1();
    reset1();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          color: Colors.white10,
          width: double.infinity,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 400,
                  child: HeaderWidget(400, false, ''),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(seconds: 2),
                    child: Column(
                      children: [
                        SizedBox(height: 10,),
                        Text(
                          "GP",
                          style: GoogleFonts.abhayaLibre(
                            color: Colors.black,
                            fontSize: 70.0,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),   ],
                    ),
                  ),
                ),
                Text(
                  "Count down timer",
                  style: TextStyle(fontSize: 25),
                ),
                Container(
                    margin: EdgeInsets.only(top: 30, bottom: 30),
                    child: buildTime1()),
              ]),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final isRunning = timer == null ? false : timer!.isActive;
    if (isRunning) {
      timer!.cancel();
    }
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }

  void reset() {
    if (countDown) {
      setState(() => duration = countdownDuration);
    } else {
      setState(() => duration = Duration());
    }
  }

  void reset1() {
    if (countDown) {
      setState(() => duration1 = countdownDuration1);
    } else {
      setState(() => duration1 = Duration());
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void startTimer1() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime1());
  }

  void addTime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  void addTime1() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration1.inSeconds - addSeconds;
      if (seconds < 0) {
        timer1?.cancel();
      } else {
        duration1 = Duration(seconds: seconds);
      }
    });
  }


  Widget buildTime1() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration1.inHours);
    final minutes = twoDigits(duration1.inMinutes.remainder(60));
    final seconds = twoDigits(duration1.inSeconds.remainder(60));
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      buildTimeCard(time: hours, header: 'HEURES'),
      SizedBox(
        width: 8,
      ),
      buildTimeCard(time: minutes, header: 'MINUTES'),
      SizedBox(
        width: 8,
      ),
      buildTimeCard(time: seconds, header: 'SECONDS'),
    ]);
  }

  Widget buildTimeCard({required String time, required String header}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20),border: Border.all(color: Colors.black12)),
            child: Text(
              time,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 50),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Text(header, style: TextStyle(color: Colors.black45)),
        ],
      );
}

import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 5));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginSection()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 600,
              child: HeaderWidget(600, false, ''),
            ),

            AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 2),
              child: Column(
                children: [
                  // Container(
                  //   width: 300,
                  //   height: 120,
                  //   // child: CircleAvatar(backgroundColor: Colors.white,
                  //   //   child:
                  //   //   Image.asset(
                  //   //     'assets/supnum.png',
                  //   //     // color: Colors.white,
                  //   //     width: 130,
                  //   //     fit: BoxFit.cover,
                  //   //   ),
                  //   // ),
                  // ),
                  SizedBox(height: 10,),
                  Text(
                    "GP",
                    style: GoogleFonts.italianno(
                      color: Colors.black,
                      fontSize: 70.0,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 10),
            // CircularProgressIndicator(
            //   valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            // ),
          ],
        ),
      ),
    );
  }
}

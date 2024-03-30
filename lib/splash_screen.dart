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
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 500));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())),
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
              height: 400,
              child: HeaderWidget(400, false, ''),
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
                    style: GoogleFonts.abhayaLibre(
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
            SizedBox(height: 180),
            // Stack(
            //   children:[
            //   CircularProgressIndicator(
            //     valueColor: AlwaysStoppedAnimation<Color>(Colors.black,),
            //   ),
            //     // Text(DateTime..second.toString())
            //   ]
            // ),


            ElevatedButton(
              onPressed: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())),
                );
              },
              child: Text("Log In",
                style: GoogleFonts.abhayaLibre(
                color: Colors.black,
                fontSize: 40.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
              ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff0fb2ea),
                foregroundColor: Colors.white,
                elevation: 10,
                minimumSize:  Size( MediaQuery.of(context).size.width -60 , MediaQuery.of(context).size.width/7),
                // padding: EdgeInsets.only(left: MediaQuery.of(context).size.width /5,
                //     right: MediaQuery.of(context).size.width /5,bottom: 20,top: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            )

          ],
        ),
      ),
    );
  }
}

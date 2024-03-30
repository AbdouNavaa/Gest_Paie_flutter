import 'dart:convert';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gestion_payements/professeures.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/categories.dart';
import 'package:gestion_payements/matieres.dart';
import 'package:gestion_payements/prof_info.dart';
import 'package:gestion_payements/profs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'Cours.dart';
import 'ProfCours.dart';
import 'auth/login.dart';
import 'auth/profile.dart';
import 'auth/users.dart';
import 'more_page.dart';

class LogoutScreen extends StatefulWidget {

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sync_lock,size: 370,color: Color(0xff0fb2ea),),
            Text("You must sign-in to access to this section", style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,fontStyle: FontStyle.italic),),
            SizedBox(height: 15,),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('token', '');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())));
                    // MaterialPageRoute(builder: (context) => LoginSection()));
              },
              child: Text("Logout", style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic,fontWeight: FontWeight.w400),),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15) ),
                  padding: EdgeInsets.only(left: 117,right: 117,top: 15,bottom: 15),foregroundColor: Colors.white,backgroundColor: Color(0xff0fb2ea)),
            ),

          ],
        ),
      ),
      // bottomNavigationBar: BottomNav(),
    );
  }
}



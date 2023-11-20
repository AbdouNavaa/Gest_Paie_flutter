import 'package:gestion_payements/prof_info.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/categories.dart';
import 'package:gestion_payements/auth/profile.dart';
import 'package:gestion_payements/profs.dart';
import 'package:gestion_payements/settings.dart';
import 'package:gestion_payements/splash_screen.dart';
import 'package:gestion_payements/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Cours.dart';
import 'Dashboard.dart';
import 'ProfCours.dart';
import 'auth/login.dart';
import 'auth/settings.dart';
import 'auth/signup.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(),
      child: MyApp(),
    ),
  );
}




class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);
    return MaterialApp(
    //  theme: themeChanger.themeData, // Utilisez le thème actuel
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),  debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginSection(),
        '/signUp': (context) => SignUpSection(),
        '/logout': (context) => LogoutScreen(),
        '/profile': (context) => ProfilePage(),
        '/categories': (context) => Categories(),
        '/settings': (context) => SettingsPage(), // Add the new route
      },
    );
  }
}











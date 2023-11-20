import 'dart:convert';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gestion_payements/auth/users.dart';
import 'package:gestion_payements/home_screen.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/auth/profile.dart';
import 'package:gestion_payements/auth/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Dashboard.dart';
import '../categories.dart';
import '../main.dart';
import '../prof_info.dart';
import 'package:provider/provider.dart';

class LoginSection extends StatefulWidget {
  static const String id = "LoginSection";

  @override
  State<LoginSection> createState() => _LoginSectionState();
}

class _LoginSectionState extends State<LoginSection> {
  var email;

  var password;

  bool hidePassword = true;
  bool isLoginFailed = false;
  String errorMessage = '';
  bool isEmailValid = true;
  bool isPasswordValid = true;
  String emailErrorMessage = '';
  String passwordErrorMessage = '';
  bool validateEmail(String value) {
    // Expression régulière pour valider l'email
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegExp.hasMatch(value);
  }


  bool validatePassword(String value) {
    // Validation de la longueur minimale du mot de passe
    return value.length >= 8;
  }
  bool showFirstContainer = true; // Add this line to manage the visibility

  @override
  Widget build(BuildContext context) {
    // final bool isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(context);
    return Scaffold(

      body: SingleChildScrollView(scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Stack(
              children:[
              Container(
                width: MediaQuery.of(context).size.width,
                height:  MediaQuery.of(context).size.height / 2.5 ,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFFFFFFF)
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                        // bottomLeft: Radius.circular(90),
                    )
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Spacer(),
                    Align(
                      alignment: Alignment.topCenter,
                      child:
                      // Icon(Icons.person,
                      //   size: 90,
                      //   color: Colors.white,
                      // ),
                    Text('LOGIN', style: TextStyle(color: Colors.black,fontSize: 40),)),
                    Spacer(),

                    // Align(
                    //   alignment: Alignment.topRight,
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(
                    //         bottom: 32,
                    //         right: 32
                    //     ),
                    //     child: Text('Login',
                    //       style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 18
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
                Center(
                  child: Card(
                    margin: EdgeInsets.only(top: 230),
                    elevation: 18,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(55),side: BorderSide(color: Colors.black12)),

                    child: Container(
                      height: MediaQuery.of(context).size.height/ 1.7 ,
                      width: MediaQuery.of(context).size.width / 1.12,
                      // margin: EdgeInsets.only(top: 300),
                      padding: EdgeInsets.only(top: 12),

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Column(
                        children: <Widget>[
                          CircleAvatar(maxRadius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.account_circle,size: 70),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            width: MediaQuery.of(context).size.width/1.2,
                            height: 45,

                            padding: EdgeInsets.only(
                              top: 4, left: 16, right: 16, bottom: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: TextField(style: TextStyle(
                            color: Colors.black,
                            ),
                              decoration: InputDecoration(
                                border: InputBorder.none,

                                icon: Icon(
                                  Icons.email,
                                  color: Colors.grey,
                                ),
                                hintText: 'Email',
                              ),
                              onChanged: (value) {
                                email = value;
                                isEmailValid = validateEmail(value); // Appeler une fonction de validation pour l'email
                                if (!isEmailValid) {
                                  emailErrorMessage = 'Email invalide.';
                                } else {
                                  emailErrorMessage = '';
                                }
                              },
                              onTap: () {
                                setState(() {
                                  showFirstContainer = false; // Hide the first container
                                });
                              },
                            ),
                          ),
                          if (!isEmailValid)
                            Text(
                              emailErrorMessage,
                              style: TextStyle(color: Colors.red),
                            ),
                          Container(
                            width: MediaQuery.of(context).size.width/1.2,
                            height: 45,
                            margin: EdgeInsets.only(top: 32),
                            padding: EdgeInsets.only(
                              top: 4, left: 16, right: 16, bottom: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: TextField(style: TextStyle(
                            color: Colors.black,
                            ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                icon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                                  icon: Icon(
                                    hidePassword
                                        ? Icons.vpn_key_off
                                        : Icons.vpn_key,
                                  ),
                                ),
                                hintText: "Password",
                              ),
                              obscureText: hidePassword,
                              onChanged: (value) {
                                password = value;
                                isPasswordValid = validatePassword(value); // Appeler une fonction de validation pour le mot de passe
                                if (!isPasswordValid) {
                                  passwordErrorMessage = 'Mot de passe invalide (8 caractères minimum).';
                                }
                                else {
                                  passwordErrorMessage = '';
                                }
                              },
                              onTap: () {
                                setState(() {
                                  showFirstContainer = false; // Hide the first container
                                });
                              },                    ),
                          ),
                          if (!isPasswordValid)
                            Text(
                              passwordErrorMessage,
                              style: TextStyle(color: Colors.red),
                            ),
                          SizedBox(height: 30,),

                          Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width / 1.2,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFf45d27),
                                    Color(0xFFf5851f)
                                  ],
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(50)
                                )
                            ),
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    isLoginFailed = false; // Réinitialisation de la variable d'erreur
                                  });
                                  // if (isEmailValid && isPasswordValid) {
                                  await login(email, password);
                                  SharedPreferences prefs = await SharedPreferences
                                      .getInstance();
                                  String token = prefs.getString("token")!;
                                  String role = prefs.getString("role")!;
                                  String email1 = prefs.getString("email")!;
                                  String id = prefs.getString("id")!;
                                  String name = prefs.getString("nom")!;
                                  // String lastname = prefs.getString("prenom")!;
                                  print(name);
                                  print(email1);

                                  if (!isLoginFailed) { // Vérifiez si l'authentification a réussi
                                    if (token != null && role == "professeur") {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) =>
                                            // ProfesseurInfoPage(
                                            //     id: id, email: email, role: role),
                                        // builder: (context) => LandingScreen(role: role,name: nom,), // Passer le rôle ici
                                      HomeScreen(role: role,name: name,email: email1,)),);
                                    }
                                    else if (token != null && role == "responsable") {
                                      // Navigator.push(
                                      //     context, MaterialPageRoute(
                                      //     builder: (context) => Categories()));

                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) =>
                                          // ProfesseurInfoPage(
                                          //     id: id, email: email, role: role),
                                          // builder: (context) => LandingScreen(role: role,name: nom,), // Passer le rôle ici
                                          HomeScreen(role: role,name: name,email: email1,)),);

                                    }
                                    else if (token != null && role == "admin") {
                                      // Navigator.push(
                                      //     context, MaterialPageRoute(
                                      //     builder: (context) => Users()));
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) =>
                                          // ProfesseurInfoPage(
                                          //     id: id, email: email, role: role),
                                          // builder: (context) => LandingScreen(role: role,name: nom,), // Passer le rôle ici
                                          HomeScreen(role: role,name: name,email: email1,)),);
                                    }
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(' Email ou Password Incorrectes')),
                                    );}
                                  // }
                                },

                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15)),
                                    padding: EdgeInsets.only(left: 117, right: 117),
                                    // backgroundColor:  Color(0xFFf5851f)),
                                    backgroundColor: Color(0xff0fb2ea)
                                ),
                                // icon: Icon(Icons.save),
                                child: Center(
                                  child: Text('Login'.toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),),
                            ),
                          ),
                          SizedBox(height: 15,),

                          Container(
                            height: 45,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width / 1.2,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFf45d27),
                                    Color(0xFFf5851f)
                                  ],
                                ),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(50)
                                )
                            ),
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => SignUpSection()));
                                },

                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15)),
                                    padding: EdgeInsets.only(left: 117, right: 117),
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87),
                                // icon: Icon(Icons.save),
                                child: Center(
                                  child: Text('Sign Up'.toUpperCase(),
                                    style: TextStyle(
                                      // color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ]
            ),
          ],
        ),
      ),
    );
  }

  login(email, password) async {
    var url = "http://192.168.43.73:5000/auth/login"; // iOS
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var parse = jsonDecode(response.body);

    var nom = parse["data"]["user"]["nom"];
    var role = parse["data"]["user"]["role"];
    var id = parse["data"]["user"]["_id"];
    var email1 = parse["data"]["user"]["email"];
    await prefs.setString('token', parse["token"]);
    await prefs.setString('role', role);
    await prefs.setString('id', id);
    await prefs.setString('email', email1);
    await prefs.setString('nom', nom);
    print('Welcom $email1');
  }
    else {
      // Authentification échouée
      isLoginFailed = true;
      errorMessage = 'Email ou mot de passe incorrect.';
      // Mettez à jour l'état de l'interface utilisateur
      setState(() {});
    }
}}
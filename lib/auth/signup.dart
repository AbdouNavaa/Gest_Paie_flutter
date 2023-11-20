import 'dart:convert';
import 'package:gestion_payements/auth/users.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Dashboard.dart';
import '../categories.dart';
import '../main.dart';
import '../prof_info.dart';
import '../professeures.dart';
import 'login.dart';
class SignUpSection extends StatefulWidget {

  @override
  State<SignUpSection> createState() => _SignUpSectionState();
}

class _SignUpSectionState extends State<SignUpSection> {
  var email;
  var username;
  var prenom;
  var mobile;

  var password;
  var passwordConfirm;

  bool hidePassword = true;
  bool isLoginFailed = false;
  String errorMessage = '';
  bool isEmailValid = true;
  bool isPasswordValid = true;
  bool isNameValid = true;
  bool isPrenomValid = true;
  String emailErrorMessage = '';
  String passwordErrorMessage = '';
  String phoneErrorMessage = '';
  String usernameErrorMessage = '';
  String prenomErrorMessage = '';

  bool validateEmail(String value) {
    // Expression régulière pour valider l'email
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegExp.hasMatch(value);
  }


  bool validatePassword(String value) {
    // Validation de la longueur minimale du mot de passe
    return value.length >= 8;
  }
  bool validateName(String value) {
    // Validation de la longueur minimale du mot de passe
    return value.length >= 3;
  }
  bool showFirstContainer = true; // Add this line to manage the visibility

  @override
  Widget build(BuildContext context) {
    // checkToken() async {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   String? token = prefs.getString("token");
    //   if (token != null) {
    //     Navigator.push(context, MaterialPageRoute(builder: (context) => LandingScreen()));
    //   }
    // }

    // checkToken();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height:  MediaQuery.of(context).size.height / 2.7 ,
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
                      SizedBox(height: 60,),
                      Align(
                          alignment: Alignment.topCenter,
                          child:
                          // Icon(Icons.person,
                          //   size: 90,
                          //   color: Colors.white,
                          // ),
                          Text('SIGN IN', style: TextStyle(color: Colors.black,fontSize: 40),)),
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

                    margin: EdgeInsets.only(top: 130),
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),

                    child: Container(
                      height: MediaQuery.of(context).size.height/ 1.25 ,
                      width: MediaQuery.of(context).size.width / 1.12,
                      // margin: EdgeInsets.only(top: 300),
                      padding: EdgeInsets.only(top: 12),

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: SingleChildScrollView(scrollDirection: Axis.vertical,
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width / 1.2,
                              height: 55,
                              padding: EdgeInsets.only(
                                  top: 4, left: 16, right: 16, bottom: 4
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(50)
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5
                                    )
                                  ]
                              ),
                              child: TextField(style: TextStyle(
                              color: Colors.black,
                              ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  icon: Icon(Icons.account_circle_outlined,
                                    color: Colors.grey,
                                  ),
                                  hintText: 'Nom',
                                ),
                                onChanged: (value) {
                                  username = value;

                                  isNameValid = validateName(value); // Appeler une fonction de validation pour le mot de passe
                                  if (!isNameValid) {
                                    usernameErrorMessage = 'Veuillez entrer un nom Valide.';
                                  }
                                  else {
                                    usernameErrorMessage = '';
                                  }
                                },
                                onTap: () {
                                  setState(() {
                                    showFirstContainer =
                                    false; // Hide the first container
                                  });
                                },
                              ),
                            ),
                            if (!isNameValid) // Display error message conditionally
                              Text(
                                usernameErrorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 1.2,
                              height: 55,
                              margin: EdgeInsets.only(top: 20),
                              padding: EdgeInsets.only(
                                  top: 8, left: 16, right: 16, bottom: 4
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(50)
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5
                                    )
                                  ]
                              ),
                              child: TextField(style: TextStyle(
                              color: Colors.black,
                              ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    icon: Icon(Icons.account_circle_outlined,
                                      color: Colors.grey,
                                    ),
                                    hintText: 'Prenom',
                                  ),
                                  onChanged: (value) {
                                    prenom = value;
                                    isPrenomValid = validateName(value); // Appeler une fonction de validation pour le mot de passe
                                    if (!isPrenomValid) {
                                      prenomErrorMessage = 'Veuillez entrer un prenom Valide.';
                                    }
                                    else {
                                      prenomErrorMessage = '';
                                    } }
                              ),
                            ),
                            if (!isPrenomValid) // Display error message conditionally
                              Text(
                                prenomErrorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 1.2,
                              height: 55,
                              margin: EdgeInsets.only(top: 20),
                              padding: EdgeInsets.only(
                                  top: 8, left: 16, right: 16, bottom: 4
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(50)
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5
                                    )
                                  ]
                              ),
                              child: TextField(style: TextStyle(
                              color: Colors.black,
                              ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    icon: Icon(Icons.phone,
                                      color: Colors.grey,
                                    ),
                                    hintText: 'Mobile',
                                  ),
                                  onChanged: (value) {
                                    mobile = value;
                                    isPasswordValid = validatePassword(
                                        value); // Appeler une fonction de validation pour le mot de passe
                                    if (!isPasswordValid) {
                                      phoneErrorMessage =
                                      '8 caractères minimum.';
                                    }
                                    else {
                                      passwordErrorMessage = '';
                                    }
                                  }
                              ),
                            ),
                            if (!isPasswordValid)
                              Text(
                                phoneErrorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            //password
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 1.2,
                              height: 55,
                              margin: EdgeInsets.only(top: 20),
                              padding: EdgeInsets.only(
                                  top: 4, left: 16, right: 16, bottom: 4
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(50)
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5
                                    )
                                  ]
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
                                        hidePassword ? Icons.vpn_key_off : Icons
                                            .vpn_key,)), hintText: "Password",),
                                  obscureText: hidePassword,
                                  onChanged: (value) {
                                    password = value;
                                    isPasswordValid = validatePassword(
                                        value); // Appeler une fonction de validation pour le mot de passe
                                    if (!isPasswordValid) {
                                      passwordErrorMessage =
                                      '8 caractères minimum.';
                                    }
                                    else {
                                      passwordErrorMessage = '';
                                    }
                                  }),
                            ),
                            if (!isPasswordValid)
                              Text(
                                passwordErrorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            //confirme Password
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 1.2,
                              height: 55,
                              margin: EdgeInsets.only(top: 20),
                              padding: EdgeInsets.only(
                                  top: 4, left: 16, right: 16, bottom: 4
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(50)
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5
                                    )
                                  ]
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
                                        hidePassword ? Icons.vpn_key_off : Icons
                                            .vpn_key,)),
                                    hintText: "Confirme Password",),
                                  obscureText: hidePassword,
                                  onChanged: (value) {
                                    passwordConfirm = value;
                                    isPasswordValid = validatePassword(
                                        value); // Appeler une fonction de validation pour le mot de passe
                                    if (!isPasswordValid) {
                                      passwordErrorMessage =
                                      '8 caractères minimum.';
                                    }
                                    else {
                                      passwordErrorMessage = '';
                                    }
                                  }),
                            ),
                            if (!isPasswordValid)
                              Text(
                                passwordErrorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 1.2,
                              height: 55,
                              margin: EdgeInsets.only(top: 20),
                              padding: EdgeInsets.only(
                                  top: 4, left: 16, right: 16, bottom: 4
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(50)
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5
                                    )
                                  ]
                              ),
                              child: TextField(style: TextStyle(
                              color: Colors.black,
                              ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  icon: Icon(Icons.email_outlined,
                                    color: Colors.grey,
                                  ),
                                  hintText: 'Email',
                                ),
                                onChanged: (value) {
                                  email = value;
                                  isEmailValid = validateEmail(
                                      value); // Appeler une fonction de validation pour l'email
                                  if (!isEmailValid) {
                                    emailErrorMessage = 'Email invalide.';
                                  } else {
                                    emailErrorMessage = '';
                                  }
                                },

                              ),
                            ),
                            if (!isEmailValid)
                              Text(
                                emailErrorMessage,
                                style: TextStyle(color: Colors.red),
                              ),
                            SizedBox(height: 30,),

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
                                  onPressed: () async {
                                    setState(() {
                                      isLoginFailed =
                                      false; // Réinitialisation de la variable d'erreur
                                      AddProfesseur(username, prenom, email,
                                          num.parse(mobile));
                                    });
                                    await signup(username, prenom, mobile, password, passwordConfirm, email);

                                    SharedPreferences prefs = await SharedPreferences
                                        .getInstance();
                                    String token = prefs.getString("token")!;
                                    String role = prefs.getString("role")!;
                                    String email1 = prefs.getString("email")!;
                                    String id = prefs.getString("id")!;
                                    String name = prefs.getString("nom")!;
                                    print(name);
                                    print(email1);
                                    if (!isLoginFailed) { // Vérifiez si l'authentification a réussi
                                      if (token != null && role == "professeur") {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context) =>
                                              ProfesseurInfoPage(
                                                  id: id, email: email, role: role),
                                          // builder: (context) => LandingScreen(role: role,name: nom,), // Passer le rôle ici
                                        ),);
                                      }
                                      else if (token != null && role == "responsable") {
                                        Navigator.push(
                                            context, MaterialPageRoute(
                                            builder: (context) => Categories()));
                                      }
                                      else if (token != null && role == "admin") {
                                        Navigator.push(
                                            context, MaterialPageRoute(
                                            builder: (context) => Users()));
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(
                                            'Entrer des Donnees Valides')),
                                      );
                                    }
                                  },

                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15)),
                                      padding: EdgeInsets.only(left: 117, right: 117),
                                      backgroundColor: Color(0xff0fb2ea)),
                                  // icon: Icon(Icons.save),
                                  child: Center(
                                    child: Text('Sign Up'.toUpperCase(),
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
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => LoginSection()));
                                  },

                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15)),
                                      padding: EdgeInsets.only(left: 117, right: 117),
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black87),
                                  // icon: Icon(Icons.save),
                                  child: Center(
                                    child: Text('Login'.toUpperCase(),
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
                  ),
                )
              ],
            )
          ],
        ),
      ),

    );
  }

  signup(username, prenom, mobile, password, passwordConfirm, email) async {
    var url = "http://192.168.43.73:5000/auth/signup"; // iOS
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nom': username,
        'prenom': prenom,
        'mobile': mobile,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'email': email,
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
      print('Welcom $nom');
    } else {
      // Authentification échouée
      isLoginFailed = true;
      errorMessage = 'Email ou mot de passe incorrect.';
      // Mettez à jour l'état de l'interface utilisateur
      setState(() {});
    }
  }
}
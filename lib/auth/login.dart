import 'dart:convert';
import 'package:gestion_payements/home_screen.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../theme_helper.dart';
import 'forgot_password_page.dart';
import 'header_widget.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class LoginSection extends StatefulWidget {
  const LoginSection({Key? key}) : super(key: key);

  @override
  _LoginSectionState createState() => _LoginSectionState();
}

class _LoginSectionState extends State<LoginSection> {
  double _headerHeight = 350;
  Key _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

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

  bool showFirstContainer = true; // Add this line to manage the visibility

  bool validatePassword(String value) {
    // Validation de la longueur minimale du mot de passe
    return value.length >= 4;
  }
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: _headerHeight,
              child: HeaderWidget(_headerHeight, true, 'assets/supnum.png'),
            ),
            SafeArea(
              child: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  margin: EdgeInsets.fromLTRB(
                      10, 10, 10, 10), // This will be the login form
                  child: Column(
                    children: [
                      // Text(
                      //   'Welcome GoPlanners!',
                      //   style: TextStyle(
                      //       fontSize: 60,
                      //       color: Colors.indigoAccent,
                      //       fontWeight: FontWeight.bold),
                      // ),
                      // Text(
                      //   '',
                      //   style: TextStyle(color: Colors.grey),
                      // ),
                      SizedBox(height: 30.0),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Card(
                                    elevation: 5,
                                    shadowColor: Colors.black,
                                    // color: Colors.black87,
                                    // shape: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        width:MediaQuery.of(context).size.width /6.2,

                                        child: IconButton(
                                          onPressed: () {

                                          },
                                          icon: Icon(
                                                Icons.email_outlined,
                                          ),padding: EdgeInsets.only(right: 15),

                                        ),


                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:MediaQuery.of(context).size.width /1.5,
                                    child: TextField(
                                      controller: _emailController!,
                                      decoration: ThemeHelper().textInputDecoration(
                                          'E-mail', ''),
                                      onChanged: (value) {
                                        _emailController.text = value;
                                        isEmailValid = validateEmail(value); // Appeler une fonction de validation pour l'email//abdou
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
                                    decoration:
                                    ThemeHelper().inputBoxDecorationShaddow(),
                                  ),
                                ],
                              ),
                              if (!isEmailValid)
                                Text(
                                  emailErrorMessage,
                                  style: TextStyle(color: Colors.red),
                                ),      SizedBox(height: 30.0),
                              Row(
                                children: [
                                  Card(
                                    elevation: 5,
                                    shadowColor: Colors.black,
                                    // color: Colors.black87,
                                    // shape: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                        ),
                                        width:MediaQuery.of(context).size.width /6.2,

                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              hidePassword = !hidePassword;
                                            });
                                          },
                                          icon: Icon(
                                            hidePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                          ),padding: EdgeInsets.only(right: 15),

                                        ),


                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:MediaQuery.of(context).size.width /1.5,
                                    child: TextField(
                                      controller: _passwordController,
                                      obscureText: hidePassword,
                                      decoration: ThemeHelper().textInputDecoration(
                                          'Mot de Passe', ''),

                                      onChanged: (value) {
                                        _passwordController.text = value;
                                        isPasswordValid = validatePassword(value); // Appeler une fonction de validation pour le m  de passe
                                        if (!isPasswordValid) {
                                          passwordErrorMessage = 'Mot de passe invalide (4 caractères minimum).';
                                        }
                                        else {
                                          passwordErrorMessage = '';
                                        }
                                      },
                                      onTap: () {
                                        setState(() {
                                          showFirstContainer = false; // Hide the first container
                                        });
                                      },
                                    ),

                                    decoration:
                                    ThemeHelper().inputBoxDecorationShaddow(),

                                  ),
                                ],
                              ),
                              if (!isPasswordValid)
                                Text(
                                  passwordErrorMessage,
                                  style: TextStyle(color: Colors.red),
                                ),    SizedBox(height: 15.0),
                              Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 10, 20),
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ForgotPasswordPage()),
                                    );
                                  },
                                  child: Text(
                                    "Mot de passe oublie?",
                                    style: TextStyle(
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration:
                                ThemeHelper().buttonBoxDecoration(context),
                                child: ElevatedButton(
                                  style: ThemeHelper().buttonStyle(),
                                  child: Padding(
                                    padding:
                                    EdgeInsets.fromLTRB(40, 10, 40, 10),
                                    child: Text(
                                      'Log In'.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      isLoginFailed = false; // Réinitialisation de la variable d'erreur
                                    });
                                    // if (isEmailValid && isPasswordValid) {
                                    await login(_emailController.text, _passwordController.text);
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
                                        String? profId = await getProfId(token, id)!;

                                        int? notif = await fetchPaiements(profId,token);
                                        int? CNS = await CoursNS(profId,token);

                                        print("AbdouId: ${notif}");
                                        if (profId != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HomeScreen(
                                                role: role,
                                                name: name,
                                                email: email1,
                                                profId: profId, // Passer l'ID du professeur à la page HomeScreen
                                                notif: notif, // Passer l'ID du professeur à la page HomeScreen
                                                CNS: CNS, // Passer l'ID du professeur à la page HomeScreen
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Gérer le cas où l'ID du prof n'est pas disponible
                                          // Peut-être afficher un message d'erreur ou rediriger vers une autre page
                                        }
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
                                ),
                              ),
                              // Container(
                              //   margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                              //   //child: Text('Don\'t have an account? Create'),
                              //   child: Text.rich(TextSpan(children: [
                              //     TextSpan(text: "Don\'t have an account? "),
                              //     TextSpan(
                              //       text: 'signup',
                              //       // recognizer: TapGestureRecognizer()
                              //       //   ..onTap = () {
                              //       //     Navigator.push(
                              //       //         context,
                              //       //         MaterialPageRoute(
                              //       //             builder: (context) =>
                              //       //                 RegistrationPage()));
                              //       //   },
                              //       style: TextStyle(
                              //           fontWeight: FontWeight.bold,
                              //           color: Theme.of(context).primaryColor),
                              //     ),
                              //   ])),
                              // ),
                            ],
                          )),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );

  }
  void showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("you have logged in successfully"),
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomeScreen()));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text(
        "wrong username or password",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text("please put correct credentials"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
  }

}

Future<String?> getProfId(String token,String id) async {
  var url = "http://192.168.43.73:5000/user/$id/professeur"; // L'URL de ton endpoint pour récupérer l'ID du prof
  final response = await http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body);
    String profId = data['prof']['id'];
    print("PID:${profId}");
    return profId;
  } else {
    return null;
  }
}
List<dynamic> paies = [];
List<dynamic> courses = [];

Future<int?> fetchPaiements(id, String token) async {
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // String token = prefs.getString("token")!;

  var url = Uri.parse('http://192.168.43.73:5000/paiement/$id/professeur');

  var responseInitialise = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json', // Ajoutez le type de contenu
    },
    body: jsonEncode({"notification": ""}), // Encodez votre corps en JSON
  );

  // var responseValide = await http.post(
  //   url,
  //   headers: {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json', // Ajoutez le type de contenu
  //   },
  //   body: jsonEncode({}), // Ou d'autres valeurs pour "validé"
  // );

  if (responseInitialise.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(responseInitialise.body);
    paies = jsonResponse['paiements'];
    print('Paiements avec status "initialisé": ${paies.length}');
    return paies.length;
  } else {
    print('Request for "initialisé" failed with status: ${responseInitialise.statusCode}');
  }

  // if (responseValide.statusCode == 200) {
  //   Map<String, dynamic> jsonResponse = jsonDecode(responseValide.body);
  //   paies = jsonResponse['paiements'];
  //   print('Paiements avec status "validé": $paies');
  // }
  // else {
  //   print('Request for "validé" failed with status: ${responseValide.statusCode}');
  // }
}
Future<int?> CoursNS(id, String token) async {
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // String token = prefs.getString("token")!;

  var url = Uri.parse('http://192.168.43.73:5000/professeur/${id}/cours-non');

  var responseInitialise = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json', // Ajoutez le type de contenu
    },
  );

  if (responseInitialise.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(responseInitialise.body);
    courses = jsonResponse['cours'];
    print('${courses.length} Cours Non Signe');
    return courses.length;
  } else {
    print('Request for "initialisé" failed with status: ${responseInitialise.statusCode}');
  }

  // if (responseValide.statusCode == 200) {
  //   Map<String, dynamic> jsonResponse = jsonDecode(responseValide.body);
  //   paies = jsonResponse['paiements'];
  //   print('Paiements avec status "validé": $paies');
  // }
  // else {
  //   print('Request for "validé" failed with status: ${responseValide.statusCode}');
  // }
}


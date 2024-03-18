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

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
//   scopes: <String>[
//     'email',
//     'https://www.googleapis.com/auth/contacts.readonly',
//   ],
// );


import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginSection extends StatefulWidget {
  @override
  _LoginSectionState createState() => _LoginSectionState();
}

class _LoginSectionState extends State<LoginSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;


   TextEditingController _emailController = TextEditingController();
   TextEditingController _passwordController = TextEditingController();
  bool isPass = false;
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
    return value.length >= 4;
  }
  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: .7, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    )..addListener(
          () {
        setState(() {});
      },
    )..addStatusListener(
          (status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      },
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          child: SizedBox(
            height: _height,
            child: Column(
              children: [
                Container(
                  height: 300,
                  child: HeaderWidget(300, false, ''),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(),
                      Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff000000),
                        ),
                      ),
                      SizedBox(),
                      // component1(Icons.account_circle_outlined, 'User name...',
                      //     false, false),
                      component1(Icons.email_outlined,_emailController!,(){}, (value){
                      _emailController.text = value;
                      isEmailValid = validateEmail(value); // Appeler une fonction de validation pour l'email//abdou
                      if (!isEmailValid) {
                      emailErrorMessage = 'Email invalide.';
                      } else {
                      emailErrorMessage = '';
                      }
                      },'Email...', false, true,isEmailValid),
                      if (!isEmailValid)
                        Text(
                          emailErrorMessage,
                          style: TextStyle(color: Colors.white),
                        ),
                      SizedBox(height: 2.0),
                      component1(
                          Icons.lock_outline, _passwordController!,() => isPass = !isPass
                      ,(value) {
                        _passwordController.text = value;
                        isPasswordValid = validatePassword(value); // Appeler une fonction de validation pour le m  de passe
                        if (!isPasswordValid) {
                          passwordErrorMessage = 'Mot de passe invalide (4 caractères minimum).';
                        }
                        else {
                          passwordErrorMessage = '';
                        }
                      },'Password...', isPass, false,isPasswordValid),
                      if (!isPasswordValid)
                        Text(
                          passwordErrorMessage,
                          style: TextStyle(color: Colors.white),
                        ),    SizedBox(height: 15.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Mot de passe oublie?',
                              style: TextStyle(
                                color: Colors.blue.shade200,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordPage()),
                                  );
                                },
                            ),
                          ),
                          SizedBox(width: _width / 10),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: _width * .07),
                          height: _width * .7,
                          width: _width * .7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Transform.scale(
                          scale: _animation.value,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: ()  async {
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
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage != null ? errorMessage : 'Email ou mot de passe incorrect')),
                                );
                              }
                              // }
                            },
                            child: Container(
                              height: _width * .2,
                              width: _width * .2,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                'SIGN-IN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget component1(
      IconData icon,TextEditingController text,VoidCallback onPress,void Function(String)? onChange, String hintText, bool isPassword, bool isEmail,bool valid) {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      height: _width / 7,
      width: _width / 1.22,
      alignment: Alignment.center,
      padding: EdgeInsets.only(right: _width / 30),
      decoration: BoxDecoration(
        color: Colors.white,border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: text,
        onChanged: onChange,
        style: TextStyle(color: Colors.black12.withOpacity(.9)),
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: IconButton(
            icon: Icon(
              icon,
              color: Colors.black12.withOpacity(.7),
            ),
            onPressed:onPress,
          ),
          border: InputBorder.none,
          hintMaxLines: 1,
          hintText: hintText,iconColor: Colors.black12,
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.black12.withOpacity(.5),
          ),
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
      var parse = jsonDecode(response.body);
      errorMessage = parse["message"];
      // Mettez à jour l'état de l'interface utilisateur
      setState(() {});
    }

  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
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


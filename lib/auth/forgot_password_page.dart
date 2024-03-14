
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme_helper.dart';
import 'forgot_password_verification_page.dart';
import 'header_widget.dart';
import 'package:http/http.dart' as http;


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
   TextEditingController _token = TextEditingController();


  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();

  }


  @override
  Widget build(BuildContext context) {
    double _headerHeight = 300;
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
                  margin: EdgeInsets.fromLTRB(25, 10, 25, 10),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Changer le Mot de Passe',
                              style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  // color: Colors.black54
                                  color: Colors.indigoAccent
                              ),
                              // textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20,),
                            Text('Entrer ton email',
                              style: TextStyle(
                                // fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54
                              ),
                              // textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20,),
                            Text('Nous vous enverrons par e-mail un code de verification pour verifier votre authenticite.',
                              style: TextStyle(
                                color: Colors.black38,
                                // fontSize: 40,
                              ),
                              // textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: TextFormField(
                                controller: _emailController,
                                decoration: ThemeHelper().textInputDecoration("Email", "Enter your email"),
                                validator: (val){
                                  if(val!.isEmpty){
                                    return "Email can't be empty";
                                  }
                                  else if(!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(val)){
                                    return "Enter a valid email address";
                                  }
                                  return null;
                                },
                              ),
                              decoration: ThemeHelper().inputBoxDecorationShaddow(),
                            ),
                            SizedBox(height: 40.0),
                            Container(
                              decoration: ThemeHelper().buttonBoxDecoration(context),
                              child: ElevatedButton(
                                style: ThemeHelper().buttonStyle(),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      40, 10, 40, 10),
                                  child: Text(
                                    "Envoyer".toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  if(_formKey.currentState!.validate()) {
                                    await forgotPassword(_emailController.text);

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ForgotPasswordVerificationPage()),
                                    );
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: "Remember your password? "),
                                  TextSpan(
                                    text: 'Login',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => LoginSection()),

                                        );
                                      },
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, color: Colors.lightBlue


                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: "Remember your password? "),
                                  TextSpan(
                                    text: 'Login',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          // MaterialPageRoute(builder: (context) => LoginSection()),
                                            MaterialPageRoute(builder: (context) => ForgotPasswordVerificationPage()),

                                        );
                                      },
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, color: Colors.lightBlue


                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        )
    );
  }

  forgotPassword(email) async {
    var url = "http://192.168.43.73:5000/auth/forgotPassword"; // iOS
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var parse = jsonDecode(response.body);

       // _token.text = parse["resetToken"];
      // print('Welcom $_token');
    }
    else {
      // Authentification échouée
      // isLoginFailed = true;
      // errorMessage = 'Email ou mot de passe incorrect.';
      // Mettez à jour l'état de l'interface utilisateur
      setState(() {});
    }
  }

}

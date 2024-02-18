import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/auth/login.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../theme_helper.dart';
import 'header_widget.dart';


class ForgotPasswordVerificationPage extends StatefulWidget {
  String token;
   ForgotPasswordVerificationPage({Key? key, required this.token}) : super(key: key);

  @override
  _ForgotPasswordVerificationPageState createState() => _ForgotPasswordVerificationPageState();
}

class _ForgotPasswordVerificationPageState extends State<ForgotPasswordVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _pinSuccess = false;
  TextEditingController _token = TextEditingController();
  TextEditingController _pass = TextEditingController();
  TextEditingController _conf = TextEditingController();

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
                child: HeaderWidget(
                    _headerHeight, true, 'assets/supnum.png'),
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
                            Text('Verification',
                              style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54
                              ),
                              // textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10,),
                            Text(
                              'Entrer le code de verification que nous venonsde vous envoyer sur votre addresse e-mail.',
                              style: TextStyle(
                                // fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54
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
                            // OTPTextField(
                            //   length: 4,
                            //   width: 300,
                            //   fieldWidth: 50,
                            //   style: TextStyle(
                            //       fontSize: 30
                            //   ),
                            //   textFieldAlignment: MainAxisAlignment.spaceAround,
                            //   fieldStyle: FieldStyle.underline,
                            //   onCompleted: (pin) {
                            //     setState(() {
                            //       _pinSuccess = true;
                            //     });
                            //   },
                            // ),
                            SizedBox(height: 10.0),
                          TextFormField(
                            controller: _pass,
                            decoration: ThemeHelper().textInputDecoration("Mot de Passe", ""),
                          ),
                            SizedBox(height: 10.0),
                            Container(
                              child: TextFormField(
                                controller: _conf,
                                decoration: ThemeHelper().textInputDecoration("Confirmation de mot de passe", ""),
                              ),
                              decoration: ThemeHelper().inputBoxDecorationShaddow(),
                            ),

                            SizedBox(height: 50.0),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Si vous n'avez pas recu de code! ",
                                    style: TextStyle(
                                      color: Colors.black38,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Renvoyez',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ThemeHelper().alartDialog("Reussi",
                                                "code de verification renvoye avec  succes.",
                                                context);
                                          },
                                        );
                                      },
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 40.0),
                            Container(
                              decoration: _pinSuccess ? ThemeHelper().buttonBoxDecoration(context):ThemeHelper().buttonBoxDecoration(context, "#AAAAAA","#757575"),
                              child: ElevatedButton(
                                style: ThemeHelper().buttonStyle(),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      40, 10, 40, 10),
                                  child: Text(
                                    "Verifier".toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onPressed: () async {
                                  await resetPassword(widget.token,_pass.text, _conf.text);

                                _pinSuccess?  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => LoginSection()
                                      ),
                                          (Route<dynamic> route) => false
                                  )
                                    : ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(' l\'operation a un erreur')),
                                );;
                                }
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

  resetPassword( token,password,conf,) async {
    var url = "http://192.168.43.73:5000/auth/resetPassword/$token"; // iOS
    final response = await http.patch(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'password': password,
        'passwordConfirm': conf,
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {

      setState(() {
        _pinSuccess = true;
      });
    }
    else {
      setState(() {
        _pinSuccess = false;
      });
    }
  }

}

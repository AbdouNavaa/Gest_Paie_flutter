import 'dart:convert';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gestion_payements/home_screen.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../prof_info.dart';
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


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
   TextEditingController _emailController = TextEditingController();
   TextEditingController _passwordController = TextEditingController();

   // savePref(String role, String email,String name,String id,String? profId, int? notif, int? CNS) async {
   //   SharedPreferences prefs = await SharedPreferences
   //       .getInstance();
   //   String token = prefs.getString("token")!;
   //    role = prefs.getString("role")!;
   //    email = prefs.getString("email")!;
   //    id = prefs.getString("id")!;
   //    name = prefs.getString("nom")!;
   //   // String lastname = prefs.getString("prenom")!;
   //   print(name);
   //   print(email);
   //
   //   if (token != null && role == "professeur") {
   //      profId = (await getProfId(token, id)!)!;
   //
   //      notif = (await fetchPaiements(profId,token))!;
   //     CNS = (await CoursNS(profId,token))!;
   //   }
   // }
  bool isPass = false;
  bool hidePassword = true;
  bool isLoginFailed = false;
  String errorMessage = '';
  bool isEmailValid = true;
  bool isPasswordValid = true;
  String emailErrorMessage = '';
  String passwordErrorMessage = '';


  String _Banque = 'BMCI';
  TextEditingController _account = TextEditingController();
  TextEditingController _mobile = TextEditingController();

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
    // savePref();
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
    bool isKeyboadVisible = KeyboardVisibilityProvider.isKeyboardVisible(context);
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
                // isKeyboadVisible? SizedBox() :
                Container(
                  height: 300,
                  child: HeaderWidget(300, true, 'assets/supnum.png',70),
                  // child: HeaderWidget(300, false, ''),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(),
                      Text(
                        'CONNECTER',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          // color: Color(0xff000000),
                          color: Colors.indigoAccent,
                        ),
                      ),
                      SizedBox(),
                      // component1(Icons.account_circle_outlined, 'User name...',
                      //     false, false),
                   Form(key: _formKey,
                       child: Column(children: [
                     component1(Icons.email_outlined,_emailController!,(){}, (value){
                       if (value == null || value.isEmpty) {
                         return 'Le champ ne peut pas être vide';
                       }
                       if (!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(value)) {
                         return 'Entrez une adresse email valide';
                       }
                       return null;
                     }, 'Email...', false, true,isEmailValid,30),
                     SizedBox(height: 2.0),
                     component1(Icons.lock_outline, _passwordController!, () => isPass = !isPass,(value) {
                       if (value == null || value.isEmpty) {
                         return 'Le champ ne peut pas être vide';
                       }
                       if (value.length < 8) {
                         return 'Le champ doit contenir au moins 8 caractères';
                       }
                       return null;
                     },'Password...', isPass, false,isPasswordValid,11),

                   ],)),

                      // if (!isEmailValid)
                      //   Text(
                      //     emailErrorMessage,
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      //
                      // if (!isPasswordValid)
                      //   Text(
                      //     passwordErrorMessage,
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      SizedBox(height: 15.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Mot de passe oublie?',
                              style: TextStyle(
                                color: Colors.indigoAccent,
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
                        child: InkWell(
                          // splashColor: Colors.transparent,
                          // highlightColor: Colors.transparent,
                          onTap: ()  async {
                            if (_formKey.currentState!.validate()){
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
                              String photo = prefs.getString("photo")!;
                              // String lastname = prefs.getString("prenom")!;
                              print(name);
                              print("Photo: ${photo}");

                              if (!isLoginFailed) { // Vérifiez si l'authentification a réussi
                                if (token != null && role == "professeur") {
                                  String? profId = await getProfId(token, id)!;

                                  int? notif = await fetchPaiements(profId,token);
                                  int? CNS = await CoursNS(profId,token);

                                  print("AbdouId: ${notif}");
                                  if (profId != null) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(
                                          role: role,
                                          name: name,
                                          email: email1,
                                          // photo: photo,
                                          profId: profId,
                                          notif: notif,
                                          CNS: CNS,
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
                                  Navigator.pushReplacement(context, MaterialPageRoute(
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
                            }
                          },
                          child: Container(
                            height: _width * .4,
                            width: _width -260,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.indigoAccent,
                              gradient: LinearGradient(
                                // stops: [.65,.33],
                                tileMode: TileMode.repeated,  begin: const FractionalOffset(0.0, 0.0),
                                end: const FractionalOffset(1.0, 0.0),
                                colors: [Colors.indigo, Colors.indigoAccent],),
                              boxShadow: [BoxShadow(color: Colors.white)],
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

  Widget component1(IconData icon,TextEditingController text,VoidCallback onPress, onChange, String hintText, bool isPassword,
      bool isEmail,bool vali,MaxL ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: TextFormField(
        controller: text,
        // validator: myvalidator,
        maxLength: MaxL,
        validator: onChange,
        style: TextStyle(color: Colors.black12.withOpacity(.9)),
        // maxLines: 1,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(prefixIcon: IconButton(
          icon: Icon(
          icon,
          color: Colors.black12.withOpacity(.3),
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
          enabledBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide(color: Colors.black,),),
            focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide(color: Colors.black,),),
            errorBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide(color: Colors.redAccent,),),
            focusedErrorBorder: UnderlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide(color: Colors.redAccent,),),
            contentPadding: EdgeInsets.symmetric(vertical: 18)
        ),
      ),
    );
  }
// Validation spécifique pour l'email
  String? validateMail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le champ ne peut pas être vide';
    }
    if (!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(value)) {
      return 'Entrez une adresse email valide';
    }
    return null;
  }

// Validation spécifique pour le mot de passe et la confirmation
  String? validatePass(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le champ ne peut pas être vide';
    }
    if (value.length < 8) {
      return 'Le champ doit contenir au moins 8 caractères';
    }
    return null;
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
      String token = prefs.getString("token")!;

      var nom = parse["data"]["user"]["nom"];
      var role = parse["data"]["user"]["role"];
      var id = parse["data"]["user"]["_id"];
      var email1 = parse["data"]["user"]["email"];
      var photo = parse["data"]["user"]["photo"];
      await prefs.setString('token', parse["token"]);
      await prefs.setString('role', role);
      await prefs.setString('id', id);
      await prefs.setString('email', email1);
      await prefs.setString('nom', nom);
      await prefs.setString('photo', photo);
      print('Welcom $email1');
    }
    else {
      // Authentification échouée
      isLoginFailed = true;
      var parse = jsonDecode(response.body);
      errorMessage = parse["message"];
      // Mettez à jour l'état de l'interface utilisateur
      if(parse['error']['statusCode'] == 406)
      setState(() {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                insetPadding: EdgeInsets.only(top: 190,),
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                title:
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Ajouter Infos", style: TextStyle(fontSize: 25),),
                    Spacer(),
                    InkWell(
                      child: Icon(Icons.close),
                      onTap: (){
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),

                content: Container(
                  height: 450,
                  width: MediaQuery.of(context).size.width,
                  // padding: const EdgeInsets.all(25.0),
                  child: SingleChildScrollView(
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        //hmmm
                        SizedBox(height: 35),
                        TextFormField(
                          controller: _account,
                          decoration: InputDecoration(
                              filled: true,

                              // fillColor: Color(0xA3B0AF1),
                              fillColor: Colors.blueGrey.shade50,
                              hintText: "Compte",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,gapPadding: 1,
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                        ),

                        SizedBox(height: 35),
                        DropdownButtonFormField<String>(
                          value: _Banque,


                          items: [
                            DropdownMenuItem<String>(
                              child: Text('BMCI'),
                              value: 'BMCI',
                            ),
                            DropdownMenuItem<String>(
                              child: Text('BNM'),
                              value: 'BNM',
                            ),
                            DropdownMenuItem<String>(
                              child: Text('ORABANK'),
                              value: 'ORABANK',
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _Banque = value!;
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.blueGrey.shade50,
                            // fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,gapPadding: 1,
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                        ),

                        SizedBox(height: 35),
                        ElevatedButton(
                          onPressed: () async{
                            Navigator.of(context).pop();

                            await signUp(_emailController.text,_passwordController.text, _Banque,_account.text,);

                            setState(() {
                              Navigator.pop(context);
                              //  fetchProfs();
                            });
                          },
                          child: Text("Ajouter"),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff0fb2ea),
                            foregroundColor: Colors.white,
                            elevation: 10,
                            minimumSize:  Size( MediaQuery.of(context).size.width , MediaQuery.of(context).size.width/7),
                            // padding: EdgeInsets.only(left: MediaQuery.of(context).size.width /5,
                            //     right: MediaQuery.of(context).size.width /5,bottom: 20,top: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        )
                      ],
                    ),


                  ),
                ),

              );
            });

      });
    }

  }
  signUp(email, password,banque,account) async {
    var url = "http://192.168.43.73:5000/auth/signup"; // iOS
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        // 'mobile': mobile,
        'banque': banque,
        'accountNumero': account,
      }),
    );
    print(response.body);
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var parse = jsonDecode(response.body);
      String token = prefs.getString("token")!;

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


  if (responseInitialise.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(responseInitialise.body);
    paies = jsonResponse['paiements'];
    print('Paiements avec status "initialisé": ${paies.length}');
    return paies.length;
  } else {
    print('Request for "initialisé" failed with status: ${responseInitialise.statusCode}');
  }

}
Future<int?> CoursNS(id, String token) async {
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // String token = prefs.getString("token")!;

  var url = Uri.parse('http://192.168.43.73:5000/cours?professeur=${id}&isSigned=en attente');

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


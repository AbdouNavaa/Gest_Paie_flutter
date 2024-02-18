import 'dart:convert';
import 'package:gestion_payements/auth/emploi.dart';
import 'package:gestion_payements/element.dart';
import 'package:gestion_payements/group.dart';
import 'package:gestion_payements/matieres.dart';
import 'package:gestion_payements/more_page.dart';
import 'package:gestion_payements/paie.dart';
import 'package:gestion_payements/paiements.dart';
import 'package:gestion_payements/professeures.dart';
import 'package:gestion_payements/settings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:gestion_payements/auth/profile.dart';
import 'package:gestion_payements/constants.dart';
import 'package:gestion_payements/prof_info.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Cours.dart';
import 'Dashboard.dart';
import 'ProfCours.dart';
import 'ProfCoursNon.dart';
import 'ProfEmp.dart';
import 'ProfPaie.dart';
import 'auth/login.dart';
import 'auth/users.dart';
import 'categories.dart';
import 'filliere.dart';


class HomeScreen extends StatefulWidget {
   HomeScreen({Key? key, this.role, this.name, this.email, this.profId, this.notif, this.CNS}) : super(key: key);
  final String? role;
  final String? name;
  final String? email;
  final String? profId;
  late int? notif;
  late int? CNS;
  static String routeName = 'HomeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  List<User>? useres;
  List<Professeur>? profs;
  List<filliere>? fillieres;
  List<emploi>? emplois;
  int coursNum = 0;
  int coursCN = 0;
  int coursPN = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUser().then((data) {
      setState(() {
        useres = data; // Assigner la liste renvoyée par Useresseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchfilliere().then((data) {
      setState(() {
        fillieres = data; // Assigner la liste renvoyée par Matiereesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchemploi().then((data) {
      setState(() {
        emplois = data; // Assigner la liste renvoyée par Matiereesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchProfs().then((data) {
      setState(() {
        profs = data; // Assigner la liste renvoyée par Professeuresseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });


  }

  Color _primaryColor =Colors.lightBlueAccent;

  Color _accentColor =Colors.white;
  late int index;
  late List<Widget> _screens;
  final double _drawerIconSize = 24;
  final double _drawerFontSize = 17;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: widget.role == "professeur"
      //     ? AppBar(
      //   backgroundColor:Color(0xff40deef),
      //   // colors: [ Color(0xff0fb2ea)],
      //   // ,
      //   actions: [
      //
      //   ],
      // )
      //     : null,

      drawer: Drawer(width: 250,
        child: Container(color: Colors.white,
          child: ListView(
            children: [
              DrawerHeader(

                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 1.0],
                    colors: [ Colors.lightBlueAccent,Colors.white],

                  ),
                ),
                child: Container(
                  alignment: Alignment.topLeft,

                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap:() async {
                              if (widget.role == "professeur") {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                String token = prefs.getString("token")!;
                                String role = prefs.getString("role")!;
                                String email = prefs.getString("email")!;
                                String name = prefs.getString("nom")!;
                                String id = prefs.getString("id")!;
                                print(id);
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                  // ProfesseurInfoPage(id: id, email: email, role: role),
                                  ProfesseurDetailsScreen(
                                    profId: widget.profId!,
                                    nom: name,
                                    mail: email,
                                  ),
                                  // builder: (context) => LandingScreen(role: role,name: nom,), // Passer le rôle ici
                                ),);

                              }

                              else{
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(  username: widget.name,
                                  role: widget.role,
                                  email: widget.email,)));
                              }

                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),

                              child: Image.asset("assets/user1.png",width: 90),
                            ),
                          ),
                          widget.role == "professeur"?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: Alignment.center, // Centrez les enfants dans la stack
                                children: [
                                  IconButton(
                                    onPressed: ()async{
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String token = prefs.getString("token")!;
                                      String id = prefs.getString("id")!;
                                      String nom = prefs.getString("nom")!;

                                      var url = Uri.parse('http://192.168.43.73:5000/professeur/${widget.profId}/cours-non');

                                      var responseInitialise = await http.get(
                                        url,
                                        headers: {
                                          'Authorization': 'Bearer $token',
                                          'Content-Type': 'application/json', // Ajoutez le type de contenu
                                        },
                                        // body: jsonEncode({"notification": ""}), // Encodez votre corps en JSON
                                      );


                                      if (responseInitialise.statusCode == 200) {
                                        Map<String, dynamic> jsonResponse = jsonDecode(responseInitialise.body);
                                        courses = jsonResponse['cours'];
                                        // print('Paiements avec status "initialisé": ${paies.length}');
                                        setState(() {
                                          widget.CNS = courses.length;
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) =>
                                              ProfCoursesNonSigne(courses: courses,
                                                ProfId: widget.profId!,)),
                                        );

                                      } else {
                                        print('Request for "initialisé" failed with status: ${responseInitialise.statusCode}');
                                      }
                                    },
                                    icon: Icon(Icons.message_outlined, color: Colors.white,size: 30),
                                  ),
                                  Positioned(
                                    right: 2,top: 5, // Ajustez la position verticale du texte selon vos besoins
                                    child: Text(
                                      widget.CNS.toString(),
                                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                alignment: Alignment.center, // Centrez les enfants dans la stack
                                children: [
                                  IconButton(
                                    onPressed: ()async{
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String token = prefs.getString("token")!;
                                      String id = prefs.getString("id")!;
                                      String nom = prefs.getString("nom")!;

                                      var url = Uri.parse('http://192.168.43.73:5000/paiement/${widget.profId}/professeur');

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
                                        // print('Paiements avec status "initialisé": ${paies.length}');
                                        setState(() {
                                          widget.notif = paies.length;
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) =>
                                              Paie(paies: paies,
                                                ProfId: id,
                                                Id:  widget.profId!,
                                                ProfName: nom,)),
                                        );

                                      } else {
                                        print('Request for "initialisé" failed with status: ${responseInitialise.statusCode}');
                                      }
                                    },

                                    icon: Icon(Icons.notifications_none, color: Colors.white,size: 30,),
                                  ),
                                  Positioned(
                                    right: 8,top: 5, // Ajustez la position verticale du texte selon vos besoins
                                    child: Text(
                                      widget.notif.toString(),
                                      style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ):Container()

                        ],
                      ),
                      Row(
                        children: [
                          Text(
                              "BienVenue",
                              style: GoogleFonts.slabo27px(
                                color: Colors.white,
                                fontSize: 20,
                              )
                          ),
                          Text(
                            " ${widget.name!.toUpperCase()}",
                            style: GoogleFonts.slabo27px(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                              // letterSpacing: 2.0,
                            ),
                          ),
                          SizedBox(width: 10,),
                        ],
                      ),

                    ],
                  ),

                ),
              ),
              if (widget.role == "professeur")
                Column(
                  children: [
                    ListTile(
                        leading: Icon(Icons.book_outlined, size: _drawerIconSize, color: Colors.black,),
                        title: Text('Mes Cours', style: TextStyle(fontSize: 17, color: Colors.black),),
                        onTap: ()async{
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String token = prefs.getString("token")!;
                          String id = prefs.getString("id")!;
                          String nom = prefs.getString("nom")!;

                          var url = Uri.parse('http://192.168.43.73:5000/professeur/${widget.profId}/cours-oui');

                          var responseInitialise = await http.get(
                            url,
                            headers: {
                              'Authorization': 'Bearer $token',
                              'Content-Type': 'application/json', // Ajoutez le type de contenu
                            },
                            // body: jsonEncode({"notification": ""}), // Encodez votre corps en JSON
                          );


                          if (responseInitialise.statusCode == 200) {
                            Map<String, dynamic> jsonResponse = jsonDecode(responseInitialise.body);
                            courses = jsonResponse['cours'];
                            // print('Paiements avec status "initialisé": ${courses.length}');
                            setState(() {
                              coursCN = courses.length;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  ProfCoursesPage(courses: courses,
                                    ProfId: widget.profId!,)),
                            );

                          } else {
                            print('Request for "initialisé" failed with status: ${responseInitialise.statusCode}');
                          }
                        }
                    ),
                    ListTile(
                      leading: Icon(Icons.payment_outlined,size: _drawerIconSize,color: Colors.black),
                      title: Text('Paiements', style: TextStyle(fontSize: _drawerFontSize, color: Colors.black),
                      ),
                      onTap:()async{
                        // try {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String token = prefs.getString("token")!;
                        String id = prefs.getString("id")!;
                        String nomComplet = prefs.getString("nom")!;
                        String nom = nomComplet;

                        var url = Uri.parse('http://192.168.43.73:5000/paiement/${widget.profId}/professeur');

                        var responseInitialise = await http.post(
                          url,
                          headers: {
                            'Authorization': 'Bearer $token',
                            'Content-Type': 'application/json', // Ajoutez le type de contenu
                          },
                          body: jsonEncode({}), // Encodez votre corps en JSON
                        );


                        if (responseInitialise.statusCode == 200) {
                          Map<String, dynamic> jsonResponse = jsonDecode(responseInitialise.body);
                          paies = jsonResponse['paiements'];
                          setState(() {
                            coursPN = paies.length;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                ProfPaies(paies: paies,
                                  ProfId: id,
                                  Id:  widget.profId!,
                                  ProfName: nom,)),
                          );
                          print('Paiements avec status "initialisé": ${paies.length}');
                        } else {
                          print('Request for "initialisé" failed with status: ${responseInitialise.statusCode}');
                        }


                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.calendar_month, size: _drawerIconSize,color: Colors.black,),
                      title: Text('Mon Emploi',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                      onTap:() async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EmploiPage(profId: widget.profId!,)));
                      },
                    ),
                    //Divider(color: Theme.of(context).primaryColor, height: 1,),
                    ListTile(
                      leading: Icon(Icons.logout_rounded, size: _drawerIconSize,color: Colors.black,),
                      title: Text('Logout',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                      onTap: () async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('token', '');
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginSection()));

                      },
                    ),
                  ],
                ),
              // if (widget.role == "responsable")
              if (widget.role == "admin")
                Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.supervised_user_circle_outlined, size: _drawerIconSize, color: Colors.black,),
                      title: Text('Users', style: TextStyle(fontSize: 17, color: Colors.black),),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Users()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.groups,size: _drawerIconSize,color: Colors.black),
                      title: Text('Professeures', style: TextStyle(fontSize: _drawerFontSize, color: Colors.black),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Professeures()),);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.featured_play_list_outlined,size: _drawerIconSize,color: Colors.black),
                      title: Text('Elements', style: TextStyle(fontSize: _drawerFontSize, color: Colors.black),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Elements()),);
                      },
                    ),
                    //Divider(color: Theme.of(context).primaryColor, height: 1,),
                    //Divider(color: Theme.of(context).primaryColor, height: 1,),
                    ListTile(
                      leading: Icon(Icons.play_lesson_outlined, size: _drawerIconSize,color: Colors.black,),
                      title: Text('Cours',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                      onTap: ()async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String token = prefs.getString("token")!;
                        String role = prefs.getString("role")!;
                        var response = await http.get(
                          Uri.parse('http://192.168.43.73:5000/cours'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer $token'
                          },
                        );
                        // print(response.body);

                        if (response.statusCode == 200) {
                          List<dynamic> courses = json.decode(
                              response.body)['cours'];
                          // this.coursNum = json.decode(response.body)['data']['countLL'];
                          // num heuresTV = json.decode(response.body)['data']['heuresTV'];
                          // num sommeTV = json.decode(response.body)['data']['sommeTV'];
                          // setState(() {
                          this.coursNum = json.decode(response.body)['cours'].length;
                          //
                          // });
                          print('Mes Cours :${json.decode(response.body)['cours']}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                CoursesPage(courses: courses,
                                  coursNum: coursNum,
                                  // heuresTV: heuresTV,
                                  // sommeTV: sommeTV,
                                  role: role,)),
                          );
                        } else {
                          // Handle error
                          print('Failed to fetch prof courses. Status Code: ${response
                              .statusCode}');
                        }
                      },
                    ),
                    // Divider(color: Colors.black38, height: 1,),
                    ListTile(
                        leading: Icon(Icons.payment_outlined, size: _drawerIconSize,color: Colors.black,),
                        title: Text('Paiements',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                        onTap: ()async{
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          String token = prefs.getString("token")!;
                          String role = prefs.getString("role")!;
                          var response = await http.get(
                            Uri.parse('http://192.168.43.73:5000/cours'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $token'
                            },
                          );
                          // print(response.body);

                          if (response.statusCode == 200) {
                            List<dynamic> courses = json.decode(
                                response.body)['cours'];
                            this.coursNum = json.decode(response.body)['cours'].length;
                            // print('Mes cours: ${json.decode(response.body)['cours']}');
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Paiements(courses: courses,)),
                            );
                          } else {
                            // Handle error
                            print('Failed to fetch prof courses. Status Code: ${response
                                .statusCode}');
                          }
                        }
                    ),

                    ListTile(
                      leading: Icon(Icons.calendar_month, size: _drawerIconSize,color: Colors.black,),
                      title: Text('Emplois',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                      onTap: () {
                        Navigator.push( context, MaterialPageRoute(builder: (context) => Emploi()), );
                      },
                    ),
                    //Divider(color: Theme.of(context).primaryColor, height: 1,),
                    ListTile(
                      leading: Icon(Icons.folder_special_outlined, size: _drawerIconSize,color: Colors.black),
                      title: Text('Fillieres',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Filliere()),);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.read_more, size: _drawerIconSize,color: Colors.black),
                      title: Text('Autres',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MoreOptionsPage(username: widget.name!,
                            userRole: widget.role!, userEmail: widget.email!)));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout_rounded, size: _drawerIconSize,color: Colors.black,),
                      title: Text('Logout',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                      onTap: () async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('token', '');
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginSection()));

                      },
                    ),
                  ],)
            ],
          ),
        ),
      ),
      body: Stack(
        // overflow: Overflow.visible,
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: ClippingClass(),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height*4/7,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.lightBlueAccent, Colors.white],
                  // colors: [Color(0xB0AFAFA3), Colors.white],
                ),
              ),
            ),
          ),

          Positioned(
            left: 20,
            top: 100,
            right: 20,
            child: Column(
              children:[
                GestureDetector(
                  onTap:(){},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      if (widget.role == "professeur")
                        Column(
                          children: [

                            SizedBox(height: 80,),
                            Row(
                              children: [
                                _customCard(
                                  imageUrl: "cours3.png",
                                  item: "Mes Cours",
                                  height: 180,
                                  width: 160,
                                  duration: "${coursCN} Cours",
                                  onPessed: ()async{
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    String token = prefs.getString("token")!;
                                    String id = prefs.getString("id")!;
                                    String nom = prefs.getString("nom")!;

                                    var url = Uri.parse('http://192.168.43.73:5000/professeur/${widget.profId}/cours-oui');

                                    var responseInitialise = await http.get(
                                      url,
                                      headers: {
                                        'Authorization': 'Bearer $token',
                                        'Content-Type': 'application/json', // Ajoutez le type de contenu
                                      },
                                      // body: jsonEncode({"notification": ""}), // Encodez votre corps en JSON
                                    );


                                    if (responseInitialise.statusCode == 200) {
                                      Map<String, dynamic> jsonResponse = jsonDecode(responseInitialise.body);
                                      courses = jsonResponse['cours'];
                                      // print('Paiements avec status "initialisé": ${courses.length}');
                                      setState(() {
                                        coursCN = courses.length;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            ProfCoursesPage(courses: courses,
                                              ProfId: widget.profId!,)),
                                      );

                                    } else {
                                      print('Request for "initialisé" failed with status: ${responseInitialise.statusCode}');
                                    }
                                  },

                                ),

                                _customCard(
                                  imageUrl: "paie2.jpg",
                                  item: "Paiements",
                                  height: 180,
                                  width: 160,
                                  duration: "${coursPN} Paiements",
                                  onPessed: ()async{
                                    // try {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    String token = prefs.getString("token")!;
                                    String id = prefs.getString("id")!;
                                    String nomComplet = prefs.getString("nom")!;
                                    String nom = nomComplet;

                                    var url = Uri.parse('http://192.168.43.73:5000/paiement/${widget.profId}/professeur');

                                    var responseInitialise = await http.post(
                                      url,
                                      headers: {
                                        'Authorization': 'Bearer $token',
                                        'Content-Type': 'application/json', // Ajoutez le type de contenu
                                      },
                                      body: jsonEncode({}), // Encodez votre corps en JSON
                                    );


                                    if (responseInitialise.statusCode == 200) {
                                      Map<String, dynamic> jsonResponse = jsonDecode(responseInitialise.body);
                                      paies = jsonResponse['paiements'];
                                      setState(() {
                                        coursPN = paies.length;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            ProfPaies(paies: paies,
                                              ProfId: id,
                                              Id:  widget.profId!,
                                              ProfName: nom,)),
                                      );
                                      print('Paiements avec status "initialisé": ${paies.length}');
                                    } else {
                                      print('Request for "initialisé" failed with status: ${responseInitialise.statusCode}');
                                    }


                                  },

                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _customCard(
                                  imageUrl: "emp2.png",
                                  // imageUrl: "user1.png",
                                  item: "Mon Emploi",
                                  height: 180,
                                  width: 160,        duration: "",
                                  onPessed:  () async {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => EmploiPage(profId: widget.profId!,)));
                                  },
                                ),
                                _customCard(
                                  imageUrl: "logout1.png",
                                  // imageUrl: "user1.png",
                                  item: "Se Déconnecter",
                                  height: 180,
                                  width: 160,
                                  duration: "",
                                  onPessed:  () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    await prefs.setString('token', '');
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginSection()));
                                  },
                                ),


                              ],
                            ),
                          ],
                        ),
                      if (widget.role == "responsable")
                        Column(
                          children: [
                            Row(
                              children: [
                                _customCard(
                                  imageUrl: "categ2.png",
                                  item: "Categories",
                                  height: 150,
                                  width: 150,
                                  duration: "${emplois?.length} Categories",
                                  onPessed: (){
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => Categories()));

                                  },
                                ),
                                _customCard(
                                  imageUrl: "coding3.png",
                                  item: "Matieres",
                                  height: 150,
                                  width: 150,
                                  duration: "${fillieres?.length} Matieres",
                                  onPessed: (){
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => Matieres()));

                                  },
                                ),


                              ],
                            ),
                            Row(
                              children: [
                                _customCard(
                                  imageUrl: "cours3.png",
                                  item: "Cours",
                                  duration: "${coursNum} Cours",

                                  height: 150,
                                  width: 150,
                                  // duration: "${this.coursNb} Cours",
                                  onPessed: ()async{
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    String token = prefs.getString("token")!;
                                    String role = prefs.getString("role")!;
                                    var response = await http.get(
                                      Uri.parse('http://192.168.43.73:5000/cours'),
                                      headers: {
                                        'Content-Type': 'application/json',
                                        'Authorization': 'Bearer $token'
                                      },
                                    );
                                    // print(response.body);

                                    if (response.statusCode == 200) {
                                      List<dynamic> courses = json.decode(
                                          response.body)['data']['coursLL'];
                                      this.coursNum = json.decode(response.body)['data']['countLL'];
                                      num heuresTV = json.decode(response.body)['data']['heuresTV'];
                                      num sommeTV = json.decode(response.body)['data']['sommeTV'];
                                      setState(() {
                                        this.coursNum = json.decode(response.body)['data']['countLL'];

                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            CoursesPage(courses: courses,
                                              coursNum: coursNum,
                                              // heuresTV: heuresTV,
                                              // sommeTV: sommeTV,
                                              role: role,
                                            )),
                                      );
                                    } else {
                                      // Handle error
                                      print('Failed to fetch prof courses. Status Code: ${response
                                          .statusCode}');
                                    }
                                  },
                                ),
                                _customCard(
                                  imageUrl: "paie2.jpg",
                                  // imageUrl: "paie3.jpg",
                                  item: "Paiements",
                                  duration: "",
                                  height: 150,
                                  width: 150,
                                  onPessed: (){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(' Ne fonctionne pas actuellement')),
                                    );
                                  },
                                ),


                              ],
                            ),
                            Row(
                              children: [
                                _customCard(
                                  imageUrl: "settings2.png",
                                  // imageUrl: "user1.png",
                                  item: "Outils",
                                  height: 150,
                                  width: 150,
                                  duration: "",
                                  onPessed:  () async {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
                                  },
                                ),
                                _customCard(
                                  imageUrl: "logout1.png",
                                  // imageUrl: "user1.png",
                                  item: "Se Déconnecter",
                                  duration: "",
                                  height: 150,
                                  width: 150,
                                  onPessed:  () async {
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    await prefs.setString('token', '');
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginSection()));
                                  },
                                ),


                              ],
                            ),

                          ],
                        ),
                      if (widget.role == "admin")
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _customCard(
                                    imageUrl: "users1.jpg",
                                    item: "Utilisateures",
                                    duration: "${useres?.length!} Users",
                                    height: 150,
                                    width: 150,
                                    onPessed: (){
                                      Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => Users()));


                                    },
                                  ),

                                  SizedBox(width: 15,),
                                  _customCard(
                                    imageUrl: "profs2.png",
                                    item: "Professeures",
                                    duration: "${profs?.length!} Profs",
                                    height: 150,
                                    width: 150,
                                    onPessed: (){
                                      Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => Professeures()));
                                    },
                                  ),


                                ],
                              ),

                              SizedBox(height: 5,),
                              Row(
                                children: [
                                  _customCard(
                                    imageUrl: "cours3.png",
                                    item: "Cours",
                                    duration: "${coursNum} Cours",
                                    height: 150,
                                    width: 150,
                                    onPessed: ()async{
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String token = prefs.getString("token")!;
                                      String role = prefs.getString("role")!;
                                      var response = await http.get(
                                        Uri.parse('http://192.168.43.73:5000/cours'),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Authorization': 'Bearer $token'
                                        },
                                      );
                                      // print(response.body);

                                      if (response.statusCode == 200) {
                                        List<dynamic> courses = json.decode(
                                            response.body)['cours'];
                                        // this.coursNum = json.decode(response.body)['data']['countLL'];
                                        // num heuresTV = json.decode(response.body)['data']['heuresTV'];
                                        // num sommeTV = json.decode(response.body)['data']['sommeTV'];
                                        setState(() {
                                        this.coursNum = json.decode(response.body)['cours'].length;
                                        //
                                        });
                                        print('Mes Cours :${json.decode(response.body)['cours']}');
                                        print("Mes CN${coursNum}");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) =>
                                              CoursesPage(courses: courses,
                                                coursNum: coursNum,
                                                // heuresTV: heuresTV,
                                                // sommeTV: sommeTV,
                                                role: role,)),
                                        );
                                      } else {
                                        // Handle error
                                        print('Failed to fetch prof courses. Status Code: ${response
                                            .statusCode}');
                                      }
                                    },
                                  ),

                                  SizedBox(width: 15,),
                                  _customCard(
                                    imageUrl: "paie2.jpg",
                                    // imageUrl: "paie3.jpg",
                                    item: "Paiements",
                                    duration: "",
                                    height: 150,
                                    width: 150,
                                    onPessed: ()async{
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String token = prefs.getString("token")!;
                                      String role = prefs.getString("role")!;
                                      var response = await http.get(
                                        Uri.parse('http://192.168.43.73:5000/cours'),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Authorization': 'Bearer $token'
                                        },
                                      );
                                      // print(response.body);

                                      if (response.statusCode == 200) {
                                        List<dynamic> courses = json.decode(
                                            response.body)['cours'];
                                        this.coursNum = json.decode(response.body)['cours'].length;
                                        // print('Mes cours: ${json.decode(response.body)['cours']}');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => Paiements(courses: courses,)),
                                        );
                                      } else {
                                        // Handle error
                                        print('Failed to fetch prof courses. Status Code: ${response
                                            .statusCode}');
                                      }
                                    },
                                  ),


                                ],
                              ),

                              SizedBox(height: 5,),
                              Row(
                                children: [
                                  _customCard(
                                    imageUrl: "emp4.png",
                                    item: "Emploi",
                                    duration: "${emplois?.length!} Emploi",
                                    height: 150,
                                    width: 150,
                                    onPessed: (){
                                      Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => Emploi()));

                                    },
                                  ),


                                  SizedBox(width: 15,),
                                  _customCard(
                                    imageUrl: "grps4.jpg",
                                    item: "Fillieres",
                                    duration: "${fillieres?.length} Filliere",
                                    height: 150,
                                    width: 150,
                                    onPessed: (){
                                      Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => Filliere()));
                                      // context, MaterialPageRoute(builder: (context) => ()));

                                    },
                                  ),


                                ],
                              ),

                              SizedBox(height: 5,),
                              Row(
                                children: [
                                  _customCard(
                                    imageUrl: "settings2.png",
                                    // imageUrl: "more1.png",
                                    item: "Autres",
                                    duration: "",
                                    height: 150,
                                    width: 150,
                                    onPessed:  () async {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                          MoreOptionsPage(username: widget.name!, userRole: widget.role!, userEmail: widget.email!)));
                                    },
                                  ),


                                  SizedBox(width: 15,),
                                  _customCard(
                                    imageUrl: "coding1.jpg",
                                    // imageUrl: "user1.png",
                                    item: "Elements",
                                    duration: "",
                                    height: 150,
                                    width: 150,
                                    onPessed:   () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Elements()),);
                                    },
                                  ),


                                ],
                              ),


                            ],
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
    );
  }

  _customCard({required String imageUrl,required double height,required double width, required String item, required String duration,required final VoidCallback onPessed,}){
    return SizedBox(
      height: height,
      width: width,
      child: InkWell(
        onTap: onPessed,
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          elevation: 10,
          child: Container(
            decoration: BoxDecoration(
              // shape: BoxShape.circle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
            ),

            child: Padding(
              padding: EdgeInsets.all(8),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset("assets/" + imageUrl,width: 60,fit: BoxFit.cover),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item,
                            style: GoogleFonts.slabo27px(fontSize: 20,color: Colors.black),
                          ),
                          Text(duration,style: GoogleFonts.slabo27px(
                            color: Colors.black54,
                          ),)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClippingClass extends CustomClipper<Path>{
  @override

  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);
    var controlPoint = Offset(size.width - (size.width / 2), size.height - 120);
    var endPoint = Offset(size.width, size.height);
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
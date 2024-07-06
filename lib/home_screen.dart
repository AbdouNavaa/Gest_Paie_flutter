import 'dart:convert';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gestion_payements/auth/emploi.dart';
import 'package:gestion_payements/element.dart';
import 'package:gestion_payements/matieres.dart';
import 'package:gestion_payements/more_page.dart';
import 'package:gestion_payements/paie.dart';
import 'package:gestion_payements/paiements.dart';
import 'package:gestion_payements/professeures.dart';
import 'package:gestion_payements/settings.dart';
import 'package:gestion_payements/test.dart';
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
 late List<CostsData> PieData ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchStatistics().then((data) {
      setState(() {
        PieData.add(data); // Assigner la liste renvoyée par Useresseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
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

    _loadPhotoUrl();
  }

  String? photoUrl;
  _loadPhotoUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      photoUrl = prefs.getString("photo");
      if (photoUrl != null && photoUrl!.contains("localhost")) {
        photoUrl = photoUrl!.replaceFirst("localhost", "192.168.43.73"); // Use your server's IP address here
      }
    });
  }


  late int index;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion de Paiement',
        style: GoogleFonts.abhayaLibre(
          color: Colors.white,
          fontSize: 25.0,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.0,
        ),
      ),
        // leading: IconButton(onPressed: ()=> MyDrawer(), icon: Icon(Icons.sort_outlined)),
        backgroundColor:Colors.indigoAccent.shade700,iconTheme: IconThemeData(color: Colors.white,),
        // colors: [ Color(0xff0fb2ea)],
        // ,
        actions: [

          IconButton(icon:Icon(Icons.output_outlined),
            onPressed: () async{
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('token', '');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())));
              // MaterialPageRoute(builder: (context) => LoginSection()));

            },

          )
        ],
      )
          ,

      drawer: MyDrawer(),
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
                  begin: Alignment.center,
                  end: Alignment.bottomLeft,
                  // colors: [ Colors.white,Colors.white],
                  // stops: [0.0, 2],
                  colors: [Colors.indigoAccent.shade700, Colors.indigo.shade700],
                  // colors: [Color(0xB0AFAFA3), Colors.white],
                ),
              ),
            ),
          ),

          Positioned(
            left: 20,
            top: widget.role == "professeur"? 40:40,
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
                            // SizedBox(height: 40,),

                            InkWell(
                              onTap: () async {
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



                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),

                                child:
                                     // photoUrl != null
                                    // ? Image.network(photoUrl!, width: 100, height: 100, fit: BoxFit.cover)
                                    Image.asset("assets/user1.png", width: 100, height: 100),
                              ),
                            ),

                            SizedBox(height: 20,),
                            Row(
                              children: [
                                Stack(
                                  // alignment: Alignment.center, // Centrez les enfants dans la stack
                                    children: [
                                      _customCard(
                                        imageUrl: "cours2.png",
                                        item: "Cours Non Signé",
                                        height: 160,
                                        width: 160,
                                        duration: "${widget.CNS} Cours",
                                        onPessed: ()async{
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          String token = prefs.getString("token")!;
                                          String id = prefs.getString("id")!;
                                          String nom = prefs.getString("nom")!;

                                          var url = Uri.parse('http://192.168.43.73:5000/cours?professeur=${widget.profId}&isSigned=en attente');
                                          // var url = Uri.parse('http://192.168.43.73:5000/cours/non-signe-professeur/${widget.profId}');

                                          var responseInitialise = await http.get(
                                            url,
                                            headers: {
                                              'Authorization': 'Bearer $token',
                                              'Content-Type': 'application/json', // Ajoutez le type de contenu
                                            },
                                            // body: jsonEncode({}), // Encodez votre corps en JSON
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

                                      ),
                                      Positioned(
                                        right: 1,top: 1, // Ajustez la position verticale du texte selon vos besoins
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(color: Colors.lightGreenAccent,borderRadius: BorderRadius.circular(50)),
                                          child: Center(
                                            child: Text(
                                              widget.CNS.toString(),
                                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ] ),
                                Stack(
                                  // alignment: Alignment.center, // Centrez les enfants dans la stack
                                    children: [
                                      _customCard(
                                        imageUrl: "paie1.png",
                                        item: "Paiements Non Confirmés",
                                        height: 160,
                                        width: 160,
                                        duration: "${widget.notif} Paies",
                                        onPessed: ()async{
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
                                            // print('paies:${paies}');

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


                                      ),
                                      Positioned(
                                        right: 1,top: 1, // Ajustez la position verticale du texte selon vos besoins
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(color: Colors.lightGreenAccent,borderRadius: BorderRadius.circular(50)),
                                          child: Center(
                                            child: Text(
                                              widget.notif.toString(),
                                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ] ),

                              ],
                            ),
                            Row(
                              children: [
                                _customCard(
                                  imageUrl: "cours3.png",
                                  item: "Mes Cours",
                                  height: 160,
                                  width: 160,
                                  duration: "${coursCN} Cours",
                                  onPessed: ()async{
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    String token = prefs.getString("token")!;
                                    String id = prefs.getString("id")!;
                                    String nom = prefs.getString("nom")!;

                                    var url = Uri.parse('http://192.168.43.73:5000/cours?professeur=${widget.profId}&isSigned=effectué');

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
                                  height: 160,
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

                                      print(paies);
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
                            Row(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _customCard(
                                  imageUrl: "emp2.png",
                                  // imageUrl: "user1.png",
                                  item: "Mon Emploi",
                                  height: 160,
                                  width: 160,        duration: "",
                                  onPessed:  () async {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => EmploiPage(profId: widget.profId!,)));
                                  },
                                ),
                                // _customCard(
                                //   imageUrl: "logout1.png",
                                //   // imageUrl: "user1.png",
                                //   item: "Se Déconnecter",
                                //   height: 180,
                                //   width: 160,
                                //   duration: "",
                                //   onPessed:  () async {
                                //     SharedPreferences prefs = await SharedPreferences.getInstance();
                                //     await prefs.setString('token', '');
                                //     Navigator.push(context,
                                //         MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())));
                                //     // MaterialPageRoute(builder: (context) => LoginSection()));
                                //   },
                                // ),


                              ],
                            ),
                            // SizedBox(height: 40,),
                          ],
                        ),
                      if (widget.role == "responsable")
                        SingleChildScrollView(
                          child: Column(
                            children: [
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
                                        Uri.parse('http://192.168.43.73:5000/cours?isPaid=en attente'),
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
                                                paid: false,
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
                                    item: "Filières",
                                    duration: "${fillieres?.length} Filières",
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
                                    item: "Categories",
                                    duration: "",
                                    height: 150,
                                    width: 150,
                                    onPessed: () {
                                      // Navigate to CategoriesPage
                                      Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => Categories()));
                                    },
                                  ),


                                  SizedBox(width: 15,),
                                  _customCard(
                                    imageUrl: "coding1.jpg",
                                    // imageUrl: "user1.png",
                                    item: "Matieres",
                                    duration: "",
                                    height: 150,
                                    width: 150,
                                    onPessed:   () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Elements()),);
                                    },
                                  ),


                                ],
                              ),

                              Center(child:  _customCard(
                                imageUrl: "logout1.png",
                                // imageUrl: "user1.png",
                                item: "Se Déconnecter",
                                height: 150,
                                width: 150,
                                duration: "",
                                onPessed:  () async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('token', '');
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())));
                                  // MaterialPageRoute(builder: (context) => LoginSection()));
                                },
                              ),)

                            ],
                          ),
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
                                    imageUrl: "grps4.jpg",
                                    item: "Filières",
                                    duration: "${fillieres?.length} Filières",
                                    height: 150,
                                    width: 150,
                                    onPessed: (){
                                      Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => Filliere()));
                                      // context, MaterialPageRoute(builder: (context) => ()));

                                    },
                                  ),

                                  SizedBox(width: 15,),
                                  _customCard(
                                    imageUrl: "coding1.jpg",
                                    // imageUrl: "user1.png",
                                    item: "Matieres",
                                    duration: "",
                                    height: 150,
                                    width: 150,
                                    onPessed:   () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Elements()),);
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
                                        // Uri.parse('http://192.168.43.73:5000/cours?isPaid=en attente'),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Authorization': 'Bearer $token'
                                        },
                                      );
                                      // print(response.body);

                                      if (response.statusCode == 200) {
                                        List<dynamic> courses = json.decode(
                                            response.body)['cours'];
                                        setState(() {
                                          this.coursNum = json.decode(response.body)['cours'].length;
                                        });
                                        print('Mes Cours :${json.decode(response.body)['cours']}');
                                        print("Mes CN${coursNum}");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) =>
                                              CoursesPage(courses: courses,
                                                coursNum: coursNum,
                                                // heuresTV: heuresTV,
                                                paid: false,
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
                                ],
                              ),

                              SizedBox(height: 5,),
                              Row(
                                children: [
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
                                  SizedBox(width: 15,),

                                  _customCard(
                                    imageUrl: "categ2.png",
                                    // imageUrl: "more1.png",
                                    item: "Categories",
                                    duration: "",
                                    height: 150,
                                    width: 150,
                                    onPessed: () {
                                      // Navigate to CategoriesPage
                                      Navigator.push(
                                          context, MaterialPageRoute(builder: (context) => Categories()));
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
      // bottomNavigationBar: BottomNav(),
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


class MyDrawer extends StatefulWidget {
  MyDrawer({Key? key}) : super(key: key);


  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {

  String role = '';
  String name = '';
  String email = '';
  String? profId;
  int notif = 0;
  int CNS = 0;
  final double _drawerIconSize = 24;
  final double _drawerFontSize = 17;
  int coursNum = 0;
  int coursCN = 0;
  int coursPN = 0;

  getPref() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance();
    String token = prefs.getString("token")!;
    String? id;
    setState(() {
      role = prefs.getString("role")!;
      email = prefs.getString("email")!;
      id = prefs.getString("id")!;
      name = prefs.getString("nom")!;
    });
    if (token != null && role == "professeur") {
      profId = (await getProfId(token, id!)!)!;

      notif = (await fetchPaiements(profId,token))!;
      CNS = (await CoursNS(profId,token))!;

    }
    print('hello, Role: $role , ProfName $name, Email $email , ProfId:$profId, Notif:$notif, CNS:$CNS');
  }

  late List<CostsData> PieData ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(width: 250,
      child: Container(color: Colors.white,
        child: ListView(
          children: [
            DrawerHeader(

              decoration: BoxDecoration(
                // color: Colors.indigoAccent,
                gradient: LinearGradient(
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                //   stops: [0.0, 2],
                colors: [Colors.indigoAccent.shade700, Colors.indigo.shade700],

                //
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
                            if (role == "professeur") {
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
                                  profId: profId!,
                                  nom: name,
                                  mail: email,
                                ),
                                // builder: (context) => LandingScreen(role: role,name: nom,), // Passer le rôle ici
                              ),);

                            }

                            else{
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(  username: name,
                                role: role,
                                email: email,)));
                            }

                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),

                            child: Image.asset("assets/user1.png",width: 90),
                          ),
                        ),
                        role == "professeur"?
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

                                    var url = Uri.parse('http://192.168.43.73:5000/cours?professeur=${profId}&isSigned=en attente');
                                    // var url = Uri.parse('http://192.168.43.73:5000/cours/non-signe-professeur/${profId}');

                                    print('Agg:${profId}');
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
                                      var cours = jsonResponse['cours'];
                                      print('Agg:${cours}');
                                      // print('Paiements avec status "initialisé": ${paies.length}');
                                      setState(() {
                                        CNS = cours.length;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            ProfCoursesNonSigne(courses: cours,
                                              ProfId: profId!,)),
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
                                    CNS.toString(),
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

                                    var url = Uri.parse('http://192.168.43.73:5000/paiement/${profId}/professeur');

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
                                        notif = paies.length;
                                      });
                                      print(paies);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            Paie(paies: paies,
                                              ProfId: id,
                                              Id:  profId!,
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
                                    notif.toString(),
                                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ):Container()        ],  ),
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
                          " ${name!.toUpperCase()}",
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
                    ),      ],    ),  ),  ),
            if (role == "professeur")
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.dashboard_customize_outlined, size: _drawerIconSize, color: Colors.black,),
                    title: Text('Acceuil', style: TextStyle(fontSize: 17, color: Colors.black),),
                    onTap: (){
                       if (profId != null) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => HomeScreen(
                                                                role: role,
                                                                name: name,
                                                                email: email,
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

                    },
                  ),
                  ListTile(
                      leading: Icon(Icons.book_outlined, size: _drawerIconSize, color: Colors.black,),
                      title: Text('Mes Cours', style: TextStyle(fontSize: 17, color: Colors.black),),
                      onTap: ()async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String token = prefs.getString("token")!;
                        String id = prefs.getString("id")!;
                        String nom = prefs.getString("nom")!;

                        var url = Uri.parse('http://192.168.43.73:5000/cours?professeur=${profId}&isSigned=effectué');

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
                                  ProfId: profId!,)),
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

                      var url = Uri.parse('http://192.168.43.73:5000/paiement/${profId}/professeur');

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
                                Id:  profId!,
                                ProfName: nom,)),
                        );
                        print('Paiements avec status "initialisé": ${paies.length}');
                      } else {
                        print('Request for "initialisé" failed with status: ${responseInitialise.statusCode}');
                      }


                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.payment_outlined,size: _drawerIconSize,color: Colors.black),
                    title: Text('Etat de Paiements', style: TextStyle(fontSize: _drawerFontSize, color: Colors.black),
                    ),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EtatPaiemens()));
                    },
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

                      var url = Uri.parse('http://192.168.43.73:5000/paiement/${profId}/professeur');

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
                                Id:  profId!,
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EmploiPage(profId: profId!,)));
                    },
                  ),
                  //Divider(color: Theme.of(context).primaryColor, height: 1,),
                  SizedBox(height: MediaQuery.of(context).size.height /2.7 ,),
                  ElevatedButton(
                    child: Text('Logout',style: TextStyle(fontSize: _drawerFontSize,color: Colors.white),),
                    onPressed: () async{
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('token', '');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())));
                      // MaterialPageRoute(builder: (context) => LoginSection()));

                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent,padding: EdgeInsets.symmetric(horizontal: 90,vertical: 10)),
                  ),

                ],
              ),
            if (role == "responsable")
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.home, size: _drawerIconSize, color: Colors.black,),
                    // leading: Icon(Icons.dashboard_customize_outlined, size: _drawerIconSize, color: Colors.black,),
                    title: Text('Acceuil', style: TextStyle(fontSize: 17, color: Colors.black),),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                          // ProfesseurInfoPage(
                          //     id: id, email: email, role: role),
                          // builder: (context) => LandingScreen(role: role,name: nom,), // Passer le rôle ici
                          HomeScreen(role: role,name: name,email: email,)),);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.featured_play_list_outlined,size: _drawerIconSize,color: Colors.black),
                    title: Text('Matieres', style: TextStyle(fontSize: _drawerFontSize, color: Colors.black),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Elements()),);
                    },
                  ),
                  //Divider(color: Theme.of(context).primaryColor, height: 1,),
                  //Divider(color: Theme.of(context).primaryColor, height: 1,),
                  ListTile(
                    leading: Icon(Icons.bookmark_border, size: _drawerIconSize,color: Colors.black,),
                    title: Text('Cours',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                    onTap: ()async{
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String token = prefs.getString("token")!;
                      String role = prefs.getString("role")!;
                      var response = await http.get(
                        Uri.parse('http://192.168.43.73:5000/cours?isPaid=en attente'),
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
                                paid: false,
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
                  ListTile(
                    leading: Icon(Icons.bookmark_remove_outlined, size: _drawerIconSize,color: Colors.black,),
                    title: Text('Cours a Paié',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                    onTap: ()async{
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String token = prefs.getString("token")!;
                      String role = prefs.getString("role")!;
                      var response = await http.get(
                        Uri.parse('http://192.168.43.73:5000/cours?isPaid=préparé'),
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
                                coursNum: coursNum,paid: true,
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
                    title: Text('Filières',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Filliere()),);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.read_more, size: _drawerIconSize,color: Colors.black),
                    title: Text('Autres',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MoreOptionsPage(username: name!,
                          userRole: role!, userEmail: email!)));
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 8,),
                  ElevatedButton(
                    child: Text('Logout',style: TextStyle(fontSize: _drawerFontSize,color: Colors.white),),
                    onPressed: () async{
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('token', '');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())));
                      // MaterialPageRoute(builder: (context) => LoginSection()));

                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent,padding: EdgeInsets.symmetric(horizontal: 90,vertical: 10)),
                  ),
                ],),
            if (role == "admin")
              Column(
                children: [
                  // ListTile(
                  //   leading: Icon(Icons.bar_chart, size: _drawerIconSize, color: Colors.black,),
                  //   // leading: Icon(Icons.dashboard_customize_outlined, size: _drawerIconSize, color: Colors.black,),
                  //   title: Text('Statustique', style: TextStyle(fontSize: 17, color: Colors.black),),
                  //   onTap: (){
                  //     Navigator.push(context, MaterialPageRoute(
                  //         builder: (context) =>
                  //         // ProfesseurInfoPage(
                  //         //     id: id, email: email, role: role),
                  //         // builder: (context) => LandingScreen(role: role,name: nom,), // Passer le rôle ici
                  //         PieChartExample()),);
                  //   },
                  // ),
                  ListTile(
                    leading: Icon(Icons.home_outlined, size: _drawerIconSize, color: Colors.black,),
                    // leading: Icon(Icons.dashboard_customize_outlined, size: _drawerIconSize, color: Colors.black,),
                    title: Text('Acceuil', style: TextStyle(fontSize: 17, color: Colors.black),),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                          // ProfesseurInfoPage(
                          //     id: id, email: email, role: role),
                          // builder: (context) => LandingScreen(role: role,name: nom,), // Passer le rôle ici
                          HomeScreen(role: role,name: name,email: email,)),);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.supervisor_account_outlined, size: _drawerIconSize, color: Colors.black,),
                    title: Text('Utilisateurs', style: TextStyle(fontSize: 17, color: Colors.black),),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Users()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.groups,size: _drawerIconSize,color: Colors.black),
                    title: Text('Professeurs', style: TextStyle(fontSize: _drawerFontSize, color: Colors.black),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Professeures()),);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.code,size: _drawerIconSize,color: Colors.black),
                    title: Text('Matieres', style: TextStyle(fontSize: _drawerFontSize, color: Colors.black),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Elements()),);
                    },
                  ),
                  //Divider(color: Theme.of(context).primaryColor, height: 1,),
                  //Divider(color: Theme.of(context).primaryColor, height: 1,),
                  ListTile(
                    leading: Icon(Icons.bookmark_border, size: _drawerIconSize,color: Colors.black,),
                    title: Text('Cours',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                    onTap: ()async{
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String token = prefs.getString("token")!;
                      String role = prefs.getString("role")!;
                      var response = await http.get(
                        Uri.parse('http://192.168.43.73:5000/cours'),
                        // Uri.parse('http://192.168.43.73:5000/cours?isPaid=en attente'),
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
                                paid: false,
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
                  // ListTile(
                  //   leading: Icon(Icons.bookmark_remove_outlined, size: _drawerIconSize,color: Colors.black,),
                  //   title: Text('Cours a paye',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                  //   onTap: ()async{
                  //     SharedPreferences prefs = await SharedPreferences.getInstance();
                  //     String token = prefs.getString("token")!;
                  //     String role = prefs.getString("role")!;
                  //     var response = await http.get(
                  //       Uri.parse('http://192.168.43.73:5000/cours?isPaid=préparé'),
                  //       // Uri.parse('http://192.168.43.73:5000/cours?isPaid=préparé'),
                  //       headers: {
                  //         'Content-Type': 'application/json',
                  //         'Authorization': 'Bearer $token'
                  //       },
                  //     );
                  //     // print(response.body);
                  //
                  //     if (response.statusCode == 200) {
                  //       List<dynamic> courses = json.decode(
                  //           response.body)['cours'];
                  //       // this.coursNum = json.decode(response.body)['data']['countLL'];
                  //       // num heuresTV = json.decode(response.body)['data']['heuresTV'];
                  //       // num sommeTV = json.decode(response.body)['data']['sommeTV'];
                  //       // setState(() {
                  //       this.coursNum = json.decode(response.body)['cours'].length;
                  //       //
                  //       // });
                  //       print('Mes Cours :${json.decode(response.body)['cours']}');
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (context) =>
                  //             CoursesPage(courses: courses,
                  //               coursNum: coursNum,paid: true,
                  //               // heuresTV: heuresTV,
                  //               // sommeTV: sommeTV,
                  //               role: role,)),
                  //       );
                  //     } else {
                  //       // Handle error
                  //       print('Failed to fetch prof courses. Status Code: ${response
                  //           .statusCode}');
                  //     }
                  //   },
                  // ),
                  // ListTile(
                  //   leading: Icon(Icons.bookmark_added_outlined, size: _drawerIconSize,color: Colors.black,),
                  //   title: Text('Cours  paye',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                  //   onTap: ()async{
                  //     SharedPreferences prefs = await SharedPreferences.getInstance();
                  //     String token = prefs.getString("token")!;
                  //     String role = prefs.getString("role")!;
                  //     var response = await http.get(
                  //       Uri.parse('http://192.168.43.73:5000/cours?isPaid=effectué'),
                  //       headers: {
                  //         'Content-Type': 'application/json',
                  //         'Authorization': 'Bearer $token'
                  //       },
                  //     );
                  //     // print(response.body);
                  //
                  //     if (response.statusCode == 200) {
                  //       List<dynamic> courses = json.decode(
                  //           response.body)['cours'];
                  //       // this.coursNum = json.decode(response.body)['data']['countLL'];
                  //       // num heuresTV = json.decode(response.body)['data']['heuresTV'];
                  //       // num sommeTV = json.decode(response.body)['data']['sommeTV'];
                  //       // setState(() {
                  //       this.coursNum = json.decode(response.body)['cours'].length;
                  //       //
                  //       // });
                  //       print('Mes Cours :${json.decode(response.body)['cours']}');
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (context) =>
                  //             CoursesPage(courses: courses,
                  //               coursNum: coursNum,paid: true,
                  //               // heuresTV: heuresTV,
                  //               // sommeTV: sommeTV,
                  //               role: role,)),
                  //       );
                  //     } else {
                  //       // Handle error
                  //       print('Failed to fetch prof courses. Status Code: ${response
                  //           .statusCode}');
                  //     }
                  //   },
                  // ),
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
                    leading: Icon(Icons.sticky_note_2_outlined,size: _drawerIconSize,color: Colors.black),
                    title: Text('États de Paiements', style: TextStyle(fontSize: _drawerFontSize, color: Colors.black),
                    ),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EtatPaiemens()));
                    },
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
                    title: Text('Filières',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Filliere()),);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.read_more, size: _drawerIconSize,color: Colors.black),
                    title: Text('Autres',style: TextStyle(fontSize: _drawerFontSize,color: Colors.black),),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MoreOptionsPage(username: name!,
                          userRole: role!, userEmail: email!)));
                    },
                  ),
                  ElevatedButton(
                    child: Text('Logout',style: TextStyle(fontSize: _drawerFontSize,color: Colors.white),),
                    onPressed: () async{
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('token', '');
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())));
                      // MaterialPageRoute(builder: (context) => LoginSection()));

                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent,padding: EdgeInsets.symmetric(horizontal: 90,vertical: 10)),
                  ),
                ],)
          ],   ),   ),  ); }}

class BottomNav extends StatefulWidget {
//  final String? role; // Assurez-vous que le rôle est accessible ici

  BottomNav({Key ? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State {
  int _selectedIndex = 0;
  bool chngColor = false;
  bool isUser = true; // Change this based on your actual logic
  bool isAdmin = true; // Change this based on your actual logic
  bool isBook = false; // Change this based on your actual logic
  bool isMenu = false; // Change this based on your actual logic

  Color _getIconColor(int index) {
    if ((isUser && index == _selectedIndex) || (isAdmin && index == _selectedIndex) ) {
      return chngColor ? Colors.blueAccent : Colors.black;
    } else {
      return Colors.black87;
    }
  }

  @override
  void initState() {
    super.initState();
    // Call the function to check user's role
    checkUserRole();
    checkAdminRole();
  }

  Future<void> checkUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString("role")!;
    setState(() {
      isUser = (role == "professeur");
    });
  }
  Future<void> checkAdminRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString("role")!;
    setState(() {
      isAdmin = (role == "admin");
    });
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
      chngColor = true;
      print('index ${_selectedIndex}');
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString("role")!;
    if(role == "professeur") {
      if (index == 0) {
        // Handle Profile
        String token = prefs.getString("token")!;
        String id = prefs.getString("id")!;
        String nom = prefs.getString("nom")!;
        String mail = prefs.getString("email")!;
        String? profId = await getProfId(token, id)!;
        int? notif = await fetchPaiements(profId,token);
        int? CNS = await CoursNS(profId,token);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                role: role,
                name: nom,
                email: mail,
                profId: profId, // Passer l'ID du professeur à la page HomeScreen
                notif: notif, // Passer l'ID du professeur à la page HomeScreen
                CNS: CNS, // Passer l'ID du professeur à la page HomeScreen
              ),
            ));
      }
      if (index == 1) {
        // Handle Profile
        // index =1;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String token = prefs.getString("token")!;
        String role = prefs.getString("role")!;
        String email = prefs.getString("email")!;
        String id = prefs.getString("id")!;
        String nom = prefs.getString("nom")!;
        print(role);
        Navigator.push(context, MaterialPageRoute(
          builder: (context) =>
              ProfesseurDetailsScreen(profId: id, mail: email, nom: nom),
          // builder: (context) => LandingScreen(role: role,name: nom,), // Passer le rôle ici
        ),);
      }
      // else if (index == 1) {
      //   // Handle Categories (only for 'responsable')
      //
      //   try {
      //     SharedPreferences prefs = await SharedPreferences.getInstance();
      //     String token = prefs.getString("token")!;
      //     final professorData = await fetchProfessorInfo();
      //     String id = professorData['professeur']['_id'];
      //
      //     print(id);
      //     var response = await http.get(
      //       Uri.parse('http://192.168.43.73:5000/professeur/$id/cours'),
      //       headers: {
      //         'Content-Type': 'application/json',
      //         'Authorization': 'Bearer $token'
      //       },
      //     );
      //     // print(response.body);
      //
      //     if (response.statusCode == 200) {
      //       List<dynamic> courses = json.decode(
      //           response.body)['data']['coursLL'];
      //       int coursNum = json.decode(response.body)['data']['countLL'];
      //       num heuresTV = json.decode(response.body)['data']['heuresTV'];
      //       num sommeTV = json.decode(response.body)['data']['sommeTV'];
      //       String ProfId = json.decode(response.body)['data']['id'];
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) =>
      //             ProfCoursesPage(courses: courses,
      //               coursNum: coursNum,
      //               heuresTV: heuresTV,
      //               sommeTV: sommeTV, ProfId: ProfId,)),
      //       );
      //     }
      //     else {
      //       // Handle error
      //       Navigator.pop(context);
      //       print('Failed to fetch prof courses. Status Code: ${response
      //           .statusCode}');
      //     }
      //   } catch (err) {
      //     Navigator.pop(context);
      //     print('Server Error: $err');
      //   }
      // }
      else if (index == 2) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())));
        // MaterialPageRoute(builder: (context) => LogoutScreen()));
      }
    }


    else if(role == "admin") {
      if (index == 0) {
        // Handle Profile
        String token = prefs.getString("token")!;
        String id = prefs.getString("id")!;
        String nom = prefs.getString("nom")!;
        String mail = prefs.getString("email")!;
        String? profId = await getProfId(token, id)!;
        int? notif = await fetchPaiements(profId,token);
        int? CNS = await CoursNS(profId,token);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                role: role,
                name: nom,
                email: mail,
                profId: profId, // Passer l'ID du professeur à la page HomeScreen
                notif: notif, // Passer l'ID du professeur à la page HomeScreen
                CNS: CNS, // Passer l'ID du professeur à la page HomeScreen
              ),
            ));
      }
      if (index == 1) {
        // Handle Profile
        String email = prefs.getString("email")!;
        String id = prefs.getString("id")!;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Users()));
      }
      if (index == 2) {
        // Handle Profile
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Professeures()));
      }
      else if (index == 3) {
        // Handle ProfCourse (only for 'user')
        String username = prefs.getString("nom")!;
        String userRole = prefs.getString("role")!;
        String userEmail = prefs.getString("email")!;

        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => KeyboardVisibilityProvider(child: LoginSection())));
        // MaterialPageRoute(builder: (context) => MoreOptionsPage(username:username,userRole:userRole,userEmail: userEmail,)));
      }

    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: BottomNavigationBar(
          // selectedIconTheme: IconThemeData(color: chngColor ? Colors.blueAccent : Colors.black),
          unselectedItemColor: Colors.black87,
          showUnselectedLabels: true,
          iconSize: chngColor ? 25 : 20,
          currentIndex: _selectedIndex,
          selectedItemColor: chngColor ? Colors.blueAccent : Colors.black,
          showSelectedLabels: true,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          elevation: 5,
          items: isUser
              ? [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled, color: _getIconColor(0)),
              label: 'Acceuil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined, color: _getIconColor(1)),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout, color: _getIconColor(2)),
              label: 'Logout',
            ),
          ]
              : isAdmin
              ? [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: _getIconColor(0)),
              label: 'Acceuil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle_rounded, color: _getIconColor(1)),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded, color: _getIconColor(2)),
              label: 'Profs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout_rounded, color: _getIconColor(3)),
              label: 'Logout',
            ),
          ]
              : [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined, color: _getIconColor(0)),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined, color: _getIconColor(1)),
              label: 'Matieres',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined, color: _getIconColor(2)),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_outlined, color: _getIconColor(3)),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
class ClippingClass extends CustomClipper<Path>{
  @override

  Path getClip(Size size) {
    var path = Path();
    // path.lineTo(0.0, size.height - 40);
    // var controlPoint = Offset(size.width - (size.width / 2), size.height - 120);
    // var endPoint = Offset(size.width, size.height);
    // path.quadraticBezierTo(size.width -(size.width / 4),size.height,size.width,size.height - 40);
    // path.quadraticBezierTo(size.width /4,size.height,size.width/2,size.height);
    // path.lineTo(0,size.height);
    // path.quadraticBezierTo(300, 300,300, 300);


    path.lineTo(0,(size.height /2));
    path.cubicTo(size.width /4,(size.height /2) ,(size.width /4) * 3,size.height /4,size.width,size.height * 0.3,);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
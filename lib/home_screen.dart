import 'dart:convert';
import 'package:gestion_payements/matieres.dart';
import 'package:gestion_payements/paie.dart';
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
import 'auth/login.dart';
import 'auth/users.dart';
import 'categories.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.role, this.name, this.email}) : super(key: key);
  final String? role;
  final String? name;
  final String? email;
  // final String? lastname;
  static String routeName = 'HomeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  List<User>? useres;
  List<Professeur>? profs;
  List<Matiere>? mats;
  List<Category>? categs;
  int coursNum = 0;
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
    fetchMatiere().then((data) {
      setState(() {
        mats = data; // Assigner la liste renvoyée par Matiereesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchCategory().then((data) {
      setState(() {
        categs = data; // Assigner la liste renvoyée par Matiereesseur à items
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // overflow: Overflow.visible,
        fit: StackFit.expand,
        children: <Widget>[
          ClipPath(
            clipper: ClippingClass(),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height*4/7,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xff40dedf), Color(0xff0fb2ea)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 80,
            height: 60,
            width: 60,
            child: InkWell(
              onTap:() async {
                if (widget.role == "professeur") {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String token = prefs.getString("token")!;
                    String role = prefs.getString("role")!;
                    String email = prefs.getString("email")!;
                    String id = prefs.getString("id")!;
                    print(role);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) =>
                          ProfesseurInfoPage(id: id, email: email, role: role),
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
                child: Image.asset("assets/user1.png"),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                        "BienVenue ${widget.role!}",
                        style: GoogleFonts.slabo27px(
                          color: Colors.black,
                          fontSize: 20,
                        )
                    ),
                    Text(
                        " ${widget.name!.toUpperCase()}",
                      style: GoogleFonts.slabo27px(
                        // color: Colors.black,
                        fontSize: 20.0,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        // letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 60.0),
                  child: Text(
                      DateFormat('dd-MM-yyyy').format(DateTime.now()).toString(),
                      // DateTime.now().toString(),
                      style: GoogleFonts.slabo27px(
                        color: Colors.black,
                        fontSize: 20,
                      )
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            top: 200,
            right: 20,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap:(){},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      if (widget.role == "professeur")
                     Column(
                       children: [
                         Row(
                           children: [
                             _customCard(
                                 imageUrl: "cours3.png",
                                 item: "Mes Cours",
                                 duration: "${coursPN} Cours",
                               onPessed: ()async{
                                 try {
                                   SharedPreferences prefs = await SharedPreferences.getInstance();
                                   String token = prefs.getString("token")!;
                                   final professorData = await fetchProfessorInfo();
                                   String id = professorData['professeur']['_id'];

                                   print(id);
                                   var response = await http.get(
                                     Uri.parse('http://192.168.43.73:5000/professeur/$id/cours'),
                                     headers: {
                                       'Content-Type': 'application/json',
                                       'Authorization': 'Bearer $token'
                                     },
                                   );
                                   // print(response.body);

                                   if (response.statusCode == 200) {
                                     List<dynamic> courses = json.decode(
                                         response.body)['data']['coursLL'];
                                       coursPN = json.decode(response.body)['data']['countLL'];
                                     num heuresTV = json.decode(response.body)['data']['heuresTV'];
                                     num sommeTV = json.decode(response.body)['data']['sommeTV'];
                                     String ProfId = json.decode(response.body)['data']['id'];
                                     setState(() {
                                       coursPN = json.decode(response.body)['data']['countLL'];
                                     });
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(builder: (context) =>
                                           ProfCoursesPage(courses: courses,
                                             coursNum: coursPN,
                                             heuresTV: heuresTV,
                                             sommeTV: sommeTV, ProfId: ProfId,)),
                                     );
                                   }
                                   else {
                                     // Handle error
                                     Navigator.pop(context);
                                     print('Failed to fetch prof courses. Status Code: ${response
                                         .statusCode}');
                                   }
                                 } catch (err) {
                                   Navigator.pop(context);
                                   print('Server Error: $err');
                                 }
                               },
                             ),

                             _customCard(
                               imageUrl: "paie2.jpg",
                               item: "Paiements",
                               duration: "",
                               onPessed: ()async{
                                 try {
                                   SharedPreferences prefs = await SharedPreferences.getInstance();
                                   String token = prefs.getString("token")!;
                                   final professorData = await fetchProfessorInfo();
                                   String id = professorData['professeur']['_id'];

                                   print(id);
                                   var response = await http.get(
                                     Uri.parse('http://192.168.43.73:5000/professeur/$id/cours'),
                                     headers: {
                                       'Content-Type': 'application/json',
                                       'Authorization': 'Bearer $token'
                                     },
                                   );
                                   // print(response.body);

                                   if (response.statusCode == 200) {
                                     List<dynamic> courses = json.decode(
                                         response.body)['data']['coursLL'];
                                     String ProfId = json.decode(response.body)['data']['id'];
                                     String ProfName = json.decode(response.body)['data']['professeur'];
                                     setState(() {
                                     });
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(builder: (context) =>
                                           Paie(courses: courses,
                                             ProfId: ProfId, ProfName: ProfName,)),
                                     );
                                   }
                                   else {
                                     // Handle error
                                     Navigator.pop(context);
                                     print('Failed to fetch prof courses. Status Code: ${response
                                         .statusCode}');
                                   }
                                 } catch (err) {
                                   Navigator.pop(context);
                                   print('Server Error: $err');
                                 }
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
                                 duration: "${categs?.length} Categories",
                               onPessed: (){
                                 Navigator.push(
                                     context, MaterialPageRoute(builder: (context) => Categories()));

                               },
                             ),
                             _customCard(
                                 imageUrl: "Lang2.jpg",
                                 item: "Matieres",
                                 duration: "${mats?.length} Matieres",
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
                                           heuresTV: heuresTV,
                                           sommeTV: sommeTV, role: role,)),
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
                     Column(
                       children: [
                         Row(
                           children: [
                             _customCard(
                                 imageUrl: "users2.webp",
                                 item: "Utilisateures",
                                 duration: "${useres?.length!} Users",
                               onPessed: (){
                                   Navigator.push(
                                       context, MaterialPageRoute(builder: (context) => Users()));


                               },
                             ),
                             _customCard(
                                 imageUrl: "profs2.png",
                                 item: "Professeures",
                               duration: "${profs?.length!} Profs",
                               onPessed: (){
                                 Navigator.push(
                                     context, MaterialPageRoute(builder: (context) => Professeures()));
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
                                           heuresTV: heuresTV,
                                           sommeTV: sommeTV, role: role,)),
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
                               imageUrl: "categ2.png",
                               item: "Categories",
                               duration: "${categs?.length!} Categories",
                               onPessed: (){
                                 Navigator.push(
                                     context, MaterialPageRoute(builder: (context) => Categories()));

                               },
                             ),
                             _customCard(
                               imageUrl: "Lang2.jpg",
                               item: "Matieres",
                               duration: "${mats?.length} Matieres",
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
                               imageUrl: "settings2.png",
                               // imageUrl: "user1.png",
                               item: "Outils",
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

  _customCard({required String imageUrl, required String item, required String duration,required final VoidCallback onPessed}){
    return SizedBox(
      height: 158,
      width: 150,
      child: InkWell(
        onTap: onPessed,
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          elevation: 10,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset("assets/" + imageUrl,width: 70,),
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
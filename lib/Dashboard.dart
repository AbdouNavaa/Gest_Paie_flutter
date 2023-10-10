import 'dart:convert';
import 'package:gestion_payements/professeures.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/categories.dart';
import 'package:gestion_payements/matieres.dart';
import 'package:gestion_payements/prof_info.dart';
import 'package:gestion_payements/profs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'Cours.dart';
import 'ProfCours.dart';
import 'auth/login.dart';
import 'auth/profile.dart';
import 'auth/users.dart';
import 'more_page.dart';

class LogoutScreen extends StatefulWidget {

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sync_lock,size: 370,color: Color(0xFF0C2FDA),),
            Text("You must sign-in to access to this section", style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,fontStyle: FontStyle.italic),),
            SizedBox(height: 15,),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('token', '');
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginSection()));
              },
              child: Text("Logout", style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic,fontWeight: FontWeight.w400),),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15) ),
                  padding: EdgeInsets.only(left: 117,right: 117,top: 15,bottom: 15),foregroundColor: Colors.white,backgroundColor: Color(0xFF0C2FDA)),
            ),

          ],
        ),
      ),
      // bottomNavigationBar: BottomNav(),
    );
  }
}


class BottomNav extends StatefulWidget {
//  final String? role; // Assurez-vous que le rôle est accessible ici

  BottomNav({Key ? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State  {
  int _selectedIndex = 0;
  bool isUser = true; // Change this based on your actual logic
  bool isAdmin = true; // Change this based on your actual logic
  bool isBook = false; // Change this based on your actual logic
  bool isMenu = false; // Change this based on your actual logic

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
      print(_selectedIndex);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString("role")!;
    if(role == "professeur") {
      if (index == 0) {
        // Handle Profile
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
      else if (index == 1) {
        // Handle Categories (only for 'responsable')

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
            int coursNum = json.decode(response.body)['data']['countLL'];
            num heuresTV = json.decode(response.body)['data']['heuresTV'];
            num sommeTV = json.decode(response.body)['data']['sommeTV'];
            String ProfId = json.decode(response.body)['data']['id'];
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  ProfCoursesPage(courses: courses,
                    coursNum: coursNum,
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
      }
      else if (index == 2) {
        // Handle Matieres (only for 'responsable')

        String token = prefs.getString("token")!;

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LogoutScreen()));
      }
    }

    else if (role == "responsable") {
        if (index == 0) {
          // Handle Profile
          String email = prefs.getString("email")!;
          String id = prefs.getString("id")!;
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Categories()));
        }
        else if (index == 1) {
          // Handle Categories (only for 'responsable')

          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Matieres()));
          setState(() {
            isMenu = true;
          });
        }
        else if (index == 2) {
          // Handle Matieres (only for 'responsable')
setState(() {
  isBook = true;
});
          String token = prefs.getString("token")!;
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
            int coursNum = json.decode(response.body)['data']['countLL'];
            num heuresTV = json.decode(response.body)['data']['heuresTV'];
            num sommeTV = json.decode(response.body)['data']['sommeTV'];
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  CoursesPage(courses: courses,
                    coursNum: coursNum,
                    heuresTV: heuresTV,
                    sommeTV: sommeTV, role: '',)),
            );
          } else {
            // Handle error
            print('Failed to fetch prof courses. Status Code: ${response
                .statusCode}');
          }
        }
        else if (index == 3) {
          // Handle ProfCourse (only for 'user')
          String username = prefs.getString("nom")!;
          String userRole = prefs.getString("role")!;
          String userEmail = prefs.getString("email")!;

          Navigator.push(
              context, MaterialPageRoute(builder: (context) =>
              MoreOptionsPage(username:username,userRole:userRole,userEmail: userEmail,)));
        }
      }

    else if(role == "admin") {
      if (index == 0) {
        // Handle Profile
        String email = prefs.getString("email")!;
        String id = prefs.getString("id")!;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Users()));
      }
      if (index == 1) {
        // Handle Profile
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Professeures()));
      }
      else if (index == 2) {
        // Handle Matieres (only for 'responsable')
        setState(() {
          isBook = true;
        });
        String token = prefs.getString("token")!;
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
          int coursNum = json.decode(response.body)['data']['countLL'];
          num heuresTV = json.decode(response.body)['data']['heuresTV'];
          num sommeTV = json.decode(response.body)['data']['sommeTV'];
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                CoursesPage(courses: courses,
                  coursNum: coursNum,
                  heuresTV: heuresTV,
                  sommeTV: sommeTV, role: '',)),
          );
        } else {
          // Handle error
          print('Failed to fetch prof courses. Status Code: ${response
              .statusCode}');
        }
      }
      else if (index == 3) {
        // Handle ProfCourse (only for 'user')
        String username = prefs.getString("nom")!;
        String userRole = prefs.getString("role")!;
        String userEmail = prefs.getString("email")!;

        Navigator.push(
            context, MaterialPageRoute(builder: (context) =>
            MoreOptionsPage(username:username,userRole:userRole,userEmail: userEmail,)));
      }

    }

  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          selectedIconTheme: IconThemeData(color: Colors.black),
          unselectedItemColor: Colors.black87,
          showUnselectedLabels: true,
          // selectedLabelStyle: TextStyle(color: Colors.orangeAccent),
          // unselectedLabelStyle: TextStyle(color: Colors.orangeAccent),
          unselectedIconTheme: IconThemeData(color: Colors.black),
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black87,
          showSelectedLabels: true,
          onTap: _onItemTapped,
          backgroundColor: Colors.white, // Customize background color
          elevation: 5, // No shadow
          items: isUser
              ? [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Prof Course',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Logout',
            ),
          ]
              : isAdmin
?          [
            BottomNavigationBarItem(
              icon: Icon(Icons.supervised_user_circle_rounded),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              // icon: Icon(isBook? Icons.book:Icons.book_outlined),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_outlined),
              label: 'More',
            ),
          ]:
          [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              // icon: Icon(isMenu? Icons.dashboard:Icons.dashboard_outlined),
              icon: Icon(Icons.school_outlined),
              label: 'Matieres',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              // icon: Icon(isBook? Icons.book:Icons.book_outlined),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_outlined),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

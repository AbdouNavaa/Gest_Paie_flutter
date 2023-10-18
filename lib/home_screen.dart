import 'dart:convert';
import 'package:gestion_payements/matieres.dart';
import 'package:gestion_payements/professeures.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:gestion_payements/auth/profile.dart';
import 'package:gestion_payements/constants.dart';
import 'package:gestion_payements/prof_info.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('BienVennue'),
      //   actions: [
      //     InkWell(
      //       onTap: (){
      //
      //       },
      //       child: Container(
      //         padding: EdgeInsets.only(
      //             right: kDefaultPadding /2
      //         ),
      //         child: Row(
      //           children: [
      //             Icon(Icons.logout),
      //             // kHalfWidthsizedBox,
      //             // Text('Logout',style: TextStyle(color: Colors.white, fontSize: 20),)
      //           ],
      //         ),
      //       ),
      //     )
      //   ],
      // ),
      body:
    Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 3,
          padding: EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('BienVenue',style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          fontWeight: FontWeight.w700,fontSize: 25
                      ),),
                      User(userName: widget.name!, role: widget.role!, ),
                      // kHalfsizedBox,
                      // UserRole(userRole: 'Role: ${widget.role!}'),

                      kHalfsizedBox,
                      BookingYear(bookingYear: DateTime.now().toString())
                    ],
                  ),
                  kHalfsizedBox,
                  if (widget.role == "professeur")
                    Row(
                      children: [
                        UserPicture(picAdderess: 'assets/user1.png', onPressed: () async {
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
                        )

                      ],
                    ),
                  if (widget.role == "responsable" || widget.role == "admin")
                    Row(
                      children: [
                        UserPicture(picAdderess: 'assets/user1.png', onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                username: widget.name,
                                role: widget.role,
                                email: widget.email,
                              ),
                            ),
                          );


                        }
                        )

                      ],
                    ),
                ],
              ),
              SizedBox(height: kDefaultPadding ,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // HotelDataCard(title: 'Hotel Place', value: 'Nktt', onPressed: (){}),
                  // HotelDataCard(title: 'Price', value: '35.000 MRU', onPressed: (){}),

                ],
              )
            ],
          ),
        ),

        Expanded(
            child: Container(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(kDefaultPadding * 3),
                    topRight: Radius.circular(kDefaultPadding * 3),
                  )
                ),
                child: ListView(primary: true,
                  children: [
                    if (widget.role == "professeur")
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [

                            // HomeCard(onPessed: ()async{
                            //   SharedPreferences prefs = await SharedPreferences.getInstance();
                            //   String token = prefs.getString("token")!;
                            //   String role = prefs.getString("role")!;
                            //   String email = prefs.getString("email")!;
                            //   String id = prefs.getString("id")!;
                            //   print(role);
                            //   Navigator.push(context, MaterialPageRoute(
                            //     builder: (context) =>
                            //         ProfesseurInfoPage(id: id, email: email, role: role),
                            //     // builder: (context) => LandingScreen(role: role,name: nom,), // Passer le rôle ici
                            //   ),);
                            //
                            // },
                            //   icon: Icons.person_add_alt_outlined,
                            //   title: 'Mes Infos',),
                            HomeCard(onPessed: ()async{
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
                            },
                              icon: Icons.book_outlined,
                              title: 'Mes Cours',),
                            HomeCard(
                              onPessed: (){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(' Ne fonctionne pas actuellement')),
                                );
                              },
                              icon: Icons.paid_outlined,
                              title: 'Paiements',),

                          ],
                        ),
                        SizedBox(height: kDefaultPadding,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            HomeCard(
                              onPessed:  () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setString('token', '');
                                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginSection()));
                              },
                              icon: Icons.logout_rounded,
                              title: 'Se Déconnecter',),

                          ],
                        ),
                      ],
                    ),
                    if (widget.role == "responsable")
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [

                              HomeCard(onPessed: (){
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => Categories()));

                              },
                                icon: Icons.category_outlined,
                                title: 'Categories',),
                              HomeCard(onPessed: (){
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => Matieres()));

                              },
                                icon: Icons.school_outlined,
                                title: 'Matieres',),

                            ],
                          ),
                          SizedBox(height: kDefaultPadding,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              HomeCard(onPessed: ()async{
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
                                  int coursNum = json.decode(response.body)['data']['countLL'];
                                  num heuresTV = json.decode(response.body)['data']['heuresTV'];
                                  num sommeTV = json.decode(response.body)['data']['sommeTV'];
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
                                icon: Icons.book_outlined,
                                title: 'Cours',),
                              HomeCard(onPessed: (){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(' Ne fonctionne pas actuellement')),
                                );
                              },
                                icon: Icons.paid_outlined,
                                title: 'Paiements',),
                            ],
                          ),
                          SizedBox(height: kDefaultPadding,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              HomeCard(
                                onPessed:  () async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('token', '');
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginSection()));
                                },
                                icon: Icons.logout_rounded,
                                title: 'Se Déconnecter',),
                            ],
                          ),
                        ],
                      ),

                    if (widget.role == "admin")
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              HomeCard(onPessed: (){
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => Users()));

                              },
                                icon: Icons.groups_outlined,
                                title: 'Utilisateures',),
                              HomeCard(onPessed: (){
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => Professeures()));
                              },
                                icon: Icons.person_outline,
                                title: 'Professeures',),
                            ],
                          ),
                          SizedBox(height: kDefaultPadding,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              HomeCard(onPessed: ()async{
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
                                  int coursNum = json.decode(response.body)['data']['countLL'];
                                  num heuresTV = json.decode(response.body)['data']['heuresTV'];
                                  num sommeTV = json.decode(response.body)['data']['sommeTV'];
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
                                icon: Icons.book_outlined,
                                title: 'Cours',),
                              HomeCard(onPessed: (){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(' Ne fonctionne pas actuellement')),
                                );
                              },
                                icon: Icons.paid_outlined,
                                title: 'Paiements',),
                            ],
                          ),
                          SizedBox(height: kDefaultPadding,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [

                              HomeCard(onPessed: (){
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => Categories()));

                              },
                                icon: Icons.category_outlined,
                                title: 'Categories',),
                              HomeCard(onPessed: (){
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => Matieres()));

                              },
                                icon: Icons.school_outlined,
                                title: 'Matieres',),

                            ],
                          ),
                          SizedBox(height: kDefaultPadding,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              HomeCard(
                                onPessed:  () async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('token', '');
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginSection()));
                                },
                                icon: Icons.logout_rounded,
                                title: 'Se Déconnecter',),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ))
      ],
    ),);
  }
}

class HomeCard extends StatelessWidget {
  const HomeCard({
    Key? key, required this.onPessed, required this.icon, required this.title,
  }) : super(key: key);
final VoidCallback onPessed;
final IconData icon;
final String title;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPessed,
      child: Container(
        // margin: EdgeInsets.only(top: kDefaultPadding / 2),
        width: MediaQuery.of(context).size.width / 2.5,
        height: MediaQuery.of(context).size.height/ 5.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kDefaultPadding),border: Border.all(color: Colors.black12)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black,),
            Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
class User extends StatelessWidget {
  const User({Key? key, required this.userName, required this.role}) : super(key: key);
  final String userName;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(role,style: Theme.of(context).textTheme.subtitle1!.copyWith(
          fontWeight: FontWeight.w700,fontSize: 25
        ),),
        SizedBox(width: 5,),
        Text(userName,style: Theme.of(context).textTheme.subtitle1!.copyWith(
          fontWeight: FontWeight.w700,fontSize: 25
        ),),
      ],
    );
  }
}

class UserRole extends StatelessWidget {
  const UserRole({Key? key, required this.userRole}) : super(key: key);
  final String userRole;
  @override
  Widget build(BuildContext context) {
    return Text(userRole,
      style: Theme.of(context).textTheme.subtitle2!.copyWith(
          fontSize: 18.0
      ),);
  }
}
class BookingYear extends StatelessWidget {
  const BookingYear({Key? key, required this.bookingYear}) : super(key: key);
  final String bookingYear;
  @override
  Widget build(BuildContext context) {
    return    Container(
      width: 100,
      height: 20,
      decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: BorderRadius.circular(kDefaultPadding)
      ),
      child: Center(
        child: Text(bookingYear,
          style: TextStyle(
              fontSize: 17,
              color: kTextBlackColor,
              fontWeight: FontWeight.bold
          ),),
      ),
    );
  }
}
class UserPicture extends StatelessWidget {
  const UserPicture({Key? key, required this.picAdderess, required this.onPressed}) : super(key: key);
  final String picAdderess;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        minRadius: 50.0,
        maxRadius: 50.0,
        backgroundColor: kSecondaryColor,
        // child:Icon(picAdderess, size: 70, color: Colors.white,),
        backgroundImage: AssetImage(picAdderess,),

      ),
    )
    ;
  }
}

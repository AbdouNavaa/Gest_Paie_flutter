import 'package:flutter/material.dart';
import 'package:gestion_payements/settings.dart';

import 'Dashboard.dart';
import 'auth/profile.dart';
import 'categories.dart';
import 'matieres.dart';

class MoreOptionsPage extends StatefulWidget {
   late String username;
      late String userRole;
  late String userEmail;
MoreOptionsPage({required this.username, required this.userRole,required this.userEmail});
   bool isDark = false;

  @override
  State<MoreOptionsPage> createState() => _MoreOptionsPageState();
}

class _MoreOptionsPageState extends State<MoreOptionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.isDark? Color(0xD5464640): Colors.white,
        title: Text('More Options',style: TextStyle(
          color: widget.isDark?  Colors.white: Color(0xD5464640),
        ),),
      ),
      backgroundColor: widget.isDark? Color(0xD5464640): Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // SizedBox(height: 70,),
          if (widget.userRole == "responsable")

            Column(
              children: [
                Container(
                  height: 100,child: Row(
                  children: [
                    SizedBox(width: 150,),
                    Icon(Icons.manage_accounts_outlined, size: 80,),
                  ],
                ),),
                SwitchListTile(
                    title: const Text('Dark Mode?',style: TextStyle(
                      color: Colors.green,),),
                    value: widget.isDark,
                    onChanged: (_) {
                      setState(() {
                        widget.isDark = !widget.isDark;
                      });
                    }),
                Divider(),
                Container(
                  height: MediaQuery.of(context).size.height/ 15,
                  width: MediaQuery.of(context).size.width,

                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: widget.isDark? Colors.white : Colors.black87,
                        // //backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),

                    onPressed: () {
                      // Navigate to LogoutScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LogoutScreen()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.logout_outlined, color: widget.isDark? Colors.green : Colors.black,),
                        SizedBox(width: 10,),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height/ 15,
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: widget.isDark? Colors.white : Colors.black87,
                        // //backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: () {
                      // Navigate to ProfilePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(
                            username: widget.username,
                            role: widget.userRole,
                            email: widget.userEmail,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.person_off, color: widget.isDark? Colors.green : Colors.black,),
                        SizedBox(width: 10,),
                        Text('Profile'),
                      ],
                    ),
                  ),
                ),

                Divider(),

                Container(
                  height: MediaQuery.of(context).size.height/ 15,
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: widget.isDark? Colors.white : Colors.black87,//backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: () {
                      // Navigate to CategoriesPage
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => SettingsPage()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.settings, color: widget.isDark? Colors.green : Colors.black,),
                        SizedBox(width: 10,),
                        Text('Settings'),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height/ 15,
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: widget.isDark? Colors.white : Colors.black87,//backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: () {
                      // Navigate to UsersPage
                      // Navigator.push(
                      //     context, MaterialPageRoute(builder: (context) => Matieres()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: widget.isDark? Colors.green : Colors.black,),
                        SizedBox(width: 10,),
                        Text('About'),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          if (widget.userRole == "admin")

           Column(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.max,
             children: [
              Container(
                height: 100,child: Row(
                children: [
                 SizedBox(width: 150,),
                  Icon(Icons.manage_accounts_outlined, size: 80,),
                ],
              ),),
               SwitchListTile(
                   title: const Text('Dark Mode?',style: TextStyle(
                     color: Colors.green,),),
                   value: widget.isDark,
                   onChanged: (_) {
                     setState(() {
                       widget.isDark = !widget.isDark;
                     });
                   }),
               Divider(),
               Container(
                 height: MediaQuery.of(context).size.height/ 15,
                 width: MediaQuery.of(context).size.width,

                 child: TextButton(
                   style: TextButton.styleFrom(
                       foregroundColor: widget.isDark? Colors.white : Colors.black87,
                       // //backgroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),

                   onPressed: () {
                     // Navigate to LogoutScreen
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => LogoutScreen()),
                     );
                   },
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Icon(Icons.logout_outlined, color: widget.isDark? Colors.green : Colors.black,),
                       SizedBox(width: 10,),
                       Text('Logout'),
                     ],
                   ),
                 ),
               ),
               Container(
                 height: MediaQuery.of(context).size.height/ 15,
                 width: MediaQuery.of(context).size.width,
                 child: TextButton(
                   style: TextButton.styleFrom(
                       foregroundColor: widget.isDark? Colors.white : Colors.black87,
                       // //backgroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                   onPressed: () {
                     // Navigate to ProfilePage
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => ProfilePage(
                           username: widget.username,
                           role: widget.userRole,
                           email: widget.userEmail,
                         ),
                       ),
                     );
                   },
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Icon(Icons.person_off, color: widget.isDark? Colors.green : Colors.black,),
                       SizedBox(width: 10,),
                       Text('Profile'),
                     ],
                   ),
                 ),
               ),
               Container(
                 height: MediaQuery.of(context).size.height/ 15,
                 width: MediaQuery.of(context).size.width,
                 child: TextButton(
                   style: TextButton.styleFrom(
                       foregroundColor: widget.isDark? Colors.white : Colors.black87,
                       // //backgroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                   onPressed: () {
                     // Navigate to CategoriesPage
                     Navigator.push(
                         context, MaterialPageRoute(builder: (context) => Categories()));
                   },
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Icon(Icons.local_offer, color: widget.isDark? Colors.green : Colors.black,),
                       SizedBox(width: 10,),
                       Text('Categories'),
                     ],
                   ),
                 ),
               ),
               Container(
                 height: MediaQuery.of(context).size.height/ 15,
                 width: MediaQuery.of(context).size.width,
                 child: TextButton(
                   style: TextButton.styleFrom(
                       foregroundColor: widget.isDark? Colors.white : Colors.black87,//backgroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                   onPressed: () {
                     // Navigate to UsersPage
                     Navigator.push(
                         context, MaterialPageRoute(builder: (context) => Matieres()));
                   },
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Icon(Icons.school_outlined, color: widget.isDark? Colors.green : Colors.black,),
                       SizedBox(width: 10,),
                       Text('Matieres'),
                     ],
                   ),
                 ),
               ),
               Divider(),

               Container(
                 height: MediaQuery.of(context).size.height/ 15,
                 width: MediaQuery.of(context).size.width,
                 child: TextButton(
                   style: TextButton.styleFrom(
                       foregroundColor: widget.isDark? Colors.white : Colors.black87,//backgroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                   onPressed: () {
                     // Navigate to CategoriesPage
                     // Navigator.push(
                     //     context, MaterialPageRoute(builder: (context) => AppState()));
                     Navigator.push(
                         context, MaterialPageRoute(builder: (context) => SettingsPage())); },
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Icon(Icons.settings, color: widget.isDark? Colors.green : Colors.black,),
                       SizedBox(width: 10,),
                       Text('Settings'),
                     ],
                   ),
                 ),
               ),
               Container(
                 height: MediaQuery.of(context).size.height/ 15,
                 width: MediaQuery.of(context).size.width,
                 child: TextButton(
                   style: TextButton.styleFrom(
                       foregroundColor: widget.isDark? Colors.white : Colors.black87,//backgroundColor: Colors.white,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                   onPressed: () {
                     // Navigate to UsersPage
                     // Navigator.push(
                     //     context, MaterialPageRoute(builder: (context) => Matieres()));
                   },
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Icon(Icons.info_outline, color: widget.isDark? Colors.green : Colors.black,),
                       SizedBox(width: 10,),
                       Text('About'),
                     ],
                   ),
                 ),
               ),
             ],
           )
        ],
      ),
      // bottomNavigationBar: BottomNav(),
    );
  }
}


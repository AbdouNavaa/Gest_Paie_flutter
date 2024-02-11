import 'package:flutter/material.dart';
import 'package:gestion_payements/filliere.dart';
import 'package:gestion_payements/semestre.dart';
import 'package:gestion_payements/settings.dart';

import 'Dashboard.dart';
import 'auth/profile.dart';
import 'categories.dart';
import 'group.dart';
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
        title: Row(
          children: [
            SizedBox(width: 50,),
            Text('Autres',style: TextStyle(
              color: widget.isDark?  Colors.white: Color(0xD5464640),
            ),),
          ],
        ),leading:
      TextButton(onPressed: (){
        Navigator.pop(context);
      }, child: Icon(Icons.arrow_back_ios_new_outlined,size: 20,),
        style: TextButton.styleFrom(
          backgroundColor:Colors.white ,
          foregroundColor:Colors.black ,
          // elevation: 10,
          // shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black26)),
        ),
      ),

      ),
      backgroundColor: widget.isDark? Color(0xD5464640): Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // SizedBox(height: 70,),
          if (widget.userRole == "responsable")

            Column(
              children: [
                // Container(
                //   height: 100,child: Row(
                //   children: [
                //     SizedBox(width: 150,),
                //     Icon(Icons.description_outlined, size: 80,),
                //   ],
                // ),),
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
                          builder: (context) =>Semestres()
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.date_range, color: widget.isDark? Colors.green : Colors.black,),
                        SizedBox(width: 10,),
                        Text('Semestres'),
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
              // Container(
              //   height: 100,child: Row(
              //   children: [
              //    SizedBox(width: 150,),
              //     Icon(Icons.description_outlined, size: 70,color: Colors.black26,),
              //   ],
              // ),),
               SizedBox(height: 100,),
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
                       MaterialPageRoute(builder: (context) => Groups()),
                     );
                   },
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Icon(Icons.file_copy_outlined, color: widget.isDark? Colors.green : Colors.black,),
                       SizedBox(width: 10,),
                       Text('Groups'),
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
                           builder: (context) =>Semestres()
                       ),
                     );
                   },
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Icon(Icons.date_range, color: widget.isDark? Colors.green : Colors.black,),
                       SizedBox(width: 10,),
                       Text('Semestres'),
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
                       Icon(Icons.qr_code, color: widget.isDark? Colors.green : Colors.black,),
                       // Image.asset('assets/categ2.png'),
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
                       Icon(Icons.code, color: widget.isDark? Colors.green : Colors.black,),
                       // Image.asset('assets/coding3.png',width: 25,),
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


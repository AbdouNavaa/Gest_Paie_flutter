import 'package:flutter/material.dart';
import 'package:gestion_payements/auth/settings.dart';
import 'package:provider/provider.dart';

import '../Dashboard.dart';
import '../main.dart';


class ProfilePage extends StatefulWidget {
  final String? username;
  final String? role;
  final String? email;
  final String? prenom;
  final num? mobile;

  ProfilePage({this.role, this.email, this.username,this.prenom,this.mobile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Profile'),
      // ),
      body: Column(
        children: [

          SizedBox(height: 40),
          Container(
            height: 50,
            child: Row(
              children: [
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
                SizedBox(width: 30,),
                Text("Profile",style: TextStyle(fontSize: 25),)
              ],
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage(
                        'assets/user1.png'),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.all(5),
                    height: 350,
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: Icon(Icons.perm_identity_sharp, size: 30),
                              title: Text(
                                "Username",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Text(
                                widget.username!,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.workspace_premium, size: 30),
                              title: Text(
                                "Role",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Text(
                                widget.role!,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.alternate_email_sharp, size: 30),
                              title: Text(
                                "Email",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              subtitle: Text(
                                widget.email!,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),

      // bottomNavigationBar: BottomNav(),

    );
  }
}



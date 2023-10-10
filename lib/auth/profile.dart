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
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(
                    'https://th.bing.com/th/id/R.8b167af653c2399dd93b952a48740620?rik=%2fIwzk0n3LnH7dA&pid=ImgRaw&r=0'),
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

      // bottomNavigationBar: BottomNav(),

    );
  }
}



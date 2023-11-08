import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Dashboard.dart';
import 'main.dart';




class Profs extends StatefulWidget {
  static const String id = "Private";
  Profs({Key ? key}) : super(key: key);

  @override
  _ProfsState createState() => _ProfsState();
}

class _ProfsState extends State<Profs> {

  Future<List<Prof>>? futureProf;

  List<Prof>? filteredItems;

  void DeleteProf(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/delete' +"/$id"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'token': token,
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchProf();
    }

  }

  Future<List<Prof>> fetchProf() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    final response = await http.get(
      Uri.parse('http://192.168.43.73:5000/private'),
      headers: {"token": token},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> jsonResponse = jsonDecode(response.body);
      // items = jsonResponse;
      List<Prof> profs = [];

      for (var item in jsonResponse) {
        profs.add(
          Prof(
            id: item['_id'],
            nom: item['nom'],
            prenom: item['prenom'],
            email: item['email'],
            tel: item['tel'],
            Banque: item['Banque'],
            Compte: item['Compte'],
          ),
        );
      }

      print(profs);
      // setState(() {
      //
      // });
      return profs;

    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Prof');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProf().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Professeur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
  }
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        appBar: AppBar(
          title: Center(child: Text(' ${filteredItems?.length} Professeurs')),
        ),
        body: Column(
          children: [
            Container(
              child: TextField(
                controller: _searchController,
                onChanged: (value) async {
                  List<Prof> profs = await fetchProf();

                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les professeurs dont le nom ou le prénom contient la valeur saisie
                    filteredItems = profs!.where((prof) =>
                    prof.nom!.toLowerCase().contains(value.toLowerCase()) ||
                        prof.prenom!.toLowerCase().contains(value.toLowerCase()) || prof.email!.toLowerCase().contains(value.toLowerCase())).toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by name or surname',
                  prefixIcon: Icon(Icons.search),
                ),
              )
              ,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: FutureBuilder<List<Prof>>(
                    future: fetchProf(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<Prof>? items = snapshot.data;

                          return ListView.builder(
                              itemCount: filteredItems!.length,
                              itemBuilder: (context, int index) {
                                return Container(
                                  height: 150,
                                  margin: EdgeInsets.all(8),
                                  child: Card(
                                    elevation: 5,margin: EdgeInsets.only(top: 10),
                                    shadowColor: Colors.blue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    child: InkWell(
                                      onTap: () {
                                      },
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Image.network('https://th.bing.com/th/id/R.8b167af653c2399dd93b952a48740620?rik=%2fIwzk0n3LnH7dA&pid=ImgRaw&r=0', width: 170,
                                                fit: BoxFit.fill,
                                                height: 85,),

                                              SizedBox(height: 5,),
                                              ElevatedButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text("Confirmer la suppression"),
                                                        content: Text(
                                                            "Êtes-vous sûr de vouloir supprimer cet élément ?"),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child: Text("ANNULER"),
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: Text(
                                                              "SUPPRIMER",
                                                              // style: TextStyle(color: Colors.red),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                              DeleteProf(snapshot.data![index].id);
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(content: Text('Le Prof a été Supprimer avec succès.')),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Text('Supprimer'),
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.deepOrangeAccent,padding: EdgeInsets.only(left: 65,right: 65),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                                                ),
                                              ),

                                            ],
                                          ),

                                          SizedBox(width: 10,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '${filteredItems![index].nom} ${filteredItems![index].prenom}',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                '${filteredItems![index].email}',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                '${filteredItems![index].tel}',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                '${filteredItems![index].Banque}',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              SizedBox(height: 5,),
                                              Text(
                                                '${filteredItems![index].Compte}',
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w400,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                              // ElevatedButton(
                                              //   style: ElevatedButton.styleFrom(
                                              //     backgroundColor: Colors.black54,
                                              //     padding: EdgeInsets.only(left: 40, right: 40),
                                              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                              //   ),
                                              //   onPressed: () {
                                              //   },
                                              //   child: Text(
                                              //     'Courses',
                                              //     style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                                              //   ),
                                              // ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );

                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Container(margin:EdgeInsets.only(left: 230),height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black,  elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: () => _displayTextInputDialog(context),
            child: Row(
              children: [
                Icon(Icons.add,size: 30,color: Colors.blue,),
                Text('Ajouter', style: TextStyle(fontSize: 17,fontStyle: FontStyle.italic,color: Colors.blue),)
              ],
            ),
            // tooltip: 'Add Prof',
          ),
        ),

      ),
      // bottomNavigationBar: BottomNav(),

    );
  }
}

class Prof {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String tel;
  final String Banque;
  final String Compte;

  Prof({required this.id, required this.nom, required this.prenom, required this.email,required this.tel,
    required this.Banque,required this.Compte, });

  factory Prof.fromJson(Map<String, dynamic> json) {
    return Prof(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      tel: json['tel'],
      Banque: json['Banque'],
      Compte: json['Compte'],
    );
  }
}
void AddProf (String nom,String prenom,String email,String tel,String Banque,String Compte,) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);
  final response = await http.post(
    Uri.parse('http://192.168.43.73:5000/addProf'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'token': token,
    },
    body: jsonEncode(<String, dynamic>{
      "nom":nom,
      "prenom":prenom ,
      "email": email ,
      "tel": tel ,
      "Banque": Banque ,
      "Compte": Compte ,
    }),
  );
  if (response.statusCode == 200) {
    print('Prof ajouter avec succes');
  } else {
    print("SomeThing Went Wrong");
  }
}


Future<void> _displayTextInputDialog(BuildContext context) async {
  TextEditingController _nom = TextEditingController();
  TextEditingController _prenom = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _tel = TextEditingController();
  TextEditingController _Banque = TextEditingController();
  TextEditingController _Compte = TextEditingController();


  Profs prof;
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text('Ajouter un Proffesseur'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nom,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "nom",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),
                  TextField(
                    controller: _prenom,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "prenom",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Email",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),
                  TextField(
                    controller: _tel,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "tel",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),
                  TextField(
                    controller: _Banque,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Banque",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),
                  TextField(
                    controller: _Compte,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Compte",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),

                  ElevatedButton(onPressed: (){
                    Navigator.of(context).pop();
                    // fetchProf();
                    AddProf(_nom.text,_prenom.text,_email.text,_tel.text,_Banque.text,_Compte.text,);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Le Prof a été ajouter avec succès.')),
                    );
                  }, child: Text("Ajouter"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff0fb2ea),
                      foregroundColor: Colors.white,
                      elevation: 10,
                      padding: EdgeInsets.only(left: 90, right: 90),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),)
                ],
              ),
            )
        );
      });
}
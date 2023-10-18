import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Dashboard.dart';





class Users extends StatefulWidget {
  Users({Key ? key}) : super(key: key);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {

  Future<List<User>>? futureUser;

  List<User>? filteredItems;
  bool _userIsActive = false; // Variable pour suivre l'état de l'utilisateur

  void DeleteUser(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/categorie' +"/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchUser();
    }

  }


  @override
  void initState() {
    super.initState();
    fetchUser().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Useresseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
  }
  TextEditingController _searchController = TextEditingController();

  TextEditingController _name = TextEditingController();
  TextEditingController _desc = TextEditingController();
  TextEditingController _taux = TextEditingController();
  num _selectedTaux = 500;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        // appBar: AppBar(
        //   title: Center(child: Text(' ${filteredItems?.length} ')),
        // ),
        body: Column(
          children: [
            SizedBox(height: 40,),
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
                  Text("Liste de Utlisateurs",style: TextStyle(fontSize: 25),)
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) async {
                  List<User> Users = await fetchUser();

                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les Useresseurs dont le name ou le préname contient la valeur saisie
                    filteredItems = Users!.where((User) =>
                    User.name!.toLowerCase().contains(value.toLowerCase()) ||
                        User.prenom!.toLowerCase().contains(value.toLowerCase())).toList();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Rechercher  ',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),

              )
              ,
            ),
            Container(width: 200,height: 50,
                // color: Colors.black87,
                // margin: EdgeInsets.all(8),
                child: Card(
                    elevation: 5,
                    // margin: EdgeInsets.only(top: 10),
                    shadowColor: Colors.blue,
                    // color: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(' ${filteredItems?.length} Users',style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)))),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: FutureBuilder<List<User>>(
                    future: fetchUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<User>? items = snapshot.data;

                          return  SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                              margin: EdgeInsets.only(left: 10),
                              child: DataTable(
                                showCheckboxColumn: true,
                                showBottomBorder: true,
                                headingRowHeight: 50,
                                horizontalMargin: 2,
                                columnSpacing: 3,
                                dataRowHeight: 50,
                                // border: TableBorder.all(color: Colors.black12, width: 2),
                                headingTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Set header text color
                                ),
                                // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFF0C2FDA)), // Set row background color
                                columns: [
                                  DataColumn(label: Text('No')),
                                  DataColumn(label: Text('Active')),
                                  DataColumn(label: Text('Nom')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Mobile')),
                                  DataColumn(label: Text('Role')),
                                  // DataColumn(label: Text('Catégorie')),
                                  DataColumn(label: Text('Action')),
                                ],
                                rows: [
                                  for (var index = 0; index < (filteredItems?.length ?? 0); index++)
//                                    if(filteredItems?[index].role != 'admin')
                                    DataRow(
                                      cells: [
                                        DataCell(Text('${index + 1}',style: TextStyle(fontSize: 15),)), // Numbering cell
                                        DataCell(
                                            CupertinoSwitch(
                                              activeColor: Colors.black,
                                              value: filteredItems![index].isActive!,
                                              onChanged: (value) async {
                                                // Continue with the rest of your onChanged logic if the types string is in the expected format
                                                setState(() {
                                                  // filteredItems![index].isActive = value;
                                                  // fetchUser();
                                                });

                                                // Navigator.of(context).pop();

                      fetchUser().then((data) {
                      setState(() {
                      filteredItems = data; // Assigner la liste renvoyée par Useresseur à items
                      });});

                                                  ActiveUser(
                                                    filteredItems![index].id,
                                                  );
                                              },
                                            )

                                        ), DataCell(Container(width: 70,
                                            child: Text('${filteredItems?[index].name } ${filteredItems?[index].prenom}'))),
                                        DataCell(Container(width: 150,
                                            child: Text('${filteredItems?[index].email}',)),),
                                        DataCell(Container(width: 68,
                                            child: Text('${filteredItems?[index].mobile}',)),),
                                        DataCell(Container(width: 80,
                                            child: Text('${filteredItems?[index].role}',)),),

                                        // DataCell(Container(width: 105,
                                        //     child: Text('${filteredItems?[index].description}',)),),
                                        // DataCell(Text('${filteredItems?[index].categorie}')),
                                        DataCell(
                                          Row(
                                            children: [
                                              Container(
                                                width: 35,
                                                child: TextButton(
                                                  onPressed: () {
                                                    _name.text = items![index].name!;
                                                    _desc.text = items![index].prenom!;
                                                    // _selectedTaux = items![index].email!;
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: Text("Mise à jour de la tâche"),
                                                          content: Form(
                                                            child: SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  TextFormField(
                                                                    controller: _name,
                                                                    decoration: InputDecoration(labelText: 'Name'),
                                                                  ),
                                                                  TextFormField(
                                                                    controller: _desc,
                                                                    decoration: InputDecoration(labelText: 'Descreption'),
                                                                  ),
                                                                  DropdownButtonFormField<num>(
                                                                    value: _selectedTaux,
                                                                    items: [
                                                                      DropdownMenuItem<num>(
                                                                        child: Text('500'),
                                                                        value: 500,
                                                                      ),
                                                                      DropdownMenuItem<num>(
                                                                        child: Text('900'),
                                                                        value: 900,
                                                                      ),
                                                                    ],
                                                                    onChanged: (value) {
                                                                      setState(() {
                                                                        _selectedTaux = value!;
                                                                      });
                                                                    },
                                                                    decoration: InputDecoration(
                                                                      filled: true,
                                                                      fillColor: Colors.white,
                                                                      hintText: "taux",
                                                                      border: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              child: Text("ANNULER"),
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: Text(
                                                                "MISE À JOUR",
                                                                style: TextStyle(color: Colors.blue),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                                _taux.text = _selectedTaux.toString();

                                                                fetchUser();
                                                                // AddUser(_name.text, _desc.text);
                                                                print(items![index].id!);
                                                                UpdateCateg(items![index].id!, _name.text, _desc.text, _selectedTaux,);
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(content: Text('Le Type est mis à jour avec succès.')),
                                                                );

                                                                setState(() {
                                                                  fetchUser();
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Icon(Icons.edit, color: Colors.green),
                                                  style: TextButton.styleFrom(
                                                    primary: Colors.white,
                                                    elevation: 0,
                                                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 35,
                                                child: TextButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),elevation: 1,
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
                                                                DeleteUser(snapshot.data![index].id);
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(content: Text('Le User a été Supprimer avec succès.')),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },

                                                  child: Icon(Icons.delete, color: Colors.red),
                                                  style: TextButton.styleFrom(
                                                    primary: Colors.white,
                                                    elevation: 0,
                                                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
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
        floatingActionButton: FloatingActionButton.extended(
          // heroTag: 'uniqueTag',
          tooltip: 'Ajouter un Utilisateur',
          backgroundColor: Colors.white,
          label: Row(
            children: [Icon(Icons.add,color: Colors.black,)],
          ),
          // onPressed: () => _displayTextInputDialog(context),
          onPressed: () {},

        ),


      ),
      // bottomNavigationBar: BottomNav(),

    );
  }


  Future<void> _displayTextInputDialog(BuildContext context) async {
    // TextEditingController _name = TextEditingController();
    // TextEditingController _description = TextEditingController();
    // TextEditingController _prix = TextEditingController();
    // num _selectedTaux = 500;


    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Ajouter un Utilisateur'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _name,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "name",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    ),
                    TextField(
                      controller: _desc,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "description",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    ),
                    DropdownButtonFormField<num>(
                      value: _selectedTaux,
                      items: [
                        DropdownMenuItem<num>(
                          child: Text('500'),
                          value: 500,
                        ),
                        DropdownMenuItem<num>(
                          child: Text('900'),
                          value: 900,
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTaux = value!;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "taux",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),


                    ElevatedButton(onPressed: (){
                      Navigator.of(context).pop();
                      fetchUser();
                      _taux.text = _selectedTaux.toString();
                      AddUser(_name.text,_desc.text,num.parse(_taux.text));
                      // AddUser(_name.text, _desc.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Le User a été ajouter avec succès.')),
                      );
                      // setState(() {
                      //   fetchUser();
                      // });
                    }, child: Text("Ajouter"),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0C2FDA),
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


  void AddUser (String name,String description,[num? prix]) async {

    // Check if the prix parameter is provided, otherwise use the default value of 100
    if (prix == null) {
      prix = 100;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/categorie/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "name":name,
        "description":description ,
        "prix": prix ,
      }),
    );
    if (response.statusCode == 200) {
      print('User ajouter avec succes');
    } else {
      print("SomeThing Went Wrong");
    }
  }

  void UpdateCateg( id,String name,String description,[num? prix]) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.patch(
      Uri.parse("http://192.168.43.73:5000/categorie" + "/$id"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "name":name,
        "description":description ,
        "prix": prix ,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      // Fetch the updated list of Matieres and update the UI
      fetchUser().then((data) {
        setState(() {
          filteredItems = data;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des Matieres: $error');
      });
    } else {
      return Future.error('Server Error');
      print(
          '4e 5asser sa77bi mad5al======================================');
    }
  }
}

class User {
  late final String id;
  final String name;
  final String prenom;
  final num mobile;
  final String email;
  final String role;
   late final bool? isActive;


  User({
    required this.id,
    required this.name,
    required this.prenom,
    required this.email,
    required this.mobile,
    required this.role,
     this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      mobile: json['mobile'],
      role: json['role'],
      isActive: json['active'],
    );
  }
}
Future<List<User>> fetchUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/user'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  print(response.statusCode);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    List<dynamic> UsersData = jsonResponse['users'];

    // print(UsersData);
    List<User> Users = UsersData.map((item) {
      return User.fromJson(item);
    }).toList();

    print(Users);
    return Users;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load User');
  }
}

Future<void> ActiveUser( id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  final url = 'http://192.168.43.73:5000/user/'  + '/$id'+'/active';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };


  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 201) {
      // Course creation was successful
      print("OK!");
      // You can handle the response data as needed
    } else {
      // Course creation failed
      print("Failed to create course. Status code: ${response.statusCode}");
      print("Error Message: ${response.body}");
    }
  } catch (error) {
    print("Error: $error");
  }
}




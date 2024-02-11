import 'dart:typed_data';


import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart' as Excel;

import 'dart:io';
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
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  bool showFloat = false;
  void DeleteUser(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/user' +"/$id"),
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
      Navigator.pop(context);
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
  TextEditingController _prenom = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _pass = TextEditingController();
  TextEditingController _confpass = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _banque = TextEditingController();
  TextEditingController _role = TextEditingController();
  TextEditingController _compte = TextEditingController();


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
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      }, child: Icon(Icons.arrow_back_ios_new_outlined,size: 20,color: Colors.black,),

                    ),
                  ),
                  SizedBox(width: 50,),
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


                          //abou
                          return
                            Container(
                              height: 500,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Theme(
                                  data: ThemeData(
                                    // Modifiez les couleurs de DataTable ici
                                    dataTableTheme: DataTableThemeData(
                                      dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white), // Couleur des lignes de données
                                      // headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black), // Couleur de la ligne d'en-tête

                                    ),
                                  ),
                                  child: PaginatedDataTable(
                                    columnSpacing: 10,dataRowHeight: 55,
                                    rowsPerPage: _rowsPerPage,
                                    showFirstLastButtons: _rowsPerPage >= 10 ? true: false,
                                    availableRowsPerPage: [5, 7,9,10, 20],
                                    onRowsPerPageChanged: (value) {
                                      setState(() {
                                        _rowsPerPage = value ?? _rowsPerPage;
                                      });
                                    },
                                    columns: [
                                      DataColumn(label: Text('Active')),
                                      DataColumn(label: Text('Nom')),
                                      DataColumn(label: Text('Email')),
                                      DataColumn(label: Text('Role')),
                                      DataColumn(label: Text('Banque')),
                                      // DataColumn(label: Text('Action')),
                                    ],
                                    source: YourDataSource(filteredItems ?? items!,),
                                  ),
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
        floatingActionButton:
        showFloat?
        Container(
          width: 300,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(50)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
              ),
            ],
          ),

          margin: EdgeInsets.only(left: 80,right: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(width: 18,),
              TextButton(
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.black,),
                    Text('Ajouter',style: TextStyle(color: Colors.black),),
                  ],
                ),
                onPressed: () => _displayTextInputDialog(context),

              ),
              TextButton(
                child: Row(
                  children: [
                    Icon(Icons.cloud_download_outlined, color: Colors.black,),
                    Text('Importer',style: TextStyle(color: Colors.black),),
                  ],
                ),
                onPressed: () => _importData(context),

              ),
              TextButton(
                child: Icon(Icons.close_outlined, color: Colors.black,),
                onPressed: () {
                  setState(() {
                    showFloat = false;
                  });
                },

              ),


            ],
          ),
        )
        :Container(
          width: 60,
          decoration: BoxDecoration(
            color: Colors.lightGreen,
            borderRadius: BorderRadius.all(Radius.circular(50)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
              ),
            ],
          ),

          // margin: EdgeInsets.only(left: 90,right: 60),
          child:
          TextButton(
            child: Icon(Icons.add, color: Colors.white,),
            onPressed: () {
              setState(() {
                showFloat = true;
              });
            },

          ),

        ),


      ),
      // bottomNavigationBar: BottomNav(),

    );
  }


  Future<void> _importData(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.first.path!);

      ByteData data = await file.readAsBytes().then((bytes) {
        return ByteData.sublistView(Uint8List.fromList(bytes));
      });
      List<int> bytes = data.buffer.asUint8List();
      var excel = Excel.Excel.decodeBytes(bytes);


      for (var table in excel.tables.keys) {
        print(table); // Nom de la feuille
        print(excel.tables[table]!.maxCols);
        print("hmm: ${excel.tables[table]!.maxCols}");
        print(excel.tables[table]!.rows[0]); // Lecture de l'en-tête

        // Commencer à traiter à partir de la deuxième ligne (index 1)
        for (var i = 1; i < 100; i++) {
          var row = excel.tables[table]!.rows[i];

          print('taille: ${row.length}');
          // if (row.length >= excel.tables[table]!.maxCols) {  // Vérifiez si la ligne a au moins le nombre maximum de colonnes
          String nom = row[0]?.value?.toString() ?? "";
          String prenom = row[1]?.value?.toString() ?? "";
          String mobile = row[2]?.value?.toString() ?? "";

          String email = row[3]?.value?.toString() ?? "";
          String pass = row[4]?.value?.toString() ?? "";
          String banque = row[5]?.value?.toString() ?? "";

          String role = row[6]?.value?.toString() ?? "";
          String compte = row[7]?.value?.toString() ?? "";

          // Faites quelque chose avec les données, par exemple, ajoutez-les à votre liste de professeurs
          // print('Code: $nom, Nom $niveau,Desc $desc,');
          AddUser(nom,prenom,int.parse(mobile),email,pass,pass,banque,role,int.parse(compte));
          // } else {
          //   print('La ligne $i n\'a pas suffisamment d\'éléments.');
          // }
        }


      }
      print("Hello ${excel.tables.values.first}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Données importées avec succès depuis le fichier Excel.')),
      );
    }
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {


    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              insetPadding: EdgeInsets.only(top: 60,),
              surfaceTintColor: Color(0xB0AFAFA3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              title: Text('Ajouter un Utilisateur'),
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextField(
                        controller: _name,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            filled: true,
                            // fillColor: Color(0xA3B0AF1),
                            fillColor: Colors.white,
                            hintText: "Nom",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,gapPadding: 1,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)))),

                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _prenom,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Prenom",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,gapPadding: 1,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _mobile,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Mobile",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,gapPadding: 1,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "email",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,gapPadding: 1,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                      ),


                      SizedBox(height: 10),
                      TextField(
                        controller: _pass,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Mot de Passe",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,gapPadding: 1,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _confpass,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Confirmation",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,gapPadding: 1,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _banque,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Banque",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,gapPadding: 1,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                      ),

                      SizedBox(height: 10),
                      TextField(
                        controller: _role,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Role",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,gapPadding: 1,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _compte,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Compte",
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,gapPadding: 1,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                      ),


                      SizedBox(height: 20),
                      ElevatedButton(onPressed: (){
                        Navigator.of(context).pop();
                        fetchUser();
                        AddUser(_name.text,_prenom.text,int.parse(_mobile.text),_email.text,_pass.text,_confpass.text,_banque.text,_role.text,int.parse(_compte.text));
                        // AddUser(_name.text, _desc.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Le User a été ajouter avec succès.')),
                        );
                        // setState(() {
                        //   fetchUser();
                        // });
                      }, child: Text("Ajouter"),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff0fb2ea),
                          foregroundColor: Colors.white,
                          elevation: 10,
                          minimumSize:  Size( MediaQuery.of(context).size.width , MediaQuery.of(context).size.width/7),
                          // padding: EdgeInsets.only(left: MediaQuery.of(context).size.width /5,
                          //     right: MediaQuery.of(context).size.width /5,bottom: 20,top: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      )
                    ],
                  ),
                ),
              )
          );
        });
  }


  void AddUser (String name,String prenom,int mobile,String email,String pass,String confPass,String banque,String role,int compte) async {
    final Map<String, dynamic> data = {
      "nom":name,
      "prenom":prenom ,
      "mobile": mobile ,
      "email":email,
      "password":pass ,
      "passwordConfirm": confPass ,
      "banque":banque ,
      "role": role ,
      "accountNumero":compte,
    };

    // Check if the prix parameter is provided, otherwise use the default value of 100
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    // print(token);
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/user/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('User ajouter avec succes');
      setState(() {
        Navigator.pop(context);
      });
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

class YourDataSource extends DataTableSource {
  List<User> _items;
  // Function(int) onTapCallback; // La fonction prendra un index comme paramètre

  YourDataSource(this._items,);

  @override
  DataRow? getRow(int index) {

    final item = _items[index];
    return DataRow(cells: [
      DataCell(
          CupertinoSwitch(
            activeColor: Colors.black26,
            // thumbColor: Colors.blueAccent,
            value: item.isActive!,
            onChanged: (value) async {
              // Continue with the rest of your onChanged logic if the types string is in the expected format
              // setState(() {
                // filteredItems![index].isActive = value;
                // fetchUser();
              // });

              // Navigator.of(context).pop();

              // fetchUser().then((data) {
              //   setState(() {
              //     filteredItems = data; // Assigner la liste renvoyée par Useresseur à items
              //   });});

              ActiveUser(
                item.id,
              );
            },
          )

      ),
      DataCell(Container(width: 70,
          child: Text('${item.name } ${item.prenom}',style: TextStyle(
            color: Colors.black,
          ),))),
      DataCell(Container(width: 150,
          child: Text('${item.email}',style: TextStyle(
            color: Colors.black,
          ),)),),
      DataCell(Container(width: 80, child: Text('${item.role}',style: TextStyle(
            color: Colors.black,
          ),)),),
      DataCell(Container(width: 68,
          child: Text('${item.banque}',style: TextStyle(
            color: Colors.black,
          ),)),),



    ]);
  }

  @override
  int get rowCount => _items.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}


class User {
  late final String id;
  final String name;
  final String prenom;
  final num? mobile;
  final String email;
  final String role;
  final String banque;
   late final bool? isActive;


  User({
    required this.id,
    required this.name,
    required this.prenom,
    required this.email,
     this.mobile,
    required this.role,
    required this.banque,
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
      banque: json['banque'],
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

    print(UsersData);
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




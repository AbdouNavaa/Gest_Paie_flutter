import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Dashboard.dart';
import 'main.dart';





class Categories extends StatefulWidget {
  Categories({Key ? key}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {

  Future<List<Category>>? futureCategory;

  List<Category>? filteredItems;

  void DeleteCategory(id) async{
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
      fetchCategory();
    }

  }


  @override
  void initState() {
    super.initState();
    fetchCategory().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Categoryesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
  }
  TextEditingController _searchController = TextEditingController();

  TextEditingController _name = TextEditingController();
  // TextEditingController _code = TextEditingController();
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
                  List<Category> Categories = await fetchCategory();

                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les Categoryesseurs dont le name ou le préname contient la valeur saisie
                    filteredItems = Categories!.where((Category) =>
                    Category.name!.toLowerCase().contains(value.toLowerCase()) ||
                        Category.description!.toLowerCase().contains(value.toLowerCase())).toList();
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
                    child: Center(child: Text(' ${filteredItems?.length} Categories',style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)))),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: FutureBuilder<List<Category>>(
                    future: fetchCategory(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<Category>? items = snapshot.data;

                          return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                // margin: EdgeInsets.only(left: 10),
                                child:
                                DataTable(
                                  showCheckboxColumn: true,
                                  showBottomBorder: true,
                                  headingRowHeight: 50,
                                  columnSpacing: 15,
                                  dataRowHeight: 50,
                                  // border: TableBorder.all(color: Colors.black12, width: 2),
                                  headingTextStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // Set header text color
                                  ),
                                  // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFF0C2FDA)), // Set row background color
                                  columns: [
                                    // DataColumn(label: Text('Code')),
                                    DataColumn(label: Text('Nom')),
                                    DataColumn(label: Text('Taux')),
                                    DataColumn(label: Text('Action')),
                                    // DataColumn(label: Text('Descrition')),
                                  ],
                                  rows: [
                                    for (var categ in filteredItems!)
                                        DataRow(
                                            cells: [
                                              // DataCell(Container(child: Text('${categ.code}')),

                                                // onTap:() => _showcategDetails(context, categ)
                                              // ),
                                              DataCell(Text('${categ.name}'),

                                                // onTap:() => _showcategDetails(context, categ)
                                              ),
                                              DataCell(Text('${categ.prix}'),),
                                              DataCell(
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 35,
                                                      child: TextButton(

                                                        onPressed: (){
                                                          _name.text = categ.name!;
                                                          // _code.text = categ.code!;
                                                          _desc.text = categ.description!;
                                                          _selectedTaux = categ.prix!;
                                                          showModalBottomSheet(
                                                              context: context,
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                                                                  topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
                                                              isScrollControlled: true, // Rendre le contenu déroulable

                                                              builder: (BuildContext context){
                                                                return SingleChildScrollView(
                                                                  child: Container(
                                                                    height: 600,
                                                                    padding: const EdgeInsets.all(25.0),
                                                                    child: Column(
                                                                      // mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        Row(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          // mainAxisAlignment: MainAxisAlignment.start,
                                                                          children: [
                                                                            Text("Mise à jour de la tâche", style: TextStyle(fontSize: 25),),
                                                                            Spacer(),
                                                                            InkWell(
                                                                              child: Icon(Icons.close),
                                                                              onTap: (){
                                                                                Navigator.pop(context);
                                                                              },
                                                                            )
                                                                          ],
                                                                        ),
                                                                        //hmmm
                                                                        SizedBox(height: 40),
                                                                        TextField(
                                                                          controller: _name,
                                                                          keyboardType: TextInputType.text,
                                                                          decoration: InputDecoration(
                                                                              filled: true,
                                                                              fillColor: Colors.white,
                                                                              border: OutlineInputBorder(
                                                                                  borderSide: BorderSide.none,
                                                                                  borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                                                        ),

                                                                        SizedBox(height: 10),
                                                                        TextFormField(
                                                                          controller: _desc,
                                                                          keyboardType: TextInputType.text,
                                                                          maxLines: 3,
                                                                          decoration: InputDecoration(
                                                                              filled: true,

                                                                              fillColor: Colors.white,
                                                                              hintText: "description",
                                                                              border: OutlineInputBorder(
                                                                                  borderSide: BorderSide.none,
                                                                                  borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                                                        ),

                                                                        SizedBox(height: 10),
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
                                                                            border: OutlineInputBorder(
                                                                              borderSide: BorderSide.none,
                                                                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 10),




                                                                        ElevatedButton(
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop();
                                                                            _taux.text = _selectedTaux.toString();

                                                                            fetchCategory();
                                                                            // AddCategory(_name.text, _desc.text);
                                                                            print(categ.id!);
                                                                            UpdateCateg(categ.id!, _name.text,_desc.text, _selectedTaux,);
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(content: Text('Le Type est mis à jour avec succès.')),
                                                                            );

                                                                            setState(() {
                                                                              fetchCategory();
                                                                            });
                                                                          },
                                                                          child: Text("Modifier"),

                                                                          style: ElevatedButton.styleFrom(
                                                                            backgroundColor: Color(0xFF0C2FDA),
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
                                                                );

                                                              }


                                                          );
                                                        }, // Disable button functionality
                                                        child: Icon(Icons.edit, color: Colors.green,),

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
                                                                      DeleteCategory(categ.id);
                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                        SnackBar(content: Text('Le Category a été Supprimer avec succès.')),
                                                                      );
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }, // Disable button functionality
                                                        child: Icon(Icons.delete_outline, color: Colors.red,),

                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ),
                                              // DataCell(Container(width: 105,
                                              //     child: Text('${categ.description}',)),),


                                            ]),
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
          tooltip: 'Ajouter une categorie',
          backgroundColor: Colors.white,
          label: Row(
            children: [Icon(Icons.add,color: Colors.black,)],
          ),
          onPressed: () => _displayTextInputDialog(context),

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


    return showModalBottomSheet(
        context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
          topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
      isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return SingleChildScrollView(
            child: Container(
              height: 600,
              padding: const EdgeInsets.all(25.0),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Ajouter une Categorie", style: TextStyle(fontSize: 25),),
                      Spacer(),
                      InkWell(
                        child: Icon(Icons.close),
                        onTap: (){
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                  //hmmm
                  SizedBox(height: 40),
                  TextField(
                    controller: _name,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Nom",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),

                  SizedBox(height: 10),
                  TextFormField(
                    controller: _desc,
                    keyboardType: TextInputType.text,
                    maxLines: 3,
                    decoration: InputDecoration(
                        filled: true,

                        fillColor: Colors.white,
                        hintText: "description",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),

                  SizedBox(height: 10),
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
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),




                  ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                      fetchCategory();
                      _taux.text = _selectedTaux.toString();
                      AddCategory(_name.text,_desc.text,num.parse(_taux.text));
                      // AddCategory(_name.text, _desc.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Le Category a été ajouter avec succès.')),
                      );
                      // setState(() {
                      //   fetchCategory();
                      // });
                    },
                    child: Text("Ajouter"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0C2FDA),
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
          );

        }


    );
  }


  void AddCategory (String name,String description,[num? prix]) async {

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
        // "code":code ,
        "description":description ,
        "prix": prix ,
      }),
    );
    if (response.statusCode == 200) {
      print('Category ajouter avec succes');
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
        // "code":code ,
        "description":description ,
        "prix": prix ,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      // Fetch the updated list of Matieres and update the UI
      fetchCategory().then((data) {
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

class Category {
  late final String id;
  final String name;
  // final String? code;
  final String? description;
  final num? prix;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    // this.code,
    this.description,
    this.prix,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      // code: json['code'],
      description: json['description'],
      prix: json['prix'] ?? 100, // Provide a default value of 100 if not provided
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
Future<List<Category>> fetchCategory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/categorie/'),
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
    List<dynamic> categoriesData = jsonResponse['categories'];

    // print(categoriesData);
    List<Category> categories = categoriesData.map((item) {
      return Category.fromJson(item);
    }).toList();

    print(categories);
    return categories;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Category');
  }
}





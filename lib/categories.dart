import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart' as Excel;

import 'dart:io';





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

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/categorie/$id' ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchCategory().then((data) {
        setState(() {
          filteredItems = data;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des Matieres: $error');
      });

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
                  Text("Liste de Categories",style: TextStyle(fontSize: 25),)
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
              child: TextField(style: TextStyle(
                color: Colors.black,
              ),
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

            Expanded(
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DataTable(
                      showCheckboxColumn: true,
                      showBottomBorder: true,
                      headingRowHeight: 50,
                      columnSpacing: 8,
                      dataRowHeight: 50,
                      columns: [
                        DataColumn(label: Text('Code')),
                        DataColumn(label: Text('Nom')),
                        DataColumn(label: Text('Taux')),
                        DataColumn(label: Text('Nb Mat')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: [
                        for (var index = 0; index < (filteredItems?.length ?? 0); index++)
                          // for (var categ in filteredItems!)
                          DataRow(
                              cells: [
                                DataCell(Text('${filteredItems?[index].code}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                // DataCell(Container(child: Text('${categ.code}')),
                                //
                                //   // onTap:() => _showcategDetails(context, categ)
                                // ),
                                DataCell(Container(width: 100,
                                  child: Text('${filteredItems?[index].name}',style: TextStyle(
                                    color: Colors.black,
                                  ),),
                                )),
                                DataCell(Text('${filteredItems?[index].prix}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Text('${filteredItems?[index].nb_matieres}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(
                                  Row(
                                    children: [
                                      Container(
                                        width: 35,
                                        child: TextButton(

                                          onPressed: (){
                                            _name.text = filteredItems![index].name!;
                                            // _code.text = categ.code!;
                                            _desc.text = filteredItems![index].description!;
                                            _selectedTaux = filteredItems![index].prix!;
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
                                                              Text("Modifier une categorie", style: TextStyle(fontSize: 25),),
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
                                                                // fillColor: Colors.white,
                                                                border: OutlineInputBorder(
                                                                    borderSide: BorderSide.none,gapPadding: 1,
                                                                    borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                                          ),

                                                          SizedBox(height: 10),
                                                          TextFormField(
                                                            controller: _desc,
                                                            keyboardType: TextInputType.text,
                                                            maxLines: 3,
                                                            decoration: InputDecoration(
                                                                filled: true,

                                                                // fillColor: Colors.white,
                                                                hintText: "description",
                                                                border: OutlineInputBorder(
                                                                    borderSide: BorderSide.none,gapPadding: 1,
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
                                                              // fillColor: Colors.white,
                                                              border: OutlineInputBorder(
                                                                borderSide: BorderSide.none,gapPadding: 1,
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
                                                              print(filteredItems?[index].id!);
                                                              UpdateCateg(filteredItems?[index].id!, _name.text,_desc.text, _selectedTaux,);
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(content: Text('Le Type est mis à jour avec succès.')),
                                                              );

                                                              setState(() {
                                                                fetchCategory();
                                                              });
                                                            },
                                                            child: Text("Modifier"),

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
                                                  );

                                                }
                                            );
                                          }, // Disable button functionality
                                          child: Icon(Icons.mode_edit_outline_outlined, color: Colors.black,),

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

                                                        fetchCategory();
                                                        DeleteCategory(filteredItems?[index]!.id);
                                                        print(filteredItems?[index].id!);
                                                        // Navigator.of(context).pop();
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Le Category a été Supprimer avec succès.')),
                                                        );
                                                        setState(() {
                                                          fetchCategory();
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }, // Disable button functionality
                                          child: Icon(Icons.delete_outline, color: Colors.black,),

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
          onPressed: () => _importData(context),

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
              height: 450,
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
                        // fillColor: Colors.white,
                        hintText: "Nom",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),

                  SizedBox(height: 10),
                  TextFormField(
                    controller: _desc,
                    keyboardType: TextInputType.text,
                    maxLines: 3,
                    decoration: InputDecoration(
                        filled: true,

                        // fillColor: Colors.white,
                        hintText: "description",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
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
                      // fillColor: Colors.white,
                      hintText: "taux",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,gapPadding: 1,
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
                      setState(() {
                        fetchCategory();
                      });
                    },
                    child: Text("Ajouter"),

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
          );

        }


    );
  }


  Future<void> _importData(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.first.path!);

      // String directoryPath = (await getApplicationDocumentsDirectory()).path;
      // String filePath = '$directoryPath/${basename(file.path)}';
      // await file.copy(filePath);

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
          String desc = row[1]?.value?.toString() ?? "";
          String prix = row[2]?.value?.toString() ?? "0";

          // Faites quelque chose avec les données, par exemple, ajoutez-les à votre liste de professeurs
          print('les infos: $nom, Desc $desc,Prix $desc,');
          AddCategory(nom,desc, num.parse(prix));
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
      fetchCategory().then((data) {
        setState(() {
          filteredItems = data;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des Matieres: $error');
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
  final num? nb_matieres;
  final String? code;
  final num? prix;

  Category({
    required this.id,
    required this.name,
    // this.code,
    this.description,
    this.nb_matieres,
    this.code,
    this.prix,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      // code: json['code'],
      description: json['description'] ?? '',
      nb_matieres: json['nb_matieres'],
      code: json['code'],
      prix: json['prix'] , // Provide a default value of 100 if not provided
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
  print("Categ:${response.statusCode}");
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    List<dynamic> categoriesData = jsonResponse['categories'];

    // print(categoriesData);
    List<Category> categories = categoriesData.map((item) {
      return Category.fromJson(item);
    }).toList();

    // print(categories);
    return categories;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Category');
  }
}





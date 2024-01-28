import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart' as Excel;

import 'dart:io';
import 'categories.dart';





class Matieres extends StatefulWidget {
  Matieres({Key ? key}) : super(key: key);

  @override
  _MatieresState createState() => _MatieresState();
}

class _MatieresState extends State<Matieres> {

  Future<List<Matiere>>? futureMatiere;
  // Categories myNewClass = Categories();


  List<Matiere>? filteredItems;
  String generateMatiereCode(String? semestre, String categoryCode, int newCodeNumber) {
    final semesterCode = semestre?.substring(1); // Get the second character of the semestre (e.g., "1" from "S1")
    // final autre = 1; // Get the second character of the semestre (e.g., "1" from "S1")
    print( 'my code: $newCodeNumber');
    return '$categoryCode$semesterCode$newCodeNumber';
  }
  bool showCategoryDropdown = false;
  String getCategoryNameFromId(String categoryId, List<Category> categories) {
    final category = categories.firstWhere((c) => c.id == categoryId, orElse: () => Category(id: '', name: '')); // Replace 'Category' with your actual Category class
    return category.name;
  }
  String getCategoryId(String code) {
    final category = categs.firstWhere((c) => c.code == code, orElse: () => Category(id: '', name: '')); // Replace 'Category' with your actual Category class
    return category.id!;
  }


  void DeleteMatiere(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/matiere/$id' ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchMatiere().then((data) {
        setState(() {
          filteredItems = data;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des Matieres: $error');
      });

    }

  }
  void DeleteAll() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/matiere/' ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchMatiere().then((data) {
        setState(() {
          filteredItems = data!;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des Matieres: $error');
      });

    }

  }

  Future<void> UpdateMatiere(String id, String name, String categorieId) async {
    final Map<String, dynamic> data = {
      "name": name,

      // "description": description,
      "categorie": categorieId,
      // "code": newCode,
    };

    final response = await http.patch(
      Uri.parse('http://192.168.43.73:5000/matiere/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      // Update successful
      print('Matiere mise à jour avec succès');
      // Fetch the updated list of Matieres and update the UI
      fetchMatiere().then((data) {
        setState(() {
          filteredItems = data;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des Matieres: $error');
      });
    } else {
      print('Erreur lors de la mise à jour de la Matiere. Code d\'état: ${response.statusCode}');
    }
  }

  void AddMatiere(String name,String description, String? categorieId) async {
    final Map<String, dynamic> data = {
      "name": name,

      "description": description,
      "categorie": categorieId,
    };

    if (categorieId != null) {
      data["categorie"] = categorieId;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/matiere/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      print('Matiere ajoutée avec succès');

      fetchMatiere().then((data) {
        setState(() {
          filteredItems = data;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des Matieres: $error');
      });
    } else {
      print("Quelque chose s'est mal passé");
    }
  }
  String getCategoryCodeFromName(String categoryName) {
    List<String> words = categoryName.split(' ');

    if (words.length == 1) {
      // Si la catégorie a un seul mot, prenez les 3 premières lettres
      return categoryName.substring(0, 3).toUpperCase();
    } else if (words.length >= 2) {
      // Si la catégorie a deux mots ou plus, prenez les premières lettres de chaque mot
      String code = '';
      for (String word in words) {
        code += word[0].toUpperCase();
      }
      return code;
    } else {
      // Gestion d'erreur ou valeur par défaut si nécessaire
      return 'N/A';
    }
  }

  List<Category> categs = [];
  @override
  void initState() {
    super.initState();
    fetchMatiere().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Matiereesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchCategory().then((data) {
      setState(() {
        categs = data; // Assigner la liste renvoyée par Matiereesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

  }
  TextEditingController _searchController = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _semestre = TextEditingController();
  TextEditingController _desc = TextEditingController();
  late String _categ ;
  late String _categcode ;
  Category? selectedCateg; // initialiser le type sélectionné à null
  String _selectedSemestre = 'S1';
  // String? selectedTypes ;
  String? selectedType;


  List<Map<String, dynamic>> availableTypes = [
    {"name": "S1"},
    {"name": "S2",},
    {"name": "S3",},
    {"name": "S4",},
    {"name": "MS1",},
    // Add more available types here as needed
  ];



  @override
  Widget build(BuildContext context) {

    // Sort the items list based on the semestre
    // filteredItems?.sort((a, b) {
    //   final semestreOrder = {'S1': 1,'MS1': 2, 'S2': 3, 'S3': 4, 'S4': 5};
    //   // final semestreComparison = semestreOrder[a.semestre]!.compareTo(semestreOrder[b.semestre]!);
    //
    //   if (semestreComparison != 0) {
    //     return semestreComparison; // Sort by semestre if they are different
    //   } else {
    //     // Sort by code within the same semestre
    //     return a.code!.compareTo(b.code!);
    //   }
    // });


// Build the DataTable with sorted items

    return Scaffold(
      body: Scaffold(
        // appBar: AppBar(
        //   title: Center(child: Text(' ${filteredItems?.length} Matiere')),
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
                  Text("Liste de Matieres",style: TextStyle(fontSize: 25),)
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
                  List<Matiere> Matieres = await fetchMatiere();

                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les Matiereesseurs dont le name ou le préname contient la valeur saisie
                    filteredItems = Matieres!.where((Matiere) =>
                    Matiere.name!.toLowerCase().contains(value.toLowerCase())
                        // Matiere.description!.toLowerCase().contains(value.toLowerCase())
                    ).toList();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Rechercher ',
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
                  child: FutureBuilder<List<Matiere>>(
                    future: fetchMatiere(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<Matiere>? items = snapshot.data;

                          return  SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
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
                                columnSpacing: 8,
                                dataRowHeight: 50,
                                // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xff0fb2ea)), // Set row background color
                                columns: [
                                  // DataColumn(label: Text('Semestre')),
                                  DataColumn(label: Text('Code EM')),
                                  DataColumn(label: Text('Element de Module')),
                                  // DataColumn(label: Text('Catégorie')),
                                  DataColumn(label: Text('Action')),
                                ],
                                rows: [
                                  for (var index = 0; index < (filteredItems?.length ?? 0); index++)
                                    DataRow(
                                      cells: [
                                        // DataCell(Text('${filteredItems?[index].semestre}')),
                                        DataCell(Text('${filteredItems?[index].code}',style: TextStyle(
                            color: Colors.black,
                          ),)),
                                        // DataCell(Text(generateMatiereCode(
                                        //   filteredItems![index].categoriecode, // Replace with actual property name
                                        //   filteredItems![index]!.semestre!,
                                        //   index, // Use index as matiereCount
                                        // ))),
                                        // DataCell(Text('${filteredItems?[index].description}')),
                                        DataCell(Container(width: 120,
                                            child: Text('${filteredItems?[index].name}',style: TextStyle(
                      color: Colors.black,
                      ),)),),

                                        DataCell(
                                          Row(
                                            children: [
                                              Container(
                                                width: 30,
                                                child: TextButton(
                                                  onPressed: () =>_showCourseDetails(context, filteredItems![index],filteredItems![index].id),// Disable button functionality

                                                  child: Icon(Icons.more_horiz, color: Colors.black54),
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
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 18,),
            FloatingActionButton.extended(
              // heroTag: 'uniqueTag',
              tooltip: 'Supprimer Tous',backgroundColor: Colors.white,
              label: Row(
                children: [Icon(Icons.delete_outlined,color: Colors.black,)],
              ),
              // onPressed: () => DeleteAll(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),elevation: 1,
                      title: Text("Alert"),
                      content: Text(
                          "Êtes-vous sûr de vouloir supprimer tous les éléments ?"),
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

                            DeleteAll();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Les Categories sont Supprimer avec succès.')),
                            );

                            setState(() {
                              Navigator.of(context).pop();
                              fetchMatiere();
                            });

                          },
                        ),
                      ],
                    );
                  },
                );
              },

            ),
            SizedBox(width: 210,),
            FloatingActionButton.extended(
              // heroTag: 'uniqueTag',
              tooltip: 'Ajouter une matiere',backgroundColor: Colors.white,
              label: Row(
                children: [Icon(Icons.add,color: Colors.black,)],
              ),
              onPressed: () => _importData(context),

            ),
          ],
        ),

      ),
      // bottomNavigationBar: BottomNav(),

    );
  }


  String separateCharactersAndNumbers(String input) {
    // Initialiser une instance de StringBuffer pour stocker le résultat
    StringBuffer result = StringBuffer();

    // Parcourir chaque caractère de la chaîne d'entrée
    for (int i = 0; i < input.length; i++) {
      String currentChar = input[i];

      // Vérifier si le caractère est une lettre
      if (currentChar.contains(RegExp(r'[A-Za-z]'))) {
        // Si c'est une lettre, l'ajouter au résultat
        result.write(currentChar);
      }
    }

    // Retourner la chaîne résultante
    return result.toString();
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
          String code = row[0]?.value?.toString() ?? "";
          String nom = row[1]?.value?.toString() ?? "";
          String desc = row[2]?.value?.toString() ?? "";

          // Faites quelque chose avec les données, par exemple, ajoutez-les à votre liste de professeurs
          print('Code: $code, Nom $nom,Desc $desc,');
          AddMatiere(nom,desc, getCategoryId(separateCharactersAndNumbers(code)));
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
    TextEditingController _name = TextEditingController();
    TextEditingController _description = TextEditingController();

    Category? selectedCateg; // initialiser le type sélectionné à null

    List<Category> types =await fetchCategory();


          return showModalBottomSheet(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
              isScrollControlled: true, // Rendre le contenu déroulable


              context: context,
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
                            Text("Ajouter une Matiere", style: TextStyle(fontSize: 25),),
                            Spacer(),
                            InkWell(
                              child: Icon(Icons.close),
                              onTap: (){
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
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
                        DropdownButtonFormField<Category>(
                          value: selectedCateg,
                          items: types.map((type) {
                            return DropdownMenuItem<Category>(
                              value: type,
                              child: Text(type.name ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCateg = value;
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            // fillColor: Colors.white,
                            hintText: "Categorie",
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,gapPadding: 1,
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                        ),
                        // String? selectedType; // Variable pour suivre l'élément sélectionné

                        SizedBox(height: 10),
                        TextFormField(
                          controller: _description,
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

                        ElevatedButton(
                          onPressed: (){
                          Navigator.of(context).pop();

                          // fetchMatiere();
                          AddMatiere(_name.text, _description.text,selectedCateg!.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Le Maitiere a été ajouter avec succès.')),

                          );
                          setState(() {
                            fetchMatiere();
                          });
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
                );

            }
          );

  }
  Future<void> _showCourseDetails(BuildContext context, Matiere mat,String MatId) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return Container(
            height: 450,
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Matiere Infos',style: TextStyle(fontSize: 30),),
                SizedBox(height: 50),
                Row(
                  children: [
                    Text('Nom:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                    SizedBox(width: 10,),
                    Text(mat.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Categorie:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${mat.categorie_name}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Code:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${mat.code}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Numero:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${mat.numero}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                  ],
                ),

                SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        List<Category> types = await fetchCategory();
                        List<Matiere> matieres = await fetchMatiere();
                        _name.text = mat.name;
                        // _desc.text = filteredItems![index].description;
                        _categ = mat.categorieId;
                        // selectedCateg = filteredItems![index].categorie;
                        // _selectedSemestre = filteredItems![index].semestre!;
                        List<Category?> selectedCategories = List.generate(matieres.length, (_) => null);

                        showModalBottomSheet(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
                            isScrollControlled: true, // Rendre le contenu déroulable


                            context: context,
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
                                          Text("Modifier une Matiere", style: TextStyle(fontSize: 20),),
                                          Spacer(),
                                          InkWell(
                                            child: Icon(Icons.close),
                                            onTap: (){
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      ),
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
                                      DropdownButtonFormField<Category>(
                                        value: selectedCateg,//getCategoryNameFromId

                                        hint: Text('${mat.code}'),
                                        items: types.map((type) {
                                          return DropdownMenuItem<Category>(
                                            value: type,
                                            child: Text(type.name ?? ''),
                                          );
                                        }).toList(),

                                        onChanged: (value) {
                                          setState(() {
                                            selectedCateg = value;
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
                                      // String? selectedType; // Variable pour suivre l'élément sélectionné


                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();


                                          fetchMatiere();
                                          // Check if you're updating an existing matiere or creating a new one
                                          UpdateMatiere(
                                              mat.id!,
                                              _name.text,
                                              // _desc.text,
                                            selectedCateg!.id!
                                          );


                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Le Type est mis à jour avec succès.')),
                                          );
                                          setState(() {
                                            Navigator.pop(context);
                                            // fetchMatiere();
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
                      },


                      child: Text('Modifier'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.only(left: 20,right: 20),
                        foregroundColor: Colors.lightGreen,
                        backgroundColor: Colors.white,
                        // side: BorderSide(color: Colors.black,),
                        elevation: 3,
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),

                    ),
                    ElevatedButton(
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

                                    fetchMatiere();
                                    DeleteMatiere(mat!.id);
                                    print(mat.id!);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Le Category a été Supprimer avec succès.')),
                                    );

                                    setState(() {
                                      Navigator.of(context).pop();
                                      fetchMatiere();
                                    });

                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }, // Disable button functionality

                      child: Text('Supprimer'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.only(left: 20,right: 20),
                        foregroundColor: Colors.redAccent,
                        backgroundColor: Colors.white,
                        // side: BorderSide(color: Colors.black,),
                        elevation: 3,
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),

                    ),
                  ],
                ),

              ],
            ),
          );
        }


    );
  }
}

Future<List<Matiere>> fetchMatiere() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/matiere/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },);

  print("mat::${response.statusCode}");


  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    List<dynamic> matieresData = jsonResponse['matieres'];

    // print(matieresData);
    List<Matiere> matieres = matieresData.map((item) {
      return Matiere.fromJson(item);
    }).toList();

    // print("Matiere List: $matieres");
    return matieres;
  } else {
    throw Exception('Failed to load Matiere');
  }
}

class Matiere {
  final String id;
  final String name;
  final String? code;
  // final String description;
  final String categorieId;
  final String? categorie_name;
  final num? numero;
  final num? taux;
  // final List<Semestre> semestres; // Ajout de la liste de semestres

  Matiere({
    required this.id,
    required this.name,
    // required this.description,
    required this.categorieId,
     this.categorie_name,
     this.code,
    this.taux,
    this.numero,
  });

  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      id: json['_id'],
      name: json['name'],
      categorieId: json['categorie'],
      categorie_name: json['categorie_name'] ,
      code: json['code'],
      taux: json['taux'],
      numero: json['numero'] ,
    );
  }
}














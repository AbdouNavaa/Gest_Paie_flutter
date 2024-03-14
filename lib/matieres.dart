import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
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
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  // int _rowsPerPage = 5;

  bool sort = false;
  List<Matiere>? filteredItems;
  bool showFloat = false;
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40,),
              Container(
                height: 50,
                child: Row(
                  children: [
                    TextButton(onPressed: (){
                      Navigator.pop(context);
                    }, child: Icon(Icons.arrow_back_ios,color: Colors.black,size: 20,)),
                    // SizedBox(width: 50,),
                    Text("Liste des Matieres",style: TextStyle(fontSize: 20),)
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
                  style: TextStyle(
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
              Container(
                height: 500,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Theme(
                    data: ThemeData(
                      // Modifiez les couleurs de DataTable ici
                      dataTableTheme: DataTableThemeData(
                        dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white), // Couleur des lignes de données
                        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white70), // Couleur de la ligne d'en-tête
                        // headingRowColor: MaterialStateColor.resolveWith((states) => Colors.lightBlueAccent.shade100), // Couleur de la ligne d'en-tête

                      ),
                    ),
                    child: PaginatedDataTable(
                      rowsPerPage: _rowsPerPage,
                      showFirstLastButtons: _rowsPerPage > 10 ? true: false,
                      availableRowsPerPage: [5, 7,9,10, 20],
                      onRowsPerPageChanged: (value) {
                        setState(() {
                          _rowsPerPage = value ?? _rowsPerPage;
                        });
                      },
                      columns: [
                        DataColumn(label: Text('Code EM')),
                        DataColumn(label: Text('Element de Module')),
                        // DataColumn(label: Text('Action')),
                      ],
                      source: YourDataSource(filteredItems ?? [],
                      //   onTapCallback: (index) {
                      //   _showMatDetails(context, filteredItems![index],); // Appel de showMatDetails avec l'objet Matiere correspondant
                      // },
                      ),
                    ),
                  ),
          
                ),
              )
          
          
            ],
          ),
        ),

        floatingActionButton:
        showFloat?
        Container(
          width: 400,
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
              // TextButton(
              //   child: Row(
              //     children: [
              //       Icon(Icons.delete_outlined, color: Colors.black,),
              //       Text('Supprimer Tous',style: TextStyle(color: Colors.black),),
              //     ],
              //   ),
              //   onPressed: () {
              //                         showDialog(
              //                           context: context,
              //                           builder: (BuildContext context) {
              //                             return AlertDialog(
              //                                       surfaceTintColor: Color(0xB0AFAFA3),
              //                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
              //                               title: Text("Confirmer la suppression"),
              //                               content: Text(
              //                                   "Êtes-vous sûr de vouloir supprimer tous les  éléments ?"),
              //                               actions: <Widget>[
              //                                 TextButton(
              //                                   child: Text("ANNULER"),
              //                                   onPressed: () {
              //                                     Navigator.of(context).pop();
              //                                   },
              //                                 ),
              //                                 TextButton(
              //                                   child: Text(
              //                                     "SUPPRIMER",
              //                                     // style: TextStyle(color: Colors.red),
              //                                   ),
              //                                   onPressed: () {
              //                                     Navigator.of(context).pop();
              //
              //                                     fetchMatiere();
              //                                     DeleteAll();
              //
              //                                     ScaffoldMessenger.of(context).showSnackBar(
              //                                       SnackBar(content: Text('Le Category a été Supprimer avec succès.')),
              //                                     );
              //
              //                                     setState(() {
              //                                       Navigator.of(context).pop();
              //                                       fetchMatiere();
              //                                     });
              //
              //                                   },
              //                                 ),
              //                               ],
              //                             );
              //                           },
              //                         );
              //                       }, // Disable button functionality
              // ),

              // SizedBox(width: 210,),
              TextButton(
                child: Row(
                  children: [
                    Icon(Icons.cloud_download_outlined, color: Colors.black,),
                    Text('Importer',style: TextStyle(color: Colors.black),),
                  ],
                ),
                onPressed: () async {
                  String? filePath = await pickExcelFile();
                  if (filePath != null) {
                    uploadFileToBackend(filePath);
                  }
                },

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
            color: Colors.white,
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
            child: Icon(Icons.add, color: Colors.black,),
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



  Future<String?> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      return result.files.single.path;
    } else {
      return null;
    }
  }

  Future<void> uploadFileToBackend(String? filePath) async {
    if (filePath != null) {
      try {
        Uri url = Uri.parse('http://192.168.43.73:5000/matiere/upload');
        var request = http.MultipartRequest('POST', url);
        request.files.add(await http.MultipartFile.fromPath('file', filePath));

        var response = await request.send();
        if (response.statusCode == 200) {
          var jsonResponse = await response.stream.bytesToString();
          print('Réponse du serveur: $jsonResponse');
        } else {
          print('Échec de la requête: ${response.statusCode}');
        }
      } catch (e) {
        print('Erreur lors de la requête: $e');
      }
    } else {
      print('Aucun fichier sélectionné');
    }
  }




  Future<void> _displayTextInputDialog(BuildContext context) async {
    TextEditingController _name = TextEditingController();
    TextEditingController _description = TextEditingController();

    Category? selectedCateg; // initialiser le type sélectionné à null

    List<Category> types =await fetchCategory();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            insetPadding: EdgeInsets.only(top: 190,),
            surfaceTintColor: Color(0xB0AFAFA3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            title: Row(
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

            content: Container(
              height: 450,
              width: MediaQuery.of(context).size.width,
              // padding: const EdgeInsets.all(25.0),
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 40),
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


                    SizedBox(height: 30),
                    DropdownButtonFormField<Category>(
                      dropdownColor: Colors.white,
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
                        // fillColor: Color(0xA3B0AF1),
                        fillColor: Colors.white,
                        hintText: "Categorie",
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    // String? selectedType; // Variable pour suivre l'élément sélectionné

                    SizedBox(height: 30),
                    TextFormField(
                      controller: _description,
                      keyboardType: TextInputType.text,
                      maxLines: 3,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,

                          // fillColor: Color(0xA3B0AF1),
                          hintText: "description",
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,gapPadding: 1,
                              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    ),



                    SizedBox(height: 30),

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
            ),

          );
        });

  }
  Future<void> _showMatDetails(BuildContext context, Matiere mat) {
    return showModalBottomSheet(
        context: context,backgroundColor: Colors.white,
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
                Container(width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                        SizedBox(width: 10,),
                        Text(mat.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                      ],
                    ),
                  ),
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
                // Row(
                //   children: [
                //     Text('Numero:',
                //       style: TextStyle(
                //         fontSize: 20,
                //         fontWeight: FontWeight.w400,
                //         fontStyle: FontStyle.italic,
                //         // color: Colors.lightBlue
                //       ),),
                //
                //     SizedBox(width: 10,),
                //     Text('${mat.numero}',
                //       style: TextStyle(
                //         fontSize: 20,
                //         fontWeight: FontWeight.w400,
                //         fontStyle: FontStyle.italic,
                //         // color: Colors.lightBlue
                //       ),),
                //
                //   ],
                // ),

                SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () async {
                        List<Category> types = await fetchCategory();
                        List<Matiere> matieres = await fetchMatiere();
                        _name.text = mat.name;
                        // _desc.text = filteredItems![index].description;
                        _categ = mat.categorieId;
                        // selectedCateg = filteredItems![index].categorie;
                        // _selectedSemestre = filteredItems![index].semestre!;
                        List<Category?> selectedCategories = List.generate(matieres.length, (_) => null);

                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                insetPadding: EdgeInsets.only(top: 190,),
                                surfaceTintColor: Color(0xB0AFAFA3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    topLeft: Radius.circular(20),
                                  ),
                                ),
                                title:
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

                                content: Container(
                                  height: 450,
                                  width: MediaQuery.of(context).size.width,
                                  // padding: const EdgeInsets.all(25.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      // mainAxisSize: MainAxisSize.min,
                                      children: [

                                        SizedBox(height: 40),
                                        TextField(
                                          controller: _name,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                              filled: true,
                                              // fillColor: Color(0xA3B0AF1),
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,gapPadding: 1,
                                                  borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                        ),

                                        SizedBox(height: 30),
                                        DropdownButtonFormField<Category>(
                                          dropdownColor: Colors.white,
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
                                            // fillColor: Color(0xA3B0AF1),
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,gapPadding: 1,
                                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 35),

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
                                ),

                              );
                            });
                      },


                      child: Text('Modifier'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(left: 20,right: 20),
                        foregroundColor: Colors.lightGreen,
                        backgroundColor: Color(0xfffff1),
                        side: BorderSide(color: Colors.black12,),
                        elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),

                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                                      surfaceTintColor: Color(0xB0AFAFA3),
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
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(left: 20,right: 20),
                        foregroundColor: Colors.redAccent,
                        backgroundColor: Color(0xfffff1),
                        side: BorderSide(color: Colors.black12,),
                        elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
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


class YourDataSource extends DataTableSource {
  List<Matiere> _items;
  // Function(int) onTapCallback; // La fonction prendra un index comme paramètre

  YourDataSource(this._items, );
  // YourDataSource(this._items, {required this.onTapCallback});

  @override
  DataRow? getRow(int index) {

    final item = _items[index];
    return DataRow(cells: [
      DataCell(Container(width: 40,
          child: Text(item.code!))),
      DataCell(Text(item.name!.capitalize!)),
      // DataCell(
      //   IconButton(
      //     icon: Icon(Icons.more_horiz),
      //     onPressed: () {
      //       onTapCallback(index); // Appel de la fonction de callback avec l'index
      //     },
      //   ),
      // ),
    ]);
  }

  @override
  int get rowCount => _items.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
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

    print(matieresData);
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














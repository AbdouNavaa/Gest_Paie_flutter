// import 'dart:html';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/auth/users.dart';
import 'package:gestion_payements/matieres.dart';
import 'package:gestion_payements/prof_info.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Dashboard.dart';
   
import 'Cours.dart';
import 'categories.dart';
// import 'package:flutter/material.dart' hide Border;
import 'package:excel/excel.dart' as Excel;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:io';

class Professeures extends StatefulWidget {
  Professeures({Key ? key}) : super(key: key);

  @override
  _ProfesseuresState createState() => _ProfesseuresState();
}

class _ProfesseuresState extends State<Professeures> {


  List<Professeur>? filteredItems;

  Matiere? selectedMat;
  List<Matiere> matieres = [];
  Category? selectedCategory;
  List<Category> categories = [];
  Future<void> fetchCategories() async {
    List<Category> fetchedCategories = await fetchCategory();
    setState(() {
      categories = fetchedCategories;
    });
  }
  Future<void> updateMatiereList() async {
    if (selectedCategory != null) {
      List<Matiere> fetchedmatieres = await fetchMatieresByCategory(selectedCategory!.id);
      setState(() {
        matieres = fetchedmatieres;
      });
    } else {
      List<Matiere> fetchedmatieres = await fetchMatiere();
      setState(() {
        matieres = fetchedmatieres;
      });
    }
  }

  void DeleteProf(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/professeur' +"/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      setState(() {
        Navigator.pop(context);
      });
    }

  }
  Future<List<Matiere>> fetchMatieresByCategory(String categoryId) async {
    String apiUrl = 'http://192.168.43.73:5000/categorie/$categoryId/matieres';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> matieresData = responseData['matieres'];
        // print(categoryId);
        // print(matieresData);
        List<Matiere> matieres = matieresData.map((data) => Matiere.fromJson(data)).toList();
        // print(matieres);
        return matieres;
      } else {
        throw Exception('Failed to fetch matières by category');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  Future<void> fetchProfDatails(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    final response = await http.get(
      Uri.parse('http://192.168.43.73:5000/professeur/'+'/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(response.statusCode);
    // print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> professeursData = jsonDecode(response.body);
      Map<String, dynamic> professeurData = professeursData['professeur'];
      List<dynamic> matieres = professeursData['matieres'];
      _showDetails(context, professeurData,matieres);
      print("professeursData: ${professeursData}");

    } else {
      throw Exception('Failed to load Matieres');
    }
  }

  List<Matiere> matiereList = [];
  List<User> users = [];
  List<Professeur> profs = [];


  @override
  void initState() {
    super.initState();
    fetchProfs().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Professeur à items
      });

    }).catchError((error) {
      print('Erreur: $error');
    });

    fetchMatiere().then((data) {
      setState(() {
        matiereList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    // fetchProfs().then((data) {
    //   setState(() {
    //     profs = data; // Assigner la liste renvoyée par emploiesseur à items
    //   });
    // }).catchError((error) {
    //   print('Erreur: $error');
    // });
    fetchUser().then((data) {
      setState(() {
        users = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

    fetchCategories();
  }

  String getMatIdFromName(String id) {
    final professeur = matiereList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Matiere(id: '', name: 'blbla', categorieId: '', categorie_name: '', code: '',));
    // print('MatID: ${matiereList}');
    return professeur.name; // Return the ID if found, otherwise an empty string

  }
  // Professeur getProfInfos(String id) {
  //   final professeur = profs.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Professeur(id: ''));
  //   // print('MatID: ${matiereList}');
  //   return professeur; // Return the ID if found, otherwise an empty string
  //
  // }
  num? getUserMob(String name) {
    final user = users.firstWhere((user) => '${user.name}' == name, orElse: () =>User(id: '', name: 'blbla', prenom: '', email: '', mobile: 0, role: '', banque: '',));
    // print('MatID: ${matiereList}');
    return user.mobile!; // Return the ID if found, otherwise an empty string

  }
  String? getProfBanq(String name) {
    final user = filteredItems!.firstWhere((user) => '${user.nom}' == name, orElse: () =>Professeur(id: 'id'));
    // print('MatID: ${matiereList}');
    return user.banque!; // Return the ID if found, otherwise an empty string

  }
  String getMatIdFromNames(String elements) {
    List<dynamic> ids = elements.split(', '); // Sépare la chaîne en une liste d'IDs

    // Traitez chaque ID individuellement ici
    String result = '';
    for (var id in ids) {
      result += getMatIdFromName((id)) + '   '; // Traitez chaque ID avec getMatIdFromName
    }

    // print(result);
    return result.isNotEmpty ? result.substring(0, result.length - 2) : '';
  }

  TextEditingController _searchController = TextEditingController();

  TextEditingController _name = TextEditingController();
  String _Banque = 'BMCI';
  TextEditingController _account = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _mobile = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                Text("Liste des Professeurs",style: TextStyle(fontSize: 20),)
              ],
            ),
          ),
          Divider(),
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
                List<Professeur> Profs = await fetchProfs();

                setState(() {
                  // Implémentez la logique de filtrage ici
                  // Par exemple, filtrez les Professeurs dont le name ou le préname contient la valeur saisie
                  filteredItems = Profs!.where((professeur) =>
                  professeur.nom!.toLowerCase().contains(value.toLowerCase())
                      // ||
                      // professeur.prenom!.toLowerCase().contains(value.toLowerCase())
                  ).toList();
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
                child: FutureBuilder<List<Professeur>>(
                  future: fetchProfs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<Professeur>? items = snapshot.data;

                        return
                          ListView.builder(
                            itemCount: filteredItems?.length ?? items!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 100,
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 2,color: Colors.black12))),
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          InkWell(
                                            onTap: () => fetchProfDatails(filteredItems?[index].id ?? items?[index].id!),// Disable button functionality

                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),color: Colors.black26),
                                                width: 80.0,
                                                height: 75.0,
                                                // color: Colors.black26,
                                                child: Icon(Icons.person,color: Colors.white,size: 50),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 10,),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${filteredItems?[index].nom.toString().capitalizeFirst ?? items?[index].nom!.capitalizeFirst} ',style: TextStyle(
                                            color: Colors.black,
                                          ),),
                                          SizedBox(height: 10),
                                          Text(' ${filteredItems?[index].banque ?? items?[index].banque!}',style: TextStyle(color: Colors.black38),),
                                         SizedBox(height: 10),
                                          Text(' ${filteredItems?[index].email ?? items?[index].email!}',style: TextStyle(color: Colors.black38),),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ],
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
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: FoldableOptions(),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // heroTag: 'uniqueTag',
        tooltip: 'Ajouter un Prof',
        backgroundColor: Colors.white,
        label: Row(
          children: [
            Icon(Icons.cloud_download_outlined,color: Colors.black,),

          ],
        ),
        onPressed: () async {
          String? filePath = await pickExcelFile();
          if (filePath != null) {
            uploadFileToBackend(filePath);
          }
        },

      ),


    );
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String token = prefs.getString("token")!;
        Uri url = Uri.parse('http://192.168.43.73:5000/professeur/upload');
        var request = http.MultipartRequest('POST', url,);
        request.headers['Authorization'] = 'Bearer $token';
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
  String extractEmail(var cell) {
    // Utilisation d'une regex simple pour valider le format de l'e-mail
    RegExp regex = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');

    // Extraction de la valeur de la cellule
    String? cellValue = cell?.value?.toString();

    // Validation de l'e-mail avec la regex
    if (cellValue != null && regex.hasMatch(cellValue)) {
      return cellValue;
    } else {
      // Gérer le cas où l'e-mail n'est pas dans un format valide
      return ""; // Ou une autre valeur par défaut
    }
  }

  Future<void> _showDetails(BuildContext context, Map<String, dynamic> prof,List<dynamic> mat) {
    return showModalBottomSheet(
        context: context,backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return Container(
            height: 550,
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // for (var p in prof['professeur'])
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Spacer(),
                          Text("Prof Infos", style: TextStyle(fontSize: 25),),
                          Spacer(),
                          InkWell(
                            child: Icon(Icons.close,size: 25),
                            onTap: (){
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                      SizedBox(height: 50),
                      Row(
                        children: [
                          Text('Nom:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),),
                          SizedBox(width: 10,),
                          Text('${prof['nom'].toString().capitalize} ${prof['prenom'].toString().capitalize} ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),),
                        ],
                      ),
                      SizedBox(height: 25),
                      SingleChildScrollView(scrollDirection: Axis.horizontal,
                        child: Container(width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Text('Email:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                ),),
                              SizedBox(width: 10,),
                              Text('${prof['email']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                ),),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Text('Mobile:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),),
                          SizedBox(width: 10,),
                          Text('${prof['info']['mobile']}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),),

                        ],
                      ),

                      SizedBox(height: 25),
                      Row(
                        children: [
                          Text('Banque:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),),
                          SizedBox(width: 10,),
                          Text('${prof['info']['banque']}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),),

                        ],
                      ),

                      SizedBox(height: 25),
                      Row(
                        children: [
                          Text('Compte:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),),
                          SizedBox(width: 10,),
                          Text('${prof['info']['accountNumero']}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),),

                        ],
                      ),

                      SizedBox(height: 25),
                      Container(width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Text('Matieres:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                ),),
                              SizedBox(width: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  for (var matiere in mat) // Assuming items![index].matieres is a list of matieres for the professor
                                    Row(
                                      children: [
                                        // Text('Matieres: [${getMatIdFromNames(getMatSemIdFromName(semestre['_id']).join(", "))}]',style: TextStyle(fontSize: 18)),
                                        Text(matiere['name'].toString().capitalize ?? '',//abdou
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.italic,
                                            )),
                                        TextButton(
                                        onPressed: (){
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),elevation: 1,
                                                    title: Text('Supprimer Matiere'),
                                                    content: Text('Voulez vous supprimer: ${matiere['name']}?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop(); // Close the dialog
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop(); // Close the dialog
                                                          String profId = prof['_id']!;
                                                          String matiereId = matiere['_id']; // Replace 'matiere' with the actual matiere data
                                                          deleteMatiereFromProfesseur(profId, matiereId);
                                                          setState(() {
                                                            Navigator.pop(context);
                                                          });ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                                content: Text('La matiere est Supprimer avec succès.',)),);

                                                        },
                                                        child: Text('Supprimer'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Icon(Icons.delete, color: Colors.red,))
                                      ],
                                    ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: (){
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
                                          Text("Modifier Profile", style: TextStyle(fontSize: 25),),
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
                                              //hmmm
                                              SizedBox(height: 40),
                                              TextFormField(
                                                controller: _mobile,
                                                keyboardType: TextInputType.text,
                                                // maxLines: 3,
                                                decoration: InputDecoration(
                                                    filled: true,

                                                    // fillColor: Color(0xA3B0AF1),
                                                    fillColor: Colors.white,
                                                    hintText: "Mobile",
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide.none,gapPadding: 1,
                                                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                              ),

                                              SizedBox(height: 30),
                                              TextFormField(
                                                controller: _account,
                                                decoration: InputDecoration(
                                                    filled: true,

                                                    // fillColor: Color(0xA3B0AF1),
                                                    fillColor: Colors.white,
                                                    hintText: "Compte",
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide.none,gapPadding: 1,
                                                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                              ),

                                              SizedBox(height: 30),
                                              DropdownButtonFormField<String>(
                                                value: _Banque,


                                                items: [
                                                  DropdownMenuItem<String>(
                                                    child: Text('BMCI'),
                                                    value: 'BMCI',
                                                  ),
                                                  DropdownMenuItem<String>(
                                                    child: Text('BNM'),
                                                    value: 'BNM',
                                                  ),
                                                  DropdownMenuItem<String>(
                                                    child: Text('ORABANK'),
                                                    value: 'ORABANK',
                                                  ),
                                                ],
                                                onChanged: (value) {
                                                  setState(() {
                                                    _Banque = value!;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,gapPadding: 1,
                                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                  ),
                                                ),
                                              ),

                                              SizedBox(height: 30),
                                              ElevatedButton(
                                                onPressed: () async{
                                                  Navigator.of(context).pop();

                                                  fetchProfs();

                                                  String professeurId = prof['_id']; // Remplacez par l'ID de votre professeur
                                                  Map<String, dynamic> updatedData = {
                                                    'info': {
                                                      'mobile': _mobile.text, // Remplacez par la nouvelle valeur
                                                      'accountNumero': _account.text, // Remplacez par la nouvelle valeur
                                                      'banque': _Banque, // Remplacez par la nouvelle valeur
                                                    },
                                                  };

                                                  await updateProfesseurInfo(professeurId, updatedData);

                                                  setState(() {
                                                    Navigator.pop(context);
                                                  //  fetchProfs();
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
                            }, // Disable button functionality

                            child: Text('Modifier'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.only(left: 20,right: 20),
                              foregroundColor: Colors.lightGreen,
                                backgroundColor: Color(0xfffff1),
                                side: BorderSide(color: Colors.black12,),
                                // side: BorderSide(color: Colors.black,),
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                            ),

                          ),
                          TextButton(
                            onPressed:() {
                            Navigator.pop(context);
                              _AddProfMatriere(context,prof['_id']!);

                            setState(() {
                              fetchProfs();
                            });
                              },

                            child: Text('Ajout Mat'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.only(left: 20,right: 20),
                              // foregroundColor: Colors.black,
                              foregroundColor: Color(0xff0fb2ea),
                              backgroundColor: Color(0xfffff1),
                              side: BorderSide(color: Colors.black12,),
                              // side: BorderSide(color: Colors.black,),
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                            ),

                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                            surfaceTintColor: Color(0xB0AFAFA3),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                                    title: Text("Confirmer la suppression"),
                                    content: Text("Êtes-vous sûr de vouloir supprimer cet élément ?"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text("ANNULER"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text("SUPPRIMER"),
                                        onPressed: () {
                                          Navigator.of(context).pop();

                                          DeleteProf(prof['professeur']['_id']!);
                                          setState(() {
                                            Navigator.pop(context);
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Le Professeur a été Supprimer avec succès.')),
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
                              padding: EdgeInsets.only(left: 20,right: 20),
                              foregroundColor: Colors.redAccent,
                                backgroundColor: Color(0xfffff1),
                                side: BorderSide(color: Colors.black12,),
                                // side: BorderSide(color: Colors.black,),
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),
          );
        }


    );
  }

  Future<void> _AddProfMatriere(BuildContext context,String Id) async {
    setState(() {
      fetchProfs().then((data) {
        setState(() {
          filteredItems = data; // Assigner la liste renvoyée par Professeur à items
        });

      }).catchError((error) {
        print('Erreur: $error');
      });
    });
    return showDialog(
      context: context,
      builder: (context) {
        return AddProfMat(profId: Id,);
      },
    );
  }


}

void AddProf (String user,String nom,num mobile,String email,String password,String Banque, num account) async {

  // Check if the prix parameter is provided, otherwise use the default value of 100
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  // print(token);
  final response = await http.post(
    Uri.parse('http://192.168.43.73:5000/professeur/'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      "user":user,
      "nom":nom,
      // "prenom":prenom ,
      "mobile": mobile ,
      "email":email,
      "password":password,
      "banque":Banque ,
      "accountNumero": account ,
      "matieres": [],
    }),
  );

  print(response.statusCode);
  if (response.statusCode == 200) {
    print('Professeur ajouter avec succes');
    // setState(() {
    //   Navigator.pop(context);
    // });
  } else {
    print("SomeThing Went Wrong");
  }
}

class FoldableOptions extends StatefulWidget {
  @override
  _FoldableOptionsState createState() => _FoldableOptionsState();
}

class _FoldableOptionsState extends State<FoldableOptions>
    with SingleTickerProviderStateMixin {
  final List<IconData> options = [
    Icons.cloud_download_outlined,
    Icons.person_add_alt_outlined,
  ];



  TextEditingController _name = TextEditingController();
  TextEditingController _Banque = TextEditingController();
  TextEditingController _account = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  
  late Animation<Alignment> firstAnim;
  late Animation<Alignment> secondAnim;
  late Animation<Alignment> thirdAnim;
  late Animation<double> verticalPadding;
  late AnimationController controller;
  final duration = Duration(milliseconds: 190);

  Widget getItem(IconData source,VoidCallback onPress) {
    final size = 45.0;
    return GestureDetector(
      onTap: () {
        controller.reverse();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(
            Radius.circular(40),
          ),
        ),
        child: IconButton(
          icon: Icon(source,size: 20),
          color: Colors.white.withOpacity(1.0),
          onPressed: onPress,
        ),
      ),
    );
  }

  Widget buildPrimaryItem(IconData source) {
    final size = 45.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.8),
              blurRadius: verticalPadding.value),
        ],
      ),
      child: Icon(
        source,
        color: Colors.white.withOpacity(1),
        size: 20,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: duration);

    final anim = CurvedAnimation(parent: controller, curve: Curves.linear);
    firstAnim =
        Tween<Alignment>(begin: Alignment.centerRight, end: Alignment.topRight)
            .animate(anim);
    secondAnim =
        Tween<Alignment>(begin: Alignment.centerRight, end: Alignment.topLeft)
            .animate(anim);
    verticalPadding = Tween<double>(begin: 0, end: 26).animate(anim);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 120,
      margin: EdgeInsets.only(top: 15,right: 15),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Stack(
            children: <Widget>[
              Align(
                alignment: firstAnim.value,
                child:Container(
                  padding: EdgeInsets.only(
                       bottom: verticalPadding.value),
                  child: getItem(
                    options.elementAt(0),
                          ()=>_importData(context)
                  ),
                )
              ),
              Align(
                alignment: secondAnim.value,
                child:Container(
                  padding: EdgeInsets.only(
                      left: 73, top: verticalPadding.value),
                  child: getItem(
                    options.elementAt(1),
                      ()=>_displayTextInputDialog(context)
                  ),
                )
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    controller.isCompleted
                        ? controller.reverse()
                        : controller.forward();
                  },
                  child: buildPrimaryItem(
                    controller.isCompleted || controller.isAnimating
                        ? Icons.close
                        : Icons.add,
                  ),
                ),
              ),
            ],
          );
        },
      ),
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
          String banque = row[1]?.value?.toString() ?? "";
          String compte = row[2]?.value?.toString() ?? "0";
          String mobile = row[3]?.value?.toString() ?? "0";
          // String email = extractEmail(row[5]);
          String email = row[4]?.value?.toString() ?? "";
          String password = row[5]?.value?.toString() ?? "";
          String user = row[6]?.value?.toString() ?? "";

          // Faites quelque chose avec les données, par exemple, ajoutez-les à votre liste de professeurs
          print('les infos: $nom, Banque $compte');
          AddProf(user,nom, num.parse(mobile), email, password, banque, num.parse(compte));
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

    return showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable


        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              height: 590,
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Ajouter un Prof", style: TextStyle(fontSize: 25),),
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
                        // fillColor: Color(0xA3B0AF1),
                        // fillColor: Colors.white,
                        hintText: "name",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)))),
                  ),

                  // SizedBox(height: 10),
                  // TextField(
                  //   controller: _prenom,
                  //   keyboardType: TextInputType.text,
                  //   decoration: InputDecoration(
                  //       filled: true,
                  //       // fillColor: Color(0xA3B0AF1),
                  //       // fillColor: Colors.white,
                  //       hintText: "Prenom",
                  //       border: OutlineInputBorder(
                  //           borderSide: BorderSide.none,gapPadding: 1,
                  //           borderRadius: BorderRadius.all(
                  //               Radius.circular(10.0)))),
                  // ),

                  SizedBox(height: 10),
                  TextField(
                    controller: _mobile,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        // fillColor: Color(0xA3B0AF1),
                        // fillColor: Colors.white,
                        hintText: "Mobile",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)))),
                  ),

                  SizedBox(height: 10),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        // fillColor: Color(0xA3B0AF1),
                        // fillColor: Colors.white,
                        hintText: "Email",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)))),
                  ),

                  SizedBox(height: 10),
                  TextField(
                    controller: _Banque,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        // fillColor: Color(0xA3B0AF1),
                        // fillColor: Colors.white,
                        hintText: "Banque",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)))),
                  ),

                  SizedBox(height: 10),
                  TextField(
                    controller: _account,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        // fillColor: Color(0xA3B0AF1),
                        // fillColor: Colors.white,
                        hintText: "Compte",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(
                                Radius.circular(10.0)))),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(onPressed: () {
                    Navigator.of(context).pop();
                    fetchProfs();
                    // AddProf(_name.text, _Banque.text, _account.text);
                    // AddProf(_name.text, _desc.text);
                    setState(() {
                      Navigator.pop(context);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                          'Le Prof a été ajouter avec succès.')),
                    );
                    setState(() {
                      Navigator.of(context).pop();
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
        });
  }
}

class AddProfMat extends StatefulWidget {
  final String profId;
  const AddProfMat({Key? key, required this.profId}) : super(key: key);

  @override
  State<AddProfMat> createState() => _AddProfMatState();
}

class _AddProfMatState extends State<AddProfMat> {
  Matiere? selectedMat; // initialiser le type sélectionné à null
  @override
  void initState()  {
    super.initState();
    fetchCategories();

  }
  Category? selectedCateg; // initialiser le type sélectionné à null
  Future<void> fetchCategories() async {
    List<Category> fetchedCategories = await fetchCategory();
    setState(() {
      categories = fetchedCategories;
    });
  }

  // Future<Map<String, dynamic>> types =await  fetchProfessorInfo() ;
  // _id.text = items![index].name;
  Category? selectedCategory;
  List<Matiere> matieres = [];
  List<Category> categories =  [];
  Future<void> updateMatiereList() async {
    if (selectedCategory != null) {
      List<Matiere> fetchedmatieres = await fetchMatieresByCategory(selectedCategory!.id);
      setState(() {
        matieres = fetchedmatieres;
      });
    } else {
      List<Matiere> fetchedmatieres = await fetchMatiere();
      setState(() {
        matieres = fetchedmatieres;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
                surfaceTintColor: Color(0xB0AFAFA3),
        insetPadding: EdgeInsets.only(top: 280,),
// backgroundColor: Color(0xB0AFAFA3),
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
            Text("Ajouter une Matiere", style: TextStyle(fontSize: 20),),
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
width: MediaQuery.of(context).size.width,
          height: 350,
          // color: Color(0xA3B0AF1),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 16),
              Text(
                "Selection d'une Categorie:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<Category>(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name ?? ''),
                  );
                }).toList(),
                onChanged: (value) async{
                  setState(() {
                    selectedCategory = value;
                    selectedMat = null; // Reset the selected matière
                    // matieres = []; // Clear the matieres list when a category is selected
                    updateMatiereList(); // Update the list of matières based on the selected category
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "....",hintStyle: TextStyle(fontSize: 20),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Selection d'une Matiere",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<Matiere>(
                value: selectedMat,
                items: matieres.map((matiere) {
                  return DropdownMenuItem<Matiere>(
                    value: matiere,
                    child: Text(matiere.name ?? ''),
                  );
                }).toList(),
                onChanged: (value)async {
                  setState(()  {
                    selectedMat = value;
                    // professeurs = await fetchProfsByMatiere(selectedMat!.id); // Clear the professeurs list when a matière is selected
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  hintText: "....",hintStyle: TextStyle(fontSize: 20),
                  // fillColor: Color(0xA3B0AF1),
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  print(widget.profId); // Use the professor's ID in the addMatiereToProfesseus method
                  print(selectedMat!.id!);

                  addMatiereToProfesseus(widget.profId, selectedMat!.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Matiere has been added to professor successfully.')),
                  );

                  setState(() {
                    fetchProfs();
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
        )
    );

  }
}
class Professeur {
  String id;
  String? nom;
  String? prenom;
  String? email;
  int? mobile;
  String? banque;
  String? user;
  int? compte;
  num? nbh;
  num? nbc;
  num? th;
  num? somme;
  List<Info>? infos; // Change this field to be of type List<String>
  List? matieres; // Change this field to be of type List<String>

  Professeur({
    required this.id,
    this.nom,
    this.prenom,
    this.banque,
    this.compte,
    this.user,
    this.email,
    this.mobile,
    this.nbh,
    this.nbc,
    this.th,
    this.somme,
    this.infos, // Update the constructor parameter
    this.matieres, // Update the constructor parameter
  });

  // Add a factory method to create a Professeur object from a JSON map
  factory Professeur.fromJson(Map<String, dynamic> json) {
    return Professeur(
      id: json['_id'],
      nom: json['nom'],
      prenom: json['prenom'],
      mobile: json['info']['mobile'] ,
      banque: json['info']['banque'] ,
      user: json['user']?? '',
      compte: json['info']['accountNumero'],
      email: json['email'],
      nbh: json['nbh'],
      nbc: json['nbc'],
      th: json['th'],
      somme: json['somme'],
      matieres: List.from(json['matieres']?? []), // Convert the 'matieres' list to List<String>
      // infos: List.from(json['info']?? []), // Convert the 'matieres' list to List<String>
    );
  }
}

class Info {
  int? mobile;
  int? compte;
  String? banque;

  Info({
    this.mobile,
    this.compte,
    this.banque,
  });

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      mobile: json['mobile'],
      compte: json['accountNumero'],
      banque: json['banque'],
    );
  }
}
Future<List<Professeur>> fetchProfs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/professeur/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("Prof ${response.statusCode}");
  // print(response.body);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    List<dynamic> professeursData = jsonResponse['professeurs'];

    // print("Profs${professeursData}");
    List<Professeur> profs = professeursData.map((item) {
      return Professeur.fromJson(item);
    }).toList();

    // print("Prof List: $profs");
    return profs;
  } else {
    throw Exception('Failed to load Matiere');
  }
}
Future<List<Professeur>> fetchProfesseursByMatiere(String matiereId) async {
  String apiUrl = 'http://192.168.43.73:5000/matiere/$matiereId/professeurs';

  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    // if (responseData['professeurs'] is List<dynamic>) {
    final List<dynamic> professeursData = responseData['professeurs'];
    List<Professeur> fetchedProfesseurs =
    professeursData.map((data) => Professeur.fromJson(data)).toList();
    print('Mat Pros${fetchedProfesseurs}');
    return fetchedProfesseurs;
    // } else {
    //   throw Exception('Invalid API response: professeurs data is not a list');
    // }
  } else {
    throw Exception('Failed to fetch professeurs by matière');
  }
}




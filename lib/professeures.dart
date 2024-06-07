// import 'dart:html';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/auth/users.dart';
import 'package:gestion_payements/element.dart';
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

import 'home_screen.dart';

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

    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/professeur/'+'$id/elements'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(response.statusCode);
    // print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> professeursData = jsonDecode(response.body);
      var professeurData = professeursData['professeur'];
      var matieres = professeursData['elements'];
      // _showDetails(context, professeurData,matieres);
      _showDetails(context, professeurData,matieres);
      print("professeursData: ${professeurData}, MatData: ${matieres}");

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
  String? getProfBanq(String name) {
    final user = filteredItems!.firstWhere((user) => '${user.nom}' == name, orElse: () =>Professeur(id: 'id'));
    // print('MatID: ${matiereList}');
    return user.banque!; // Return the ID if found, otherwise an empty string

  }

  User getUserInfo(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = users.firstWhere((prof) => '${prof.id}' == id, orElse: () =>User(id: '', name: 'blbla', prenom: '', email: '',  role: '', ));
    // print(professeur.name);
    return professeur; // Return the ID if found, otherwise an empty string

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

  bool showSearch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      // drawer: buildDrawer(context),
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
                showSearch?
                Container(width: MediaQuery.of(context).size.width/3*2,
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(.85),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child:TextField(
                      controller: _searchController, onChanged: (value) async {
                      List<Professeur> Profs = await fetchProfs();

                      setState(() {
                        // Implémentez la logique de filtrage ici
                        // Par exemple, filtrez les Professeurs dont le name ou le préname contient la valeur saisie
                        filteredItems = Profs!.where((professeur) =>
                            professeur.nom!.toLowerCase().contains(value.toLowerCase())
                          ||
                          professeur.prenom!.toLowerCase().contains(value.toLowerCase())
                        ).toList();
                      });
                    },
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.tune_sharp, color: Colors.grey),
                          onPressed: () {
                            // _showFilterOptionsDialog(context,_searchController.text);
                          },
                        ),
                        hintText: 'Rechercher',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    )):Text("Liste des Professeurs",style: TextStyle(fontSize: 20),),
                showSearch?
                SizedBox():
                SizedBox(width: 60,),
                Container(
                  width: 50,
                  height: 50,
                  // color: Colors.black26,
                  child: IconButton(icon:Icon(Icons.search, size: 30,color: Colors.black),
                    onPressed: () {
                      setState(() {
                        showSearch = !showSearch;
                      });
                    },
                  ),
                ),    ],
            ),
          ),
          Divider(),


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
                    if (snapshot.hasData ==false) {
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
                                                child: Image.asset('assets/user1.png',),
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
                                          Text('${filteredItems?[index].nom.toString().capitalizeFirst} ${ filteredItems?[index].prenom!.capitalizeFirst} ',style: TextStyle(
                                            color: Colors.black,
                                          ),),
                                          SizedBox(height: 10),
                                          Text(' ${filteredItems?[index].banque ?? items?[index].banque!}',style: TextStyle(color: Colors.black38),),
                                         SizedBox(height: 10),
                                          Text(' ${getUserInfo(filteredItems![index].user ?? items![index].user!).email}',style: TextStyle(color: Colors.black38),),
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
        tooltip: 'Ajouter un Professeur',
        backgroundColor: Colors.indigo,
        label: Row(
          children: [
            Icon(Icons.cloud_download_outlined,color: Colors.white,),

          ],
        ),
        onPressed: () async {
          String? filePath = await pickExcelFile();
          if (filePath != null) {
            uploadFileToBackend(filePath);
            Navigator.pop(context);
          }
        },

      ),

//      bottomNavigationBar: BottomNav(),

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

  // Future<void> _showDetails(BuildContext context, Map<String, dynamic> prof, List<dynamic> matieres,) {
  Future<void> _showDetails(BuildContext context, Map<String, dynamic> prof, matieres ) {
    return showModalBottomSheet(
        context: context,backgroundColor: Colors.white,
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return Container(
            height: 550,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              color: Colors.white,
                // border: Border(top: BorderSide(color: Colors.black))
            ),
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Prof Infos", style: TextStyle(fontSize: 25,color: Colors.blueGrey),),
                      Spacer(),
                      InkWell(
                        child: Icon(Icons.close,color: Colors.blueGrey),
                        onTap: (){
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 50),
                  rowInfos("Nom:","${prof['user']['nom'].toString().capitalize} ${prof['user']['prenom'].toString().capitalize}"),
                  SizedBox(height: 25),
                  rowInfos("Email:","${prof['user']['email']}"),
                  // rowInfos("Email:","${getUserInfo(prof['user']).email}"),
                  // SizedBox(height: 25),
                  // rowInfos("Mobile:","${getUserInfo(prof['user']).mobile}"),

                  SizedBox(height: 25),
                  rowInfos("Banque:","${prof['banque']}"),

                  SizedBox(height: 25),
                  rowInfos("Compte:","${prof['accountNumero']}"),

                  SizedBox(height: 25),
                  Container(width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
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
                            children: [
                              for (var matiere in matieres) // Assuming items![index].matieres is a list of matieres for the professor
                                Row(
                                  children: [
                                    // Text('Matieres: [${getMatIdFromNames(getMatSemIdFromName(semestre['_id']).join(", "))}]',style: TextStyle(fontSize: 18)),
                                    // Text(matiere['code'].split('-')[1].toString().toUpperCase() ?? '',//abdou
                                    Text(matiere['code'].toString().toUpperCase() ?? '',//abdou
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
                                                surfaceTintColor: Color(0xB0AFAFA3),
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
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
                                        child: Icon(Icons.delete_outline_sharp, color: Colors.blueGrey,size: 30,))
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
                      ElevatedButton(
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

                                                  'mobile': _mobile.text, // Remplacez par la nouvelle valeur
                                                  'accountNumero': _account.text, // Remplacez par la nouvelle valeur
                                                  'banque': _Banque, // Remplacez par la nouvelle valeur
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
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          // side: BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),

                      ),
                      ElevatedButton(
                        onPressed:() {
                        Navigator.pop(context);
                          _AddProfMatriere(context,prof['_id']!);

                        setState(() {
                          fetchProfs();
                        });
                          },

                        child: Text('Ajout Mat'),
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          // side: BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),

                      ),
                      ElevatedButton(
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
                          // surfaceTintColor: Colors.white,
                          // side: BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
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

  Row rowInfos(name,value) {
    return Row(
                      children: [
                        Text(name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                          ),),
                        SizedBox(width: 10,),
                        Text(value,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                          ),),
                      ],
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

class AddProfMat extends StatefulWidget {
  final String profId;
  const AddProfMat({Key? key, required this.profId}) : super(key: key);

  @override
  State<AddProfMat> createState() => _AddProfMatState();
}

class _AddProfMatState extends State<AddProfMat> {
  Elem? selectedMat; // initialiser le type sélectionné à null
  @override
  void initState()  {
    super.initState();
    fetchCategories();

  }
  Future<void> fetchCategories() async {
    List<Category> fetchedCategories = await fetchCategory();
    setState(() {
      categories = fetchedCategories;
    });
  }

  // Future<Map<String, dynamic>> types =await  fetchProfessorInfo() ;
  // _id.text = items![index].name;
  Category? selectedCategory;
  List<Elem> matieres = [];
  List<Category> categories =  [];
  Future<void> updateMatiereList() async {
    if (selectedCategory != null) {
      List<Elem> fetchedmatieres = await fetchMatieresByCategory(selectedCategory!.id);
      setState(() {
        matieres = fetchedmatieres;
        print('Mats: ${matieres}');
      });
    } else {
      List<Elem> fetchedmatieres = await fetchElems();
      setState(() {
        matieres = fetchedmatieres;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
                surfaceTintColor: Color(0xB0AFAFA3),
        insetPadding: EdgeInsets.only(top: 300,),
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
              DropdownButtonFormField<Elem>(
                value: selectedMat,
                items: matieres.map((matiere) {
                  return DropdownMenuItem<Elem>(
                    value: matiere,
                    child: Text(matiere.nameMat ?? ''),
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
  String? compte;
  num? nbh;
  num? nbc;
  // num? th;
  num? somme;
  // List<Info>? infos; // Change this field to be of type List<String>
  // List? matieres; // Change this field to be of type List<String>

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
    // this.th,
    this.somme,
    // this.infos, // Update the constructor parameter
    // this.matieres, // Update the constructor parameter
  });

  // Add a factory method to create a Professeur object from a JSON map
  factory Professeur.fromJson(Map<String, dynamic> json) {
    return Professeur(
      id: json['_id'],
      nom: json['nom'],
      prenom: json['prenom'],
      // mobile: json['info']['mobile'] ,
      banque: json['banque'] ,
      user: json['user']?? '',
      compte: json['accountNumero'],
      email: json['email'],
      nbh: json['nbh'],
      nbc: json['nbc'],
      // th: json['th'],
      somme: json['somme'],
      // matieres: List.from(json['matieres']?? []), // Convert the 'matieres' list to List<String>
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




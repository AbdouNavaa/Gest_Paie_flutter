import 'package:flutter/material.dart';
import 'package:gestion_payements/matieres.dart';
import 'package:gestion_payements/prof_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Dashboard.dart';
import 'Ajout.dart';
import 'Cours.dart';
import 'categories.dart';





class Professeures extends StatefulWidget {
  Professeures({Key ? key}) : super(key: key);

  @override
  _ProfesseuresState createState() => _ProfesseuresState();
}

class _ProfesseuresState extends State<Professeures> {

  Future<List<Professeur>>? futureProfesseur;

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

  void DeleteProfesseur(id) async{
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
      // List<dynamic> professeursData = jsonResponse['professeur'];
      _showDetails(context, professeursData);
      print(professeursData);

    } else {
      throw Exception('Failed to load Matiere');
    }
  }

  List<Matiere> matiereList = [];


  @override
  void initState() {
    super.initState();
    fetchProfs().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Professeuresseur à items
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

    fetchCategories();
  }

  String getMatIdFromName(String id) {
    final professeur = matiereList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Matiere(id: '', name: 'blbla', categorieId: '', categorie_name: '', code: '',));
    print('MatID: ${matiereList}');
    return professeur.name; // Return the ID if found, otherwise an empty string

  }
  String getMatIdFromNames(String elements) {
    List<dynamic> ids = elements.split(', '); // Sépare la chaîne en une liste d'IDs

    // Traitez chaque ID individuellement ici
    String result = '';
    for (var id in ids) {
      result += getMatIdFromName((id)) + '   '; // Traitez chaque ID avec getMatIdFromName
    }

    print(result);
    return result.isNotEmpty ? result.substring(0, result.length - 2) : '';
  }

  TextEditingController _searchController = TextEditingController();

  TextEditingController _name = TextEditingController();
  TextEditingController _prenom = TextEditingController();
  TextEditingController _Banque = TextEditingController();
  TextEditingController _account = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _matieres = TextEditingController();


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
                Text("Liste de Professeures",style: TextStyle(fontSize: 25),)
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
                List<Professeur> Professeurs = await fetchProfs();

                setState(() {
                  // Implémentez la logique de filtrage ici
                  // Par exemple, filtrez les Professeuresseurs dont le name ou le préname contient la valeur saisie
                  filteredItems = Professeurs!.where((professeur) =>
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
                            itemCount: filteredItems?.length ?? 0,
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
                                            onTap: () => fetchProfDatails(filteredItems?[index].id),// Disable button functionality

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
                                          Text('${filteredItems?[index].nom} ',style: TextStyle(
                                            color: Colors.black,
                                          ),),
                                          SizedBox(height: 10),
                                          Text(' ${filteredItems?[index].banque}',style: TextStyle(color: Colors.black38),),
                                         SizedBox(height: 10),
                                          Text(' ${filteredItems?[index].email}',style: TextStyle(color: Colors.black38),),
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // heroTag: 'uniqueTag',
        tooltip: 'Ajouter un Professeur',
        backgroundColor: Colors.white,
        label: Row(
          children: [Icon(Icons.add,color: Colors.black,)],
        ),
        onPressed: () => _displayTextInputDialog(context),

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
              isScrollControlled: true, // Rendre le contenu déroulable


              context: context,
              builder: (BuildContext context) {
                return SingleChildScrollView(
                  child: Container(
                    height: 650,
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Ajouter un Professeur", style: TextStyle(fontSize: 25),),
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
                          AddProfesseur(_name.text, _Banque.text, _email.text,
                              num.parse(_mobile.text),num.parse(_account.text));
                          // AddProfesseur(_name.text, _desc.text);
                          setState(() {
                            Navigator.pop(context);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                'Le Professeur a été ajouter avec succès.')),
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
  Future<void> _showDetails(BuildContext context, Map<String, dynamic> prof) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return Container(
            height: 600,
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
                          Text("Prof Infos", style: TextStyle(fontSize: 30),),
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
                          Text('${prof['professeur']['nomComplet']} ',
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
                          Text('Email:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),),
                          SizedBox(width: 10,),
                          Text('${prof['professeur']['email']}',
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
                          Text('mobile:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),),
                          SizedBox(width: 10,),
                          Text('${prof['professeur']['mobile']}',
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
                          Text('${prof['professeur']['banque']}',
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
                          Text('${prof['professeur']['accountNumero']}',
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
                          Text('Matieres:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),),
                          SizedBox(width: 10,),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              for (var matiere in prof['matieres']) // Assuming items![index].matieres is a list of matieres for the professor
                                Row(
                                  children: [
                                    // Text('Matieres: [${getMatIdFromNames(getMatSemIdFromName(semestre['_id']).join(", "))}]',style: TextStyle(fontSize: 18)),
                                    Text(matiere['name'] ?? '',//abdou
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
                                                      String profId = prof['professeur']['id']!;
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
                      // SizedBox(height: 40,),
                      // ElevatedButton(
                      //   onPressed:() =>_AddProfMatriere(context,prof['professeur']['_id']!),
                      //   child:Text('Ajouter une Matiere au Prof',style: TextStyle(fontSize: 18)),
                      //
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Color(0xff0fb2ea),
                      //     foregroundColor: Colors.white,
                      //     elevation: 10,
                      //     minimumSize:  Size( MediaQuery.of(context).size.width , MediaQuery.of(context).size.width/7),
                      //     // padding: EdgeInsets.only(left: MediaQuery.of(context).size.width /5,
                      //     //     right: MediaQuery.of(context).size.width /5,bottom: 20,top: 20),
                      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      //   ),
                      //
                      // ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Modifier les informations du professeur
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
                            onPressed:() {
                            Navigator.pop(context);
                              _AddProfMatriere(context,prof['professeur']['_id']!);

                            setState(() {
                              fetchMatiere();
                            });
                              },

                            child: Text('Ajout Mat'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.only(left: 20,right: 20),
                              foregroundColor: Colors.blue,
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
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    elevation: 1,
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

                                          DeleteProfesseur(prof['professeur']['_id']!);
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
          filteredItems = data; // Assigner la liste renvoyée par Professeuresseur à items
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


  void updateProf( id,String name,String prenom, String email,[num? mobile]) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.patch(
      Uri.parse("http://192.168.43.73:5000/professeur" + "/$id"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "nom":name,
        "prenom":prenom ,
        "mobile": mobile ,
        "email": email ,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      // Fetch the updated list of Matieres and update the UI
      fetchProfs().then((data) {
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
  void UpdateProf( id,String name,String description,[num? prix]) async {

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
      fetchProfs().then((data) {
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
void AddProfesseur (String name,String Banque,String email,num mobile,[num? account]) async {

  // Check if the prix parameter is provided, otherwise use the default value of 100
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);
  final response = await http.post(
    Uri.parse('http://192.168.43.73:5000/professeur/'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      "nomComplet":name,
      "banque":Banque ,
      "mobile": mobile,
      "email": email ,
      "accountNumero": account ,
    }),
  );
  if (response.statusCode == 200) {
    print('Professeur ajouter avec succes');
    // setState(() {
    //   Navigator.pop(context);
    // });
  } else {
    print("SomeThing Went Wrong");
  }
}

class Professeur {
  String id;
  String nom;
  // String prenom;
  int mobile;
  String? banque;
  int? compte;
  num nbh;
  num nbc;
  num th;
  num somme;
  String email;
  // List matieres; // Change this field to be of type List<String>

  Professeur({
    required this.id,
    required this.nom,
     this.banque,
     this.compte,
    required this.mobile,
    required this.nbh,
    required this.nbc,
    required this.th,
    required this.somme,
    required this.email,
    // required this.matieres, // Update the constructor parameter
  });

  // Add a factory method to create a Professeur object from a JSON map
  factory Professeur.fromJson(Map<String, dynamic> json) {
    return Professeur(
      id: json['_id'],
      nom: json['nomComplet'],
      // prenom: json['prenom'],
      mobile: json['mobile'],
      nbh: json['nbh'],
      nbc: json['nbc'],
      th: json['th'],
      somme: json['somme'],
      email: json['email'],
      banque: json['banque'],
      compte: json['accountNumero'],
      // matieres: List.from(json['matieres']), // Convert the 'matieres' list to List<String>
    );
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
        insetPadding: EdgeInsets.only(top: 80,),
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
          height: 700,
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
                  // fillColor: Colors.white,
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
                    // professeurs = await fetchProfesseursByMatiere(selectedMat!.id); // Clear the professeurs list when a matière is selected
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  hintText: "....",hintStyle: TextStyle(fontSize: 20),
                  // fillColor: Color(0xA3B0AF1),
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
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String token = prefs.getString("token")!;

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

  print(response.statusCode);
  // print(response.body);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    List<dynamic> professeursData = jsonResponse['professeurs'];

    // print(matieresData);
    List<Professeur> profs = professeursData.map((item) {
      return Professeur.fromJson(item);
    }).toList();

    print("Prof List: $profs");
    return profs;
  } else {
    throw Exception('Failed to load Matiere');
  }
}




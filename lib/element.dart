import 'package:flutter/material.dart';
import 'package:gestion_payements/filliere.dart';
import 'package:gestion_payements/professeures.dart';
import 'package:gestion_payements/semestre.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import '../matieres.dart';
import 'Cours.dart';
import 'categories.dart';





class Elements extends StatefulWidget {
  Elements({Key ? key}) : super(key: key);

  @override
  _ElementsState createState() => _ElementsState();
}

class _ElementsState extends State<Elements> {

  // Future<List<Element>>? futureGroup;

  List<Elem>? filteredItems;



  List<Matiere> matiereList = [];
  Matiere? selectedMat; // initialiser le type sélectionné à null
  Category? selectedCateg; // initialiser le type sélectionné à null

  // Future<Map<String, dynamic>> types =await  fetchProfessorInfo() ;
  // _id.text = items![index].name;
  Category? selectedCategory;
  List<Category> categories =  [];
  List<filliere> filList = [];
  List<Semestre> semLis = [];
  filliere? selectedFil;
  Semestre? selectedSem;
  TextEditingController _date = TextEditingController();
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];


  Future<void> updateProfesseurList() async {
    if (selectedMat != null) {
      List<Professeur> fetchedProfesseurs = await fetchProfesseursByMatiere(selectedMat!.id);
      setState(() {
        professeurs = fetchedProfesseurs;
        selectedProfesseur = null;
      });
    } else {
      List<Professeur> fetchedProfesseurs = await fetchProfs();
      setState(() {
        professeurs = fetchedProfesseurs;
        selectedProfesseur = null;
      });
    }
  }

  void DeleteElems(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/element' +"/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchElems().then((data) {
        setState(() {
          // filteredItems = data; // Assigner la liste renvoyée par Groupesseur à items
        });
      }).catchError((error) {
        print('Erreur: $error');
      });

    }

  }
  String getProfIdFromName(String nom) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = professeurs.firstWhere((prof) => '${prof.nom}' == nom, orElse: () =>Professeur(id: ''));
    print("ProfName:${professeur.nom}");
    return professeur.id; // Return the ID if found, otherwise an empty string

  }
  String getFilIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final fil = filList.firstWhere((f) => '${f.id}' == id, orElse: () =>filliere(id: '', name: '', description: '', niveau: ''));
    print(id);
    return fil.name; // Return the ID if found, otherwise an empty string

  }
  List<Semestre> getFilSem(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    List<Semestre> lis = [];
    final fil = semLis.firstWhere((f) => '${f.filliereId}' == id, orElse: () =>Semestre(id: '', filliereName: ''));
    lis.add(fil);
    print(id);
    return lis; // Return the ID if found, otherwise an empty string

  }

  Future<void> selectDate(TextEditingController controller) async {
    DateTime? selectedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (selectedDateTime != null) {
      String formattedDateTime = DateFormat('yyyy/MM/dd').format(selectedDateTime);
      setState(() {
        controller.text = formattedDateTime;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    fetchElems().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Groupesseur à items
        print("ElList${filteredItems}");
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchfilliere().then((data) {
      setState(() {
        filList = data; // Assigner la liste renvoyée par Groupesseur à items
        fetchMatiere().then((data) {
          setState(() {
            matiereList = data; // Assigner la liste renvoyée par Groupesseur à items
          });
        }).catchError((error) {
          print('Erreur: $error');
        });
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchProfs().then((data) {
      setState(() {
        professeurs = data; // Assigner la liste renvoyée par Groupesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchCategory().then((data) {
      setState(() {
        categories = data; // Assigner la liste renvoyée par Groupesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchSemestre().then((data) {
      setState(() {
        semLis = data; // Assigner la liste renvoyée par Groupesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchCategories();
  }

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
        matiereList = fetchedmatieres;
      });
    } else {
      List<Matiere> fetchedmatieres = await fetchMatiere();
      setState(() {
        matiereList = fetchedmatieres;
      });
    }
  }
  TextEditingController _searchController = TextEditingController();



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
                  Text("Liste de Elements",style: TextStyle(fontSize: 25),)
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
                  List<Elem>? Els = await fetchElems();

                  // print("Els List: ${Els.length}");
                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les emploiesseurs dont le name ou le préname contient la valeur saisie
                    filteredItems = Els.where((ele) =>
                    (ele.mat)!.toLowerCase().contains(value.toLowerCase()) ||
                    (ele.ProfCM!).toLowerCase().contains(value.toLowerCase()) ||
                    (ele.ProfTP!).toLowerCase().contains(value.toLowerCase()) ||
                    (ele.ProfTD!).toLowerCase().contains(value.toLowerCase())
                    // (ele.SemNum!).toLowerCase().contains(value.toLowerCase()) ||
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
                  child: FutureBuilder<List<Elem>>(
                    future: fetchElems(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<Elem>? items = snapshot.data;
                          // filteredItems = items;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              // width: MediaQuery.of(context).size.width,
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
                                // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xff0fb2ea)), // Set row background color
                                columns: [
                                  DataColumn(label: Text('Sem')),
                                  DataColumn(label: Text('Mat')),
                                  DataColumn(label: Text('Fil')),
                                  DataColumn(label: Text('Prof.CM')),
                                  DataColumn(label: Text('Prof.TP')),
                                  DataColumn(label: Text('Prof.TD')),
                                  DataColumn(label: Text('Action')),
                                  // DataColumn(label: Text('Descrition')),
                                ],
                                rows: [
                                  // if (filteredItems != null)
                                    for (var ele in filteredItems ?? items!)
                                    DataRow(
                                        cells: [
                                          DataCell(Text('S${ele.SemNum}'),),
                                          DataCell(Container(
                                              width: 50,
                                              child: Text('${ele.mat}')),),


                                          DataCell(Text('${(ele.fil)?.toUpperCase()}'),),

                                          DataCell(Container(
                                              width: 50,
                                              child: Text('${ele.ProfCM}')),),
                                          DataCell(Container(
                                            width: 50,
                                              child: Text('${ele.ProfTP}')),),
                                          DataCell(Container(
                                              width: 50,
                                              child: Text('${ele.ProfTD}')),),

                                          DataCell(
                                            Row(
                                              children: [
                                                Container(
                                                  width: 35,
                                                  child: TextButton(
                                                    onPressed: () =>_showGroupDetails(context, ele,ele.id),// Disable button functionality

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
                                          // DataCell(Container(width: 105,
                                          //     child: Text('${ele.description}',)),),


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
    setState(() {
      fetchElems().then((data) {
        setState(() {
          filteredItems = data; // Assigner la liste renvoyée par Professeur à items
        });

      }).catchError((error) {
        print('Erreur: $error');
      });
    });return showDialog(
      context: context,
      builder: (context) {
        return AddElemScreen();
      },
    );
  }


  Future<void> _showGroupDetails(BuildContext context, Elem ele,String EleID) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return Container(
            height: 650,
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Element Infos',style: TextStyle(fontSize: 30),),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text('Semestre:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                    SizedBox(width: 10,),
                    Text("S${ele.SemNum}",
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
                    Text('Filliere:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text(ele.fil!.toUpperCase(),
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
                    Text('matiere:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text(
                      '${ele.mat }',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Prof de CM:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Container(width: 200,
                      child: Text(
                        '${ele.ProfCM }',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Prof de TP:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Container(width: 200,
                      child: Text(
                        '${ele.ProfTP }',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Prof de TD:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Container(width: 200,
                      child: Text(
                        '${ele.ProfTD }',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 25,),
              Row(
                  children: [
                    Text('Credit CM du Matiere:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text(
                      '${ele.CrCM }',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  ],
                ),
              SizedBox(height: 25,),
              Row(
                  children: [
                    Text('Credit TP du Matiere:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text(
                      '${ele.CrTP }',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  ],
                ),
              SizedBox(height: 25,),
              Row(
                  children: [
                    Text('Credit TD du Matiere:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text(
                      '${ele.CrTD }',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // _selectedNum = emp.dayNumero;
                        // _date.text = ele.fil!;
                        print(ele.id);
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                          UpdateElemScreen(eleId: ele.id,  Sem: "${ele.fil!.toUpperCase()} -S${ele.SemNum}", Mat: ele.mat!, ProCM: ele.ProfCM!,
                              ProTP: ele.ProfTP!, ProTD: ele.ProfTD!, CredCM: ele.CrCM!, CredTP: ele.CrTP!,CredTD: ele.CrTD!,
                            SemId: ele.SemId, MatId: ele.MatId, ProfCMId: ele.ProCMId, ProfTPId: ele.ProTPId,ProfTDId: ele.ProTDId,
                          )));
                        });
                        // selectedMat = emp.mat!;


                      },// Disable button functionality



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

                                    fetchElems();
                                    DeleteElems(EleID);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Le Category a été Supprimer avec succès.')),
                                    );

                                    setState(() {
                                      Navigator.pop(context);
                                      fetchElems();
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


class Elem {
  String id;
  String SemId;
  String MatId;
  String ProCMId;
  String ProTPId;
  String ProTDId;
  int? CrCM;
  int? CrTP;
  int? CrTD;
  String? code;
  String? nameMat;
  int? taux;
  int? SemNum;
  String? mat;
  String? fil;
  String? ProfCM;
  String? ProfTP;
  String? ProfTD;

  Elem({
    required this.id,
    required this.SemId,
    required this.MatId,
    required this.ProCMId,
    required this.ProTPId,
    required this.ProTDId,
    this.SemNum,
    this.code,
    this.nameMat,
    this.mat,
    this.fil,
    this.taux,
    this.CrCM,
    this.CrTP,
    this.CrTD,
    this.ProfCM,
    this.ProfTP,
    this.ProfTD,
  });

  factory Elem.fromJson(Map<String, dynamic> json) {
    return Elem(
      id: json['_id'],
      SemId: json['semestre_id'],
      MatId: json['matiere_id'],
      CrCM: json['creditCM'],
      CrTP: json['creditTP'],
      CrTD: json['creditTD'],
      code: json['code'],
      nameMat: json['name_EM'],
      taux: json['taux'],
      SemNum: json['semestre'],
      fil: json['filiere'],
      mat: json['matiere'],
      ProfCM: json['professeurCM'],
      ProfTP: json['professeurTP'],
      ProfTD: json['professeurTD'],
      ProCMId: json['professeurCM_id'],
      ProTPId: json['professeurTP_id'],
      ProTDId: json['professeurTD_id'],
    );
  }
}


Future<List<Elem>> fetchElems() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/element/'),
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
    List<dynamic> semData = jsonResponse['elements'];

    // print(semData);
    List<Elem> categories = semData.map((item) {
      return Elem.fromJson(item);
    }).toList();

    // print(categories);
    return categories;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Group');
  }
}

class AddElemScreen extends StatefulWidget {
  @override
  _AddElemScreenState createState() => _AddElemScreenState();
}

class _AddElemScreenState extends State<AddElemScreen> {
  List<Elem>? filteredItems;


  String selectedTypeName = 'CM'; // Nom de type sélectionné par défaut
  int CrCM = 0;
  int CrTP = 0;
  int CrTD = 0;
  List<int> nbhValues = [0,10, 20];

  Matiere? selectedMat;
  Professeur? selectedProfesseurCM;
  Professeur? selectedProfesseurTP;
  Professeur? selectedProfesseurTD;
  List<Professeur> professeurs = [];
  List<Matiere> matieres = [];
  DateTime? selectedDateTime;

  bool isChanged =false;


  Future<void> updateProfesseurList() async {
    if (selectedMat != null) {
      List<Professeur> fetchedProfesseurs = await fetchProfesseursByMatiere(selectedMat!.id);
      setState(() {
        professeurs = fetchedProfesseurs;
        selectedProfesseurCM = null;
        selectedProfesseurTP = null;
        selectedProfesseurTD = null;
      });
    } else {
      List<Professeur> fetchedProfesseurs = await fetchProfs();
      setState(() {
        professeurs = fetchedProfesseurs;
        selectedProfesseurCM = null;
        selectedProfesseurTP = null;
        selectedProfesseurTD = null;
      });
    }
  }

  List<Professeur> professeurList = [];
  Category? selectedCategory;
  filliere? selectedFil;
  List<Category> categories = [];
  List<Matiere> matiereList = [];
  List<Semestre> semLis = [];
  Semestre? selectedSem;
  @override
  void initState() {
    super.initState();
    fetchCategory().then((data) {
      setState(() {
        categories = data; // Assigner la liste renvoyée par emploiesseur à items
      });

      fetchMatiere().then((data) {
        setState(() {
          matiereList = data; // Assigner la liste renvoyée par emploiesseur à items
        });
      }).catchError((error) {
        print('Erreur: $error');
      });

    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchProfs().then((data) {
      setState(() {
        professeurList = data; // Assigner la liste renvoyée par emploiesseur à items
        print('Hello');
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchSemestre().then((data) {
      setState(() {
        semLis = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

    fetchCategories();
  }
  void AddElem (String matId,String semId,String? PCM,String? PTP,String? PTD,int? CrCM,int? CrTP,int? CrTD,) async {

    // Check if the prix parameter is provided, otherwise use the default value of 100
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    Map<String, dynamic> body ={};
    if( PTP == '' && PTD == ''){
      body = {
        "matiere": matId,
        "semestre": semId,
        "professeurCM": PCM ?? '',
        // "professeurTP": PTP ?? '',
        // "professeurTD": PTD ?? '',
        "creditCM": CrCM ?? 0,
        "creditTP": CrTP ?? 0,
        "creditTD": CrTD ?? 0
      };

    }
    else if( PTP == '' && PTD != ''){
      body = {
        "matiere": matId,
        "semestre": semId,
        "professeurCM": PCM ?? '',
        // "professeurTP": PTP ?? '',
        "professeurTD": PTD ?? '',
        "creditCM": CrCM ?? 0,
        "creditTP": CrTP ?? 0,
        "creditTD": CrTD ?? 0
      };

    }
    else if( PTP != '' && PTD == ''){
      body = {
        "matiere": matId,
        "semestre": semId,
        "professeurCM": PCM ?? '',
        "professeurTP": PTP ?? '',
        // "professeurTD": PTD ?? '',
        "creditCM": CrCM ?? 0,
        "creditTP": CrTP ?? 0,
        "creditTD": CrTD ?? 0
      };

    }
    else {
      body = {
        "matiere": matId,
        "semestre": semId,
        "professeurCM": PCM ?? '',
        "professeurTP": PTP ?? '',
        "professeurTD": PTD ?? '',
        "creditCM": CrCM ?? 0,
        "creditTP": CrTP ?? 0,
        "creditTD": CrTD ?? 0
      };

    }
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/element/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(<String, dynamic>{
      // }),
      body: json.encode(body),

    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('Element ajouter avec succes');

setState(() {
  Navigator.pop(context);
});


    } else {
      print("SomeThing Went Wrong");
    }
  }

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
        matiereList = fetchedmatieres;
      });
    } else {
      List<Matiere> fetchedmatieres = await fetchMatiere();
      setState(() {
        matiereList = fetchedmatieres;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        insetPadding: EdgeInsets.only(top: 50,),
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
            Text("Ajouter un Element", style: TextStyle(fontSize: 25),),
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
          // height: 600,
          // color: Color(0xA3B0AF1),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),

              DropdownButtonFormField<Semestre>(
                value: selectedSem,
                items: semLis.map((sem) {
                  return DropdownMenuItem<Semestre>(
                    value: sem,
                    child: Text('${(sem.filliereName).toUpperCase()}-S${(sem.numero)} '),
                  );
                }).toList(),
                onChanged: (value)async {
                  setState(()  {
                    selectedSem = value;
                    // updateSemList();
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "selection Semestre",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),

              SizedBox(height: 10),
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
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "selection d'une Categorie",

                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<Matiere>(
                value: selectedMat,
                items: matiereList.map((mat) {
                  return DropdownMenuItem<Matiere>(
                    value: mat,
                    child: Text('${(mat.name)} '),
                  );
                }).toList(),
                onChanged: (value)async {
                  setState(()  {
                    selectedMat = value;
                    // updateSemList();
                    selectedProfesseurCM = null;
                    selectedProfesseurTP = null;
                    selectedProfesseurTD = null;
                    updateProfesseurList();
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "selection Matiere",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<Professeur>(
                value: selectedProfesseurCM,
                items: professeurs.map((professeur) {
                  return DropdownMenuItem<Professeur>(
                    value: professeur,
                    child: Text(professeur.nom! ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProfesseurCM = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "selection d'un  Professeur de CM", // Update the hintText
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
             SizedBox(height: 10),
              DropdownButtonFormField<Professeur>(
                value: selectedProfesseurTP,
                items: professeurs.map((professeur) {
                  return DropdownMenuItem<Professeur>(
                    value: professeur,
                    child: Text(professeur.nom! ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProfesseurTP = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "selection d'un  Professeur de TP", // Update the hintText
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
             SizedBox(height: 10),
              DropdownButtonFormField<Professeur>(
                value: selectedProfesseurTD,
                items: professeurs.map((professeur) {
                  return DropdownMenuItem<Professeur>(
                    value: professeur,
                    child: Text(professeur.nom! ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProfesseurTD = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "selection d'un  Professeur de TD", // Update the hintText
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'CrCM',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: CrCM,
                      items: nbhValues.map((nbhValue) {
                        return DropdownMenuItem<int>(
                          child: Text(nbhValue.toString()),
                          value: nbhValue,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          CrCM = value ?? 0;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 90,
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'CrTP',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: CrTP,
                      items: nbhValues.map((nbhValue) {
                        return DropdownMenuItem<int>(
                          child: Text(nbhValue.toString()),
                          value: nbhValue,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          CrTP = value ?? 0;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 90,
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'CrTD',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: CrTD,
                      items: nbhValues.map((nbhValue) {
                        return DropdownMenuItem<int>(
                          child: Text(nbhValue.toString()),
                          value: nbhValue,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          CrTD = value ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),
              ElevatedButton(
                onPressed: (){
                  Navigator.of(context).pop();
                  fetchElems();
                  // Pass the selected types to addCoursToProfesseur method
                  String PrCM = selectedProfesseurCM != null ? selectedProfesseurCM!.id: '';
                  int CCM = selectedProfesseurCM != null ? CrCM: 0;
                  String PrTP = selectedProfesseurTP != null ? selectedProfesseurTP!.id: '';
                  int CTP = selectedProfesseurTP != null ? CrTP: 0;
                  String PrTD = selectedProfesseurTD != null ? selectedProfesseurTD!.id: '';
                  int CTD = selectedProfesseurTD != null ? CrTD: 0;
                  AddElem(selectedMat!.id!, selectedSem!.id!,PrCM,PrTP,PrTD,CCM,CTP,CTD);
                  // AddElem(int.parse(_numero.text),date, selectedFil!.id!);

                  // Addfilliere(_name.text, _desc.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Le filliere a été ajouter avec succès.')),
                  );
                  setState(() {
                    fetchElems();
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

  Future<void> addEmp(String type, num nbh,String date, int days, String GpId, String ProfId, String MatId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    final Uri uri = Uri.parse('http://192.168.43.73:5000/emploi');


    final Map<String, dynamic> emploiData = {
      "type": type,
      "nbh": nbh,
      "startTime": date,
      "dayNumero": days,
      "group": GpId,
      "professeur": ProfId,
      "matiere": MatId
    };

    try {
      final response = await http.post(
        uri,
        body: jsonEncode(emploiData),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {


        print('Emploi ajouter avec succes');
        fetchElems().then((data) {
          setState(() {
            // filteredItems = data; // Assigner la liste renvoyée par Groupesseur à items
            Navigator.pop(context);
          });
        }).catchError((error) {
          print('Erreur: $error');
        });


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'ajout de l\'emploi.')),
        );
      }

    }
    catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $error')),
      );
    }
  }

}

class UpdateElemScreen extends StatefulWidget {
  final String eleId;
  final String SemId;
  final String MatId;
  final String ProfCMId;
  final String ProfTPId;
  final String ProfTDId;
  final String Sem;
  final String Mat;
  final String ProCM;
  final String ProTP;
  final String ProTD;
  final int CredCM;
  final int CredTP;
  final int CredTD;
  UpdateElemScreen({Key? key, required this.eleId, required this.CredTD, required this.Sem, required this.Mat, required this.ProCM,
    required this.ProTP, required this.ProTD, required this.CredCM, required this.CredTP, required this.SemId, required this.MatId,
    required this.ProfCMId, required this.ProfTPId, required this.ProfTDId}) : super(key: key);
  
  @override
  _UpdateElemScreenState createState() => _UpdateElemScreenState();
}

class _UpdateElemScreenState extends State<UpdateElemScreen> {
  List<Elem>? filteredItems;


  String selectedTypeName = 'CM'; // Nom de type sélectionné par défaut
  int CrCM = 0;
  int CrTP = 0;
  int CrTD = 0;
  List<int> nbhValues = [0,10, 20];

  Matiere? selectedMat;
  Professeur? selectedProfesseurCM;
  Professeur? selectedProfesseurTP;
  Professeur? selectedProfesseurTD;
  List<Professeur> professeurs = [];
  List<Matiere> matieres = [];
  DateTime? selectedDateTime;

  bool isChanged =false;


  Future<void> updateProfesseurList() async {
    if (selectedMat != null) {
      List<Professeur> fetchedProfesseurs = await fetchProfesseursByMatiere(selectedMat!.id);
      setState(() {
        professeurs = fetchedProfesseurs;
        selectedProfesseurCM = null;
        selectedProfesseurTP = null;
        selectedProfesseurTD = null;
      });
    } else {
      List<Professeur> fetchedProfesseurs = await fetchProfs();
      setState(() {
        professeurs = fetchedProfesseurs;
        selectedProfesseurCM = null;
        selectedProfesseurTP = null;
        selectedProfesseurTD = null;
      });
    }
  }

  List<Professeur> professeurList = [];
  Category? selectedCategory;
  filliere? selectedFil;
  List<Category> categories = [];
  List<Matiere> matiereList = [];
  List<Semestre> semLis = [];
  Semestre? selectedSem;
  @override
  void initState() {
    super.initState();
    fetchCategory().then((data) {
      setState(() {
        categories = data; // Assigner la liste renvoyée par emploiesseur à items
      });

      fetchMatiere().then((data) {
        setState(() {
          matiereList = data; // Assigner la liste renvoyée par emploiesseur à items
        });
      }).catchError((error) {
        print('Erreur: $error');
      });

    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchProfs().then((data) {
      setState(() {
        professeurList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchSemestre().then((data) {
      setState(() {
        semLis = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

    CrCM = widget.CredCM;
    CrTP = widget.CredTP;
    CrTD = widget.CredTD;
    fetchCategories();
    // fetchPros();
  }
  // String getProfIdFromName(String nom) {
  //   // Assuming you have a list of professeurs named 'professeursList'
  //
  //   final professeur = professeurs.firstWhere((prof) => '${prof.nom!.toUpperCase()} ${prof.prenom!.toUpperCase()}' == nom, orElse: () =>Professeur(id: ''));
  //   print("ProfName:${professeur.nom}");
  //   return professeur.id; // Return the ID if found, otherwise an empty string
  //
  // }

  Future<void> UpdateElem (String id,String matId,String semId,String? PCM,String? PTP,String? PTD,int? CrCM,int? CrTP,int? CrTD) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    Map<String, dynamic> body ={};
    if( PTP == '' && PTD == ''){
      body = {
        "matiere": matId,
        // //"categorie": CategId,
        "semestre": semId,
        "professeurCM": PCM ?? '',
        // "professeurTP": PTP ?? '',
        // "professeurTD": PTD ?? '',
        "creditCM": CrCM ?? 0,
        "creditTP": CrTP ?? 0,
        "creditTD": CrTD ?? 0
      };

    }
    else if( PTP == '' && PTD != ''){
      body = {
        "matiere": matId,
        //"categorie": CategId,
        "semestre": semId,
        "professeurCM": PCM ?? '',
        // "professeurTP": PTP ?? '',
        "professeurTD": PTD ?? '',
        "creditCM": CrCM ?? 0,
        "creditTP": CrTP ?? 0,
        "creditTD": CrTD ?? 0
      };

    }
    else if( PTP != '' && PTD == ''){
      body = {
        "matiere": matId,
        //"categorie": CategId,
        "semestre": semId,
        "professeurCM": PCM ?? '',
        "professeurTP": PTP ?? '',
        // "professeurTD": PTD ?? '',
        "creditCM": CrCM ?? 0,
        "creditTP": CrTP ?? 0,
        "creditTD": CrTD ?? 0
      };

    }
    else {
      body = {
        "matiere": matId,
        //"categorie": CategId,
        "semestre": semId,
        "professeurCM": PCM ?? '',
        "professeurTP": PTP ?? '',
        "professeurTD": PTD ?? '',
        "creditCM": CrCM ?? 0,
        "creditTP": CrTP ?? 0,
        "creditTD": CrTD ?? 0
      };

    }  
    final url = 'http://192.168.43.73:5000/element/'  + '/$id';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        // Course creation was successful
        print("Element Updated successfully!");
        final responseData = json.decode(response.body);
          setState(() {
            Navigator.pop(context);
          });
      } else {
        // Course creation failed
        print("Failed to update. Status code: ${response.statusCode}");
        print("Error Message: ${response.body}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  Future<void> fetchCategories() async {
    List<Category> fetchedCategories = await fetchCategory();
    setState(() {
      categories = fetchedCategories;
    });
  }
  // Future<void> fetchPros() async {
  //   List<Professeur> fetchedprofs = await fetchProfs();
  //
  //   setState(() {
  //     professeurs = fetchedprofs ;
  //   });
  // }
  Future<void> updateMatiereList() async {
    if (selectedCategory != null) {
      List<Matiere> fetchedmatieres = await fetchMatieresByCategory(selectedCategory!.id);
      setState(() {
        matiereList = fetchedmatieres;
        selectedMat = null;
      });
    } else {
      List<Matiere> fetchedmatieres = await fetchMatiere();
      setState(() {
        matiereList = fetchedmatieres;
        selectedMat = null;
      });
    }
  }

  bool showSem = false;
  bool showmat = false;
  bool showPCM = false;
  bool showPTP = false;
  bool showPTD = false;
  bool showCCM = false;
  bool showCTP = false;
  bool showCTD = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        insetPadding: EdgeInsets.only(top: 50,),
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
            Text("Ajouter un Element", style: TextStyle(fontSize: 25),),
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
          // height: 600,
          // color: Color(0xA3B0AF1),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),

              // showSem?
              DropdownButtonFormField<Semestre>(
                value: selectedSem,
                hint: Text(widget.Sem),
                items: semLis.map((sem) {
                  return DropdownMenuItem<Semestre>(
                    value: sem,
                    child: Text('${(sem.filliereName).toUpperCase()}-S${(sem.numero)} '),
                  );
                }).toList(),
                onChanged: (value)async {
                  setState(()  {
                    selectedSem = value;
                    showSem = true;
                    // updateSemList();
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "selection Semestre",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              //     : TextFormField(
              //   // controller: profCMController,
              //   controller: TextEditingController(text: widget.Sem),
              //   decoration: InputDecoration(
              //     filled: true,
              //     border: OutlineInputBorder(
              //       borderSide: BorderSide.none,
              //       gapPadding: 1,
              //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
              //     ),
              //   ),
              //   onTap: () {
              //     // Afficher le menu déroulant lorsque le champ de texte est cliqué
              //       showSem = !showSem;
              //   },
              //   readOnly: true, // Rendre le champ de texte en lecture seule pour désactiver le clavier
              // ),

              SizedBox(height: 10),
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
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "selection d'une Categorie",

                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // showmat?
              DropdownButtonFormField<Matiere>(
                value: selectedMat,
                hint: Text(widget.Mat),
                items: matiereList.map((mat) {
                  return DropdownMenuItem<Matiere>(
                    value: mat,
                    child: Text('${(mat.name)} '),
                  );
                }).toList(),
                onChanged: (value)async {
                  setState(()  {
                    selectedMat = value;
                    showmat = true;
                    // updateSemList();
                    selectedProfesseurCM = null;
                    selectedProfesseurTP = null;
                    selectedProfesseurTD = null;
                    updateProfesseurList();
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "selection Matiere",
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              //     : TextFormField(
              //   // controller: profCMController,
              //   controller: TextEditingController(text: widget.Mat),
              //   decoration: InputDecoration(
              //     filled: true,
              //     border: OutlineInputBorder(
              //       borderSide: BorderSide.none,
              //       gapPadding: 1,
              //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
              //     ),
              //   ),
              //   onTap: () {
              //     // Afficher le menu déroulant lorsque le champ de texte est cliqué
              //     showmat = !showmat;
              //   },
              //   readOnly: true, // Rendre le champ de texte en lecture seule pour désactiver le clavier
              // ),

              SizedBox(height: 10),
              DropdownButtonFormField<Professeur>(
                value: selectedProfesseurCM,
                hint: Text(widget.ProCM),
                items: professeurs.map((professeur) {
                  return DropdownMenuItem<Professeur>(
                    value: professeur,
                    child: Text(professeur.nom! ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProfesseurCM = value;
                    showPCM = true;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "selection d'un  Professeur de CM", // Update the hintText
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),

             SizedBox(height: 10),
              DropdownButtonFormField<Professeur>(
                value: selectedProfesseurTP,
                hint: Text(widget.ProTP),
                items: professeurs.map((professeur) {
                  return DropdownMenuItem<Professeur>(
                    value: professeur,
                    child: Text(professeur.nom! ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProfesseurTP = value;
                    showPTP = true;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "selection d'un  Professeur de TP", // Update the hintText
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
             SizedBox(height: 10),
             DropdownButtonFormField<Professeur>(
                value: selectedProfesseurTD,
                hint: Text(widget.ProTD),
                items: professeurs.map((professeur) {
                  return DropdownMenuItem<Professeur>(
                    value: professeur,
                    child: Text(professeur.nom! ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    showPTD = true;
                    selectedProfesseurTD = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  // fillColor: Color(0xA3B0AF1),
                  hintText: "selection d'un  Professeur de TD", // Update the hintText
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'CrCM',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: CrCM,
                      hint: Text(widget.CredCM.toString()),
                      items: nbhValues.map((nbhValue) {
                        return DropdownMenuItem<int>(
                          child: Text(nbhValue.toString()),
                          value: nbhValue,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          CrCM = value ?? 0;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 90,
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'CrTP',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: CrTP,
                      hint: Text(widget.CredTP.toString()),
                      items: nbhValues.map((nbhValue) {
                        return DropdownMenuItem<int>(
                          child: Text(nbhValue.toString()),
                          value: nbhValue,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          CrTP = value ?? 0;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 90,
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'CrTD',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: CrTD,
                      hint: Text(widget.CredTD.toString()),
                      items: nbhValues.map((nbhValue) {
                        return DropdownMenuItem<int>(
                          child: Text(nbhValue.toString()),
                          value: nbhValue,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          CrTD = value ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),
              ElevatedButton(
                onPressed: (){
                  String PrCM = selectedProfesseurCM != null ? selectedProfesseurCM!.id: '';
                  int CCM = showPCM? (selectedProfesseurCM != null ? CrCM :0): CrCM;

                  String PrTP = selectedProfesseurTP != null ? selectedProfesseurTP!.id: '';

                  // int CTP = selectedProfesseurTP != null ? CrTP: 0;
                  int CTP = showPTP? (selectedProfesseurTP != null ? CrTP :0): CrTP;
                  String PrTD = selectedProfesseurTD != null ? selectedProfesseurTD!.id: '';
                  // int CTD = selectedProfesseurTD != null ? CrTD: 0;
                  int CTD = showPTP? (selectedProfesseurTD != null ? CrTD :0): CrTD;
                  // print("CategId:${selectedCategory!.id!}");

                  String semestre = showSem ? selectedSem!.id! : widget.SemId;
                  String mat = showmat ? selectedMat!.id! : widget.MatId;
                  String ProCM = showPCM ? PrCM : widget.ProfCMId;
                  String ProTP = showPTP ? PrTP :widget.ProfTPId!;
                  String ProTD = showPTD ? PrTD : widget.ProfTDId;

                  UpdateElem(widget.eleId,mat, semestre,ProCM,ProTP,ProTD,CCM,CTP,CTD);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('L\'element a été ajouter avec succès.')),
                  );
                  setState(() {
                    fetchElems();
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

  Future<void> addEmp(String type, num nbh,String date, int days, String GpId, String ProfId, String MatId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    final Uri uri = Uri.parse('http://192.168.43.73:5000/emploi');


    final Map<String, dynamic> emploiData = {
      "type": type,
      "nbh": nbh,
      "startTime": date,
      "dayNumero": days,
      "group": GpId,
      "professeur": ProfId,
      "matiere": MatId
    };

    try {
      final response = await http.post(
        uri,
        body: jsonEncode(emploiData),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {


        print('Emploi ajouter avec succes');
        fetchElems().then((data) {
          setState(() {
            // filteredItems = data; // Assigner la liste renvoyée par Groupesseur à items
            Navigator.pop(context);
          });
        }).catchError((error) {
          print('Erreur: $error');
        });


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'ajout de l\'emploi.')),
        );
      }

    }
    catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $error')),
      );
    }
  }

}



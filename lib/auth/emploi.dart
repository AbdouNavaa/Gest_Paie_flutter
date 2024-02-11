import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/auth/users.dart';
import 'package:gestion_payements/element.dart';
import 'package:gestion_payements/filliere.dart';
import 'package:gestion_payements/group.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import '../matieres.dart';
import '../professeures.dart';
import '../semestre.dart';





class Emploi extends StatefulWidget {
  Emploi({Key ? key}) : super(key: key);

  @override
  _EmploiState createState() => _EmploiState();
}

class _EmploiState extends State<Emploi> {

  Future<List<emploi>>? futureemploi;

  List<emploi>? filteredItems;

  List<Professeur> professeurList = [];
  List<User> users = [];
  // List<Group> grpList = [];
  // List<Group> grpList1 = [];
  List<Elem> elList1 = [];
  // List<Semestre> SemList = [];
  // List<Semestre> SemList1 = [];
  List<Elem> elLis = [];
  List<Matiere> matiereList = [];
  List<filliere> filList = [];

  String getProfesseurIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    // awai
    final professeur = professeurList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>
        Professeur(id: '', nom:'',user: '', matieres: [],  ));
    print("Nom: ${professeurList}");
    return "${professeur.nom!} ${ professeur.prenom!}"; // Return the ID if found, otherwise an empty string

  }

  Elem getEls(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final element = elLis.firstWhere((g) => '${g.id}' == id, orElse: () => Elem(id: '', filId: '', MatId: '', ));
    print( "Els:${element}");
    return element!; // Return the ID if found, otherwise an empty string

  }

  String getMatIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = matiereList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Matiere(id: '', name: '',  categorieId: '', categorie_name: '', code: '',));
    // print(professeur.name);
    return professeur.name; // Return the ID if found, otherwise an empty string

  }
  String getUserIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = users.firstWhere((prof) => '${prof.id}' == id, orElse: () =>User(id: '', name: 'blbla', prenom: '', email: '', mobile: 0, role: '', banque: '',));
    // print(professeur.name);
    return professeur.name; // Return the ID if found, otherwise an empty string

  }

  String getFilIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final fil = filList.firstWhere((f) => '${f.id}' == id, orElse: () =>filliere(id: '', name: '', description: '', niveau: ''));
    // print(id);
    return fil.name; // Return the ID if found, otherwise an empty string

  }

  bool showed = true;
  // List<emploi> filterItemsByGroup(Group? group, List<emploi> allItems) {
  //   if (group == null) {
  //     return allItems;
  //   } else {
  //     return allItems.where((emp) => emp.group == group.id).toList();
  //   }
  // }

  List<emploi> filterItemsBySemestre(Elem? ele, List<emploi> allItems) {
    if (ele == null) {
      return allItems;
    } else {
      print("ElID:${ele.id}");
      return allItems.where((emp) => emp.SemNum == ele.SemNum).toList();
    }
  }


  List<Elem> filterItemsByFil(filliere? fil, List<Elem> allItems) {
    if (fil == null) {
      return allItems;
    } else {
      return allItems.where((ele) => ele!.filId == fil.id).toList();
    }
  }

  List<Group> filterItemsBySem(Semestre? sem, List<Group> allItems) {
    if (sem == null) {
      return allItems;
    } else {
      return allItems.where((emp) => emp.semestre!.id == sem!.id).toList();
    }
  }

// Méthode de mise à jour du groupe sélectionné
  void updateSelectedGroup(Group? newGroup) {
    setState(() {
      selectedGroup = newGroup;
    });
  }
  void updateSelectedFil(filliere? newGroup) {
    setState(() {
      selectedFil = newGroup;
      selectedGroup = null;
    });
  }


  List<emploi> filterItemsByGroupAndSemester(List<emploi> items, Elem? selectedEle) {
    return items.where((emp) {
      String groupIdentifier = emp.element;
      String semester = "S${emp.SemNum!}";
      return groupIdentifier == selectedEle!.id && semester == selectedEle.SemNum;
    }).toList();
  }


  Group? selectedGroup;
  filliere? selectedFil;
  Elem? selectedELem;



  void DeleteEmploi(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/emploi' +"/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchemploi();
      setState(() {
        Navigator.pop(context);
      });
    }

  }


  @override
  void initState() {
    super.initState();
    fetchemploi().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par emploiesseur à items
      });

      fetchElems().then((data) {
        setState(() {
          elLis = data; // Assigner la liste renvoyée par emploiesseur à items
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
    fetchUser().then((data) {
      setState(() {
        users = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchfilliere().then((data) {
      setState(() {
        filList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });


  }

  TextEditingController _searchController = TextEditingController();

  TextEditingController _date = TextEditingController();
  int _selectedNum = 1;


  List<String> days = [
    "Dimanch",
    "Lundi",
    "Mardi",
    "Mercredi",
    "Jeudi",
    "Vendredi",
    "Samedi",
  ];

  Future<void> _showCourseDetails(BuildContext context, emploi emp) {
    return showModalBottomSheet(
        context: context,backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          // final typeWithNonZeroNbh = findTypeWithNonZeroNbh(emp.types);
          return Container(
            height: 680,
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Emploi Infos',style: TextStyle(fontSize: 30),),
                  SizedBox(height: 50),
                  // Row(
                  //   children: [
                  //     Text('Prof:',
                  //       style: TextStyle(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.w400,
                  //         fontStyle: FontStyle.italic,
                  //         // color: Colors.lightBlue
                  //       ),),
                  //     SizedBox(width: 10,),
                  //     Text(emp.type == "CM" ? getEls(emp.element)!.ProfCM!.toUpperCase()
                  //         :(emp.type == 'TP' ? getEls(emp.element)!.ProfTP!.toUpperCase():getEls(emp.element)!.ProfTD!.toUpperCase()),
                  //       style: TextStyle(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.w400,
                  //         fontStyle: FontStyle.italic,
                  //         // color: Colors.lightBlue
                  //       ),),
                  //   ],
                  // ),
                  Row(
                    children: [
                      Text('Professeur:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text(emp.enseignat!,
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
                      Text('Matiere:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text('${emp.mat}',
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
                      Text('Semestre:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text( 'S${emp.SemNum!}',
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
                  //     Text('Professeur:',
                  //       style: TextStyle(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.w400,
                  //         fontStyle: FontStyle.italic,
                  //         // color: Colors.lightBlue
                  //       ),),
                  //
                  //     SizedBox(width: 10,),
                  //     Text(getProfesseurIdFromName(emp.professor!),
                  //       style: TextStyle(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.w400,
                  //         fontStyle: FontStyle.italic,
                  //         // color: Colors.lightBlue
                  //       ),),
                  //
                  //   ],
                  // ),
                  // Row(
                  //   children: [
                  //     Text('Jour:',
                  //       style: TextStyle(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.w400,
                  //         fontStyle: FontStyle.italic,
                  //         // color: Colors.lightBlue
                  //       ),),
                  //
                  //     SizedBox(width: 10,),
                  //     Text(days[emp.dayNumero],
                  //       style: TextStyle(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.w400,
                  //         fontStyle: FontStyle.italic,
                  //         // color: Colors.lightBlue
                  //       ),),
                  //
                  //   ],
                  // ),
                  Row(
                    children: [
                      Text('Jour:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text(emp.jour!,
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
                      Text('Deb:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text(emp.startTime!,
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
                      Text('Fin:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text(emp.finishTime!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                    ],
                  ),
                  // SizedBox(height: 15),
                  // if (typeWithNonZeroNbh != null)
                  Column(
                    children: [
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Text('Type:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text('${emp.type}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Text('Nb Heures:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text('${emp.nbh}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 25,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _selectedNum = emp.dayNumero;
                          _date.text = emp.startTime!;
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UpdateEmploiScreen(empId: emp.id, day: _selectedNum, start: _date.text,
                                GN: '',
                                EM: getEls( emp.element)!.nameMat!,
                                // EP:emp.type == "CM" ?
                                // getEls( emp.element)!.ProfCM!
                                //     :(emp.type == "TP" ? getEls( emp.element)!.ProfCM!:getEls( emp.element)!.ProfCM!),
                                TN: emp.type!, TH: emp.nbh!, GId: '',EId: emp.element,)),
                            );
                          });
                          // selectedMat = emp.nameMat!;


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
                                        surfaceTintColor: Color(0xB0AFAFA3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
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
                                      DeleteEmploi(emp.id);
                                      setState(() {
                                        Navigator.pop(context);
                                      });
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
            ),
          );
        }


    );
  }


  @override
  Widget build(BuildContext context) {
    // Sort the items list based on the semestre
    // filteredItems?.sort((a, b) {
    //   // final semestreOrder = {'Lundi': 1,'Mardi': 2, 'Mercredi': 3, 'Jeudi': 4, 'Vendredi': 5, 'Samedi': 6, 'Dimanch': 7};
    //   final semestreComparison = days[a.dayNumero]!.compareTo(days[b.dayNumero]!);
    //
    //   if (semestreComparison != 0) {
    //     return semestreComparison; // Sort by semestre if they are different
    //   } else {
    //     // Sort by code within the same semestre
    //     return getEls(a.element)!.nameMat!.compareTo(getEls(b.element)!.nameMat!);
    //   }
    // });
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
                  Text("Liste d\'Emplois",style: TextStyle(fontSize: 25),)
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
                  List<emploi> Emplois = await fetchemploi();

                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les emploiesseurs dont le name ou le préname contient la valeur saisie
                    filteredItems = Emplois.where((emploi) =>
                    // getEls(emploi.element)!.ProfCM!.toLowerCase().contains(value.toLowerCase()) ||
                    // getEls(emploi.element)!.ProfTP!.toLowerCase().contains(value.toLowerCase()) ||
                    // getEls(emploi.element)!.ProfTP!.toLowerCase().contains(value.toLowerCase()) ||
                    getEls(emploi.element)!.nameMat!.toLowerCase().contains(value.toLowerCase()) ||
                    (days[emploi.dayNumero]).toLowerCase().contains(value.toLowerCase()) ||
                        (emploi.startTime!).toLowerCase().contains(value.toLowerCase())
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
                  child: FutureBuilder<List<emploi>>(
                    future: fetchemploi(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {

                          List<emploi>? items = snapshot.data;

                          (filteredItems ?? items!).sort((a, b) {
                            // final semestreOrder = {'Lundi': 1,'Mardi': 2, 'Mercredi': 3, 'Jeudi': 4, 'Vendredi': 5, 'Samedi': 6, 'Dimanch': 7};
                            final semestreComparison = days[a.dayNumero]!.compareTo(days[b.dayNumero]!);

                            if (semestreComparison != 0) {
                              return semestreComparison; // Sort by semestre if they are different
                            } else {
                              // Sort by code within the same semestre
                              // return getEls(a.element)!.mat!.compareTo(getEls(b.element)!.mat!);
                              return a.SemNum!.compareTo(b.SemNum!);
                            }
                          });

                          //abou
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              width: MediaQuery.of(context).size.width + 5,
                              margin: EdgeInsets.only(left: 1),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                              // margin: EdgeInsets.only(left: 1),
                              child:
                              SingleChildScrollView(
                                  child: Column(
                                    children: [

                              Row(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width /3,
                                    height: 80,
                                    child: DropdownButtonFormField<filliere>(
                                      dropdownColor: Colors.white,
                                      value: selectedFil,hint: Text("Fillieres"),
                                      items: filList.map((fil) {
                                        return DropdownMenuItem<filliere>(
                                          value: fil,
                                          child: Text(fil.name.toUpperCase()),
                                        );
                                      }).toList(),
                                      onChanged: (value)  {

                                        updateSelectedFil(value);
                                        setState(() {
                                          elList1 = filterItemsByFil(selectedFil, elLis!);
                                          selectedELem = null;
                                          // selectedGroup = null;
                                        });


                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        // hintText: "Sélecte Filliere",
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          gapPadding: 1,
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 80,
                                    width: MediaQuery.of(context).size.width / 3,
                                    child: DropdownButtonFormField<Elem>(
                                      value: selectedELem,hint: Text('Elements'),
                                      items: elList1.map((ele) {
                                        return DropdownMenuItem<Elem>(
                                          value: ele,
                                          child: Text("S${ele.SemNum}" ),
                                        );
                                      }).toList(),
                                      onChanged: (value) async{
                                        setState(() {
                                          selectedELem = value;
                                          // selectedGroup = null;
                                          // updateElemList(selectedFil!.id, selectedSem!.numero!); // Mettre à jour la liste des éléments en fonction du semestre du groupe sélectionné
                                          // filteredItems = filterElsbySem(selectedFil!.id!,selectedSem!.numero!, elList!);
                                                  filteredItems = filterItemsBySemestre(selectedELem, items!);
                                          // grpList1 = filterItemsBySem(selectedSem, grpList!);

                                        });
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: "Sélecte Group",
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          gapPadding: 1,
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Container(
                                  //   width: MediaQuery.of(context).size.width /3,
                                  //   height: 80,
                                  //   child: DropdownButtonFormField<Group>(
                                  //     dropdownColor: Colors.white,
                                  //     value: selectedGroup,hint: Text('Groups'),
                                  //     items: grpList1.map((grp) {
                                  //       return DropdownMenuItem<Group>(
                                  //         value: grp,
                                  //         child: Text('${getFilIdFromName(grp.filliereId!).toUpperCase()}-${grp.type}${grp.numero}'),
                                  //       );
                                  //     }).toList(),
                                  //     onChanged: (value)  {
                                  //       updateSelectedGroup(value);
                                  //
                                  //       setState(() {
                                  //         // filteredItems = filterItemsByGroup(selectedGroup, items!);
                                  //       });
                                  //
                                  //
                                  //     },
                                  //     decoration: InputDecoration(
                                  //       filled: true,
                                  //       fillColor: Colors.white,
                                  //       hintText: "Sélecte Group",
                                  //       border: OutlineInputBorder(
                                  //         borderSide: BorderSide.none,
                                  //         gapPadding: 1,
                                  //         borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                                      SizedBox(height: 10,),
                                      buildDayDataTable('Lundi', filteredItems ?? items!),
                                      SizedBox(height: 10,),
                                      buildDayDataTable('Mardi', filteredItems ?? items!),
                                      SizedBox(height: 10,),
                                      buildDayDataTable('Mercredi', filteredItems ?? items!),             // buildDayDataTable('Mercredi', filteredItems ?? items!),
                                      SizedBox(height: 10,),
                                      buildDayDataTable('Jeudi', filteredItems ?? items!),
                                      SizedBox(height: 10,),
                                      buildDayDataTable('Vendredi', filteredItems ?? items!),
                                      SizedBox(height: 10,),
                                      buildDayDataTable('Samedi', filteredItems ?? items!),
                                      SizedBox(height: 10,),
                                      buildDayDataTable('Dimanch', filteredItems ?? items!),
                                    ],
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
        // floatingActionButton: FloatingActionButton.extended(
        //   // heroTag: 'uniqueTag',
        //   tooltip: 'Ajouter un Emploi',
        //   backgroundColor: Colors.white,
        //   label: Row(
        //     children: [Icon(Icons.add,color: Colors.black,)],
        //   ),
        //   onPressed: () => _displayTextInputDialog(context),
        //
        // ),
        floatingActionButton: Container(
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

          // margin: EdgeInsets.only(left: 25,right: 5),
          margin: EdgeInsets.only(left: 60,right: 55),
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
            ],
          ),
        ),


      ),
      // bottomNavigationBar: BottomNav(),

    );
  }



  DataTable buildDayDataTable(String day ,List<emploi> items) {
    List<DataRow> dayRows = [];

    if (!items.any((emp) => days[emp.dayNumero] == day)) {
      dayRows.add(
        DataRow(
          cells: [
            DataCell(Container(width: 60,child: Text('N/A', style: TextStyle(color: Colors.black)))),
            DataCell(Container(width: 50,child: Text('N/A', style: TextStyle(color: Colors.black)))),
            DataCell(Container(width: 50,child: Text('N/A', style: TextStyle(color: Colors.black)))),
            DataCell(Container(width: 50,child: Text('N/A', style: TextStyle(color: Colors.black)))),
            DataCell(Container(width: 35,child: Text('N/A', style: TextStyle(color: Colors.black)))),
          ],
        ),
      );
    }

    // Ajoutez les DataRow pour chaque cours du jour
    for (var emp in items!) {
      if (days[emp.dayNumero] == day) {
        dayRows.add(
          DataRow(
            cells: [
              DataCell(Text(emp.startTime!, style: TextStyle(color: Colors.black))),
              DataCell(Text(getProfesseurIdFromName(emp.professor!), style: TextStyle(color: Colors.black))),
              // DataCell(Container(
              //   child: Text(
              //     '${emp.type == 'CM' ? getEls(emp.element)!.ProfCM ?? ''
              //         :(emp.type == 'TP' ? getEls(emp.element)!.ProfTP ?? '':getEls(emp.element)!.ProfTD ?? '')}',
              //   ),
              // )),
              DataCell(Container(width: 50, child: Text('${emp.mat}'))),
              // DataCell(Container(width: 50, child: Text('${getFilIdFromName(getGroupIdFromName(emp.group).filliereId!).toUpperCase()}${getGroupIdFromName(emp.group).SemNum!}'
              //     '-${getGroupIdFromName(emp.group).type!.toUpperCase()}'))),
              DataCell(Container(width: 50, child: Text('S${emp.SemNum!}'))),
              DataCell(
                Container(
                  width: 35,
                  child: TextButton(
                    onPressed: () =>_showCourseDetails(context, emp),
                    child: Icon(Icons.more_horiz, color: Colors.black54),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    // Construisez le DataTable pour le jour donné
    return DataTable(
      showCheckboxColumn: true,
      showBottomBorder: true,
      headingRowHeight: 50,
      columnSpacing: 15,
      dataRowHeight: 60,
      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.lightBlueAccent.shade100), // Couleur de la ligne d'en-tête

      headingTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      columns: [
        DataColumn(label: Text(day),),
        DataColumn(label: Text('')),
        DataColumn(label: Text('')),
        DataColumn(label: Text('')),
        DataColumn(label: Text('')),
      ],
      rows: dayRows,
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    setState(() {
      fetchemploi().then((data) {
        setState(() {
          filteredItems = data; // Assigner la liste renvoyée par Professeur à items
        });

      }).catchError((error) {
        print('Erreur: $error');
      });
    });return showDialog(
      context: context,
      builder: (context) {
        return AddEmploiScreen();
      },
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
        Uri url = Uri.parse('http://192.168.43.73:5000/emploi/upload');
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



}



class AddEmploiScreen extends StatefulWidget {
  @override
  _AddEmploiScreenState createState() => _AddEmploiScreenState();
}

class _AddEmploiScreenState extends State<AddEmploiScreen> {
  // Déclarez vos variables ici
  String _selectedType = 'CM';
  num _selectedNbh = 1.5;
  // ... Ajoutez d'autres variables nécessaires pour l'ajout
  List<emploi>? filteredItems;

  TextEditingController _date = TextEditingController();
  int _selectedNum = 1;

  Group? selectedGroup;
  filliere? selectedFil;
  Semestre? selectedSem;
  Elem? selectedElem;
  Matiere? selectedMat;
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];
  DateTime? selectedDateTime;

  bool isChanged =false;

  // Future<void> updateProfesseurList() async {
  //   if (selectedMat != null) {
  //     List<Professeur> fetchedProfesseurs = await fetchProfesseursByMatiere(selectedMat!.id);
  //     setState(() {
  //       professeurs = fetchedProfesseurs;
  //       selectedProfesseurCM = null;
  //       selectedProfesseurTP = null;
  //       selectedProfesseurTD = null;
  //     });
  //   } else {
  //     List<Professeur> fetchedProfesseurs = await fetchProfs();
  //     setState(() {
  //       professeurs = fetchedProfesseurs;
  //       selectedProfesseurCM = null;
  //       selectedProfesseurTP = null;
  //       selectedProfesseurTD = null;
  //     });
  //   }
  // }


  Elem getEls(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final element = elList.firstWhere((g) => '${g.id}' == id, orElse: () => Elem(id: '', filId: '', MatId: '', ));
    print( "Els:${elList}");
    return element!; // Return the ID if found, otherwise an empty string

  }

  Future<void> updateProfesseurList() async {
    if (selectedElem != null) {
      List<Professeur> fetchedProfesseurs = await fetchProfesseursByMatiere(selectedElem!.MatId);
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

  List<Professeur> professeurList = [];
  List<Group> grpList = [];
  List<Group> grpList1 = [];
  List<Elem> elList = [];
  List<Elem> elList1 = [];
  List<Matiere> matiereList = [];
  List<filliere> filList = [];
  List<Semestre> SemList = [];
  List<Semestre> SemList1 = [];
  String getFilIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final fil = filList.firstWhere((f) => '${f.id}' == id, orElse: () =>filliere(id: '', name: '', description: '', niveau: ''));
    // print(id);
    return fil.name; // Return the ID if found, otherwise an empty string

  }
  Future<void> selectTime(TextEditingController controller) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      String formattedTime = selectedTime.format(context); // Utilise la méthode format avec le context


      setState(() {
        controller.text = formattedTime;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    fetchElems().then((data) {
      setState(() {
        elList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchGroup().then((data) {
      setState(() {
        grpList = data; // Assigner la liste renvoyée par emploiesseur à items
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
    fetchfilliere().then((data) {
      setState(() {
        filList = data; // Assigner la liste renvoyée par emploiesseur à items
      });



    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchSemestre().then((data) {
      setState(() {
        SemList = data; // Assigner la liste renvoyée par emploiesseur à items
        print("Sems${SemList}");
      });



    }).catchError((error) {
      print('Erreur: $error');
    });

  }


  Future<void> updateElementList(String semestreId) async {
    // try {
    // Utilisez l'ID du semestre pour récupérer les éléments correspondants
    List<Elem> elements = await fetchElementsBySemestre(semestreId);

    setState(() {
      elList = elements;
      selectedElem = null; // Réinitialiser la sélection de l'élément
    });
    // } catch (error) {
    //   print('Erreur lors de la récupération des éléments: $error');
    // }
  }

  List<Semestre> filterItemsByFil(filliere? fil, List<Semestre> allItems) {
    if (fil == null) {
      return allItems;
    } else {
      return allItems.where((emp) => emp!.filliereId == fil.id).toList();
    }
  }
  List<Group> filterItemsBySem(Semestre? sem, List<Group> allItems) {
    if (sem == null) {
      return allItems;
    } else {
      return allItems.where((emp) => emp.semestre!.id == sem!.id).toList();
    }
  }
  List<Elem> filterElsbySem(String FilId, int sem,List<Elem> allItems) {
    if (FilId == null) {
      return [];
    } else {
      return allItems.where((emp) => emp.filId == FilId && emp.SemNum == sem).toList();
    }
  }



  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        surfaceTintColor: Color(0xB0AFAFA3),
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.only(top: 60,),
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
            Text("Ajouter un Emploi", style: TextStyle(fontSize: 25),),
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
          child: SingleChildScrollView(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                // _buildTypesInput(),
                SizedBox(height: 30),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.8,
                      child: DropdownButtonFormField<filliere>(
                        value: selectedFil,
                        items: filList.map((fil) {
                          return DropdownMenuItem<filliere>(
                            value: fil,
                            child: Text(fil.name ),
                          );
                        }).toList(),
                        onChanged: (value) async{
                          setState(() {
                            selectedFil = value;
                            selectedSem = null; // Reset the selected matière
                            selectedGroup = null; // Reset the selected matière
                            selectedElem = null; // Reset the selected matière
                            SemList1 = filterItemsByFil(selectedFil, SemList!);

                            print("Sems1${SemList1}");

                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Color(0xA3B0AF1),
                          fillColor: Colors.white,
                          hintText: "selection d'un flliere",

                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: MediaQuery.of(context).size.width / 3.6,
                      child: DropdownButtonFormField<Semestre>(
                        value: selectedSem,
                        items: SemList1.map((sem) {
                          return DropdownMenuItem<Semestre>(
                            value: sem,
                            child: Text("S${sem.numero}" ),
                          );
                        }).toList(),
                        onChanged: (value) async{
                          setState(() {
                            selectedSem = value;
                            selectedGroup = null;
                            selectedElem = null;
                            // updateElemList(selectedFil!.id, selectedSem!.numero!); // Mettre à jour la liste des éléments en fonction du semestre du groupe sélectionné
                            elList1 = filterElsbySem(selectedFil!.id!,selectedSem!.numero!, elList!);
                            grpList1 = filterItemsBySem(selectedSem, grpList!);

                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Color(0xA3B0AF1),
                          fillColor: Colors.white,
                          hintText: "...",

                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                  SizedBox(height: 10),
                DropdownButtonFormField<Group>(
                  value: selectedGroup,
                  items: grpList1.map((grp) {
                    return DropdownMenuItem<Group>(
                      value: grp,
                      child: Text('${getFilIdFromName(grp.filliereId!).toUpperCase()}${grp.numero}-${grp.type}' ),
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedGroup = value;
                      // selectedElem = null;

                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'une Group",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),

                SizedBox(height: 10),
                DropdownButtonFormField<Elem>(
                  value: selectedElem,
                  items: elList1.map((ele) {
                    return DropdownMenuItem<Elem>(
                        value: ele,
                        child: Text('${getEls(ele.id).nameMat}' )
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedElem = value;
                      selectedProfesseur = null; // Reset the selected matière
                      updateProfesseurList();

                      // print("PL${professeurs}");
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'un Element",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),

                // SizedBox(height: 10),
                // DropdownButtonFormField<Professeur>(
                //   value: selectedProfesseur,
                //   items: professeurs.map((ele) {
                //     return DropdownMenuItem<Professeur>(
                //       value: ele,
                //       child: Text(ele?.nom ?? ''));
                //   }).toList(),
                //   onChanged: (value) async{
                //     setState(() {
                //       selectedProfesseur = value;
                //       // selectedMat = null; // Reset the selected matière
                //
                //     });
                //   },
                //   decoration: InputDecoration(
                //     filled: true,
                //     fillColor: Colors.white,
                //     hintText: "selection d'un Element",
                //
                //     border: OutlineInputBorder(
                //       borderSide: BorderSide.none,gapPadding: 1,
                //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //     ),
                //   ),
                // ),

                SizedBox(height: 10),

                Row(
                  children: [
                    Container(
                      width: 147.5,
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        items: [
                          DropdownMenuItem<String>(
                            child: Text('CM'),
                            value: 'CM',
                          ),
                          DropdownMenuItem<String>(
                            child: Text('TP'),
                            value: 'TP',
                          ),
                          DropdownMenuItem<String>(
                            child: Text('TD'),
                            value: 'TD',
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
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

                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 147.5,
                      child: DropdownButtonFormField<num>(
                        value: _selectedNbh,
                        items: [
                          DropdownMenuItem<num>(
                            child: Text('1.5'),
                            value: 1.5,
                          ),
                          DropdownMenuItem<num>(
                            child: Text('2'),
                            value: 2,
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedNbh = value!;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "taux",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),

                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _date,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Heure",
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  // readOnly: true,
                  onTap: () => selectTime(_date),
                ),


                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _selectedNum,
                  items: [
                    DropdownMenuItem<int>(
                      child: Text('Dimanch'),
                      value: 0,
                    ),
                    DropdownMenuItem<int>(
                      child: Text('Lundi'),
                      value: 1,
                    ),
                    DropdownMenuItem<int>(
                      child: Text('Mardi'),
                      value: 2,
                    ),
                    DropdownMenuItem<int>(
                      child: Text('Mercredi'),
                      value: 3,
                    ),
                    DropdownMenuItem<int>(
                      child: Text('Jeudi'),
                      value: 4,
                    ),
                    DropdownMenuItem<int>(
                      child: Text('Vendredi'),
                      value: 5,
                    ),
                    DropdownMenuItem<int>(
                      child: Text('Samedi'),
                      value: 6,
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedNum = value!;
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


                SizedBox(height:20),
                ElevatedButton(
                  onPressed: (){

                    addEmp(_selectedType,_selectedNbh,_date.text,_selectedNum,selectedGroup!.id,selectedElem!.id,);
                    // Addemploi(_name.text, _desc.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('L\'emploi a été ajouter avec succès.')),
                    );

                    setState(() {
                      Navigator.of(context).pop();
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
        )
    );

  }

  Future<void> addEmp(String type, num nbh,String date, int days, String GpId, String ElemId) async {
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
      // "professeur": ProfId,
      "element": ElemId
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
        setState(() {
          Navigator.pop(context);
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

class UpdateEmploiScreen extends StatefulWidget {
  final String empId;
  final int day;
  final String start;
  final String GN;
  final String GId;
  final String EM;
  // final String EP;
  final String EId;
  final String TN;
  final num TH;

  UpdateEmploiScreen({Key? key, required this.empId, required this.day, required this.start, required this.GN, required this.EM,  required this.TN, required this.TH, required this.GId, required this.EId}) : super(key: key);
  @override
  State<UpdateEmploiScreen> createState() => _UpdateEmploiScreenState();

}

class _UpdateEmploiScreenState extends State<UpdateEmploiScreen> {

  TextEditingController _date = TextEditingController();
  int _selectedNum = 1;
  String selectedTypeName = 'CM'; // Nom de type sélectionné par défaut
  num selectedNbhValue = 1.5;
  List<String> typeNames = ['CM', 'TP', 'TD']; // Liste des noms uniques de types
  List<double> nbhValues = [1.5, 2];

  bool showType = false;
  bool showNum = false;
  bool showdays = false;
  bool showgroup = false;
  bool showElem = false;
  bool showTime = false;

  Elem? selectedElem;
  Group? selectedGroup;
  Matiere? selectedMat;
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];
  List<Matiere> matieres = [];
  DateTime? selectedDateTime;

  bool isChanged =false;



  List<Professeur> professeurList = [];
  List<Group> grpList = [];
  List<Elem> elList = [];
  List<Matiere> matiereList = [];
  List<filliere> filList = [];
  String getFilIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final fil = filList.firstWhere((f) => '${f.id}' == id, orElse: () =>filliere(id: '', name: '', description: '', niveau: ''));
    // print(id);
    return fil.name; // Return the ID if found, otherwise an empty string

  }
  Future<void> selectTime(TextEditingController controller) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      String formattedTime = selectedTime.format(context); // Utilise la méthode format avec le context


      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  Elem getEls(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final element = elList.firstWhere((g) => '${g.id}' == id, orElse: () => Elem(id: '', filId: '', MatId: '', ));
    print( "Els:${element}");
    return element!; // Return the ID if found, otherwise an empty string

  }
  Future<void> updateElementList(String semestreId) async {
    // try {
    // Utilisez l'ID du semestre pour récupérer les éléments correspondants
    List<Elem> elements = await fetchElementsBySemestre(semestreId);

    setState(() {
      elList = elements;
      selectedElem = null; // Réinitialiser la sélection de l'élément
    });
    // } catch (error) {
    //   print('Erreur lors de la récupération des éléments: $error');
    // }
  }


  @override
  void initState() {
    super.initState();
    fetchGroup().then((data) {
      setState(() {
        grpList = data; // Assigner la liste renvoyée par emploiesseur à items
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
    fetchfilliere().then((data) {
      setState(() {
        filList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

    selectedNbhValue = widget.TH;
    selectedTypeName = widget.TN;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
                surfaceTintColor: Color(0xB0AFAFA3),
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
            Text("Modifier un Emploi", style: TextStyle(fontSize: 25),),
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
          child: SingleChildScrollView(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                //hmmm
                SizedBox(height: 30),
                // _buildTypesInput(),
                Row(
                  children: [
                    Container(
                      width: 147.5,
                      child: DropdownButtonFormField<String>(
                        value: selectedTypeName,
                        items: typeNames.map((typeName) {
                          return DropdownMenuItem<String>(
                            child: Text(typeName),
                            value: typeName,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTypeName = value ?? 'CM';
                            showType = true;
                            showElem = true;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "selection d'une Group",

                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),

                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 147.5,
                      child: DropdownButtonFormField<num>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "selection d'une Group",

                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        value: selectedNbhValue,
                        items: nbhValues.map((nbhValue) {
                          return DropdownMenuItem<num>(
                            child: Text(nbhValue.toString()),
                            value: nbhValue,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedNbhValue = value ?? 1.5;
                            showNum = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _date,
                  // initialValue: widget.start!,
                  onChanged: (value) {
                    setState(() {
                      showTime = true;
                    });
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: widget.start!,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  // readOnly: true,
                  onTap: () => selectTime(_date),
                ),

                SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: widget.day,
                  items: [
                    DropdownMenuItem<int>(
                      child: Text('Dimanch'),
                      value: 0,
                    ),
                    DropdownMenuItem<int>(
                      child: Text('Lundi'),
                      value: 1,
                    ),
                    DropdownMenuItem<int>(
                      child: Text('Mardi'),
                      value: 2,
                    ),
                    DropdownMenuItem<int>(
                      child: Text('Mercredi'),
                      value: 3,
                    ),
                    DropdownMenuItem<int>(
                      child: Text('Jeudi'),
                      value: 4,
                    ),
                    DropdownMenuItem<int>(
                      child: Text('Vendredi'),
                      value: 5,
                    ),
                    DropdownMenuItem<int>(
                      child: Text('Samedi'),
                      value: 6,
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedNum = value!;
                      showdays = true;
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


                SizedBox(height: 10),
                DropdownButtonFormField<Group>(
                  value: selectedGroup,
                  hint: Text(widget.GN),
                  items: grpList.map((grp) {
                    return DropdownMenuItem<Group>(
                      value: grp,
                      child: Text('${getFilIdFromName(grp.filliereId!).toUpperCase()}${grp.semestre!.numero}-${grp.type}' ),
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedGroup = value;
                      selectedElem = null; // Reset the selected matière
                      updateElementList(selectedGroup!.semestre!.id); // Mettre à jour la liste des éléments en fonction du semestre du groupe sélectionné
                      showgroup = true;

                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'une Group",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),

                SizedBox(height: 10),
                DropdownButtonFormField<Elem>(
                  value: selectedElem,
                  hint: Text('${widget.EM}'),
                  items: elList.map((ele) {
                    return DropdownMenuItem<Elem>(
                        value: ele,
                        child: Text('${getEls(ele.id).nameMat}' )
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedElem = value;
                      // selectedMat = null; // Reset the selected matière
                      showElem = true;

                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'un Element",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),

                SizedBox(height: 10),
                // DropdownButtonFormField<Elem>(
                //   value: selectedElem,
                //   hint: Text('${widget.EP}'),
                //   items: elList.map((ele) {
                //     return DropdownMenuItem<Elem>(
                //       value: ele,
                //       child: selectedTypeName == "CM" ? Text('${getEls(ele.id).ProfCM}' )
                //           :(selectedTypeName == "TP" ? Text('${getEls(ele.id).ProfTP}' ):Text('${getEls(ele.id).ProfTD}' )),
                //     );
                //   }).toList(),
                //   onChanged: (value) async{
                //     setState(() {
                //       selectedElem = value;
                //       // selectedMat = null; // Reset the selected matière
                //       showElem = true;
                //
                //     });
                //   },
                //   decoration: InputDecoration(
                //     filled: true,
                //     fillColor: Colors.white,
                //     hintText: "selection d'un Element",
                //
                //     border: OutlineInputBorder(
                //       borderSide: BorderSide.none,gapPadding: 1,
                //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //     ),
                //   ),
                // ),

                SizedBox(height:20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();



                    String type = showType ? selectedTypeName : widget.TN;
                    num nbh = showNum ? selectedNbhValue : widget.TH;
                    int day = showdays ? _selectedNum : widget.day;
                    String group = showgroup ? selectedGroup!.id : widget.GId;
                    String elem = showElem ? selectedElem!.id : widget.EId;
                    String time = showTime ? _date.text:widget.start;

                    UpdatEmp(
                        widget.empId,
                        type,
                        nbh,
                        time,day,group,elem
                    );

                    setState(() {
                      Navigator.pop(context);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Le Type est mis à jour avec succès.')),
                    );
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

        )
    );

  }


  Future<void> UpdatEmp (id,String TN,num TH,String date,int days,String GpId,String ElemId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    final url = 'http://192.168.43.73:5000/emploi/'  + '/$id';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final Map<String, dynamic> body = {
      "type": TN,
      "nbh": TH,
      "startTime": date,
      "dayNumero": days,
      "group": GpId,
      // "professeur": ProfId,
      "element": ElemId
    };

    if (date != null) {
      body['startTime'] = date;
    }

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        // Course creation was successful
        print("Emploi Updated successfully!");
        final responseData = json.decode(response.body);
        // print("Course ID: ${responseData['cours']['_id']}");
        // You can handle the response data as needed
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

}

class emploi {
  final String id;
  final String? type;
  final num? nbh;
  final num? SemNum;
  final String? startTime;
  final int dayNumero;
  // final String group;
  final String professor;
  final String element;
  final String? jour;
  final String mat;
  final String? fil;
  final String? finishTime;
  final String? enseignat;

  emploi( {
    required this.id,
    required this.type,
    required this.nbh,
    required this.startTime,
    required this.dayNumero,
    required this.mat,
    required this.element,
    required this.professor,
    this.jour,
    this.fil,
    this.SemNum,
    this.enseignat,
    required this.finishTime,
  });

  factory emploi.fromJson(Map<String, dynamic> json) {
    return emploi(
      id: json['_id'],
      type: json['type'],
      startTime: json['startTime'],
      nbh: json['nbh'],
      dayNumero: json['dayNumero'],
      professor: json['professeur'],
      element: json['element'],
      jour: json['jour'],
    mat: json['matiere'],
      fil: json['filiere'],
      finishTime: json['finishTime'],
      SemNum: json['semestre'],
      enseignat: json['enseignat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'nbh': nbh,
      'startTime': startTime,
      'dayNumero': dayNumero,
      "professeur": professor,
      "element": element,
      "jour": jour,
      "matiere": mat,
      "filiere": fil,
      "finishTime": finishTime,
      "semestre": SemNum,
      "enseignat": enseignat
    };
  }
}

Future<List<emploi>> fetchemploi() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/emploi/'),
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
    List<dynamic> empData = jsonResponse['emplois'];

    print(empData);
    List<emploi> emplois = empData.map((item) {
      return emploi.fromJson(item);
    }).toList();

    print(emplois);
    return emplois;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load emploi');
  }
}
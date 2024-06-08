import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/auth/users.dart';
import 'package:gestion_payements/constants.dart';
import 'package:gestion_payements/element.dart';
import 'package:gestion_payements/filliere.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import '../Cours.dart';
import '../home_screen.dart';
import '../matieres.dart';
import '../professeures.dart';





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
  List<filliere> filList = [];




  bool showed = true;


  List<emploi> filterItemsBySem(int? ele,filliere? filiere, List<emploi> allItems) {
    if (ele == null) {
      return allItems;
    } else {
      print("ElID:${ele}");
      return allItems.where((emp) => emp.SemNum! == ele && emp.fil!.toLowerCase() == filiere!.name!.toLowerCase()).toList();
    }
  }

  List<int> extractUniqueSemesters(List<Elem> elems) {
    // List<Elem> Els = filterItemsByFil()
    Set<int> uniqueSemesters = elems.map((elem) => elem.SemNum!).toSet();
    return uniqueSemesters.toList();
  }
  List<Elem> filterItemsByFil(filliere? fil, List<Elem> allItems) {
    if (fil == null) {
      return allItems;
    } else {
      return allItems.where((ele) => ele!.filId == fil.id).toList();
    }
  }



  List<emploi> filterItemsByGroupAndSemester(List<emploi> items, Elem? selectedEle) {
    return items.where((emp) {
      String groupIdentifier = emp.element;
      String semester = "S${emp.SemNum!}";
      return groupIdentifier == selectedEle!.id && semester == selectedEle.SemNum;
    }).toList();
  }


  filliere? selectedFil;
  Elem? selectedELem;
  List<int> semestersList = [];
int? selectedSem ;

  bool showFloat  = false;
  bool showSearch  = false;
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
    "Dimanche",
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
            height: 600,
            decoration: BoxDecoration(borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              color: Colors.white,
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
                      Text('Emploi Infos',style: TextStyle(fontSize: 25,color: Colors.blueGrey),),
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
                  rowInfos('Professeur:',emp.enseignat!.toString().capitalize!),

                  SizedBox(height: 25),
                  rowInfos('Code-Matiere:',emp.code!.split('-')[1]!.toUpperCase()),
                  SizedBox(height: 25),
                  rowInfos('Matiere:',emp.mat!.capitalize!),

                  SizedBox(height: 25),
                  rowInfos('Semestre:','S${emp.SemNum.toString()}'),

                  SizedBox(height: 25),
                  Row(
                    children: [
                      rowInfos('Filiere:',emp.fil!.toUpperCase()),
                      SizedBox(width: 25),
                      rowInfos('Groupe:','${emp.type}${emp.groupe!.split('-')[2]!}'),
                    ],
                  ),

                  SizedBox(height: 25),
                  rowInfos('Jour:',emp.jour!.capitalize!),

                  SizedBox(height: 25),
                 // SizedBox(height: 15),
                  // if (typeWithNonZeroNbh != null)
                  Row(
                    children: [
                      rowInfos('Deb:',emp.startTime!),

                      SizedBox(width: 25),
                      rowInfos('Fin:',emp.finishTime!),
                    ],
                  ),

                  SizedBox(height: 25),
                  rowInfos('Nb Heures:','${emp.nbh}'),

                  SizedBox(height: 25,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _selectedNum = emp.dayNumero;
                          _date.text = emp.startTime!;
                          setState(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UpdateEmploiScreen(empId: emp.id, day: _selectedNum, start: _date.text,
                                GN: emp.groupe!,
                                EM: emp.mat!,
                                Prof:emp.enseignat!,
                                ProfId:emp.professor!,
                                Fil:emp.fil!,
                                  SemN: emp.SemNum!,
                                // getEls( emp.element)!.ProfCM!
                                //     :(emp.type == "TP" ? getEls( emp.element)!.ProfCM!:getEls( emp.element)!.ProfCM!),
                                TN: emp.type!, TH: emp.nbh!, GId: '',EId: emp.element,)),
                            );
                          });
                          // selectedMat = emp.nameMat!;


                        },// Disable button functionality

                        child: Text('Modifier'),
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          // side: BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 35),
                          backgroundColor: Colors.green,
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
                                        SnackBar(content: Text('L\'emploi a été Supprimer avec succès.')),
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
                          surfaceTintColor: Colors.white,
                          // side: BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 35),
                          backgroundColor: Colors.red,
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
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text(value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                  ],
                );
  }

  bool Mon = true;
  bool Tue = false;
  bool Wed = false;
  bool Thu = false;
  bool Fri = false;
  bool Sat = false;
  bool San = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Center(child: Text(' ${filteredItems?.length} ')),
        // ),
        drawer: MyDrawer(),
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
                        controller: _searchController,
                        onChanged: (value) async {
                          List<emploi> Emplois = await fetchemploi();

                          setState(() {
                            // Implémentez la logique de filtrage ici
                            // Par exemple, filtrez les emploiesseurs dont le name ou le préname contient la valeur saisie
                            filteredItems = Emplois.where((emploi) =>
                            emploi.enseignat!.toLowerCase().contains(value.toLowerCase()) ||
                                emploi.fil!.toLowerCase().contains(value.toLowerCase()) ||
                                emploi.mat!.toLowerCase().contains(value.toLowerCase()) ||
                                emploi.code!.toLowerCase().contains(value.toLowerCase()) ||
                                (days[emploi.dayNumero]).toLowerCase().contains(value.toLowerCase()) ||
                                (emploi.startTime!).toLowerCase().contains(value.toLowerCase()) ||
                                ("S${emploi.SemNum!}").toLowerCase().contains(value.toLowerCase())
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
                      )):Text("Liste des emplois",style: TextStyle(fontSize: 20),),
                  showSearch?
                  SizedBox():
                  SizedBox(width: 90,),
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
                  ),
                ],
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Container(
                                      // width: MediaQuery.of(context).size.width /3,
                                      height: 60,
                                      // color: Colors.black12,
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

                                          setState(() {
                                            selectedFil = value;
                                            selectedSem = null;
                                            elList1 = filterItemsByFil(selectedFil, elLis!);
                                             semestersList = extractUniqueSemesters(elList1);
                                            // selectedELem = null;
                                            // selectedGroup = null;
                                          });


                                          print("ElemListe${elLis}");
                                          print("SemListe${semestersList}");
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
                                  ),
                                  Flexible(
                                    child: Container(
                                      height: 60,
                                      // width: MediaQuery.of(context).size.width / 3,
                                      child: DropdownButtonFormField<int>(
                                        value: selectedSem,
                                        hint: Text('Semestres'),
                                        items: semestersList.map((sem) {
                                          return DropdownMenuItem<int>(
                                            value: sem,
                                            child: Text("S$sem"),
                                          );
                                        }).toList(),
                                        onChanged: (value) async {
                                          setState(() {
                                            selectedSem = value;
                                            filteredItems = filterItemsBySem(selectedSem,selectedFil, items!);
                                            print("Emps:${filteredItems}, ${items}, ${selectedSem} ${selectedFil!.name}");
                                          });
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: "Sélecte Semestre",
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            gapPadding: 1,
                                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                                      // SizedBox(height: 10,),
                                      SingleChildScrollView(scrollDirection: Axis.horizontal,
                                        child:
                                        Container(
                                          // width: MediaQuery.of(context).size.width - 10,
                                          height: 50,
                                          decoration: BoxDecoration(
                                          color: Colors.white,
                                              // border: Border.all(color: Colors.black12,width: 2),
                                            borderRadius: BorderRadius.all(Radius.circular(10))
                                          ),

                                          child: Row(
                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton(
                                                  onPressed: (){
                                                setState(() {
                                                  Mon = true;
                                                  Tue = false;Wed = false;Thu = false;Fri = false;Sat = false;San = false;
                                                });
                                              }, child: Text('Lun',),
                                                style: buildStyleFrom(Mon),
                                                // style: TextButton.styleFrom(backgroundColor: Mon? Colors.white:Colors.black12,padding: EdgeInsets.only(top: 15,bottom: 15),
                                                // ),
                                              ),

                                              SizedBox(width: 5,),
                                              // SizedBox(child: Container(color: Colors.black38,width: 1,),height: 21,),
                                              TextButton(onPressed: (){
                                                setState(() {
                                                  Tue = true;
                                                  Mon = false;Wed = false;Thu = false;Fri = false;Sat = false;San = false;                                                });
                                              }, child: Text('Mar'),
                                                style: buildStyleFrom(Tue),
                                              ),

                                              SizedBox(width: 5,),
                                              // SizedBox(child: Container(color: Colors.black38,width: 1,),height: 21,),
                                              TextButton(onPressed: (){
                                                setState(() {
                                                  Wed = true;
                                                  Mon = false;Tue = false;Thu = false;Fri = false;Sat = false;San = false;
                                                });
                                              }, child: Text('Mer'),
                                                style: buildStyleFrom(Wed),
                                              ),

                                              // SizedBox(child: Container(color: Colors.black38,width: 1,),height: 21,),
                                              SizedBox(width: 5,),
                                              TextButton(
                                                  onPressed: (){
                                                setState(() {
                                                  Thu = true;
                                                  Mon = false;Tue = false;Wed = false;Fri = false;Sat = false;San = false;
                                                });
                                              },
                                                  child: Text('Jeu'),
                                                style: buildStyleFrom(Thu),
                                              ),

                                              SizedBox(width: 5,),
                                              TextButton(
                                                  onPressed: (){
                                                setState(() {
                                                  Fri = true;
                                                  Mon = false;Tue = false;Wed = false;Thu = false;Sat = false;San = false;
                                                });
                                              },
                                                  child: Text('Ven'),
                                                style: buildStyleFrom(Fri),
                                              ),

                                              SizedBox(width: 5,),
                                              TextButton(
                                                  onPressed: (){
                                                setState(() {
                                                  Sat = true;
                                                  Mon = false;Tue = false;Wed = false;Thu = false;Fri = false;San = false;
                                                });
                                              },
                                                  child: Text('Sam'),
                                                style: buildStyleFrom(Sat),
                                              ),

                                              SizedBox(width: 5,),
                                              TextButton(
                                                  onPressed: (){
                                                setState(() {
                                                  San = true;
                                                  Mon = false;Tue = false;Wed = false;Thu = false;Fri = false;Sat = false;
                                                });
                                              },
                                                  child: Text('Dim'),
                                                style: buildStyleFrom(San),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                      Mon? buildDayDataTable('Lundi', filteredItems ?? items!): Container(),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(top: 20.0),
                                      //   child: Container(child: Text('Cliquez sur l\'un des bouton',style: TextStyle(fontSize: 30),),),
                                      // ),
                                      // SizedBox(height: 10,),
                                      Tue?buildDayDataTable('Mardi', filteredItems ?? items!): Container(),
                                      // SizedBox(height: 10,),
                                      Wed?buildDayDataTable('Mercredi', filteredItems ?? items!): Container(),             // buildDayDataTable('Mercredi', filteredItems ?? items!),
                                      // SizedBox(height: 10,),
                                      Thu?buildDayDataTable('Jeudi', filteredItems ?? items!): Container(),
                                      // SizedBox(height: 10,),
                                     Fri? buildDayDataTable('Vendredi', filteredItems ?? items!): Container(),
                                      // SizedBox(height: 10,),
                                      Sat?buildDayDataTable('Samedi', filteredItems ?? items!): Container(),
                                      // SizedBox(height: 10,),
                                      San?buildDayDataTable('Dimanche', filteredItems ?? items!): Container(),
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
        floatingActionButton:
        selectedEmploiIds.isNotEmpty?
        TextButton(
          onPressed: () {
            if (selectedEmploiIds.isNotEmpty) {

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    // surfaceTintColor: Color(0xB0AFAFA3),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                    title: Text("Confirmer la suppression",style: TextStyle(fontSize: 20)),
                    content: Text("Êtiez-vous sûr de vouloir supprimer cet élément ?"),
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
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          deleteSelectedEmplois();
                          // DeleteCours(course['_id']);
                          setState(() {
                            Navigator.pop(context);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Les emplois ont été Supprimer avec succès.')),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },

          child: Icon(Icons.delete_outlined,size: 40,),
          style: TextButton.styleFrom(
            surfaceTintColor: Colors.white,
            // side: BorderSide(color: Colors.black38),
            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 5,
            // padding: EdgeInsets.symmetric(horizontal: 25),
            foregroundColor: Colors.red,
            backgroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ):
        showFloat ?
        Container(
          width: 260,
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
          margin: EdgeInsets.only(left: 30,right: 25),
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
            color: Colors.indigo,
            borderRadius: BorderRadius.all(Radius.circular(10)),
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



      );

  }

  ButtonStyle buildStyleFrom(bool bol) {
    return TextButton.styleFrom(
        backgroundColor: bol ? Colors.indigo : Colors.white12,
        foregroundColor: bol ? Colors.white : Colors.black87,
        textStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        padding: EdgeInsets.only(top: 3, bottom: 3),minimumSize: Size.fromWidth(80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)),side: BorderSide(color: Colors.black12,width: 1))
    );
  }


  List<String> selectedEmploiIds = [];
  Container buildDayDataTable(String day ,List<emploi> items) {
    List<DataRow> dayRows = [];


    // Ajoutez les DataRow pour chaque cours du jour
    for (var emp in items!) {
      if (emp.jour!.capitalize == day) {
        // dayRows.add(
        //   DataRow(
        //     cells: [
        //
        //       DataCell(Container()
        //       ),
        //       DataCell(Container()
        //       ),
        //       DataCell(Container()
        //       ),
        //     ],
        //   ),
        // );
        dayRows.add(
          DataRow(
            color: MaterialStateColor.resolveWith((states) => Colors.black87),
            selected: selectedEmploiIds.contains(emp.id),
            onSelectChanged: (selected) {
              setState(() {
                if (selected!) {
                  selectedEmploiIds.add(emp.id);
                } else {
                  selectedEmploiIds.remove(emp.id);
                }
              });
            },
            cells: [
              DataCell(Container(child:
              Text(emp.startTime!, style: TextStyle(color: Colors.white)),)
              ),
              DataCell(Text('à',style: TextStyle(color: Colors.white),)
              ),
              DataCell(Container(child:
              Text(emp.finishTime!, style: TextStyle(color: Colors.white)),)
              ),


            ],
          ),
        );
        dayRows.add(
          DataRow(
            cells: [

              DataCell(Text('${emp.code!.split('-')[1].toUpperCase()}'),//abdou
                onTap: () =>_showCourseDetails(context, emp),
              ),

              DataCell(Text('${emp.fil!.toUpperCase()}')),
              DataCell(Text(emp.type == 'CM'?'G${emp.groupe!.split('-')[2]!.toString().capitalize!}':
              emp.type == 'TP'?'TP${emp.groupe!.split('-')[2]!.toString().capitalize!}':'TD${emp.groupe!.split('-')[2]!.toString().capitalize!}',
                  style: TextStyle(color: Colors.black))),
            ],
          ),
        );
        dayRows.add(
          DataRow(
            cells: [
               DataCell(Text(emp.mat!.toString().capitalize!, style: TextStyle(color: Colors.black))),
              DataCell(Container()),
              DataCell(Container()),


            ],
          ),
        );
        dayRows.add(
          DataRow(
            cells: [

              DataCell(Text(emp.enseignat!.toString().capitalize!, style: TextStyle(color: Colors.black))),
              DataCell(Container()
              ),
              DataCell(
                Container(width: 20,
                  child: TextButton(
                    onPressed: () =>_showCourseDetails(context, emp),
                    child: Icon(Icons.more_horiz_outlined, color: Colors.black54),
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

    bool vide =!items.any((emp) => emp.jour == day);
    // Construisez le DataTable pour le jour donné
    return  vide? Container(
      margin: EdgeInsets.only(bottom: 10),
      width: MediaQuery.of(context).size.width -10,
      decoration: BoxDecoration(
          // color: Colors.indigo.shade500,
          // color: Colors.black87,
          borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      child: DataTable(
        // showCheckboxColumn: true,
        // showBottomBorder: true,
        headingRowHeight: 50,
        columnSpacing: 15,
        dataRowHeight: 60,
        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white10),
        dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
        horizontalMargin: 10,

        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        columns: [
          DataColumn(label: Text('')),
          // DataColumn(label: Text('')),
          DataColumn(label: Container(width: 80,
            child: Text(day ,
              style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),
            ),
          ),),
          // DataColumn(label: Text('')),
          // DataColumn(label: Text('')),
          // DataColumn(label: Text('')),
          DataColumn(label: Text('')),
        ],
        rows: dayRows,

      ),
    ): Container();
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
      fetchemploi().then((data) {
        setState(() {
          filteredItems = data; // Assigner la liste renvoyée par Professeur à items
        });

      }).catchError((error) {
        print('Erreur: $error');
      });
return showDialog(
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

  void deleteSelectedEmplois() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    for (var id in selectedEmploiIds) {
      var response = await http.delete(
        Uri.parse('http://192.168.43.73:5000/emploi' + "/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var jsonResponse = jsonDecode(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('Deleted $id');

      } else {
        print('Failed to delete $id');
      }
    }

    fetchemploi();
    setState(() {
      selectedEmploiIds.clear();
    });
  }



}



class AddEmploiScreen extends StatefulWidget {
  @override
  _AddEmploiScreenState createState() => _AddEmploiScreenState();
}

class _AddEmploiScreenState extends State<AddEmploiScreen> {
  List<emploi>? filteredItems;


  bool isChanged =false;

  List<Professeur> professeurList = [];
  List<Elem> elList = [];
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
        builder: (context, child){
          return TimeCalender(child: child!,);
        }
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
    fetchElems().then((data) {
      setState(() {
        elList = data; // Assigner la liste renvoyée par emploiesseur à items
        print("Elems  :${elList}");
      });



    }).catchError((error) {
      print('Erreur: $error');
    });

  }

  List<Elem> filterItemsBySemestre(int? ele, List<Elem> allItems) {
    if (ele == 0) {
      return allItems;
    } else {
      // print("ElID:${ele.id}");
      return allItems.where((elem) => elem.SemNum == ele).toList();
    }
  }

  List<int> extractUniqueSemesters(List<Elem> elems) {
    // List<Elem> Els = filterItemsByFil(fil,elems);
    Set<int> uniqueSemesters = elems.map((elem) => elem.SemNum!).toSet();
    return uniqueSemesters.toList();
  }
  List<Elem> filterItemsByFil(filliere? fil, List<Elem> allItems) {
    if (fil == null) {
      return allItems;
    } else {
      return allItems.where((ele) => ele!.filId == fil.id).toList();
    }
  }


  List<FormModel> formDataList = [];
  FormModel form = FormModel();
  void addFormData() {
   setState(() {
     formDataList.add(FormModel());
     // elList = [];
     // form.selectedSem = null;
     // elList1 = [];
     // elList2 = [];
   });
  }
  void subFormData() {
   setState(() {
     formDataList.removeLast();
   });
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
              children: [
                // Afficher les formulaires existants
                for (int i = 0; i < formDataList.length; i++)
                  buildForm(formDataList[i],i),

                // Button pour ajouter un nouveau formulaire
                SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    onPressed: addFormData,
                    child: Text("Ajouter un formulaire"),
                    style: ElevatedButton.styleFrom(
                      surfaceTintColor: Colors.white,
                      // side: BorderSide(color: Colors.black38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                      // padding: EdgeInsets.symmetric(horizontal: 25),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      textStyle: TextStyle(fontWeight: FontWeight.bold),
                      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),

                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 1,
                      child: ElevatedButton(
                        onPressed: subFormData,
                        child: Text("Annuler"),
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          // side: BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          // padding: EdgeInsets.symmetric(horizontal: 25),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),

                      ),
                    ),
                    Expanded(flex: 1,
                      child: ElevatedButton(
                        onPressed: submitForms,
                        child: Text("Creer tous"),
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          // side: BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          // padding: EdgeInsets.symmetric(horizontal: 25),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    ),
                  ],
                )

                // Button pour soumettre tous les formulaires
              ],
            )

          ),
        )
    );

    //Abdou
  }


  List<dynamic> filteredGroups = [];

  List<dynamic> getProfName(String elements) {
    List<dynamic> ids = elements.split('-'); // Sépare la chaîne en une liste d'IDs
    print(ids);
    print('ProfGP:${ids[0]}');
    print('NbGP:${ids[2]}');
    return ids;
  }
  String getProfesseurIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    // awai
    final professeur = professeurList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>
        Professeur(id: '', nom:'',user: '',  ));
    print("Nom: ${professeurList}");
    return "${professeur.nom!} ${ professeur.prenom!}"; // Return the ID if found, otherwise an empty string

  }

  List<dynamic>? updateFilteredGroups(selectedType,selectedProfesseur,selectedElem) {
    if (selectedType != null && selectedElem != null) {
      List<dynamic> groups;
      List<dynamic> professors;
      if (selectedType == 'CM') {
        groups = selectedElem!.groupeCM ?? [];
        // professors = selectedElem?.professeurCM ?? [];
      } else if (selectedType == 'TP') {
        groups = selectedElem?.groupeTP ?? [];
        // professors = selectedElem?.professeurTP ?? [];
      } else {
        groups = selectedElem?.groupeTD ?? [];
        // professors = selectedElem?.professeurTD ?? [];
      }

      // Filter groups by professor ID
      String profId = selectedProfesseur?.id ?? '';
      print('ProfID:${profId}');
      filteredGroups = groups;
      print("Groups:${filteredGroups}");
      return filteredGroups;
    } else {
      filteredGroups = [];
    }
  }
  Widget buildForm(FormModel formData,FormNum) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Form ${FormNum+1}",
              style: GoogleFonts.abhayaLibre(
            color: Colors.black,
            fontSize: 25.0,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          )
              ,),
        ),
         SizedBox(height: 10),
        Row(
          children: [
            Flexible(
              child: DropdownButtonFormField<filliere>(
                value: formData.selectedFil,
                items: filList.map((fil) {
                  return DropdownMenuItem<filliere>(
                    value: fil,
                    child: Text(fil.name.toUpperCase() ),
                  );
                }).toList(),
                onChanged: (value) async{
                  setState(() {
                    formData.selectedFil = value;
                    formData.selectedSem = null; // Reset the selected matière
                    // selectedGroup = null; // Reset the selected matière
                    formData.selectedElem = null; // Reset the selected matière

                    formData.elList2 = filterItemsByFil(formData.selectedFil, elList!);
                    formData.semestersList = extractUniqueSemesters(formData.elList2);

                    // print("Sems1${formData.selectedFil!.id!}");
                    print("Sems${elList}");
                    print("Sems1${formData.elList1}");
                    print("Sems2${formData.elList2}");

                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  // fillColor: Color(0xA3B0AF1),
                  fillColor: Colors.white,
                  labelText: 'Filiere',labelStyle: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: DropdownButtonFormField<int>(
                value: formData.selectedSem,
                // hint: Text('Semestre'),
                items: formData.semestersList.map((sem) {
                  return DropdownMenuItem<int>(
                    value: sem,
                    child: Text("S$sem"),
                  );
                }).toList(),
                onChanged: (value) async {
                  setState(() {
                    formData.selectedSem = value;
                    // filteredItems = filterItemsBySemestre(selectedSem, items!);
                    // semestersList = extractUniqueSemesters(elList1);
                    // elList1 = filterItemsByFil(selectedFil, elList!);
                    formData.elList1 = filterItemsBySemestre(formData.selectedSem, formData.elList2!);
                    // print("EL1${elList1} et ${elList}");
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Semestre',labelStyle: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),

          ],
        ),
        SizedBox(height: 15),
        DropdownButtonFormField<Elem>(
          value: formData.selectedElem,
          items: formData.elList1.map((ele) {
            return DropdownMenuItem<Elem>(
                value: ele,
                child: Text(ele.nameMat ?? '')
            );
          }).toList(),
          onChanged: (value) async{
            setState(() {
              formData.selectedElem = value;
              // selectedProfesseur = null; // Reset the selected matière
              // updateProfesseurList();
              //abdou

              // print("PL${professeurs}");
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: 'Matiere',labelStyle: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,gapPadding: 1,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        ),



        SizedBox(height: 15),
        Row(
          children: [
            Flexible(
              child: DropdownButtonFormField<String>(
                value: formData._selectedType,
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
                    formData._selectedType = value!;
                    formData.selectedGroup = null;
                    // formData.filteredGroups
                    formData.groupName = formData._selectedType == "CM"?'G':formData._selectedType == "TP"?'TP':'TD';
                    updateFilteredGroups(  formData._selectedType,formData.selectedProfesseur,formData.selectedElem,);
                    formData.filteredGroups = filteredGroups;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Type',labelStyle: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: DropdownButtonFormField<num>(
                value: formData._selectedNbh,
                items: [
                  DropdownMenuItem<num>(
                    child: Text('1.5'),
                    value: 1.5,
                  ),
                  DropdownMenuItem<num>(
                    child: Text('3'),
                    value: 3,
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    formData._selectedNbh = value!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Temps',labelStyle: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),

          ],
        ),

        SizedBox(height: 15),
        if (formData._selectedType != null)
        DropdownButtonFormField<String>(
          value: formData.selectedGroup,disabledHint: Text('Groupe'),
          items: formData.filteredGroups.map((group) {
            return DropdownMenuItem<String>(
              value: group,//abdou
              child: Text('${getProfesseurIdFromName(group.split('-')[0])} ${formData.groupName}${getProfName(group)[2]}'),
              // child: Text('${getProfesseurIdFromName(getProfName(group)[0])}-${formData.groupName}${getProfName(group)[2]}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              formData.selectedGroup = value;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Sélectionner un groupe",
            labelText: 'Groupe',labelStyle: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Flexible(
              child: TextFormField(
                controller: formData._date,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Heure',labelStyle: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600),
                    // hintText: "Heure",
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,gapPadding: 1,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                // readOnly: true,
                onTap: () => selectTime(formData._date),
              ),
            ),

            SizedBox(width: 10),
            Flexible(
              child: DropdownButtonFormField<int>(
                value: formData._selectedNum,
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
                    formData._selectedNum = value!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Jour',labelStyle: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
            ),

          ],
        ),
        // SizedBox(height: 10),
        SizedBox(height: 10),



      ],
    );
  }
  void submitForms() {
    for (int i = 0; i < formDataList.length; i++) {
      // Traitez chaque formulaire ici, par exemple, envoyez-le à votre API
      FormModel formData = formDataList[i];
      print('SelectedGp:${formData.selectedGroup}');
      addEmp(formData._selectedType,formData._selectedNbh,formData._date.text,formData._selectedNum,
          formData.selectedElem!.id,formData.selectedGroup!);
      setState(() {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                surfaceTintColor: Color(0xB0AFAFA3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Alerte de succès"),
                    Icon(Icons.fact_check_outlined,color: Colors.lightGreen,)
                  ],
                ),
                content: Text(
                    "Les emplois sont ajoutés avec succès"),

                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),

                ],

              );});
      });

      // Ajoutez votre logique pour traiter les données du formulaire
      // formData.name, formData.description, etc.
      // Envoyez les données à votre API, sauvegardez-les dans la base de données, etc.
    }
  }

  Future<void> addEmp(String type, num nbh,String date, int days, String ElemId,String group) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    final Uri uri = Uri.parse('http://192.168.43.73:5000/emploi');


    final Map<String, dynamic> emploiData = {
      "type": type,
      "nbh": nbh,
      "startTime": date,
      "element": ElemId,
      "dayNumero": days,
      "groupe": group,
      // "professeur": ProfId,
    };

    // try {
    final response = await http.post(
      uri,
      body: jsonEncode(emploiData),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(response.statusCode);
    if (response.statusCode == 201) {

print('Emploi ajoute');

    }
    else {
      setState(() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                surfaceTintColor: Color(0xB0AFAFA3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Alert d\'erreur"),
                    Icon(Icons.wrong_location_outlined,color: Colors.redAccent,)
                  ],
                ),
                content: Text(jsonDecode(response.body)["message"]),
              );});

      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Échec de l\'ajout de l\'emploi.')),
      // );
    }

    // }
    // catch (error) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Erreur: $error')),
    //   );
    // }
  }

}

class FormModel {
  TextEditingController controller = TextEditingController();
  String _selectedType = 'CM';
  String groupName = 'G';
  num _selectedNbh = 1.5;
  List<dynamic> filteredGroups = [];

  String? selectedGroup;
  Professeur? selectedProfesseur;
  filliere? selectedFil;
  int? selectedSem;
  Elem? selectedElem;
  List<int> semestersList = [];

  List<Elem> elList2 = [];
  List<Elem> elList1 = [];
  TextEditingController _date = TextEditingController();
  int _selectedNum = 1;
// Ajoutez d'autres champs selon vos besoins
}


Future<List<Eles>?> fetchElsByProf(String ProfId,) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);




  final response = await http.post(
    Uri.parse('http://192.168.43.73:5000/professeur/'+'$ProfId/elements'),
    // Uri.parse('http://192.168.43.73:5000/professeur/$ProfId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  // try {

  print(response.statusCode);
  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    List<dynamic> empData = jsonResponse['elements'];

    print(empData);
    List<Eles> els = empData.map((item) {
      return Eles.fromJson(item);
    }).toList();

    print(els);

    // await sendEmailNotification(profEmail, type, date, time); // Send email
    // setState(() {
    //   Navigator.pop(context);
    // });

    return els;

  } else {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Échec de l\'ajout de l\'emploi.')),
    // );
  }

  // }
  // catch (error) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Erreur: $error')),
  //   );
  // }
}

class Eles {
  String id;
  int? SemNum;
  String filId;
  String? filName;
  List<dynamic>? ProCMId; // Le type exact des éléments peut être spécifié ici
  List<dynamic>? ProTPId;
  List<dynamic>? ProTDId;
  final List<dynamic>? groupeCM;
  final List<dynamic>? groupeTP;
  final List<dynamic>? groupeTD;
  final List<dynamic>? professeurCM;
  final List<dynamic>? professeurTP;
  final List<dynamic>? professeurTD;
  List<String>? ProCM;
  List<String>? ProTP;
  List<String>? ProTD;
  num? HCM;
  num? HTP;
  num? HTD;
  String? code;
  String? nameMat;
  String? catId;
  int? prix;
  // String? ProfTD;

  Eles({
    required this.id,
    required this.filId,
    this.ProCMId,
    this.ProTPId,
    this.ProTDId,
    this.groupeCM,
    this.groupeTP,
    this.groupeTD,
    this.professeurCM,
    this.professeurTP,
    this.professeurTD,
    this.SemNum,
    this.code,
    this.nameMat,
    // this.mat,
    this.filName,
    this.HCM,
    this.HTP,
    this.HTD,
    this.catId,
    this.prix,
    // this.ProfTD,
  });

  factory Eles.fromJson(Map<String, dynamic> json) {
    return Eles(
      id: json['_id'],
      nameMat: json['name'],
      SemNum: json['semestre'],
      HCM: json['heuresCM'],
      HTP: json['heuresTP'],
      HTD: json['heuresTD'],
      code: json['code'],
      filId: json['filiere_id'],
      filName: json['filiere'],
      catId: json['categorie_id'],
      prix: json['prix'],
      groupeCM: json['CM'] ?? [],
      groupeTP: json['TP'] ?? [],
      groupeTD: json['TD'] ?? [],
      professeurCM: json['professeurCM'] ?? [],
      professeurTP: json['professeurTP'] ?? [],
      professeurTD: json['professeurTD'] ?? [],
      // ProCM: (json['info']['CM'] as List<dynamic>).map((e) => e.toString()).toList(),
      // ProTP: (json['info']['TP'] as List<dynamic>).map((e) => e.toString()).toList(),
      // ProTD: (json['info']['TD'] as List<dynamic>).map((e) => e.toString()).toList(),

    );
  }
}

class UpdateEmploiScreen extends StatefulWidget {
  final String empId;
  final int day;
  final String start;
  final String GN;
  final String GId;
  final String EM;
  final String Prof;
  final String ProfId;
  final String Fil;
  final String EId;
  final String TN;
  final num TH;
  final num SemN;

  UpdateEmploiScreen({Key? key, required this.empId, required this.day, required this.start, required this.GN, required this.Prof,required this.ProfId,
    required this.Fil,required this.EM,  required this.TN, required this.TH, required this.GId, required this.EId, required this.SemN}) : super(key: key);
  @override
  State<UpdateEmploiScreen> createState() => _UpdateEmploiScreenState();

}

class _UpdateEmploiScreenState extends State<UpdateEmploiScreen> {

  TextEditingController _date = TextEditingController();
  int _selectedNum = 1;
  String selectedTypeName = 'CM'; // Nom de type sélectionné par défaut
  num selectedNbhValue = 1.5;
  List<String> typeNames = ['CM', 'TP', 'TD']; // Liste des noms uniques de types
  List<double> nbhValues = [1.5, 3];
  String? selectedGroup;

  bool showType = false;
  bool showNum = false;
  bool showdays = false;
  bool showElem = false;
  bool showTime = false;
  bool showGroup = false;
  bool showProf = false;

  Eles? selectedElem;
  Matiere? selectedMat;
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];
  List<Matiere> matieres = [];
  DateTime? selectedDateTime;

  bool isChanged =false;



  List<Professeur> professeurList = [];
  List<Eles> elList = [];
  List<Eles> elList1 = [];
  List<Eles> elList2 = [];
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
        builder: (context, child){
          return TimeCalender(child: child!,);
        }
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

  List<int> semestersList = [];
  filliere? selectedFil;
  int? selectedSem;
  Future<void> updateElemList() async {
    if (selectedProfesseur != null) {
      List<Eles>? fetchedProfesseurs = await fetchElsByProf(selectedProfesseur!.id);
      print('FFF:${fetchedProfesseurs}');
      setState(() {
        elList = fetchedProfesseurs!;
        selectedElem = null;
      });
    } else {
      // List<Elem> fetchedProfesseurs = await fetchElems();
      setState(() {
        elList = [];
        selectedElem = null;
      });
    }
  }


  List<Eles> filterItemsBySemestre(int? ele, List<Eles> allItems) {
    if (ele == 0) {
      return allItems;
    } else {
      // print("ElID:${ele.id}");
      return allItems.where((elem) => elem.SemNum == ele).toList();
    }
  }

  List<int> extractUniqueSemesters(List<Eles> elems) {
    // List<Elem> Els = filterItemsByFil(fil,elems);
    Set<int> uniqueSemesters = elems.map((elem) => elem.SemNum!).toSet();
    return uniqueSemesters.toList();
  }
  List<Eles> filterItemsByFil(filliere? fil, List<Eles> allItems) {
    if (fil == null) {
      return allItems;
    } else {
      return allItems.where((ele) => ele!.filId == fil.id).toList();
    }
  }


  List<dynamic> filteredGroups = [];

  List<dynamic> getProfName(String elements) {
    List<dynamic> ids = elements.split('-'); // Sépare la chaîne en une liste d'IDs
    print(ids);
    print('ProfGP:${ids[0]}');
    print('NbGP:${ids[2]}');
    return ids;
  }
  String getProfesseurIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    // awai
    final professeur = professeurList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>
        Professeur(id: '', nom:'',user: '',  ));
    print("Nom: ${professeurList}");
    return "${professeur.nom!} ${ professeur.prenom!}"; // Return the ID if found, otherwise an empty string

  }

  void updateFilteredGroups(selectedType,selectedProfesseur,selectedElem) {
    if (selectedType != null && selectedProfesseur != null) {
      List<dynamic> groups;
      List<dynamic> professors;
      if (selectedType == 'CM') {
        groups = selectedElem!.groupeCM ?? [];
        professors = selectedElem?.professeurCM ?? [];
      } else if (selectedType == 'TP') {
        groups = selectedElem?.groupeTP ?? [];
        professors = selectedElem?.professeurTP ?? [];
      } else {
        groups = selectedElem?.groupeTD ?? [];
        professors = selectedElem?.professeurTD ?? [];
      }

      // Filter groups by professor ID
      String profId = selectedProfesseur?.id ?? '';
      print('ProfID:${profId}');
      filteredGroups = groups.where((group) {
        return professors.any((prof) => prof == profId && group.contains(prof));
      }).toList();
      print("Groups:${filteredGroups}");
    } else {
      filteredGroups = [];
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
                surfaceTintColor: Color(0xB0AFAFA3),
        insetPadding: EdgeInsets.only(top: 110,),
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
          height: 600,
          // color: Color(0xA3B0AF1),
          child: SingleChildScrollView(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                //hmmm
                SizedBox(height: 30),
                DropdownButtonFormField<Professeur>(
                  value: selectedProfesseur,
                  hint: Text('${widget.Prof}'),
                  items: professeurList.map((prof) {
                    return DropdownMenuItem<Professeur>(
                      value: prof,
                      child: Text(prof.nom! ),
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedProfesseur = value;
                      selectedElem = null;
                      showProf = true;
                      updateElemList();
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'un Professeur",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2.2,
                      child: DropdownButtonFormField<filliere>(
                        value: selectedFil,
                        hint: Text('${widget.Fil}'),
                        items: filList.map((fil) {
                          return DropdownMenuItem<filliere>(
                            value: fil,
                            child: Text(fil.name.toUpperCase() ),
                          );
                        }).toList(),
                        onChanged: (value) async{
                          setState(() {
                            selectedFil = value;
                            selectedSem = null; // Reset the selected matière
                            // selectedGroup = null; // Reset the selected matière
                            selectedElem = null; // Reset the selected matière
                            elList2 = filterItemsByFil(selectedFil, elList!);
                            semestersList = extractUniqueSemesters(elList2);

                            print("Sems1${elList2}");

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
                      width: MediaQuery.of(context).size.width /2.7,
                      child: DropdownButtonFormField<int>(
                        value: selectedSem,
                        hint: Text('S${widget.SemN}'),
                        items: semestersList.map((sem) {
                          return DropdownMenuItem<int>(
                            value: sem,
                            child: Text("S$sem"),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            selectedSem = value;
                            // filteredItems = filterItemsBySemestre(selectedSem, items!);
                            // semestersList = extractUniqueSemesters(elList1);
                            // elList1 = filterItemsByFil(selectedFil, elList!);
                            elList1 = filterItemsBySemestre(selectedSem, elList2!);
                            // print("EL1${elList1} et ${elList}");
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Sélecte Semestre",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<Eles>(
                  value: selectedElem,
                  hint: Text('${widget.EM}'),
                  items: elList1.map((ele) {
                    return DropdownMenuItem<Eles>(
                        value: ele,
                        child: Text(ele.nameMat ?? '')
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedElem = value;
                      // selectedProfesseur = null; // Reset the selected matière
                      // updateProfesseurList();
                      showElem = true;

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

                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 1,
                      child: Container(
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
                              showGroup = true;
                              selectedGroup = null;
                              updateFilteredGroups(selectedTypeName,selectedProfesseur,selectedElem);
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
                    ),
                    SizedBox(width: 10),
                    if (selectedTypeName != null)
                      Expanded(flex: 1,
                        child: Container(
                          child: DropdownButtonFormField<String>(
                            value: selectedGroup,
                            hint: Text('G${getProfName(widget.GN)[2]}'),
                            items: filteredGroups.map((group) {
                              return DropdownMenuItem<String>(
                                value: group,//abdou
                                child: Text(selectedTypeName == "CM"?'G${getProfName(group)[2]}':selectedTypeName == "TP"?'TP${getProfName(group)[2]}':'TD${getProfName(group)[2]}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedGroup = value;
                                showGroup = true;
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Sélectionner un groupe",
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(width: 10),
                    Expanded(flex: 1,
                      child: Container(
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
                    ),
                  ],
                ),

                SizedBox(height: 10),
                TextFormField(
                  controller: _date,
                  // initialValue: widget.start!,
                  onChanged: (value) {

                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: widget.start!,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  // readOnly: true,
                  onTap: () {
                  setState(() {
                    selectTime(_date);
                    // _date.text = value;
                    showTime = true;
                  });

                  }
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




                SizedBox(height:20),
                ElevatedButton(
                  onPressed: () {
                      Navigator.of(context).pop();
                    setState(() {
                      fetchemploi();
                    });

                    String type = showType ? selectedTypeName : widget.TN;
                    num nbh = showNum ? selectedNbhValue : widget.TH;
                    int day = showdays ? _selectedNum : widget.day;
                    String elem = showElem ? selectedElem!.id : widget.EId;
                    String time = showTime ? _date.text:widget.start;
                    String prof = showProf ? selectedProfesseur!.id : widget.ProfId;
                    String gp = showGroup ? selectedGroup! : widget.GN;

                    print('${type}, NbH:${nbh}, startTime:${time}, day:${day}, elem:${elem}');
                    UpdatEmp(
                        widget.empId,
                        type,
                        nbh,
                        time,day,
                        elem,
                      gp
                    );

                    setState(() {
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              surfaceTintColor: Color(0xB0AFAFA3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("Alert de Succes"),
                                  Icon(Icons.fact_check_outlined,color: Colors.lightGreen,)
                                ],
                              ),
                              content: Text(
                                  "L\'emploi est modifier avec succes"),
                              actions: [
                                TextButton(
                                  child: Text("Ok"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    fetchemploi();

                                  },
                                ),

                              ],
                            );});
                    });


                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('L\'emploi est mis à jour avec succès.')),
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


  Future<void> UpdatEmp (id,String TN,num TH,String date,int days,String ElemId,String group) async {
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
      // "professeur": ProfId,
      "element": ElemId,
      "groupe": group,
    };



    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      print("Abd${response.statusCode}");
      if (response.statusCode == 200) {
        // Course creation was successful
        print("Emploi Updated successfully!");
        final responseData = json.decode(response.body);
        // print("Course ID: ${responseData['cours']['_id']}");
        // You can handle the response data as needed


        setState(() {
          Navigator.pop(context);
        });


      }
      else {

        // Course creation failed
        setState(() {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  surfaceTintColor: Color(0xB0AFAFA3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Alert d\'erreur"),
                      Icon(Icons.wrong_location_outlined,color: Colors.redAccent,)
                    ],
                  ),
                  content: Text(jsonDecode(response.body)["message"]),
                  actions: [
                    TextButton(
                      child: Text("Retourne"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),

                  ],
                );});

        });
        // var parse = jsonDecode(response.body);
        // errorMessage = parse["message"];
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
  // final num? SemNum;
  final String? startTime;
  final int dayNumero;
  final String? mat;
  final String professor;
  final String element;
  final String? jour;
  final int? SemNum;
  final String? fil;
  final String? finishTime;
  final String? enseignat;
  final String? groupe;
  final String? code;

  emploi( {
    required this.id,
    required this.type,
    required this.nbh,
    required this.startTime,
    required this.dayNumero,
    required this.mat,
    required this.SemNum,
    required this.element,
    required this.professor,
    this.jour,
    this.fil,
    this.groupe,
    this.code,
    // this.classe,
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
      SemNum: json['semestre'],
      element: json['element'],
      jour: json['jour'],
    mat: json['element_name'],
      fil: json['filiere_name'],
      finishTime: json['finishTime'],
      groupe: json['groupe'],
      code: json['code'],
      // SemNum: json['semestre'],
      enseignat: '${json['nom']} ${json['prenom']}',
      // classe: json['classe'],
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
      // "matiere": mat,
      "filiere": fil,
      "finishTime": finishTime,
      // "semestre": SemNum,
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

    print("Emplois: ${empData}");
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
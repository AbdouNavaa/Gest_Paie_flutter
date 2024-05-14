import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/auth/users.dart';
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
  List<Matiere> matiereList = [];
  List<filliere> filList = [];

  String getProfesseurIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    // awai
    final professeur = professeurList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>
        Professeur(id: '', nom:'',user: '',  ));
    print("Nom: ${professeurList}");
    return "${professeur.nom!} ${ professeur.prenom!}"; // Return the ID if found, otherwise an empty string

  }

  Elem getEls(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final element = elLis.firstWhere((g) => '${g.id}' == id, orElse: () => Elem(id: '', filId: '',  ));
    print( "Els:${element}");
    return element!; // Return the ID if found, otherwise an empty string

  }

  Elem getMatIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = elLis.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Elem(id: '', filId: ''));
    print(professeur.SemNum);
    return professeur; // Return the ID if found, otherwise an empty string

  }

  String getFilIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final fil = filList.firstWhere((f) => '${f.id}' == id, orElse: () =>filliere(id: '', name: '', description: '', niveau: ''));
    // print(id);
    return fil.name; // Return the ID if found, otherwise an empty string

  }

  bool showed = true;


  List<emploi> filterItemsBySem(int? ele,filliere? filiere, List<emploi> allItems) {
    if (ele == null) {
      return allItems;
    } else {
      print("ElID:${ele}");
      return allItems.where((emp) => emp.SemNum! == ele && emp.fil == filiere!.name).toList();
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
      String semester = "S${getMatIdFromName(emp.element).SemNum!}";
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
          return Column(
            children: [
              Expanded(flex: 3,
                child: Container(margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage("images/Design35.jpg",),fit: BoxFit.cover),
                      color: Colors.white
                  ),
                  padding: EdgeInsets.only(bottom: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // CircleAvatar(
                      //   // radius: 10 * 5,
                      //   backgroundColor: Colors.black,
                      //   child: Image.asset("assets/supnum.png",width: 90),
                      //   // backgroundImage: AssetImage('assets/user1.png'),
                      // ),
                      Container(margin: EdgeInsets.only(left: MediaQuery.of(context).size.width - 40),
                        child: InkWell(
                          child: Icon(Icons.arrow_forward_ios,size: 25,color: Colors.black,),
                          onTap: (){
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(flex: 8,
                child: Container(
                  height: 550,
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
                        Text('Emploi Infos',style: TextStyle(fontSize: 30,color: Colors.blueGrey),),
                        SizedBox(height: 50),
                        rowInfos('Professeur:',getProfesseurIdFromName(emp.professor!.toString()).capitalize!),
                
                        SizedBox(height: 25),
                        rowInfos('Matiere:',getMatIdFromName(emp.element).nameMat!.capitalize),
                
                        SizedBox(height: 25),
                        rowInfos('Semestre:',getMatIdFromName(emp.element).SemNum.toString()),
                
                        SizedBox(height: 25),
                        rowInfos('Filiere:',emp.fil!),
                
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
                                _selectedNum = emp.dayNumero;
                                _date.text = emp.startTime!;
                                setState(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => UpdateEmploiScreen(empId: emp.id, day: _selectedNum, start: _date.text,
                                      GN: '',
                                      EM: getMatIdFromName(emp.element).nameMat!,
                                      Prof:emp.enseignat!,
                                      Fil:emp.fil!,
                                        SemN: getMatIdFromName(emp.element).SemNum!,
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
                                backgroundColor: Colors.white,
                                  foregroundColor: Colors.green,
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
                                surfaceTintColor: Colors.white,
                                // side: BorderSide(color: Colors.black38),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 5,
                                padding: EdgeInsets.symmetric(horizontal: 35),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.redAccent,
                                textStyle: TextStyle(fontWeight: FontWeight.bold),
                                // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                
                            ),
                          ],
                        ),
                
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
  bool Tue = true;
  bool Wed = true;
  bool Thu = true;
  bool Fri = true;
  bool Sat = true;
  bool San = true;

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
                  Text("Liste des emplois",style: TextStyle(fontSize: 20),),
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
            showSearch?
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
                    getProfesseurIdFromName(emploi.professor).toLowerCase().contains(value.toLowerCase()) ||
                        getFilIdFromName(emploi.fil!).toLowerCase().contains(value.toLowerCase()) ||
                        // getEls(emploi.element)!.ProfTP!.toLowerCase().contains(value.toLowerCase()) ||
                        // getEls(emploi.element)!.ProfTP!.toLowerCase().contains(value.toLowerCase()) ||
                        getEls(emploi.element)!.nameMat!.toLowerCase().contains(value.toLowerCase()) ||
                        (days[emploi.dayNumero]).toLowerCase().contains(value.toLowerCase()) ||
                        (emploi.startTime!).toLowerCase().contains(value.toLowerCase()) ||
                        ("S${getMatIdFromName(emploi.element).SemNum!}").toLowerCase().contains(value.toLowerCase())
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
            ): SizedBox(height: 10,),

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
                                  Expanded(flex: 1,
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
                                  Expanded(flex: 1,
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

                                              SizedBox(child: Container(color: Colors.black38,width: 1,),height: 21,),
                                              TextButton(onPressed: (){
                                                setState(() {
                                                  Tue = true;
                                                  Mon = false;Wed = false;Thu = false;Fri = false;Sat = false;San = false;                                                });
                                              }, child: Text('Mar'),
                                                style: buildStyleFrom(Tue),
                                              ),

                                              SizedBox(child: Container(color: Colors.black38,width: 1,),height: 21,),
                                              TextButton(onPressed: (){
                                                setState(() {
                                                  Wed = true;
                                                  Mon = false;Tue = false;Thu = false;Fri = false;Sat = false;San = false;
                                                });
                                              }, child: Text('Mer'),
                                                style: buildStyleFrom(Wed),
                                              ),

                                              SizedBox(child: Container(color: Colors.black38,width: 1,),height: 21,),
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

                                              SizedBox(child: Container(color: Colors.black38,width: 1,),height: 21,),
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

                                              SizedBox(child: Container(color: Colors.black38,width: 1,),height: 21,),
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

                                              SizedBox(child: Container(color: Colors.black38,width: 1,),height: 21,),
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
                                      San?buildDayDataTable('Dimanch', filteredItems ?? items!): Container(),
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
        floatingActionButton: showFloat ?
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
            color: Colors.white,
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
            child: Icon(Icons.add, color: Colors.black,),
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
        // backgroundColor: bol ? Colors.blue.shade200 : Colors.white,
        foregroundColor: bol ? Colors.blueGrey : Colors.indigo,
        textStyle: TextStyle(fontWeight: bol ? FontWeight.bold : FontWeight.w500, fontSize: bol ? 17:15),
        padding: EdgeInsets.only(top: 15, bottom: 15),minimumSize: Size.fromWidth(80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(18),bottomEnd: Radius.circular(18)))
        // shape: BeveledRectangleBorder(borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(5),bottomEnd: Radius.circular(5)))
    );
  }



  Container buildDayDataTable(String day ,List<emploi> items) {
    List<DataRow> dayRows = [];

    if (!items.any((emp) => days[emp.dayNumero] == day)) {
      dayRows.add(
        DataRow(
          // color: MaterialStateColor.resolveWith((states) => Colors..shade100),
          cells: [
            DataCell(Text('IL n\' y a', style: TextStyle(color: Colors.black))),
            DataCell(Text('pas des', style: TextStyle(color: Colors.black))),
            DataCell(Text(' emplois', style: TextStyle(color: Colors.black))),
            DataCell(Text(' dans ', style: TextStyle(color: Colors.black))),
            DataCell(Text('ce', style: TextStyle(color: Colors.black))),
            DataCell(Text('jour', style: TextStyle(color: Colors.black))),
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
              DataCell(Container(width: 35,child: Text(emp.startTime!, style: TextStyle(color: Colors.black)))),
              DataCell(Text(getProfesseurIdFromName(emp.professor!.toString()).capitalize!, style: TextStyle(color: Colors.black))),

              DataCell(Text('${emp.mat!.capitalize}'),
                onTap: () =>_showCourseDetails(context, emp),
              ),
              DataCell(Container(width: 30, child: Text(getFilIdFromName(emp.fil!).toUpperCase()))),
              DataCell(Container(width: 25, child: Text('S${emp.SemNum!}'))),
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
    return Container(
      width: MediaQuery.of(context).size.width - 10,
      decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      child: DataTable(
        // showCheckboxColumn: true,
        // showBottomBorder: true,
        headingRowHeight: 50,
        columnSpacing: 15,
        dataRowHeight: 60,
        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white70),
        dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
        horizontalMargin: 10,

        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        columns: [
          DataColumn(label: Text('')),
          DataColumn(label: Text('')),
          DataColumn(label: Container(width: 80,
            child: Text(day,
              style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w500),
            ),
          ),),
          DataColumn(label: Text('')),
          DataColumn(label: Text('')),
          DataColumn(label: Text('')),
        ],
        rows: dayRows,
      ),
    );
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



}



class AddEmploiScreen extends StatefulWidget {
  @override
  _AddEmploiScreenState createState() => _AddEmploiScreenState();
}

class _AddEmploiScreenState extends State<AddEmploiScreen> {
  List<emploi>? filteredItems;


  bool isChanged =false;

  List<Professeur> professeurList = [];
  List<Eles> elList = [];
  List<Eles> elList2 = [];
  List<Eles> elList1 = [];
  List<filliere> filList = [];
  List<int> semestersList = [];


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

  }

  Future<void> updateElemList(selectedProfesseur,selectedElem) async {
    if (selectedProfesseur != null) {
      List<Eles>? fetchedProfesseurs = await fetchElsByProf(selectedProfesseur!.id);
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


  List<FormModel> formDataList = [];
  void addFormData() {
   setState(() {
     formDataList.add(FormModel());
     elList = [];
     elList1 = [];
     elList2 = [];
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: addFormData,
                      child: Text("Ajouter un formulaire"),
                      style: ElevatedButton.styleFrom(
                        surfaceTintColor: Colors.white,
                        // side: BorderSide(color: Colors.black38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                        // padding: EdgeInsets.symmetric(horizontal: 25),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),

                    ),
                    ElevatedButton(
                      onPressed: submitForms,
                      child: Text("Ajouter tous"),
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
                  ],
                ),

                // Button pour soumettre tous les formulaires
              ],
            )

          ),
        )
    );

    //Abdou
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
        DropdownButtonFormField<Professeur>(
          value: formData.selectedProfesseur,
          items: professeurList.map((prof) {
            return DropdownMenuItem<Professeur>(
              value: prof,
              child: Text(prof.nom! ),
            );
          }).toList(),
          onChanged: (value) async{
            setState(() {
              formData.selectedProfesseur = value;
              // formData.selectedElem = null;
              updateElemList(formData.selectedProfesseur,formData.selectedElem);
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "selection d'une Professeur",

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
                    semestersList = extractUniqueSemesters(formData.elList2);

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
                value: formData.selectedSem,
                hint: Text('Semestre'),
                items: semestersList.map((sem) {
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
          value: formData.selectedElem,
          items: formData.elList1.map((ele) {
            return DropdownMenuItem<Eles>(
                value: ele,
                child: Text(ele.nameMat ?? '')
            );
          }).toList(),
          onChanged: (value) async{
            setState(() {
              formData.selectedElem = value;
              // selectedProfesseur = null; // Reset the selected matière
              // updateProfesseurList();

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
          children: [
            Container(
              width: 147.5,
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
                value: formData._selectedNbh,
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
                    formData._selectedNbh = value!;
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
          controller: formData._date,
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Heure",
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,gapPadding: 1,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)))),
          // readOnly: true,
          onTap: () => selectTime(formData._date),
        ),


        SizedBox(height: 10),
        DropdownButtonFormField<int>(
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
            border: OutlineInputBorder(
              borderSide: BorderSide.none,gapPadding: 1,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        ),


      ],
    );
  }
  void submitForms() {
    for (int i = 0; i < formDataList.length; i++) {
      // Traitez chaque formulaire ici, par exemple, envoyez-le à votre API
      FormModel formData = formDataList[i];
      Navigator.pop(context);
      addEmp(formData._selectedType,formData._selectedNbh,formData._date.text,formData._selectedNum,
          formData.selectedFil!.id,formData.selectedElem!.id,formData.selectedProfesseur!.id);
      // Ajoutez votre logique pour traiter les données du formulaire
      // formData.name, formData.description, etc.
      // Envoyez les données à votre API, sauvegardez-les dans la base de données, etc.
    }
  }

  Future<void> addEmp(String type, num nbh,String date, int days, String filId, String ElemId,String ProfId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    final Uri uri = Uri.parse('http://192.168.43.73:5000/emploi');


    final Map<String, dynamic> emploiData = {
      "type": type,
      "nbh": nbh,
      "startTime": date,
      "dayNumero": days,
      "filiere": filId,
      "professeur": ProfId,
      "element": ElemId
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
                    "L\'emploi est ajouté avec succès"),

                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),

                ],

              );});
      });


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
  num _selectedNbh = 1.5;

  Professeur? selectedProfesseur;
  filliere? selectedFil;
  int? selectedSem;
  Eles? selectedElem;

  List<Eles> elList2 = [];
  List<Eles> elList1 = [];
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
  List<String>? ProCM;
  List<String>? ProTP;
  List<String>? ProTD;
  int? HCM;
  int? HTP;
  int? HTD;
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
    // this.ProCM,
    // this.ProTP,
    // this.ProTD,
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
      // ProCMId: json['professeurCM'] ?? [],
      // ProTPId: json['professeurTP'] ?? [],
      // ProTDId: json['professeurTD'] ?? [],
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
  final String Fil;
  final String EId;
  final String TN;
  final num TH;
  final num SemN;

  UpdateEmploiScreen({Key? key, required this.empId, required this.day, required this.start, required this.GN, required this.Prof,
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
  List<double> nbhValues = [1.5, 2];

  bool showType = false;
  bool showNum = false;
  bool showdays = false;
  bool showgroup = false;
  bool showElem = false;
  bool showTime = false;

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
                      updateElemList();
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'une Professeur",

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
                        hint: Text('${widget.SemN}'),
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
                            // showElem = true;
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
                    // setState(() {
                    //   Navigator.of(context).pop();
                    // });
                       // fetchemploi();

                    String type = showType ? selectedTypeName : widget.TN;
                    num nbh = showNum ? selectedNbhValue : widget.TH;
                    int day = showdays ? _selectedNum : widget.day;
                    String elem = showElem ? selectedElem!.id : widget.EId;
                    String time = showTime ? _date.text:widget.start;

                    print('${type}, NbH:${nbh}, startTime:${time}, day:${day}, elem:${elem}');
                    UpdatEmp(
                        widget.empId,
                        type,
                        nbh,
                        time,day,
                        elem,
                      selectedProfesseur!.id,
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


  Future<void> UpdatEmp (id,String TN,num TH,String date,int days,String ElemId,String ProfId) async {
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
      "professeur": ProfId,
      "element": ElemId
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
      // SemNum: json['semestre'],
      enseignat: json['nom'],
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
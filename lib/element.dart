import 'package:flutter/material.dart';
import 'package:gestion_payements/filliere.dart';
import 'package:gestion_payements/professeures.dart';
import 'package:get/get.dart';
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
  filliere? selectedFil;
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];

  Professeur? selectedProfesseurCM;
  Professeur? selectedProfesseurTP;
  Professeur? selectedProfesseurTD;

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
    final professeur = professeurs.firstWhere((prof) => '${prof.id}' == nom, orElse: () =>Professeur(id: ''));
    // print("ProfName:${professeur.nom}");
    return "${professeur.nom} ${professeur.prenom}"; // Return the ID if found, otherwise an empty string

  }
  String getFilIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final fil = filList.firstWhere((f) => '${f.id}' == id, orElse: () =>filliere(id: '', name: '', description: '', niveau: ''));
    print(id);
    return fil.name; // Return the ID if found, otherwise an empty string

  }
  String getMatNameFromId(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final fil = filteredItems!.firstWhere((f) => '${f.id}' == id, orElse: () =>Elem(id: 'id', filId: 'filId', MatId: 'MatId'));
    print(fil.nameMat);
    return fil.nameMat!; // Return the ID if found, otherwise an empty string

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
      print("fils:${filList}");
        fetchMatiere().then((data) {
          setState(() {
            matiereList = data; // Assigner la liste renvoyée par Groupesseur à items
            print("Mats${matiereList}");
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

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  // int _rowsPerPage = 5;


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
                     TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: Icon(Icons.arrow_back_ios,color: Colors.black,size: 20,)),
                  // SizedBox(width: 50,),
                  Text("Liste des Elements",style: TextStyle(fontSize: 20),)
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
                        (ele.nameMat)!.toLowerCase().contains(value.toLowerCase()) ||
                      (ele.fil!).toLowerCase().contains(value.toLowerCase()) ||
                      // (ele.ProfTP!).toLowerCase().contains(value.toLowerCase()) ||
                      // (ele.ProfTD!).toLowerCase().contains(value.toLowerCase())
                      ("S${ele.SemNum!}").toLowerCase().contains(value.toLowerCase())
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


                          //abou
                          return
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


                                  ),
                                ),
                                child: PaginatedDataTable(
                                  columnSpacing: 10,dataRowHeight: 55,
                                  rowsPerPage: _rowsPerPage,
                                  showFirstLastButtons: _rowsPerPage >= 10 ? true: false,
                                  availableRowsPerPage: [5, 7,9,10, 20],
                                  onRowsPerPageChanged: (value) {
                                    setState(() {
                                      _rowsPerPage = value ?? _rowsPerPage;
                                    });
                                  },
                                  columns: [
                                    DataColumn(label: Text('Sem')),
                                    DataColumn(label: Text('Matiere')),
                                    DataColumn(label: Text('Fillliere')),
                                    DataColumn(label: Text('H.CM')),
                                    DataColumn(label: Text('H.TP')),
                                    DataColumn(label: Text('H.TD')),
                                    DataColumn(label: Text('Action')),
                                  ],
                                  source: YourDataSource(filteredItems ?? items!,
                                    onTapCallback: (index) {
                                      _showElemDetails(context, (filteredItems ?? items!)[index],(filteredItems ?? items!)[index].id); // Appel de showMatDetails avec l'objet Matiere correspondant
                                      // onPressed: () =>_showElemDetails(context, ele,ele.id),// Disable button functionality

                                    },),
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

  Future<void> fetchData(Id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    try {
      final response = await http.get(
        Uri.parse('http://192.168.43.73:5000/element/$Id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        // List<dynamic> data = jsonResponse['element'];

        Map<String, dynamic> data = json.decode(response.body);
        showFetchedDataModal(context, data,Id);

      } else {
        print('Failed to fetch data. Error ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> _showElemDetails(BuildContext context, Elem ele,String EleID) {
    return showModalBottomSheet(
        context: context,backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return Container(
            height: 700,
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Element Infos", style: TextStyle(fontSize: 25),),
                      Spacer(),
                      InkWell(
                        child: Icon(Icons.close),
                        onTap: (){
                          setState(() {
                            fetchElems().then((data) {
                              setState(() {
                                filteredItems = data; // Assigner la liste renvoyée par Professeur à items
                              });

                            }).catchError((error) {
                              print('Erreur: $error');
                            });
                          });
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
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

                      SizedBox(width: 10,),
                      Text('Filière:',
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
                  SizedBox(height: 15),
                  Container(width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text('Matiere:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),),
                      
                          SizedBox(width: 10,),
                          Text(
                            '${ele.nameMat.toString().capitalize }',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Professeur(e/s) de CM:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),

                        for (var prof in ele.ProCMId!)
                          Text(
                            '-${getProfIdFromName(prof).capitalize }',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Professeur(e/s) de TP:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                        for (var prof in ele.ProTPId!)
                          Text(
                            '-${getProfIdFromName(prof).capitalize }',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Professeur(e/s) de TD:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                        for (var prof in ele.ProTDId!)
                          Text(
                            '-${getProfIdFromName(prof).capitalize }',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15,),
                  Row(
                    children: [
                      Text('NBH du CM:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text(
                        '${ele.HCM }',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 15,),
                  Row(
                    children: [
                      Text('NBH du TP:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text(
                        '${ele.HTP }',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 15,),
                  Row(
                    children: [
                      Text('NBH du TD:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text(
                        '${ele.HTD }',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // _selectedNum = emp.dayNumero;
                          // _date.text = ele.fil!;
                          print(ele.id);
                          setState(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    UpdateElemScreen(eleId: ele.id,  Sem:ele.SemNum, Mat: ele.nameMat!,
                                      // ProCM: ele.ProfCM!, ProTP: ele.ProfTP!, ProTD: ele.ProfTD!,
                                      CredCM: ele.HCM!, CredTP: ele.HTP!,CredTD: ele.HTD!,
                                      filId: ele.filId, MatId: ele.MatId, fil: ele.fil!,
                                      ProfCMId: ele.ProCMId, ProfTPId: ele.ProTPId,ProfTDId: ele.ProTDId,
                                    )));
                          });
                          // selectedMat = emp.mat!;


                        },// Disable button functionality

                        child: Text('Modifier'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.only(left: 20,right: 20),
                          foregroundColor: Colors.lightGreen,
                          // backgroundColor: Colors.white,
                          // side: BorderSide(color: Colors.black,),

                            backgroundColor: Color(0xfffff1),
                            side: BorderSide(color: Colors.black12,),   elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                        ),

                      ),
                      TextButton(
                          // print(ele.id);
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

                                  content: Container(
                                    height: 450,
                                    width: MediaQuery.of(context).size.width,
                                    // padding: const EdgeInsets.all(25.0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        // mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(height: 30),
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
                                              fillColor: Colors.white,
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
                                              fillColor: Colors.white,
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
                                              fillColor: Colors.white,
                                              hintText: "selection d'un  Professeur de TD", // Update the hintText
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

                                              // fetchElems();



                                               addProfToElem(ele.id,selectedProfesseurCM?.id!,selectedProfesseurTP?.id!,selectedProfesseurTD?.id!,);

                                              setState(() {
                                                Navigator.pop(context);
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


                                    ),
                                  ),

                                );
                              });
                        }, // Disable button functionality

                        child: Text('Ajouter Prof'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.only(left: 20,right: 20),
                          foregroundColor: Color(0xff0fb2ea),
                          // foregroundColor: Colors.lightGreen,
                          backgroundColor: Color(0xfffff1),
                          side: BorderSide(color: Colors.black12,),
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
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.only(left: 20,right: 20),
                          foregroundColor: Colors.redAccent,

                            backgroundColor: Color(0xfffff1),
                            side: BorderSide(color: Colors.black12,), // side: BorderSide(color: Colors.black,),
                          elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
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
  void showFetchedDataModal(BuildContext context, Map<String, dynamic> data,String filId ) {
    showModalBottomSheet(
        context: context,backgroundColor: Colors.white,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Element Infos", style: TextStyle(fontSize: 25),),
                    Spacer(),
                    InkWell(
                      child: Icon(Icons.close),
                      onTap: (){
                        setState(() {
                          fetchElems().then((data) {
                            setState(() {
                              filteredItems = data; // Assigner la liste renvoyée par Professeur à items
                            });

                          }).catchError((error) {
                            print('Erreur: $error');
                          });
                        });
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
                SizedBox(height: 20),
                // for (var ele in data)
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
                    Text(
                      'S${data['element']['semestre']}.'.toUpperCase(),
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),

                  ],
                ),

                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Filiere:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                    SizedBox(width: 10,),
                    Text(
                      '${getFilIdFromName(data['element']['filiere'])}'.toUpperCase(),
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),

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
                    Text(
                      '${getMatNameFromId(data['element']['matiere'])!}'.toUpperCase(),
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),

                  ],
                ),

                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Heures CM:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                    SizedBox(width: 10,),
                    Text(
                      '${data['element']['heuresCM']}.'.toUpperCase(),
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),

                  ],
                ),

                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Heures TP:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                    SizedBox(width: 10,),
                    Text(
                      '${data['element']['heuresTP']}.'.toUpperCase(),
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),

                  ],
                ),

                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Heures TD:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                    SizedBox(width: 10,),
                    Text(
                      '${data['element']['heuresTD']}.'.toUpperCase(),
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),

                  ],
                ),


              ],
            ),
          );
        }


    );
  }


  Future<void> addProfToElem( id,String? ProfCM,String? ProfTP,String? ProfTD) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    final url = 'http://192.168.43.73:5000/element/$id/professeurs';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> body ={};

    if( ProfCM != null &&ProfTP != null &&ProfTD != null ){
      body = {
        'professeurCM': ProfCM,
        'professeurTP': ProfTP,
        'professeurTD': ProfTD,
      };
    }
    else if(ProfCM != null &&ProfTP == null &&ProfTD == null){
      body = {
        'professeurCM': ProfCM,
      };
    }
    else if(ProfCM != null &&ProfTP != null &&ProfTD == null){
      body = {
        'professeurCM': ProfCM,
        'professeurTP': ProfTP,
      };
    }
    else if(ProfCM != null &&ProfTP == null &&ProfTD != null){
      body = {
        'professeurCM': ProfCM,
        'professeurTD': ProfTD,
      };
    }

    else if(ProfCM == null &&ProfTP != null &&ProfTD != null){
      body = {
        'professeurTP': ProfTP,
        'professeurTD': ProfTD,
      };
    }
    else if(ProfCM == null &&ProfTP != null &&ProfTD == null){
      body = {
        'professeurTP': ProfTP,
      };
    }


    else if(ProfCM == null &&ProfTP == null &&ProfTD != null){
      body = {
        'professeurTD': ProfTD,
      };
    }
    final response = await http.patch(Uri.parse(url), headers: headers,
      body: json.encode(body),
    );

    print("Status${response.statusCode}");
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
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
                    "L\'element est ajouté avec succès"),

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

      print("L\'element est ajouté avec succès");


    } else {
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
                    Text("Alerte d\'erreur"),
                    Icon(Icons.wrong_location_outlined,color: Colors.redAccent,)
                  ],
                ),
                content: Text(
                    "L\'emploi n\'est pas ajouter"),
              );});

      });

      print("SomeThing Went Wrong");
      print('Failed to add matiere to professeus. Status Code: ${response.statusCode}');
    }
  }




}

class YourDataSource extends DataTableSource {
  List<Elem> _items;
  Function(int) onTapCallback; // La fonction prendra un index comme paramètre

  YourDataSource(this._items, {required this.onTapCallback});

  @override
  DataRow? getRow(int index) {

    final item = _items[index];
    return DataRow(cells: [
      DataCell(Container(width: 20, child: Text("S${item.SemNum!}"))),
      DataCell(Container(width: 80,
          child: Text(item.nameMat!.capitalize!))),

      DataCell(Container(width: 30, child: Text(item.fil!.toUpperCase()))),
      DataCell(Container(width: 30, child: Text(item.HCM!.toString()))),

      DataCell(Container(width: 30, child: Text(item.HTP!.toString()))),
      DataCell(Container(width: 30, child: Text(item.HTD!.toString()))),


      DataCell(
        IconButton(
          icon: Icon(Icons.more_horiz),
          onPressed: () {
            onTapCallback(index); // Appel de la fonction de callback avec l'index
          },
        ),
      ),
    ]);
  }

  @override
  int get rowCount => _items.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}


class Elem {
  String id;
  int? SemNum;
  String filId;
  String MatId;
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
  String? nameM;
  int? taux;
  // String? mat;
  String? fil;
  // String? ProfCM;
  // String? ProfTP;
  // String? ProfTD;

  Elem({
    required this.id,
    required this.filId,
    required this.MatId,
    this.ProCMId,
    this.ProTPId,
    this.ProTDId,
    // this.ProCM,
    // this.ProTP,
    // this.ProTD,
    this.SemNum,
    this.code,
    this.nameMat,
    this.nameM,
    // this.mat,
    this.fil,
    this.taux,
    this.HCM,
    this.HTP,
    this.HTD,
    // this.ProfCM,
    // this.ProfTP,
    // this.ProfTD,
  });

  factory Elem.fromJson(Map<String, dynamic> json) {
    return Elem(
      id: json['_id'],
      SemNum: json['semestre'],
      filId: json['filiere'],
      MatId: json['matiere'],
      HCM: json['heuresCM'],
      HTP: json['heuresTP'],
      HTD: json['heuresTD'],
      code: json['code'],
      taux: json['taux'],
      nameMat: json['matiere_mane'],
      nameM: json['name'],
      fil: json['filiere_name'],
      // mat: json['matiere'],
      ProCMId: json['professeurCM'] ?? [],
      ProTPId: json['professeurTP'] ?? [],
      ProTDId: json['professeurTD'] ?? [],
      // ProCM: (json['info']['CM'] as List<dynamic>).map((e) => e.toString()).toList(),
      // ProTP: (json['info']['TP'] as List<dynamic>).map((e) => e.toString()).toList(),
      // ProTD: (json['info']['TD'] as List<dynamic>).map((e) => e.toString()).toList(),

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
    List<Elem> elems = semData.map((item) {
      return Elem.fromJson(item);
    }).toList();

    // print(categories);
    return elems;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Elem');
  }
}

class AddElemScreen extends StatefulWidget {
  @override
  _AddElemScreenState createState() => _AddElemScreenState();
}

class _AddElemScreenState extends State<AddElemScreen> {
  List<Elem>? filteredItems;


  String selectedTypeName = 'CM'; // Nom de type sélectionné par défaut
  int HCM = 0;
  int HTP = 0;
  int HTD = 0;
  int semNum = 1;
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
  List<filliere> filList = [];
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
    fetchfilliere().then((data) {
      setState(() {
        filList = data; // Assigner la liste renvoyée par emploiesseur à items
        print('Hello fil');
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

    fetchCategories();
  }
  void AddElem (String matId,int? sem,String filId,String? PCM,String? PTP,String? PTD,int? HCM,int? HTP,int? HTD,) async {

    // Check if the prix parameter is provided, otherwise use the default value of 100
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    Map<String, dynamic> body ={};
    body = {
      "matiere": matId,
      "semestre": sem,
      "filiere": filId,
      "professeurCM": PCM ?? '',
      "professeurTP": PTP ?? '',
      "professeurTD": PTD ?? '',
      "heuresCM": HCM ?? 0,
      "heuresTP": HTP ?? 0,
      "heuresTD": HTD ?? 0
    };

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
                    "L\'element est ajouté avec succès"),

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

      print("L\'element est ajouté avec succès");


    } else {
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
                    Text("Alerte d\'erreur"),
                    Icon(Icons.wrong_location_outlined,color: Colors.redAccent,)
                  ],
                ),
                content: Text(
                    "L\'emploi n\'est pas ajouter"),
              );});

      });

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
                surfaceTintColor: Color(0xB0AFAFA3),
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
          child: SingleChildScrollView(scrollDirection: Axis.vertical,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),


                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 170,
                      child: DropdownButtonFormField<filliere>(
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Color(0xA3B0AF1),
                          fillColor: Colors.white,
                          hintText: 'Filières',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        value: selectedFil,
                        items: filList.map((fil) {
                          return DropdownMenuItem<filliere>(
                            child: Text(fil.name),
                            value: fil,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFil = value ;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 130,
                      child: DropdownButtonFormField<int>(
                        disabledHint: Text('Semestre'),
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Color(0xA3B0AF1),
                          fillColor: Colors.white,
                          hintText: 'Semestre',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        // value: semNum,
                        items: [
                          DropdownMenuItem<int>(
                            child: Text('S1'),
                            value: 1,
                          ),
                          DropdownMenuItem<int>(
                            child: Text('S2'),
                            value: 2,
                          ),
                          DropdownMenuItem<int>(
                            child: Text('S3'),
                            value: 3,
                          ),
                          DropdownMenuItem<int>(
                            child: Text('S4'),
                            value: 4,
                          ),
                          DropdownMenuItem<int>(
                            child: Text('S5'),
                            value: 5,
                          ),
                          DropdownMenuItem<int>(
                            child: Text('S6'),
                            value: 6,
                          ),

                        ],
                        onChanged: (value) {
                          setState(() {
                            semNum = value ?? 1;
                          });
                        },
                      ),
                    ),
                  ],
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
                    fillColor: Colors.white,
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
                      child: Container(
                          width: MediaQuery.of(context).size.width -100,
                          child: Text('${(mat.name)} ')),
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
                    fillColor: Colors.white,
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
                    fillColor: Colors.white,
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
                    fillColor: Colors.white,
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
                    fillColor: Colors.white,
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
                          // fillColor: Color(0xA3B0AF1),
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        hint:Text('HCM'),
                        // value: HCM,
                        items: nbhValues.map((nbhValue) {
                          return DropdownMenuItem<int>(
                            child: Text(nbhValue.toString()),
                            value: nbhValue,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            HCM = value ?? 0;
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
                          // fillColor: Color(0xA3B0AF1),
                          fillColor: Colors.white,
                          hintText: 'HTP',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        hint:Text('HTP'),
                        // value: HTP,
                        items: nbhValues.map((nbhValue) {
                          return DropdownMenuItem<int>(
                            child: Text(nbhValue.toString()),
                            value: nbhValue,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            HTP = value ?? 0;
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
                          // fillColor: Color(0xA3B0AF1),
                          fillColor: Colors.white,
                          hintText: 'HTD',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        hint:Text('HTD'),
                        // value: HTD,
                        items: nbhValues.map((nbhValue) {
                          return DropdownMenuItem<int>(
                            child: Text(nbhValue.toString()),
                            value: nbhValue,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            HTD = value ?? 0;
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
                    int CCM = selectedProfesseurCM != null ? HCM: 0;
                    String PrTP = selectedProfesseurTP != null ? selectedProfesseurTP!.id: '';
                    int CTP = selectedProfesseurTP != null ? HTP: 0;
                    String PrTD = selectedProfesseurTD != null ? selectedProfesseurTD!.id: '';
                    int CTD = selectedProfesseurTD != null ? HTD: 0;
                    AddElem(selectedMat!.id!,semNum,selectedFil!.id, PrCM,PrTP,PrTD,CCM,CTP,CTD);
                    // AddElem(int.parse(_numero.text),date, selectedFil!.id!);

                    // Addfilliere(_name.text, _desc.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Le filliere a été ajouter avec succès.')),
                    );
                    setState(() {
                      Navigator.pop(context);
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


}

class UpdateElemScreen extends StatefulWidget {
  final String eleId;
  final String filId;
  final String fil;
  final String MatId;
  // final String ProfCMId;
  // final String ProfTPId;
  // final String ProfTDId;
  final int? Sem;
  final String Mat;
  // final String ProCM;
  // final String ProTP;
  // final String ProTD;
  List<dynamic>? ProfCMId; // Le type exact des éléments peut être spécifié ici
  List<dynamic>? ProfTPId;
  List<dynamic>? ProfTDId;
  final int CredCM;
  final int CredTP;
  final int CredTD;
  UpdateElemScreen({Key? key, required this.eleId, required this.CredTD, required this.Sem, required this.Mat,required this.fil,
    // required this.ProCM, required this.ProTP, required this.ProTD,
    required this.CredCM, required this.CredTP, required this.filId, required this.MatId,
    required this.ProfCMId, required this.ProfTPId, required this.ProfTDId
  }) : super(key: key);

  @override
  _UpdateElemScreenState createState() => _UpdateElemScreenState();
}

class _UpdateElemScreenState extends State<UpdateElemScreen> {
  List<Elem>? filteredItems;


  String selectedTypeName = 'CM'; // Nom de type sélectionné par défaut
  int HCM = 0;
  int HTP = 0;
  int HTD = 0;
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
  List<filliere> filList = [];
  int semNum = 1;
  filliere? selectedFil;
  List<Category> categories = [];
  List<Matiere> matiereList = [];
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

    HCM = widget.CredCM;
    HTP = widget.CredTP;
    HTD = widget.CredTD;
    fetchCategories();
    // fetchPros();
  }

  Future<void> UpdateElem (String id,String matId,String filId,List<dynamic> PCM,List<dynamic> PTP,List<dynamic> PTD,int sem,int? HCM,int? HTP,int? HTD) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    Map<String, dynamic> body ={};
    body = {
      "matiere": matId,
      //"categorie": CategId,
      "semestre": sem,
      "filiere": filId,
      "professeurCM": PCM ?? '',
      "professeurTP": PTP ?? '',
      "professeurTD": PTD ?? '',
      "heuresCM": HCM ?? 0,
      "heuresTP": HTP ?? 0,
      "heuresTD": HTD ?? 0
    };

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

      print('ModStat${response.statusCode}');
      if (response.statusCode == 201) {
        // Course creation was successful
        print("Element Updated successfully!");
        final responseData = json.decode(response.body);
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
                      "L\'element est ajouté avec succès"),

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

        print("L\'element est modifié avec succès");


      } else {
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
                      Text("Alerte d\'erreur"),
                      Icon(Icons.wrong_location_outlined,color: Colors.redAccent,)
                    ],
                  ),
                  content: Text(jsonDecode(response.body)["message"]),
                );});

        });
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
  bool showFil = false;
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
            Text("Modifier un Element", style: TextStyle(fontSize: 25),),
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
          height: 500,
          // color: Color(0xA3B0AF1),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 170,
                    child: DropdownButtonFormField<filliere>(
                      decoration: InputDecoration(
                        filled: true,
                        // fillColor: Color(0xA3B0AF1),
                        fillColor: Colors.white,
                        hintText: widget.fil,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: selectedFil,
                      items: filList.map((fil) {
                        return DropdownMenuItem<filliere>(
                          child: Text(fil.name),
                          value: fil,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFil = value ;
                          showFil =true;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 130,
                    child: DropdownButtonFormField<int>(
                      // disabledHint: Text('S${widget.Sem}'),
                      decoration: InputDecoration(
                        filled: true,
                        // fillColor: Color(0xA3B0AF1),
                        fillColor: Colors.white,
                        hintText: 'S${widget.Sem}',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      // value: semNum,
                      items: [
                        DropdownMenuItem<int>(
                          child: Text('S1'),
                          value: 1,
                        ),
                        DropdownMenuItem<int>(
                          child: Text('S2'),
                          value: 2,
                        ),
                        DropdownMenuItem<int>(
                          child: Text('S3'),
                          value: 3,
                        ),
                        DropdownMenuItem<int>(
                          child: Text('S4'),
                          value: 4,
                        ),
                        DropdownMenuItem<int>(
                          child: Text('S5'),
                          value: 5,
                        ),
                        DropdownMenuItem<int>(
                          child: Text('S6'),
                          value: 6,
                        ),

                      ],
                      onChanged: (value) {
                        setState(() {
                          semNum = value ?? 1;
                          showSem = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<Matiere>(
                decoration: InputDecoration(
                  filled: true,
                  // fillColor: Color(0xA3B0AF1),
                  fillColor: Colors.white,
                  hintText: widget.Mat,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,gapPadding: 1,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                value: selectedMat,
                items: matieres.map((mat) {
                  return DropdownMenuItem<Matiere>(
                    child: Text(mat.name),
                    value: mat,
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMat = value ;
                    showmat =true;
                  });
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        filled: true,
                        // fillColor: Color(0xA3B0AF1),
                        fillColor: Colors.white,
                        hintText: 'HCM',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: HCM,
                      hint: Text(widget.CredCM.toString()),
                      items: nbhValues.map((nbhValue) {
                        return DropdownMenuItem<int>(
                          child: Text(nbhValue.toString()),
                          value: nbhValue,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          HCM = value ?? 0;
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
                        // fillColor: Color(0xA3B0AF1),
                        fillColor: Colors.white,
                        hintText: 'HTP',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: HTP,
                      hint: Text(widget.CredTP.toString()),
                      items: nbhValues.map((nbhValue) {
                        return DropdownMenuItem<int>(
                          child: Text(nbhValue.toString()),
                          value: nbhValue,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          HTP = value ?? 0;
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
                        hintText: 'HTD',
                        // fillColor: Color(0xA3B0AF1),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      value: HTD,
                      hint: Text(widget.CredTD.toString()),
                      items: nbhValues.map((nbhValue) {
                        return DropdownMenuItem<int>(
                          child: Text(nbhValue.toString()),
                          value: nbhValue,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          HTD = value ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),
              ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
                  String PrCM = selectedProfesseurCM != null ? selectedProfesseurCM!.id: '';
                  int CCM = showPCM? (selectedProfesseurCM != null ? HCM :0): HCM;

                  String PrTP = selectedProfesseurTP != null ? selectedProfesseurTP!.id: '';

                  // int CTP = selectedProfesseurTP != null ? HTP: 0;
                  int CTP = showPTP? (selectedProfesseurTP != null ? HTP :0): HTP;
                  String PrTD = selectedProfesseurTD != null ? selectedProfesseurTD!.id: '';
                  // int CTD = selectedProfesseurTD != null ? HTD: 0;
                  int CTD = showPTP? (selectedProfesseurTD != null ? HTD :0): HTD;
                  // print("CategId:${selectedCategory!.id!}");

                  String mat = showmat ? selectedMat!.id! : widget.MatId;
                  int sem = showSem ? semNum! : widget.Sem!;
                  String fil = showFil ? selectedFil!.id! : widget.filId!;

                  UpdateElem(widget.eleId,mat,fil,widget.ProfCMId!,widget.ProfTPId!,widget.ProfTDId!, sem,CCM,CTP,CTD);
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


}



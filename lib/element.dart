import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/filliere.dart';
import 'package:gestion_payements/professeures.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import '../matieres.dart';
import 'Cours.dart';
import 'auth/emploi.dart';
import 'categories.dart';
import 'home_screen.dart';





class Elements extends StatefulWidget {
  Elements({Key ? key}) : super(key: key);

  @override
  _ElementsState createState() => _ElementsState();
}

class _ElementsState extends State<Elements> {

  // Future<List<Element>>? futureGroup;

  List<Elem>? filteredItems;



  Category? selectedCateg; // initialiser le type sélectionné à null

  // Future<Map<String, dynamic>> types =await  fetchProfessorInfo() ;
  // _id.text = items![index].name;
  Category? selectedCategory;
  List<Category> categories =  [];
  List<filliere> filList = [];
  filliere? selectedFil;
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];

  List<Professeur> selectedProfesseursCM = [];
  List<Professeur> selectedProfesseursTP = [];
  List<Professeur> selectedProfesseursTD = [];
  List<String> Itemvalues = [];
  List<String> CMvalues = [];
  List<String> TPvalues = [];
  List<String> TDvalues = [];


  MultiSelectController _controller = MultiSelectController();

  bool showFloat = false;
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

  String getProfId(String elements) {
    List<dynamic> ids = elements.split('-'); // Sépare la chaîne en une liste d'IDs
    print(ids);
    print(ids[0]);
    return ids[0];
  }
  String getMatNameFromId(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final fil = filteredItems!.firstWhere((f) => '${f.id}' == id, orElse: () =>Elem(id: 'id', filId: 'filId', ));
    print(fil.nameMat);
    return fil.nameMat!; // Return the ID if found, otherwise an empty string

  }

  Future<void> selectDate(TextEditingController controller) async {
    DateTime? selectedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
        builder: (context, child){
        return CalenderStyle(child: child!,);
        }
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
        elLis = data; // Assigner la liste renvoyée par Groupesseur à items
        print("ElList${elLis}");
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchfilliere().then((data) {
      setState(() {
        filList = data; // Assigner la liste renvoyée par Groupesseur à items
      print("fils:${filList}");
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
  TextEditingController _searchController = TextEditingController();

  bool showSearch  = false;

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  // int _rowsPerPage = 5;

  // filliere? selectedFil;
  Elem? selectedELem;
  List<int> semestersList = [];
  int? selectedSem ;
  List<Elem> elList1 = [];
  // List<Semestre> SemList = [];
  // List<Semestre> SemList1 = [];
  List<Elem> elLis = [];
  // List<filliere> filList = [];
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
                          List<Elem>? Els = await fetchElems();

                          // print("Els List: ${Els.length}");
                          setState(() {
                            // Implémentez la logique de filtrage ici
                            // Par exemple, filtrez les emploiesseurs dont le name ou le préname contient la valeur saisie
                            filteredItems = Els.where((ele) =>
                            (ele.nameMat)!.toLowerCase().contains(value.toLowerCase()) ||
                                (ele.code!).toLowerCase().contains(value.toLowerCase()) ||
                                (ele.filName!).toLowerCase().contains(value.toLowerCase()) ||
                                // (var prof in ele) ?
                                // (ele.ProfTP!).toLowerCase().contains(value.toLowerCase()) ||
                                // (ele.ProfTD!).toLowerCase().contains(value.toLowerCase())
                                ("S${ele.SemNum!}").toLowerCase().contains(value.toLowerCase())
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
                      )):
                  Text("Liste des Matieres",style: TextStyle(fontSize: 20),),
                  showSearch?SizedBox():SizedBox(width: 80,),
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


                        print("ElemListe ${elList1}");
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
                          filteredItems = filterItemsBySem(selectedSem,selectedFil, elLis!);
                          print("Emps:${filteredItems}, ${filteredItems}, ${selectedSem} ${selectedFil!.name}");
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
                              child: Container(width: MediaQuery.of(context).size.width -5,
                                decoration: BoxDecoration(
                                  // color: widget.courses.length > 0 ? Colors.white10:Colors.white,
                                  //   color: Colors.black87,
                                    borderRadius: BorderRadius.all(Radius.circular(5))
                                ),
                                child: Theme(
                                  data: ThemeData(
                                    // Modifiez les couleurs de DataTable ici
                                    dataTableTheme: DataTableThemeData(
                                      dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white), // Couleur des lignes de données
                                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black87), // Couleur de la ligne d'en-tête
                                      dataTextStyle: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,fontSize: 13 // Set header text color
                                      ),
                                      headingTextStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,fontSize: 13 // Set header text color
                                      ),
                                    ),
                                  ),
                                  child: PaginatedDataTable(
                                    columnSpacing: 10,dataRowHeight: 55,
                                    rowsPerPage: _rowsPerPage,
                                    showFirstLastButtons: _rowsPerPage >= 10 ? true: false,
                                    availableRowsPerPage: [5, 7,9,10, 20],
                                    // header: Text('hekko'),

                                    onRowsPerPageChanged: (value) {
                                      setState(() {
                                        _rowsPerPage = value ?? _rowsPerPage;
                                      });
                                    },
                                    columns: [
                                      buildDataColumn('Sem'),
                                      buildDataColumn('Code'),
                                      buildDataColumn('Matiere'),
                                      buildDataColumn('Fillliere'),
                                      // buildDataColumn('H.CM'),
                                      // buildDataColumn('H.TP'),
                                      // buildDataColumn('H.TD'),
                                      buildDataColumn('Détails'),
                                    ],
                                    source: YourDataSource(filteredItems ?? items!,
                                      onTapCallback: (index) {
                                        _showElemDetails(context, (filteredItems ?? items!)[index],(filteredItems ?? items!)[index].id); // Appel de showMatDetails avec l'objet Matiere correspondant
                                        // onPressed: () =>_showElemDetails(context, ele,ele.id),// Disable button functionality

                                      },),
                                  ),
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
        floatingActionButton: showFloat?
        Container(
          width: 300,

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
                    Navigator.pop(context);
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
            // border: Border.all(color: Colors.black38,width: 2)
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

  DataColumn buildDataColumn(val) => DataColumn(label: Text(val,style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white, // Set header text color
  ),));
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
        Uri url = Uri.parse('http://192.168.43.73:5000/element/upload/all');
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
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return Container(
            height: 700,
            decoration: BoxDecoration(borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              color: Colors.white,
            ),
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
                      Text(ele.filName!.toUpperCase(),
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
                        Text('CMs :',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                        for (var prof in ele.groupeCM!)
                          Text(
                            'G${prof.toString().split('-')[2]}-${getProfIdFromName(prof.toString().split('-')[0]).capitalize }',
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
                        Text('TPs :',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                        for (var prof in ele.groupeTP!)
                          Text(
                            'TP${prof.toString().split('-')[2]}-${getProfIdFromName(prof.toString().split('-')[0]).capitalize }',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // ElemProfs(context,'Professeur(e/s) de CM:' ,ele.ProCMId!),
                  SizedBox(height: 15),
                  Container(width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TDs :',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                        for (var prof in ele.groupeTD!)
                          Text(
                            'TD${prof.toString().split('-')[2]}-${getProfIdFromName(prof.toString().split('-')[0]).capitalize }',
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
                  NbH('NBH du CM:',ele.HCM),
                  SizedBox(height: 15,),
                  NbH('NBH du TP:',ele.HTP),
                  SizedBox(height: 15,),
                  NbH('NBH du TD:',ele.HTD),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            // _selectedNum = emp.dayNumero;
                            // _date.text = ele.fil!;
                            Navigator.pop(context);
                            print(ele.id);
                            setState(() {

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      UpdateElemScreen(eleId: ele.id,  Sem:ele.SemNum, Mat: ele.nameMat!,
                                        // ProCM: ele.ProfCM!, ProTP: ele.ProfTP!, ProTD: ele.ProfTD!,
                                        CredCM: ele.HCM!, CredTP: ele.HTP!,CredTD: ele.HTD!,
                                        filId: ele.filId, fil: ele.filName!,
                                        ProfCMId: ele.ProCMId, ProfTPId: ele.ProTPId,ProfTDId: ele.ProTDId,
                                      )));

                            });
                          },// Disable button functionality

                          child: Text('Modifier'),
                          style: ElevatedButton.styleFrom(
                            surfaceTintColor: Colors.white,
                            // side: BorderSide(color: Colors.black38),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 5,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            textStyle: TextStyle(fontWeight: FontWeight.bold),
                            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),

                        ),
                      ),
                      Expanded(flex: 1,
                        child: ElevatedButton(
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
                                                  // MultiSelectDropDown(
                                            //   // showClearIcon: true,
                                            //   controller: _controller,
                                            //   onOptionSelected: (options) {
                                            //     debugPrint(options.toString());
                                            //   },
                                            //   options: const <ValueItem>[
                                            //     ValueItem(label: 'Option 1', value: '1'),
                                            //     ValueItem(label: 'Option 2', value: '2'),
                                            //     ValueItem(label: 'Option 3', value: '3'),
                                            //     ValueItem(label: 'Option 4', value: '4'),
                                            //     ValueItem(label: 'Option 5', value: '5'),
                                            //     ValueItem(label: 'Option 6', value: '6'),
                                            //   ],
                                            //   maxItems: 2,
                                            //   disabledOptions: const [ValueItem(label: 'Option 1', value: '1')],
                                            //   selectionType: SelectionType.multi,
                                            //   chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                                            //   dropdownHeight: 300,
                                            //   optionTextStyle: const TextStyle(fontSize: 16),
                                            //   selectedOptionIcon: const Icon(Icons.check_circle),
                                            // ),
                                            // SizedBox(height: 20),

                                      MultiSelectDialogField<Professeur>(
                                      initialValue: selectedProfesseursCM,
                                        selectedColor: Colors.green,
                                        backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white), // Couleur des lignes de données
                                          barrierColor: MaterialStateColor.resolveWith((states) => Colors.black38), // Couleur des lignes de données
                                        items: professeurs.map((professeur) {
                                          // Itemvalues.add(professeur.id);
                                          return MultiSelectItem<Professeur>(professeur, '${professeur.nom!} ${ professeur.prenom!}');
                                        }).toList(),
                                        onConfirm: (values) {
                                          setState(() {
                                            selectedProfesseursCM = values;
                                            CMvalues.clear(); // Effacer les anciennes valeurs
                                            CMvalues.addAll(values.map((professeur) => professeur.id).toList()); // Ajouter les nouvelles valeurs sélectionnées
                                            print('ItemVal${CMvalues}');
                                          });
                                        },
                                        chipDisplay: MultiSelectChipDisplay<Professeur>(),
                                        searchHint: 'Sélectionnez un ou plusieurs professeurs de CM',
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white!),color: Colors.white,
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                              MultiSelectDialogField<Professeur>(
                                              initialValue: selectedProfesseursTP,
                                              selectedColor: Colors.green,
                                              backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white), // Couleur des lignes de données
                                              barrierColor: MaterialStateColor.resolveWith((states) => Colors.black38), // Couleur des lignes de données
                                              items: professeurs.map((professeur) {
                                                // Itemvalues.add(professeur.id);
                                                return MultiSelectItem<Professeur>(professeur, professeur.nom!);
                                              }).toList(),
                                              onConfirm: (values) {
                                                setState(() {
                                                  selectedProfesseursTP = values;
                                                  TPvalues.clear(); // Effacer les anciennes valeurs
                                                  TPvalues.addAll(values.map((professeur) => professeur.id).toList()); // Ajouter les nouvelles valeurs sélectionnées
                                                  print('ItemVal${TPvalues}');
                                                });
                                              },
                                              chipDisplay: MultiSelectChipDisplay<Professeur>(),
                                              searchHint: 'Sélectionnez un ou plusieurs professeurs de CM',
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.white!),color: Colors.white,
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                           MultiSelectDialogField<Professeur>(
                                              initialValue: selectedProfesseursTD,
                                              selectedColor: Colors.green,
                                              backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white), // Couleur des lignes de données
                                              barrierColor: MaterialStateColor.resolveWith((states) => Colors.black38), // Couleur des lignes de données
                                              items: professeurs.map((professeur) {
                                                // Itemvalues.add(professeur.id);
                                                return MultiSelectItem<Professeur>(professeur, professeur.nom!);
                                              }).toList(),
                                              onConfirm: (values) {
                                                setState(() {
                                                  selectedProfesseursTD = values;
                                                  TDvalues.clear(); // Effacer les anciennes valeurs
                                                  TDvalues.addAll(values.map((professeur) => professeur.id).toList()); // Ajouter les nouvelles valeurs sélectionnées
                                                  print('ItemVal${TDvalues}');
                                                });
                                              },
                                              chipDisplay: MultiSelectChipDisplay<Professeur>(),
                                              searchHint: 'Sélectionnez un ou plusieurs professeurs de CM',
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.white!),color: Colors.white,
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                              ),
                                            ),
                                            SizedBox(height: 30),
                                            ElevatedButton(
                                              onPressed: () async{
                                                Navigator.of(context).pop();

                                                // fetchElems();



                                                 addProfToElem(ele.id,CMvalues!,TPvalues,TDvalues);

                                                setState(() {
                                                  Navigator.pop(context);
                                                   fetchProfs();
                                                });
                                              },
                                              child: Text("Ajouter"),

                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(0xff0fb2ea),
                                                foregroundColor: Colors.white,
                                                // elevation: 2,
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
                      ),
                    ],
                  ),
  
                  // SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 1,
                        child: ElevatedButton(
                            // print(ele.id);
                          onPressed: (){
                            AjoutGroup(context, ele);
                          }, // Disable button functionality

                          child: Text('Ajouter Groupe'),
                          style: ElevatedButton.styleFrom(
                            surfaceTintColor: Colors.white,
                            // side: BorderSide(color: Colors.black38),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 5,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            textStyle: TextStyle(fontWeight: FontWeight.bold),
                            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),


                        ),
                      ),
                      Expanded(flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                          surfaceTintColor: Colors.white,backgroundColor: Colors.white,
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
                          style: ElevatedButton.styleFrom(
                            surfaceTintColor: Colors.white,
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


  String selectedProfesseurCM = '';
  String selectedProfesseurTP = '';
  String selectedProfesseurTD = '';


  Future<dynamic> AjoutGroup(BuildContext context, Elem ele) {
    // Variables pour stocker les valeurs des champs de texte
    TextEditingController cmController = TextEditingController();
    TextEditingController tpTdController = TextEditingController();

    // Variables pour stocker le nombre de groupes
    int cmGroupCount = 0;
    int tpTdGroupCount = 0;

    List<Widget> dropdownCMs = [];
    List<Widget> dropdownTPs = [];
    List<Widget> dropdownTDs = [];

    // Map pour stocker les sélections de groupes pour chaque professeur
    Map<String, List<int>> cmSelections = {};
    Map<String, List<int>> tpSelections = {};
    Map<String, List<int>> tdSelections = {};

    // Fonction pour générer les cases à cocher pour les CM
    void generateCMCheckboxes() {
      dropdownCMs.clear();
      for (var prof in ele.ProCMId!) {
        String profId = prof['_id'];
        for(var g in ele.groupeCM!)
        if(g.contains(profId))
        cmSelections[profId] = [int.parse(g.split('-')[2])];

        dropdownCMs.add(
          Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(flex: 1,
                    child: DropdownButtonFormField<String>(
                      items: ele.ProCMId!.map((prof) {
                        return DropdownMenuItem<String>(
                          value: prof['_id'],
                          child: Text(prof['user']['nom'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          for(var g in ele.groupeCM!){
                            if(g.contains(profId))
                          cmSelections[profId] = [int.parse(g.split('-')[2])];
                          print("Dah${g.split('-')[2]}");
                          print("Dah${cmSelections[profId]}");}
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Professeur CM",
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(flex: 1,
                    child: Container(height: 65,
                      child: SingleChildScrollView(scrollDirection: Axis.vertical,
                        child: MultiSelectDialogField(
                          items: List.generate(cmGroupCount, (index) {
                            return MultiSelectItem<int>(index + 1, 'G${index + 1}');
                          }),
                          title: Text("Groupes CM"),
                          selectedColor: Colors.green,dialogHeight: 200,backgroundColor: Colors.white,
                          buttonText: Text("Groupes CM"),
                          onConfirm: (results) {
                            setState(() {
                              cmSelections[profId] = List<int>.from(results);
                            });
                          },
                          initialValue: cmSelections[profId]!,
                          decoration: BoxDecoration(shape: BoxShape.rectangle,
                            border: Border.all(color: Colors.white!),color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,)
            ],
          ),
        );
      }
    }

    // Fonction pour générer les cases à cocher pour les TP/TD
    // void generateTPCheckboxes() {
    //   dropdownTPs.clear();
    //   dropdownTDs.clear();
    //   for (var prof in ele.ProTPId!) {
    //     String profId = prof['_id'];
    //     tpSelections[profId] = [];
    //
    //     List<Widget> checkboxes = [];
    //     for (int i = 0; i < tpTdGroupCount; i++) {
    //       int groupNumber = i + 1;
    //       checkboxes.add(
    //         Row(
    //           children: [
    //             Checkbox(
    //               value: tpSelections[profId]!.contains(groupNumber),
    //               onChanged: (value) {
    //                 setState(() {
    //                   if (value == true) {
    //                     tpSelections[profId]!.add(groupNumber);
    //                   } else {
    //                     tpSelections[profId]!.remove(groupNumber);
    //                   }
    //                 });
    //               },
    //             ),
    //             Text('TP$groupNumber'),
    //           ],
    //         ),
    //       );
    //     }
    //     dropdownTPs.add(
    //       Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           DropdownButtonFormField<String>(
    //             items: ele.ProTPId!.map((category) {
    //               return DropdownMenuItem<String>(
    //                 value: category['_id'],
    //                 child: Text(category['user']['nom'] ?? ''),
    //               );
    //             }).toList(),
    //             onChanged: (value) {
    //               setState(() {
    //                 tpSelections[profId] = [];
    //               });
    //             },
    //             decoration: InputDecoration(
    //               filled: true,
    //               fillColor: Colors.white,
    //               hintText: "Sélection d'un Professeur TP",
    //               border: OutlineInputBorder(
    //                 borderSide: BorderSide.none,
    //                 borderRadius: BorderRadius.all(Radius.circular(10.0)),
    //               ),
    //             ),
    //           ),
    //           Row(children: checkboxes),
    //         ],
    //       ),
    //     );
    //   }
    //
    //   for (var prof in ele.ProTDId!) {
    //     String profId = prof['_id'];
    //     tdSelections[profId] = [];
    //
    //     List<Widget> checkboxes = [];
    //     for (int i = 0; i < tpTdGroupCount; i++) {
    //       int groupNumber = i + 1;
    //       checkboxes.add(
    //         Row(
    //           children: [
    //             Checkbox(
    //               value: tdSelections[profId]!.contains(groupNumber),
    //               onChanged: (value) {
    //                 setState(() {
    //                   if (value == true) {
    //                     tdSelections[profId]!.add(groupNumber);
    //                   } else {
    //                     tdSelections[profId]!.remove(groupNumber);
    //                   }
    //                 });
    //               },
    //             ),
    //             Text('TD$groupNumber'),
    //           ],
    //         ),
    //       );
    //     }
    //     dropdownTDs.add(
    //       Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           DropdownButtonFormField<String>(
    //             items: ele.ProTDId!.map((category) {
    //               return DropdownMenuItem<String>(
    //                 value: category['_id'],
    //                 child: Text(category['user']['nom'] ?? ''),
    //               );
    //             }).toList(),
    //             onChanged: (value) {
    //               setState(() {
    //                 tdSelections[profId] = [];
    //               });
    //             },
    //             decoration: InputDecoration(
    //               filled: true,
    //               fillColor: Colors.white,
    //               hintText: "Sélection d'un Professeur TD",
    //               border: OutlineInputBorder(
    //                 borderSide: BorderSide.none,
    //                 borderRadius: BorderRadius.all(Radius.circular(10.0)),
    //               ),
    //             ),
    //           ),
    //           Row(children: checkboxes),
    //         ],
    //       ),
    //     );
    //   }
    // }
    void generateTPCheckboxes() {
      dropdownTPs.clear();
      dropdownTDs.clear();
      for (var prof in ele.ProTPId!) {
        String profId = prof['_id'];
        for(var g in ele.groupeTP!)
          if(g.contains(profId))
            tpSelections[profId] = [int.parse(g.split('-')[2])];

        dropdownTPs.add(
          Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(flex: 1,
                    child:
                    DropdownButtonFormField<String>(
                      items: ele.ProTPId!.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['_id'],
                          child: Text(category['user']['nom'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          // tpSelections[profId] = [];
                          for(var g in ele.groupeTP!){
                            if(g.contains(profId))
                              tpSelections[profId] = [int.parse(g.split('-')[2])];
                            print("TPP${g.split('-')[2]}");
                            print("TPP${tpSelections[profId]}");}                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Sélection d'un Professeur TP",
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),

                  ),
                  SizedBox(width: 10,),
                  Expanded(flex: 1,
                    child: Container(height: 60,
                      child: SingleChildScrollView(scrollDirection: Axis.vertical,
                        child: MultiSelectDialogField(
                          items: List.generate(tpTdGroupCount, (index) {
                            return MultiSelectItem<int>(index + 1, 'TP${index + 1}');
                          }),
                          title: Text("Groupes TP"),
                          selectedColor: Colors.green,dialogHeight: 200,backgroundColor: Colors.white,
                          buttonText: Text("Groupes TP"),
                          onConfirm: (results) {
                            setState(() {
                              tpSelections[profId] = List<int>.from(results);
                            });
                          },
                          initialValue: tpSelections[profId]!,
                          decoration: BoxDecoration(shape: BoxShape.rectangle,
                            border: Border.all(color: Colors.white!),color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,)
            ],
          ),
        );
      }
      for (var prof in ele.ProTDId!) {
        String profId = prof['_id'];
        // tdSelections[profId] = [];
        for(var g in ele.groupeTD!)
          if(g.contains(profId))
            tdSelections[profId] = [int.parse(g.split('-')[2])];
        dropdownTDs.add(
          Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(flex: 1,
                    child:
                    DropdownButtonFormField<String>(
                      items: ele.ProTDId!.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['_id'],
                          child: Text(category['user']['nom'] ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          // tdSelections[profId] = [];
                          for(var g in ele.groupeTD!){
                            if(g.contains(profId))
                              tdSelections[profId] = [int.parse(g.split('-')[2])];
                            print("TDD${g.split('-')[2]}");
                            print("TDD${tdSelections[profId]}");}
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Sélection d'un Professeur TP",
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),

                  ),
                  SizedBox(width: 10,),
                  Expanded(flex: 1,
                    child: Container(height: 60,
                      child: SingleChildScrollView(scrollDirection: Axis.vertical,
                        child: MultiSelectDialogField(
                          items: List.generate(tpTdGroupCount, (index) {
                            return MultiSelectItem<int>(index + 1, 'TD${index + 1}');
                          }),
                          title: Text("Groupes TD"),
                          selectedColor: Colors.green,dialogHeight: 200,backgroundColor: Colors.white,
                          buttonText: Text("Groupes TD"),
                          onConfirm: (results) {
                            setState(() {
                              tdSelections[profId] = List<int>.from(results);
                            });
                          },
                          initialValue: tdSelections[profId]!,
                          decoration: BoxDecoration(shape: BoxShape.rectangle,
                            border: Border.all(color: Colors.white!),color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,)
            ],
          ),
        );
      }
    }

    // Fonction pour générer le JSON à partir des sélections
    Map<String, dynamic> generateJson() {
      List<Map<String, dynamic>> cmJson = [];
      cmSelections.forEach((profId, groups) {
        if (groups.isNotEmpty) {
          cmJson.add({
            'groupe': groups,
            'professeur': profId,
          });
        }
      });

      List<Map<String, dynamic>> tpJson = [];
      tpSelections.forEach((profId, groups) {
        if (groups.isNotEmpty) {
          tpJson.add({
            'groupe': groups,
            'professeur': profId,
          });
        }
      });

      List<Map<String, dynamic>> tdJson = [];
      tdSelections.forEach((profId, groups) {
        if (groups.isNotEmpty) {
          tdJson.add({
            'groupe': groups,
            'professeur': profId,
          });
        }
      });

      return {
        'CM': cmJson,
        'TP': tpJson,
        'TD': tdJson,
      };
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.only(top: 50),
          surfaceTintColor: Color(0xB0AFAFA3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ajouter un Groupe", style: TextStyle(fontSize: 25)),
              Spacer(),
              InkWell(
                child: Icon(Icons.close),
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
          content: Container(
            height: 600,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: cmController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "NBG CM",
                            focusedBorder: NBGBorder(),
                            border: NBGBorder(),
                            enabledBorder: NBGBorder(),
                            disabledBorder: NBGBorder(),

                          ),
                          onChanged: (value) {
                            setState(() {
                              cmGroupCount = int.tryParse(value) ?? 0;
                              generateCMCheckboxes();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 40),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: tpTdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "NBG TP/TD",
                            focusedBorder: NBGBorder(),
                            border: NBGBorder(),
                            enabledBorder: NBGBorder(),
                            disabledBorder: NBGBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              tpTdGroupCount = int.tryParse(value) ?? 0;
                              generateTPCheckboxes();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                  SizedBox(height: 30),
                  Container(child: Text('Goupes CM',style: TextStyle(color: Colors.blueGrey,fontSize: 20)),),
                  Divider(height: 10),
                  SizedBox(height: 10),
                  ...dropdownCMs, // Ajouter dynamiquement les DropdownButtonFormField CM
                  SizedBox(height: 20),
                  Container(child: Text('Goupes TP',style: TextStyle(color: Colors.blueGrey,fontSize: 20)),),
                  Divider(height: 10),
                  SizedBox(height: 10),
                  ...dropdownTPs, // Ajouter dynamiquement les DropdownButtonFormField TP
                  SizedBox(height: 20),
                  Container(child: Text('Goupes TD',style: TextStyle(color: Colors.blueGrey,fontSize: 20)),),
                  Divider(height: 10),
                  SizedBox(height: 10),
                  ...dropdownTDs, // Ajouter dynamiquement les DropdownButtonFormField TD
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      Map<String, dynamic> jsonPayload = generateJson();
                      // Vous pouvez maintenant utiliser jsonPayload pour envoyer la requête
                      // Exemple :
                      // await sendRequest(jsonPayload);

                      // generateJson()
                      Navigator.of(context).pop();
                      print('Abb${jsonPayload}');
                      addGroupToElem(ele.id,generateJson());

                      // addProfToElem avec les valeurs appropriées pour CMvalues, TPvalues, TDvalues
                      setState(() {
                        Navigator.pop(context);
                        fetchProfs();
                      });
                    },
                    child: Text("Ajouter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff0fb2ea),
                      foregroundColor: Colors.white,
                      minimumSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.width / 7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  OutlineInputBorder NBGBorder() => OutlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: .2), gapPadding: 1, borderRadius: BorderRadius.all(Radius.circular(10.0)),);

  Row NbH(lab,val) {
    return Row(
                  children: [
                    Text(lab,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text(
                      '${val }',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  ],
                );
  }

  Container ElemProfs(BuildContext context,label,  ele) {
    return Container(width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),
                      for (var prof in ele)
                        Text(
                          '-${getProfIdFromName(prof['_id']).capitalize }',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
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


  Future<void> addProfToElem( id, ProfCM, ProfTP, ProfTD) async {
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
  Future<void> addGroupToElem( id, Map<String, dynamic> body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    final url = 'http://192.168.43.73:5000/element/$id/affectation';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await http.post(Uri.parse(url), headers: headers,
      body: json.encode(body),
    );

    print("Status${response.statusCode}");
    if (response.statusCode == 201) {
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
                content: Text(jsonDecode(response.body)["message"]),

              );});

      });

      print("SomeThing Went Wrong");
      print('Failed to add matiere to professeus. Status Code: ${response.statusCode}');
    }
  }

  List<Elem> filterItemsBySem(int? ele,filliere? filiere, List<Elem> allItems) {
    if (ele == null) {
      return allItems;
    } else {
      print("ElID:${ele}");
      return allItems.where((emp) => emp.SemNum! == ele && emp.filName!.toLowerCase() == filiere!.name!.toLowerCase()).toList();
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


}

class YourDataSource extends DataTableSource {
  List<Elem> _items;
  Function(int) onTapCallback; // La fonction prendra un index comme paramètre

  YourDataSource(this._items, {required this.onTapCallback});

  @override
  DataRow? getRow(int index) {

    final item = _items[index];
    return DataRow(cells: [
      DataCell(Container(width: 15, child: Text("S${item.SemNum!}"))),
      DataCell(Container(width: 45,
          child: Text(item.code!.split('-')[1].toUpperCase()!))),
      DataCell(Container(width: 70,
          child: Text(item.nameMat!.capitalize!))),

      DataCell(Container(width: 30, child: Text(item.filName!.toUpperCase()))),
      // DataCell(Container(width: 15, child: Text(item.HCM!.toString()))),

      // DataCell(Container(width: 15, child: Text(item.HTP!.toString()))),
      // DataCell(Container(width: 15, child: Text(item.HTD!.toString()))),


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

class MultiSelct extends StatefulWidget {
  final List<String> items;
  const MultiSelct({super.key, required this.items});

  @override
  State<MultiSelct> createState() => _MultiSelctState();
}

class _MultiSelctState extends State<MultiSelct> {
  final List<String> _selectedItems = [];

  void _temChange(String ){}
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


class Elem {
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
  List<String>? ProCM;
  List<String>? ProTP;
  List<String>? ProTD;
  num? HCM;
  num? HTP;
  num? HTD;
  String? code;
  String? nameMat;
  // String? ProfCM;
  // String? ProfTP;
  // String? ProfTD;

  Elem({
    required this.id,
    required this.filId,
    this.ProCMId,
    this.ProTPId,
    this.ProTDId,
    this.groupeCM,
    this.groupeTP,
    this.groupeTD,
    this.SemNum,
    this.code,
    this.nameMat,
    // this.mat,
    this.filName,
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
      filId: json['filiere']['_id'],
      HCM: json['heuresCM'],
      HTP: json['heuresTP'],
      HTD: json['heuresTD'],
      code: json['code'],
      nameMat: json['name'],
      filName: json['filiere']['name'],
      // mat: json['matiere'],
      ProCMId: json['professeurCM'] ?? [],
      ProTPId: json['professeurTP'] ?? [],
      ProTDId: json['professeurTD'] ?? [],

      groupeCM: json['CM'] ?? [],
      groupeTP: json['TP'] ?? [],
      groupeTD: json['TD'] ?? [],
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

  Elem? selectedMat;
  Professeur? selectedProfesseurCM;

  List<Professeur> selectedProfesseursCM = [];
  List<Professeur> selectedProfesseursTP = [];
  List<Professeur> selectedProfesseursTD = [];
  List<String> Itemvalues = [];
  List<String> CMvalues = [];
  List<String> TPvalues = [];
  List<String> TDvalues = [];

  List<Professeur> professeurs = [];
  DateTime? selectedDateTime;

  bool isChanged =false;



  Category? selectedCategory;
  TextEditingController _name = TextEditingController();
  filliere? selectedFil;
  List<Category> categories = [];
  List<Elem> matiereList = [];
  List<filliere> filList = [];
  @override
  void initState() {
    super.initState();
    fetchCategory().then((data) {
      setState(() {
        categories = data; // Assigner la liste renvoyée par emploiesseur à items
      });
      fetchProfs().then((data) {
        setState(() {
          professeurs = data; // Assigner la liste renvoyée par emploiesseur à items
          print('ProfList ${professeurs}');
        });
      }).catchError((error) {
        print('Erreur: $error');
      });

      fetchElems().then((data) {
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
        print('Hello fil');
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

    fetchCategories();
  }
  void AddElem (String catId,String matId,int? sem,String filId, PCM, PTP, PTD,int? HCM,int? HTP,int? HTD,) async {

    // Check if the prix parameter is provided, otherwise use the default value of 100
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    Map<String, dynamic> body ={};
    body = {
      "categorie": catId,
      "name": matId,
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
      List<Elem> fetchedmatieres = await fetchMatieresByCategory(selectedCategory!.id);
      setState(() {
        matiereList = fetchedmatieres;
      });
    } else {
      List<Elem> fetchedmatieres = [];
      // List<Elem> fetchedmatieres = await fetchElems();
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
          height: 600,
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
                      // updateMatiereList(); // Update the list of matières based on the selected category
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
                SizedBox(height: 10),
                MultiSelectDialogField<Professeur>(
                  initialValue: selectedProfesseursCM,
                  selectedColor: Colors.green,
                  backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white), // Couleur des lignes de données
                  barrierColor: MaterialStateColor.resolveWith((states) => Colors.black38), // Couleur des lignes de données
                  items: professeurs.map((professeur) {
                    // Itemvalues.add(professeur.id);
                    return MultiSelectItem<Professeur>(professeur, professeur.nom!);
                  }).toList(),
                  onConfirm: (values) {
                    setState(() {
                      selectedProfesseursCM = values;
                      CMvalues.clear(); // Effacer les anciennes valeurs
                      CMvalues.addAll(values.map((professeur) => professeur.id).toList()); // Ajouter les nouvelles valeurs sélectionnées
                      print('ItemVal${CMvalues}');
                    });
                  },
                  chipDisplay: MultiSelectChipDisplay<Professeur>(),
                  searchHint: 'Sélectionnez un ou plusieurs professeurs de CM',
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white!),color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                SizedBox(height: 10),
                MultiSelectDialogField<Professeur>(
                  initialValue: selectedProfesseursTP,
                  selectedColor: Colors.green,
                  backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white), // Couleur des lignes de données
                  barrierColor: MaterialStateColor.resolveWith((states) => Colors.black38), // Couleur des lignes de données
                  items: professeurs.map((professeur) {
                    // Itemvalues.add(professeur.id);
                    return MultiSelectItem<Professeur>(professeur, professeur.nom!);
                  }).toList(),
                  onConfirm: (values) {
                    setState(() {
                      selectedProfesseursTP = values;
                      TPvalues.clear(); // Effacer les anciennes valeurs
                      TPvalues.addAll(values.map((professeur) => professeur.id).toList()); // Ajouter les nouvelles valeurs sélectionnées
                      print('ItemVal${TPvalues}');
                    });
                  },
                  chipDisplay: MultiSelectChipDisplay<Professeur>(),
                  searchHint: 'Sélectionnez un ou plusieurs professeurs de CM',
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white!),color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                SizedBox(height: 10),
                MultiSelectDialogField<Professeur>(
                  initialValue: selectedProfesseursTD,
                  selectedColor: Colors.green,
                  backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white), // Couleur des lignes de données
                  barrierColor: MaterialStateColor.resolveWith((states) => Colors.black38), // Couleur des lignes de données
                  items: professeurs.map((professeur) {
                    // Itemvalues.add(professeur.id);
                    return MultiSelectItem<Professeur>(professeur, professeur.nom!);
                  }).toList(),
                  onConfirm: (values) {
                    setState(() {
                      selectedProfesseursTD = values;
                      TDvalues.clear(); // Effacer les anciennes valeurs
                      TDvalues.addAll(values.map((professeur) => professeur.id).toList()); // Ajouter les nouvelles valeurs sélectionnées
                      print('ItemVal${TDvalues}');
                    });
                  },
                  chipDisplay: MultiSelectChipDisplay<Professeur>(),
                  searchHint: 'Sélectionnez un ou plusieurs professeurs de CM',
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white!),color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
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


                    // Pass the selected types to addCoursToProfesseur method
                    int CCM = selectedProfesseursCM.length != 0 ? HCM: 0;
                    int CTP = selectedProfesseursTP.length != 0 ? HTP: 0;
                    int CTD = selectedProfesseursTD.length != 0 ? HTD: 0;
                    AddElem(selectedCategory!.id,_name.text,semNum,selectedFil!.id,CMvalues!,TPvalues,TDvalues,CCM,CTP,CTD);

                    setState(() {
                      Navigator.pop(context);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('L\'element a été ajouter avec succès.')),
                    );
                    setState(() {
                      Navigator.of(context).pop();
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
          ),
        )
    );

  }


}

class UpdateElemScreen extends StatefulWidget {
  final String eleId;
  final String filId;
  final String fil;
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
  final num CredCM;
  final num CredTP;
  final num CredTD;
  UpdateElemScreen({Key? key, required this.eleId, required this.CredTD, required this.Sem, required this.Mat,required this.fil,
    // required this.ProCM, required this.ProTP, required this.ProTD,
    required this.CredCM, required this.CredTP, required this.filId,
    required this.ProfCMId, required this.ProfTPId, required this.ProfTDId
  }) : super(key: key);

  @override
  _UpdateElemScreenState createState() => _UpdateElemScreenState();
}

class _UpdateElemScreenState extends State<UpdateElemScreen> {
  List<Elem>? filteredItems;


  String selectedTypeName = 'CM'; // Nom de type sélectionné par défaut
  num HCM = 0;
  num HTP = 0;
  num HTD = 0;
  List<num> nbhValues = [0];

  Elem? selectedMat;
  Professeur? selectedProfesseurCM;
  Professeur? selectedProfesseurTP;
  Professeur? selectedProfesseurTD;
  List<Professeur> professeurs = [];
  List<Elem> matieres = [];
  DateTime? selectedDateTime;

  bool isChanged =false;



  List<Professeur> professeurList = [];
  Category? selectedCategory;
  List<filliere> filList = [];
  int semNum = 1;
  filliere? selectedFil;
  List<Category> categories = [];
  List<Elem> matiereList = [];
  @override
  void initState() {
    super.initState();
    fetchCategory().then((data) {
      setState(() {
        categories = data; // Assigner la liste renvoyée par emploiesseur à items
      });

      fetchElems().then((data) {
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

    nbhValues.contains(widget.CredCM)? HCM = widget.CredCM: nbhValues.add(widget.CredCM);
    nbhValues.contains(widget.CredTP)? HTP = widget.CredTP: nbhValues.add(widget.CredTP);
    nbhValues.contains(widget.CredTD)? HTD = widget.CredTD: nbhValues.add(widget.CredTD);
    HCM = widget.CredCM;
    HTP = widget.CredTP;
    HTD = widget.CredTD;
    fetchCategories();
    // fetchPros();
  }

  Future<void> UpdateElem (String id,String filId,List<dynamic> PCM,
      List<dynamic> PTP,List<dynamic> PTD,int sem,num? HCM,num? HTP,num? HTD) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    Map<String, dynamic> body ={};
    body = {
      // "matiere": matId,
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
        insetPadding: EdgeInsets.only(top: 180,),
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
              SizedBox(height: 30),
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
              DropdownButtonFormField<Elem>(
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
                  return DropdownMenuItem<Elem>(
                    child: Text(mat.nameMat!),
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

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(flex: 1,
                    child: DropdownButtonFormField<num>(
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
                        return DropdownMenuItem<num>(
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
                  Expanded(flex: 1,
                    child: DropdownButtonFormField<num>(
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
                        return DropdownMenuItem<num>(
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
                  Expanded(flex: 1,
                    child: DropdownButtonFormField<num>(
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
                        return DropdownMenuItem<num>(
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
                  num CCM = showPCM? (selectedProfesseurCM != null ? HCM :0): HCM;

                  num CTP = showPTP? (selectedProfesseurTP != null ? HTP :0): HTP;
                  num CTD = showPTP? (selectedProfesseurTD != null ? HTD :0): HTD;

                  int sem = showSem ? semNum! : widget.Sem!;
                  String fil = showFil ? selectedFil!.id! : widget.filId!;

                  UpdateElem(widget.eleId,fil,widget.ProfCMId!,widget.ProfTPId!,widget.ProfTDId!, sem,CCM,CTP,CTD);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('L\'element a été ajouter avec succès.')),
                  );
                  setState(() {
                    Navigator.pop(context);
                    // fetchElems();
                  });
                },
                child: Text("Ajouter"),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff0fb2ea),
                  foregroundColor: Colors.white,
                  elevation: 2,
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



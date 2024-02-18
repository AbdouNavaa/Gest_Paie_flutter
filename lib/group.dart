import 'package:flutter/material.dart';
import 'package:gestion_payements/filliere.dart';
import 'package:gestion_payements/semestre.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

 
import '../matieres.dart';
import 'Cours.dart';
import 'categories.dart';





class Groups extends StatefulWidget {
  Groups({Key ? key}) : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {

  Future<List<Group>>? futureGroup;

  List<Group>? filteredItems;

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


  Future<void> updateSemList() async {
    if (selectedFil != null) {
      List<Semestre> fetchedProfesseurs =  getFilSem(selectedFil!.id);
      setState(() {
        semLis = fetchedProfesseurs;
        print(semLis);
        // selectedProfesseur = null;
      });
    } else {
      List<Semestre> fetchedProfesseurs = [];
      setState(() {
        semLis = fetchedProfesseurs;
      });
    }
  }

  void DeleteGroups(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/group' +"/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchGroup().then((data) {
        setState(() {
          filteredItems = data; // Assigner la liste renvoyée par Groupesseur à items
        });
      }).catchError((error) {
        print('Erreur: $error');
      });

    }

  }
  String getMatIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = matiereList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Matiere(id: '', name: '',  categorieId: '', categorie_name: '', code: '',));
    print(professeur.name);
    return professeur.name; // Return the ID if found, otherwise an empty string

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
  String getMatIdFromNames(String elements) {
    List<String> ids = elements.split(', '); // Sépare la chaîne en une liste d'IDs

    // Traitez chaque ID individuellement ici
    String result = '';
    for (var id in ids) {
      result += getMatIdFromName(id) + '   '; // Traitez chaque ID avec getMatIdFromName
    }

    print(result);
    return result.isNotEmpty ? result.substring(0, result.length - 2) : '';
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
    fetchGroup().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Groupesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchfilliere().then((data) {
      setState(() {
        filList = data; // Assigner la liste renvoyée par Groupesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchMatiere().then((data) {
      setState(() {
        matiereList = data; // Assigner la liste renvoyée par Groupesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    // fetchSemestre().then((data) {
    //   setState(() {
    //     semLis = data; // Assigner la liste renvoyée par Groupesseur à items
    //   });
    // }).catchError((error) {
    //   print('Erreur: $error');
    // });
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

  TextEditingController _name = TextEditingController();
  TextEditingController _sem = TextEditingController();
  TextEditingController _isOne = TextEditingController();
  String _selectedGN = "A";
  String _selectedOne = "YES";


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
                  }, child: Icon(Icons.arrow_back_ios,color: Colors.black,)),
                  SizedBox(width: 50,),
                  Text("Liste de Groups",style: TextStyle(fontSize: 25),)
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
                  List<Group> Groupes = await fetchGroup();

                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les emploiesseurs dont le name ou le préname contient la valeur saisie
                    filteredItems = Groupes!.where((grp) =>
                        (grp.type!).toLowerCase().contains(value.toLowerCase()) ||
                            getFilIdFromName(grp.filliereId!).toLowerCase().contains(value.toLowerCase()) 
                        // (grp.isOne!).toLowerCase().contains(value.toLowerCase()) ||
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
                  child: FutureBuilder<List<Group>>(
                    future: fetchGroup(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<Group>? items = snapshot.data;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
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
                                headingRowColor: MaterialStateColor.resolveWith((states) => Colors.lightBlueAccent.shade100), // Couleur de la ligne d'en-tête
                                // border: TableBorder.all(color: Colors.black12, width: 2),
                                headingTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Set header text color
                                ),
                                // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xff0fb2ea)), // Set row background color
                                columns: [
                                  DataColumn(label: Text('Nom')),
                                  DataColumn(label: Text('Filliere')),
                                  DataColumn(label: Text('Semestre')),
                                  DataColumn(label: Text('Action')),
                                  // DataColumn(label: Text('Descrition')),
                                ],
                                rows: [
                                  for (var grp in filteredItems!)
                                    DataRow(
                                        cells: [
                                          DataCell(Container(child: Text('${grp.type}-${grp.numero}')),

                                            // onTap:() => _showcategDetails(context, categ)
                                          ),
                                          DataCell(Container(child:
                                          Text(getFilIdFromName(grp.filliereId!).toUpperCase(),),
                                          )),
                                          DataCell(Container(child:
                                          Text('S${grp.SemNum}'),
                                          )),

                                          DataCell(
                                            Row(
                                              children: [
                                                Container(
                                                  width: 35,
                                                  child: TextButton(
                                                    onPressed: () =>_showGroupDetails(context, grp,grp.id),// Disable button functionality

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
                                          //     child: Text('${grp.description}',)),),


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

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              insetPadding: EdgeInsets.only(top:200,),
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
                  Text("Ajouter Group", style: TextStyle(fontSize: 25),),
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
                child: SingleChildScrollView(
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      //hmmm
                      SizedBox(height: 40),
                      DropdownButtonFormField<String>(
                        value: _selectedGN,
                        items: [
                          DropdownMenuItem<String>(
                            child: Text('A'),
                            value: "A",
                          ),
                          DropdownMenuItem<String>(
                            child: Text('B'),
                            value: "B",
                          ),
                          DropdownMenuItem<String>(
                            child: Text('C'),
                            value: "C",
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGN = value!;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,labelText: 'GNom?',labelStyle: TextStyle(fontSize: 20,color: Colors.black),
                          // fillColor: Color(0xA3B0AF1),
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),



                      SizedBox(height: 30),
                      DropdownButtonFormField<filliere>(
                        value: selectedFil,
                        items: filList.map((fil) {
                          return DropdownMenuItem<filliere>(
                            value: fil,
                            child: Text('${(fil.name)} '?? ''),
                          );
                        }).toList(),
                        onChanged: (value)async {
                          setState(()  {
                            selectedFil = value;
                            updateSemList();
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Color(0xA3B0AF1),
                          fillColor: Colors.white,
                          hintText: "selection filliere",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),

                      SizedBox(height: 30),
                      DropdownButtonFormField<Semestre>(
                        value: selectedSem,
                        items: semLis.map((fil) {
                          return DropdownMenuItem<Semestre>(
                            value: fil,
                            child: Text('S${(fil.numero)}'?? ''),
                          );
                        }).toList(),
                        onChanged: (value)async {
                          setState(()  {
                            selectedSem = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Color(0xA3B0AF1),
                          fillColor: Colors.white,
                          hintText: "selection filliere",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),

                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                          fetchGroup();
                          DateTime date = DateFormat('yyyy/MM/dd').parse(_date.text).toUtc();
                          _name.text = _selectedGN.toString();
                          _isOne.text = _selectedOne.toString();

                          // Pass the selected types to addCoursToProfesseur method
                          // AddGroup(_name.text, selectedSem!.id!);
                          // AddGroup(int.parse(_numero.text),date, selectedFil!.id!);

                          // Addfilliere(_name.text, _desc.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Le filliere a été ajouter avec succès.')),
                          );
                          setState(() {
                            fetchGroup();
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
        });
  }

  Future<void> _showGroupDetails(BuildContext context, Group grp,String GrpId) {
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
                Text('Group Infos',style: TextStyle(fontSize: 30),),
                SizedBox(height: 50),
                Row(
                  children: [
                    Text('Nom:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                    SizedBox(width: 10,),
                    Text(grp.type.toString(),
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
                    Row(
                      children: [
                        Text(getFilIdFromName(grp.filliereId!),//abdou
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                        SizedBox(width: 3,),
                        Text('${grp.semestre!.numero}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                      ],
                    ),

                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {

                        setState(() {
                          Navigator.pop(context);
                        });

                        _name.text = grp.type;
                        // _isOne.text = grp.isOne;
                        _sem.text = grp.semestre!.id;
                        // _date.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(grp.startEmploi.toString()));

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
                                title:
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Modifier un Group", style: TextStyle(fontSize: 20),),
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
                                      children: [
                                        SizedBox(height: 40),
                                        DropdownButtonFormField<String>(
                                          value: _name.text,
                                          items: [
                                            DropdownMenuItem<String>(
                                              child: Text('CM'),
                                              value: "CM",
                                            ),
                                            DropdownMenuItem<String>(
                                              child: Text('TP'),
                                              value: "TP",
                                            ),
                                            DropdownMenuItem<String>(
                                              child: Text('TD'),
                                              value: "TD",
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedGN = value!;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            filled: true,labelText: 'Type?',labelStyle: TextStyle(fontSize: 20,color: Colors.black),
                                            // fillColor: Color(0xA3B0AF1),
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,gapPadding: 1,
                                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: 30),
                                        DropdownButtonFormField<Semestre>(
                                          value: selectedSem,
                                          items: semLis.map((fil) {
                                            return DropdownMenuItem<Semestre>(
                                              value: fil,
                                              child: Text('${(fil.filliereName)} -${(fil.numero.toString())}'?? ''),
                                              // child: Text(fil.numero.toString()?? ''),
                                            );
                                          }).toList(),
                                          onChanged: (value)async {
                                            setState(()  {
                                              selectedSem= value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            filled: true,
                                            // labelText: 'Filliere',labelStyle: TextStyle(fontSize: 20,color: Colors.black),
                                            // fillColor: Color(0xA3B0AF1),
                                            fillColor: Colors.white,
                                            hintText: "selection d'une Filliere",
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,gapPadding: 1,
                                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                            ),
                                          ),
                                        ),



                                        SizedBox(height: 30),
                                        TextFormField(
                                          controller: _date,
                                          decoration: InputDecoration(
                                              filled: true,
                                              // fillColor: Color(0xA3B0AF1),
                                              fillColor: Colors.white,
                                              hintText: "Date",
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,gapPadding: 1,
                                                  borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                          // readOnly: true,
                                          onTap: () => selectDate(_date),
                                        ),



                                        SizedBox(height: 30),

                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _name.text = _selectedGN.toString();
                                            _isOne.text = _selectedOne.toString();
                                            DateTime date = DateFormat('yyyy/MM/dd').parse(_date.text).toUtc();

                                            fetchGroup();

                                            UpdateGroup(grp.id!, _name.text, selectedFil!.id!, date,);



                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Le Type est mis à jour avec succès.')),
                                            );
                                            setState(() {
                                              // Navigator.pop(context);
                                              fetchGroup();
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

                                    fetchGroup();
                                    DeleteGroups(GrpId);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Le Category a été Supprimer avec succès.')),
                                    );

                                    setState(() {
                                      Navigator.pop(context);
                                      fetchGroup();
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



  Future<void> UpdateGroup (id,String type,String semestre,DateTime? date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    final url = 'http://192.168.43.73:5000/group/'  + '/$id';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> body =({
      "name":type,
      "semestre":[semestre] ,
      'startEmploi': date?.toIso8601String(),
    });

    if (date != null) {
      body['startEmploi'] = date.toIso8601String();
    }

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        // Course creation was successful
        print("Group Updated successfully!");
        final responseData = json.decode(response.body);
        // print("Course ID: ${responseData['cours']['_id']}");
        // You can handle the response data as needed
        fetchGroup().then((data) {
          setState(() {
            filteredItems = data;
          });
        }).catchError((error) {
          print('Erreur lors de la récupération des Matieres: $error');
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


class Group {
  String id;
  String type;
  int numero;
  int? SemNum;
  Semes? semestre;
  String? filliereId;

  Group({
    required this.id,
    required this.type,
    required this.numero,
    this.semestre,
    this.filliereId,
    this.SemNum,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['_id'],
      type: json['type'],
      numero: json['numero'],
      semestre: Semes.fromJson(json['semestre']),
      filliereId: json['semestre']['filliere'],
      SemNum: json['semestre']['numero'],
    );
  }
}

class Semes {
  String id;
  String filliere;
  int numero;
  DateTime start;
  // List<String> elements;
  DateTime finish;

  Semes({
    required this.id,
    required this.filliere,
    required this.numero,
    required this.start,
    // required this.elements,
    required this.finish,
  });

  factory Semes.fromJson(Map<String, dynamic> json) {
    return Semes(
      id: json['_id'],
      filliere: json['filliere'],
      numero: json['numero'],
      start: DateTime.parse(json['start']),
      // elements: List<String>.from(json['elements']),
      finish: DateTime.parse(json['finish']),
    );
  }
}

void AddGroup (int numero,String type,String semId) async {

  // Check if the prix parameter is provided, otherwise use the default value of 100
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);
  final response = await http.post(
    Uri.parse('http://192.168.43.73:5000/group/'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      "numero":numero,
      "type":type,
      "semestre": semId ,
      // 'startEmploi': date?.toIso8601String(),
    }),
  );
  if (response.statusCode == 200) {
    print('Group ajouter avec succes');



  } else {
    print("SomeThing Went Wrong");
  }
}

Future<List<Group>> fetchGroup() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/group/'),
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
    List<dynamic> semData = jsonResponse['groups'];

    print(semData);
    List<Group> categories = semData.map((item) {
      return Group.fromJson(item);
    }).toList();

    // print(categories);
    return categories;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Group');
  }
}





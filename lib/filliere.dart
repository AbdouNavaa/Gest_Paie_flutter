import 'package:flutter/material.dart';
import 'package:gestion_payements/group.dart';
import 'package:gestion_payements/home_screen.dart';
import 'package:gestion_payements/professeures.dart';
import 'package:gestion_payements/semestre.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as Excel;

import 'dart:io';
 
import '../matieres.dart';





class Filliere extends StatefulWidget {
  Filliere({Key ? key}) : super(key: key);

  @override
  _FilliereState createState() => _FilliereState();
}

class _FilliereState extends State<Filliere> {

  Future<List<filliere>>? futurefilliere;

  List<filliere>? filteredItems;

  List<Professeur> professeurList = [];
  List<Matiere> matiereList = [];
  List<Semestre> semList = [];
  List<Group> grps = [];

  void DeleteFilliere(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/filliere' +"/$id"),
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
        fetchfilliere().then((data) {
          setState(() {
            filteredItems = data; // Assigner la liste renvoyée par filliereesseur à items
          });
        }).catchError((error) {
          print('Erreur: $error');
        });
      });
    }

  }
  Future<void> fetchData(filliereId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    try {
      final response = await http.get(
        Uri.parse('http://192.168.43.73:5000/group/filliere-groups/$filliereId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
         showFetchedDataModal(context, data,filliereId);
        List<dynamic> semestreNames = data['semestre_names'];
        List<dynamic> allGroups = data['all_groups'];
        List<dynamic> groups = data['groups'];
        List<dynamic> groupNames = data['group_names'];
        List<dynamic> semestres = data['semestres'];

      } else {
        print('Failed to fetch data. Error ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Semestre getSemeInfos(String id) {
    // Assuming you have a list of professeurs named 'professeursList'

    final semes = semList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>
        Semestre(id: '', filliereName: '',  ));
    print(semes);
    return semes; // Return the ID if found, otherwise an empty string

  }
  Group getGroupInfos(String id) {
    // Assuming you have a list of professeurs named 'professeursList'

    final grp = grps.firstWhere((prof) => '${prof.id}' == id, orElse: () =>
        Group(id: '',  groupName: '',  ));
    print(grp);
    return grp; // Return the ID if found, otherwise an empty string

  }


  List<String> getMatiereNamesFromSemestreElements(Semestre semestre) {
    List<String> matiereNames = [];
    for (var elementId in semestre.elements!) {
      final matiere = matiereList.firstWhere(
            (matiere) => matiere.id == elementId,
        orElse: () => Matiere(id: '', name: 'Matiere introuvable',  categorieId: ''),
      );
      matiereNames.add(matiere.name);
    }
    return matiereNames;
  }
  @override
  void initState() {
    super.initState();
    fetchfilliere().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par filliereesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchSemestre().then((data) {
      setState(() {
    semList  = data; // Assigner la liste renvoyée par filliereesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchMatiere().then((data) {
      setState(() {
    matiereList  = data; // Assigner la liste renvoyée par filliereesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchGroup().then((data) {
      setState(() {
    grps  = data; // Assigner la liste renvoyée par filliereesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchfilliere();
  }
  TextEditingController _searchController = TextEditingController();
  List<dynamic> getMatSemIdFromName(String id) {
    final professeur = semList.firstWhere(
          (prof) => '${prof.id}' == id,
      orElse: () => Semestre(id: '', filliereName: '', elements: []),
    );
    print('eles :${professeur.elements!.join(", ")
    }'); // Return the ID if found, otherwise an empty string
    print(id); // Return the ID if found, otherwise an empty string
    return professeur.elements!; // Return the ID if found, otherwise an empty string
  }
  String getFilId(String id) {
    final fil = filteredItems?.firstWhere(
          (prof) => '${prof.id}' == id,
      orElse: () => filliere(id: '', name: '', niveau: ''),
    );
    print('FilId :${fil!.id}');
  // Return the ID if found, otherwise an empty string
    return fil.id; // Return the ID if found, otherwise an empty string
  }
  String getMatIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = matiereList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Matiere(id: '', name: '', categorieId: '', categorie_name: '', code: '',));
    print(professeur.name);
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

  TextEditingController _name = TextEditingController();
  // TextEditingController _code = TextEditingController();
  TextEditingController _desc = TextEditingController();
  TextEditingController _niveau = TextEditingController();
  String _selectedNiveau = "licence";



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
                  Text("Liste de Filliere",style: TextStyle(fontSize: 25),)
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
                  List<filliere> Fillieres = await fetchfilliere();

                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les filliereesseurs dont le name ou le préname contient la valeur saisie
                    filteredItems = Fillieres!.where((fil) =>
                    fil.name!.toLowerCase().contains(value.toLowerCase()) ||
                        fil.niveau!.toLowerCase().contains(value.toLowerCase())).toList();
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
                  child: FutureBuilder<List<filliere>>(
                    future: fetchfilliere(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<filliere>? items = snapshot.data;

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
                                // border: TableBorder.all(color: Colors.black12, width: 2),
                                headingTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Set header text color
                                ),
                                // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xff0fb2ea)), // Set row background color
                                columns: [
                                  DataColumn(label: Text('Nom')),
                                  DataColumn(label: Text('Niveau')),
                                  DataColumn(label: Text('Desc')),
                                  // DataColumn(label: Text('Periode')),
                                  DataColumn(label: Text('Action')),
                                  // DataColumn(label: Text('Descrition')),
                                ],
                                rows: [
                                  for (var fil in filteredItems!)
                                    DataRow(
                                        cells: [
                                          DataCell(Container(child: Text('${fil.name.toUpperCase()}')),),
                                          DataCell(Container(child: Text('${fil.niveau}')),),
                                          DataCell(Container(child: Text('${fil.description}')),),
                                          // DataCell(Container(child: Text('${fil.periode}')),),

                                          DataCell(
                                            Row(
                                              children: [
                                                Container(
                                                  width: 35,
                                                  child:
                                                  TextButton(
                                                    onPressed: (){
                                                      print(fil.id);
                                                      fetchData(fil.id!);
                                                    },

                                                    // onPressed: () =>showFetchedDataModal(context, fetchData(fil.id!)),// Disable button functionality

                                                    //Disable button functionality

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
                                          //     child: Text('${fil.description}',)),),


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
          onPressed: () => _importData(context),

        ),


      ),
      // bottomNavigationBar: BottomNav(),

    );
  }

  Future<void> _importData(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.first.path!);

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
          String niveau = row[1]?.value?.toString() ?? "";
          String desc = row[2]?.value?.toString() ?? "";

          // Faites quelque chose avec les données, par exemple, ajoutez-les à votre liste de professeurs
          // print('Code: $nom, Nom $niveau,Desc $desc,');
          Addfilliere(nom,niveau,desc);
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
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return SingleChildScrollView(
            child: Container(
              height: 450,
              padding: const EdgeInsets.all(25.0),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Ajouter un Filliere", style: TextStyle(fontSize: 25),),
                      Spacer(),
                      InkWell(
                        child: Icon(Icons.close),
                        onTap: (){
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                  //hmmm
                  SizedBox(height: 40),
                  TextField(
                    controller: _name,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        // fillColor: Colors.white,
                        hintText: "Nom",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),

                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedNiveau,
                    items: [
                      DropdownMenuItem<String>(
                        child: Text('licence'),
                        value: "licence",
                      ),
                      DropdownMenuItem<String>(
                        child: Text('Master'),
                        value: "master",
                      ),
                      DropdownMenuItem<String>(
                        child: Text('Doctorat'),
                        value: "doctorat",
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedNiveau = value!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      // fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,gapPadding: 1,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),


                  SizedBox(height: 10),
                  TextFormField(
                    controller: _desc,
                    keyboardType: TextInputType.text,
                    maxLines: 3,
                    decoration: InputDecoration(
                        filled: true,

                        // fillColor: Colors.white,
                        hintText: "description",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),

                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                      fetchfilliere();
                      _niveau.text = _selectedNiveau.toString();

                      Addfilliere(_name.text,_niveau.text,_desc.text);
                      // Addfilliere(_name.text, _desc.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Le filliere a été ajouter avec succès.')),
                      );
                      setState(() {
                      fetchfilliere();
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
          );

        }


    );
  }


  Future<void> _AjoutGroup(BuildContext context,List<dynamic> data) async {

    String _selectedGN = 'A';
    String _selectedSem = data.isNotEmpty ? data[0]['_id'] : '';

    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return SingleChildScrollView(
            child: Container(
              height: 500,
              padding: const EdgeInsets.all(25.0),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
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
                      // fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,gapPadding: 1,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                    value: _selectedSem,
                    items: data.map((fil) {
                      String displayText = 'S${fil['numero']}';

                      return DropdownMenuItem<String>(
                        value: fil['_id'],
                        child: Text(displayText ?? ''),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        _selectedSem = value!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      hintText: "Sélectionnez le semestre",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, gapPadding: 1,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                      fetchGroup();
                      _name.text = _selectedGN.toString();

                      // Pass the selected types to addCoursToProfesseur method
                      AddGroup(_name.text, _selectedSem);
                      // AddGroup(int.parse(_numero.text),date, selectedFil!.id!);

                      // Addfilliere(_name.text, _desc.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Le filliere a été ajouter avec succès.')),
                      );
                      setState(() {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>Groups()));
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
          );

        }


    );
  }
  
  void showFetchedDataModal(BuildContext context, Map<String, dynamic> data,String filId ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
          topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
      isScrollControlled: true, // Rendre le contenu déroulable
      builder: (BuildContext context) {
        return Container(
          height: 650,
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Filliere Infos',style: TextStyle(fontSize: 30),),
                SizedBox(height: 50),
                Text(
                  'Fillière: ${data['filliere']}.'.toUpperCase(),
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Description: ${data['description']}',style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Niveau: ${data['niveau']}',style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Semestres:',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 160,),
                    IconButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>Semestres()));
                        },
                        // onPressed: (){},
                        icon: Icon(Icons.view_list)),

                  ],
                ),
                for (var semestre in data['semestre_names'])
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('ID: ${semestre['_id']}',style: TextStyle(fontSize: 18)),
                      // '${getMatIdFromNames(grp.semestre!.elements!.join(", ")) }',
                      Text('Matieres: [${getMatIdFromNames(getMatSemIdFromName(semestre['_id']).join(", "))}]',style: TextStyle(fontSize: 18)),
                      Text('Numéro: S${semestre['numero']}',style: TextStyle(fontSize: 18)),
                      Text( 'Deb Semestre: ${DateFormat('dd/MM/yyyy ').format(
                        DateTime.parse(getSemeInfos(semestre['_id']).start.toString()).toLocal(),
                      )}',style: TextStyle(fontSize: 18)),
                      Text( 'Fin Semestre: ${DateFormat('dd/MM/yyyy ').format(
                        DateTime.parse(getSemeInfos(semestre['_id']).finish.toString()).toLocal(),
                      )}',style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                    ],
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Groupes:',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 143,),
                    IconButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>Groups()));
                        },
                        // onPressed: (){},
                        icon: Icon(Icons.view_list)),
                    IconButton(
                        onPressed: ()=> _AjoutGroup(context,data['semestre_names']),
                        // onPressed: (){},
                        icon: Icon(Icons.group_add_sharp))
                  ],
                ),
                for (var group in data['all_groups'])
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Text('ID: ${group['_id']}',style: TextStyle(fontSize: 18)),
                      Text('Nom du groupe: ${group['name']}',style: TextStyle(fontSize: 18)),
                      SizedBox(width: 100,),
                      Text('S${group['semestre_numero']}',style: TextStyle(fontSize: 18)),
                      SizedBox(width: 10,),
                      IconButton(icon:Icon( Icons.date_range),
                          onPressed:() {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupEmploiPage(groupId: group['_id'])));
        }
        ),//abdou
                      // Text( 'Deb d\'Emploi: ${DateFormat('dd/MM/yyyy ').format(DateTime.parse(getGroupInfos(group['_id']).startEmploi.toString()).toLocal(),)}',style: TextStyle(fontSize: 18)),
                      // Text( 'Fin d\'Emploi: ${DateFormat('dd/MM/yyyy ').format(DateTime.parse(getGroupInfos(group['_id']).finishEmploi.toString()).toLocal(),)}',style: TextStyle(fontSize: 18)),
                      // Text( 'Fin d\'Emploi: ${DateFormat('dd/MM/yyyy ').format(DateTime.parse(group['finishEmploi']).toLocal(),)}',style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                    ],
                  ),
                SizedBox(height: 20),
                // Ajoutez d'autres informations à afficher ici selon vos besoins

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        setState(() {
                          // fetchfilliere();
                          Navigator.pop(context);

                        });
                        _name.text = data['filliere'];
                        // _code.text = categ.code!;
                        _desc.text = data['description'];
                        _selectedNiveau = data['niveau'];
                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
                            isScrollControlled: true, // Rendre le contenu déroulable

                            builder: (BuildContext context){
                              return SingleChildScrollView(
                                child: Container(
                                  height: 450,
                                  padding: const EdgeInsets.all(25.0),
                                  child: Column(
                                    // mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text("Modifier", style: TextStyle(fontSize: 25),),
                                          Spacer(),
                                          InkWell(
                                            child: Icon(Icons.close),
                                            onTap: (){
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      ),
                                      //hmmm
                                      SizedBox(height: 40),
                                      TextField(
                                        controller: _name,
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                            filled: true,
                                            // fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none,gapPadding: 1,
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                      ),



                                      SizedBox(height: 10),
                                      DropdownButtonFormField<String>(
                                        value: _selectedNiveau,
                                        items: [
                                          DropdownMenuItem<String>(
                                            child: Text('Licence'),
                                            value: "licence",
                                          ),
                                          DropdownMenuItem<String>(
                                            child: Text('Master'),
                                            value: "master",
                                          ),
                                          DropdownMenuItem<String>(
                                            child: Text('Doctorat'),
                                            value: "doctorat",
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedNiveau = value!;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          // fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,gapPadding: 1,
                                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: _desc,
                                        keyboardType: TextInputType.text,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                            filled: true,

                                            // fillColor: Colors.white,
                                            hintText: "description",
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none,gapPadding: 1,
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                      ),
                                      SizedBox(height: 10),




                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _niveau.text = _selectedNiveau.toString();

                                          fetchfilliere();

                                          // AddCategory(_name.text, _desc.text);
                                          UpdateFilliere(filId, _name.text,_selectedNiveau,_desc.text,);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Le filliere est mis à jour avec succès.')),
                                          );
                                          setState(() {
                                            fetchfilliere();

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
                              );

                            }


                        );
                      }, // Disable button functionality


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
                                    fetchfilliere();
                                    DeleteFilliere(filId);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Le Category a été Supprimer avec succès.')),
                                    );
                                    setState(() {
                                      fetchfilliere();
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
          ),
        );
      },
    );
  }


  void Addfilliere (String name,String niveau,String description) async {

    // Check if the prix parameter is provided, otherwise use the default value of 100
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/filliere/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "name":name,
        "niveau": niveau ,
        "description":description ,
      }),
    );
    if (response.statusCode == 200) {
      print('filliere ajouter avec succes');
      setState(() {
        fetchfilliere().then((data) {
          setState(() {
            filteredItems = data; // Assigner la liste renvoyée par filliereesseur à items
          });
        }).catchError((error) {
          print('Erreur: $error');
        });
      });
    } else {
      print("SomeThing Went Wrong");
    }
  }

  Future<void> UpdateFilliere( id,String name,String niveau,String desc) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    final url = 'http://192.168.43.73:5000/filliere/'  + '/$id';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> body =({
      'name': name,
      'niveau': niveau,
      'description': desc,
    });


    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        // Course creation was successful
        print("Filliere updated successfully!");
        final responseData = json.decode(response.body);
        // print("Course ID: ${responseData['cours']['_id']}");
        // You can handle the response data as needed

        setState(() {
          fetchfilliere().then((data) {
            setState(() {
              filteredItems = data; // Assigner la liste renvoyée par filliereesseur à items
            });
          }).catchError((error) {
            print('Erreur: $error');
          });
        });
      } else {
        // Course creation failed
        print("Failed to update filliere. Status code: ${response.statusCode}");
        print("Error Message: ${response.body}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

}


class filliere {
  final String id;
  final String name;
  final String niveau;
  final String? description;
  final int? periode;

  filliere({
    required this.id,
    required this.name,
    required this.niveau,
     this.description,
     this.periode,
  });

  factory filliere.fromJson(Map<String, dynamic> json) {
    return filliere(
      id: json['_id'],
      name: json['name'],
      niveau: json['niveau'],
      description: json['description'],
      periode: json['periode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'niveau': niveau,
      'description': description,
      'periode': periode,
    };
  }
}

Future<List<filliere>> fetchfilliere() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/filliere/'),
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
    List<dynamic> filData = jsonResponse['fillieres'];

    print(filData);
    List<filliere> categories = filData.map((item) {
      return filliere.fromJson(item);
    }).toList();

    // print(categories);
    return categories;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load filliere');
  }
}


class GroupEmploiPage extends StatefulWidget {
  final String groupId; // L'ID du groupe

  GroupEmploiPage({required this.groupId});

  @override
  _GroupEmploiPageState createState() => _GroupEmploiPageState();
}

class _GroupEmploiPageState extends State<GroupEmploiPage> {
  late List<dynamic> emplois =[];
  late String filliere = '';
  late String description = '';
  late String annee = '';
  late int semestre =0;
  late String niveau = '';
  late String group = '';

  @override
  void initState() {
    super.initState();
    fetchGroupEmploi();
  }

  Future<void> fetchGroupEmploi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    String apiUrl = 'http://192.168.43.73:5000/group/${widget.groupId}/emploi';
    final response = await http.get(Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      setState(() {
        filliere = data['filliere'];
        description = data['description'];
        annee = data['annee'];
        semestre = data['semestre'];
        niveau = data['niveau'];
        group = data['group'];
        emplois = data['emplois'];
      });
    } else {
      throw Exception('Failed to load group emploi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emploi du Groupe $group'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ListTile(
          //   title: Text('Filliere: ${filliere.toUpperCase()} ($description)', style: TextStyle(fontSize: 17),),
          //   subtitle: Text('Nivau: $annee | Semestre: $semestre | Niveau: $niveau', style: TextStyle(fontSize: 17)),
          // ),
          Divider(),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                showCheckboxColumn: true,
                showBottomBorder: true,
                headingRowHeight: 50,
                columnSpacing: 8,
                dataRowHeight: 50,
                columns: [
                  DataColumn(label: Text('Jours')),
                  DataColumn(label: Text('Prof')),
                  DataColumn(label: Text('Mat')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Deb')),
                  DataColumn(label: Text('Fin')),
                  // DataColumn(label: Text('Action')),
                ],
                rows: [
                  for (var index = 0; index < (emplois?.length ?? 0); index++)
                  // for (var categ in emplois!)
                    DataRow(
                        cells: [
                          DataCell(Container(width: 60,
                            child: Text('${emplois?[index]['day']}',style: TextStyle(
                              color: Colors.black,
                            ),),
                          )),
                          DataCell(Container(width: 60,
                            child: Text('${emplois?[index]['professeur']}',style: TextStyle(
                              color: Colors.black,
                            ),),
                          )),
                          DataCell(Container(width: 60,
                            child: Text('${emplois?[index]['matiere']}',style: TextStyle(
                              color: Colors.black,
                            ),),
                          )),
                          DataCell(Container(width: 60,
                            child: Text('${emplois?[index]['type']}',style: TextStyle(
                              color: Colors.black,
                            ),),
                          )),
                          DataCell(Container(width: 60,
                            child: Text('${emplois?[index]['startTime']}',style: TextStyle(
                              color: Colors.black,
                            ),),
                          )),
                          DataCell(Container(width: 60,
                            child: Text('${emplois?[index]['finishTime']}',style: TextStyle(
                              color: Colors.black,
                            ),),
                          )),



                        ]),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}





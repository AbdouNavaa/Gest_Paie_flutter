import 'package:flutter/material.dart';
import 'package:gestion_payements/semestre.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Ajout.dart';
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
       Navigator.pop(context);

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



  List<String> getMatiereNamesFromSemestreElements(Semestre semestre) {
    List<String> matiereNames = [];
    for (var elementId in semestre.elements!) {
      final matiere = matiereList.firstWhere(
            (matiere) => matiere.id == elementId,
        orElse: () => Matiere(id: '', name: 'Matiere introuvable', description: '', categorieId: ''),
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
    fetchfilliere();
  }
  TextEditingController _searchController = TextEditingController();
  String getMatSemIdFromName(String id) {
    final professeur = semList.firstWhere(
          (prof) => '${prof.id}' == id,
      orElse: () => Semestre(id: '', filliereName: '', elements: []),
    );
    print('eles :${professeur.elements!.join(", ")
    }'); // Return the ID if found, otherwise an empty string
    print(id); // Return the ID if found, otherwise an empty string
    return professeur.elements!.join(", "); // Return the ID if found, otherwise an empty string
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
    final professeur = matiereList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Matiere(id: '', name: '', description: '', categorieId: '', categorie_name: '', code: '',));
    print(professeur.name);
    return professeur.name; // Return the ID if found, otherwise an empty string

  }
  String getMatIdFromNames(String elements) {
    List<String> ids = elements.split(', '); // Sépare la chaîne en une liste d'IDs

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
  String _selectedNiveau = "Licence";


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
                                  DataColumn(label: Text('Periode')),
                                  DataColumn(label: Text('Action')),
                                  // DataColumn(label: Text('Descrition')),
                                ],
                                rows: [
                                  for (var fil in filteredItems!)
                                    DataRow(
                                        cells: [
                                          DataCell(Container(child: Text('${fil.name}')),),
                                          DataCell(Container(child: Text('${fil.niveau}')),),
                                          DataCell(Container(child: Text('${fil.description}')),),
                                          DataCell(Container(child: Text('${fil.periode}')),),

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
          onPressed: () => _displayTextInputDialog(context),

        ),


      ),
      // bottomNavigationBar: BottomNav(),

    );
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
              height: 600,
              padding: const EdgeInsets.all(25.0),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Ajouter une Filliere", style: TextStyle(fontSize: 25),),
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
                        child: Text('Licence'),
                        value: "Licence",
                      ),
                      DropdownMenuItem<String>(
                        child: Text('Master'),
                        value: "Master",
                      ),
                      DropdownMenuItem<String>(
                        child: Text('Doctorat'),
                        value: "Doctorat",
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
          );

        }


    );
  }
  Future<void> _showFilDetails(BuildContext context, filliere fil) {
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
                Text('Filliere Infos',style: TextStyle(fontSize: 30),),
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
                    Text(fil.name.toUpperCase(),
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
                    Text('Niveau:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${ fil.niveau}',
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
                    Text('Description:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${fil.description}',
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
                    Text('Periode:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${fil.periode}',
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        _name.text = fil.name!;
                        // _code.text = categ.code!;
                        _desc.text = fil.description!;
                        _selectedNiveau = fil.niveau!;
                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
                            isScrollControlled: true, // Rendre le contenu déroulable

                            builder: (BuildContext context){
                              return SingleChildScrollView(
                                child: Container(
                                  height: 600,
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
                                            value: "Licence",
                                          ),
                                          DropdownMenuItem<String>(
                                            child: Text('Master'),
                                            value: "Master",
                                          ),
                                          DropdownMenuItem<String>(
                                            child: Text('Doctorat'),
                                            value: "Doctorat",
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


                                          setState(() {
                                            // fetchfilliere();
                                            Navigator.pop(context);

                                          });
                                          // AddCategory(_name.text, _desc.text);
                                          UpdateFilliere(fil.id!, _name.text,_selectedNiveau,_desc.text,);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Le filliere est mis à jour avec succès.')),
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
                                    DeleteFilliere(fil.id);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filliere Infos',style: TextStyle(fontSize: 30),),
              SizedBox(height: 50),
              Text(
                'Fillière: ${data['filliere']}',
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Description: ${data['description']}',style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Text('Niveau: ${data['niveau']}',style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              Text(
                'Semestres:',
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
              ),
              for (var semestre in data['semestres'])
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('ID: ${semestre['_id']}',style: TextStyle(fontSize: 18)),
                    Text('ID: ${getMatIdFromNames(getMatSemIdFromName(semestre['_id']))}',style: TextStyle(fontSize: 18)),
                    Text('Numéro: ${semestre['numero']}',style: TextStyle(fontSize: 18)),
                    Text( 'Deb Semestre: ${DateFormat('dd/MM/yyyy ').format(
                      DateTime.parse(semestre['start']).toLocal(),
                    )}',style: TextStyle(fontSize: 18)),
                    Text( 'Fin Semestre: ${DateFormat('dd/MM/yyyy ').format(
                      DateTime.parse(semestre['finish']).toLocal(),
                    )}',style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                  ],
                ),
              SizedBox(height: 20),
              Text(
                'Groupes:',
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
              ),
              for (var group in data['groups'])
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${group['_id']}',style: TextStyle(fontSize: 18)),
                    Text('Nom du groupe: ${group['groupName']}',style: TextStyle(fontSize: 18)),
                    Text('Is One: ${group['isOne']}',style: TextStyle(fontSize: 18)),
                    Text( 'Deb d\'Emploi: ${DateFormat('dd/MM/yyyy ').format(DateTime.parse(group['startEmploi']).toLocal(),)}',style: TextStyle(fontSize: 18)),
                    Text( 'Fin d\'Emploi: ${DateFormat('dd/MM/yyyy ').format(DateTime.parse(group['finishEmploi']).toLocal(),)}',style: TextStyle(fontSize: 18)),
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
                                height: 600,
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
                                          value: "Licence",
                                        ),
                                        DropdownMenuItem<String>(
                                          child: Text('Master'),
                                          value: "Master",
                                        ),
                                        DropdownMenuItem<String>(
                                          child: Text('Doctorat'),
                                          value: "Doctorat",
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


                                        setState(() {
                                          // fetchfilliere();
                                          Navigator.pop(context);

                                        });
                                        // AddCategory(_name.text, _desc.text);
                                        UpdateFilliere(filId, _name.text,_selectedNiveau,_desc.text,);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Le filliere est mis à jour avec succès.')),
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
                                  DeleteFilliere(data['filliere']);
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
        Navigator.pop(context);
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
          Navigator.pop(context);
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






import 'package:flutter/material.dart';
import 'package:gestion_payements/filliere.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Ajout.dart';
import '../matieres.dart';





class Semestres extends StatefulWidget {
  Semestres({Key ? key}) : super(key: key);

  @override
  _SemestresState createState() => _SemestresState();
}

class _SemestresState extends State<Semestres> {

  Future<List<Semestre>>? futureSemestre;

  List<Semestre>? filteredItems;

  List<Professeur> professeurList = [];
  List<Matiere> matiereList = [];
  List<filliere> filList = [];
  TextEditingController _date = TextEditingController();
  Matiere? selectedMat;
  filliere? selectedFil;

  void DeleteSemestres(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/semestre' +"/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchSemestre();
      // setState(() {
        Navigator.pop(context);
      // });
    }

  }
  void DeleteMatSem(id,String matiereId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/semestre/$id/$matiereId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchSemestre();
      // setState(() {
        Navigator.pop(context);
      // });
    }

  }
  String getMatIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = matiereList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Matiere(id: '', name: '', description: '', categorieId: '', categorie_name: '', code: '',));
    // print(professeur.name);
    return professeur.name; // Return the ID if found, otherwise an empty string

  }
  String getMatIdFromNames(String elements) {
    List<String> ids = elements.split(', '); // Sépare la chaîne en une liste d'IDs

    // Traitez chaque ID individuellement ici
    String result = '';
    for (var id in ids) {
      result += getMatIdFromName(id) + '   '; // Traitez chaque ID avec getMatIdFromName
    }

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
    fetchSemestre().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Semestreesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchfilliere().then((data) {
      setState(() {
        filList = data; // Assigner la liste renvoyée par Semestreesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchProfs().then((data) {
      setState(() {
        professeurList = data; // Assigner la liste renvoyée par Semestreesseur à items
      });
      fetchMatiere().then((data) {
        setState(() {
          matiereList = data; // Assigner la liste renvoyée par Semestreesseur à items
        });
      }).catchError((error) {
        print('Erreur: $error');
      });

    }).catchError((error) {
      print('Erreur: $error');
    });
  }
  TextEditingController _searchController = TextEditingController();

  TextEditingController _name = TextEditingController();
  TextEditingController _numero = TextEditingController();
  // TextEditingController _code = TextEditingController();
  TextEditingController _desc = TextEditingController();
  TextEditingController _taux = TextEditingController();
  num _selectedTaux = 500;


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
                  Text("Liste de Semestres",style: TextStyle(fontSize: 25),)
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
                  List<Semestre> Semestress = await fetchSemestre();

                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les Semestreesseurs dont le name ou le préname contient la valeur saisie
                    filteredItems = Semestress!.where((sem) =>
                    sem.numero!.toString().toLowerCase().contains(value.toLowerCase()) ||
                        (sem.start!.toString()).toLowerCase().contains(value.toLowerCase()) ||
                        (sem.finish!.toString()).toLowerCase().contains(value.toLowerCase()) ||
                        sem.filliereName!.toLowerCase().contains(value.toLowerCase())).toList();
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
                  child: FutureBuilder<List<Semestre>>(
                    future: fetchSemestre(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<Semestre>? items = snapshot.data;

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
                                  DataColumn(label: Text('Fillieres')),
                                  DataColumn(label: Text('Deb')),
                                  DataColumn(label: Text('Fin')),
                                  DataColumn(label: Text('Action')),
                                  // DataColumn(label: Text('Descrition')),
                                ],
                                rows: [
                                  for (var sem in filteredItems!)
                                    DataRow(
                                        cells: [
                                          DataCell(Container(child: Text('S${sem.numero}')),

                                            // onTap:() => _showcategDetails(context, categ)
                                          ),
                                          DataCell(Container(child: Text('${sem.filliereName}'))),
                                          DataCell(Container(child: Text( '${DateFormat('dd/MM/yyyy ').format(
                                            DateTime.parse(sem.start.toString()).toLocal(),
                                          )}',))),
                                          DataCell(Container(child: Text( '${DateFormat('dd/MM/yyyy ').format(
                                            DateTime.parse(sem.finish.toString()).toLocal(),
                                          )}',))),

                                          DataCell(
                                            Container(
                                              width: 35,
                                              child: TextButton(
                                                onPressed: () =>_showSemDetails(context, sem),// Disable button functionality

                                                child: Icon(Icons.more_horiz, color: Colors.black54),
                                                style: TextButton.styleFrom(
                                                  primary: Colors.white,
                                                  elevation: 0,
                                                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                                                ),
                                              ),
                                            ),
                                          ),
                                          // DataCell(Container(width: 105,
                                          //     child: Text('${sem.description}',)),),


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
                      Text("Ajouter Semestre", style: TextStyle(fontSize: 25),),
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
                    controller: _numero,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        // fillColor: Colors.white,
                        hintText: "Numero",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  ),

                  SizedBox(height: 10),
                  TextFormField(
                    controller: _date,
                    decoration: InputDecoration(
                        filled: true,
                        // fillColor: Color(0xA3B0AF1),
                        hintText: "Date",
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    // readOnly: true,
                    onTap: () => selectDate(_date),
                  ),


                  SizedBox(height: 10),
                  DropdownButtonFormField<filliere>(
                    value: selectedFil,
                    items: filList.map((fil) {
                      return DropdownMenuItem<filliere>(
                        value: fil,
                        child: Text(fil.name?? ''),
                      );
                    }).toList(),
                    onChanged: (value)async {
                      setState(()  {
                        selectedFil = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      // fillColor: Color(0xA3B0AF1),
                      hintText: "selection d'une Matiere",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,gapPadding: 1,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),

   SizedBox(height: 10),
                  DropdownButtonFormField<Matiere>(
                    value: selectedMat,
                    items: matiereList.map((matiere) {
                      return DropdownMenuItem<Matiere>(
                        value: matiere,
                        child: Text(matiere.name ?? ''),
                      );
                    }).toList(),
                    onChanged: (value)async {
                      setState(()  {
                        selectedMat = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      // fillColor: Color(0xA3B0AF1),
                      hintText: "selection d'une Matiere",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,gapPadding: 1,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),






                  ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                      // fetchfilliere();
                      DateTime date = DateFormat('yyyy/MM/dd').parse(_date.text).toUtc();

                      // Pass the selected types to addCoursToProfesseur method
                      AddSemestre(int.parse(_numero.text),date, selectedFil!.id!,selectedMat!.id!);
                      // AddSemestre(int.parse(_numero.text),date, selectedFil!.id!);

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

  Future<void> _showSemDetails(BuildContext context, Semestre sem) {
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
                Text('Matiere Infos',style: TextStyle(fontSize: 30),),
                SizedBox(height: 50),
                Row(
                  children: [
                    Text('Numero:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                    SizedBox(width: 10,),
                    Text(sem.numero.toString(),
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
                    Text('Filiere:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${sem.filliereName}',
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
                    Text(
                      '${DateFormat('dd/MM/yyyy ').format(
                        DateTime.parse(sem.start.toString()).toLocal(),
                      )}',
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
                    Text(
                        '${DateFormat('dd/MM/yyyy ').format(
                      DateTime.parse(sem.finish.toString()).toLocal(),
                    )}',
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
                    Text('matieres:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    InkWell(
                      child: Text(
                        '${getMatIdFromNames(sem.elements!.join(", ")) }',
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          // fetchfilliere();
                          Navigator.pop(context);

                        });

                        List<filliere> types = await fetchfilliere();
                        List<Matiere> matieres = await fetchMatiere();
                        _numero.text = sem.numero.toString();
                        _name.text = sem.filliereName;
                        _date.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(sem.start.toString()));
                        // selectedCateg = filteredItems![index].categorie;
                        // _selectedSemestre = filteredItems![index].semestre!;
                        List<filliere?> selectedCategories = List.generate(matiereList.length, (_) => null);

                        showModalBottomSheet(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
                            isScrollControlled: true, // Rendre le contenu déroulable


                            context: context,
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
                                          Text("Modifier Semestre", style: TextStyle(fontSize: 20),),
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
                                      // SizedBox(height: 10),
                                      DropdownButtonFormField<filliere>(
                                        value: selectedFil,
                                        items: filList.map((fil) {
                                          return DropdownMenuItem<filliere>(
                                            value: fil,
                                            child: Text(fil.name?? ''),
                                          );
                                        }).toList(),
                                        onChanged: (value)async {
                                          setState(()  {
                                            selectedFil = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          // fillColor: Color(0xA3B0AF1),
                                          hintText: "selection d'une Matiere",
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,gapPadding: 1,
                                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          ),
                                        ),
                                      ),


                                      SizedBox(height: 10),
                                      DropdownButtonFormField<Matiere>(
                                        value: selectedMat,
                                        items: matiereList.map((matiere) {
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

                                      // String? selectedType; // Variable pour suivre l'élément sélectionné


                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: _date,
                                        decoration: InputDecoration(
                                            filled: true,
                                            // fillColor: Color(0xA3B0AF1),
                                            hintText: "Date",
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none,gapPadding: 1,
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                        // readOnly: true,
                                        onTap: () => selectDate(_date),
                                      ),



                                      SizedBox(height: 10),

                                      ElevatedButton(
                                        onPressed: () {
                                          // Navigator.of(context).pop();

                                          DateTime date = DateFormat('yyyy/MM/dd').parse(_date.text).toUtc();

                                          // Check if you're updating an existing matiere or creating a new one
                                          UpdateSemestre(
                                            sem.id!,
                                              int.parse(_numero.text),
                                              date,
                                              selectedFil!.id!,
                                              selectedMat!.id!,
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
                              );

                            }
                        );
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
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
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
                                 DropdownButtonFormField<Matiere>(
                                   value: selectedMat,
                                   items: matiereList.map((matiere) {
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


                                     AddSemMat(sem.id, selectedMat!.id!);
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(content: Text('Matiere has been added to professor successfully.')),
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
                           )
                       );});
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
                                    DeleteSemestres(sem.id);
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


  void AddSemestre (int numero,DateTime? date,String filId,String elements) async {

    // Check if the prix parameter is provided, otherwise use the default value of 100
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/semestre/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "numero":numero,
        "filliere": filId ,
        'start': date?.toIso8601String(),
        "elements":[elements] ,
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
  Future<void> AddSemMat( id,String matiereId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    final url = 'http://192.168.43.73:5000/semestre/$id/$matiereId';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({
      'element': [matiereId],
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    // print(response.statusCode);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // You can handle the response data here if needed
      print(responseData);
      setState(() {
        Navigator.pop(context);
      });
    } else {
      // Handle errors
      print('Failed to add matiere to professeus. Status Code: ${response.statusCode}');
    }
  }

  Future<void> UpdateSemestre (id,int numero,DateTime? date,String filId,String elements) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    final url = 'http://192.168.43.73:5000/semestre/'  + '/$id';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> body =({
      "numero":numero,
      "filliere": filId ,
      'start': date?.toIso8601String(),
      "elements":[elements] ,
    });

    if (date != null) {
      body['start'] = date?.toIso8601String();
    }

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        // Course creation was successful
        print("Semestre Updated successfully!");
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


class Semestre {
  String id;
  String? filliereId;
  String filliereName;
  String? filliereNiveau;
  int? fillierePeriode;
  int? numero;
  DateTime? start;
  List<dynamic>? elements; // Le type exact des éléments peut être spécifié ici
  DateTime? finish;

  Semestre({
    required this.id,
     this.filliereId,
    required this.filliereName,
     this.filliereNiveau,
     this.fillierePeriode,
     this.numero,
     this.start,
     this.elements,
     this.finish,
  });

  factory Semestre.fromJson(Map<String, dynamic> json) {
    return Semestre(
      id: json['_id'] ?? '',
      filliereId: json['filliere']['_id'] ?? '',
      filliereName: json['filliere']['name'] ?? '',
      filliereNiveau: json['filliere']['niveau'] ?? '',
      fillierePeriode: json['filliere']['periode'] ?? 0,
      numero: json['numero'] ?? 0,
      start: DateTime.parse(json['start']),
      elements: json['elements'] ?? [],
      finish: DateTime.parse(json['finish']),
    );
  }
}


Future<List<Semestre>> fetchSemestre() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/semestre/'),
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
    List<dynamic> semData = jsonResponse['semestres'];

    print(semData);
    List<Semestre> categories = semData.map((item) {
      return Semestre.fromJson(item);
    }).toList();

    // print(categories);
    return categories;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Semestre');
  }
}





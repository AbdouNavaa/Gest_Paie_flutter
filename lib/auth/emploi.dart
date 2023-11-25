import 'package:flutter/material.dart';
import 'package:gestion_payements/group.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Ajout.dart';
import '../categories.dart';
import '../matieres.dart';





class Emploi extends StatefulWidget {
  Emploi({Key ? key}) : super(key: key);

  @override
  _EmploiState createState() => _EmploiState();
}

class _EmploiState extends State<Emploi> {

  Future<List<emploi>>? futureemploi;

  List<emploi>? filteredItems;

  List<Professeur> professeurList = [];
  List<Group> grpList = [];
  List<Matiere> matiereList = [];

  String getProfesseurIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = professeurList.firstWhere((prof) => '${prof.id}' == id, orElse: () => Professeur(id: '', nom: '', prenom: '', mobile: 0, email: '', matieres: []));
    print(professeur.nom);
    return professeur.nom; // Return the ID if found, otherwise an empty string

  }
  String getGroupIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final grp = grpList.firstWhere((g) => '${g.id}' == id, orElse: () => Group(id: '', groupName: '', isOne: '', startEmploi: null, semestre: null));
    print( grp.groupName);
    return grp.groupName; // Return the ID if found, otherwise an empty string

  }
  String getMatIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = matiereList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Matiere(id: '', name: '', description: '', categorieId: '', categorie_name: '', code: '',));
    // print(professeur.name);
    return professeur.name; // Return the ID if found, otherwise an empty string

  }
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
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchGroup().then((data) {
      setState(() {
        grpList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchProfs().then((data) {
      setState(() {
        professeurList = data; // Assigner la liste renvoyée par emploiesseur à items
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

  }
  TextEditingController _searchController = TextEditingController();

  TextEditingController _date = TextEditingController();
  TextEditingController _numero = TextEditingController();

  final TextEditingController _dayNumeroController = TextEditingController();

  // List<Map<String, dynamic>> typesList = [{'name': 'CM', 'nbh': 1.5}];
  Group? selectedGroup;
  Matiere? selectedMat;
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];
  List<Matiere> matieres = [];
  DateTime? selectedDateTime;
  Future<void> selectTime(TextEditingController controller) async {
    DateTime? selectedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (selectedDateTime != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        DateTime selectedDateTimeWithTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        String formattedDateTime = DateFormat('yyyy/MM/dd HH:mm').format(selectedDateTimeWithTime);
        setState(() {
          controller.text = formattedDateTime;
        });
      }
    }
  }


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

  Future<void> selectDate(TextEditingController controller) async {
    DateTime? selectedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (selectedDateTime != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        DateTime selectedDateTimeWithTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        String formattedDateTime = DateFormat('yyyy/MM/dd HH:mm').format(selectedDateTimeWithTime);
        setState(() {
          controller.text = formattedDateTime;
        });
      }
    }
  }



// Déclaration des listes au niveau de la classe
  List<String> typeNames = ['CM', 'TP', 'TD']; // Liste des noms uniques de types
  List<double> nbhValues = [1.5, 2]; // Liste des valeurs de 'nbh'

// Autres parties de votre classe

  Future<void> _addEmploi(String TN,double TH,DateTime? date,int days,String GpId,String ProfId,String MatId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    // final response = await http.post(


    final Uri uri = Uri.parse('http://192.168.43.73:5000/emploi');
    final Map<String, dynamic> emploiData = {
      "types": [
        {"name": TN, "nbh": TH}
      ],
      "startTime": date!.toIso8601String(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Emploi ajouté avec succès.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'ajout de l\'emploi.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $error')),
      );
    }
  }
  Future<void> UpdateEmp (id,String TN,double TH,DateTime? date,int days,String GpId,String ProfId,String MatId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    final url = 'http://192.168.43.73:5000/emploi/'  + '/$id';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final Map<String, dynamic> body = {
      "types": [
        {"name": TN, "nbh": TH}
      ],
      // "startTime": date!.toIso8601String(),
      'startTime': date?.toIso8601String(),
      "dayNumero": days,
      "group": GpId,
      "professeur": ProfId,
      "matiere": MatId
    };

    if (date != null) {
      body['startTime'] = date.toIso8601String();
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

  String selectedTypeName = 'CM'; // Nom de type sélectionné par défaut
  double selectedNbhValue = 1.5; // Valeur 'nbh' sélectionnée par défaut

  Widget _buildTypesInput() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(hintMaxLines: 3),
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
            });
          },
        ),
        SizedBox(height: 2),
        DropdownButtonFormField<double>(
          decoration: InputDecoration(hintMaxLines: 3),
          value: selectedNbhValue,
          items: nbhValues.map((nbhValue) {
            return DropdownMenuItem<double>(
              child: Text(nbhValue.toString()),
              value: nbhValue,
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedNbhValue = value ?? 1.5;
            });
          },
        ),
      ],
    );
  }

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
                    filteredItems = Emplois!.where((emploi) =>
                    getProfesseurIdFromName(emploi.professor!).toLowerCase().contains(value.toLowerCase()) ||
                        getMatIdFromName(emploi.mat)!.toLowerCase().contains(value.toLowerCase())).toList();
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
                                  DataColumn(label: Text('Code')),
                                  DataColumn(label: Text('Nom')),
                                  DataColumn(label: Text('Taux')),
                                  DataColumn(label: Text('Action')),
                                  // DataColumn(label: Text('Descrition')),
                                ],
                                rows: [
                                  for (var emp in filteredItems!)
                                    DataRow(
                                        cells: [
                                          DataCell(Container(child: Text('${getProfesseurIdFromName(emp.professor)}')),

                                            // onTap:() => _showcategDetails(context, categ)
                                          ),
                                         DataCell(Container(child: Text('${getMatIdFromName(emp.mat)}')),

                                            // onTap:() => _showcategDetails(context, categ)
                                          ),
                                          DataCell(Text('${getGroupIdFromName(emp.group)}',style: TextStyle(
                                            color: Colors.black,
                                          ),),),
                                          DataCell(
                                            Container(
                                              width: 35,
                                              child: TextButton(
                                                onPressed: () =>_showCourseDetails(context, emp),// Disable button functionality

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
                                          //     child: Text('${emp.description}',)),),


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
          tooltip: 'Ajouter un Emploi',
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
            scrollDirection: Axis.vertical,
            child: Container(
              height: 680,
              padding: const EdgeInsets.all(25.0),
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
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
                    //hmmm
                    SizedBox(height: 40),
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
                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              // fillColor: Color(0xA3B0AF1),
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
                          child: DropdownButtonFormField<double>(
                            decoration: InputDecoration(
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,gapPadding: 1,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                            ),
                            value: selectedNbhValue,
                            items: nbhValues.map((nbhValue) {
                              return DropdownMenuItem<double>(
                                child: Text(nbhValue.toString()),
                                value: nbhValue,
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedNbhValue = value ?? 1.5;
                              });
                            },
                          ),
                        ),
                      ],
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
                    TextField(
                      controller: _numero,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          filled: true,
                          // fillColor: Colors.white,
                          hintText: "Nb de Jours",
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,gapPadding: 1,
                              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    ),

                    SizedBox(height: 10),
                    DropdownButtonFormField<Group>(
                      value: selectedGroup,
                      items: grpList.map((grp) {
                        return DropdownMenuItem<Group>(
                          value: grp,
                          child: Text(grp.groupName ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) async{
                        setState(() {
                          selectedGroup = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        // fillColor: Color(0xA3B0AF1),
                        hintText: "selection d'une Group",

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
                          selectedProfesseur = null; // Reset the selected professor
                          // professeurs = await fetchProfesseursByMatiere(selectedMat!.id); // Clear the professeurs list when a matière is selected
                          updateProfesseurList(); // Update the list of professeurs based on the selected matière
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
                    DropdownButtonFormField<Professeur>(
                      value: selectedProfesseur,
                      items: professeurs.map((professeur) {
                        return DropdownMenuItem<Professeur>(
                          value: professeur,
                          child: Text(professeur.nom ?? ''),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProfesseur = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        // fillColor: Color(0xA3B0AF1),
                        hintText: "selection d'un  Professeur", // Update the hintText
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),

                    SizedBox(height:20),
                    ElevatedButton(
                      onPressed: (){
                        Navigator.of(context).pop();

                        setState(() {
                          // fetchemploi();
                          Navigator.pop(context);
                        });
                        // fetchemploi();
                        DateTime date = DateFormat('yyyy/MM/dd HH:mm').parse(_date.text).toUtc();
                        _addEmploi(selectedTypeName,selectedNbhValue,date,int.parse(_numero.text),selectedGroup!.id,selectedProfesseur!.id,selectedMat!.id);
                        // Addemploi(_name.text, _desc.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('L\'emploi a été ajouter avec succès.')),
                        );

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

        }


    );
  }
  Future<void> _showCourseDetails(BuildContext context, emploi emp) {
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
                    Text('Prof:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                    SizedBox(width: 10,),
                    Text(getProfesseurIdFromName(emp.professor).toUpperCase(),
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
                    Text('${getMatIdFromName( emp.mat)}',
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
                    Text('Numero:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${emp.dayNumero}',
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
                    Text('Date:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text(
                        '${DateFormat('dd/MM/yyyy ').format(
                      DateTime.parse(emp.startTime.toString()).toLocal(),
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
                    Text('Deb:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text(
                        '${DateFormat('HH:mm ').format(
                      DateTime.parse(emp.startTime.toString()).toLocal(),
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
                    Text('${DateFormat(' HH:mm').format(DateTime.parse(emp.startTime.toString()).toLocal().add(Duration(minutes: (
                        ( emp.types[0]['nbh'] )* 60).toInt())))}',
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
                    Text('Types:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${emp.types[0]['name']}',
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
                    Text('Nb Heures:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${emp.types[0]['nbh']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                  ],
                ),

                SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async{

                        setState(() {
                          Navigator.pop(context);
                        });
                        // selectedMat = emp.mat!;
                        _dayNumeroController.text = emp.dayNumero!.toString();
                        _date.text = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(emp.startTime.toString()));

                         showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
                            isScrollControlled: true, // Rendre le contenu déroulable


                            builder: (BuildContext context){
                              return SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Container(
                                  height: 680,
                                  padding: const EdgeInsets.all(25.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      // mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text("Modifier  l\'Emploi", style: TextStyle(fontSize: 25),),
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
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  // fillColor: Color(0xA3B0AF1),
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
                                              child: DropdownButtonFormField<double>(
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,gapPadding: 1,
                                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                  ),
                                                ),
                                                value: selectedNbhValue,
                                                items: nbhValues.map((nbhValue) {
                                                  return DropdownMenuItem<double>(
                                                    child: Text(nbhValue.toString()),
                                                    value: nbhValue,
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedNbhValue = value ?? 1.5;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
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
                                        TextField(
                                          controller: _dayNumeroController,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                              filled: true,
                                              // fillColor: Colors.white,
                                              hintText: "Nb de Jours",
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,gapPadding: 1,
                                                  borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                        ),

                                        SizedBox(height: 10),
                                        DropdownButtonFormField<Group>(
                                          value: selectedGroup,
                                          items: grpList.map((grp) {
                                            return DropdownMenuItem<Group>(
                                              value: grp,
                                              child: Text(grp.groupName ?? ''),
                                            );
                                          }).toList(),
                                          onChanged: (value) async{
                                            setState(() {
                                              selectedGroup = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            filled: true,
                                            // fillColor: Color(0xA3B0AF1),
                                            hintText: "selection d'une Group",

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
                                              selectedProfesseur = null; // Reset the selected professor
                                              // professeurs = await fetchProfesseursByMatiere(selectedMat!.id); // Clear the professeurs list when a matière is selected
                                              updateProfesseurList(); // Update the list of professeurs based on the selected matière
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
                                        DropdownButtonFormField<Professeur>(
                                          value: selectedProfesseur,
                                          items: professeurs.map((professeur) {
                                            return DropdownMenuItem<Professeur>(
                                              value: professeur,
                                              child: Text(professeur.nom ?? ''),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedProfesseur = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            filled: true,
                                            // fillColor: Color(0xA3B0AF1),
                                            hintText: "selection d'un  Professeur", // Update the hintText
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

                                            DateTime date = DateFormat('yyyy/MM/dd HH:mm').parse(_date.text).toUtc();

                                            // Check if you're updating an existing matiere or creating a new one
                                            UpdateEmp(
                                              emp.id!,
                                              selectedTypeName,
                                              selectedNbhValue,
                                                date,int.parse(_dayNumeroController.text),selectedGroup!.id,selectedProfesseur!.id,selectedMat!.id
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
                                ),
                              );

                            }


                        );
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
          );
        }


    );
  }


  void Addemploi (String name,String description,[num? prix]) async {

    // Check if the prix parameter is provided, otherwise use the default value of 100
    if (prix == null) {
      prix = 100;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/categorie/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "name":name,
        // "code":code ,
        "description":description ,
        "prix": prix ,
      }),
    );
    if (response.statusCode == 200) {
      print('emploi ajouter avec succes');
    } else {
      print("SomeThing Went Wrong");
    }
  }

  Future<void> UpdateEmploi( id,String professeurId,String matiereId, List<Map<String, dynamic>> types, DateTime? date, bool isPaid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    final url = 'http://192.168.43.73:5000/cours/'  + '/$id';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> body =({
      'professeur': professeurId,
      'matiere': matiereId,
      'types': types,
      // 'date': date?.toIso8601String(),
      'isPaid':isPaid
    });

    if (date != null) {
      body['date'] = date.toIso8601String();
    }

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        // Course creation was successful
        print("Course created successfully!");
        final responseData = json.decode(response.body);
        print("Course ID: ${responseData['cours']['_id']}");
        // You can handle the response data as needed
      } else {
        // Course creation failed
        print("Failed to create course. Status code: ${response.statusCode}");
        print("Error Message: ${response.body}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

}


class emploi {
  final String id;
  final List<Map<String, dynamic>> types;
  final DateTime startTime;
  final int dayNumero;
  final String group;
  final String professor;
  final String mat;
  final String finishTime;

  emploi({
    required this.id,
    required this.types,
    required this.startTime,
    required this.dayNumero,
    required this.group,
    required this.professor,
    required this.mat,
    required this.finishTime,
  });

  factory emploi.fromJson(Map<String, dynamic> json) {
    return emploi(
      id: json['_id'],
      types: List<Map<String, dynamic>>.from(json['types']),
      startTime: DateTime.parse(json['startTime']),
      dayNumero: json['dayNumero'],
      group: json['group'],
      professor: json['professeur'],
      mat: json['matiere'],
      finishTime: json['finishTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'types': types,
      'startTime': startTime.toIso8601String(),
      'dayNumero': dayNumero,
      'group': group,
      'professeur': professor,
      'matiere': mat,
      'finishTime': finishTime,
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
    List<emploi> categories = empData.map((item) {
      return emploi.fromJson(item);
    }).toList();

    // print(categories);
    return categories;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load emploi');
  }
}





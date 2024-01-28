import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_payements/matieres.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

   
import 'Cours.dart';
import 'Dashboard.dart';
import 'ProfCours.dart';
import 'categories.dart';

class ProfesseurDetailsScreen extends StatefulWidget {
  final String profId;
  final String nom;
  final String mail;


  ProfesseurDetailsScreen({required this.profId, required this.nom, required this.mail});

  @override
  _ProfesseurDetailsScreenState createState() =>
      _ProfesseurDetailsScreenState();
}

class _ProfesseurDetailsScreenState extends State<ProfesseurDetailsScreen> {
  // Map<String, dynamic>? professeurData;
  Map<String, dynamic>? userData;
  // List<dynamic>? matieres;

  @override
  void initState() {
    super.initState();
    fetchProfesseurDetail(widget.profId);
    print(widget.profId);
    fetchMatiere().then((data) {
      setState(() {
        matiereList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
  }

  Map<String, dynamic>? professeurData;
  List<dynamic> matieres = [];
  List<Matiere> matiereList = [];
  Matiere getMatIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final mat = matiereList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Matiere(id: '', name: '',  categorieId: '', categorie_name: '', code: '',));
    // print(professeur.name);
    return mat; // Return the ID if found, otherwise an empty string

  }

  Future<void> fetchProfesseurDetail(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    final response = await http.get(
      Uri.parse('http://192.168.43.73:5000/professeur/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(id);
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      professeurData = jsonResponse['professeur'];
      matieres = jsonResponse['matieres'];

      print(professeurData);
    } else {
      print('Échec de la récupération des données du professeur');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: ListView(
          children: [
            // Professor Info Table
            SingleChildScrollView(scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // CircleAvatar(
                  //   radius: 80,
                  //   backgroundImage: NetworkImage(
                  //       'https://th.bing.com/th/id/R.8b167af653c2399dd93b952a48740620?rik=%2fIwzk0n3LnH7dA&pid=ImgRaw&r=0'),
                  // ),
                  SizedBox(child: Container(
                    child: Center(
                      child: Text("Mes Iformations", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold ,color: Colors.black,
                        fontSize: 20,),),
                    ),
                    // color: Colors.blue,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                        ),
                      ],
                    ),

                    width: 370, height: 50,)
                  ),

                  SizedBox(
                    height: 12.0,
                  ),
                  Container(     width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    margin: EdgeInsets.only(left: 5, right: 10),
                    padding: EdgeInsets.only(left: 40, right: 38),
                    child: DataTable(
                      showCheckboxColumn: true,
                      showBottomBorder: true,
                      headingRowHeight: 50,
                      columnSpacing: 55,
                      dataRowHeight: 50,
                      columns: [
                        DataColumn(label: Text('Property')),
                        DataColumn(label: Text('Value')),
                      ],
                      rows: [
                        DataRow(
                            cells: [
                              DataCell(Text('Name')),
                              DataCell(Text('${widget.nom} ')),
                            ]),
                        DataRow(
                            cells: [
                              DataCell(Text('Email')),
                              DataCell(Text('${widget.mail} ')),
                            ]),
                        DataRow(cells: [
                          DataCell(Text('Compte')),
                          DataCell(Text('${professeurData?['compte']}')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Banque')),
                          DataCell(Text('${professeurData?['banque']}')),
                        ]),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            Divider(), // Add a divider between professor info and matieres

            // Matieres Table
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(child: Container(child: Center(
                  child: Text("Mes Matieres", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold ,color: Colors.black,
                    fontSize: 20,),),
                ),
                  // color: Colors.blue,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                      ),
                    ],
                  ),

                  width: 370, height: 50,)),


                SingleChildScrollView(scrollDirection: Axis.horizontal,
                  child: Container(     width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black12,
                      //     blurRadius: 5,
                      //   ),
                      // ],

                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),

                    // margin: EdgeInsets.only(left: 10),
                    // padding: EdgeInsets.only(left: 25, right: 23),

                    child: DataTable(
                      showCheckboxColumn: true,
                      showBottomBorder: true,
                      headingRowHeight: 50,
                      columnSpacing: 13,
                      dataRowHeight: 50,
                      // headingRowColor: MaterialStateColor.resolveWith((states) =>  Colors.blue,), // Set row background color
                      columns: [
                        DataColumn(label: Text('Code')),
                        DataColumn(label: Text('Nom')),
                        DataColumn(label: Text('Prix')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: [
                        for (var matiere in matieres)
                          DataRow(cells: [
                            DataCell(Text(matiere['code']!)),
                            DataCell(Text(matiere['name']!)),
                            DataCell(Text(matiere['prix'].toString()!)),
                            // DataCell(Text(getMatIdFromName(matiere).name)),
                            // DataCell(Text(getMatIdFromName(matiere).taux.toString())),
                            DataCell(
                              ElevatedButton(
                                onPressed: (){
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),elevation: 1,
                                        title: Text('Supprimer Matiere'),
                                        content: Text('Voulez vous supprimer: ${matiere['name']}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Close the dialog
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Close the dialog
                                              String profId = professeurData?['_id']!;
                                              String matiereId = matiere['_id']; // Replace 'matiere' with the actual matiere data
                                              deleteMatiereFromProfesseur(profId, matiereId);
                                              setState(() {
                                                Navigator.pop(context);
                                              });ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text('La matiere est Supprimer avec succès.',)),);

                                            },
                                            child: Text('Supprimer'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },

                                child: Icon(Icons.delete, color: Colors.red),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  elevation: 0,
                                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                                ),

                              ),
                            ),
                          ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20), // Add a divider between professor info and matieres
            Container(margin:EdgeInsets.only(left: 80,right: 80,bottom: 20 ,top: 10),height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),backgroundColor: Colors.white,elevation: 10),
                onPressed: () => _displayTextInputDialog(context,widget.profId!),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add,size: 28,color: Colors.black,),
                    Text(' Matiere', style: TextStyle(fontSize: 17,fontStyle: FontStyle.italic,color: Colors.black),)
                  ],
                ),
                // tooltip: 'Add Category',
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context, String id) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AddMat(id:id);
      },
    );
  }
}




Future<void> deleteMatiereFromProfesseur(String profId, String matiereId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;

  final url = 'http://192.168.43.73:5000/professeur/$profId/$matiereId';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final response = await http.delete(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    // You can handle the response data here if needed
    print('Ok le matiere est supprimer');

    print(responseData);
  } else {
    // Handle errors
    print('Failed to delete matiere from professeur. Status Code: ${response.statusCode}');
  }
}

Future<void> addMatiereToProfesseus( id,String matiereId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;

  final url = 'http://192.168.43.73:5000/professeur/$id';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final body = json.encode({
    'matieres': [matiereId],
  });

  final response = await http.post(Uri.parse(url), headers: headers, body: body);

  // print(response.statusCode);
  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    // You can handle the response data here if needed
    print(responseData);
  } else {
    // Handle errors
    print('Failed to add matiere to professeus. Status Code: ${response.statusCode}');
  }
}


class AddMat extends StatefulWidget {
  String id;
   AddMat({Key? key, required this.id}) : super(key: key);

  @override
  State<AddMat> createState() => _AddMatState();
}

class _AddMatState extends State<AddMat> {
  Matiere? selectedMat; // initialiser le type sélectionné à null

  @override
  void initState()  {
    super.initState();
    fetchCategories();
  }
  Category? selectedCateg; // initialiser le type sélectionné à null
  Future<void> fetchCategories() async {
    List<Category> fetchedCategories = await fetchCategory();
    setState(() {
      categories = fetchedCategories;
    });
  }

  // Future<Map<String, dynamic>> types =await  fetchProfessorInfo() ;
  // _id.text = items![index].name;
  Category? selectedCategory;
  List<Matiere> matieres = [];
  List<Category> categories =  [];
  Future<void> updateMatiereList() async {
    if (selectedCategory != null) {
      List<Matiere> fetchedmatieres = await fetchMatieresByCategory(selectedCategory!.id);
      setState(() {
        matieres = fetchedmatieres;
      });
    } else {
      List<Matiere> fetchedmatieres = await fetchMatiere();
      setState(() {
        matieres = fetchedmatieres;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter une Matiere'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Text(
              "Selection d'une Categorie:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                fillColor: Colors.white,
                hintText: "....",hintStyle: TextStyle(fontSize: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
             "Selection d'une Matiere",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<Matiere>(
              value: selectedMat,
              items: matieres.map((matiere) {
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
                fillColor: Colors.white,
                hintText: "....",hintStyle: TextStyle(fontSize: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),


            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                print("AbdouId: ${widget.id}"); // Use the professor's ID in the addMatiereToProfesseus method
                print(selectedMat!.id!);

                addMatiereToProfesseus(widget.id, selectedMat!.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Matiere has been added to professor successfully.')),
                );

                setState(() {
                  // fetchProfesseurDetail(professorId);
                });
              },
              child: Text("Ajouter"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff0fb2ea),
                foregroundColor: Colors.white,
                elevation: 10,
                padding: EdgeInsets.only(left: 90, right: 90),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            )
          ],
        )
    );

  }
}

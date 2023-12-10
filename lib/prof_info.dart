import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_payements/matieres.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'Ajout.dart';
import 'Cours.dart';
import 'Dashboard.dart';
import 'ProfCours.dart';
import 'categories.dart';
import 'main.dart';

class ProfesseurInfoPage extends StatefulWidget {
  final String? id;
  final String? email;
  final String? role;

  ProfesseurInfoPage({ this.email,  this.role, this.id});

  @override
  State<ProfesseurInfoPage> createState() => _ProfesseurInfoPageState();
}

class _ProfesseurInfoPageState extends State<ProfesseurInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Text("Mon Profile",style: TextStyle(fontSize: 25),)
              ],
            ),
          ),

          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                  future: fetchProfessorInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final professor = snapshot.data as Map<String, dynamic>;
                      if (professor['status'] == 'success') {
                        return ProfessorDetailsWidget(professor: professor['professeur']);
                      } else {
                        return Center(child: Text('No professor found with that EMAIL'));
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),

      // floatingActionButton: Container(margin:EdgeInsets.only(left: 230),height: 40,
      //   child: ElevatedButton(
      //     style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black,  elevation: 10,
      //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      //     onPressed: () => _displayTextInputDialog(context),
      //     child: Row(
      //       children: [
      //         Icon(Icons.add,size: 24,color: Colors.blue,),
      //         Text('add Matiere', style: TextStyle(fontSize: 14,fontStyle: FontStyle.italic,color: Colors.blue),)
      //       ],
      //     ),
      //     // tooltip: 'Add Category',
      //   ),
      // ),

    //bottomNavigationBar: BottomNav(),
    );


  }




}

Future<Map<String, dynamic>> fetchProfessorInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  String email1 = prefs.getString("email")!;
  print(email1);
  final url = 'http://192.168.43.73:5000/professeur/$email1/email';
  final response = await http.get(Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },);

  print(response.statusCode);
  if (response.statusCode == 200) {
    // print(response.body);
    return json.decode(response.body);
  } else {
    throw Exception('Failed to fetch professor information');
  }
}

class ProfessorDetailsWidget extends StatefulWidget {
  final Map<String, dynamic> professor;

  ProfessorDetailsWidget({required this.professor});

  @override
  State<ProfessorDetailsWidget> createState() => _ProfessorDetailsWidgetState();
}

class _ProfessorDetailsWidgetState extends State<ProfessorDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
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
                margin: EdgeInsets.only(left: 10, right: 10),
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
                      DataCell(Text('${widget.professor['nom']} ${widget.professor['prenom']}')),
                    ]),
                    DataRow(
                        cells: [
                      DataCell(Text('Email')),
                      DataCell(Text('${widget.professor['email']}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Mobile')),
                      DataCell(Text('${widget.professor['mobile']}')),
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
                    DataColumn(label: Text('Matiere')),
                    // DataColumn(label: Text('Description')),
                    // DataColumn(label: Text('Prix')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: [
                    for (var matiere in widget.professor['matieres'])
                      DataRow(cells: [
                        DataCell(Text(matiere)),
                        // DataCell(Text('${matiere['description']}')),
                        // DataCell(Text('${matiere['categorie']['prix']}')),
                        DataCell(
                          ElevatedButton(
                            onPressed: () => _showDeleteConfirmationDialog(context, matiere), // Disable button functionality
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
        Container(margin:EdgeInsets.only(left: 10,right: 10,bottom: 20),height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),backgroundColor: Colors.white,elevation: 10),
            onPressed: () => _displayTextInputDialog(context),
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
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AddMat();
      },
    );
  }



  void _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> matiere) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Supprimer Matiere'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),elevation: 1,
          content: Text('Etes-vous sûr que vous voulez supprimer: ${matiere['name']}?'),
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
                String profId = widget.professor['id'];
                String matiereId = matiere['id']; // Replace 'matiere' with the actual matiere data
                deleteMatiereFromProfesseur(profId, matiereId);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('La matiere est Supprimer avec succès.',)),);

              },
              child: Text('Supprimer'),
            ),
          ],
        );
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
  const AddMat({Key? key}) : super(key: key);

  @override
  State<AddMat> createState() => _AddMatState();
}

class _AddMatState extends State<AddMat> {
  Matiere? selectedMat; // initialiser le type sélectionné à null

  @override
  void initState()  {
    super.initState();
    fetchCategories();
    fetchProfs();
  }
  String professorId = '';
  Category? selectedCateg; // initialiser le type sélectionné à null
  Future<void> fetchCategories() async {
    List<Category> fetchedCategories = await fetchCategory();
    setState(() {
      categories = fetchedCategories;
    });
  }
  Future<void> fetchProfs() async {
    final professorData = await fetchProfessorInfo();
    setState(() {
       professorId = professorData['professeur']['_id'];
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
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String token = prefs.getString("token")!;

                print(professorId); // Use the professor's ID in the addMatiereToProfesseus method
                print(selectedMat!.id!);

                addMatiereToProfesseus(professorId, selectedMat!.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Matiere has been added to professor successfully.')),
                );

                setState(() {
                  fetchProfessorInfo();
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

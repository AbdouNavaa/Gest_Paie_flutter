import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_payements/matieres.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

   
import 'Cours.dart';
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
    print(widget.profId);
    fetchMatiere().then((data) {
      setState(() {
        matiereList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchProfesseurDetail(widget.profId);

  }

  TextEditingController _mobile = TextEditingController();
  TextEditingController _compte = TextEditingController();
  String _banque = 'BMCI';

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

      setState(() {
        professeurData = jsonResponse['professeur'];
        matieres = jsonResponse['matieres'];
      });

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

                  // SizedBox(height: 40,),
                  Container(
                    height: 50,
                    child: Row(
                      children: [
                        TextButton(onPressed: (){
                          Navigator.pop(context);
                        }, child: Icon(Icons.arrow_back_ios,color: Colors.black,size: 20,)),
                        // SizedBox(width: 3,),
                        Text('Page de Profile',style: TextStyle(fontSize: 20),),
                      ],
                    ),
                  ),

                  Divider(),
                  // SizedBox(height: 10,),
                  SizedBox(child: Container(
                    child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Mes Iformations", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold ,color: Colors.black,
                          fontSize: 20,),),
                        IconButton(
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
                                          Text("Modifier Profile", style: TextStyle(fontSize: 25),),
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
                                              //hmmm
                                              SizedBox(height: 40),
                                              TextFormField(
                                                controller: _mobile,
                                                // initialValue: professeurData!['info']['mobile'].toString()!,
                                                keyboardType: TextInputType.text,
                                                // maxLines: 3,
                                                decoration: InputDecoration(
                                                    filled: true,

                                                    // fillColor: Color(0xA3B0AF1),
                                                    fillColor: Colors.white,
                                                    hintText: "Mobile",
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide.none,gapPadding: 1,
                                                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                              ),

                                              SizedBox(height: 30),
                                              TextFormField(
                                                controller: _compte,
                                                decoration: InputDecoration(
                                                    filled: true,

                                                    // fillColor: Color(0xA3B0AF1),
                                                    fillColor: Colors.white,
                                                    hintText: "Compte",
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide.none,gapPadding: 1,
                                                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                              ),

                                              SizedBox(height: 30),
                                               DropdownButtonFormField<String>(
                                                value: _banque,

                                                items: [
                                                  DropdownMenuItem<String>(
                                                    child: Text('BMCI'),
                                                    value: 'BMCI',
                                                  ),
                                                  DropdownMenuItem<String>(
                                                    child: Text('BNM'),
                                                    value: 'BNM',
                                                  ),
                                                  DropdownMenuItem<String>(
                                                    child: Text('ORABANK'),
                                                    value: 'ORABANK',
                                                  ),
                                                ],
                                                onChanged: (value) {
                                                  setState(() {
                                                    _banque = value!;
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

                                              SizedBox(height: 30),
                                              ElevatedButton(
                                                onPressed: () async{
                                                  Navigator.of(context).pop();


                                                  String professeurId = widget.profId; // Remplacez par l'ID de votre professeur
                                                  Map<String, dynamic> updatedData = {
                                                    'info': {
                                                      'mobile': _mobile.text, // Remplacez par la nouvelle valeur
                                                      'accountNumero': _compte.text, // Remplacez par la nouvelle valeur
                                                      'banque': _banque, // Remplacez par la nouvelle valeur
                                                    },
                                                  };

                                                  await updateProfesseurInfo(professeurId, updatedData);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Le Type est mis à jour avec succès.')),
                                                  );

                                                  setState(() {
                                                    Navigator.pop(context);
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
                            }, // Disable button functionality
                            icon: Icon(Icons.edit,color: Colors.green,))
                      ],
                    ),
                    // color: Colors.blue,
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 5,
                        ),
                      ],
                    ),

                    margin: EdgeInsets.only(left: 25,right: 26),

                    width: MediaQuery.of(context).size.width - 40, height: 50,)),


                  // SizedBox(
                  //   height: 12.0,
                  // ),
                  Card(
                    elevation: 3,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 350,
                      decoration: BoxDecoration(
                        color: Colors.white60,shape: BoxShape.rectangle,
                      ),

                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 10,),
                              Icon(Icons.person_outline_outlined),

                              SizedBox(width: 30,),
                              Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nom',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17,fontStyle: FontStyle.italic),),
                                  Row(
                                    children: [
                                      Text('${widget.nom.capitalizeFirst} ${professeurData?['prenom'].toString().capitalizeFirst}',style: TextStyle(fontSize: 17,fontStyle: FontStyle.italic),),
                                      // SizedBox(width: 90,),
                                      // Icon(Icons.arrow_forward_ios)
                                    ],
                                  ),


                                ],
                              )
                            ],
                          ),

                          // Divider(color: Colors.black38,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 10,),
                              Icon(Icons.email_outlined),

                              SizedBox(width: 30,),
                              Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('E-mail',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17,fontStyle: FontStyle.italic),),
                                  Text('${widget.mail}',style: TextStyle(fontSize: 17,fontStyle: FontStyle.italic),),
                                ],
                              )
                            ],
                          ),
                          // Divider(color: Colors.black38,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 10,),
                              Icon(Icons.call_outlined),

                              SizedBox(width: 30,),
                              Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mobile',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17,fontStyle: FontStyle.italic),),
                                  Text('${professeurData?['info']['mobile']}',style: TextStyle(fontSize: 17,fontStyle: FontStyle.italic),),
                                ],
                              )
                            ],
                          ),
                          // Divider(color: Colors.black38,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 10,),
                              Icon(Icons.account_balance_outlined),

                              SizedBox(width: 30,),
                              Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Banque',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17,fontStyle: FontStyle.italic),),
                                  Text('${professeurData?['info']['banque']}',style: TextStyle(fontSize: 17,fontStyle: FontStyle.italic),),
                                ],
                              )
                            ],
                          ),
                          // Divider(color: Colors.black38,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 10,),
                              Icon(Icons.account_box_outlined),

                              SizedBox(width: 30,),
                              Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Compte Bancaire',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17,fontStyle: FontStyle.italic),),
                                  Text('${professeurData?['info']['accountNumero']}',style: TextStyle(fontSize: 17,fontStyle: FontStyle.italic),),
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 10,)
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),

            SizedBox(height: 20,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(child: Container(child: Text("Mes Matières", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold ,color: Colors.black,
                  fontSize: 20,),),
                  // color: Colors.blue,
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 28,right: 28),

                  width: MediaQuery.of(context).size.width - 40, height: 50,)),


                SingleChildScrollView(scrollDirection: Axis.horizontal,
                  child: Card(
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(15),
                    // ),
                    margin: EdgeInsets.only(left: 24,right: 50),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      // width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.black12,
                        //     blurRadius: 5,
                        //   ),
                        // ],

                        // borderRadius: BorderRadius.circular(15),

                      ),
                    
                      // margin: EdgeInsets.only(left: 28,right: 50),
                      child: DataTable(
                        showCheckboxColumn: true,
                        showBottomBorder: true,
                        border: TableBorder(left: BorderSide(width: 1,color: Colors.black12),right: BorderSide(width: 1,color: Colors.black12)),
                        headingRowHeight: 50,
                        columnSpacing: 13,
                        dataRowHeight: 50,
                        // headingRowColor: MaterialStateColor.resolveWith((states) =>  Colors.blue,), // Set row background color
                        columns: [
                          // DataColumn(label: Text('Code')),
                          DataColumn(label: Text('Nom')),
                          DataColumn(label: Text('Prix')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: [
                          for (var matiere in matieres)
                            DataRow(cells: [
                              // DataCell(Text(matiere['code']!)),
                              DataCell(Text(matiere['name']!)),
                              DataCell(Text(matiere['prix'].toString()!)),
                              // DataCell(Text(getMatIdFromName(matiere).name)),
                              // DataCell(Text(getMatIdFromName(matiere).taux.toString())),
                              DataCell(
                                TextButton(
                                  onPressed: (){
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          surfaceTintColor: Color(0xB0AFAFA3),
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
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
                    
                                  child: Icon(Icons.delete_outlined, color: Colors.black26),
                                  style: TextButton.styleFrom(
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
                ),
              ],
            ),

            // SizedBox(height: 20), // Add a divider between professor info and matieres
            // Container(margin:EdgeInsets.only(left: 80,right: 80,bottom: 20 ,top: 10),height: 45,
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),backgroundColor: Colors.white,elevation: 10),
            //     onPressed: () => _displayTextInputDialog(context,widget.profId!),
            //     child: Row(mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Icon(Icons.add,size: 28,color: Colors.black,),
            //         Text(' Matiere', style: TextStyle(fontSize: 17,fontStyle: FontStyle.italic,color: Colors.black),)
            //       ],
            //     ),
            //     // tooltip: 'Add Category',
            //   ),
            // ),

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

Future<void> updateProfesseurInfo(String id, Map<String, dynamic> data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;

  final String apiUrl = "http://192.168.43.73:5000/professeur" + "/$id"; // Mettez à jour l'URL de votre API

  final http.Response response = await http.patch(
    Uri.parse(apiUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
      // Ajoutez d'autres en-têtes au besoin, par exemple, le jeton d'authentification.
    },
    body: jsonEncode(data),
  );

  if (response.statusCode == 201) {
    print('Mise à jour réussie');
    // Gérez la réponse réussie ici, si nécessaire.

  } else {
    print('Échec de la mise à jour - StatusCode: ${response.statusCode}');
    // Gérez l'échec de la mise à jour ici, si nécessaire.
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
        surfaceTintColor: Color(0xB0AFAFA3),
        backgroundColor: Colors.white,
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

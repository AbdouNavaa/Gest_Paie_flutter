import 'package:flutter/material.dart';
import 'package:gestion_payements/matieres.dart';
import 'package:gestion_payements/prof_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Dashboard.dart';
import 'Ajout.dart';
import 'Cours.dart';
import 'categories.dart';





class Professeures extends StatefulWidget {
  Professeures({Key ? key}) : super(key: key);

  @override
  _ProfesseuresState createState() => _ProfesseuresState();
}

class _ProfesseuresState extends State<Professeures> {

  Future<List<Professeur>>? futureProfesseur;

  List<Professeur>? filteredItems;

  Matiere? selectedMat;
  List<Matiere> matieres = [];
  Category? selectedCategory;
  List<Category> categories = [];
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
        matieres = fetchedmatieres;
      });
    } else {
      List<Matiere> fetchedmatieres = await fetchMatiere();
      setState(() {
        matieres = fetchedmatieres;
      });
    }
  }

  void DeleteProfesseur(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/professeur' +"/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchProfs();
    }

  }
  Future<List<Matiere>> fetchMatieresByCategory(String categoryId) async {
    String apiUrl = 'http://192.168.43.73:5000/categorie/$categoryId/matieres';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> matieresData = responseData['matieres'];
        // print(categoryId);
        // print(matieresData);
        List<Matiere> matieres = matieresData.map((data) => Matiere.fromJson(data)).toList();
        // print(matieres);
        return matieres;
      } else {
        throw Exception('Failed to fetch matières by category');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfs().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Professeuresseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

    fetchCategories();
  }
  TextEditingController _searchController = TextEditingController();

  TextEditingController _name = TextEditingController();
  TextEditingController _prenom = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _matieres = TextEditingController();


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
              child: TextField(
                controller: _searchController,
                onChanged: (value) async {
                  List<Professeur> Professeurs = await fetchProfs();

                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les Professeuresseurs dont le name ou le préname contient la valeur saisie
                    filteredItems = Professeurs!.where((professeur) =>
                    professeur.nom!.toLowerCase().contains(value.toLowerCase()) ||
                        professeur.prenom!.toLowerCase().contains(value.toLowerCase())).toList();
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
            Container(width: 200,height: 50,
                // color: Colors.black87,
                // margin: EdgeInsets.all(8),
                child: Card(
                    elevation: 5,
                    // margin: EdgeInsets.only(top: 10),
                    shadowColor: Colors.blue,
                    // color: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(' ${filteredItems?.length} Professeurs',style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),)))),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: FutureBuilder<List<Professeur>>(
                    future: fetchProfs(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<Professeur>? items = snapshot.data;

                          return  SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                              margin: EdgeInsets.only(left: 10),
                              child: DataTable(
                                showCheckboxColumn: true,
                                showBottomBorder: true,
                                headingRowHeight: 50,
                                horizontalMargin: 2,
                                columnSpacing: 3,
                                dataRowHeight: 50,
                                headingTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // Set header text color
                                ),
                                headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFF0C2FDA)), // Set row background color
                                columns: [
                                  DataColumn(label: Text('#')),
                                  DataColumn(label: Text('Nom')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Mobile')),
                                  DataColumn(label: Text('Matieres')),
                                  DataColumn(label: Text('Action')),
                                ],
                                rows: [
                                  for (var index = 0; index < (filteredItems?.length ?? 0); index++)
                                      DataRow(
                                      cells: [
                                        DataCell(Text('${index +1}',style: TextStyle(fontSize: 15),)), // Numbering cell
                                        DataCell(Container(width: 70,
                                            child: Text('${filteredItems?[index].nom } ${filteredItems?[index].prenom}'))),
                                        DataCell(Container(width: 150,
                                            child: Text('${filteredItems?[index].email}',)),),
                                        DataCell(Container(width: 68,
                                            child: Text('${filteredItems?[index].mobile}',)),),
                                        DataCell(
                                          Container(
                                            width: 80,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                for (var matiere in items![index].matieres) // Assuming items![index].matieres is a list of matieres for the professor
                                                  Center(child: InkWell(
                                                    onTap: (){
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
                                                                  String profId = items![index].id!;
                                                                  String matiereId = matiere['_id']; // Replace 'matiere' with the actual matiere data
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
                                                    },hoverColor: Colors.redAccent,
                                                      child: Text(matiere['name'] ?? ''))),
                                              ],
                                            ),
                                          ),
                                        ),



                                        DataCell(
                                          Row(
                                            children: [
                                              Container(
                                                width: 35,
                                                child: TextButton(
                                                  onPressed:() =>_AddProfMatriere(context,items![index].id!),
                                                  child: Icon(Icons.add, color: Colors.blue),
                                                  style: TextButton.styleFrom(
                                                    primary: Colors.white,
                                                    elevation: 0,
                                                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 35,
                                                child: TextButton(
                                                  onPressed:() {
                                                    _name.text = items![index].nom!;
                                                    _prenom.text = items![index].prenom!;
                                                    _mobile.text = items![index].mobile!.toString();
                                                    _email.text = items![index].email!;
                                                    // _matieres.text = items![index].matieres!;
                                                    // _selectedTaux = items![index].email!;
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: Text("Mise à jour de la tâche"),
                                                          content: Form(
                                                            child: SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  TextFormField(
                                                                    controller: _name,
                                                                    decoration: InputDecoration(labelText: 'Name'),
                                                                  ),
                                                                  TextFormField(
                                                                    controller: _prenom,
                                                                    decoration: InputDecoration(labelText: 'Prenom'),
                                                                  ),
                                                                  TextFormField(
                                                                    controller: _mobile,
                                                                    decoration: InputDecoration(labelText: 'Mobile'),
                                                                  ),
                                                                  TextFormField(
                                                                    controller: _email,
                                                                    decoration: InputDecoration(labelText: 'Email'),
                                                                  ),
                                                                  SizedBox(height: 16),
                                                                  Text(
                                                                    "selection d'une Categorie:",
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
                                                                      hintText: "selection d'une Categorie",
                                                                      border: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 16),
                                                                  Text(
                                                                    "selection d'une Matiere",
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
                                                                      hintText: "selection d'une Matiere",
                                                                      border: OutlineInputBorder(
                                                                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              child: Text("ANNULER"),
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: Text(
                                                                "MISE À JOUR",
                                                                style: TextStyle(color: Colors.blue),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.of(context).pop();

                                                                fetchProfs();
                                                                // AddProfesseur(_name.text, _desc.text);
                                                                print(items![index].id!);
                                                                UpdateCateg(items![index].id!, _name.text, _prenom.text, _email.text,num.parse(_mobile.text));
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(content: Text('Le Type est mis à jour avec succès.')),
                                                                );

                                                                setState(() {
                                                                  fetchProfs();
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Icon(Icons.edit, color: Colors.lightGreen),
                                                  style: TextButton.styleFrom(
                                                    primary: Colors.white,
                                                    elevation: 0,
                                                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 35,
                                                child: TextButton(
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
                                                                DeleteProfesseur(snapshot.data![index].id);
                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(content: Text('Le Professeur a été Supprimer avec succès.')),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },

                                                  child: Icon(Icons.delete, color: Colors.red),
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
                                      ],
                                    ),
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
          tooltip: 'Ajouter un Professeur',
          backgroundColor: Colors.white,
          label: Row(
            children: [Icon(Icons.add,color: Colors.black,)],
          ),
          onPressed: () => _displayTextInputDialog(context),

        ),


      ),
      bottomNavigationBar: BottomNav(),

    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    // TextEditingController _name = TextEditingController();
    // TextEditingController _description = TextEditingController();
    // TextEditingController _prix = TextEditingController();
    // num _selectedTaux = 500;


    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text('Ajouter un Professeur'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _name,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "name",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    ),
                    TextField(
                      controller: _prenom,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Prenom",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    ),
                    TextField(
                      controller: _mobile,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Mobile",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    ),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Email",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                    ),
                    ElevatedButton(onPressed: (){
                      Navigator.of(context).pop();
                      fetchProfs();
                      AddProfesseur(_name.text,_prenom.text,_email.text,num.parse(_mobile.text));
                      // AddProfesseur(_name.text, _desc.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Le Professeur a été ajouter avec succès.')),
                      );
                      setState(() {
                        Navigator.of(context).pop();
                      });
                    }, child: Text("Ajouter"),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0C2FDA),
                        foregroundColor: Colors.white,
                        elevation: 10,
                        padding: EdgeInsets.only(left: 90, right: 90),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),)
                  ],
                ),
              )
          );
        });
  }

  Future<void> _AddProfMatriere(BuildContext context,String Id) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AddProfMat(profId: Id,);
      },
    );
  }

  void AddProfesseur (String name,String prenom,String email,[num? mobile]) async {

    // Check if the prix parameter is provided, otherwise use the default value of 100
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/professeur/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "nom":name,
        "prenom":prenom ,
        "mobile": mobile,
        "email": email ,
      }),
    );
    if (response.statusCode == 200) {
      print('Professeur ajouter avec succes');
    } else {
      print("SomeThing Went Wrong");
    }
  }

  void UpdateCateg( id,String name,String prenom, String email,[num? mobile]) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.patch(
      Uri.parse("http://192.168.43.73:5000/categorie" + "/$id"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "nom":name,
        "prenom":prenom ,
        "mobile": mobile ,
        "email": email ,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      // Fetch the updated list of Matieres and update the UI
      fetchProfs().then((data) {
        setState(() {
          filteredItems = data;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des Matieres: $error');
      });
    } else {
      return Future.error('Server Error');
      print(
          '4e 5asser sa77bi mad5al======================================');
    }
  }
}

class Professeur {
  String id;
  String nom;
  String prenom;
  int mobile;
  String email;
  List matieres; // Change this field to be of type List<String>

  Professeur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.mobile,
    required this.email,
    required this.matieres, // Update the constructor parameter
  });

  // Add a factory method to create a Professeur object from a JSON map
  factory Professeur.fromJson(Map<String, dynamic> json) {
    return Professeur(
      id: json['_id'],
      nom: json['nom'],
      prenom: json['prenom'],
      mobile: json['mobile'],
      email: json['email'],
      matieres: List.from(json['matieres']), // Convert the 'matieres' list to List<String>
    );
  }
}

class AddProfMat extends StatefulWidget {
  final String profId;
  const AddProfMat({Key? key, required this.profId}) : super(key: key);

  @override
  State<AddProfMat> createState() => _AddProfMatState();
}

class _AddProfMatState extends State<AddProfMat> {
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
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String token = prefs.getString("token")!;

                print(widget.profId); // Use the professor's ID in the addMatiereToProfesseus method
                print(selectedMat!.id!);

                addMatiereToProfesseus(widget.profId, selectedMat!.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Matiere has been added to professor successfully.')),
                );

                setState(() {
                  fetchProfs();
                });
              },
              child: Text("Ajouter"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0C2FDA),
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

Future<List<Professeur>> fetchProfs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/professeur/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print(response.statusCode);
  // print(response.body);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    List<dynamic> professeursData = jsonResponse['professeurs'];

    // print(matieresData);
    List<Professeur> profs = professeursData.map((item) {
      return Professeur.fromJson(item);
    }).toList();

    print("Prof List: $profs");
    return profs;
  } else {
    throw Exception('Failed to load Matiere');
  }
}




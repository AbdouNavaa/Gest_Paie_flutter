import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Ajout.dart';
import 'Cours.dart';
import 'categories.dart';
import 'matieres.dart';

class UpdateCoursDialog extends StatefulWidget {
  final Map<String, dynamic> courses;

  UpdateCoursDialog({required this.courses});
  @override
  _UpdateCoursDialogState createState() => _UpdateCoursDialogState();
}

class _UpdateCoursDialogState extends State<UpdateCoursDialog> {
  List<Map<String, dynamic>> selectedTypes = [];
  List<Map<String, dynamic>> availableTypes = [
    {"name": "CM", "nbh": 1.5},
    {"name": "CM", "nbh": 2},
    {"name": "TP", "nbh": 1.5},
    {"name": "TP", "nbh": 1},
    {"name": "TD", "nbh": 1.5},
    {"name": "TD", "nbh": 1},
    // Add more available types here as needed
  ];
  Category? selectedCategory;
  Matiere? selectedMat;
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];
  List<Professeur> professeurList = [];
  List<Matiere> matieres = [];
  List<Matiere> matiereList = [];
  DateTime? selectedDateTime;
  List<Category> categories = [];
  bool _selectedSigne = false;
  TextEditingController _date = TextEditingController();
  TextEditingController _isSigne = TextEditingController();
  late String mat ;
  late String prof ;

  bool showMatDropdown = false;
  bool showProfDropdown = false;

  @override
  void initState()  {
    super.initState();
    fetchCategories();
    fetchMats();
    fetchproffs();
    fetchProfs();
    _date.text = DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(widget.courses['date'])).toString();
    _selectedSigne = widget.courses['isSigne'];
    mat = widget.courses['matiere'];
    prof = widget.courses['professeur'];
  }

  Future<void> fetchCategories() async {
    List<Category> fetchedCategories = await fetchCategory();
    setState(() {
      categories = fetchedCategories;
    });
  }
  Future<void> fetchMats() async {
    List<Matiere> fetchedMats = await fetchMatiere();
    setState(() {
      matiereList = fetchedMats;
    });
  }
  Future<void> fetchproffs() async {
    List<Professeur> fetchedProfs = await fetchProfs();
    setState(() {
      professeurList = fetchedProfs;
    });
  }
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

  Future<void> updateMatiereList() async {
    if (selectedCategory != null) {
      List<Matiere> fetchedmatieres = await fetchMatieresByCategory(selectedCategory!.id);
      setState(() {
        matieres = fetchedmatieres;
        selectedProfesseur = null;
      });
    } else {
      List<Matiere> fetchedmatieres = await fetchMatiere();
      setState(() {
        matieres = fetchedmatieres;
        selectedProfesseur = null;
      });
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

  String getProfesseurIdFromName(String name) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = professeurList.firstWhere((prof) => '${prof.nom} ${prof.prenom}' == name, orElse: () => Professeur(id: '', nom: '', prenom: '', mobile: 0, email: '', matieres: []));
    return professeur?.id ?? ''; // Return the ID if found, otherwise an empty string
  }

  String getMatiereIdFromName(String name) {
    // Assuming you have a list of matieres named 'matieresList'
    final matiere = matiereList.firstWhere((mat) => mat.name == name, orElse: () => Matiere(id: '', name: '', description: '', categorieId: '', semestres: []));
    return matiere?.id ?? ''; // Return the ID if found, otherwise an empty string
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: Text("Mise à jour de la tâche"),
        content: Form(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 110,
                  child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                    child: Row(
                      children: availableTypes.map((type) {
                        return CheckboxMenuButton(
                          value: selectedTypes.contains(type),
                          onChanged: (value) {
                            setState(() {
                              if (selectedTypes.contains(type)) {
                                selectedTypes.remove(type);
                              } else {
                                selectedTypes.add(type);
                              }
                            });
                          },child: Text(type['name'] + ' - ' + type['nbh'].toString()),
                        );
                      }).toList(),
                    ),
                  ),
                ),
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
                  onChanged: (value) async {
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
                    hintText: "....",hintStyle: TextStyle(fontSize: 15),
//                    hintText: "selection d'une Categorie",
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

                showMatDropdown ?
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
                      selectedProfesseur = null; // Reset the selected professor
                      // professeurs = await fetchProfesseursByMatiere(selectedMat!.id); // Clear the professeurs list when a matière is selected
                      updateProfesseurList(); // Update the list of professeurs based on the selected matière
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "....",hintStyle: TextStyle(fontSize: 15),
//                    hintText: "selection d'une Matiere",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                )
              : TextFormField(
                  initialValue: mat,
                  decoration: InputDecoration(labelText: 'Nom du Catégorie'),
                  readOnly: true,
                  onTap: () {
                    setState(() {
                      showMatDropdown = true;
                    });
                  },
                ),
                SizedBox(height: 16),
                Text(
                  "selection d'un Professeur:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                showProfDropdown ?
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
                    fillColor: Colors.white,
                    hintText: "....",hintStyle: TextStyle(fontSize: 15),
                    // hintText: "selection d'un Professeur", // Update the hintText
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                )
                    : TextFormField(
                  initialValue: prof,
                  decoration: InputDecoration(labelText: 'Nom du Catégorie'),
                  readOnly: true,
                  onTap: () {
                    setState(() {
                      showProfDropdown = true;
                    });
                  },
                ),


                SizedBox(height: 16),

                SizedBox(height: 16),
                TextFormField(
                  controller: _date,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  // readOnly: true,
                  onTap: () => selectTime(_date),
                ),

                SizedBox(height: 16,),
                DropdownButtonFormField<bool>(
                  value: _selectedSigne,
                  items: [
                    DropdownMenuItem<bool>(
                      child: Text('True'),
                      value: true,
                    ),
                    DropdownMenuItem<bool>(
                      child: Text('False'),
                      value: false,
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSigne = value!;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
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
            onPressed: () async {
              Navigator.of(context).pop(true);

              _isSigne.text = _selectedSigne.toString();

              DateTime date = DateFormat('yyyy/MM/dd HH:mm').parse(_date.text).toUtc();
              Navigator.of(context).pop();

              if (showMatDropdown && showProfDropdown) {
                // No changes, directly use the selected IDs
                updateCours(widget.courses['_id'], selectedProfesseur!.id, selectedMat!.id!, selectedTypes, date, bool.parse(_isSigne.text));
              } else {
                // Changes made, get the updated IDs
                String updatedProfId = await getProfesseurIdFromName(prof); // Get updated prof ID
                String updatedMatId = await getMatiereIdFromName(mat); // Get updated matière ID
                print('updatedProfId: $updatedProfId');
                print('updatedMatId: $updatedMatId');
                updateCours(widget.courses['_id'], updatedProfId, updatedMatId, selectedTypes, date, bool.parse(_isSigne.text));
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Le Type est mis à jour avec succès.')),
              );

              setState(() {
                widget.courses;
              });
            },
          ),
        ],
      ),

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
Future<List<Professeur>> fetchProfesseursByMatiere(String matiereId) async {
  String apiUrl = 'http://192.168.43.73:5000/matiere/$matiereId/professeur';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['professeurs'] is List<dynamic>) {
        final List<dynamic> professeursData = responseData['professeurs'];
        List<Professeur> fetchedProfesseurs =
        professeursData.map((data) => Professeur.fromJson(data)).toList();
        return fetchedProfesseurs;
      } else {
        throw Exception('Invalid API response: professeurs data is not a list');
      }
    } else {
      throw Exception('Failed to fetch professeurs by matière');
    }
  } catch (error) {
    throw Exception('Error: $error');
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

Future<void> updateCours( id,String professeurId,String matiereId, List<Map<String, dynamic>> types, DateTime? date, bool isPaid) async {
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

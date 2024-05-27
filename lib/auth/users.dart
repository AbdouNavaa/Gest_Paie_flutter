import 'dart:typed_data';


import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart' as Excel;

import 'dart:io';
import '../Dashboard.dart';
import '../home_screen.dart';
import '../prof_info.dart';





class Users extends StatefulWidget {
  Users({Key ? key}) : super(key: key);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {

  Future<List<User>>? futureUser;

  List<User>? filteredItems;
  bool _userIsActive = false; // Variable pour suivre l'état de l'utilisateur
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  User?  user ;
  bool showFloat = false;
  bool showSearch  = false;
  void DeleteUser(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/user' +"/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      // fetchUser();
      // Navigator.pop(context);
    }

  }


  @override
  void initState() {
    super.initState();
    fetchUser().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Useresseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
  }
  TextEditingController _searchController = TextEditingController();

  void _showFilterOptionsDialog(BuildContext context,val) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(

        surfaceTintColor: Color(0xB0AFAFA3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
          title: Text('Options de recherche'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                _applyFilter('Nom',val);
                Navigator.pop(context);
              },
              child: Text('Rechercher par Nom'),
            ),
            SimpleDialogOption(
              onPressed: () {
                _applyFilter('Prenom',val);
                Navigator.pop(context);
              },
              child: Text('Rechercher par Prénom'),
            ),
            SimpleDialogOption(
              onPressed: () {
                _applyFilter('Tous',val);
                Navigator.pop(context);
              },
              child: Text('Rechercher par nom et prénom'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _applyFilter(String option,val) async {
    List<User> Users = await fetchUser();

      if(option == "Nom")
      filteredItems = Users!.where((User) =>
      User.name!.toLowerCase().contains(val.toLowerCase())).toList();

    if(option == "Prenom")
      filteredItems = Users!.where((User) =>
          User.prenom!.toLowerCase().contains(val.toLowerCase())
      ).toList();

    if(option == "Tous")
      filteredItems = Users!.where((User) =>
      User.name!.toLowerCase().contains(val.toLowerCase()) ||
          User.prenom!.toLowerCase().contains(val.toLowerCase())
      ).toList();
    // });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _name = TextEditingController();
  TextEditingController _prenom = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _pass = TextEditingController();
  TextEditingController _confpass = TextEditingController();
  TextEditingController _email = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  int good = 1;
  String error = '';
  String _role ="professeur";
  String _banque  ="BMCI";
  TextEditingController _compte = TextEditingController();

  List<User> selectedUsers = [];

  Future<void> _pickImage1() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Center(child: Text(' ${filteredItems?.length} ')),
        // ),
        drawer: MyDrawer(),
        body: Column(
          children: [
            SizedBox(height: 40,),
            Container(
              height: 50,
              child: Row(
                children: [
                     TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: Icon(Icons.arrow_back_ios,color: Colors.black,size: 20,)),
                  // SizedBox(width: 50,),
                  showSearch?
                  Container(width: MediaQuery.of(context).size.width/3*2,
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(.85),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child:TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.tune_sharp, color: Colors.grey),
                            onPressed: () {
                              _showFilterOptionsDialog(context,_searchController.text);
                            },
                          ),
                          hintText: 'Rechercher',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                  )):Text("Liste des utilisateurs",style: TextStyle(fontSize: 20),),
                  showSearch?
                  SizedBox():
                  SizedBox(width: 70,),
                  Container(
                    width: 50,
                    height: 50,
                    // color: Colors.black26,
                    child: IconButton(icon:Icon(Icons.search, size: 30,color: Colors.black),
                      onPressed: () {
                        setState(() {
                          showSearch = !showSearch;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Sélectionnez tous les cours
                        selectedUsers = filteredItems!;
                      });
                    },
                    child: Text('Sélectionner tous', style: TextStyle(fontSize: 13),),
                    style: ElevatedButton.styleFrom(
                      // surfaceTintColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      // side: BorderSide(color: Colors.black38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                      padding: EdgeInsets.only(left: 10,right: 10),
                      backgroundColor: Colors.indigoAccent,
                      //   foregroundColor: Colors.black,
                      textStyle: TextStyle(fontWeight: FontWeight.bold),
                      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),

                  ),
                ),
                Flexible(
                child: TextButton(
                  onPressed: () {
                    // Confirmer et traiter les cours sélectionnés
                    if (selectedUsers.length == 0){
                      buildShowNullDialog(context);
                    }
                    else{ activerOuDesactiverUser(selectedUsers);
                    // Remettre la liste de sélection à zéro
                    setState(() {
                      selectedUsers = [];
                      Navigator.of(context).pop();
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              surfaceTintColor: Color(0xB0AFAFA3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("Alerte de succès"),
                                  Icon(Icons.fact_check_outlined,color: Colors.lightGreen,)
                                ],
                              ),
                              content: Text(
                                  "l\'operation est effectuée avec succès"),
                              actions: [
                                TextButton(
                                  child: Text("Ok"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),

                              ],
                            );});
                    });}
                  },
                  child: Row(
                    children: [
                      Text('Activation', style: TextStyle(fontSize: 13),),
                      Icon(Icons.check_box_outline_blank_outlined),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    surfaceTintColor: Colors.white,
                    foregroundColor: Colors.black,
                    // side: BorderSide(color: Colors.black38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    backgroundColor: Colors.white,
                    //   foregroundColor: Colors.black,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),

                ),
                ),
                Flexible(
                child: TextButton(
                  onPressed: () {
                    // Navigator.pop(context);
                    if (selectedUsers.length == 0){
                      buildShowNullDialog(context);
                    }else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            surfaceTintColor: Color(0xB0AFAFA3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                            title: Text("Confirmer la suppression"),
                            content: Text(
                                "Êtiez-vous sûr de vouloir supprimer ces éléments ?"),
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
                                  // Confirmer et traiter les cours sélectionnés
                                  SupprimerUsers(selectedUsers);
                                  // Remettre la liste de sélection à zéro
                                  setState(() {
                                    selectedUsers = [];
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            surfaceTintColor: Color(0xB0AFAFA3),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text("Alerte de succès"),
                                                Icon(Icons.fact_check_outlined,color: Colors.lightGreen,)
                                              ],
                                            ),
                                            content: Text(
                                                "l\'operation est effectuée avec succès"),
                                            actions: [
                                              TextButton(
                                                child: Text("Ok"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),

                                            ],
                                          );});
                                  });
                                },

                              ),
                            ],
                          );
                        },
                      );
                    }

                  }, // Disable button functionality
                  child: Row(
                    children: [
                      Text('Supprimer', style: TextStyle(fontSize: 13),),
                      Icon(Icons.delete_outline_outlined),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    surfaceTintColor: Colors.white,
                    foregroundColor: Colors.black,
                    // side: BorderSide(color: Colors.black38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    backgroundColor: Colors.white,
                    //   foregroundColor: Colors.black,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),

                ),
                ),
              ],
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
                  child: FutureBuilder<List<User>>(
                    future: fetchUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Erreur: ${snapshot.error}');
                        } else {

                          List<User>? items = snapshot.data;


                          //abou
                          return
                            Container(
                              height: 500,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Theme(
                                  data: ThemeData(
                                    // Modifiez les couleurs de DataTable ici
                                    dataTableTheme: DataTableThemeData(
                                      dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                                      // Couleur des lignes de données

                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),

                                    ),
                                  ),
                                  child: PaginatedDataTable(
                                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white),arrowHeadColor: Colors.black, // Couleur de la ligne d'en-tête
                                    columnSpacing: 10,dataRowHeight: 55,
                                    rowsPerPage: _rowsPerPage,
                                    showFirstLastButtons: _rowsPerPage >= 10 ? true: false,
                                    availableRowsPerPage: [5, 7,9,10, 20],
                                    onRowsPerPageChanged: (value) {
                                      setState(() {
                                        _rowsPerPage = value ?? _rowsPerPage;
                                      });
                                    },
                                    columns: [
                                      DataColumn(
                                        label: Text('Active'),
                                        onSort: (columnIndex, ascending) {
                                          // Code pour gérer la sélection ici
                                        },
                                      ),
                                      DataColumn(label: Text('Nom')),
                                      DataColumn(label: Text('E-mail')),
                                      DataColumn(label: Text('Role')),
                                      DataColumn(label: Text('Action')), // Nouvelle colonne pour le bouton Update
                                    ],
                                    source: YourDataSource(filteredItems ?? items!, updateState, selectedUsers, context,_pickImage1,_image,_picker),
                                  ),
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
        floatingActionButton:
        showFloat?
        Container(
          width: 300,

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

          margin: EdgeInsets.only(left: 80,right: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(width: 18,),
              TextButton(
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.black,),
                    Text('Ajouter',style: TextStyle(color: Colors.black),),
                  ],
                ),
                onPressed: () => _displayTextInputDialog(context),

              ),
              TextButton(
                child: Row(
                  children: [
                    Icon(Icons.cloud_download_outlined, color: Colors.black,),
                    Text('Importer',style: TextStyle(color: Colors.black),),
                  ],
                ),
                onPressed: () => _importData(context),

              ),
              TextButton(
                child: Icon(Icons.close_outlined, color: Colors.black,),
                onPressed: () {
                  setState(() {
                    showFloat = false;
                  });
                },

              ),


            ],
          ),
        )
        :Container(
          width: 60,
          decoration: BoxDecoration(
            color: Colors.indigo,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
              ),
            ],
            // border: Border.all(color: Colors.black38,width: 2)
          ),

          // margin: EdgeInsets.only(left: 90,right: 60),
          child:
          TextButton(
            child: Icon(Icons.add, color: Colors.white,),
            onPressed: () {
              setState(() {
                showFloat = true;
              });
            },

          ),

        ),


      );

  }

  Future<dynamic> buildShowNullDialog(BuildContext context) {
    return showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          surfaceTintColor: Color(0xB0AFAFA3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                          title: Text("Alert d\'erreur",style: TextStyle(color: Colors.red.shade900),),
                          content: Text(
                              "Il faut sélectioner quelques elements"),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Réessayez"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
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
          String prenom = row[1]?.value?.toString() ?? "";
          String mobile = row[2]?.value?.toString() ?? "";

          String email = row[3]?.value?.toString() ?? "";
          String pass = row[4]?.value?.toString() ?? "";
          String banque = row[5]?.value?.toString() ?? "";

          String role = row[6]?.value?.toString() ?? "";
          String compte = row[7]?.value?.toString() ?? "";

          // Faites quelque chose avec les données, par exemple, ajoutez-les à votre liste de professeurs
          // print('Code: $nom, Nom $niveau,Desc $desc,');
          AddUser(nom,prenom,int.parse(mobile),email,pass,pass,banque,role,compte);
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


    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              insetPadding: EdgeInsets.only(top: 120,),
              surfaceTintColor: Color(0xB0AFAFA3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              title: Text('Ajouter un utilisateur'),
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Exemple d'utilisation
                        textField(_name, validateName, TextInputType.text, 'Nom'),
                        SizedBox(height: 10),
                        textField(_prenom, validateName, TextInputType.text, 'Prénom'),
                        SizedBox(height: 10),
                        textField(_mobile, validateMobile, TextInputType.phone, 'Mobile'),
                        SizedBox(height: 10),
                        textField(_email, validateEmail, TextInputType.emailAddress, 'Email'),
                        SizedBox(height: 10),
                        textField(_pass, validatePassword, TextInputType.visiblePassword, 'Mot de Passe'),
                        SizedBox(height: 10),
                        textField(_confpass, validatePassword, TextInputType.visiblePassword, 'Confirmation'),
                        SizedBox(height: 10),
                        textField(_compte, validateCompte, TextInputType.text, 'Compte'),
                        SizedBox(height: 10),
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

                        SizedBox(height: 10),


                        SizedBox(height: 20),
                        ElevatedButton(onPressed: (){
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop();
                            fetchUser();
                            // print("${_role} ${_banque} et ${int.parse(_compte.text)}");
                            AddUser(_name.text,_prenom.text,int.parse(_mobile.text),_email.text,_pass.text,_confpass.text,_banque,_role,_compte.text);
                            // AddUser(_name.text, _desc.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('L\'utilisateur a été ajouté avec succès.')),
                            );
                            setState(() {
                              fetchUser();
                            });  }

                        }, child: Text("Ajouter"),

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
              )
          );
        });
  }

  TextFormField textField(TextEditingController controller, String? Function(String?)? validator, TextInputType keyboardType, String hintText) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          gapPadding: 1,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
    );
  }

// Validation spécifique pour le nom et le prénom
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le champ ne peut pas être vide';
    }
    if (value.length < 5) {
      return 'Le champ doit contenir au moins 5 caractères';
    }
    return null;
  }

// Validation spécifique pour le numéro de mobile
  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le champ ne peut pas être vide';
    }
    if (value.length != 8) {
      return 'Le numéro de mobile doit contenir exactement 8 chiffres';
    }
    return null;
  }

// Validation spécifique pour l'email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le champ ne peut pas être vide';
    }
    if (!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(value)) {
      return 'Entrez une adresse email valide';
    }
    return null;
  }

// Validation spécifique pour le mot de passe et la confirmation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le champ ne peut pas être vide';
    }
    if (value.length < 8) {
      return 'Le champ doit contenir au moins 8 caractères';
    }
    return null;
  }

// Validation spécifique pour le compte
  String? validateCompte(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le champ ne peut pas être vide';
    }
    if (value.length < 10) {
      return 'Le champ doit contenir au moins 10 caractères';
    }
    return null;
  }


  void AddUser (String name,String prenom,int mobile,String email,String pass,String confPass,String banque,String role,String compte) async {
    final Map<String, dynamic> data = {
      "nom":name,
      "prenom":prenom,
      "mobile": mobile,
      "email":email,
      "password":pass,
      "passwordConfirm": confPass,
      "banque":banque,
      "role": role,
      "accountNumero":compte,
    };

    // Check if the prix parameter is provided, otherwise use the default value of 100
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    // print(token);
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/user/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    print("Status${response.statusCode}");
    if (response.statusCode == 200) {
      print('User ajouter avec succes');
      setState(() {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                surfaceTintColor: Color(0xB0AFAFA3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Alerte de succès"),
                    Icon(Icons.fact_check_outlined,color: Colors.lightGreen,)
                  ],
                ),
                content: Text(
                    "L\'utilisateur est ajouté avec succès"),

                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),

                ],

              );});
      });


    }
    else {
      setState(() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                surfaceTintColor: Color(0xB0AFAFA3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Alert d\'erreur"),
                    Icon(Icons.wrong_location_outlined,color: Colors.redAccent,)
                  ],
                ),
                content: Text(jsonDecode(response.body)["message"]),
                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),

                ],
              );});

      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Échec de l\'ajout de l\'emploi.')),
      // );
    }
  }

  void UpdateCateg( id,String name,String description,[num? prix]) async {

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
        "name":name,
        "description":description ,
        "prix": prix ,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      // Fetch the updated list of Matieres and update the UI
      fetchUser().then((data) {
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

  void activerOuDesactiverUser(List<User> selectedUsers) {
    for (User user in selectedUsers) {
      ActiveUser(
        user.id,
      );
    }
  }
  void SupprimerUsers(List<User> selectedUsers) {
    for (User user in selectedUsers) {
      DeleteUser(
        user.id,
      );
    }
  }
  void updateState(void Function() callback) {
    setState(() {
      callback();
    });
  }






}



class YourDataSource extends DataTableSource {
  List<User> _items;
  List<User> selectedUsers;
  final Function(void Function()) updateStateCallback;
  final BuildContext context; // Ajout du contexte
  void Function() _pickImage1;
  File? _image;
  ImagePicker _picker;
  YourDataSource(this._items, this.updateStateCallback, this.selectedUsers, this.context, this._pickImage1,this._image,this._picker);


  Future<void> update(BuildContext context, User user) async {
    final TextEditingController _nameController = TextEditingController(text: user.name);
    final TextEditingController _prenomController = TextEditingController(text: user.prenom);
    final TextEditingController _mobileController = TextEditingController(text: user.mobile.toString());
    final TextEditingController _emailController = TextEditingController(text: user.email);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.only(top: 130),
          surfaceTintColor: Color(0xB0AFAFA3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Utilisateur Infos", style: TextStyle(fontSize: 25, color: Colors.blueGrey)),
              Spacer(),
              InkWell(
                child: Icon(Icons.close, color: Colors.blueGrey),
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
          content: Container(
            height: 500,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 40),
                  buildTextFormField(_nameController, TextInputType.text, 'Nom',),
                  SizedBox(height: 30),
                  buildTextFormField(_prenomController, TextInputType.text, 'Prenom',),
                  SizedBox(height: 30),
                  buildTextFormField(_mobileController, TextInputType.number, 'Mobile',),
                  SizedBox(height: 30),
                  buildTextFormField(_emailController, TextInputType.emailAddress, 'Email',),
                  SizedBox(height: 30),
                  // ElevatedButton(
                  //   onPressed: _pickImage1,
                  //   child: Text("Choisir une image"),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Color(0xff0fb2ea),
                  //     foregroundColor: Colors.white,
                  //     elevation: 10,
                  //     minimumSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.width / 7),
                  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  //   ),
                  // ),
                  // SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();

                      String userId = user.id;
                      Map<String, dynamic> updatedData = {
                        'mobile': _mobileController.text,
                        'nom': _nameController.text,
                        'prenom': _prenomController.text,
                        'email': _emailController.text,
                        // 'basePath': 'http://localhost:5000/uploads/images/',
                        // 'fileName': '${_image!.path.split('/').last}',
                      };

                      print('Photo${_image}');
                      await updateUserInfos(userId, updatedData, _image);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Le Type est mis à jour avec succès.')),
                      );

                      // setState(() {
                      //   _nameController.clear();
                      //   _prenomController.clear();
                      //   _mobileController.clear();
                      //   _emailController.clear();
                      // });
                    },
                    child: Text("Modifier"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff0fb2ea),
                      foregroundColor: Colors.white,
                      elevation: 10,
                      minimumSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.width / 7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  TextFormField buildTextFormField(cont, keyBT,hintT) {
    return TextFormField(
      controller: cont,
      // initialValue: Val,
      keyboardType: keyBT,
      onChanged: (value){
        cont = value;
      },
      // maxLines: 3,
      decoration: InputDecoration(
          filled: true,

          // fillColor: Color(0xA3B0AF1),
          fillColor: Colors.white,
          hintText: hintT,
          border: OutlineInputBorder(
              borderSide: BorderSide.none,gapPadding: 1,
              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
    );
  }

  @override
  DataRow? getRow(int index) {
    final item = _items[index];
    return DataRow(cells: [
      DataCell(
        Row(
          children: [
            Checkbox(
              value: selectedUsers.contains(item),
              activeColor: Colors.green,
              onChanged: (value) {
                updateStateCallback(() {
                  if (value != null && value) {
                    selectedUsers.add(item);
                  } else {
                    selectedUsers.remove(item);
                  }
                });
              },
            ),
            Text(
              item.isActive! ? 'Actif' : 'Inactif',
              style: TextStyle(
                color: item.isActive! ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
      DataCell(Text('${item.name} ${item.prenom}')),
      DataCell(Text('${item.email}')),
      DataCell(Text('${item.role}')),
      DataCell(
        TextButton(
          onPressed: () => update(context, item),
          child: Icon(Icons.edit_note_sharp),
          style: TextButton.styleFrom(surfaceTintColor: Colors.white),
        ),
      ),
    ]);
  }

  @override
  int get rowCount => _items.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}



class User {
  late final String id;
  final String name;
  final String prenom;
  final num? mobile;
  final String email;
  final String role;
  final String? photo;
   late final bool? isActive;


  User({
    required this.id,
    required this.name,
    required this.prenom,
    required this.email,
     this.mobile,
    required this.role,
     this.photo,
     this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      mobile: json['mobile'],
      role: json['role'],
      photo: json['photo'],
      isActive: json['active'],
    );
  }
}
Future<List<User>> fetchUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/user'),
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
    List<dynamic> UsersData = jsonResponse['users'];

    print(UsersData);
    List<User> Users = UsersData.map((item) {
      return User.fromJson(item);
    }).toList();

    print(Users);
    return Users;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load User');
  }
}


Future<void> ActiveUser( id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  final url = 'http://192.168.43.73:5000/user/'  + '/$id'+'/active';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };


  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 201) {
      // Course creation was successful
      print("OK!");
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




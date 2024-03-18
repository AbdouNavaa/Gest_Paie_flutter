import 'package:flutter/material.dart';
import 'package:gestion_payements/professeures.dart';
import 'package:get/get.dart';
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
import 'element.dart';





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

  bool showFloat = false;


  void DeleteFilliere(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/filiere' +"/$id"),
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
                     TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: Icon(Icons.arrow_back_ios,color: Colors.black,size: 20,)),
                  // SizedBox(width: 3,),
                  Text("Liste des Filières",style: TextStyle(fontSize: 20),)
                ],
              ),
            ),
            Divider(),
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
                                headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white70), // Couleur de la ligne d'en-tête
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
                                          DataCell(Container(child: Text('${fil.niveau.capitalize}')),),
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
                                                      _showFilDetails(context,fil);
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
        floatingActionButton:
        showFloat?
        Container(
          width: 400,
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
          // margin: EdgeInsets.only(left: 60,right: 55),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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

              // SizedBox(width: 210,),
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
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(50)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
              ),
            ],
          ),

          // margin: EdgeInsets.only(left: 90,right: 60),
          child:
          TextButton(
            child: Icon(Icons.add, color: Colors.black,),
            onPressed: () {
              setState(() {
                showFloat = true;
              });
            },

          ),

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


    return showDialog(
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

            content:
              Container(
            height: 450,
                width: MediaQuery.of(context).size.width,
            // padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  //hmmm
                  SizedBox(height: 40),
                  TextField(
                    controller: _name,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        // fillColor: Color(0xA3B0AF1),
                        fillColor: Colors.white,
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
                      // fillColor: Color(0xA3B0AF1),
                      fillColor: Colors.white,
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
              
                        // fillColor: Color(0xA3B0AF1),
                        fillColor: Colors.white,
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
          ),

          );
        });

  }





  Future<String?> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      return result.files.single.path;
    } else {
      return null;
    }
  }

  Future<void> uploadFileToBackend(String? filePath, id) async {
    if (filePath != null) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String token = prefs.getString("token")!;
        Uri url = Uri.parse('http://192.168.43.73:5000/element/upload/${id}');
        var request = http.MultipartRequest('POST', url,);
        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(await http.MultipartFile.fromPath('file', filePath));

        var response = await request.send();
        if (response.statusCode == 200) {
          var jsonResponse = await response.stream.bytesToString();
          print('Réponse du serveur: $jsonResponse');
        } else {
          print('Échec de la requête: ${response.statusCode}');
        }
      } catch (e) {
        print('Erreur lors de la requête: $e');
      }
    } else {
      print('Aucun fichier sélectionné');
    }
  }



  Future<void> _showFilDetails(BuildContext context, filliere fil) {
    return showModalBottomSheet(
        context: context,backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return Container(
            height: 500,
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Filière Infos',style: TextStyle(fontSize: 30),),
                SizedBox(height: 40),
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
                    Container(
                      width: 200,
                      child: Text(fil.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),
                    ),
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
                    Text('${fil.niveau.capitalizeFirst}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                  ],
                ),
                SizedBox(height: 25),
                SingleChildScrollView(scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text('Description:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),
                  
                      SizedBox(width: 10,),
                      Container(
                        // width: 200,
                        child: Text('${fil.description}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),
                      ),
                  
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Elements:',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 120,),
                    IconButton(
                        onPressed: () async {
                          Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => FilElemsPage(filiId: fil.id)));
                        },
                        icon: Icon(Icons.format_list_bulleted)),
                    IconButton(
                        onPressed: () async {
                          String? filePath = await pickExcelFile();
                          if (filePath != null) {
                            uploadFileToBackend(filePath, fil.id);
                          }
                        },
                        icon: Icon(Icons.cloud_upload_outlined))


                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Emplois:',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 130,),
                    IconButton(
                        onPressed: () async {
                          Navigator.push(
                              context, MaterialPageRoute(
                              builder: (context) => FilEmploiPage(filiId: fil.id)));
                        },
                        icon: Icon(Icons.format_list_bulleted_outlined))


                  ],
                ),
                SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(

                      onPressed: () async {
                        // setState(() {
                        //   // fetchfilliere();
                        //   Navigator.pop(context);
                        //
                        // });
                        _name.text = fil.name;
                        _desc.text = fil.description!;
                        _selectedNiveau = fil.niveau;

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
                                    Text("Modifier une Matiere", style: TextStyle(fontSize: 20),),
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

                                        SizedBox(height: 40),
                                        TextField(
                                          controller: _name,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                              filled: true,
                                              // fillColor: Color(0xA3B0AF1),
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,gapPadding: 1,
                                                  borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                        ),

                                        SizedBox(height: 30),
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
                                            // fillColor: Color(0xA3B0AF1),
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,gapPadding: 1,
                                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 30),

                                        TextFormField(
                                          controller: _desc,
                                          keyboardType: TextInputType.text,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                              filled: true,

                                              // fillColor: Color(0xA3B0AF1),
                                              fillColor: Colors.white,
                                              hintText: "description",
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,gapPadding: 1,
                                                  borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _niveau.text = _selectedNiveau.toString();

                                            fetchfilliere();

                                            // AddCategory(_name.text, _desc.text);
                                            UpdateFilliere(fil.id, _name.text,_selectedNiveau,_desc.text,);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Le filière est mis à jour avec succès.')),
                                            );
                                            setState(() {
                                              fetchfilliere();
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
                      },


                      child: Text('Modifier'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(left: 20,right: 20),
                        foregroundColor: Colors.lightGreen,
                          backgroundColor: Color(0xfffff1),
                          side: BorderSide(color: Colors.black12,),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),

                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                              surfaceTintColor: Color(0xB0AFAFA3),
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

                                    DeleteFilliere(fil.id);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Le Filière a été Supprimer avec succès.')),
                                    );

                                    setState(() {
                                      fetchfilliere();
                                      Navigator.pop(context);
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
                          backgroundColor: Color(0xfffff1),
                          side: BorderSide(color: Colors.black12,),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
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

  void Addfilliere (String name,String niveau,String description) async {

    // Check if the prix parameter is provided, otherwise use the default value of 100
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/filiere/'),
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
    final url = 'http://192.168.43.73:5000/filiere/'  + '/$id';
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
  // final int? periode;

  filliere({
    required this.id,
    required this.name,
    required this.niveau,
     this.description,
     // this.periode,
  });

  factory filliere.fromJson(Map<String, dynamic> json) {
    return filliere(
      id: json['_id'],
      name: json['name'],
      niveau: json['niveau'],
      description: json['description'],
      // periode: json['periode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'niveau': niveau,
      'description': description,
      // 'periode': periode,
    };
  }
}

Future<List<filliere>> fetchfilliere() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/filiere/'),
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
    List<dynamic> filData = jsonResponse['filieres'];

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


class FilEmploiPage extends StatefulWidget {
  final String filiId; // L'ID du groupe

  FilEmploiPage({required this.filiId});

  @override
  _FilEmploiPageState createState() => _FilEmploiPageState();
}


class _FilEmploiPageState extends State<FilEmploiPage> {
  late List<dynamic> emplois = [];
  late String fill = '';
  late String description = '';
  late String niveau = '';

  @override
  void initState() {
    super.initState();
    fetchFilEmploi();
  }

  Future<void> fetchFilEmploi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    String apiUrl = 'http://192.168.43.73:5000/filiere/${widget.filiId}/emplois';
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
        fill = data['filiere'];
        description = data['description'];
        niveau = data['niveau'];
        emplois = data['emplois'];
        // Sort emplois by semester and day
        emplois.sort((a, b) {
          int semesterComparison = a['semestre'].compareTo(b['semestre']);
          if (semesterComparison == 0) {
            return a['dayNumero'].compareTo(b['dayNumero']);
          }
          return semesterComparison;
        });
      });
    } else {
      throw Exception('Failed to load group emploi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40,),
          Container(
            height: 50,
            child: Row(
              children: [
                TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Icon(Icons.arrow_back_ios,color: Colors.black,size: 20,)),
                // SizedBox(width: 3,),
                Text('Emplois du Filière ${fill.toUpperCase()}',style: TextStyle(fontSize: 20),),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                itemCount: emplois.length,
                itemBuilder: (BuildContext context, int index) {
                  // Check if the current semester is different from the previous one
                  if (index == 0 || emplois[index]['semestre'] != emplois[index - 1]['semestre']) {
                    // Display semester header
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(

                        children: [
                          Text(
                            'Semestre ${emplois[index]['semestre']}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildDataRow(index),
                        ],
                      ),
                    );
                  } else {
                    // Continue displaying rows for the current semester
                    return _buildDataRow(index);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(int index) {
    return DataTable(
      showCheckboxColumn: true,
      showBottomBorder: true,
      headingRowHeight: 50,
      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey.shade100),
      columnSpacing: 8,
      dataRowHeight: 50,
      columns: [
        DataColumn(label: Text(emplois[index]['jour'].toString().capitalize!,style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),)),
        DataColumn(label: Text('')),
        DataColumn(label: Text('')),
        DataColumn(label: Text('')),
        DataColumn(label: Text('')),
      ],
      rows: [
        DataRow(
          cells: [
            // DataCell(Container(
            //   width: 60,
            //   child: Text(
            //     '${emplois[index]['jour']}',
            //     style: TextStyle(
            //       color: Colors.black,
            //     ),
            //   ),
            // )),
            DataCell(Text(
              '${emplois[index]['enseignat'].toString().capitalize}',
              style: TextStyle(
                color: Colors.black,
              ),
            )),
            DataCell(Text(
              '${emplois[index]['matiere'].toString().capitalize}',
              style: TextStyle(
                color: Colors.black,
              ),
            )),
            DataCell(Container(
              width: 40,
              child: Text(
                '${emplois[index]['type']}',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            )),
            DataCell(Container(
              width: 40,
              child: Text(
                '${emplois[index]['startTime']}',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            )),
            DataCell(Container(
              width: 40,
              child: Text(
                '${emplois[index]['finishTime']}',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            )),
          ],
        ),
      ],
    );
  }
}


class FilElemsPage extends StatefulWidget {
  final String filiId; // L'ID du groupe

  FilElemsPage({required this.filiId});

  @override
  _FilElemsPageState createState() => _FilElemsPageState();
}

class _FilElemsPageState extends State<FilElemsPage> {
  late List<dynamic> emplois =[];
  late String fill = '';
  // late String description = '';
  // late String annee = '';
  // late int semestre =0;
  late String niveau = '';


  Professeur? selectedProfesseurCM;
  Professeur? selectedProfesseurTP;
  Professeur? selectedProfesseurTD;
  List<Professeur> professeurs = [];
  // late int GNum = 0;
  // late String GType = '';

  @override
  void initState() {
    super.initState();
    fetchFilEmploi();
    fetchProfs().then((data) {
      setState(() {
        professeurs = data; // Assigner la liste renvoyée par Groupesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
  }

  Future<void> fetchFilEmploi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    String apiUrl = 'http://192.168.43.73:5000/filiere/${widget.filiId}';
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
        fill = data['filiere'];
        // description = data['description'];
        // annee = data['annee'];
        // semestre = data['semestre'];
        // niveau = data['niveau'];
        // GNum = data['group'];
        // GType = data['group_type'];
        emplois = data['elements'];
      });
    } else {
      throw Exception('Failed to load group emploi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ListTile(
          //   title: Text('Filliere: ${filliere.toUpperCase()} ($description)', style: TextStyle(fontSize: 17),),
          //   subtitle: Text('Nivau: $annee | Semestre: $semestre | Niveau: $niveau', style: TextStyle(fontSize: 17)),
          // ),
          SizedBox(height: 40,),
          Container(
            height: 50,
            child: Row(
              children: [
                TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Icon(Icons.arrow_back_ios,color: Colors.black,size: 20,)),
                // SizedBox(width: 3,),
                Text('Elements du Filière ${fill.toUpperCase()}',style: TextStyle(fontSize: 20),),
              ],
            ),
          ),
          Divider(),
          SizedBox(child: Center(child: Text('Il y a ${emplois.length} elements')),),
          Expanded(
              child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                child: Container(
                  height: 700,
                  child: SingleChildScrollView(scrollDirection: Axis.vertical,
                    child: DataTable(
                      showCheckboxColumn: true,
                      showBottomBorder: true,
                      headingRowHeight: 50,
                      // headingRowColor: MaterialStateColor.resolveWith((states) => Colors.lightBlueAccent.shade100), // Couleur de la ligne d'en-tête
                      columnSpacing: 8,
                      dataRowHeight: 90,
                      columns: [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Sem')),
                        DataColumn(label: Text('Matiere')),
                        DataColumn(label: Text('ProfCM')),
                        DataColumn(label: Text('ProfTP')),
                        DataColumn(label: Text('ProfTD')),
                        // DataColumn(label: Text('HCM')),
                        // DataColumn(label: Text('HTP')),
                        // DataColumn(label: Text('HTD')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: [
                        for (var index = 0; index < (emplois?.length ?? 0); index++)
                        // for (var categ in emplois!)
                          DataRow(
                              cells: [
                                DataCell(Text((index + 1).toString(),style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Text('S${emplois?[index]['semestre']}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Container(width: 75,
                                  child: Text('${emplois?[index]['name'].toString().capitalize}',style: TextStyle(
                                    color: Colors.black,
                                  ),),
                                )),
                                DataCell(SingleChildScrollView(scrollDirection: Axis.vertical,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (var prof in emplois?[index]['professeurCM'])
                                      Text('${getProfIdFromName(prof).capitalize} /',style: TextStyle(
                                        color: Colors.black,
                                      ),),
                                    ],
                                  ),
                                )),
                                DataCell(SingleChildScrollView(scrollDirection: Axis.vertical,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          for (var prof in emplois?[index]['professeurTP'])
                                            Text('${getProfIdFromName(prof).capitalize} /',style: TextStyle(
                                            color: Colors.black,
                                          ),),
                                        ],
                                      ),
                                    )),
                                DataCell(SingleChildScrollView(scrollDirection: Axis.vertical,

                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (var prof in emplois?[index]['professeurTD'])
                                        Text('${getProfIdFromName(prof).capitalize} /',style: TextStyle(
                                        color: Colors.black,
                                      ),),
                                    ],
                                  ),
                                )),
                                // DataCell(Text('${emplois?[index]['heuresCM']}',style: TextStyle(
                                //   color: Colors.black,
                                // ),)),
                                // DataCell(Text('${emplois?[index]['heuresTP']}',style: TextStyle(
                                //   color: Colors.black,
                                // ),)),
                                // DataCell(Text('${emplois?[index]['heuresTD']}',style: TextStyle(
                                //   color: Colors.black,
                                // ),)),
                                DataCell(
                                  Row(
                                    children: [
                                      Container(
                                        width: 35,
                                        child:
                                        TextButton(
                                          onPressed: (){
                                            // print(fil.id);
                                            _showElemDetails(context,emplois,index,emplois[index]['_id']);
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



                              ]),
                      ],
                    ),
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }

  Future<void> _showElemDetails(BuildContext context, List<dynamic> ele,var index,String EleID) {
    return showModalBottomSheet(
        context: context,backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return Container(
            height: 700,
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Element Infos", style: TextStyle(fontSize: 25),),
                      Spacer(),
                      InkWell(
                        child: Icon(Icons.close),
                        onTap: (){
                          setState(() {
                            Navigator.pop(context);
                          });
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Semestre:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),
                      SizedBox(width: 10,),
                      Text("S${ele[index]['semestre']}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                    ],
                  ),
                  SizedBox(height: 15),
                  Container(width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text('Matiere:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),),

                          SizedBox(width: 10,),
                            Text("${ele[index]['name'].toString().capitalize}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Professeur(e/s) de CM:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),

                        for (var prof in emplois?[index]['professeurCM'])
                          // for (var prof in ele?[index]['info']['CM'])
                          Text("${getProfIdFromName(prof).capitalize}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Professeur(e/s) de TP:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),

                          // for (var prof in ele?[index]['info']['TP'])
                        for (var prof in emplois?[index]['professeurTP'])
                          Text("${getProfIdFromName(prof).capitalize}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Professeur(e/s) de TD:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),

                          // for (var prof in ele?[index]['info']['TD'])
                        for (var prof in emplois?[index]['professeurTD'])
                          Text("${getProfIdFromName(prof).capitalize}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Text('NBH du CM:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text("${ele[index]['heuresCM']}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 15,),
                  Row(
                    children: [
                      Text('NBH du TP:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text("${ele[index]['heuresTP']}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 15,),
                  Row(
                    children: [
                      Text('NBH du TD:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text("${ele[index]['heuresTD']}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // _selectedNum = emp.dayNumero;
                          // _date.text = ele.fil!;
                          print(ele[index]['_id']);
                          setState(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    UpdateElemScreen(eleId: ele[index]['_id'],  Sem:ele[index]['semestre'], Mat: ele[index]['name'],
                                      // ProCM: ele.ProfCM!, ProTP: ele.ProfTP!, ProTD: ele.ProfTD!,
                                      CredCM: ele[index]['heuresCM'], CredTP: ele[index]['heuresTP'],CredTD: ele[index]['heuresTD'],
                                      filId: ele[index]['filiere'], MatId: ele[index]['matiere'], fil: fill!,
                                      ProfCMId: ele[index]['professeurCM'], ProfTPId: ele[index]['professeurTP'],ProfTDId: ele[index]['professeurTD'],
                                    )));
                          });
                          // selectedMat = emp.mat!;


                        },// Disable button functionality

                        child: Text('Modifier'),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.only(left: 20,right: 20),
                            foregroundColor: Colors.lightGreen,
                            // backgroundColor: Colors.white,
                            // side: BorderSide(color: Colors.black,),

                            backgroundColor: Color(0xfffff1),
                            side: BorderSide(color: Colors.black12,),   elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                        ),

                      ),
                      TextButton(
                        // print(ele.id);
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
                                      Text("Ajouter un Professeur", style: TextStyle(fontSize: 25),),
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
                                          SizedBox(height: 30),
                                          DropdownButtonFormField<Professeur>(
                                            value: selectedProfesseurCM,
                                            items: professeurs.map((professeur) {
                                              return DropdownMenuItem<Professeur>(
                                                value: professeur,
                                                child: Text(professeur.nom! ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedProfesseurCM = value;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              filled: true,
                                              // fillColor: Color(0xA3B0AF1),
                                              fillColor: Colors.white,
                                              hintText: "selection d'un  Professeur de CM", // Update the hintText
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,gapPadding: 1,
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          DropdownButtonFormField<Professeur>(
                                            value: selectedProfesseurTP,
                                            items: professeurs.map((professeur) {
                                              return DropdownMenuItem<Professeur>(
                                                value: professeur,
                                                child: Text(professeur.nom! ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedProfesseurTP = value;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              filled: true,
                                              // fillColor: Color(0xA3B0AF1),
                                              fillColor: Colors.white,
                                              hintText: "selection d'un  Professeur de TP", // Update the hintText
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,gapPadding: 1,
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          DropdownButtonFormField<Professeur>(
                                            value: selectedProfesseurTD,
                                            items: professeurs.map((professeur) {
                                              return DropdownMenuItem<Professeur>(
                                                value: professeur,
                                                child: Text(professeur.nom! ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                selectedProfesseurTD = value;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              filled: true,
                                              // fillColor: Color(0xA3B0AF1),
                                              fillColor: Colors.white,
                                              hintText: "selection d'un  Professeur de TD", // Update the hintText
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

                                              // fetchElems();



                                              addProfToElem(ele[index]['_id'],selectedProfesseurCM?.id!,selectedProfesseurTP?.id!,selectedProfesseurTD?.id!,);

                                              setState(() {
                                                Navigator.pop(context);
                                                // fetchProfs();
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
                                  ),

                                );
                              });
                        }, // Disable button functionality

                        child: Text('Ajouter Prof'),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.only(left: 20,right: 20),
                            foregroundColor: Color(0xff0fb2ea),
                            // foregroundColor: Colors.lightGreen,
                            backgroundColor: Color(0xfffff1),
                            side: BorderSide(color: Colors.black12,),
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                        ),

                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                surfaceTintColor: Color(0xB0AFAFA3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
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

                                      fetchElems();
                                      DeleteElems(EleID);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Le Category a été Supprimer avec succès.')),
                                      );

                                      setState(() {
                                        Navigator.pop(context);
                                        fetchElems();
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }, // Disable button functionality

                        child: Text('Supprimer'),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.only(left: 20,right: 20),
                            foregroundColor: Colors.redAccent,

                            backgroundColor: Color(0xfffff1),
                            side: BorderSide(color: Colors.black12,), // side: BorderSide(color: Colors.black,),
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                        ),

                      ),
                    ],
                  ),

                ],
              ),
            ),
          );
        }


    );
  }
  void DeleteElems(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/element' +"/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchElems().then((data) {
        setState(() {
          // filteredItems = data; // Assigner la liste renvoyée par Groupesseur à items
        });
      }).catchError((error) {
        print('Erreur: $error');
      });

    }

  }

  Future<void> addProfToElem( id,String? ProfCM,String? ProfTP,String? ProfTD) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    final url = 'http://192.168.43.73:5000/element/$id/professeurs';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> body ={};

    if( ProfCM != null &&ProfTP != null &&ProfTD != null ){
      body = {
        'professeurCM': ProfCM,
        'professeurTP': ProfTP,
        'professeurTD': ProfTD,
      };
    }
    else if(ProfCM != null &&ProfTP == null &&ProfTD == null){
      body = {
        'professeurCM': ProfCM,
      };
    }
    else if(ProfCM != null &&ProfTP != null &&ProfTD == null){
      body = {
        'professeurCM': ProfCM,
        'professeurTP': ProfTP,
      };
    }
    else if(ProfCM != null &&ProfTP == null &&ProfTD != null){
      body = {
        'professeurCM': ProfCM,
        'professeurTD': ProfTD,
      };
    }

    else if(ProfCM == null &&ProfTP != null &&ProfTD != null){
      body = {
        'professeurTP': ProfTP,
        'professeurTD': ProfTD,
      };
    }
    else if(ProfCM == null &&ProfTP != null &&ProfTD == null){
      body = {
        'professeurTP': ProfTP,
      };
    }


    else if(ProfCM == null &&ProfTP == null &&ProfTD != null){
      body = {
        'professeurTD': ProfTD,
      };
    }
    final response = await http.patch(Uri.parse(url), headers: headers,
      body: json.encode(body),
    );

    print("Status${response.statusCode}");
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
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
                content: Text("L\'element est ajouté avec succès"),
                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigator.push(
                      //     context, MaterialPageRoute(
                      //     builder: (context) => Elements()));

                    },
                  ),

                ],

              );});
      });

      print("L\'element est ajouté avec succès");


    } else {
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
                    Text("Alerte d\'erreur"),
                    Icon(Icons.wrong_location_outlined,color: Colors.redAccent,)
                  ],
                ),
                content: Text(
                    "L\'emploi n\'est pas ajouter"),
              );});

      });

      print("SomeThing Went Wrong");
      print('Failed to add matiere to professeus. Status Code: ${response.statusCode}');
    }
  }

  String getProfIdFromName(String nom) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = professeurs.firstWhere((prof) => '${prof.id}' == nom, orElse: () =>Professeur(id: ''));
    print("ProfName:${professeur.nom}");
    return "${professeur.nom} ${professeur.prenom}"; // Return the ID if found, otherwise an empty string

  }


}



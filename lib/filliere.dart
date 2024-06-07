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
import 'home_screen.dart';





class Filliere extends StatefulWidget {
  Filliere({Key ? key}) : super(key: key);

  @override
  _FilliereState createState() => _FilliereState();
}

class _FilliereState extends State<Filliere> {

  Future<List<filliere>>? futurefilliere;

  List<filliere>? filteredItems;

  List<Professeur> professeurList = [];
  List<Elem> matiereList = [];

  bool showFloat = false;
  bool showSearch = false;


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
    fetchElems().then((data) {
      setState(() {
    matiereList  = data; // Assigner la liste renvoyée par filliereesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchfilliere();
    _loadFiliere();
  }

  List<bool> isExpandedList = [];
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
  Elem getMatIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = matiereList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Elem(id: '', filId: ''));
    // print(professeur.name);
    return professeur; // Return the ID if found, otherwise an empty string

  }


Future<void> _loadFiliere() async {
  List<filliere> filieres = await fetchfilliere();
  setState(() {
    filteredItems = filieres;
    isExpandedList = List<bool>.filled(filieres.length, true);
  });
}
  TextEditingController _name = TextEditingController();
  // TextEditingController _code = TextEditingController();
  TextEditingController _desc = TextEditingController();
  TextEditingController _niveau = TextEditingController();
  TextEditingController _sem = TextEditingController();
  String _selectedNiveau = "licence";
  String _selecteSem = "1,2";



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Center(child: Text(' ${filteredItems?.length} ')),
        // ),
        drawer: MyDrawer(),
      body:
      filteredItems == null
          ? Center(child: CircularProgressIndicator()):Column(
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
                        suffixIcon: IconButton(
                          icon: Icon(Icons.tune_sharp, color: Colors.grey),
                          onPressed: () {
                            // _showFilterOptionsDialog(context,_searchController.text);
                          },
                        ),
                        hintText: 'Rechercher',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    )):
                Text("Liste des Filières",style: TextStyle(fontSize: 20),),
                showSearch?SizedBox():SizedBox(width: 100,),
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
               Expanded(
                 child: ListView.builder(
                             physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                             itemCount: filteredItems!.length,
                             itemBuilder: (context, index) {
                               return InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      isExpandedList[index] = !isExpandedList[index];
                    });
                  },
                  child: AnimatedContainer(
                    margin: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    padding: EdgeInsets.all(20),
                    height: isExpandedList[index ] ? 70 : 270,
                    curve: Curves.fastLinearToSlowEaseIn,
                    duration: Duration(milliseconds: 1200),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: Offset(1, 1),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(isExpandedList[index] ? 10 : 10),
                      ),
                    ),
                    child: SingleChildScrollView(scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                filteredItems![index].name.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                isExpandedList[index]
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_up,
                                color: Colors.black,
                                size: 27,
                              ),
                            ],
                          ),
                          isExpandedList[index] ? SizedBox() : SizedBox(height: 20),
                          AnimatedCrossFade(
                            firstChild: Text(
                              '',
                              style: TextStyle(
                                fontSize: 0,
                              ),
                            ),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Semestres:',
                                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w300,color: Colors.black),
                                    ),
                                    // for(var sem in filteredItems![index].semestres.split(','))
                                    Row(
                                      children: [
                                        Text(
                                          ' S${filteredItems![index].semestres.split(',')[0]} et S${filteredItems![index].semestres.split(',')[1]}',
                                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.w300,color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        Text(
                                  'Description: ${filteredItems![index].description}',
                                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.w300,color: Colors.black),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Matieres:',
                                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),
                                    ),
                                    SizedBox(width: 110,),
                                    IconButton(
                                        onPressed: () async {
                                          Navigator.push(
                                              context, MaterialPageRoute(
                                              builder: (context) => FilElemsPage(filiId: filteredItems![index].id)));
                                        },
                                        icon: Icon(Icons.format_list_bulleted,color: Colors.black)),
                                    IconButton(
                                        onPressed: () async {
                                          String? filePath = await pickExcelFile();
                                          if (filePath != null) {
                                            uploadFileToBackend(filePath, filteredItems![index].id);
                                            Navigator.pop(context);
                                          }
                                        },
                                        icon: Icon(Icons.cloud_upload_outlined,color: Colors.black))


                                  ],
                                ),
                                // Row(
                                //   children: [
                                //     Text(
                                //       'Emplois:',
                                //       style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.black),
                                //     ),
                                //     SizedBox(width: 117,),
                                //     IconButton(
                                //         onPressed: () async {
                                //           // Navigator.push(
                                //           //     context, MaterialPageRoute(
                                //           //     builder: (context) => FilEmploiPage(filiId: filteredItems![index].id)));
                                //         },
                                //         icon: Icon(Icons.format_list_bulleted_outlined,color: Colors.black))
                                //
                                //
                                //   ],
                                // ),
                                SizedBox(height: 25,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(

                                      onPressed: () async {

                                        _name.text = filteredItems![index].name;
                                        _desc.text = filteredItems![index].description!;
                                        _selectedNiveau = filteredItems![index].niveau;

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

                                                            // fetchfilliere();

                                                            // AddCategory(_name.text, _desc.text);
                                                            UpdateFilliere(filteredItems![index].id, _name.text,_selectedNiveau,_desc.text,);
                                                            // ScaffoldMessenger.of(context).showSnackBar(
                                                            //   SnackBar(content: Text('Le filière est mis à jour avec succès.')),
                                                            // );
                                                            setState(() {
                                                              // fetchfilliere();
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
                                      style: ElevatedButton.styleFrom(
                                        surfaceTintColor: Colors.white,
                                        // side: BorderSide(color: Colors.black38),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 5,
                                        padding: EdgeInsets.symmetric(horizontal: 25),
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      ),

                                    ),
                                    ElevatedButton(
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

                                                    DeleteFilliere(filteredItems![index].id);

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
                                        surfaceTintColor: Colors.white,
                                        // side: BorderSide(color: Colors.black38),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        elevation: 5,
                                        padding: EdgeInsets.symmetric(horizontal: 25),
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      ),

                                    ),
                                  ],
                                ),

                              ],
                            ),
                            crossFadeState: isExpandedList[index]
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: Duration(milliseconds: 1200),
                            reverseDuration: Duration.zero,
                            sizeCurve: Curves.fastLinearToSlowEaseIn,
                          ),
                        ],
                      ),
                    ),
                  ),
                               );
                             },
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
            color: Colors.indigo,
            borderRadius: BorderRadius.all(Radius.circular(10)),
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
                  textField(_name,1,"Nom"),

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
                  DropdownButtonFormField<String>(
                    value: _selecteSem,
                    items: [
                      DropdownMenuItem<String>(
                        child: Text('1,2'),
                        value: "1,2",
                      ),
                      DropdownMenuItem<String>(
                        child: Text('3,4'),
                        value: "3,4",
                      ),
                      DropdownMenuItem<String>(
                        child: Text('5,6'),
                        value: "5,6",
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selecteSem = value!;
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




                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                      fetchfilliere();
                      _niveau.text = _selectedNiveau.toString();
                      _sem.text = _selecteSem.toString();

                      Addfilliere(_name.text,_niveau.text,_sem.text);
                      // Addfilliere(_name.text, _desc.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Le filliere a été ajouter avec succès.')),
                      );
                      setState(() {
                        Navigator.pop(context);
                        // fetchfilliere();
                        // _name.text = '';
                        // _niveau.text = '';
                        // _desc.text = '';
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

  TextField textField(TextEditingController cont,maxL,hintT) {
    return TextField(
                  controller: cont,
                  keyboardType: TextInputType.text,
                  maxLines: maxL,
                  decoration: InputDecoration(
                      filled: true,
                      // fillColor: Color(0xA3B0AF1),
                      fillColor: Colors.white,suffixIcon: IconButton(onPressed: (){
                        cont.text = '';
                  }, icon: Icon(Icons.close,size: 20,color: Colors.black45,)),
                      hintText: hintT,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                );
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



  // Future<void> _showFilDetails(BuildContext context, filliere fil) {
  //   return showModalBottomSheet(
  //       context: context,backgroundColor: Colors.white,
  //       // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
  //       //     topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
  //       isScrollControlled: true, // Rendre le contenu déroulable
  //
  //       builder: (BuildContext context){
  //         return Container(
  //           height: 500,
  //           decoration: BoxDecoration(borderRadius: BorderRadius.only(
  //               topRight: Radius.circular(20), topLeft: Radius.circular(20)),
  //             color: Colors.white,
  //           ),
  //           padding: const EdgeInsets.all(25.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             // mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Row(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 // mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   // Text("Element Infos", style: TextStyle(fontSize: 25),),
  //                   Text('Filière Infos',style: TextStyle(fontSize: 25,color: Colors.blueGrey),),
  //                   Spacer(),
  //                   InkWell(
  //                     child: Icon(Icons.close,color: Colors.blueGrey),
  //                     onTap: (){
  //                       setState(() {
  //                         Navigator.pop(context);
  //                       });
  //                     },
  //                   )
  //                 ],
  //               ),
  //               SizedBox(height: 40),
  //               rowInfos("Nom:", fil.name.toUpperCase()),
  //               SizedBox(height: 25),
  //               rowInfos("Niveau:", fil.niveau.capitalizeFirst),
  //               SizedBox(height: 25),
  //               rowInfos("Description:", fil.description),
  //
  //               SizedBox(height: 20),
  //               Row(
  //                 children: [
  //                   Text(
  //                     'Elements:',
  //                     style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
  //                   ),
  //                   SizedBox(width: 120,),
  //                   IconButton(
  //                       onPressed: () async {
  //                         Navigator.push(
  //                             context, MaterialPageRoute(
  //                             builder: (context) => FilElemsPage(filiId: fil.id)));
  //                       },
  //                       icon: Icon(Icons.format_list_bulleted)),
  //                   IconButton(
  //                       onPressed: () async {
  //                         String? filePath = await pickExcelFile();
  //                         if (filePath != null) {
  //                           uploadFileToBackend(filePath, fil.id);
  //                           Navigator.pop(context);
  //                         }
  //                       },
  //                       icon: Icon(Icons.cloud_upload_outlined))
  //
  //
  //                 ],
  //               ),
  //               Row(
  //                 children: [
  //                   Text(
  //                     'Emplois:',
  //                     style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
  //                   ),
  //                   SizedBox(width: 130,),
  //                   IconButton(
  //                       onPressed: () async {
  //                         Navigator.push(
  //                             context, MaterialPageRoute(
  //                             builder: (context) => FilEmploiPage(filiId: fil.id)));
  //                       },
  //                       icon: Icon(Icons.format_list_bulleted_outlined))
  //
  //
  //                 ],
  //               ),
  //               SizedBox(height: 25,),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                 children: [
  //                   ElevatedButton(
  //
  //                     onPressed: () async {
  //                       // setState(() {
  //                       //   // fetchfilliere();
  //                       //   Navigator.pop(context);
  //                       //
  //                       // });
  //                       _name.text = fil.name;
  //                       _desc.text = fil.description!;
  //                       _selectedNiveau = fil.niveau;
  //
  //                       showDialog(
  //                           context: context,
  //                           builder: (context) {
  //                             return AlertDialog(
  //                               insetPadding: EdgeInsets.only(top: 190,),
  //                               surfaceTintColor: Color(0xB0AFAFA3),
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.only(
  //                                   topRight: Radius.circular(20),
  //                                   topLeft: Radius.circular(20),
  //                                 ),
  //                               ),
  //                               title:
  //                               Row(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 // mainAxisAlignment: MainAxisAlignment.start,
  //                                 children: [
  //                                   Text("Modifier une Matiere", style: TextStyle(fontSize: 20),),
  //                                   Spacer(),
  //                                   InkWell(
  //                                     child: Icon(Icons.close),
  //                                     onTap: (){
  //                                       Navigator.pop(context);
  //                                     },
  //                                   )
  //                                 ],
  //                               ),
  //
  //                               content: Container(
  //                                 height: 450,
  //                                 width: MediaQuery.of(context).size.width,
  //                                 // padding: const EdgeInsets.all(25.0),
  //                                 child: SingleChildScrollView(
  //                                   child: Column(
  //                                     // mainAxisSize: MainAxisSize.min,
  //                                     children: [
  //
  //                                       SizedBox(height: 40),
  //                                       TextField(
  //                                         controller: _name,
  //                                         keyboardType: TextInputType.text,
  //                                         decoration: InputDecoration(
  //                                             filled: true,
  //                                             // fillColor: Color(0xA3B0AF1),
  //                                             fillColor: Colors.white,
  //                                             border: OutlineInputBorder(
  //                                                 borderSide: BorderSide.none,gapPadding: 1,
  //                                                 borderRadius: BorderRadius.all(Radius.circular(10.0)))),
  //                                       ),
  //
  //                                       SizedBox(height: 30),
  //                                       DropdownButtonFormField<String>(
  //                                         value: _selectedNiveau,
  //                                         items: [
  //                                           DropdownMenuItem<String>(
  //                                             child: Text('Licence'),
  //                                             value: "licence",
  //                                           ),
  //                                           DropdownMenuItem<String>(
  //                                             child: Text('Master'),
  //                                             value: "master",
  //                                           ),
  //                                           DropdownMenuItem<String>(
  //                                             child: Text('Doctorat'),
  //                                             value: "doctorat",
  //                                           ),
  //                                         ],
  //                                         onChanged: (value) {
  //                                           setState(() {
  //                                             _selectedNiveau = value!;
  //                                           });
  //                                         },
  //                                         decoration: InputDecoration(
  //                                           filled: true,
  //                                           // fillColor: Color(0xA3B0AF1),
  //                                           fillColor: Colors.white,
  //                                           border: OutlineInputBorder(
  //                                             borderSide: BorderSide.none,gapPadding: 1,
  //                                             borderRadius: BorderRadius.all(Radius.circular(10.0)),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                       SizedBox(height: 30),
  //
  //                                       TextFormField(
  //                                         controller: _desc,
  //                                         keyboardType: TextInputType.text,
  //                                         maxLines: 3,
  //                                         decoration: InputDecoration(
  //                                             filled: true,
  //
  //                                             // fillColor: Color(0xA3B0AF1),
  //                                             fillColor: Colors.white,
  //                                             hintText: "description",
  //                                             border: OutlineInputBorder(
  //                                                 borderSide: BorderSide.none,gapPadding: 1,
  //                                                 borderRadius: BorderRadius.all(Radius.circular(10.0)))),
  //                                       ),
  //                                       ElevatedButton(
  //                                         onPressed: () {
  //                                           Navigator.of(context).pop();
  //
  //                                           // fetchfilliere();
  //
  //                                           // AddCategory(_name.text, _desc.text);
  //                                           UpdateFilliere(fil.id, _name.text,_selectedNiveau,_desc.text,);
  //                                           // ScaffoldMessenger.of(context).showSnackBar(
  //                                           //   SnackBar(content: Text('Le filière est mis à jour avec succès.')),
  //                                           // );
  //                                           setState(() {
  //                                             // fetchfilliere();
  //                                             Navigator.pop(context);
  //                                           });
  //
  //                                         },
  //                                         child: Text("Modifier"),
  //
  //                                         style: ElevatedButton.styleFrom(
  //                                           backgroundColor: Color(0xff0fb2ea),
  //                                           foregroundColor: Colors.white,
  //                                           elevation: 10,
  //                                           minimumSize:  Size( MediaQuery.of(context).size.width , MediaQuery.of(context).size.width/7),
  //                                           // padding: EdgeInsets.only(left: MediaQuery.of(context).size.width /5,
  //                                           //     right: MediaQuery.of(context).size.width /5,bottom: 20,top: 20),
  //                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //                                         ),
  //                                       )
  //                                     ],
  //                                   ),
  //
  //
  //                                 ),
  //                               ),
  //
  //                             );
  //                           });
  //                     },
  //
  //
  //                     child: Text('Modifier'),
  //                     style: ElevatedButton.styleFrom(
  //                       surfaceTintColor: Colors.white,
  //                       // side: BorderSide(color: Colors.black38),
  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //                       elevation: 5,
  //                       padding: EdgeInsets.symmetric(horizontal: 25),
  //                       backgroundColor: Colors.white,
  //                       foregroundColor: Colors.green,
  //                       textStyle: TextStyle(fontWeight: FontWeight.bold),
  //                       // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  //                     ),
  //
  //                   ),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       showDialog(
  //                         context: context,
  //                         builder: (BuildContext context) {
  //                           return AlertDialog(
  //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
  //                             surfaceTintColor: Color(0xB0AFAFA3),
  //                             title: Text("Confirmer la suppression"),
  //                             content: Text(
  //                                 "Êtes-vous sûr de vouloir supprimer cet élément ?"),
  //                             actions: <Widget>[
  //                               TextButton(
  //                                 child: Text("ANNULER"),
  //                                 onPressed: () {
  //                                   Navigator.of(context).pop();
  //                                 },
  //                               ),
  //                               TextButton(
  //                                 child: Text(
  //                                   "SUPPRIMER",
  //                                   // style: TextStyle(color: Colors.red),
  //                                 ),
  //                                 onPressed: () {
  //                                   Navigator.of(context).pop();
  //                                   fetchfilliere();
  //
  //                                   DeleteFilliere(fil.id);
  //
  //                                   ScaffoldMessenger.of(context).showSnackBar(
  //                                     SnackBar(content: Text('Le Filière a été Supprimer avec succès.')),
  //                                   );
  //
  //                                   setState(() {
  //                                     fetchfilliere();
  //                                     Navigator.pop(context);
  //                                   });
  //
  //                                 },
  //                               ),
  //                             ],
  //                           );
  //                         },
  //                       );
  //                     }, // Disable button functionality
  //
  //                     child: Text('Supprimer'),
  //                     style: ElevatedButton.styleFrom(
  //                       surfaceTintColor: Colors.white,
  //                       // side: BorderSide(color: Colors.black38),
  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //                       elevation: 5,
  //                       padding: EdgeInsets.symmetric(horizontal: 25),
  //                       backgroundColor: Colors.white,
  //                       foregroundColor: Colors.redAccent,
  //                       textStyle: TextStyle(fontWeight: FontWeight.bold),
  //                       // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  //                     ),
  //
  //                   ),
  //                 ],
  //               ),
  //
  //             ],
  //           ),
  //         );
  //       }
  //
  //
  //   );
  // }

  Row rowInfos(label,value) {
    return Row(
                children: [
                  Text(label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                  SizedBox(width: 10,),
                  Container(
                    width: 200,
                    child: Text(value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                  ),
                ],
              );
  }

  void Addfilliere (String name,String niveau,String semestres) async {

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
        "semestres":semestres ,
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
                  content: Text("L\'element est modifié avec succès"),
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

        // print("L\'element est ajouté avec succès");


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
                      "L\'emploi n\'est pas modifier"),
                );});

        });
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
  final int? semestre;
  final dynamic semestres;
  final String? description;
  final bool? isPaireSemestre;

  filliere({
    required this.id,
    required this.name,
    required this.niveau,
     this.description,
     this.semestres,
     this.semestre,
     this.isPaireSemestre,
  });

  factory filliere.fromJson(Map<String, dynamic> json) {
    return filliere(
      id: json['_id'],
      name: json['name'],
      niveau: json['niveau'],
      description: json['description'],
      semestres: json['semestres'],
      semestre: json['semestre'],
      isPaireSemestre: json['isPaireSemestre'],
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


// class FilEmploiPage extends StatefulWidget {
//   final String filiId; // L'ID du groupe
//
//   FilEmploiPage({required this.filiId});
//
//   @override
//   _FilEmploiPageState createState() => _FilEmploiPageState();
// }
//
//
// class _FilEmploiPageState extends State<FilEmploiPage> {
//   late List<dynamic> emplois = [];
//   late Map<dynamic,dynamic> fill ={} ;
//   late String description = '';
//   late String niveau = '';
//
//   String day = 'Lundi';
//   bool coursesFound = false;
//   List<Professeur> professeurs = [];
//
//   List<Elem> matiereList = [];
//
//   Elem getMatIdFromName(String id) {
//     // Assuming you have a list of professeurs named 'professeursList'
//     final professeur = matiereList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>Elem(id: '', filId: ''));
//     // print(professeur.name);
//     return professeur; // Return the ID if found, otherwise an empty string
//
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchFilEmploi();
//     fetchProfs().then((data) {
//       setState(() {
//         professeurs = data; // Assigner la liste renvoyée par Groupesseur à items
//       });
//     }).catchError((error) {
//       print('Erreur: $error');
//     });
//     fetchElems().then((data) {
//       setState(() {
//         matiereList = data; // Assigner la liste renvoyée par Groupesseur à items
//       });
//     }).catchError((error) {
//       print('Erreur: $error');
//     });
//   }
//
//   Future<void> fetchFilEmploi() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String token = prefs.getString("token")!;
//
//     String apiUrl = 'http://192.168.43.73:5000/filiere/${widget.filiId}/emplois';
//     final response = await http.get(Uri.parse(apiUrl),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       Map<String, dynamic> data = jsonDecode(response.body);
//
//       setState(() {
//         fill = data['filiere'];
//         // description = data['description'];
//         // niveau = data['niveau'];
//         emplois = data['emplois'];
//         // Sort emplois by semester and day
//         emplois.sort((a, b) {
//           int semesterComparison = a['semestre'].compareTo(b['semestre']);
//           if (semesterComparison == 0) {
//             return a['dayNumero'].compareTo(b['dayNumero']);
//           }
//           return semesterComparison;
//         });
//       });
//     } else {
//       throw Exception('Failed to load group emploi');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 40,),
//           Container(
//             height: 50,
//             child: Row(
//               children: [
//                 TextButton(onPressed: (){
//                   Navigator.pop(context);
//                 }, child: Icon(Icons.arrow_back_ios,color: Colors.black,size: 20,)),
//                 // SizedBox(width: 3,),
//                 Text('Emplois du Filière ${(fill['name'] ?? '').toUpperCase()}',style: TextStyle(fontSize: 20),),
//               ],
//             ),
//           ),
//           Divider(),
//           Expanded(
//             child: Container(
//               width: MediaQuery.of(context).size.width,
//               child: _buildGroupedEmploisList(emplois)
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Map<String, Map<int, List<dynamic>>> groupEmploisByJourSemestre(List<dynamic> emplois) {
//     // Map<String, Map<int, List<dynamic>>> groupedEmplois = {};
//
//     for (var emploi in emplois) {
//       String jour = emploi['jour'];
//       int semestre = emploi['semestre'] ?? 0;
//
//       if (!groupedEmplois.containsKey(jour)) {
//         groupedEmplois[jour] = {};
//       }
//
//       if (!groupedEmplois[jour]!.containsKey(semestre)) {
//         groupedEmplois[jour]![semestre] = [];
//       }
//
//       groupedEmplois[jour]![semestre]!.add(emploi);
//     }
//
//     return groupedEmplois;
//   }
//   Widget _buildGroupedEmploisList(List<dynamic> emplois) {
//     Map<String, Map<int, List<dynamic>>> groupedEmplois = groupEmploisByJourSemestre(emplois);
//
//     return ListView.builder(
//       itemCount: groupedEmplois.length,
//       itemBuilder: (BuildContext context, int index) {
//         String jour = groupedEmplois.keys.elementAt(index);
//         Map<int, List<dynamic>> semestresEmplois = groupedEmplois[jour]!;
//
//         // Affichez les emplois pour chaque semestre du jour
//         return Padding(
//           padding: const EdgeInsets.only(top: 10.0),
//           child: Column(
//             children: [
//               ...semestresEmplois.entries.map((entry) {
//                 int semestre = entry.key;
//                 List<dynamic> emplois = entry.value;
//
//                 // Affichez les emplois pour ce semestre dans une seule table
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 10.0),
//                   child: Column(
//                     children: [
//                       if (_shouldDisplaySemestre(index, semestre))
//                         Text(
//                           'Semestre $semestre',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       _buildSemestreEmploisTable(emplois, jour),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Map<String, Map<int, List<dynamic>>> groupedEmplois = {};
//   bool _shouldDisplaySemestre(int index, int semestre) {
//     if (index == 0) {
//       // Affichez toujours le premier semestre
//       return true;
//     } else {
//       // Affichez le semestre si différent du précédent
//       String previousJour = groupedEmplois.keys.elementAt(index - 1);
//       int previousSemestre = groupedEmplois[previousJour]!.keys.first;
//       return semestre != previousSemestre;
//     }
//   }
//
//
//   Widget _buildSemestreEmploisTable(List<dynamic> emplois, String jour) {
//     return Container(
//       width: MediaQuery.of(context).size.width ,
//       decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.all(Radius.circular(30)),
//       ),
//       child: DataTable(
//         showCheckboxColumn: true,
//         showBottomBorder: true,
//         headingRowHeight: 50,
//         headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white10),
//         dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
//         columnSpacing: 8,
//         dataRowHeight: 50,
//         columns: [
//           DataColumn(label: Text(jour.capitalize!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic))),
//           // DataColumn(label: Text('')),
//           DataColumn(label: Text('')),
//           DataColumn(label: Text('')),
//           // DataColumn(label: Text('')),
//         ],
//         rows: _buildEmploiDataRow(emplois,dayRows,jour),
//         // rows: emplois.map<DataRow>((emploi) => _buildEmploiDataRow(emploi)).toList(),
//       ),
//     );
//   }
//   List<DataRow> dayRows = [];
//
//   List<DataRow> _buildEmploiDataRow(dynamic emploi,
//   List<DataRow> dayRows,String day ) {
//     for (var emp in emploi!) {
//       dayRows.add(
//           DataRow(color: MaterialStateColor.resolveWith((states) => Colors.white30),
//             cells: [
//               DataCell(Text(emp['startTime'],style: TextStyle(color: Colors.white),),),
//               DataCell(Text('à',style: TextStyle(color: Colors.white))),
//               DataCell(Text(emp['finishTime'],style: TextStyle(color: Colors.white))),
//             ],
//           )
//       );
//     dayRows.add(
//         DataRow(
//           cells: [
//             DataCell(Text(emp['code'].split('-')[1].toString().toUpperCase()!)),
//             DataCell(Text('${emp['type']}${emp['groupe'].split('-')[2]}')),
//             DataCell(Text(emp['nbh'].toString())),
//             // DataCell(Text(emploi['finishTime'])),
//           ],
//         )
//     );
//     dayRows.add(
//         DataRow(
//           cells: [
//             DataCell(Text(emp['name'].toString().capitalize!)),
//             DataCell(Container()),
//             DataCell(Container()),
//             // DataCell(Text(emploi['finishTime'])),
//           ],
//         )
//     );
//
//       dayRows.add(
//           DataRow(
//             cells: [
//               DataCell(Text('${emp['nom'].toString().capitalize!} ${emp['prenom'].toString().capitalize!}')),
//               DataCell(Container()),
//               DataCell(Container()),
//               // DataCell(Text(emploi['finishTime'])),
//             ],
//           )
//       );
//     }
//     return dayRows;
//   }
//
//
//
//
//
// }
String getProfIdFromName(String nom,professeurs) {
  // Assuming you have a list of professeurs named 'professeursList'
  final professeur = professeurs.firstWhere((prof) => '${prof.id}' == nom, orElse: () =>Professeur(id: ''));
  print("ProfName:${professeur.nom}");
  return "${professeur.nom} ${professeur.prenom}".toString().capitalize!; // Return the ID if found, otherwise an empty string

}



class FilElemsPage extends StatefulWidget {
  final String filiId; // L'ID du groupe

  FilElemsPage({required this.filiId});

  @override
  _FilElemsPageState createState() => _FilElemsPageState();
}

class _FilElemsPageState extends State<FilElemsPage> {
  late List<dynamic> elems =[];
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
        elems = data['elements'];
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
          SizedBox(child: Center(child: Text('Il y a ${elems.length} elements')),),
          Expanded(
              child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                child: Container(
                  height: 700,
                  decoration: BoxDecoration(
                    color: elems.length > 0 ? Colors.black87:Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),       // margin: EdgeInsets.only(left: 10),
                  child: SingleChildScrollView(scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white10),
                      dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                      showCheckboxColumn: true,
                      showBottomBorder: true,
                      headingRowHeight: 50,headingTextStyle: TextStyle(color: Colors.white),
                      // headingRowColor: MaterialStateColor.resolveWith((states) => Colors.lightBlueAccent.shade100), // Couleur de la ligne d'en-tête
                      columnSpacing: 8,
                      dataRowHeight: 90,
                      columns: [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Code')),
                        DataColumn(label: Text('Sem')),
                        DataColumn(label: Text('Matiere')),
                        // DataColumn(label: RichText(text: TextSpan(children: [TextSpan(text: 'ProfCM')]))),
                        DataColumn(label: Text('Professeur CM')),
                        DataColumn(label: Text('Professeur TP')),
                        DataColumn(label: Text('Professeur TD')),
                        // DataColumn(label: Text('HCM')),
                        // DataColumn(label: Text('HTP')),
                        // DataColumn(label: Text('HTD')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: [
                        for (var index = 0; index < (elems?.length ?? 0); index++)
                        // for (var categ in emplois!)
                          DataRow(
                              cells: [
                                DataCell(Text((index + 1).toString(),style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Text(elems?[index]['code'].split('-')[1],style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Text('S${elems?[index]['semestre']}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Container(width: 75,
                                  child: Text('${elems?[index]['name'].toString().capitalize}',style: TextStyle(
                                    color: Colors.black,
                                  ),),
                                )),
                                DataCell(SingleChildScrollView(scrollDirection: Axis.vertical,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (var prof in elems?[index]['professeurCM'])
                                      Text('${getProfIdFromName(prof['_id'],professeurs)} /',style: TextStyle(
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
                                          for (var prof in elems?[index]['professeurTP'])
                                    Text('${getProfIdFromName(prof['_id'],professeurs)} /',style: TextStyle(
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
                                      for (var prof in elems?[index]['professeurTD'])
                                    Text('${getProfIdFromName(prof['_id'],professeurs)} /',style: TextStyle(
                                        color: Colors.black,
                                      ),),
                                    ],
                                  ),
                                )),
                                // DataCell(Text('${elems?[index]['heuresCM']}',style: TextStyle(
                                //   color: Colors.black,
                                // ),)),
                                // DataCell(Text('${elems?[index]['heuresTP']}',style: TextStyle(
                                //   color: Colors.black,
                                // ),)),
                                // DataCell(Text('${elems?[index]['heuresTD']}',style: TextStyle(
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
                                            _showElemDetails(context,elems,index,elems[index]['_id']);
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

//      bottomNavigationBar: BottomNav(),

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
            decoration: BoxDecoration(borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              color: Colors.white,
            ),
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

                        for (var prof in elems?[index]['professeurCM'])
                          // for (var prof in ele?[index]['info']['CM'])
                          Text('${getProfIdFromName(prof['_id'],professeurs)} /',
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
                        for (var prof in elems?[index]['professeurTP'])
                          Text('${getProfIdFromName(prof['_id'],professeurs)} /',
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
                        for (var prof in elems?[index]['professeurTD'])
                          Text("${getProfIdFromName(prof['_id'],professeurs)}",
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
                      ElevatedButton(
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
                                      filId: ele[index]['filiere']['_id'],  fil: ele[index]['filiere']['name'],
                                      ProfCMId: ele[index]['professeurCM'], ProfTPId: ele[index]['professeurTP'],ProfTDId: ele[index]['professeurTD'],
                                    )));
                          });
                          // selectedMat = emp.mat!;


                        },// Disable button functionality

                        child: Text('Modifier'),
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          // side: BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),

                      ),
                      ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          // side: BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),

                      ),
                      ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          // side: BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.redAccent,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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



}



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmploiPage extends StatefulWidget {
  final String profId; // L'ID du professeur

  EmploiPage({required this.profId});

  @override
  _EmploiPageState createState() => _EmploiPageState();
}

class _EmploiPageState extends State<EmploiPage> {
  // late List<ProfEmploi> emplois;
  late List<ProfEmploi> emplois = [];

  @override
  void initState() {
    super.initState();
    fetchEmplois();

  }

  Future<void> fetchEmplois() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    String apiUrl = 'http://192.168.43.73:5000/emploi/${widget.profId}/professeur';
    final response = await http.get(Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      // Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> filData = data['emplois'];

      setState(() {
        emplois = List<ProfEmploi>.from(data['emplois'].map((emp) => ProfEmploi.fromJson(emp)));
      });
      print("My Data${filData}");
    } else {
      throw Exception('Failed to load emplois');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Column(
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
                Text('Mon emploi',style: TextStyle(fontSize: 20),),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: MediaQuery.of(context).size.width ,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    // margin: EdgeInsets.only(left: 10),
                    child: DataTable(
                      showCheckboxColumn: true,
                      showBottomBorder: true,
                      // headingRowColor: MaterialStateColor.resolveWith((states) => Colors.lightBlueAccent.shade100), // Couleur de la ligne d'en-tête
                      headingRowHeight: 50,horizontalMargin: 10,
                      headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
                      columnSpacing: 10,
                      dataRowHeight: 70,
                      columns: [
                        DataColumn(label: Text('Jours')),
                        DataColumn(label: Text('Matière')),
                        DataColumn(label: Text('Filière')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Deb')),
                        // DataColumn(label: Text('Fin')),
                        // DataColumn(label: Text('Action')),
                      ],
                      rows: [
                        for (var index = 0; index < (emplois?.length ?? 0); index++)
                        // for (var categ in emplois!)
                          DataRow(
                              cells: [
                                DataCell(Container(width: 60,
                                  child: Text('${emplois?[index].day.capitalizeFirst}',style: TextStyle(
                                    color: Colors.black,
                                  ),),
                                )),
                                // DataCell(Text('${emplois?[index].filliere.toUpperCase()}${emplois[index].semestre}',style: TextStyle(
                                //   color: Colors.black,
                                // ),)),
                                DataCell(Container(
                                  width: 80,
                                  child: Text('${emplois?[index].matiere.capitalize}',style: TextStyle(
                                    color: Colors.black,
                                  ),),
                                )),
                                DataCell(Container(
                                  width: 70,
                                  child: Text('${emplois?[index].classe.capitalize}',style: TextStyle(
                                    color: Colors.black,
                                  ),),
                                )),
                                DataCell(Text('${emplois?[index].type}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Container(width: 40,
                                  child: Text('${emplois?[index].startTime}',style: TextStyle(
                                    color: Colors.black,
                                  ),),
                                )),
                                // DataCell(Text('${emplois?[index].finishTime}',style: TextStyle(
                                //   color: Colors.black,
                                // ),)),


                              ]),
                      ],
                    ),

                  ),
                ),
              ),
            ),
          ),
        ],
      )

    );
  }
}

class ProfEmploi {
  final String id;
  final String day;
  final String startTime;
  final String finishTime;
  final int dayNumero;
  final String type;
  final double nbh;
  final String classe;
  final String matiere;
  // final Mats matiere;

  ProfEmploi({
    required this.id,
    required this.day,
    required this.startTime,
    required this.finishTime,
    required this.dayNumero,
    required this.type,
    required this.nbh,
    required this.classe,
    required this.matiere,
  });

  factory ProfEmploi.fromJson(Map<String, dynamic> json) {
    return ProfEmploi(
      id: json['_id'],
      day: json['jour'],
      startTime: json['startTime'],
      finishTime: json['finishTime'],
      dayNumero: json['dayNumero'],
      type: json['type'],
      nbh: json['nbh'],
      matiere: json['matiere'],
      classe: json['classe'],
      // matiere: Mats.fromJson(json['matiere']),
    );
  }
}

class Mats {
  final String id;
  final String name;
  final String categorie;
  final int numero;
  final int prix;
  final String code;

  Mats({
    required this.id,
    required this.name,
    required this.categorie,
    required this.numero,
    required this.prix,
    required this.code,
  });

  factory Mats.fromJson(Map<String, dynamic> json) {
    return Mats(
      id: json['_id'],
      name: json['name'],
      categorie: json['categorie'],
      numero: json['numero'],
      prix: json['prix'],
      code: json['code'],
    );
  }
}




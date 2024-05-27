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

  String getMatCode(String elements) {
    List<dynamic> ids = elements.split('-'); // Sépare la chaîne en une liste d'IDs
    print(ids);
    print(ids[1]);
    return ids[1];
  }

  Future<void> fetchEmplois() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    String apiUrl = 'http://192.168.43.73:5000/professeur/${widget.profId}/emplois';
    final response = await http.get(Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('blabla ${response.statusCode}');
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      Map<String, dynamic> emploisData = data['emplois'];

      List<ProfEmploi> allEmplois = [];

      emploisData.forEach((jour, emploisJour) {
        List<dynamic> emploisJourList = emploisJour;
        List<ProfEmploi> emploisJourParsed = emploisJourList.map((emp) => ProfEmploi.fromJson(emp)).toList();
        allEmplois.addAll(emploisJourParsed);
      });

      setState(() {
        emplois = allEmplois;
      });
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
          Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width ,
                      decoration: BoxDecoration(
                          // color: Colors.indigo.shade500,
                          color: Colors.black87,
                          borderRadius: BorderRadius.all(Radius.circular(30))
                      ),
                      child: DataTable(
                        showCheckboxColumn: true,
                        showBottomBorder: true,
                        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white12), // Couleur de la ligne d'en-tête
                        dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white), // Couleur de la ligne d'en-tête
                        headingRowHeight: 50,horizontalMargin: 10,
                        headingTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
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
                                    child: Text('${getMatCode(emplois![index].code).toUpperCase()}',style: TextStyle(
                                      color: Colors.black,
                                    ),),
                                  )),
                                  DataCell(Container(
                                    width: 70,
                                    child: Text('${emplois?[index].fil.toUpperCase()}',style: TextStyle(
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
                  ],
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
  // final String classe;
  final String matiere;
  final String code;
  final String fil;

  ProfEmploi({
    required this.id,
    required this.day,
    required this.startTime,
    required this.finishTime,
    required this.dayNumero,
    required this.type,
    required this.nbh,
    // required this.classe,
    required this.matiere,
    required this.code,
    required this.fil,
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
      matiere: json['element'],
      // classe: json['classe'],
      code: json['code'],
      fil: json['filiere'],
      // matiere: Mats.fromJson(json['matiere']),
    );
  }
}
class ProfEmplois {
  final dynamic Lun;
  final dynamic Mar;
  final dynamic Mer;
  final dynamic Jeu;
  final dynamic Ven;
  final dynamic Sam;
  final dynamic Dim;

  ProfEmplois( {
    required this.Lun,
    this.Mar,
    this.Mer,
    this.Jeu,
    this.Ven,
    this.Sam,
    this.Dim,
  });

  factory ProfEmplois.fromJson(Map<String, dynamic> json) {
    return ProfEmplois(
      Lun: json['lundi'],
      Mar: json['mardi'],
      Mer: json['mercredi'],
      Jeu: json['jeudi'],
      Ven: json['vendredi'],
      Sam: json['samedi'],
      Dim: json['dimanche'],
    );
  }
}





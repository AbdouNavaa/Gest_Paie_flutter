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
        print('MonEmp:${emplois}');
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
              child: SingleChildScrollView(scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    buildDataTable(emplois,'lundi'),
                    // SizedBox(height: 20,),
                    buildDataTable(emplois,'mardi'),
                    // SizedBox(height: 20,),
                    buildDataTable(emplois,'mercredi'),
                    // SizedBox(height: 20,),
                    buildDataTable(emplois,'jeudi'),
                    // SizedBox(height: 20,),
                    buildDataTable(emplois,'vendredi'),
                    // SizedBox(height: 20,),
                    buildDataTable(emplois,'samedi'),
                    // SizedBox(height: 20,),
                    buildDataTable(emplois,'dimanche'),
                  ],
                ),
              ),
            ),
          ),
        ],
      )

    );
  }

  Container buildDataTable(List<ProfEmploi> emp, day) {
                List<DataRow> dayRows = [];
                for (var emp in emp!) {
                  if (emp?.day == day) {
                    // dayRows.add(
                    //   DataRow(
                    //     cells: [
                    //
                    //       DataCell(Container()
                    //       ),
                    //       DataCell(Container()
                    //       ),
                    //       DataCell(Container()
                    //       ),
                    //     ],
                    //   ),
                    // );
                    dayRows.add(
                      DataRow(
                        color: MaterialStateColor.resolveWith((states) => Colors.black87),

                        cells: [
                          DataCell(Container(child:
                          Text(emp.startTime!, style: TextStyle(color: Colors.white)),)
                          ),
                          DataCell(Text('à',style: TextStyle(color: Colors.white),)
                          ),
                          DataCell(Container(child:
                          Text(emp.finishTime!, style: TextStyle(color: Colors.white)),)
                          ),


                        ],
                      ),
                    );
                    dayRows.add(
                      DataRow(
                        cells: [

                          DataCell(Text('${emp.code!.split('-')[1].toUpperCase()}'),//abdou
                          ),

                          DataCell(Text('${emp.fil!.toUpperCase()}')),
                          DataCell(Text('${emp.type!.toUpperCase()}')),
                        ],
                      ),
                    );
                    dayRows.add(
                      DataRow(
                        cells: [
                          DataCell(Text(emp.matiere!.toString().capitalize!, style: TextStyle(color: Colors.black))),
                          DataCell(Container()),
                          DataCell(Container()),


                        ],
                      ),
                    );




                  }
                }

                bool vide =emp.any((em) => em.day == day);
                // Construisez le DataTable pour le jour donné
                return  vide? Container(
                  margin: EdgeInsets.only(bottom: 10),
                  width: MediaQuery.of(context).size.width -10,
                  decoration: BoxDecoration(
                    // color: Colors.indigo.shade500,
                    // color: Colors.black87,
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: DataTable(
                    // showCheckboxColumn: true,
                    // showBottomBorder: true,
                    headingRowHeight: 50,
                    columnSpacing: 15,
                    dataRowHeight: 60,
                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.indigo),
                    // headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white10),
                    dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                    horizontalMargin: 10,

                    headingTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    columns: [
                      DataColumn(label: Container(width: 80,
                        child: Text(day.toString().capitalize! ,
                          style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),
                        ),
                      ),),
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                    ],
                    rows: dayRows,

                  ),
                ): Container();
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





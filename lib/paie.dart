import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Paie extends StatefulWidget {
  final List<dynamic> paies;

  final String ProfId;
  final String Id;
  final String ProfName;
  DateTime? dateDeb;
  DateTime? dateFin;
// Calculate the sums for filtered courses

  Paie({required this.paies, required this.ProfName,
    required this.ProfId, required this.Id}) {}


  @override
  State<Paie> createState() => _PaieState();
}

class _PaieState extends State<Paie> {
  double totalType = 0;
  double somme = 0;

  bool showPaid = true;
   List<dynamic> paies = [];

  Future<void> fetchPaiements(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    var url = Uri.parse('http://192.168.43.73:5000/paiement/$id/professeur');

    var responseInitialise = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Ajoutez le type de contenu
      },
      body: jsonEncode({"notification": ""}), // Encodez votre corps en JSON
    );


    if (responseInitialise.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(responseInitialise.body);
      paies = jsonResponse['paiements'];
      // print('Paiements avec status "initialisé": ${paies.length}');
    } else {
      print('Request for "initialisé" failed with status: ${responseInitialise.statusCode}');
    }

  }
  void Confirm(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    var url = Uri.parse('http://192.168.43.73:5000/paiement/$id/confirmation');


    var reponse = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Ajoutez le type de contenu
      },
      body: jsonEncode({}), // Ou d'autres valeurs pour "validé"
    );

    if (reponse.statusCode == 200) {
      // Map<String, dynamic> jsonResponse = jsonDecode(responseInitialise.body);
      // paies = jsonResponse['paiements'];
      print('Paiement est confirmer avec status ');
      setState(() {
        Navigator.pop(context);
      });
    } else {
      print('Request for "validé" failed with status: ${reponse.statusCode}');
    }

  }
  void Refuse(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    var url = Uri.parse('http://192.168.43.73:5000/paiement/$id/confirmation');

    var reponse = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Ajoutez le type de contenu
      },
      body: jsonEncode({"refuse": ""}), // Encodez votre corps en JSON
    );



    if (reponse.statusCode == 200) {
      // Map<String, dynamic> jsonResponse = jsonDecode(responseInitialise.body);
      // paies = jsonResponse['paiements'];
      print('Paiement est refuser avec success ');
      setState(() {
        Navigator.pop(context);
      });
    } else {
      print('Request for "initialisé" failed with status: ${reponse.statusCode}');
    }

  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // widget.courses;
    // fetchPaiements(widget.Id);
  }





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
                   TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: Icon(Icons.arrow_back_ios,color: Colors.black,size: 20,)),
                // SizedBox(width: 5,),
                Text("Paiements à confirmer",style: TextStyle(fontSize: 20),)
              ],
            ),
          ),

          // showPaid?
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 30),
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
                      headingRowHeight: 50,
                      columnSpacing: 8,headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
                      dataRowHeight: 50,
                      columns: [
                        DataColumn(label: Text('Du')),
                        DataColumn(label: Text('Au')),
                        DataColumn(label: Text('NBC')),
                        DataColumn(label: Text('NBH')),
                        DataColumn(label: Text('MT')),
                        // DataColumn(label: Text('Statut')),
                        DataColumn(label: Text('Confirmation')),
                        // DataColumn(label: Text('Action')),
                      ],
                      rows: [
                        for (var index = 0; index < (widget.paies?.length ?? 0); index++)
                        // for (var categ in filteredItems!)
                          DataRow(
                              cells: [
                                DataCell(Text('${DateFormat('dd/MM ').format(DateTime.parse(widget.paies![index]["fromDate"].toString()).toLocal())}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Text('${DateFormat('dd/MM ').format(DateTime.parse(widget.paies![index]["toDate"].toString()).toLocal())}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Text('${widget.paies![index]["nbc"]}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Text('${widget.paies![index]["nbh"].toString()}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Text('${widget.paies![index]["totalMontant"].toString()}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                // DataCell(Text('${widget.paies![index]["status"].toString()}',style: TextStyle(
                                //   color: Colors.black,
                                // ),)),
                                // DataCell(Text('${widget.paies![index]["confirmation"].toString()}',style: TextStyle(
                                //   color: Colors.black,
                                // ),)),
                                DataCell(
                                  Row(
                                    children: [
                                      Container(
                                        width: 35,
                                        child: TextButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  surfaceTintColor: Color(0xB0AFAFA3),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                                                  title: Row(
                                                    children: [
                                                      Text("Refusion"),
                                                      SizedBox(width: 90,),
                                                      Icon(Icons.thumb_down_off_alt_outlined, color: Colors.redAccent.shade200,)
                                                    ],
                                                  ),
                                                  content: Container(height: 200,
                                                    child: Column(
                                                      children: [
                                                        Container(height: 40,
                                                          child: Text(
                                                              "Êtes-vous sûr de vouloir refuser ce paiement ?"),
                                                        ),
                                                        TextFormField(maxLines: 5,decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.red.shade100))),
                                                          initialValue: 'Message de Refusion',)
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text("Annuler",style: TextStyle(color: Colors.red)),
                                                      // child: Text("Non"),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                        "Envoyer",
                                                        style: TextStyle(color: Colors.green),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();

                                                        // fetchCategory();
                                                        Refuse(widget.paies![index]["_id"]);
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
                                                                      "Le paiement est refusé"),

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
                                          }, // Disable button functionality
                                          child: Icon(Icons.thumb_down_alt_outlined, color: Colors.red,),

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
                                                  surfaceTintColor: Color(0xB0AFAFA3),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                                                  title: Row(
                                                    children: [
                                                      Text("Confirmation"),
                                                     SizedBox(width: 80,),
                                                      Icon(Icons.thumb_up_alt_outlined, color: Colors.lightGreen,)
                                                    ],
                                                  ),
                                                  content: Text(
                                                      "Êtes-vous sûr de vouloir confirmer ce paiement ?"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text("Annuler",style: TextStyle(color: Colors.red)),
                                                      // child: Text("Non"),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                        "Confirmer",
                                                        style: TextStyle(color: Colors.green),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();

                                                        // fetchCategory();
                                                        Confirm(widget.paies![index]["_id"]);
                                                        // print(filteredItems?[index].id!);
                                                        // Navigator.of(context).pop();
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
                                                                      "Le paiement est confirmé"),

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
                                          }, // Disable button functionality
                                          child: Icon(Icons.thumb_up_alt_outlined, color: Colors.lightGreen,),

                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                                // DataCell(Container(width: 105,
                                //     child: Text('${categ.description}',)),),


                              ]),
                      ],
                    ),

                  ),
                ),
              ),
            ),
          )
              // :Container()




        ],
      ),


    );

  }
}

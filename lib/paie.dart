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
          SizedBox(height: 30,),
          Container(
            height: 50,
            child: Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
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
                  child: InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    }, child: Icon(Icons.arrow_back_ios_new_outlined,size: 20,color: Colors.black,),

                  ),
                ),
                SizedBox(width: 50,),
                Text("Etat de Paiement",style: TextStyle(fontSize: 25),)
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
                      headingRowHeight: 50,
                      columnSpacing: 8,
                      dataRowHeight: 50,
                      columns: [
                        DataColumn(label: Text('De')),
                        DataColumn(label: Text('Vers')),
                        // DataColumn(label: Text('Prof')),
                        // DataColumn(label: Text('Banq')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('confirmation')),
                        DataColumn(label: Text('Action')),
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
                                DataCell(Text('${widget.paies![index]["status"].toString()}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Text('${widget.paies![index]["confirmation"].toString()}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
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
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),elevation: 1,
                                                  title: Text("Confirmer la Refusion"),
                                                  content: Text(
                                                      "Êtes-vous sûr de vouloir refuser cet paiement ?"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text("ANNULER"),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                        "OK",
                                                        // style: TextStyle(color: Colors.red),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();

                                                        // fetchCategory();
                                                        Refuse(widget.paies![index]["_id"]);
                                                        // print(filteredItems?[index].id!);
                                                        // Navigator.of(context).pop();
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Le Paiement a été Rfuser avec succès.')),
                                                        );
                                                        setState(() {
                                                          // Navigator.pop(context);
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }, // Disable button functionality
                                          child: Icon(Icons.refresh_outlined, color: Colors.black,),

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
                                                  title: Text("Confimation"),
                                                  content: Text(
                                                      "Êtes-vous sûr de vouloir confirmer cet paiement ?"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text("ANNULER"),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                        "OK",
                                                        // style: TextStyle(color: Colors.red),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();

                                                        // fetchCategory();
                                                        Confirm(widget.paies![index]["_id"]);
                                                        // print(filteredItems?[index].id!);
                                                        // Navigator.of(context).pop();
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Le Paiement a été Confirmer avec succès.')),
                                                        );
                                                        setState(() {
                                                          // Navigator.pop(context);
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }, // Disable button functionality
                                          child: Icon(Icons.check_box_outlined, color: Colors.black,),

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

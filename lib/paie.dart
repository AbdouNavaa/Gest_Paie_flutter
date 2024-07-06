import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  void Refuse(id,message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;

    var url = Uri.parse('http://192.168.43.73:5000/paiement/$id/confirmation');

    var reponse = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Ajoutez le type de contenu
      },
      body: jsonEncode(<String, String>{"refuse": "","message": message}), // Encodez votre corps en JSON
    );


    print('Dadi: ${reponse.statusCode}');

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

  TextEditingController _message = TextEditingController();


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

          Divider(),
          // showPaid?
              for (var index = 0; index < (widget.paies?.length ?? 0); index++)
          Container(width: 310,height: 215,color: Colors.white,margin: EdgeInsets.only(top: 10),
            child: Card(color: Colors.white,shadowColor: Colors.black,surfaceTintColor: Colors.white,elevation: 8,
              child: SingleChildScrollView(scrollDirection: Axis.vertical,
                child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 310,height: 50,decoration: BoxDecoration(borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                  ),color: Colors.black),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Du: ${DateFormat('dd/MM/yyyy ').format(DateTime.parse(widget.paies![index]["fromDate"].toString()).toLocal())}',
                        style: WhiteStyle(),
                      ),
                      Text('Au: ${DateFormat('dd/MM/yyyy ').format(DateTime.parse(widget.paies![index]["toDate"].toString()).toLocal())}',
                        style: WhiteStyle(),
                      ),
                    ],
                  ),
                    ),

                  SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                    Text('Nombre de Cours: ${widget.paies![index]["nbc"]}',
                      style: MyStyle(),
                    ),
                  ],),
                  SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                    Text('Nombre d\'heures: ${widget.paies![index]["nbh"]}',
                      style: MyStyle(),
                    ),
                  ],),
                  SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                    Text('Montant Total: ${widget.paies![index]["somme"]}', style: MyStyle(),
                    ),
                  ],),

                  SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  surfaceTintColor: Color(0xB0AFAFA3),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                                  title: Row(
                                    children: [
                                      Text("Refusé"),
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
                                        TextFormField(
                                          controller: _message,
                                          maxLines: 5,
                                          decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.red.shade100))),
                                          // initialValue: 'Message de Refusion',
                                        )

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
                                        print('Hello${widget.paies![index]["_id"]},${_message.text}');
                                        Refuse(widget.paies![index]["_id"],_message.text);
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
                          child: Text('Refusé',style: WhiteStyle(),),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)))),

                        ),

                             ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(titlePadding: EdgeInsets.all(1),
                                  surfaceTintColor: Color(0xB0AFAFA3),insetPadding: EdgeInsets.only(top: 100,left: 25,right: 25),
                                  titleTextStyle: GoogleFonts.abhayaLibre( color: Colors.white,
                                    fontSize: 20.0,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                                  title: Container(height: 50,
                                    decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10))
                                  ),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Confirmation"),
                                        Icon(Icons.check_circle_outline_outlined,size: 30,color: Colors.white),
                                      ],
                                    ),
                                  ),
                                  content: Text("Êtes-vous sûr de vouloir confirmer ce paiement ?"),
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
                          child: Text('Confirmer',style: WhiteStyle(),),

                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)))),
                        ),

                      ),


                    ],
                  ),
                ],
                            ),
              ),),
          )




        ],
      ),


    );

  }

  TextStyle WhiteStyle() {
    return GoogleFonts.abhayaLibre(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        );
  }

  TextStyle MyStyle() {
    return GoogleFonts.abhayaLibre(
            color: Colors.black,
            fontSize: 20.0,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfPaies extends StatefulWidget {
  final List<dynamic> paies;

  final String ProfId;
  final String Id;
  final String ProfName;
  DateTime? dateDeb;
  DateTime? dateFin;
// Calculate the sums for filtered courses

 ProfPaies({required this.paies, required this.ProfName,
    required this.ProfId, required this.Id}) {}


  @override
  State<ProfPaies> createState() => _PaieState();
}

class _PaieState extends State<ProfPaies> {
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
      body: jsonEncode({}), // Encodez votre corps en JSON
    );


    if (responseInitialise.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(responseInitialise.body);
      paies = jsonResponse['paiements'];
      print('Paiements avec status "initialisé": ${paies.length}');
    } else {
      print('Request for "initialisé" failed with status: ${responseInitialise.statusCode}');
    }

    // if (responseValide.statusCode == 200) {
    //   Map<String, dynamic> jsonResponse = jsonDecode(responseValide.body);
    //   paies = jsonResponse['paiements'];
    //   print('Paiements avec status "validé": $paies');
    // }
    // else {
    //   print('Request for "validé" failed with status: ${responseValide.statusCode}');
    // }
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


  // void calculateTotalType() {
  //   if (widget.dateDeb != null && widget.dateFin != null) {
  //     // If date filters are applied
  //     totalType = widget.courses.where((course) {
  //       DateTime courseDate = DateTime.parse(course['date'].toString());
  //       return (course['isSigned'] != "en attente" && course['isPaid'] == "en attente") && // Filter courses with signs
  //           (courseDate.isAtSameMomentAs(widget.dateDeb!.toLocal()) || (courseDate.isAfter(widget.dateDeb!.toLocal()) &&
  //               courseDate.isBefore(widget.dateFin!.toLocal().add(Duration(days: 1)))));
  //     }).map((course) => double.parse(course['TH'].toString())).fold(0, (prev, amount) => prev + amount);
  //
  //     somme = widget.courses.where((course) {
  //       DateTime courseDate = DateTime.parse(course['date'].toString());
  //       return ( course['isSigned'] != "en attente"&& course['isPaid'] == "en attente") && // Filter courses with signs
  //           (courseDate.isAtSameMomentAs(widget.dateDeb!.toLocal()) ||
  //               (courseDate.isAfter(widget.dateDeb!.toLocal()) &&
  //                   courseDate.isBefore(
  //                       widget.dateFin!.toLocal().add(Duration(days: 1)))));
  //     }).map((course) => double.parse(course['somme'].toString())).fold(0, (prev, amount) => prev + amount);
  //   } else if ((widget.dateDeb != null && widget.dateFin == null) || (widget.dateDeb == null && widget.dateFin != null)) {
  //     // If date filters are applied
  //     totalType = 0;
  //     somme = 0;
  //   } else {
  //     // If no date filters are applied
  //     int startIndex = (currentPage - 1) * coursesPerPage;
  //     int endIndex = startIndex + coursesPerPage - 1;
  //     totalType = widget.courses.skip(startIndex).take(coursesPerPage).where((course) =>
  //     (course['isSigned'] != 'en attente' && course['isPaid'] == "en attente")).map((course) => double.parse(course['TH'].toString())).fold(0, (prev, amount) => prev + amount);
  //     somme = widget.courses.skip(startIndex).take(coursesPerPage).where((course) =>
  //     (course['isSigned'] != 'en attente'&& course['isPaid'] == "en attente" )).map((course) => double.parse(course['somme'].toString())).fold(0, (prev, amount) => prev + amount);
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // widget.courses;
    // fetchPaiements(widget.Id);
  }


  int currentPage = 1;
  int coursesPerPage = 5;
  String searchQuery = '';
  bool sortByDateAscending = true;
  bool isSigned = false;




  @override
  Widget build(BuildContext context) {
    // calculateTotalType();
    // print("Addd: ${widget.Id}");
    return Scaffold(
      // appBar: AppBar(title:
      // Center(child: Text('${widget.coursNum} Courses',
      //   style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.bold,color: Colors.white),),)),
      body: Column(
        children: [
          SizedBox(height: 40,),
          Container(
            height: 50,
            // color: Color(0xB0AFAFA3),
            child: Row(
              children: [
                   TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: Icon(Icons.arrow_back_ios,color: Colors.black,size: 20,)),
                // SizedBox(width: 40,),
                Text("État de Paiement",style: TextStyle(fontSize: 20),)
              ],
            ),
          ),



          Divider(),

          // Padding(padding: EdgeInsets.all(20)),

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
                      SizedBox(height: 10),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Confirmation: ${widget.paies![index]["confirmation"]!.toString().capitalize}', style: MyStyle(),
                          ),
                        ],),

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

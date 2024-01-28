import 'dart:convert';

import 'package:flutter/material.dart';
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
  //       return (course['isSigned'] != "pas encore" && course['isPaid'] == "pas encore") && // Filter courses with signs
  //           (courseDate.isAtSameMomentAs(widget.dateDeb!.toLocal()) || (courseDate.isAfter(widget.dateDeb!.toLocal()) &&
  //               courseDate.isBefore(widget.dateFin!.toLocal().add(Duration(days: 1)))));
  //     }).map((course) => double.parse(course['TH'].toString())).fold(0, (prev, amount) => prev + amount);
  //
  //     somme = widget.courses.where((course) {
  //       DateTime courseDate = DateTime.parse(course['date'].toString());
  //       return ( course['isSigned'] != "pas encore"&& course['isPaid'] == "pas encore") && // Filter courses with signs
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
  //     (course['isSigned'] != 'pas encore' && course['isPaid'] == "pas encore")).map((course) => double.parse(course['TH'].toString())).fold(0, (prev, amount) => prev + amount);
  //     somme = widget.courses.skip(startIndex).take(coursesPerPage).where((course) =>
  //     (course['isSigned'] != 'pas encore'&& course['isPaid'] == "pas encore" )).map((course) => double.parse(course['somme'].toString())).fold(0, (prev, amount) => prev + amount);
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



          Padding(padding: EdgeInsets.all(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  DateTime? selectedDateDeb = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  );

                  if (selectedDateDeb != null) {
                    setState(() {
                      widget.dateDeb = selectedDateDeb.toUtc();
                      // totalType = 0; // Reset the totalId
                    });
                  }
                },
                child: Text(widget.dateDeb != null ? DateFormat('yyyy/MM/dd').format(widget.dateDeb!) : 'Date Deb'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0fb2ea),foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),

              ),
              ElevatedButton(
                onPressed: () async {
                  DateTime? selectedDateFin = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  );

                  if (selectedDateFin != null) {
                    setState(() {
                      widget.dateFin = selectedDateFin.toUtc();
                      // totalType = 0; // Reset the totalId
                    });
                  }
                },
                child: Text(widget.dateFin != null ? DateFormat('yyyy/MM/dd').format(widget.dateFin!) : 'Date Fin'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff0fb2ea),foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ],          ),

          Padding(padding: EdgeInsets.all(20)),

          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: SizedBox(
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Row(
          //           children: [
          //             ElevatedButton(
          //               onPressed: () {
          //                 setState(() {
          //                   showPaid = false;
          //                   // showSigned = !showSigned;
          //                 });
          //               },
          //               style: ElevatedButton.styleFrom(
          //                   shape: RoundedRectangleBorder(
          //                       borderRadius: BorderRadius.circular(10)),
          //                   padding: EdgeInsets.only(left: 40, right: 40),
          //                   backgroundColor: showPaid? Colors.white:Colors.white70,foregroundColor: Colors.black54,side: BorderSide(color: Colors.black12,width: 1)),
          //               child: Row(
          //                 children: [
          //                   Text('Facture'),
          //                   Icon(Icons.fact_check_outlined)
          //                 ],
          //               ),
          //
          //             ),
          //             SizedBox(width: 10),
          //             ElevatedButton(
          //               onPressed: () {
          //                 setState(() {
          //                   showPaid = true;
          //                   // Navigator.push(context, MaterialPageRoute(builder: (context) => PaieList()));
          //
          //                 });
          //               },
          //               style: ElevatedButton.styleFrom(
          //                   shape: RoundedRectangleBorder(
          //                       borderRadius: BorderRadius.circular(10)),
          //                   padding: EdgeInsets.only(left: 30, right: 30),
          //                   backgroundColor: showPaid? Colors.white70:Colors.white,foregroundColor: Colors.black54,side: BorderSide(color: Colors.black12,width: 1)),
          //               child: Row(
          //                 children: [
          //                   Text('Notifications'),
          //                   Icon(Icons.message_outlined)
          //                 ],
          //               ),
          //             ),
          //           ],
          //         ),
          //
          //       ],
          //     ),
          //   ),
          // ),

          // showPaid?
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
                                DataCell(Text('${widget.paies![index]["status"].toString()}',style: TextStyle(
                                  color: Colors.black,
                                ),)),
                                DataCell(Text('${widget.paies![index]["confirmation"].toString()}',style: TextStyle(
                                  color: Colors.black,
                                ),)),


                              ]),
                      ],
                    ),

                  ),
                ),
              ),
            ),
          )
          //     :Expanded(
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.only(
          //         topLeft: Radius.circular(20),
          //         topRight: Radius.circular(20),
          //       ),
          //     ),
          //     child: Padding(
          //       padding: const EdgeInsets.all(1.0),
          //       child: SingleChildScrollView(
          //         scrollDirection: Axis.horizontal,
          //         child: Container(
          //           decoration: BoxDecoration(
          //             color: Colors.white12,
          //             borderRadius: BorderRadius.all(
          //               Radius.circular(20.0),
          //             ),
          //           ),
          //           margin: EdgeInsets.only(left: 10),
          //           child: DataTable(
          //             showCheckboxColumn: true,
          //             showBottomBorder: true,
          //             horizontalMargin: 1,
          //             headingRowHeight: 50,
          //             columnSpacing: 18,
          //             dataRowHeight: 50,
          //             headingTextStyle: TextStyle(
          //               fontWeight: FontWeight.bold,
          //               color: Colors.black, // Set header text color
          //             ),
          //             // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xff0fb2ea)), // Set row background color
          //             columns: [
          //               DataColumn(label: Text('Enseignant')),
          //               DataColumn(label: Text('Volume Horaire')),
          //               DataColumn(label: Text('Montant')),
          //             ],
          //             rows: [
          //                   DataRow(
          //                     cells: [
          //                       DataCell(Text('${widget.ProfName}',style: TextStyle(
          //                         color: Colors.black,
          //                       ),),///hmmm
          //                       ),
          //                       DataCell(
          //                         Text('${totalType.toStringAsFixed(2)}',style: TextStyle(
          //                           color: Colors.black,
          //                         ),),
          //                       ),
          //                       DataCell(
          //                         Text('${somme.toStringAsFixed(2)}',style: TextStyle(
          //                           color: Colors.black,
          //                         ),),
          //                       ),
          //                     ],
          //                   ),
          //                   DataRow(
          //                     cells: [
          //                       DataCell(Text('Montant Totale (MRU)',style: TextStyle(
          //                         color: Colors.black,
          //                       ),),///hmmm
          //                       ),
          //                       DataCell(
          //                         Text(''),
          //                       ),
          //                       DataCell(
          //                         Text('${somme.toStringAsFixed(2)}',style: TextStyle(
          //                         color: Colors.black,
          //                       ),),
          //                       ),
          //                     ],
          //                   ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),




        ],
      ),


    );

  }
}
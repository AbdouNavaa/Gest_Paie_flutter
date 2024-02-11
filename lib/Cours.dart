import 'dart:convert';
import 'package:gestion_payements/professeures.dart';
import 'package:gestion_payements/semestre.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'categories.dart';
import 'constants.dart';
import 'element.dart';
import 'filliere.dart';
import 'group.dart';
import 'matieres.dart';


class CoursesPage extends StatefulWidget {
  final List<dynamic> courses;
  final int coursNum;
  // final num heuresTV;
  final String role;
  // final num sommeTV;
  DateTime? dateDeb;
  DateTime? dateFin;
// Calculate the sums for filtered courses

  CoursesPage({required this.courses, required this.role, required this.coursNum}) {}



  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  double totalType = 0;
// Calculate totalType based on applied date filters and pagination
  double somme = 0;
  int coursesNum = 0;
  List<Professeur> professeurList = [];

  String getProfesseurIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = professeurList.firstWhere((prof) => '${prof.id}' == id, orElse: () => Professeur(id: '',user: '', matieres: [], ));
    print(professeur.user);
    return professeur.user!; // Return the ID if found, otherwise an empty string

  }

  void payeCours( id,String isPaid) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.patch(
      Uri.parse("http://192.168.43.73:5000/cours" + "/$id/paye"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'isPaid':isPaid
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      // Fetch the updated list of Matieres and update the UI
      setState(() {
        Navigator.pop(context);
      });
    } else {
      return Future.error('Server Error');
    }
  }


  void calculateTotalType() {
    if (widget.dateDeb != null && widget.dateFin != null) {
      // If date filters are applied
      List<dynamic> coursesInDateRange = widget.courses.where((course) {
        DateTime courseDate = DateTime.parse(course['date'].toString());
        return courseDate.isAtSameMomentAs(widget.dateDeb!.toLocal()) ||
            (courseDate.isAfter(widget.dateDeb!.toLocal()) &&
                courseDate.isBefore(
                    widget.dateFin!.toLocal().add(Duration(days: 1))));
      }).toList();

      // Nombre de cours dans la période spécifiée
      coursesNum = coursesInDateRange.length;

      // Calcul d'autres valeurs en fonction de la liste filtrée des cours
      totalType = coursesInDateRange
          .map((course) => double.parse(course['TH'].toString()))
          .fold(0, (prev, amount) => prev + amount);

      somme = coursesInDateRange
          .map((course) => double.parse(course['somme'].toString()))
          .fold(0, (prev, amount) => prev + amount);

      // Utilisez nombreDeCours, totalType, somme comme nécessaire
    }
    else if ((widget.dateDeb != null && widget.dateFin == null) || (widget.dateDeb == null && widget.dateFin != null) ) {
      // If date filters are applied
      totalType = 0;
      somme = 0;
    }else {
      // If no date filters are applied
      int startIndex = (currentPage - 1) * coursesPerPage;
      int endIndex = startIndex + coursesPerPage - 1;
      totalType = widget.courses
          .skip(startIndex)
          .take(coursesPerPage)
          .map((course) => double.parse(course['TH'].toString()))
          .fold(0, (prev, amount) => prev + amount);

      somme = widget.courses
          .skip(startIndex)
          .take(coursesPerPage)
          .map((course) => double.parse(course['somme'].toString()))
          .fold(0, (prev, amount) => prev + amount);
    }
  }


  TextEditingController _date = TextEditingController();
  TextEditingController _time = TextEditingController();
  List<Elem> elLis = [];

  Elem getEls(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final element = elLis.firstWhere((g) => '${g.id}' == id, orElse: () => Elem(id: '', filId: '', MatId: '', ));
    print( "Els:${element}");
    return element!; // Return the ID if found, otherwise an empty string

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchProfs().then((data) {
      setState(() {
        professeurList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchElems().then((data) {
      setState(() {
        elLis = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

  }

  void DeleteCours(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/cours' +"/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      // fetchCategory();
      setState(() {
        Navigator.pop(context);
      });
    }

  }


  int currentPage = 1;
  int coursesPerPage = 10;
  String searchQuery = '';
  bool sortByDateAscending = true;
  bool showSigned = false;
  bool showPaid = false;
  bool courseFitsCriteria(Map<String, dynamic> course) {
    // Apply your filtering criteria here
    DateTime courseDate = DateTime.parse(course['date'].toString());
    bool isMatch = (
        course['matiere'].toLowerCase().contains(searchQuery.toLowerCase()) || course['professeur'].toLowerCase().contains(searchQuery.toLowerCase())
            || course['isSigned'].toString().contains(searchQuery.toLowerCase())
    );
    // || course['isPaid'].toString().contains(searchQuery.toLowerCase()));

    // Check if the course date falls within the selected date range
    if ((widget.dateDeb == null || courseDate.isAtSameMomentAs(widget.dateDeb!.toLocal()) ||
        courseDate.isAfter(widget.dateDeb!.toLocal())) &&
        (widget.dateFin == null ||
            courseDate.isBefore(widget.dateFin!.toLocal().add(Duration(days: 1))) ||
            courseDate.isAtSameMomentAs(widget.dateFin!.toLocal()))) {
      return isMatch; // Return whether the course matches the criteria
    }

    return false; // Course doesn't meet criteria
  }





bool showFloat = false;
  @override
  Widget build(BuildContext context) {
    // Call the method to calculate totalType
    calculateTotalType();
    return Scaffold(
      // appBar: AppBar(title: Center(child: Text('${widget.coursNum} Courses',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.w400),))),
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
                Text("Liste de Cours",style: TextStyle(fontSize: 25),),

                SizedBox(width: 60,),
                // Container(
                //   width: 50,
                //   height: 50,
                // color: Colors.black26,
                // child: IconButton(icon:Icon(Icons.cached, size: 40,color: Colors.black38), onPressed: () => auto(),),
                // )

              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width/1.075,
            margin: EdgeInsets.only(left: 8,top: 5,bottom: 5),
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
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Recherche ',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),



          Container(
            width: 300,
            height: 50,
            // color: Colors.black38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Icon(Icons.not_interested,),
                Text('Pas encore'),
                SizedBox(width: 8,),
                Icon(Icons.indeterminate_check_box_outlined,),
                Text('En Cours'),
                SizedBox(width: 8,),
                Icon(Icons.check_circle_outline,),
                Text('Oui')
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(scrollDirection: Axis.vertical,
              child: Container(
                height: MediaQuery.of(context).size.height -100,
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
                      height: MediaQuery.of(context).size.height,
                      padding: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      // margin: EdgeInsets.only(left: 3),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            DataTable(
                              showCheckboxColumn: true,
                              showBottomBorder: true,
                              // sortColumnIndex: 1,
                              // sortAscending: true,
                              // headingRowColor: MaterialStateColor.resolveWith((states) => Colors.lightBlueAccent.shade100), // Couleur de la ligne d'en-tête
                              headingRowHeight: 50,
                              columnSpacing:  (!showPaid && !showSigned)?8: 25,
                              horizontalMargin:  3,
                              // border: TableBorder(verticalInside: BorderSide(width: 1.5)),
                              dataRowHeight: 60,
                              headingTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Set header text color
                              ),
                              // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFF0C2FDA)), // Set row background color
                              columns: [
                                // if ( showSigned)
                                if (!showPaid)
                                  DataColumn(label: InkWell(
                                      // onTap: (){
                                      //   setState(() {
                                      //     showSigned = !showSigned;
                                      //   });
                                      //
                                      // },
                                      child: Text('Signé'))),
                                // if (widget.role == "admin" && showPaid)
                                if (widget.role == "admin"&& !showSigned )
                                  DataColumn(label: InkWell(
                                      // onTap: (){
                                      //   setState(() {
                                      //     showPaid = !showPaid;
                                      //   });
                                      //
                                      // },
                                      child: Text('Paié'))),
                                DataColumn(label: InkWell(
                                    // onTap: (){
                                    //   setState(() {
                                    //     totalType =0;
                                    //     sortByDateAscending = !sortByDateAscending;
                                    //     // Reverse the sorting order when the button is tapped
                                    //     widget.courses.sort((a, b) {
                                    //       DateTime dateA = DateTime.parse(a['date'].toString());
                                    //       DateTime dateB = DateTime.parse(b['date'].toString());
                                    //
                                    //       // Sort in ascending order if sortByDateAscending is true,
                                    //       // otherwise sort in descending order
                                    //       return sortByDateAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
                                    //     });
                                    //   });
                                    //
                                    //
                                    // },
                                    child: Text('Date'))),
                                DataColumn(label: Text('Prof')),
                                DataColumn(label: Text('Matiere')),
                                DataColumn(label: Text('Eq.CM')),
                                // DataColumn(label: Text('Prix')),
                                DataColumn(label: Text('Details')),
                              ],


                              rows: [
                                for (var index = (currentPage - 1) * coursesPerPage;
                                index < widget.courses.length && index < currentPage * coursesPerPage;
                                index++)
                                  if (courseFitsCriteria(widget.courses[index]))
                                    if ((!showSigned || widget.courses[index]['isSigned'] == 'oui') &&
                                        (!showPaid || widget.courses[index]['isPaid'] == 'oui' || widget.courses[index]['isPaid'] == 'préparée'))
                                      DataRow(
                                        onLongPress: () =>
                                            _showCourseDetails(context, widget.courses[index]),

                                        cells: [
                                          // DataCell(Text('${index + 1}',style: TextStyle(fontSize: 18),)), // Numbering cell
                                          // if ( showSigned)
                                          if (!showPaid)
                                            DataCell(
                                              Container(
                                                margin: EdgeInsets.only(left: 5),
                                                width: 20,color: Colors.white,
                                                child: Icon( widget.courses[index]['isSigned'] =="oui"?  Icons.check_circle_outline:Icons.not_interested,
                                                  size: 25,),
                                              ),
                                            ),
                                          if (widget.role == "admin" && !showSigned)
                                          // if (widget.role == "admin")
                                            DataCell(
                                              InkWell(
                                                child:     Container(
                                                  margin: EdgeInsets.only(right: 5),
                                                  width: 20,
                                                  color: Colors.white,
                                                  child: Icon( widget.courses[index]['isPaid'] =="oui" ?
                                                  Icons.check_circle_outline:widget.courses[index]['isPaid'] =="préparée"  ?
                                                  Icons.indeterminate_check_box_outlined:
                                                  Icons.not_interested,
                                                    size: 25,),
                                                ),
                                              ),
                                            ),
                                          DataCell(
                                            Container(width: 35,
                                              child: Text(
                                                '${DateFormat('dd/M ').format(
                                                  DateTime.parse(widget.courses[index]['date'].toString()).toLocal(),
                                                )}',style: TextStyle(
                                                color: Colors.black,
                                              ),
                                              ),
                                            ),
                                          ),
                                          DataCell(Container(width: 50,child: Text('${widget.courses[index]['professeur']}',style: TextStyle(
                                            color: Colors.black,
                                          ),)),
                                              onTap: () => _showCourseDetails(context, widget.courses[index])
                                          ),
                                          DataCell(Container(width: 55,child: Text('${widget.courses[index]['matiere']}',style: TextStyle(
                                            color: Colors.black,
                                          ),)),
                                            onTap: () => _showCourseDetails(context, widget.courses[index])
                                          ),
                                          DataCell(
                                            Center(child: Container(width: 20, child: Text('${widget.courses[index]['TH']}',style: TextStyle(
                                              color: Colors.black,
                                            ),))),
                                          ),
                                          // DataCell(
                                          //   Text('${widget.courses[index]['somme']}',style: TextStyle(
                                          //     color: Colors.black,
                                          //   ),),
                                          // ),
                                          DataCell(
                                            Row(
                                              // mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 25,
                                                  child: TextButton(
                                                    onPressed: () =>_showCourseDetails(context, widget.courses[index]),// Disable button functionality

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
                                        ],
                                      ),
                                // if (!showPaid && !showSigned)
                                // DataRow(
                                //   cells: [
                                //     if (!showPaid)
                                //       DataCell(
                                //           Text('Totals:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                                //       ),
                                //     if (widget.role == "admin"&& !showSigned)
                                //       DataCell(
                                //           (widget.dateDeb != null && widget.dateFin != null)?
                                //       Text('${coursesNum}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),):
                                //       Text('${widget.coursNum}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                                //       ),
                                //
                                //
                                //     DataCell(
                                //       Text('Eq. CM: ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                                //
                                //     ),
                                //     DataCell(
                                //       Text('${totalType}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),),
                                //
                                //     ),
                                //     DataCell(
                                //       Text('MT:',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                                //
                                //     ),
                                //     DataCell(
                                //         Text('${somme}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                                //     ),
                                //    DataCell(
                                //      Text('')
                                //       ),
                                //
                                //   ],
                                // ),


                              ],
                            ),
                            // Container(
                            //   width: MediaQuery.of(context).size.width,
                            //   margin: EdgeInsets.only(top: 20,left: 10),
                            //   child: DataTable(
                            //
                            //     showCheckboxColumn: true,
                            //     showBottomBorder: true,
                            //     horizontalMargin: 1,
                            //     headingRowHeight: 50,
                            //     columnSpacing: 18,
                            //     dataRowHeight: 50,
                            //     headingTextStyle: TextStyle(
                            //       fontWeight: FontWeight.bold,
                            //       color: Colors.black, // Set header text color
                            //     ),
                            //     // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xff0fb2ea)), // Set row background color
                            //     columns: [
                            //       DataColumn(label: Text('Equivalant CM')),
                            //       DataColumn(label: Text('Montant Total')),
                            //       DataColumn(label: Text('Nombre de Cours')),
                            //     ],
                            //     rows: [
                            //       DataRow(
                            //         cells: [
                            //
                            //           DataCell((widget.dateDeb != null && widget.dateFin != null)?
                            //           Text('${totalType} heures',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                            //               :Text('${totalType} heures',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),),
                            //           ),
                            //           DataCell((widget.dateDeb != null && widget.dateFin != null)?
                            //           Text('${somme} MRU',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400))
                            //               :Text('${somme} MRU',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                            //           ),
                            //           DataCell((widget.dateDeb != null && widget.dateFin != null)?
                            //           Center(child: Text('${coursesNum} Cours',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400)))
                            //               :Text('${widget.courses.length} Cours',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                            //           ),
                            //
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            Container(
                                width: MediaQuery.of(context).size.width-20,
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                margin: EdgeInsets.only(left: 10,top: 20),
                                child: Row(
                                  children: [
                                    Text('Totals', style: TextStyle(fontWeight: FontWeight.bold),),

                                    SizedBox(width: 40,),
                                    (widget.dateDeb != null && widget.dateFin != null)?
                                    Text('${coursesNum} Cours',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                                        :Text('${widget.courses.length} Cours',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),),


                                    SizedBox(width: 30,),

                                    (widget.dateDeb != null && widget.dateFin != null)?
                                    Text('${somme} MRU',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400))
                                        :Text('${somme} MRU',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),),

                                    SizedBox(width: 20,),

                                    (widget.dateDeb != null && widget.dateFin != null)?
                                    Text('${totalType} H',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                                        :Text('${totalType} H',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),),


                                  ],
                                )
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Visibility(
            visible: widget.courses.length > coursesPerPage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (currentPage > 1) {
                        currentPage--;
                      }
                    });
                  },
                  child: Text('Precedant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
                Container(
                  width: 115,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(currentPage.toString()),
                          Text('/'),
                          Text((widget.courses.length / coursesPerPage).ceil().toString()),
                        ],
                      ),
                      Text('(${coursesPerPage} Cours par page)')
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    int totalPage = (widget.courses.length / coursesPerPage).ceil();
                    setState(() {
                      if (currentPage < totalPage) {
                        currentPage++;
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    child: Text('Suivant'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),

          )


        ],
      ),

      floatingActionButton: showFloat ?
      Container(
          width: 320,
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

          margin: EdgeInsets.only(left: 40,right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            TextButton(
              child: Row(
                children: [
                  Icon(Icons.filter_list_alt, color: Colors.black,),
                  Text('Filtrer',style: TextStyle(color: Colors.black),),
                ],
              ),
              onPressed: () => _filtrer(context),

            ),

            // SizedBox(width: 210,),
            TextButton(
              child: Row(
                children: [
                  Icon(Icons.sort, color: Colors.black,),
                  Text('Trier',style: TextStyle(color: Colors.black),),
                ],
              ),
              onPressed: () => _trier(context),

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

      // bottomNavigationBar: BottomNav(),
    );

  }

  Future<void> _showCourseDetails(BuildContext context, Map<String, dynamic> course) {
    return showModalBottomSheet(
        context: context,backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return Container(
            height: 650,
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Cours Infos',style: TextStyle(fontSize: 30),),
                SizedBox(height: 50),
                Row(
                  children: [
                    Text('Prof:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                    SizedBox(width: 10,),
                    Text(course['professeur'].toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Matiere:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${course['matiere']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Date:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${DateFormat('dd/M/yyyy ').format(DateTime.parse(course['date'].toString()).toLocal())}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                  ],
                ),
                SizedBox(height: 25),
                Row(children: [
                  Row(
                    children: [
                      Text('Deb:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text('${course['startTime']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),


                    ],
                  ),
                  SizedBox(width: 15),
                  Row(
                    children: [
                      Text('Fin:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text('${course['finishTime']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                    ],
                  ),
                ],),
                SizedBox(height: 25),

                Row(children: [
                  Row(
                    children: [
                      Text('Type:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text('${course['type']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                    ],
                  ),
                  SizedBox(width: 15),
                  Row(
                    children: [
                      Text('NbH:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                      SizedBox(width: 10,),
                      Text('${course['nbh']} heures',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          // color: Colors.lightBlue
                        ),),

                    ],
                  ),
                ],),
                //    SizedBox(height: 25),


                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Eq.CM:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${course['TH']} heures',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Montant Total:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${course['somme']}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Signé:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text(
                      course['isSigned'] == "oui"?
                      'Oui':'Pas encore',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                  ],
                ),
                SizedBox(height: 25),
                if (widget.role == "admin")
                  Column(
                    children: [
                      Row(
                        children: [
                          Text('Payé:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),),

                          SizedBox(width: 10,),
                          Text(
                            course['isPaid'] =="oui"?
                            'Oui':course['isPaid'] =="préparée"?'Préparée' :'Pas encore',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              // color: Colors.lightBlue
                            ),),

                        ],
                      ),
                    ],
                  ),
                SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {

                        setState(() {
                          Navigator.pop(context);
                        });
                        // selectedMat = emp.mat!;
                        _time.text = course['startTime'];
                        _date.text = DateFormat('yy/MM/dd ').format(DateTime.parse(course['date'].toString()).toLocal(),);
                        // nbhValues = course['nbh'];
                        // typeNames = course['type'];

                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UpdateCoursScreen(empId: course['_id'], start: course['startTime'],date: course['date'],
                              EM:course['matiere'], EP:course['professeur'], TN: course['type'], TH: course['nbh'], GN: '', MId: course['matiere_id'], PId: course['professeur_id'],)),
                          );
                        });
                      },// Disable button functionality

                      child: Text('Modifier'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.only(left: 20,right: 20),
                        foregroundColor: Colors.lightGreen,
                        backgroundColor: Colors.white,
                        // side: BorderSide(color: Colors.black,),
                        elevation: 3,
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
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
                                    DeleteCours(course['_id']);
                                    setState(() {
                                      Navigator.pop(context);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Le Category a été Supprimer avec succès.')),
                                    );
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
                        backgroundColor: Colors.white,
                        // side: BorderSide(color: Colors.black,),
                        elevation: 3,
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
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

  Future<void> _displayTextInputDialog(BuildContext context) async {
    // setState(() {
    //   Navigator.pop(context);
    // });
    return showDialog(
      context: context,
      builder: (context) {
        return AddCoursScreen();
      },
    );
  }
  Future<void> _filtrer(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Container(
            child: AlertDialog(
                insetPadding: EdgeInsets.only(top: 250,),


                        surfaceTintColor: Color(0xB0AFAFA3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                title: Text('Ajouter un Filter'),
                content: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 390,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Date', style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15 ),),
                          ],
                        ),

                        SizedBox(height: 10,),
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
                                   Navigator.pop(context);
                                    // totalType = 0; // Reset the totalId
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  Text(widget.dateDeb != null ? DateFormat('yyyy/MM/dd').format(widget.dateDeb!) : 'Date Deb'),
                                  Icon(Icons.calendar_month_outlined)
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                          surfaceTintColor: Color(0xB0AFAFA3),
                                  foregroundColor: Colors.black,
                                  side: BorderSide(color: Colors.black38),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),

                            ),
                            // Container(width: 50,
                            //   child:Text('total: ${totalType.toStringAsFixed(2)}'),
                            // ),
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
                                   Navigator.pop(context);
                                    // totalType = 0; // Reset the totalId
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  Text(widget.dateFin != null ? DateFormat('yyyy/MM/dd').format(widget.dateFin!) : 'Date Fin'),
                                  Icon(Icons.calendar_month_outlined)
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                          surfaceTintColor: Color(0xB0AFAFA3),
                                  foregroundColor: Colors.black,
                                  side: BorderSide(color: Colors.black38),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            ),
                          ],          ),

                        SizedBox(height: 50,),
                        Row(
                         mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Type', style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15 ),),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(

                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(onPressed: (){
                              setState(() {
                                showSigned = !showSigned;
                                Navigator.of(context).pop();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Le filtre est appliquer avec succès.')),
                              );

                            }
                            , child: Row(
                              children: [
                                Icon(Icons.check_circle_outline),
                                Text("Signé"),
                              ],
                            ),
                              style: ElevatedButton.styleFrom(
                                // backgroundColor: Color(0xff0fb2ea),
                                //         surfaceTintColor: Color(0xB0AFAFA3),
                                surfaceTintColor: showSigned?  Colors.lightGreenAccent: Colors.white,
                                foregroundColor: Colors.black,
                                side: BorderSide(color: Colors.black38),
                                elevation: 10,
                                padding: EdgeInsets.only(left: 40, right: 40),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          SizedBox(width: 10,),
                          ElevatedButton(onPressed: (){
                              // Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Le filtre est appliquer avec succès.')),
                              );
                              setState(() {
                                showPaid = !showPaid;
                                Navigator.of(context).pop();
                              });
                            }
                            , child: Row(
                              children: [
                                Icon(Icons.check_circle_outline),
                                Text("Paié"),
                              ],
                            ),
                              style: ElevatedButton.styleFrom(
                                surfaceTintColor: showPaid?  Colors.lightGreenAccent: Colors.white,
                                foregroundColor: Colors.black,
                                side: BorderSide(color: Colors.black38),
                                elevation: 10,
                                padding: EdgeInsets.only(left: 40, right: 40),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                )
            ),
          );
        });
  }

  Future<void> _trier(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
                      surfaceTintColor: Color(0xB0AFAFA3),
              insetPadding: EdgeInsets.only(top: 300,),
// backgroundColor: Color(0xB0AFAFA3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              title: Text('Trier les Cours'),
              content: Container(
                width: MediaQuery.of(context).size.width,
                height: 330,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 30,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Date: Ancienne à Récente', style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15 ),),
                          SizedBox(width: 100,),
                          Radio(
                            value: 'responsable',
                            groupValue: sortByDateAscending,
                            onChanged: (value) {
                              setState(() {
                                totalType =0;
                                sortByDateAscending = !sortByDateAscending;
                                // Reverse the sorting order when the button is tapped
                                widget.courses.sort((a, b) {
                                  DateTime dateA = DateTime.parse(a['date'].toString());
                                  DateTime dateB = DateTime.parse(b['date'].toString());

                                  // Sort in ascending order if sortByDateAscending is true,
                                  // otherwise sort in descending order

                                  return dateA.compareTo(dateB) ;
                                });
                              });
                            },
                          ),
                        ],
                      ),
                      Divider(color: Colors.black38,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Date: Récente à Ancienne', style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15 ),),
                          SizedBox(width: 100,),
                          Radio(
                            value: '',hoverColor: Colors.black,activeColor: Colors.green,
                            groupValue: sortByDateAscending,
                            onChanged: (value) {
                              setState(() {
                                // sortByDateAscending = !sortByDateAscending;
                                // Reverse the sorting order when the button is tapped
                                widget.courses.sort((a, b) {
                                  DateTime dateA = DateTime.parse(a['date'].toString());
                                  DateTime dateB = DateTime.parse(b['date'].toString());

                                  // Sort in ascending order if sortByDateAscending is true,
                                  // otherwise sort in descending order

                                  return dateB.compareTo(dateA);
                                });
                              });
                            },

                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              )
          );
        });
  }





}


class AddCoursScreen extends StatefulWidget {
  @override
  _AddCoursScreenState createState() => _AddCoursScreenState();
}

class _AddCoursScreenState extends State<AddCoursScreen> {
  // Déclarez vos variables ici
  String _selectedType = 'CM';
  num _selectedNbh = 1.5;
  // ... Ajoutez d'autres variables nécessaires pour l'ajout
  // List<emploi>? filteredItems;

  TextEditingController _date = TextEditingController();
  int _selectedNum = 1;

  Group? selectedGroup;
  Elem? selectedElem;
  filliere? selectedFil;
  Semestre? selectedSem;
  Matiere? selectedMat;
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];
  DateTime? selectedDateTime;

  Future<void> updateProfesseurList() async {
    if (selectedElem != null) {
      List<Professeur> fetchedProfesseurs = await fetchProfesseursByMatiere(selectedElem!.MatId);
      setState(() {
        professeurs = fetchedProfesseurs;
        selectedProfesseur = null;
      });
    } else {
      List<Professeur> fetchedProfesseurs = await fetchProfs();
      setState(() {
        professeurs = fetchedProfesseurs;
        selectedProfesseur = null;
      });
    }
  }

  List<Professeur> professeurList = [];
  List<Group> grpList = [];
  List<Group> grpList1 = [];
  List<Elem> elList = [];
  List<Elem> elList1 = [];
  List<Matiere> matiereList = [];
  List<filliere> filList = [];
  List<Semestre> SemList = [];
  List<Semestre> SemList1 = [];

  Future<void> updateElementList(String semestreId) async {
    // try {
    // Utilisez l'ID du semestre pour récupérer les éléments correspondants
    List<Elem> elements = await fetchElementsBySemestre(semestreId);

    setState(() {
      elList = elements;
      selectedElem = null; // Réinitialiser la sélection de l'élément
    });
    // } catch (error) {
    //   print('Erreur lors de la récupération des éléments: $error');
    // }
  }

  List<Semestre> filterItemsByFil(filliere? fil, List<Semestre> allItems) {
    if (fil == null) {
      return allItems;
    } else {
      return allItems.where((emp) => emp!.filliereId == fil.id).toList();
    }
  }
  List<Group> filterItemsBySem(Semestre? sem, List<Group> allItems) {
    if (sem == null) {
      return allItems;
    } else {
      return allItems.where((emp) => emp.semestre!.id == sem!.id).toList();
    }
  }
  List<Elem> filterElsbySem(String FilId, int sem,List<Elem> allItems) {
    if (FilId == null) {
      return [];
    } else {
      return allItems.where((emp) => emp.filId == FilId && emp.SemNum == sem).toList();
    }
  }

  TextEditingController _time = TextEditingController();

  Future<void> selectDate(TextEditingController controller) async {
    DateTime? selectedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (selectedDateTime != null) {
      String formattedDateTime = DateFormat('yyyy/MM/dd').format(selectedDateTime);
      setState(() {
        controller.text = formattedDateTime;
      });
    }
  }
  bool isChanged =false;

  Elem getEls(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final element = elList.firstWhere((g) => '${g.id}' == id, orElse: () => Elem(id: '', filId: '', MatId: '', ));
    print( "Els:${element}");
    return element!; // Return the ID if found, otherwise an empty string

  }


  String getFilIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final fil = filList.firstWhere((f) => '${f.id}' == id, orElse: () =>filliere(id: '', name: '', description: '', niveau: ''));
    // print(id);
    return fil.name; // Return the ID if found, otherwise an empty string

  }
  Future<void> selectTime(TextEditingController controller) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      String formattedTime = selectedTime.format(context); // Utilise la méthode format avec le context


      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  String getProfEmailFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final prof = professeurList.firstWhere((f) => '${f.id}' == id, orElse: () =>Professeur(id: 'id'));
    // print("ProfMail${professeurList}");
    print("ProfMail${prof.email!}");
    return prof.email!; // Return the ID if found, otherwise an empty string

  }


  @override
  void initState() {
    super.initState();
    fetchElems().then((data) {
      setState(() {
        elList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchGroup().then((data) {
      setState(() {
        grpList = data; // Assigner la liste renvoyée par emploiesseur à items
      });

      fetchProfs().then((data) {
        setState(() {
          professeurList = data; // Assigner la liste renvoyée par emploiesseur à items
          print('Hello');
        });
      }).catchError((error) {
        print('Erreur: $error');
      });

      fetchMatiere().then((data) {
        setState(() {
          matiereList = data; // Assigner la liste renvoyée par emploiesseur à items
        });
      }).catchError((error) {
        print('Erreur: $error');
      });

    }).catchError((error) {
      print('Erreur: $error');
    });

    fetchfilliere().then((data) {
      setState(() {
        filList = data; // Assigner la liste renvoyée par emploiesseur à items
      });



    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchSemestre().then((data) {
      setState(() {
        SemList = data; // Assigner la liste renvoyée par emploiesseur à items
      });



    }).catchError((error) {
      print('Erreur: $error');
    });

  }

  Elem getElem(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final elem = elList.firstWhere((f) => '${f.id}' == id, orElse: () =>Elem(id: '', filId: '', MatId: '', ));
    print(elem.id);
    return elem; // Return the ID if found, otherwise an empty string

  }

  Future<void> updateElemList() async {
    if (selectedGroup != null) {
      Elem fetchedmatieres = getElem(selectedGroup!.id);
      setState(() {
        selectedElem = fetchedmatieres;
      });
    } else {
      List<Elem> fetchedmatieres = await fetchElems();
      setState(() {
        elList = fetchedmatieres;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        insetPadding: EdgeInsets.only(top: 80,),

        surfaceTintColor: Color(0xB0AFAFA3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Ajouter une Cours", style: TextStyle(fontSize: 25),),
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
          width: MediaQuery.of(context).size.width,
          // height: 600,
          // color: Color(0xA3B0AF1),
          child: SingleChildScrollView(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                // _buildTypesInput(),
                SizedBox(height: 30),
            
                Row(
                  children: [
                    Container(
                      width: 147.5,
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        items: [
                          DropdownMenuItem<String>(
                            child: Text('CM'),
                            value: 'CM',
                          ),
                          DropdownMenuItem<String>(
                            child: Text('TP'),
                            value: 'TP',
                          ),
                          DropdownMenuItem<String>(
                            child: Text('TD'),
                            value: 'TD',
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Colors.white,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
            
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 147.5,
                      child: DropdownButtonFormField<num>(
                        value: _selectedNbh,
                        items: [
                          DropdownMenuItem<num>(
                            child: Text('1.5'),
                            value: 1.5,
                          ),
                          DropdownMenuItem<num>(
                            child: Text('2'),
                            value: 2,
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedNbh = value!;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Colors.white,
                          fillColor: Colors.white,
                          hintText: "taux",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
            
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _date,
                  decoration: InputDecoration(
                      filled: true,
                      // fillColor: Colors.white,
                      fillColor: Colors.white,
                      hintText: "Date",
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  // readOnly: true,
                  onTap: () => selectDate(_date),
                ),
            
            
                SizedBox(height: 10),
                TextFormField(
                  controller: _time,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Deb",
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  // readOnly: true,
                  onTap: () => selectTime(_time),
                ),
            
            
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 1.8,
                      child: DropdownButtonFormField<filliere>(
                        value: selectedFil,
                        items: filList.map((fil) {
                          return DropdownMenuItem<filliere>(
                            value: fil,
                            child: Text(fil.name ),
                          );
                        }).toList(),
                        onChanged: (value) async{
                          setState(() {
                            selectedFil = value;
                            selectedSem = null; // Reset the selected matière
                            selectedGroup = null; // Reset the selected matière
                            selectedElem = null; // Reset the selected matière
                            SemList1 = filterItemsByFil(selectedFil, SemList!);

                            print("Sems1${SemList1}");

                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Color(0xA3B0AF1),
                          fillColor: Colors.white,
                          hintText: "selection d'un flliere",

                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: MediaQuery.of(context).size.width / 3.6,
                      child: DropdownButtonFormField<Semestre>(
                        value: selectedSem,
                        items: SemList1.map((sem) {
                          return DropdownMenuItem<Semestre>(
                            value: sem,
                            child: Text("S${sem.numero}" ),
                          );
                        }).toList(),
                        onChanged: (value) async{
                          setState(() {
                            selectedSem = value;
                            selectedGroup = null;
                            selectedElem = null;
                            // updateElemList(selectedFil!.id, selectedSem!.numero!); // Mettre à jour la liste des éléments en fonction du semestre du groupe sélectionné
                            elList1 = filterElsbySem(selectedFil!.id!,selectedSem!.numero!, elList!);
                            grpList1 = filterItemsBySem(selectedSem, grpList!);

                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Color(0xA3B0AF1),
                          fillColor: Colors.white,
                          hintText: "...",

                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<Group>(
                  value: selectedGroup,
                  items: grpList1.map((grp) {
                    return DropdownMenuItem<Group>(
                      value: grp,
                      child: Text('${getFilIdFromName(grp.filliereId!).toUpperCase()}${grp.numero}-${grp.type}' ),
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedGroup = value;
                      // selectedElem = null;

                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'une Group",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),

                SizedBox(height: 10),
                DropdownButtonFormField<Elem>(
                  value: selectedElem,
                  items: elList1.map((ele) {
                    return DropdownMenuItem<Elem>(
                        value: ele,
                        child: Text('${getEls(ele.id).nameMat}' )
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedElem = value;
                      selectedProfesseur = null; // Reset the selected matière
                      updateProfesseurList();

                      // print("PL${professeurs}");
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'un Element",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),


                SizedBox(height: 10),
                // DropdownButtonFormField<Elem>(
                //   value: selectedElem,
                //   // hint: Text('${widget.EP}'),
                //   items: elList.map((ele) {
                //     return DropdownMenuItem<Elem>(
                //       value: ele,
                //       child: _selectedType == "CM" ? Text('${getEls(ele.id).ProfCM}' )
                //           :(_selectedType == "TP" ? Text('${getEls(ele.id).ProfTP}' ):Text('${getEls(ele.id).ProfTD}' )),
                //     );
                //   }).toList(),
                //   onChanged: (value) async{
                //     setState(() {
                //       selectedElem = value;
                //       // selectedMat = null; // Reset the selected matière
                //
                //     });
                //   },
                //   decoration: InputDecoration(
                //     filled: true,
                //     fillColor: Colors.white,
                //     hintText: "selection d'un Prof",
                //
                //     border: OutlineInputBorder(
                //       borderSide: BorderSide.none,gapPadding: 1,
                //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //     ),
                //   ),
                // ),
            
                SizedBox(height:20),
                ElevatedButton(
                  onPressed: (){
            
                    DateTime date = DateFormat('yyyy/MM/dd').parse(_date.text).toUtc();
            
                    // String email =  getProfEmailFromName(selectedElem!.ProCMId);
                        // _selectedType == "TP" ? getProfEmailFromName(selectedElem!.ProTPId):getProfEmailFromName(selectedElem!.ProTDId));
                    // print("MatId${selectedElem!.MatId}");
                    // String Prof = _selectedType == "CM" ? selectedElem!.ProCMId:( _selectedType == "TP" ? selectedElem!.ProTPId: selectedElem!.ProTDId);
                    // print("ProfId${Prof}");
                    addCours(_selectedType,_selectedNbh,date,_time.text,selectedElem!.id,selectedGroup!.id);
                    // Addemploi(_name.text, _desc.text);
            
                    // addCours(_selectedType,_selectedNbh,date,_time.text,selectedProfesseur!.id,selectedMat!.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Le Cours a été ajouter avec succès.')),
                    );
            
                    setState(() {
                      Navigator.of(context).pop();
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
        )
    );

  }

  Future<void> addCours(String type, num nbh,DateTime date,String time, String ElemId,String GrpId,) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    final Uri uri = Uri.parse('http://192.168.43.73:5000/cours');


    final Map<String, dynamic> emploiData = {
      "type": type,
      "nbh": nbh,
      "date": date!.toIso8601String(),
      "startTime": time,
      // "dayNumero": days,
      "element": ElemId,
      "group": GrpId
    };

    // try {
      final response = await http.post(
        uri,
        body: jsonEncode(emploiData),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);
      if (response.statusCode == 200) {


        print('Cour ajouter avec succes');
        // await sendEmailNotification(profEmail, type, date, time); // Send email
        setState(() {
          Navigator.pop(context);
        });


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'ajout de l\'emploi.')),
        );
      }

    // }
    // catch (error) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Erreur: $error')),
    //   );
    // }
  }

  Future<void> sendEmailNotification(
      String recipientEmail,
      String coursType,
      DateTime coursDate,
      String coursTime,
      ) async {
    try {
      String username = 'i17201.etu@iscae.mr';
      String password = '26986690';

      final smtpServer = gmail(username, password);
      final message = Message()
        ..from = Address(username, 'Emploi du Temps')
        ..recipients.add(recipientEmail)
        ..subject = 'Nouveau cours créé : $coursType'
        ..text = 'Bonjour,\n\nUn nouveau cours de type $coursType a été créé pour vous.\n'
            'Date: ${DateFormat('EEEE, d MMMM yyyy').format(coursDate)}\n'
            'Heure: $coursTime\n\nCordialement,\nEmploi du Temps';

      await send(message, smtpServer);
      print('Email notification sent successfully');
    } catch (error) {
      print('Error sending email: $error');
      // Handle email sending errors gracefully, e.g., display a user-friendly message
    }
  }
}

class Filtrer extends StatefulWidget {
  late DateTime dateDeb;
  late DateTime dateFin;
  late  bool showSigned ;
  late bool showPaid ;

  Filtrer({required this.showPaid, required this.showSigned, required this.dateDeb,required this.dateFin,}){}
  
  @override
  _FiltrerState createState() => _FiltrerState();
}

class _FiltrerState extends State<Filtrer> {
  
  // Déclarez vos variables ici
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
                surfaceTintColor: Color(0xB0AFAFA3),
        insetPadding: EdgeInsets.only(top: 80,),
// backgroundColor: Color(0xB0AFAFA3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Ajouter une Filtre", style: TextStyle(fontSize: 25),),
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
          width: MediaQuery.of(context).size.width,
          // height: 600,
          // color: Color(0xA3B0AF1),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
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
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xff0fb2ea)
                        ,foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),

                  ),
                  // Container(width: 50,
                  //   child:Text('total: ${totalType.toStringAsFixed(2)}'),
                  // ),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xff0fb2ea),foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ],
                  ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Type', style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15 ),),
                ],
              ),
              Row(

                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(onPressed: (){
                    setState(() {
                      widget.showSigned = !widget.showSigned;
                      Navigator.of(context).pop();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Le filtre est appliquer avec succès.')),
                    );

                  }
                    , child: Row(
                      children: [
                        Icon(Icons.check_circle_outline),
                        Text("Signé"),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Color(0xff0fb2ea),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.black38),
                      elevation: 10,
                      padding: EdgeInsets.only(left: 40, right: 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(onPressed: (){
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Le filtre est appliquer avec succès.')),
                    );
                    setState(() {
                      widget.showPaid = !widget.showPaid;
                    });
                  }
                    , child: Row(
                      children: [
                        Icon(Icons.check_circle_outline),
                        Text("Paié"),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.black38),
                      elevation: 10,
                      padding: EdgeInsets.only(left: 40, right: 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                ],
              ),
            ],
          ),
        )
    );

  }

  Future<void> addCours(String type, num nbh,DateTime date,String time, String ElemId,String GrpId,String profEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    final Uri uri = Uri.parse('http://192.168.43.73:5000/cours');


    final Map<String, dynamic> emploiData = {
      "type": type,
      "nbh": nbh,
      "date": date!.toIso8601String(),
      "startTime": time,
      // "dayNumero": days,
      "element": ElemId,
      "group": GrpId
    };

    // try {
      final response = await http.post(
        uri,
        body: jsonEncode(emploiData),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.statusCode);
      if (response.statusCode == 200) {


        print('Cour ajouter avec succes');
        await sendEmailNotification(profEmail, type, date, time); // Send email
        setState(() {
          Navigator.pop(context);
        });


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'ajout de l\'emploi.')),
        );
      }

    // }
    // catch (error) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Erreur: $error')),
    //   );
    // }
  }

  Future<void> sendEmailNotification(
      String recipientEmail,
      String coursType,
      DateTime coursDate,
      String coursTime,
      ) async {
    try {
      String username = 'i17201.etu@iscae.mr';
      String password = '26986690';

      final smtpServer = gmail(username, password);
      final message = Message()
        ..from = Address(username, 'Emploi du Temps')
        ..recipients.add(recipientEmail)
        ..subject = 'Nouveau cours créé : $coursType'
        ..text = 'Bonjour,\n\nUn nouveau cours de type $coursType a été créé pour vous.\n'
            'Date: ${DateFormat('EEEE, d MMMM yyyy').format(coursDate)}\n'
            'Heure: $coursTime\n\nCordialement,\nEmploi du Temps';

      await send(message, smtpServer);
      print('Email notification sent successfully');
    } catch (error) {
      print('Error sending email: $error');
      // Handle email sending errors gracefully, e.g., display a user-friendly message
    }
  }
}


class UpdateCoursScreen extends StatefulWidget {
  final String empId;
  // final int day;
  final String start;
  final String date;
  final String GN;
  // final String GId;
  final String EM;
  final String MId;
  final String EP;
  final String PId;
  // final String EId;
  final String TN;
  final num TH;

  UpdateCoursScreen({Key? key, required this.empId,  required this.start,  required this.EM, required this.EP, required this.TN, required this.TH, required this.GN, required this.MId, required this.PId, required this.date}) : super(key: key);
  @override
  State<UpdateCoursScreen> createState() => _UpdateCoursScreenState();

}

class _UpdateCoursScreenState extends State<UpdateCoursScreen> {

  TextEditingController _date = TextEditingController();

  TextEditingController _time = TextEditingController();

  Future<void> selectDate(TextEditingController controller) async {
    DateTime? selectedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (selectedDateTime != null) {
      String formattedDateTime = DateFormat('yyyy/MM/dd').format(selectedDateTime);
      setState(() {
        controller.text = formattedDateTime;
      });
    }
  }

  int _selectedNum = 1;
  String signe = "pas encore";
  String selectedTypeName = 'CM'; // Nom de type sélectionné par défaut
  num selectedNbhValue = 1.5;
  List<String> typeNames = ['CM', 'TP', 'TD']; // Liste des noms uniques de types
  List<double> nbhValues = [1.5, 2];

  bool showType = false;
  bool showNum = false;
  bool showTime = false;
  bool showDate = false;
  bool showgroup = false;
  bool showElem = false;

  Elem? selectedElem;
  Group? selectedGroup;
  String? selectedMat;
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];
  List<Matiere> matieres = [];
  DateTime? selectedDateTime;

  bool isChanged =false;



  List<Professeur> professeurList = [];
  List<Group> grpList = [];
  List<Elem> elList = [];
  List<Matiere> matiereList = [];
  List<filliere> filList = [];
  String getFilIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final fil = filList.firstWhere((f) => '${f.id}' == id, orElse: () =>filliere(id: '', name: '', description: '', niveau: ''));
    // print(id);
    return fil.name; // Return the ID if found, otherwise an empty string

  }
  Future<void> selectTime(TextEditingController controller) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      String formattedTime = selectedTime.format(context); // Utilise la méthode format avec le context


      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  Elem getEls(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final element = elList.firstWhere((g) => '${g.id}' == id, orElse: () => Elem(id: '', filId: '', MatId: '', ));
    print( "Els:${element}");
    return element!; // Return the ID if found, otherwise an empty string

  }
  Future<void> updateElementList(String semestreId) async {
    // try {
    // Utilisez l'ID du semestre pour récupérer les éléments correspondants
    List<Elem> elements = await fetchElementsBySemestre(semestreId);

    setState(() {
      elList = elements;
      selectedElem = null; // Réinitialiser la sélection de l'élément
    });
    // } catch (error) {
    //   print('Erreur lors de la récupération des éléments: $error');
    // }
  }


  @override
  void initState() {
    super.initState();
    fetchGroup().then((data) {
      setState(() {
        grpList = data; // Assigner la liste renvoyée par emploiesseur à items
      });

      fetchMatiere().then((data) {
        setState(() {
          matiereList = data; // Assigner la liste renvoyée par emploiesseur à items
        });
      }).catchError((error) {
        print('Erreur: $error');
      });

    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchProfs().then((data) {
      setState(() {
        professeurList = data; // Assigner la liste renvoyée par emploiesseur à items
        print('Hello');
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    fetchfilliere().then((data) {
      setState(() {
        filList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

    _date.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.date.toString()));
    selectedNbhValue = widget.TH;
    selectedTypeName = widget.TN;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
                surfaceTintColor: Color(0xB0AFAFA3),
        insetPadding: EdgeInsets.only(top: 60,),
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Modifier un Cours", style: TextStyle(fontSize: 25),),
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
          width: MediaQuery.of(context).size.width,
          // height: 600,
          // color: Color(0xA3B0AF1),
          child: SingleChildScrollView(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                //hmmm
                SizedBox(height: 10),
                // _buildTypesInput(),
                Row(
                  children: [
                    Container(
                      width: 147.5,
                      child: DropdownButtonFormField<String>(
                        value: selectedTypeName,
                        items: typeNames.map((typeName) {
                          return DropdownMenuItem<String>(
                            child: Text(typeName),
                            value: typeName,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTypeName = value ?? 'CM';
                            showType = true;
                            showElem = true;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "selection d'une Group",

                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),

                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 147.5,
                      child: DropdownButtonFormField<num>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        value: selectedNbhValue,
                        items: nbhValues.map((nbhValue) {
                          return DropdownMenuItem<num>(
                            child: Text(nbhValue.toString()),
                            value: nbhValue,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedNbhValue = value ?? 1.5;
                            showNum = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _date,
                  onChanged: (value) {
                    setState(() {
                      showDate = true;
                    });
                  },

                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: widget.date,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  // readOnly: true,
                  onTap: () => selectDate(_date),
                ),


                SizedBox(height: 10),
                TextFormField(
                  controller: _time,
                  onChanged: (value) {
                    setState(() {
                      showTime = true;
                    });
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: widget.start!,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  // readOnly: true,
                  onTap: () => selectTime(_time),
                ),



                SizedBox(height: 10),
                DropdownButtonFormField<Group>(
                  value: selectedGroup,
                  hint: Text(widget.GN),
                  items: grpList.map((grp) {
                    return DropdownMenuItem<Group>(
                      value: grp,
                      child: Text('${getFilIdFromName(grp.filliereId!).toUpperCase()}${grp.semestre!.numero}-${grp.type}' ),
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedGroup = value;
                      selectedElem = null; // Reset the selected matière
                      updateElementList(selectedGroup!.semestre!.id); // Mettre à jour la liste des éléments en fonction du semestre du groupe sélectionné
                      showgroup = true;

                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'une Group",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),

                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedMat,
                  hint: showElem ? Text(''):Text('${widget.EM}'),
                  items: elList.map((ele) {
                    return DropdownMenuItem<String>(
                      value: ele.id,
                      child: Text('${getEls(ele.id).nameMat}' )
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedMat = value;
                      // selectedMat = null; // Reset the selected matière
                      showElem = true;

                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'un Element",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),

                SizedBox(height: 10),
                // DropdownButtonFormField<Elem>(
                //   value: selectedElem,
                //   hint: Text('${widget.EP}'),
                //   items: elList.map((ele) {
                //     return DropdownMenuItem<Elem>(
                //       value: ele,
                //       child: selectedTypeName == "CM" ? Text('${getEls(ele.id).ProfCM}' )
                //           :(selectedTypeName == "TP" ? Text('${getEls(ele.id).ProfTP}' ):Text('${getEls(ele.id).ProfTD}' )),
                //     );
                //   }).toList(),
                //   onChanged: (value) async{
                //     setState(() {
                //       selectedElem = value;
                //       // selectedMat = null; // Reset the selected matière
                //       showElem = true;
                //
                //     });
                //   },
                //   decoration: InputDecoration(
                //     filled: true,
                //     fillColor: Colors.white,
                //     hintText: "selection d'un Element",
                //
                //     border: OutlineInputBorder(
                //       borderSide: BorderSide.none,gapPadding: 1,
                //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //     ),
                //   ),
                // ),

                SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: signe,
                  items: [
                    DropdownMenuItem<String>(
                      child: Text('True'),
                      value: "oui",
                    ),
                    DropdownMenuItem<String>(
                      child: Text('False'),
                      value: "pas encore",
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      signe = value!;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Est Signe",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),

                ),

                SizedBox(height:20),
                ElevatedButton(
                  onPressed: () {
                    // Navigator.of(context).pop();

                    // DateTime date = showDate ? DateFormat('yyyy/MM/dd').parse(_date.text).toUtc():DateFormat('yyyy/MM/dd').parse(widget.date).toUtc();
                    DateTime date =DateFormat('yyyy/MM/dd').parse(_date.text).toUtc();
                    String time = showTime ? _time.text:widget.start;

                    print("MatId${showElem? selectedElem!.MatId: widget.MId}");
                    // String Prof = showElem?(selectedTypeName == "CM" ? selectedElem!.ProCMId:( selectedTypeName == "TP" ? selectedElem!.ProTPId: selectedElem!.ProTDId))
                    // :widget.PId;
                    // print("ProfId${Prof}");

                    String type = showType ? selectedTypeName : widget.TN;
                    num nbh = showNum ? selectedNbhValue : widget.TH;
                    String mat = showElem ? selectedElem!.MatId : widget.MId;
                    UpdatCours(
                        widget.empId,
                        type,
                        nbh,date,
                        time
                        ,selectedElem!.id,selectedGroup!.id,
                      signe
                    );

                    setState(() {
                      Navigator.pop(context);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Le Type est mis à jour avec succès.')),
                    );
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

        )
    );

  }


  Future<void> UpdatCours (id,String TN,num TH,DateTime date,String time, String ElemId,String GrpId,String isSigned) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    final url = 'http://192.168.43.73:5000/cours/'  + '/$id';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final Map<String, dynamic> body = {
      "type": TN,
      "nbh": TH,
      'date': date.toIso8601String(),
      "startTime": time,
      "element": ElemId,
      "group": GrpId,
      "isSigned": isSigned,
    };

    if (date != null) {
      body['date'] = date.toIso8601String();
    }

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      print('Status:${response.statusCode}');
      if (response.statusCode == 201) {
        // Course creation was successful
        print("Emploi Updated successfully!");
        final responseData = json.decode(response.body);
        // print("Course ID: ${responseData['cours']['_id']}");
        // You can handle the response data as needed
        setState(() {
          Navigator.pop(context);
        });


      } else {
        // Course creation failed
        print("Failed to update. Status code: ${response.statusCode}");
        print("Error Message: ${response.body}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

}

Future<List<Matiere>> fetchMatieresByCategory(String categoryId) async {
  String apiUrl = 'http://192.168.43.73:5000/categorie/$categoryId/matieres';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> matieresData = responseData['matieres'];
      print(categoryId);
      print(matieresData);
      List<Matiere> matieres = matieresData.map((data) => Matiere.fromJson(data)).toList();
      print(matieres);
      return matieres;
    } else {
      throw Exception('Failed to fetch matières by category');
    }
  } catch (error) {
    throw Exception('Error: $error');
  }
}

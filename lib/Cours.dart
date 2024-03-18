import 'dart:convert';
import 'package:gestion_payements/professeures.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'auth/emploi.dart';
import 'element.dart';
import 'filliere.dart';
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
          .map((course) => double.parse(course['th'].toString()))
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
          .map((course) => double.parse(course['th'].toString()))
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
  int coursesPerPage = 7;
  String searchQuery = '';
  bool sortByDateAscending = true;
  bool showSigned = false;
  bool showPaid = false;
  bool courseFitsCriteria(Map<String, dynamic> course) {
    // Apply your filtering criteria here
    DateTime courseDate = DateTime.parse(course['date'].toString());
    bool isMatch = (
        course['matiere'].toLowerCase().contains(searchQuery.toLowerCase()) || course['enseignant'].toLowerCase().contains(searchQuery.toLowerCase())
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
                   TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: Icon(Icons.arrow_back_ios,color: Colors.black,size: 20,)),
                // SizedBox(width: 40,),
                Text("Liste des Cours",style: TextStyle(fontSize: 20),),

                SizedBox(width: 100,),
                Container(
                  width: 50,
                  height: 50,
                // color: Colors.black26,
                child: IconButton(icon:Icon(Icons.cached, size: 30,color: Colors.black), onPressed: () => auto(),),
                )

              ],
            ),
          ),
          Divider(),
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

                Icon(Icons.panorama_fish_eye,),
                Text('en attente'),
                SizedBox(width: 8,),
                Icon(Icons.remove_circle_outline,),
                Text('En Cours'),
                SizedBox(width: 8,),
                Icon(Icons.task_alt,),
                Text('Effectué')
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
                                    if ((!showSigned || widget.courses[index]['isSigned'] == "effectué") &&
                                        (!showPaid || widget.courses[index]['isPaid'] == "effectué" || widget.courses[index]['isPaid'] == 'préparé'))
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
                                                child: Icon( widget.courses[index]['isSigned'] =="effectué"?  Icons.task_alt:Icons.panorama_fish_eye,
                                                  color: widget.courses[index]['isSigned'] =="effectué" ? Colors.green: Colors.black54,

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
                                                  child: Icon( widget.courses[index]['isPaid'] =="effectué" ?
                                                  Icons.task_alt:widget.courses[index]['isPaid'] =="préparé"  ?
                                                  Icons.remove_circle_outline:
                                                  Icons.panorama_fish_eye,
                                                    color: widget.courses[index]['isPaid'] =="effectué" ? Colors.green:widget.courses[index]['isPaid'] =="préparé"  ? Colors.lightBlue: Colors.black54,
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
                                          DataCell(Container(width: 50,child: Text('${widget.courses[index]['enseignant'].toString().capitalize}',style: TextStyle(
                                            color: Colors.black,
                                          ),)),
                                              onTap: () => _showCourseDetails(context, widget.courses[index])
                                          ),
                                          DataCell(Container(width: 55,child: Text('${widget.courses[index]['matiere'].toString().capitalize}',style: TextStyle(
                                            color: Colors.black,
                                          ),)),
                                            onTap: () => _showCourseDetails(context, widget.courses[index])
                                          ),
                                          DataCell(
                                            Center(child: Container(width: 20, child: Text('${widget.courses[index]['th']}',style: TextStyle(
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
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (currentPage > 1) {
                        currentPage--;
                      }
                    });
                  },
                  child: Icon(Icons.skip_previous_rounded),
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Colors.white,
                  //   foregroundColor: Colors.black,
                  // ),
                ),
                Container(
                  width: 115,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          // Text('(${coursesPerPage} Cours par page)'),
                          Container(
                            width: 70,
                            child: DropdownButtonFormField<int>(
                              value: coursesPerPage,
                              hint: Text(coursesPerPage.toString()),
                              items: [
                                DropdownMenuItem<int>(
                                  child: Text('5'),
                                  value: 5,
                                ),
                                DropdownMenuItem<int>(
                                  child: Text('7'),
                                  value: 7,
                                ),
                                DropdownMenuItem<int>(
                                  child: Text('10'),
                                  value: 10,
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  coursesPerPage = value!;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Sélecte Semestre",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  gapPadding: 1,
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(currentPage.toString(),style: TextStyle(fontSize: 18),),
                          SizedBox(width: 5,),
                          Text('/',style: TextStyle(fontSize: 18)),
                          SizedBox(width: 5,),
                          Text((widget.courses.length / coursesPerPage).ceil().toString(),style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () {
                    int totalPage = (widget.courses.length / coursesPerPage).ceil();
                    setState(() {
                      if (currentPage < totalPage) {
                        currentPage++;
                      }
                    });
                  },
                  child: Icon(Icons.skip_next),
                  // style: ElevatedButton.styleFrom(
                  //   backgroundColor: Colors.white,
                  //   foregroundColor: Colors.black,
                  // ),
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
                Row(
                  children: [
                    Text('Cours Infos',style: TextStyle(fontSize: 25),),
                    Spacer(),
                    InkWell(
                      child: Icon(Icons.close),
                      onTap: (){
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
                SizedBox(height: 30),
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
                    Text(course['enseignant'].toString().capitalize!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),
                  ],
                ),
                SizedBox(height: 25),
                Container(
                  width: MediaQuery.of(context).size.width,
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
                        Text('${course['matiere'].toString().capitalize}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),

                      ],
                    ),
                  ),
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
                    Text('${course['th']} heures',
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
                      course['isSigned'] == "effectué"?
                      'Oui':'En attente',
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
                            course['isPaid'] =="effectué"?
                            'Effectué':course['isPaid'] =="préparé"?'Préparé' :'En attente',
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
                    TextButton(
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
                            MaterialPageRoute(builder: (context) => UpdateCoursScreen(empId: course['_id'], start: course['startTime'], date: DateFormat('dd/MM/yyyy ').format(
                              DateTime.parse(course['date'].toString()).toLocal(),),Prof: course['enseignant'],
                              EM:course['matiere'], EP:course['enseignant'], TN: course['type'], th: course['nbh'], GN: '', MId: course['element'], PId: course['professeur'],)),
                          );
                        });
                      },// Disable button functionality

                      child: Text('Modifier'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(left: 20,right: 20),
                        foregroundColor: Colors.lightGreen,
                          backgroundColor: Color(0xfffff1),
                          side: BorderSide(color: Colors.black12,),
                          // side: BorderSide(color: Colors.black,),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                      ),

                    ),

                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                      surfaceTintColor: Color(0xB0AFAFA3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                              title: Text("Confirmer la suppression"),
                              content: Text(
                                  "Êtiez-vous sûr de vouloir supprimer cet élément ?"),
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
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(left: 20,right: 20),
                        foregroundColor: Colors.redAccent,
                          backgroundColor: Color(0xfffff1),
                          side: BorderSide(color: Colors.black12,),
                          // side: BorderSide(color: Colors.black,),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
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
    setState(() {
      Navigator.pop(context);
    });
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
                                Icon(Icons.task_alt),
                                Text("Payé"),
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
                            value: '',
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


  Future<void> auto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    final response = await http.get(
      Uri.parse('http://192.168.43.73:5000/cours/auto-create/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // print("Categ:${response.statusCode}");
    if (response.statusCode == 200) {
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
                    "Tous les cours en emploi aujourduis sont créés"),
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


    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Category');
    }
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
  TextEditingController _start = TextEditingController();
  int _selectedNum = 1;

  filliere? selectedFil;
  int? selectedSem;
  Elem? selectedElem;
  Matiere? selectedMat;
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];
  DateTime? selectedDateTime;

  // Future<void> updateProfesseurList() async {
  //   if (selectedElem != null) {
  //     List<Professeur> fetchedProfesseurs = await fetchProfesseursByMatiere(selectedElem!.MatId);
  //     setState(() {
  //       professeurs = fetchedProfesseurs;
  //       selectedElem = null;
  //     });
  //   } else {
  //     List<Professeur> fetchedProfesseurs = await fetchProfs();
  //     setState(() {
  //       professeurs = fetchedProfesseurs;
  //       selectedElem = null;
  //     });
  //   }
  // }
  Future<void> updateElemList() async {
    if (selectedProfesseur != null) {
      List<Elem>? fetchedProfesseurs = await fetchElsByProf(selectedProfesseur!.id);
      setState(() {
        elList = fetchedProfesseurs!;
        selectedElem = null;
      });
    } else {
      List<Elem> fetchedProfesseurs = await fetchElems();
      setState(() {
        elList = fetchedProfesseurs;
        selectedElem = null;
      });
    }
  }

  List<Professeur> professeurList = [];

  List<Elem> elList = [];
  List<Elem> elList2 = [];
  List<Elem> elList1 = [];
  List<Matiere> matiereList = [];
  List<filliere> filList = [];
  List<int> semestersList = [];


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


    fetchfilliere().then((data) {
      setState(() {
        filList = data; // Assigner la liste renvoyée par emploiesseur à items
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

  }

  Elem getElem(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final elem = elList.firstWhere((f) => '${f.id}' == id, orElse: () =>Elem(id: '', filId: '', MatId: '', ));
    print(elem.id);
    return elem; // Return the ID if found, otherwise an empty string

  }


  List<Elem> filterItemsBySemestre(int? ele, List<Elem> allItems) {
    if (ele == 0) {
      return allItems;
    } else {
      // print("ElID:${ele.id}");
      return allItems.where((elem) => elem.SemNum == ele).toList();
    }
  }

  List<int> extractUniqueSemesters(List<Elem> elems) {
    Set<int> uniqueSemesters = elems.map((elem) => elem.SemNum!).toSet();
    return uniqueSemesters.toList();
  }
  List<Elem> filterItemsByFil(filliere? fil, List<Elem> allItems) {
    if (fil == null) {
      return allItems;
    } else {
      return allItems.where((ele) => ele!.filId == fil.id).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        surfaceTintColor: Color(0xB0AFAFA3),
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.only(top: 60,),
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
            Text("Ajouter un Cours", style: TextStyle(fontSize: 25),),
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
          height: 700,
          // color: Color(0xA3B0AF1),
          child: SingleChildScrollView(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                // _buildTypesInput(),
                SizedBox(height: 30),
                TextFormField(
                  controller: _start,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Heure",
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  // readOnly: true,
                  onTap: () => selectTime(_start),
                ),

                SizedBox(height: 10),
                TextFormField(
                  controller: _date,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Date",
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  // readOnly: true,
                  onTap: () => selectDate(_date),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<Professeur>(
                  value: selectedProfesseur,
                  items: professeurList.map((prof) {
                    return DropdownMenuItem<Professeur>(
                      value: prof,
                      child: Text(prof.nom! ),
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedProfesseur = value;
                      selectedElem = null;
                      updateElemList();
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'une Professeur",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2.2,
                      child: DropdownButtonFormField<filliere>(
                        value: selectedFil,
                        items: filList.map((fil) {
                          return DropdownMenuItem<filliere>(
                            value: fil,
                            child: Text(fil.name.toUpperCase() ),
                          );
                        }).toList(),
                        onChanged: (value) async{
                          setState(() {
                            selectedFil = value;
                            selectedSem = null; // Reset the selected matière
                            // selectedGroup = null; // Reset the selected matière
                            selectedElem = null; // Reset the selected matière
                            elList2 = filterItemsByFil(selectedFil, elList!);
                            semestersList = extractUniqueSemesters(elList2);

                            print("Sems1${elList2}");

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
                      width: MediaQuery.of(context).size.width /2.7,
                      child: DropdownButtonFormField<int>(
                        value: selectedSem,
                        hint: Text('Semestre'),
                        items: semestersList.map((sem) {
                          return DropdownMenuItem<int>(
                            value: sem,
                            child: Text("S$sem"),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            selectedSem = value;
                            // filteredItems = filterItemsBySemestre(selectedSem, items!);
                            // semestersList = extractUniqueSemesters(elList1);
                            // elList1 = filterItemsByFil(selectedFil, elList!);
                            elList1 = filterItemsBySemestre(selectedSem, elList2!);
                            // print("EL1${elList1} et ${elList}");
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Sélecte Semestre",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<Elem>(
                  value: selectedElem,
                  items: elList1.map((ele) {
                    return DropdownMenuItem<Elem>(
                        value: ele,
                        child: Text(ele.nameM ?? '')
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedElem = value;
                      // selectedProfesseur = null; // Reset the selected matière
                      // updateProfesseurList();

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



                SizedBox(height:20),
                ElevatedButton(
                  onPressed: (){

                    DateTime date =DateFormat('yyyy/MM/dd').parse(_date.text).toUtc();
                    addCours(_selectedType,_selectedNbh,date,_start.text,selectedElem!.id,selectedProfesseur!.id);
                    // Addemploi(_name.text, _desc.text);





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

  Future<void> addCours(String type, num nbh,DateTime date,String time, String ElemId,String ProfId,) async {
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
      "professeur": ProfId
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

      print("Cours Code${response.statusCode}");
      if (response.statusCode == 201) {


        print('Cours ajouter avec succes');
        // await sendEmailNotification(profEmail, type, date, time); // Send email
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
                      "Le cours a été ajouté avec succès"),
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



      }
      else {

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
                  content: Text(jsonDecode(response.body)["message"]),
                  actions: [
                    TextButton(
                      child: Text("Réessayez?"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),

                  ],
                );});

        });

      }

    // }
    // catch (error) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Erreur: $error')),
    //   );
    // }
  }
  Future<List<Elem>?> fetchElsByProf(String ProfId,) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);




    final response = await http.get(
      Uri.parse('http://192.168.43.73:5000/professeur/$ProfId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // try {

      print(response.statusCode);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> empData = jsonResponse['elements'];

        print(empData);
        List<Elem> els = empData.map((item) {
          return Elem.fromJson(item);
        }).toList();

        print(els);

        // await sendEmailNotification(profEmail, type, date, time); // Send email
        // setState(() {
        //   Navigator.pop(context);
        // });

        return els;

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
            Text("Ajouter un Filtre", style: TextStyle(fontSize: 25),),
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
                        Icon(Icons.task_alt),
                        Text("Payé"),
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


  Future<void> sendEmailNotification(
      String recipientEmail,
      String coursType,
      DateTime coursDate,
      String coursTime,
      ) async {
    try {
      String username = 'i17201.etu@iscae.mr';
      String password = '111';

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
  final String Prof;
  final String EM;
  final String MId;
  final String EP;
  final String PId;
  // final String Fil;
  final String TN;
  final num th;
  // final num SemN;

  UpdateCoursScreen({Key? key, required this.empId,  required this.start,  required this.EM, required this.EP, required this.TN, required this.th,
    required this.GN, required this.MId, required this.PId, required this.date, required this.Prof, }) : super(key: key);
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
  String signe = "en attente";
  String selectedTypeName = 'CM'; // Nom de type sélectionné par défaut
  num selectedNbhValue = 1.5;
  List<String> typeNames = ['CM', 'TP', 'TD']; // Liste des noms uniques de types
  List<double> nbhValues = [1.5, 2];

  bool showType = false;
  bool showNum = false;
  bool showTime = false;
  bool showDate = false;
  bool showProf = false;
  bool showElem = false;

  Elem? selectedElem;
  String? selectedMat;
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];
  List<Matiere> matieres = [];
  DateTime? selectedDateTime;

  List<Elem> elList = [];
  List<Elem> elList2 = [];
  List<Elem> elList1 = [];
  bool isChanged =false;



  List<Professeur> professeurList = [];
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



  Future<void> updateElemList() async {
    if (selectedProfesseur != null) {
      List<Elem>? fetchedProfesseurs = await fetchElsByProf(selectedProfesseur!.id);
      setState(() {
        elList = fetchedProfesseurs!;
        selectedElem = null;
      });
    } else {
      List<Elem> fetchedProfesseurs = await fetchElems();
      setState(() {
        elList = fetchedProfesseurs;
        selectedElem = null;
      });
    }
  }


  List<Elem> filterItemsBySemestre(int? ele, List<Elem> allItems) {
    if (ele == 0) {
      return allItems;
    } else {
      // print("ElID:${ele.id}");
      return allItems.where((elem) => elem.SemNum == ele).toList();
    }
  }

  List<int> extractUniqueSemesters(List<Elem> elems) {
    // List<Elem> Els = filterItemsByFil(fil,elems);
    Set<int> uniqueSemesters = elems.map((elem) => elem.SemNum!).toSet();
    return uniqueSemesters.toList();
  }
  List<Elem> filterItemsByFil(filliere? fil, List<Elem> allItems) {
    if (fil == null) {
      return allItems;
    } else {
      return allItems.where((ele) => ele!.filId == fil.id).toList();
    }
  }

  Elem getEls(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final element = elList.firstWhere((g) => '${g.id}' == id, orElse: () => Elem(id: '', filId: '', MatId: '', ));
    print( "Els:${element}");
    return element!; // Return the ID if found, otherwise an empty string

  }

  filliere? selectedFil;
  int? selectedSem;
  List<int> semestersList = [];

  @override
  void initState() {
    super.initState();

    fetchProfs().then((data) {
      setState(() {
        professeurList = data; // Assigner la liste renvoyée par emploiesseur à items
        print('Hello');
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
    fetchElems().then((data) {
      setState(() {
        elList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
    _date.text = widget.date.toString();
    selectedNbhValue = widget.th;
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
            Text("Modifier un cours", style: TextStyle(fontSize: 25),),
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
                SizedBox(height: 30),
                DropdownButtonFormField<Professeur>(
                  value: selectedProfesseur,
                  hint: Text('${widget.Prof}'),
                  items: professeurList.map((prof) {
                    return DropdownMenuItem<Professeur>(
                      value: prof,
                      child: Text(prof.nom! ),
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedProfesseur = value;
                      selectedElem = null;
                      updateElemList();
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'une Professeur",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2.2,
                      child: DropdownButtonFormField<filliere>(
                        value: selectedFil,
                        // hint: Text('${widget.Fil}'),
                        items: filList.map((fil) {
                          return DropdownMenuItem<filliere>(
                            value: fil,
                            child: Text(fil.name.toUpperCase() ),
                          );
                        }).toList(),
                        onChanged: (value) async{
                          setState(() {
                            selectedFil = value;
                            selectedSem = null; // Reset the selected matière
                            // selectedGroup = null; // Reset the selected matière
                            selectedElem = null; // Reset the selected matière
                            elList2 = filterItemsByFil(selectedFil, elList!);
                            semestersList = extractUniqueSemesters(elList2);

                            print("Sems1${elList2}");

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
                      width: MediaQuery.of(context).size.width /2.7,
                      child: DropdownButtonFormField<int>(
                        value: selectedSem,
                        // hint: Text('${widget.SemN}'),
                        items: semestersList.map((sem) {
                          return DropdownMenuItem<int>(
                            value: sem,
                            child: Text("S$sem"),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            selectedSem = value;
                            // filteredItems = filterItemsBySemestre(selectedSem, items!);
                            // semestersList = extractUniqueSemesters(elList1);
                            // elList1 = filterItemsByFil(selectedFil, elList!);
                            elList1 = filterItemsBySemestre(selectedSem, elList2!);
                            // print("EL1${elList1} et ${elList}");
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Sélecte Semestre",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            gapPadding: 1,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<Elem>(
                  value: selectedElem,
                  hint: Text('${widget.EM}'),
                  items: elList1.map((ele) {
                    return DropdownMenuItem<Elem>(
                        value: ele,
                        child: Text(ele.nameM ?? '')
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedElem = value;
                      // selectedProfesseur = null; // Reset the selected matière
                      // updateProfesseurList();

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
                      _date.text = value;
                      showDate = true;
                    });
                  },

                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Entrer la Date',
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,gapPadding: 1,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                  // readOnly: true,
                  onTap: () {
                    setState(() {
                      selectDate(_date);
                      showDate = true;

                    });
                  },
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
                  onTap: ()  {
                    setState(() {
                      selectTime(_time);
                      showTime = true;
                    });
                  },
                ),



                SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: signe,
                  items: [
                    DropdownMenuItem<String>(
                      child: Text('True'),
                      value: "effectué",
                    ),
                    DropdownMenuItem<String>(
                      child: Text('False'),
                      value: "en attente",
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
                    Navigator.of(context).pop();

                    // DateTime date = showDate ? DateFormat('yyyy/MM/dd').parse(_date.text).toUtc():DateFormat('yyyy/MM/dd').parse(widget.date).toUtc();
                    DateTime date =
                    showDate ?
                    DateFormat('yyyy/MM/dd').parse(_date.text).toUtc()
                    :DateFormat('dd/MM/yyyy').parse(widget.date).toUtc();
                    // _date.text = DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.date.toString()));
                    String time = showTime ? _time.text:widget.start;

                    print("MatId${showElem? selectedElem!.MatId: widget.MId}");
                    // String Prof = showElem?(selectedTypeName == "CM" ? selectedElem!.ProCMId:( selectedTypeName == "TP" ? selectedElem!.ProTPId: selectedElem!.ProTDId))
                    // :widget.PId;
                    // print("ProfId${Prof}");

                    String type = showType ? selectedTypeName : widget.TN;
                    num nbh = showNum ? selectedNbhValue : widget.th;
                    String elem = showElem ? selectedElem!.id : widget.MId;
                    String prof = showProf ? selectedProfesseur!.id : widget.PId;
                    UpdatCours(
                        widget.empId,
                        type,
                        nbh,date,
                        time
                        ,elem,prof,
                      signe
                    );

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
                                  "Le cours a été modifier avec succès"),
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


  Future<void> UpdatCours (id,String TN,num th,DateTime date,String time, String ElemId,String ProfId,String isSigned) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    final url = 'http://192.168.43.73:5000/cours/'  + '/$id';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final Map<String, dynamic> body = {
      "type": TN,
      "nbh": th,
      'date': date.toIso8601String(),
      "startTime": time,
      "element": ElemId,
      "professeur": ProfId,
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

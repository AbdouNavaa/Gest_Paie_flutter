import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:gestion_payements/professeures.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gestion_payements/prof_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Dashboard.dart';
import 'categories.dart';
import 'main.dart';
import 'matieres.dart';
// import 'package:multi_select_flutter/multi_select_flutter.dart';


class ProfCoursesNonSigne extends StatefulWidget {
  final List<dynamic> courses;

  final String ProfId;
  // final int coursNum;
  // final num heuresTV;
  // final num sommeTV;
  DateTime? dateDeb;
  DateTime? dateFin;
// Calculate the sums for filtered courses

  ProfCoursesNonSigne({required this.courses, required this.ProfId}) {}



  @override
  State<ProfCoursesNonSigne> createState() => _ProfCoursesNonSigneState();
}

class _ProfCoursesNonSigneState extends State<ProfCoursesNonSigne> {
  bool isCourseSigned = false; // État pour suivre si le cours est signé ou non
  double totalType = 0;
  double somme = 0;
  int coursesNum = 0;
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


  void singeCours( id,bool isSigned) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.patch(
      Uri.parse("http://192.168.43.73:5000/cours" + "/$id/signe"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'isSigned':isSigned? "oui": "pas encore"
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      // Fetch the updated list of Matieres and update the UI
    } else {
      return Future.error('Server Error');
    }
  }


  String getMatiereIdFromName(String matiereName) {
    final matiere = matieresList.firstWhere((matiere) => matiere.name == matiereName);
    if (matiere != null) {
      return matiere.id;
    }
    return "";
  }
  List<Matiere> matieresList = [];
  Future<void> fetchMats() async {
    List<Matiere> matieres = await fetchMatiere();
    setState(() {
      matieresList = matieres;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchMats();
    widget.courses;
  }

  TextEditingController _date = TextEditingController();

  int currentPage = 1;
  int coursesPerPage = 5;
  String searchQuery = '';
  bool sortByDateAscending = true;
  bool isSignedd = false;

  bool courseFitsCriteria(Map<String, dynamic> course) {
    // Apply your filtering criteria here
    DateTime courseDate = DateTime.parse(course['date'].toString());
    bool isMatch = (
        course['matiere'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            course['professeur'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            course['isSigned'].toString().contains(searchQuery.toLowerCase()));

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



  @override
  Widget build(BuildContext context) {
    calculateTotalType();
    int totalPages = (widget.courses.length / coursesPerPage).ceil();
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
                Text("Cours Non Signé",style: TextStyle(fontSize: 25),)
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: TextField(style: TextStyle(color: Colors.black),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Rechercher ',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),



          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: 10),
            child: Row(
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
                Container(width: 50,
                  child:Center(child: Text('total: ${totalType.toStringAsFixed(2)}')),
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
                Container(width: MediaQuery.of(context).size.width /8,height: 45,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    color: Color(0xff0fb2ea),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          totalType =0;
                          sortByDateAscending = !sortByDateAscending;
                          // Reverse the sorting order when the button is tapped
                          widget.courses.sort((a, b) {
                            DateTime dateA = DateTime.parse(a['date'].toString());
                            DateTime dateB = DateTime.parse(b['date'].toString());

                            // Sort in ascending order if sortByDateAscending is true,
                            // otherwise sort in descending order
                            return sortByDateAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
                          });
                        });
                      },
                      child: Icon(sortByDateAscending ? Icons.arrow_upward : Icons.arrow_downward,color: Colors.white,),
                    ),
                  ),
                ),


              ],          ),
          ),

          // Display the calculated sums


// Define the pagination variables

// Determine the total number of pages

          Expanded(
            child: Container(
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
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    margin: EdgeInsets.only(left: 10),
                    child: Column(
                      children: [
                        DataTable(
                          showCheckboxColumn: true,
                          showBottomBorder: true,
                          horizontalMargin: 1,
                          headingRowHeight: 50,
                          columnSpacing: 18,
                          dataRowHeight: 50,
                          headingTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Set header text color
                          ),
                          // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xff0fb2ea)), // Set row background color
                          columns: [
                            DataColumn(label: Text('Signe')),
                            // DataColumn(label: Text('Payé')),
                            DataColumn(label: Text('Matiere')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Eq.CM')),
                            DataColumn(label: Text('Prix')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: [
                            for (var index = (currentPage - 1) * coursesPerPage;
                            index < widget.courses.length && index < currentPage * coursesPerPage;
                            index++)
                              if (courseFitsCriteria(widget.courses[index]))
                                DataRow(
                                  onLongPress: () =>
                                      _showCourseDetails(context, widget.courses[index]),
                                  cells: [

                                    DataCell(
                                        widget.courses[index]['isSigned'] == "oui"? Icon(Icons.check_box_outlined,size: 27):CupertinoSwitch(
                                          activeColor: Colors.black26,
                                          value:  widget.courses[index]['isSigned'] == "oui"? true: false,
                                          onChanged: (value) async {



                                            setState(() {
                                              widget.courses[index]['isSigned'] = value;
                                            });

                                            Navigator.of(context).pop();

                                            final updatedDate = DateFormat('yyyy-MM-ddTHH:mm').parse(widget.courses[index]['date']).toUtc();

                                            final matiereName = widget.courses[index]['somme'];
                                            // final matiereId = getMatiereIdFromName(matiereName);
                                            singeCours(
                                                widget.courses[index]['_id'],
                                                value
                                            );
                                          },
                                        )
                                    ),
                                    // DataCell(
                                    //     widget.courses[index]['isPaid'] == "oui"||widget.courses[index]['isPaid'] == "préparée"? Icon(Icons.check_box_outlined,size: 27)
                                    //         :Icon(Icons.check_box_outline_blank,size: 27)
                                    // ),
                                    DataCell(Container(
                                      width: 60,
                                      child: Text('${widget.courses[index]['matiere']}',style: TextStyle(
                                        color: Colors.black,
                                      ),),
                                    ),
                                        onTap: () =>
                                            _showCourseDetails(context, widget.courses[index])),
                                    DataCell(
                                      Text(
                                        '${DateFormat('dd/M ').format(
                                          DateTime.parse(widget.courses[index]['date'].toString()).toLocal(),
                                        )}',style: TextStyle(
                                        color: Colors.black,
                                      ),
                                      ),
                                    ),
                                    DataCell(
                                      Text('${widget.courses[index]['TH']}',style: TextStyle(
                                        color: Colors.black,
                                      ),),
                                    ),
                                    DataCell(
                                      Text('${widget.courses[index]['prix']}',style: TextStyle(
                                        color: Colors.black,
                                      ),),
                                    ),
                                    DataCell(

                                        Row(
                                          children: [
                                            Container(
                                              width: 35,
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
                                        )
                                    ),
                                  ],
                                ),
                            DataRow(cells: [
                              DataCell(Text('totals')),
                              // DataCell(Text('')),
                              DataCell((widget.dateDeb != null && widget.dateFin != null)?
                              Center(child: Text('${coursesNum} Cours',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400)))
                                  :Text('${widget.courses.length} Cours',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                              ),
                              DataCell(Text('')),
                              DataCell((widget.dateDeb != null && widget.dateFin != null)?
                              Text('${totalType}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                                  :Text('${totalType}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),),
                              ),

                              DataCell((widget.dateDeb != null && widget.dateFin != null)?
                              Text('${somme}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400))
                                  :Text('${somme}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                              ),

                              DataCell(Text('')),
                            ])

                          ],
                        ),

                      ],
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
                  child: Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
                Container(
                  width: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(currentPage.toString()),
                      Text('/'),
                      Text((widget.courses.length / coursesPerPage).ceil().toString()),
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
                    child: Text('Next'),
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

      // floatingActionButton: FloatingActionButton.extended(
      //   // heroTag: 'uniqueTag',
      //   tooltip: 'Ajouter une Cours',backgroundColor: Colors.white,
      //   label: Row(
      //     children: [Icon(Icons.add,color: Colors.black,)],
      //   ),
      //   onPressed: () => _displayTextInputDialog(context),
      //
      // ),


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
            height: 620,
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
                      Text(course['startTime'],
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
                      Text(course['finishTime'],
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

                Row(
                  children: [
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
                    SizedBox(width: 20),
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
                        Text('${course['nbh']}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),

                      ],
                    ),
                    SizedBox(width: 20),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text('Taux:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${course['prix']}',
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
                    Text('Eq.CM:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text('${course['TH']}',
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
                    Text('Signed:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text(
                      '${course['isSigned'] == "oui"? 'Oui': 'Non'}',
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
                    Text('Payé:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                    SizedBox(width: 10,),
                    Text(
                      '${course['isPaid'] == "oui"||course['isPaid'] == "préparée"? 'Oui': 'Non'}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        // color: Colors.lightBlue
                      ),),

                  ],
                ),
                SizedBox(height: 25,),
                ElevatedButton(
                  onPressed: () async{
                    setState(() {
                      Navigator.pop(context);
                    });
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return UpdateProfCoursDialog(courses: course, ProfId: course['professeur_id'],);
                      },
                    );
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
              ],
            ),
          );
        }


    );
  }


  // Future<void> _displayTextInputDialog(BuildContext context) async {
  //   List<Map<String, dynamic>> selectedTypes = [];
  //
  //   List<Map<String, dynamic>> availableTypes = [
  //     {"name": "CM", "nbh": 1.5},
  //     {"name": "CM", "nbh": 2},
  //     {"name": "TP", "nbh": 1.5},
  //     {"name": "TP", "nbh": 1},
  //     {"name": "TD", "nbh": 1.5},
  //     {"name": "TD", "nbh": 1},
  //     // Add more available types here as needed
  //   ];
  //
  //   final professorData = await fetchProfessorInfo();
  //   String professorId = professorData['professeur']['_id'];
  //   List<dynamic> professorMatieres = professorData['professeur']['matieres'];
  //
  //
  //   Matiere? selectedMat;
  //
  //   DateTime? selectedDateTime; // Initialize the selected date and time to null
  //   Future<void> selectTime(TextEditingController controller) async {
  //     DateTime? selectedDateTime = await showDatePicker(
  //       context: context,
  //       initialDate: DateTime.now(),
  //       firstDate: DateTime(2000),
  //       lastDate: DateTime(2030),
  //     );
  //
  //     if (selectedDateTime != null) {
  //       TimeOfDay? selectedTime = await showTimePicker(
  //         context: context,
  //         initialTime: TimeOfDay.now(),
  //       );
  //
  //       if (selectedTime != null) {
  //         DateTime selectedDateTimeWithTime = DateTime(
  //           selectedDateTime.year,
  //           selectedDateTime.month,
  //           selectedDateTime.day,
  //           selectedTime.hour,
  //           selectedTime.minute,
  //         );
  //
  //         String formattedDateTime = DateFormat('yyyy/MM/dd HH:mm').format(selectedDateTimeWithTime);
  //         setState(() {
  //           controller.text = formattedDateTime;
  //         });
  //       }
  //     }
  //   }
  //
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return SingleChildScrollView(
  //         child: AlertDialog(
  //           title: Text('Ajouter Cours Au Prof'),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Container(height: 110,
  //                 child: SingleChildScrollView(scrollDirection: Axis.horizontal,
  //                   child:  CourseTypeSelector(
  //                     availableTypes: availableTypes,
  //                     selectedTypes: selectedTypes,
  //                     onChanged: (newSelectedTypes) {
  //                       setState(() {
  //                         selectedTypes = newSelectedTypes;
  //                       });
  //                     },
  //                   ),
  //                 ),
  //               ),
  //
  //               SizedBox(height: 16),
  //               Text(
  //                "selection d'une Matiere",
  //                 style: TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //
  //               DropdownButtonFormField<Matiere>(
  //                 value: selectedMat,
  //                 items: professorMatieres.map((matiere) {
  //                   return DropdownMenuItem<Matiere>(
  //                     value: Matiere(
  //                       id: matiere['_id'],
  //                       name: matiere['name'], semestre: matiere['semestre'],
  //                       description: matiere['description'], categorieId: matiere['categorie']['_id'],
  //                       // Add other properties if needed
  //                     ),
  //                     child: Text(matiere['name'] ?? ''),
  //                   );
  //                 }).toList(),
  //                 onChanged: (value) {
  //                   setState(() {
  //                     selectedMat = value;
  //                   });
  //                 },
  //                 decoration: InputDecoration(
  //                   filled: true,
  //                   fillColor: Colors.white,
  //                   hintText: "....",hintStyle: TextStyle(fontSize: 20),
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.all(Radius.circular(10.0)),
  //                   ),
  //                 ),
  //               ),
  //
  //
  //               SizedBox(height: 16),
  //               TextFormField(
  //                 controller: _date,
  //                 decoration: InputDecoration(
  //                   labelText: 'Date',
  //                   border: OutlineInputBorder(),
  //                 ),
  //                 // readOnly: true,
  //                 onTap: () => selectTime(_date),
  //               ),
  //
  //
  //               // ElevatedButton for adding the matiere to professor
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   if (selectedMat == null ) {
  //
  //                     // Check if both a matiere and at least one type is selected
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text('Please select a matiere .')),
  //                     );
  //                   }
  //                   else if (selectedTypes.isEmpty) {
  //
  //                     // Check if both a matiere and at least one type is selected
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text('Please select  at least one type.')),
  //                     );
  //                   }
  //                   else if (_date == null) {
  //
  //                     // Check if both a matiere and at least one type is selected
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text('Please select a date.')),
  //                     );
  //                   }
  //                   else {
  //                     Navigator.of(context).pop();
  //                     // SharedPreferences prefs = await SharedPreferences.getInstance();
  //                     // String token = prefs.getString("token")!;
  //
  //                     print(professorId);
  //                     print(selectedMat!.id!);
  //                     print(selectedTypes); // Check the selected types here
  //
  //                     DateTime date = DateFormat('yyyy/MM/dd HH:mm').parse(_date.text).toUtc();
  //                     // Pass the selected types to addCoursToProfesseur method
  //                     addCoursToProfesseur( selectedMat!.id!, selectedTypes, date);
  //
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text('Matiere has been added to professor successfully.')),
  //                     );
  //
  //                     // setState(() {
  //                     //   fetchProfessorInfo();
  //                     // });
  //                   }
  //                 },
  //                 child: Text("Ajouter"),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.black,
  //                   foregroundColor: Colors.white,
  //                   elevation: 10,
  //                   padding: EdgeInsets.only(left: 90, right: 90),
  //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }


  Future<void> addCoursToProfesseur( String matiereId, List<Map<String, dynamic>> types, DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    String id = prefs.getString("_id")!;
    // final professorData = await fetchProfesseurDetails(id);
    // String id = professorData['professeur']['_id'];
    final url = 'http://192.168.43.73:5000/professeur/$id/cours';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({
      'matiere': matiereId,
      'type': types,
      'date': date.toIso8601String(),
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    print(response.statusCode);
    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      Navigator.of(context).pop(true);

      // You can handle the response data here if needed
      print(responseData);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Course added successfully.')),
      // );
    } else {
      // Handle errors
      print('Failed to add course to professor. Status Code: ${response.statusCode}');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to add course to professor.')),
      // );
    }
  }


  Future<List<Matiere>> fetchMatiereCateg(String categoryId) async {
    final url = 'http://192.168.43.73:5000/categorie/$categoryId/matieres';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Matiere> matieres = List<Matiere>.from(data['matieres'].map((m) => Matiere.fromJson(m)));
      return matieres;
    } else {
      throw Exception('Failed to fetch matières');
    }
  }


}


class CourseTypeSelector extends StatefulWidget {
  final List<Map<String, dynamic>> availableTypes;
  final List<Map<String, dynamic>> selectedTypes;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  CourseTypeSelector({
    required this.availableTypes,
    required this.selectedTypes,
    required this.onChanged,
  });

  @override
  _CourseTypeSelectorState createState() => _CourseTypeSelectorState();
}

class _CourseTypeSelectorState extends State<CourseTypeSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.availableTypes.map((type) {
            return CheckboxMenuButton(
              value: widget.selectedTypes.contains(type),
              onChanged: (value) {
                setState(() {
                  if (widget.selectedTypes.contains(type)) {
                    widget.selectedTypes.remove(type);
                  } else {
                    widget.selectedTypes.add(type);
                  }
                  widget.onChanged(widget.selectedTypes);
                });
              },
              child: Text(type['name'] + ' - ' + type['nbh'].toString()),
            );
          }).toList(),
        ),
      ),
    );
  }



}


class UpdateProfCoursDialog extends StatefulWidget {
  final Map<String, dynamic> courses;
  final String ProfId;

  UpdateProfCoursDialog({required this.courses, required this.ProfId});
  @override
  _UpdateProfCoursDialogState createState() => _UpdateProfCoursDialogState();
}

class _UpdateProfCoursDialogState extends State<UpdateProfCoursDialog> {
  List<Map<String, dynamic>> selectedTypes = [];
  List<Map<String, dynamic>> availableTypes = [
    {"name": "CM", "nbh": 1.5},
    {"name": "CM", "nbh": 2},
    {"name": "TP", "nbh": 1.5},
    {"name": "TP", "nbh": 1},
    {"name": "TD", "nbh": 1.5},
    {"name": "TD", "nbh": 1},
    // Add more available types here as needed
  ];
  Category? selectedCategory;
  dynamic? selectedMat;
  List<dynamic> matieres = [];
  List<Matiere> matiereList = [];
  DateTime? selectedDateTime;
  List<Category> categories = [];
  bool _selectedSigne = false;
  TextEditingController _date = TextEditingController();
  TextEditingController _isSigned = TextEditingController();

  bool showMatDropdown = false;
  late String mat;
  @override
  void initState()  {
    super.initState();
    // fetchProfMat();
    fetchMats();
    _date.text = DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(widget.courses['date'])).toString();
    // _selectedSigne = widget.courses['isSigned'];
    mat = widget.courses['matiere'];
  }

  Future<void> selectTime(TextEditingController controller) async {
    DateTime? selectedDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (selectedDateTime != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        DateTime selectedDateTimeWithTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        String formattedDateTime = DateFormat('yyyy/MM/dd HH:mm').format(selectedDateTimeWithTime);
        setState(() {
          controller.text = formattedDateTime;
        });
      }
    }
  }

  // Future<void> fetchProfMat() async {
  //   Map<String, dynamic> professorData = await fetchProfessorInfo();
  //
  //   List<dynamic> professorMatieres = professorData['professeur']['matieres'];
  //   setState(() {
  //     matieres = professorMatieres;
  //   });
  // }
  Future<void> fetchMats() async {
    List<Matiere> fetchedMats = await fetchMatiere();
    setState(() {
      matiereList = fetchedMats;
    });
  }
  String getMatiereIdFromName(String name) {
    // Assuming you have a list of matieres named 'matieresList'
    final matiere = matiereList.firstWhere((mat) => mat.name == name, orElse: () => Matiere(id: '', name: '',  categorieId: '', categorie_name: '', code: '',));
    return matiere?.id ?? ''; // Return the ID if found, otherwise an empty string
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: Text("Mise à jour de la tâche"),
        content: Form(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 110,
                  child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                    child: Row(
                      children: availableTypes.map((type) {
                        return CheckboxMenuButton(
                          value: selectedTypes.contains(type),
                          onChanged: (value) {
                            setState(() {
                              if (selectedTypes.contains(type)) {
                                selectedTypes.remove(type);
                              } else {
                                selectedTypes.add(type);
                              }
                            });
                          },child: Text(type['name'] + ' - ' + type['nbh'].toString()),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "selection d'une Matiere",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                showMatDropdown ?
                DropdownButtonFormField<dynamic>(
                  value: selectedMat,
                  items: matieres.map((matiere) {
                    return DropdownMenuItem<dynamic>(
                      value: matiere,
                      child: Text(matiere['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value)async {
                    setState(()  {
                      selectedMat = value;
                      // professeurs = await fetchProfesseursByMatiere(selectedMat!.id); // Clear the professeurs list when a matière is selected
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "....",hintStyle: TextStyle(fontSize: 15),
//                    hintText: "selection d'une Matiere",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                )
                    : TextFormField(
                  initialValue: mat,
                  decoration: InputDecoration(labelText: 'Nom du Catégorie'),
                  readOnly: true,
                  onTap: () {
                    setState(() {
                      showMatDropdown = true;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _date,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  // readOnly: true,
                  onTap: () => selectTime(_date),
                ),

                SizedBox(height: 16,),
                DropdownButtonFormField<bool>(
                  value: _selectedSigne,
                  items: [
                    DropdownMenuItem<bool>(
                      child: Text('True'),
                      value: true,
                    ),
                    DropdownMenuItem<bool>(
                      child: Text('False'),
                      value: false,
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSigne = value!;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "taux",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text("ANNULER"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              "MISE À JOUR",
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () async{
              Navigator.of(context).pop(true);

              _isSigned.text = _selectedSigne.toString();

              print(selectedTypes); // Check the selected types here

              DateTime date = DateFormat('yyyy/MM/dd HH:mm').parse(_date.text).toUtc();
              Navigator.of(context).pop();

              if (showMatDropdown) {
                // No changes, directly use the selected IDs
                // updateProfCours(widget.courses['_id'],widget.ProfId,selectedMat!['_id']!, widget.courses['CM'], date,bool.parse(_isSigned.text));
              } else {
                // Changes made, get the updated IDs
                String updatedMatId = await getMatiereIdFromName(mat); // Get updated matière ID
                print('updatedMatId: $updatedMatId');
                // updateProfCours(widget.courses['_id'], widget.ProfId, updatedMatId, widget.courses['CM'], date, bool.parse(_isSigned.text));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Le Type est  Update avec succès.')),
              );

              setState(() {
                widget.courses;
              });
            },
          ),
        ],
      ),

    );
  }


}

Future<void> updateProfCours( id,String professeurId,String matiereId, double CM, double TP, double TD, DateTime? date,String startTime, bool isSigned) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;

  List<Map<String, dynamic>> types = [
    {"name": "CM", "nbh": CM},
    {"name": "TP", "nbh": TP},
    {"name": "TD", "nbh": TD},
  ];

  final url = 'http://192.168.43.73:5000/cours/'  + '/$id';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  Map<String, dynamic> body =({
    'professeur': professeurId,
    'matiere': matiereId,
    'types': types,
    "startTime": CM,
    'date': date?.toIso8601String(),
    'isSigned':isSigned? "oui": "pas encore"
  });

  if (date != null) {
    body['date'] = date.toIso8601String();
  }

  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      // Course creation was successful
      print("Course created successfully!");
      final responseData = json.decode(response.body);
      print("Course ID: ${responseData['cours']['_id']}");
      // You can handle the response data as needed
    } else {
      // Course creation failed
      print("Failed to create course. Status code: ${response.statusCode}");
      print("Error Message: ${response.body}");
    }
  } catch (error) {
    print("Error: $error");
  }
}
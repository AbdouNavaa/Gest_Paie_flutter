import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:gestion_payements/professeures.dart';
import 'package:gestion_payements/update.dart';
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


class ProfCoursesPage extends StatefulWidget {
  final List<dynamic> courses;

  final String ProfId;
  final int coursNum;
  final num heuresTV;
  final num sommeTV;
  DateTime? dateDeb;
  DateTime? dateFin;
// Calculate the sums for filtered courses

  ProfCoursesPage({required this.courses, required this.coursNum, required this.heuresTV, required this.sommeTV, required this.ProfId}) {}



  @override
  State<ProfCoursesPage> createState() => _ProfCoursesPageState();
}

class _ProfCoursesPageState extends State<ProfCoursesPage> {
  double totalType = 0;
  void calculateTotalType() {
    if (widget.dateDeb != null && widget.dateFin != null) {
      // If date filters are applied
      totalType = widget.courses
          .where((course) {
        DateTime courseDate =
        DateTime.parse(course['date'].toString());
        return courseDate.isAtSameMomentAs(widget.dateDeb!.toLocal()) ||
            (courseDate.isAfter(widget.dateDeb!.toLocal()) &&
                courseDate.isBefore(
                    widget.dateFin!.toLocal().add(Duration(days: 1))));
      })
          .map((course) => double.parse(course['TH'].toString()))
          .fold(0, (prev, amount) => prev + amount);
    }
    else if ((widget.dateDeb != null && widget.dateFin == null) || (widget.dateDeb == null && widget.dateFin != null) ) {
      // If date filters are applied
      totalType = 0;
    }else {
      // If no date filters are applied
      int startIndex = (currentPage - 1) * coursesPerPage;
      int endIndex = startIndex + coursesPerPage - 1;
      totalType = widget.courses
          .skip(startIndex)
          .take(coursesPerPage)
          .map((course) => double.parse(course['TH'].toString()))
          .fold(0, (prev, amount) => prev + amount);
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
  bool isSigned = false;

  bool courseFitsCriteria(Map<String, dynamic> course) {
    // Apply your filtering criteria here
    DateTime courseDate = DateTime.parse(course['date'].toString());
    bool isMatch = course['matiere'].toLowerCase().contains(searchQuery.toLowerCase());

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
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: 'Search by matiere ',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),



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
                    backgroundColor: Color(0xFF0C2FDA),foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),

              ),
              Container(width: 50,
                  child:Text('total: ${totalType.toStringAsFixed(2)}'),
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
                    backgroundColor: Color(0xFF0C2FDA),foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ],          ),
          // Display the calculated sums
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(width: 280,height: 50,
                  // color: Colors.black87,
                  margin: EdgeInsets.all(8),
                  child: Card(
                    elevation: 5,
                    // margin: EdgeInsets.only(top: 10),
                    shadowColor: Colors.blue,
                    // color: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Eq. CM: ${widget.heuresTV}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),),
                              Text('Montant Total : ${widget.sommeTV}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400)),
                            ],
                          ),
                          Center(child: Text('Nb de Cours: ${widget.coursNum}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400))),

                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 40,height: 40,
                  color: Color(0xFF0C2FDA),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        // totalType =0;
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

              ],
            ),
          ),


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
              child: DataTable(
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
                // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFF0C2FDA)), // Set row background color
                columns: [
                  DataColumn(label: Text('Signe')),
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
                              CupertinoSwitch(
                                activeColor: Colors.black,
                                value: widget.courses[index]['isSigne'],
                                onChanged: (value) async {
                                  final typesString = widget.courses[index]['types'];
                                  final typeParts = typesString.split(':');

                                  print(typeParts);
                                  print(typeParts.length);
                                  // Check if the "types" string is in the expected format
                                  if (typeParts.length > 2) {
                                    // Display an alert or notification here
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25),),elevation: 1,
                                          title: Text('Impossible'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Il y en a plus d'un type"),
                                              Text("Cours Type [${widget.courses[index]['types']}]"),
                                             SizedBox(height: 10,),
                                              Text("Il faut cliquer sur button de Modification",style: TextStyle(color: Colors.blueGrey),),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    return;
                                  }

                                  // Continue with the rest of your onChanged logic if the types string is in the expected format
                                  setState(() {
                                    widget.courses[index]['isSigne'] = value;
                                  });

                                  Navigator.of(context).pop();

                                  final updatedDate = DateFormat('yyyy-MM-ddTHH:mm').parse(widget.courses[index]['date']).toUtc();
                                  final typeName = typeParts[0].trim();
                                  final typeNbhString = typeParts[1].replaceAll(',', '').trim();

                                  final updatedTypes = [{'name': typeName, 'nbh': typeNbhString}];

                                  final matiereName = widget.courses[index]['matiere'];
                                  final matiereId = getMatiereIdFromName(matiereName);

                                  if (matiereId != null) {
                                    updateProfCours(
                                      widget.courses[index]['_id'],
                                      widget.ProfId,
                                      matiereId,
                                      updatedTypes,
                                      updatedDate,
                                      value,
                                    );
                                  } else {
                                    print("Matiere not found with name: $matiereName");
                                  }
                                },
                              )
                          ),
                          DataCell(Text('${widget.courses[index]['matiere']}'),
                              onTap: () =>
                                  _showCourseDetails(context, widget.courses[index])),
                          DataCell(
                            Text(
                              '${DateFormat('dd/M ').format(
                                DateTime.parse(widget.courses[index]['date'].toString()).toLocal(),
                              )}',
                            ),
                          ),
                          DataCell(
                            Text('${widget.courses[index]['TH']}'),
                          ),
                          DataCell(
                            Text('${widget.courses[index]['somme']}'),
                          ),
                          DataCell(

                            Row(
                              children: [
                                Container(
                                  width: 35,
                                  child: TextButton(
                                    onPressed: () =>_showCourseDetails(context, widget.courses[index]),// Disable button functionality

                                    child: Icon(Icons.more_vert, color: Colors.blue),
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      elevation: 0,
                                      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                                    ),
                                  ),

                                ),
                                Container(
                                  width: 35,
                                  child: TextButton(
                                    onPressed: () async{
                                      return showDialog(
                                        context: context,
                                        builder: (context) {
                                          return UpdateProfCoursDialog(courses: widget.courses[index], ProfId: widget.ProfId,);
                                        },
                                      );
                                    },// Disable button functionality

                                    child: Icon(Icons.edit, color: Colors.green),
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

  void _showCourseDetails(BuildContext context, Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25),),elevation: 1,
          title: Text(course['matiere'].toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              // color: Colors.lightBlue
            ),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Divider(color: Colors.black87),
              Row(
                children: [
                  Text('Date:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                  SizedBox(width: 10,),
                  Text('${DateFormat('dd/M/yyyy ').format(DateTime.parse(course['date'].toString()).toLocal())}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('Deb:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                  SizedBox(width: 10,),
                  Text('${DateFormat(' HH:mm').format(DateTime.parse(course['date'].toString()).toLocal())}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('Fin:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                  SizedBox(width: 10,),
                  Text('${DateFormat(' HH:mm').format(DateTime.parse(course['date'].toString()).toLocal().add(Duration(minutes: (( course['CM']+course['TP']+course['TD'] )* 60).toInt())))}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                ],
              ),
              SizedBox(height: 8),

              Row(
                children: [
                  Text('CM:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                  SizedBox(width: 10,),
                  Text('${course['CM']}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('TP:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                  SizedBox(width: 10,),
                  Text('${course['TP']}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('TD:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                  SizedBox(width: 10,),
                  Text('${course['TD']}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('Taux:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                  SizedBox(width: 10,),
                  Text('${course['prix']}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('Eq.CM:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                  SizedBox(width: 10,),
                  Text('${course['TH']}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('Montant Total:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                  SizedBox(width: 10,),
                  Text('${course['prix']* course['TH']}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('Signed:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                  SizedBox(width: 10,),
                  Text(
                    '${course['isSigne']}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      // color: Colors.lightBlue
                    ),),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
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
    final professorData = await fetchProfessorInfo();
    String id = professorData['professeur']['_id'];
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
  TextEditingController _isSigne = TextEditingController();

  bool showMatDropdown = false;
late String mat;
  @override
  void initState()  {
    super.initState();
    fetchProfMat();
    fetchMats();
    _date.text = DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(widget.courses['date'])).toString();
    _selectedSigne = widget.courses['isSigne'];
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

  Future<void> fetchProfMat() async {
      Map<String, dynamic> professorData = await fetchProfessorInfo();

      List<dynamic> professorMatieres = professorData['professeur']['matieres'];
      setState(() {
        matieres = professorMatieres;
      });
    }
  Future<void> fetchMats() async {
    List<Matiere> fetchedMats = await fetchMatiere();
    setState(() {
      matiereList = fetchedMats;
    });
  }
  String getMatiereIdFromName(String name) {
    // Assuming you have a list of matieres named 'matieresList'
    final matiere = matiereList.firstWhere((mat) => mat.name == name, orElse: () => Matiere(id: '', name: '', description: '', categorieId: '', semestres: []));
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

              _isSigne.text = _selectedSigne.toString();

              print(selectedTypes); // Check the selected types here

              DateTime date = DateFormat('yyyy/MM/dd HH:mm').parse(_date.text).toUtc();
              Navigator.of(context).pop();

              if (showMatDropdown) {
                // No changes, directly use the selected IDs
                updateProfCours(widget.courses['_id'],widget.ProfId,selectedMat!['_id']!, selectedTypes, date,bool.parse(_isSigne.text));
              } else {
                // Changes made, get the updated IDs
                String updatedMatId = await getMatiereIdFromName(mat); // Get updated matière ID
                print('updatedMatId: $updatedMatId');
                updateProfCours(widget.courses['_id'], widget.ProfId, updatedMatId, selectedTypes, date, bool.parse(_isSigne.text));
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

Future<void> updateProfCours( id,String professeurId,String matiereId, List<Map<String, dynamic>> types, DateTime? date, bool isSigne) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  final url = 'http://192.168.43.73:5000/cours/'  + '/$id';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  Map<String, dynamic> body =({
    'professeur': professeurId,
    'matiere': matiereId,
    'types': types,
    // 'date': date?.toIso8601String(),
    'isSigne':isSigne
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
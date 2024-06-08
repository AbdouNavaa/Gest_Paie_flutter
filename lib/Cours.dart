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
import 'home_screen.dart';
import 'matieres.dart';


class CoursesPage extends StatefulWidget {
  final List<dynamic> courses;
  final int coursNum;
  // final num heuresTV;
  final String role;
  // final num sommeTV;
  DateTime? dateDeb;
  DateTime? dateFin;
  bool paid;
// Calculate the sums for filtered courses

  CoursesPage({required this.courses, required this.role, required this.coursNum,required this.paid}) {}



  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  double totalType = 0;
// Calculate totalType based on applied date filters and pagination
  double somme = 0;
  int coursesNum = 0;
  List<Professeur> professeurList = [];

  bool signer = false;
  bool showInfo = false;
  bool sort = false;
  void singeCours( id, isSigned) async {

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
        'isSigned':isSigned? "effectué": "en attente"
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {

      setState(() {
        Navigator.pop(context);
      });
    } else {
      return Future.error('Server Error');
    }
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
    final element = elLis.firstWhere((g) => '${g.id}' == id, orElse: () => Elem(id: '', filId: '',   ));
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
        course['matiere'].toLowerCase().contains(searchQuery.toLowerCase()) || course['nom'].toLowerCase().contains(searchQuery.toLowerCase())
        ||
        course['prenom'].toLowerCase().contains(searchQuery.toLowerCase()) || course['code'].toLowerCase().contains(searchQuery.toLowerCase())
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

  List<String> selectedCoursIds = [];
bool showFloat = false;

  void deleteSelectedEmplois() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    for (var id in selectedCoursIds) {
      var response = await http.delete(
        Uri.parse('http://192.168.43.73:5000/cours' + "/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      var jsonResponse = jsonDecode(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('Deleted $id');

      } else {
        print('Failed to delete $id');
      }
    }

    fetchemploi();
    setState(() {
      selectedCoursIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Call the method to calculate totalType
    calculateTotalType();
    return Scaffold(
      // appBar: AppBar(title: Center(child: Text('${widget.coursNum} Courses',style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.w400),))),
      drawer: MyDrawer(),
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
                showFloat?
                Container(width: MediaQuery.of(context).size.width/3*2,
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(.85),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child:TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      // controller: searchQuery,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.tune_sharp, color: Colors.grey),
                          onPressed: () {
                            // _showFilterOptionsDialog(context,_searchController.text);
                          },
                        ),
                        hintText: 'Rechercher',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    )):
                Text("Liste des Cours",style: TextStyle(fontSize: 20),),

                showFloat?
                SizedBox():
                SizedBox(width: 115,),
                Container(
                  width: 50,
                  height: 50,
                // color: Colors.black26,
                child: IconButton(icon:Icon(Icons.search, size: 30,color: Colors.black),
                  onPressed: () {
                  setState(() {
                    showFloat = !showFloat;
                  });
                },
                ),
                ),


              ],
            ),
          ),
          Divider(),

          Container(
            width: MediaQuery.of(context).size.width,
            height: 40,
            // color: Colors.black38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    child: Row(
                      children: [
                        Icon(Icons.tune, color: Colors.black,),
                        Text('Filtrer',style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    onPressed: () => _filtrer(context),


                  ),
                ),
                SizedBox(child: Container(color: Colors.black38,width: 1,),height: 30,),
                Expanded(
                  child: TextButton(
                    child: Row(
                      children: [
                        Icon(Icons.refresh_outlined, color: Colors.black,),
                        Text('Auto',style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    onPressed: () => auto(),
                  
                  ),
                ),
                SizedBox(child: Container(color: Colors.black38,width: 1,),height: 30,),
                Expanded(
                  child: TextButton(
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.black,),
                        Text('Infos',style: TextStyle(color: Colors.black),),
                      ],
                    ),
                    onPressed: (){
                      setState(() {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                surfaceTintColor: Color(0xB0AFAFA3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                                title: Center(child: Text("Alerte")),
                                content: Container(height: 100,
                                  child: Column(
                                    children: [
                                      Row(
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 15,),
                                          Expanded(child: Row(children: [
                                            Icon(Icons.panorama_fish_eye,),
                                            Text('En attente'),
                                          ],)),

                                          Expanded(child: Row(children: [
                                            Icon(Icons.task_alt,),
                                            Text('Effectué')
                                          ],)),
                                        ],
                                      ),

                                      SizedBox(height: 20,),
                                      Row(
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 15,),
                                             widget.paid? SizedBox():
                                          Expanded(child: Row(children: [
                                            Icon(Icons.highlight_remove_sharp,),
                                            Text('Annulé')
                                          ],)),

                                          widget.paid?
                                          Expanded(child: Row(children: [
                                            Icon(Icons.remove_circle_outline,),
                                            Text('En Cours')
                                            // Text('préparé')
                                          ],))
                                              :SizedBox(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
                ),


              ],
            ),
          ),



          SizedBox(height: 10,),
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
                            Container(
                              width: MediaQuery.of(context).size.width -10,
                              decoration: BoxDecoration(
                                  // color: widget.courses.length > 0 ? Colors.white10:Colors.white,
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: DataTable(
                                showCheckboxColumn: true,
                                showBottomBorder: true,
                                // sortColumnIndex: 1,
                                // sortAscending: true,
                                headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white10),
                                dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                                headingRowHeight: 50,
                                columnSpacing:  (!showPaid && !showSigned)?8: 25,
                                horizontalMargin:  3,
                                // border: TableBorder.symmetric(outside: BorderSide(color: Colors.black),inside: BorderSide(color: Colors.black12)),
                                dataRowHeight: 60,
                                headingTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,fontSize: 13 // Set header text color
                                ),
                                dataTextStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,fontSize: 13 // Set header text color
                                ),
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
                                        child: Text('Paié'))),
                                  DataColumn(label: InkWell(
                                      child: Text('Date'))),
                                  DataColumn(label: Text('Professeur')),
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
                                          selected: selectedCoursIds.contains(widget.courses[index]['_id']),
                                          onSelectChanged: (selected) {
                                            setState(() {
                                              if (selected!) {
                                                selectedCoursIds.add(widget.courses[index]['_id']);
                                              } else {
                                                selectedCoursIds.remove(widget.courses[index]['_id']);
                                              }
                                            });
                                          },  // mouseCursor: MaterialStateMouseCursor.clickable,
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
                                                  child: Icon( widget.courses[index]['isSigned'] =="effectué"?  Icons.task_alt
                                                      :widget.courses[index]['isSigned'] =="annulé"?  Icons.highlight_remove_sharp
                                                      :Icons.panorama_fish_eye,
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
                                              Text(
                                                '${DateFormat('dd MMM ').format(
                                                  DateTime.parse(widget.courses[index]['date'].toString()).toLocal(),
                                                )}',style: TextStyle(
                                                color: Colors.black,
                                              ),
                                              ),
                                            ),
                                            DataCell(Text('${widget.courses[index]['nom'].toString().capitalize} ${widget.courses[index]['prenom'].toString().capitalize}',style: TextStyle(
                                              color: Colors.black,
                                            ),),
                                                onTap: () => _showCourseDetails(context, widget.courses[index])
                                            ),
                                            DataCell(Text('${widget.courses[index]['code'].toString().toUpperCase()}',style: TextStyle(
                                              color: Colors.black,
                                            ),),
                                              onTap: () => _showCourseDetails(context, widget.courses[index])
                                            ),
                                            DataCell(
                                              Center(child: Text('${widget.courses[index]['th']}',style: TextStyle(
                                                color: Colors.black,
                                              ),)),
                                            ),
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

                                  // DataRow(
                                  //     color:MaterialStateColor.resolveWith((states) => Colors.white),
                                  //
                                  //     cells: [
                                  //       DataCell(Text('Total', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
                                  //       DataCell(Text('')),
                                  //       DataCell((widget.dateDeb != null && widget.dateFin != null)?
                                  //       Center(child: Text('${coursesNum} Cours',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)))
                                  //           :Text('${widget.courses.length} Cours',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                                  //       ),
                                  //       DataCell(Text('')),
                                  //       DataCell(
                                  //           Text('${totalType}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                                  //       ),
                                  //
                                  //
                                  //       DataCell(
                                  //           Text('${somme}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold))
                                  //       ),
                                  //
                                  //       DataCell(Text('')),
                                  //     ])

                                ],
                              ),
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 40,),
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
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  gapPadding: 2,
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
                          Text(currentPage.toString(),style: TextStyle(fontSize: 15),),
                          SizedBox(width: 5,),
                          Text('/',style: TextStyle(fontSize: 15)),
                          SizedBox(width: 5,),
                          Text((widget.courses.length / coursesPerPage).ceil().toString(),style: TextStyle(fontSize: 15)),
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

      floatingActionButton:selectedCoursIds.isNotEmpty?
      TextButton(
        onPressed: () {
          if (selectedCoursIds.isNotEmpty) {

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  // surfaceTintColor: Color(0xB0AFAFA3),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                  title: Text("Confirmer la suppression",style: TextStyle(fontSize: 20)),
                  content: Text("Êtiez-vous sûr de vouloir supprimer cet élément ?"),
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
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        deleteSelectedEmplois();
                        // DeleteCours(course['_id']);
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
          } 
        },

        child: Icon(Icons.delete_outlined,size: 40,),
        style: TextButton.styleFrom(
          surfaceTintColor: Colors.white,
          // side: BorderSide(color: Colors.black38),
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          // padding: EdgeInsets.symmetric(horizontal: 25),
          foregroundColor: Colors.red,
          backgroundColor: Colors.white,
          textStyle: TextStyle(fontWeight: FontWeight.bold),
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ):
      Container(
        width: 60,
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
            ),
          ],
        ),

        // margin: EdgeInsets.only(left: 90,right: 60),
        child: TextButton(
          child: Icon(Icons.add, color: Colors.white,),
          onPressed: () => _displayTextInputDialog(context),

        ),

      ),

      // bottomNavigationBar: BottomNav(),
    );

  }

  Text bottomContainer(lab) => Text(lab,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),);

  Future<void> _showCourseDetails(BuildContext context, Map<String, dynamic> course) {
    return showModalBottomSheet(
        context: context,backgroundColor: Colors.white,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
        //     topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return Container(
            height: 650,
            decoration: BoxDecoration(borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text('Cours Infos',style: TextStyle(fontSize: 25,color: Colors.blueGrey),),
                    Spacer(),
                    InkWell(
                      child: Icon(Icons.close,color: Colors.blueGrey),
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
                    Text(("${course['nom']} ${course['prenom']}").toString().capitalize!,
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
                    Text('${DateFormat('dd MMMM yyyy ').format(DateTime.parse(course['date'].toString()).toLocal())}',
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
               widget.paid!?SizedBox(): Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    course['isSigned'] == "effectué"?SizedBox(): ElevatedButton(
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
                              DateTime.parse(course['date'].toString()).toLocal(),),Prof: "${course['nom']} ${course['prenom']}",
                              EM:course['matiere'], EP:"${course['nom']} ${course['prenom']}", TN: course['type'], th: course['nbh'], GN: '', MId: course['element'], PId: course['professeur'],)),
                          );
                        });
                      },// Disable button functionality

                      child: Text('Modifier'),
                      style: ElevatedButton.styleFrom(
                        surfaceTintColor: Colors.white,
                        // side: BorderSide(color: Colors.black38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),

                    ),
                    ElevatedButton(
                      onPressed: () {
                       setState(() {
                         signer = !signer;
                         singeCours(course['_id'] ,signer);
                       });
                       Navigator.of(context).pop();


                         },// Disable button functionality

                      child: Text('Signer'),
                      style: ElevatedButton.styleFrom(
                        surfaceTintColor: Colors.white,
                        // side: BorderSide(color: Colors.black38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
                      style: ElevatedButton.styleFrom(
                        // surfaceTintColor: Colors.white,
                        // side: BorderSide(color: Colors.black38),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
                insetPadding: EdgeInsets.only(top: widget.paid?300:230,),


                        surfaceTintColor: Colors.white,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                    // bottomRight: Radius.circular(20),
                    // bottomLeft: Radius.circular(20),
                  ),
                ),
                title: Text('Ajouter un Filter'),
                content: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 420,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 30,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Date :', style: TextStyle(fontWeight: FontWeight.w700,fontSize: 15,textBaseline:  TextBaseline.alphabetic),),
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
                                  builder: (context, child){
                                    return CalenderStyle(child: child!,);
                                  }
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
                                // surfaceTintColor: Colors.white,
                                // side: BorderSide(color: Colors.black38),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 5,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                textStyle: TextStyle(fontWeight: FontWeight.bold),
                                // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
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
                                    builder: (context, child){
                                    return CalenderStyle(child: child!,);
                                    }
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
                                // surfaceTintColor: Colors.white,
                                // side: BorderSide(color: Colors.black38),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 5,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                textStyle: TextStyle(fontWeight: FontWeight.bold),
                                // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 50,),
                        widget.paid?SizedBox():
                        Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Type :', style: TextStyle(fontWeight: FontWeight.w700,fontSize: 15,textBaseline:  TextBaseline.alphabetic),),
                          ],
                        ),
                        SizedBox(height: 10,),
                        widget.paid?SizedBox():
                        Row(

                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: (){
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
                                Icon(Icons.task_alt),
                                Text("Signé"),
                              ],
                            ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: showSigned?  Colors.lightGreenAccent: Colors.white,
                                backgroundColor: Colors.green.shade700,
                                elevation: 5,
                                padding: EdgeInsets.only(left: 30, right: 30),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          SizedBox(width: 50,),
                          ElevatedButton(
                            onPressed: (){
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
                              foregroundColor: showSigned?  Colors.lightGreenAccent: Colors.white,
                              backgroundColor: Colors.green.shade700,
                              elevation: 5,
                              padding: EdgeInsets.only(left: 30, right: 30),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            )
                          ],
                        ),

                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 15,),
                            Text('Date: Ancienne à Récente', style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15 ),),
                            SizedBox(width: 80,),
                            Radio(
                              value: true,
                              groupValue: sortByDateAscending,
                              onChanged: (value) {
                                setState(() {
                                  // totalType =0;
                                  sort = !sort;
                                  sortByDateAscending = sortByDateAscending!;
                                  // Reverse the sorting order when the button is tapped
                                  widget.courses.sort((a, b) {
                                    DateTime dateA = DateTime.parse(a['date'].toString());
                                    DateTime dateB = DateTime.parse(b['date'].toString());

                                    // Sort in ascending order if sortByDateAscending is true,
                                    // otherwise sort in descending order

                                    return dateA.compareTo(dateB) ;

                                  });
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        Divider(color: Colors.black38,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 15,),
                            Text('Date: Récente à Ancienne', style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15,),),
                            SizedBox(width: 80,),
                            Radio(
                              value: false,
                              groupValue: sortByDateAscending,
                              onChanged: (value) {
                                setState(() {
                                  sort = !sort;
                                  sortByDateAscending = !sortByDateAscending;
                                  widget.courses.sort((a, b) {
                                    DateTime dateA = DateTime.parse(a['date'].toString());
                                    DateTime dateB = DateTime.parse(b['date'].toString());

                                    // Sort in ascending order if sortByDateAscending is true,
                                    // otherwise sort in descending order

                                    return dateB.compareTo(dateA);
                                  });
                                });
                                  Navigator.pop(context);
                              },

                            ),
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

class CalenderStyle extends StatelessWidget {
   CalenderStyle({required this.child
  });

  Widget child ;

  @override
  Widget build(BuildContext context ) {
    return Theme(data: Theme.of(context).copyWith(
      colorScheme: ColorScheme.light(
        primary: Colors.blue,surfaceTint: Colors.white,
        secondary: Colors.white,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Colors.black
        )
      )
    ), child: child!);
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
  String? selectedGroup;

  filliere? selectedFil;
  int? selectedSem;
  Eles? selectedElem;
  Matiere? selectedMat;
  Professeur? selectedProfesseur;
  List<Professeur> professeurs = [];
  DateTime? selectedDateTime;
  List<dynamic> filteredGroups = [];

  Future<void> updateElemList() async {
    if (selectedProfesseur != null) {
      List<Eles>? fetchedProfesseurs = await fetchElsByProf(selectedProfesseur!.id);
      setState(() {
        elList = fetchedProfesseurs!;
        selectedElem = null;
      });
    } else {
      // List<Elem> fetchedProfesseurs = [];
      setState(() {
        elList = [];
        selectedElem = null;
      });
    }
  }
  List<dynamic>? updateFilteredGroups(selectedType,selectedProfesseur,selectedElem) {
    if (selectedType != null && selectedElem != null) {
      List<dynamic> groups;
      List<dynamic> professors;
      if (selectedType == 'CM') {
        groups = selectedElem!.groupeCM ?? [];
        professors = selectedElem?.professeurCM ?? [];
      } else if (selectedType == 'TP') {
        groups = selectedElem?.groupeTP ?? [];
        professors = selectedElem?.professeurTP ?? [];
      } else {
        groups = selectedElem?.groupeTD ?? [];
        professors = selectedElem?.professeurTD ?? [];
      }

      // Filter groups by professor ID
      String profId = selectedProfesseur?.id ?? '';
      print('ProfID:${profId}');
      filteredGroups = groups.where((group) {
        return professors.any((prof) => prof == profId && group.contains(prof));
      }).toList();
      print("Groups:${filteredGroups}");
      return filteredGroups;
    } else {
      filteredGroups = [];
    }
  }

  List<Professeur> professeurList = [];

  List<Eles> elList = [];
  List<Eles> elList2 = [];
  List<Eles> elList1 = [];
  List<Matiere> matiereList = [];
  List<filliere> filList = [];
  List<int> semestersList = [];


  List<Eles> filterElsbySem(String FilId, int sem,List<Eles> allItems) {
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
        builder: (context, child){
                                              return CalenderStyle(child: child!,);
        }
        );

    if (selectedDateTime != null) {
      String formattedDateTime = DateFormat('yyyy/MM/dd').format(selectedDateTime);
      setState(() {
        controller.text = formattedDateTime;
      });
    }
  }
  bool isChanged =false;



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
        builder: (context, child){
          return TimeCalender(child: child!,);
        }
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
    // fetchElems().then((data) {
    //   setState(() {
    //     elList = data; // Assigner la liste renvoyée par emploiesseur à items
    //   });
    // }).catchError((error) {
    //   print('Erreur: $error');
    // });


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



  List<Eles> filterItemsBySemestre(int? ele, List<Eles> allItems) {
    if (ele == 0) {
      return allItems;
    } else {
      // print("ElID:${ele.id}");
      return allItems.where((elem) => elem.SemNum == ele).toList();
    }
  }

  List<int> extractUniqueSemesters(List<Eles> elems) {
    Set<int> uniqueSemesters = elems.map((elem) => elem.SemNum!).toSet();
    return uniqueSemesters.toList();
  }
  List<Eles> filterItemsByFil(filliere? fil, List<Eles> allItems) {
    if (fil == null) {
      return allItems;
    } else {
      return allItems.where((ele) => ele!.filId == fil.id).toList();
    }
  }

  // Créez une fonction pour filtrer les types de cours en fonction des professeurs associés à l'élément sélectionné
  List<String> filterCoursTypes(List<Professeur> professeurs, Elem element) {
    List<String> types = [];

    // Vérifiez si le professeur est associé à l'élément comme CM
    for (var prof in element.ProCMId!) {
      if (professeurs.any((p) => p.id == prof['_id'])) {
        types.add('CM');
        break;
      }
    }

    // Vérifiez si le professeur est associé à l'élément comme TP
    for (var prof in element.ProTPId!) {
      if (professeurs.any((p) => p.id == prof['_id'])) {
        types.add('TP');
        break;
      }
    }

    // Vérifiez si le professeur est associé à l'élément comme TD
    for (var prof in element.ProTDId!) {
      if (professeurs.any((p) => p.id == prof['_id'])) {
        types.add('TD');
        break;
      }
    }

    return types;
  }

// Dans votre classe State, initialisez une liste de types de cours disponibles
  List<String> coursTypes = [];

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
                // buildTextFormField(_start,"Heure",selectTime(_start)),
                // SizedBox(height: 10),
                // buildTextFormField(_date,"Date",selectDate(_date)),

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
                    hintText: "selection d'un Professeur",

                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,gapPadding: 1,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(flex: 1,
                      child: Container(
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
                    ),
                    SizedBox(width: 10),
                    Expanded(flex: 1,
                      child: Container(
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
                    ),

                  ],
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<Eles>(
                  value: selectedElem,
                  items: elList1.map((ele) {
                    return DropdownMenuItem<Eles>(
                        value: ele,
                        child: Text(ele.nameMat ?? '')
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedElem = value;
                      // coursTypes = filterCoursTypes(professeurList, value!);
                      // _selectedType = 'CM';
                      // Réinitialiser les types de cours en fonction du professeur sélectionné
                      // List<String> filteredCourseTypes = filterCourseTypes(selectedElem!, selectedProfesseur!);
                      // Mettre à jour la liste des types de cours disponibles
                      // availableTypes = filteredCourseTypes;
                    //
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

                    Expanded(flex: 1,
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
                          selectedGroup = null;
                          groupName = _selectedType == "CM"?'G':_selectedType == "TP"?'TP':'TD';
                          updateFilteredGroups(  _selectedType,selectedProfesseur,selectedElem,);
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
                    Expanded(flex: 1,
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
                    // if (_selectedType != null)
                  SizedBox(width: 10),
                    Expanded(flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: selectedGroup,disabledHint: Text('Groupe'),
                        items: filteredGroups.map((group) {
                          return DropdownMenuItem<String>(
                            value: group,//abdou
                            child: Text('${groupName}${group.split('-')[2]}'),
                            // child: Text('${getProfesseurIdFromName(group.split('-')[0])} ${groupName}${group.split('-')[2]}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGroup = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Sélectionner un groupe",
                          labelText: 'Groupe',labelStyle: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),

                    ),
                  ],
                ),
                SizedBox(height: 15),
                // DropdownButtonFormField<String>(
                //   value: _selectedType,
                //   items: coursTypes.map((type) {
                //     return DropdownMenuItem<String>(
                //       value: type,
                //       child: Text(type),
                //     );
                //   }).toList(),
                //   onChanged: (value) {
                //     setState(() {
                //       _selectedType = value!;
                //     });
                //   },
                //   // Autres propriétés de décoration, etc.
                // ),


                SizedBox(height:20),
                ElevatedButton(
                  onPressed: (){

                    DateTime date =DateFormat('yyyy/MM/dd').parse(_date.text).toUtc();
                    addCours(_selectedType,_selectedNbh,date,_start.text,selectedElem!.id,selectedProfesseur!.id,selectedGroup!);
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

  TextFormField buildTextFormField(controller,hintT,onTap) {
    return TextFormField(
                controller: controller,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: hintT,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,gapPadding: 1,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                // readOnly: true,
                onTap: () => onTap,
              );
  }

  Future<void> addCours(String type, num nbh,DateTime date,String time, String ElemId,String ProfId,String groupe,) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    final Uri uri = Uri.parse('http://192.168.43.73:5000/cours');


    final Map<String, dynamic> emploiData = {
      "type": type,
      "nbh": nbh,
      "date": date!.toIso8601String(),
      "startTime": time,
      "groupe": groupe,
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

  String getProfesseurIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    // awai
    final professeur = professeurList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>
        Professeur(id: '', nom:'',user: '',  ));
    print("Nom: ${professeurList}");
    return "${professeur.nom!} ${ professeur.prenom!}"; // Return the ID if found, otherwise an empty string

  }
  String groupName = 'G';

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
                          builder: (context, child){
                                                                return CalenderStyle(child: child!,);
                          }
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
                          builder: (context, child){
                                                                return CalenderStyle(child: child!,);
                          }
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
        builder: (context, child){
                                              return CalenderStyle(child: child!,);
        }
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

  Eles? selectedElem;
  String? selectedMat;
  Professeur? selectedProfesseur;
  DateTime? selectedDateTime;

  List<Eles> elList = [];
  List<Eles> elList2 = [];
  List<Eles> elList1 = [];
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
        builder: (context, child){
          return TimeCalender(child: child!,);
        }
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
      List<Eles>? fetchedProfesseurs = await fetchElsByProf(selectedProfesseur!.id);
      setState(() {
        elList = fetchedProfesseurs!;
        selectedElem = null;
      });
    } else {
      // List<Elem> fetchedProfesseurs = await fetchElems();
      setState(() {
        elList = [];
        selectedElem = null;
      });
    }
  }


  List<Eles> filterItemsBySemestre(int? ele, List<Eles> allItems) {
    if (ele == 0) {
      return allItems;
    } else {
      // print("ElID:${ele.id}");
      return allItems.where((elem) => elem.SemNum == ele).toList();
    }
  }

  List<int> extractUniqueSemesters(List<Eles> elems) {
    // List<Elem> Els = filterItemsByFil(fil,elems);
    Set<int> uniqueSemesters = elems.map((elem) => elem.SemNum!).toSet();
    return uniqueSemesters.toList();
  }
  List<Eles> filterItemsByFil(filliere? fil, List<Eles> allItems) {
    if (fil == null) {
      return allItems;
    } else {
      return allItems.where((ele) => ele!.filId == fil.id).toList();
    }
  }

  // Elem getEls(String id) {
  //   // Assuming you have a list of professeurs named 'professeursList'
  //   final element = elList.firstWhere((g) => '${g.id}' == id, orElse: () => Elem(id: '', filId: '',   ));
  //   print( "Els:${element}");
  //   return element!; // Return the ID if found, otherwise an empty string
  //
  // }

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
    // fetchElems().then((data) {
    //   setState(() {
    //     elList = data; // Assigner la liste renvoyée par emploiesseur à items
    //   });
    // }).catchError((error) {
    //   print('Erreur: $error');
    // });
    _date.text = widget.date.toString();
    selectedNbhValue = widget.th;
    selectedTypeName = widget.TN;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
                surfaceTintColor: Color(0xB0AFAFA3),
        insetPadding: EdgeInsets.only(top: 120,),
        
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
                      showProf = true;
                      selectedElem = null;
                      updateElemList();
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "selection d'un Professeur",

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
                DropdownButtonFormField<Eles>(
                  value: selectedElem,
                  hint: Text('${widget.EM}'),
                  items: elList1.map((ele) {
                    return DropdownMenuItem<Eles>(
                        value: ele,
                        child: Text(ele.nameMat ?? '')
                    );
                  }).toList(),
                  onChanged: (value) async{
                    setState(() {
                      selectedElem = value;
                      // selectedProfesseur = null; // Reset the selected matière
                      showElem = true;
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
                            // showElem = true;
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

                // DropdownButtonFormField<String>(
                //   value: signe,
                //   items: [
                //     DropdownMenuItem<String>(
                //       child: Text('True'),
                //       value: "effectué",
                //     ),
                //     DropdownMenuItem<String>(
                //       child: Text('False'),
                //       value: "en attente",
                //     ),
                //   ],
                //   onChanged: (value) {
                //     setState(() {
                //       signe = value!;
                //     });
                //   },
                //   decoration: InputDecoration(
                //     filled: true,
                //     fillColor: Colors.white,
                //     hintText: "Est Signe",
                //
                //     border: OutlineInputBorder(
                //       borderSide: BorderSide.none,gapPadding: 1,
                //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
                //     ),
                //   ),
                //
                // ),

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

                    print("MatId${showElem? selectedElem!.id: widget.MId}");
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


  Future<void> UpdatCours (id,String TN,num th,DateTime date,String time, String ElemId,String ProfId) async {
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
      // "isSigned": isSigned,
    };

    if (date != null) {
      body['date'] = date.toIso8601String();
    }
// try {
  final response = await http.patch(
    Uri.parse(url),
    headers: headers,
    body: json.encode(body),
  );

  print('Status:${response.statusCode}');
  if (response.statusCode == 200) {
    // Course creation was successful
    print("Emploi Updated successfully!");
    final responseData = json.decode(response.body);
    // print("Course ID: ${responseData['cours']['_id']}");
    // You can handle the response data as needed
    setState(() {
      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              surfaceTintColor: Color(0xB0AFAFA3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),),
              elevation: 1,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Alerte de succès"),
                  Icon(Icons.fact_check_outlined, color: Colors.lightGreen,)
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
            );
          });
    });
  }
  else {
    setState(() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              surfaceTintColor: Color(0xB0AFAFA3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),),
              elevation: 1,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Alerte d\'erreur"),
                  Icon(Icons.wrong_location_outlined, color: Colors.redAccent,)
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
            );
          });
    });
  }
// }catch (error) {
//   print("Error: $error");
// }
  }

}

class TimeCalender extends StatelessWidget {
TimeCalender({required this.child
});

Widget child ;
  @override
  Widget build(BuildContext context) {
    return Theme(data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.blue,surfaceTint: Colors.white,
          secondary: Colors.black54,
        ),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                primary: Colors.black
            )
        )
    ), child: child!);
  }
}

Future<List<Elem>> fetchMatieresByCategory(String categoryId) async {
  String apiUrl = 'http://192.168.43.73:5000/categorie/$categoryId/matieres';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> matieresData = responseData['elements'];
      print(categoryId);
      print(matieresData);
      List<Elem> matieres = matieresData.map((data) => Elem.fromJson(data)).toList();
      print(matieres);
      return matieres;
    } else {
      throw Exception('Failed to fetch matières by category');
    }
  } catch (error) {
    throw Exception('Error: $error');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gestion_payements/update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Ajout.dart';
import 'constants.dart';


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
    final professeur = professeurList.firstWhere((prof) => '${prof.id}' == id, orElse: () => Professeur(id: '', nom: '',  mobile: 0, email: ''));
    print(professeur.nom);
    return professeur.nom; // Return the ID if found, otherwise an empty string

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


  TextEditingController _selectedProf = TextEditingController();
  TextEditingController _selectedMatiere = TextEditingController();
  TextEditingController _date = TextEditingController();
  TextEditingController _isSigned = TextEditingController();

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
  bool _selectedSigne = false;


  TextEditingController _searchController = TextEditingController();
  int currentPage = 1;
  int coursesPerPage = 7;
  String searchQuery = '';
  bool sortByDateAscending = true;
  bool showSigned = false;
  bool showPaid = false;
  bool courseFitsCriteria(Map<String, dynamic> course) {
    // Apply your filtering criteria here
    DateTime courseDate = DateTime.parse(course['date'].toString());
    bool isMatch = (course['prix'].toLowerCase().contains(searchQuery.toLowerCase()) || course['professeur'].toLowerCase().contains(searchQuery.toLowerCase())
        || course['isSigned'].toString().contains(searchQuery.toLowerCase()));
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
                Text("Liste de Cours",style: TextStyle(fontSize: 25),)
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
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xff0fb2ea),foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ],          ),
          SizedBox(height: 10,),
          // Display the calculated sums
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: Row(
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showSigned = !showSigned;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.only(left: 53, right: 53),
                            backgroundColor: Colors.white,foregroundColor: Colors.black54,side: BorderSide(color: Colors.black12,width: 1)),
                        child: Text('Signé'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showPaid = !showPaid;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.only(left: 55, right: 55),
                            backgroundColor: Colors.white,foregroundColor: Colors.black54,side: BorderSide(color: Colors.black12,width: 1)),
                        child: Text('Payé'),
                      ),
                    ],
                  ),
                  SizedBox(width: 10),
                  Container(width: MediaQuery.of(context).size.width /8,height: 45,
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
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
                        child: Icon(sortByDateAscending ? Icons.arrow_upward : Icons.arrow_downward,color: sortByDateAscending ? Colors.black26: Colors.black87,),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),


          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
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
                    margin: EdgeInsets.only(left: 3),
                    child: Card(
                      margin: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          showCheckboxColumn: true,
                          showBottomBorder: true,
                          // sortColumnIndex: 1,
                          // sortAscending: true,
                          headingRowHeight: 50,
                          columnSpacing: 13,
                          horizontalMargin: 3,
                          // border: TableBorder(verticalInside: BorderSide(width: 1.5)),
                          dataRowHeight: 50,
                          headingTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Set header text color
                          ),
                          // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFF0C2FDA)), // Set row background color
                          columns: [
                            // if ( showSigned)
                            if (!showPaid)
                              DataColumn(label: Text('Signé')),
                            // if (widget.role == "admin" && showPaid)
                            if (widget.role == "admin"&& !showSigned )
                              DataColumn(label: Text('Paié')),
                            DataColumn(label: Text('Date')),
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
                                    (!showPaid || widget.courses[index]['isPaid'] == 'oui'))
                                DataRow(
                                  onLongPress: () =>
                                      _showCourseDetails(context, widget.courses[index]),

                                  cells: [
                                    // DataCell(Text('${index + 1}',style: TextStyle(fontSize: 18),)), // Numbering cell
                                    // if ( showSigned)
                                    if (!showPaid)
                                      DataCell(
                                        Icon( widget.courses[index]['isSigned'] =="oui"?  Icons.check:Icons.close_outlined,
                                          color: widget.courses[index]['isSigned']=="oui"? Colors.green: Colors.red,size: 20,),
                                      ),
                                    if (widget.role == "admin" && !showSigned)
                                    // if (widget.role == "admin")
                                      DataCell(
                                        InkWell(onTap: (){
                                          payeCours(
                                              widget.courses[index]['_id'],
                                              'oui'
                                          );

                                          setState(() {
                                            Navigator.pop(context);
                                          });
                                        },
                                          child: Icon( widget.courses[index]['isPaid']=="oui"? Icons.check:Icons.close_outlined,
                                              color: widget.courses[index]['isPaid']=="oui"? Colors.green: Colors.red, size: 20),
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
                                    ),)),),
                                    DataCell(Container(width: 55,child: Text('${widget.courses[index]['prix']}',style: TextStyle(
                                      color: Colors.black,
                                    ),)),
                                      // onTap: () =>
                                      //     _showCourseDetails(context, widget.courses[index])
                                    ),
                                    DataCell(
                                      Center(child: Container(width: 25, child: Text('${widget.courses[index]['TH']}',style: TextStyle(
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
                            DataRow(
                              cells: [
                                if (!showPaid)
                                  DataCell(Icon(Icons.title_outlined)
                                  ),
                                if (widget.role == "admin"&& !showSigned)
                                  DataCell(
                                   Icon(Icons.title_outlined)
                                  ),


                                DataCell(
                                  (widget.dateDeb != null && widget.dateFin != null)?
                                  Text(' ${coursesNum}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900,fontStyle: FontStyle.italic),):
                                  Center(child: Text('NBC: ${widget.coursNum}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900,fontStyle: FontStyle.italic))),

                                ),
                                DataCell(
                                  Text('Eq. CM: ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900,fontStyle: FontStyle.italic),),

                                ),
                                DataCell(
                                  Text('${totalType}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900,fontStyle: FontStyle.italic),),

                                ),
                                DataCell(
                                  // (widget.dateDeb != null && widget.dateFin != null)?
                                    Text('MT',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900,fontStyle: FontStyle.italic),)
                                  // Text('Montant Total : ${widget.sommeTV}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400)),
                                ),
                               DataCell(
                                      Text('${somme}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900,fontStyle: FontStyle.italic),)
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

      floatingActionButton: FloatingActionButton.extended(
        // heroTag: 'uniqueTag',
        tooltip: 'Ajouter une Cours',backgroundColor: Colors.white,
        label: Row(
          children: [Icon(Icons.add,color: Colors.black,)],
        ),
        onPressed: () => _displayTextInputDialog(context),

      ),

      // bottomNavigationBar: BottomNav(),
    );

  }

  Future<void> _showCourseDetails(BuildContext context, Map<String, dynamic> course) {
    return showModalBottomSheet(
        context: context,
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

                Row(
                  children: [
                    Row(
                      children: [
                        Text('CM:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),

                        SizedBox(width: 10,),
                        Text('${course['CM']}',
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
                        Text('TP:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),

                        SizedBox(width: 10,),
                        Text('${course['TD']}',
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
                        Text('TD:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            // color: Colors.lightBlue
                          ),),

                        SizedBox(width: 10,),
                        Text('${course['TP']}',
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
                    Text('${course['matiere_prix']* course['TH']}',
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
                      'Oui':'pas encore',
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
                            'Oui':'pas encore',
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
                      onPressed: () async{
                        setState(() {
                          Navigator.pop(context);
                        });
                        return showDialog(
                          context: context,
                          builder: (context) {
                            return UpdateCoursDialog(courses: course,);
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
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),elevation: 1,
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
    return showDialog(
      context: context,
      builder: (context) {
        return AddCoursDialog();
      },
    );
  }

}



class Course {
  final String id;
  final List<Type> types;
  final DateTime date;
  final int debit;
  final String professeur;
  final String matiere;
  final num? TH;
  final num? CM;
  final num? TP;
  final num? TD;
  final num? prix;
  final num? somme;
  final bool isSigned;
  final bool isPaid;
  final DateTime? updatedAt;

  Course({
    required this.id,
    required this.types,
    required this.date,
    required this.debit,
    required this.professeur,
    required this.matiere,
    this.somme,
    this.TH,
    this.CM,
    this.TD,
    this.TP,
    this.prix,
    required this.isSigned,
    required this.isPaid,
    this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['_id'],
      types: List<Type>.from(json['types'].map((type) => Type.fromJson(type))),
      date: DateTime.parse(json['date']),
      debit: json['debit'],
      professeur: json['professeur'],
      matiere: json['matiere'],
      TH: json['TH'],
      CM: json['CM'],
      TD: json['TD'],
      somme: json['somme'],
      TP: json['TP'],
      isSigned: json['isSigned'],
      isPaid: json['isPaid'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class Type {
  final String name;
  final double nbh;
  final String id;

  Type({
    required this.name,
    required this.nbh,
    required this.id,
  });

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      name: json['name'],
      nbh: json['nbh'],
      id: json['_id'],
    );
  }
}



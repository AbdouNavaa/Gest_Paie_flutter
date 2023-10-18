import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gestion_payements/update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Ajout.dart';


class CoursesPage extends StatefulWidget {
  final List<dynamic> courses;
  final int coursNum;
  final num heuresTV;
  final String role;
  final num sommeTV;
  DateTime? dateDeb;
  DateTime? dateFin;
// Calculate the sums for filtered courses

  CoursesPage({required this.courses, required this.coursNum, required this.heuresTV, required this.sommeTV, required this.role}) {}



  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  double totalType = 0;
// Calculate totalType based on applied date filters and pagination
  void calculateTotalType() {
    if ((widget.dateDeb != null && widget.dateFin != null) ) {
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
    }
    else {
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

  TextEditingController _selectedProf = TextEditingController();
  TextEditingController _selectedMatiere = TextEditingController();
  TextEditingController _date = TextEditingController();
  TextEditingController _isSigne = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
    }

  }
  bool _selectedSigne = false;


  TextEditingController _searchController = TextEditingController();
  int currentPage = 1;
  int coursesPerPage = 7;
  String searchQuery = '';
  bool sortByDateAscending = true;

  bool courseFitsCriteria(Map<String, dynamic> course) {
    // Apply your filtering criteria here
    DateTime courseDate = DateTime.parse(course['date'].toString());
    bool isMatch = (course['matiere'].toLowerCase().contains(searchQuery.toLowerCase()) || course['professeur'].toLowerCase().contains(searchQuery.toLowerCase()));
    // || course['isSigne'].contains(searchQuery.toLowerCase()));

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
                TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Icon(Icons.arrow_back_ios_new_outlined,size: 20,),
                  style: TextButton.styleFrom(
                    backgroundColor:Colors.white ,
                    foregroundColor:Colors.black ,
                    // elevation: 10,
                    // shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black26)),
                  ),
                ),
                SizedBox(width: 30,),
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
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0C2FDA)
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
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0C2FDA),foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ],          ),
          SizedBox(height: 10,),
          // Display the calculated sums
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(width: MediaQuery.of(context).size.width /1.25,height: 50,
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
                Container(width: MediaQuery.of(context).size.width /10,height: 40,color: sortByDateAscending ? Color(0xFF0C2FDA): Color(
                    0x10000000),
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
                    child: Icon(sortByDateAscending ? Icons.arrow_upward : Icons.arrow_downward,color: sortByDateAscending ? Colors.white: Colors.black87,),
                  ),
                ),

              ],
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
                    // margin: EdgeInsets.only(left: 10),
                    child: DataTable(
                      showCheckboxColumn: true,
                      showBottomBorder: true,
                      // sortColumnIndex: 1,
                      // sortAscending: true,
                      headingRowHeight: 50,
                      border: TableBorder.all(color: Colors.black12, width: 2),
                      columnSpacing: 20,
                      horizontalMargin: 3,
                      // border: TableBorder(verticalInside: BorderSide(width: 1.5)),
                      dataRowHeight: 50,
                      headingTextStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black, // Set header text color
                      ),
                      // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xFF0C2FDA)), // Set row background color
                      columns: [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Prof')),
                        DataColumn(label: Text('Matiere')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Eq.CM')),
                        DataColumn(label: Text('Prix')),
                        DataColumn(label: Text('Signé')),
                        if (widget.role == "admin")
                        DataColumn(label: Text('Payé')),
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
                                DataCell(Text('${index + 1}',style: TextStyle(fontSize: 18),)), // Numbering cell
                                DataCell(Container(width: 50,child: Text('${widget.courses[index]['professeur']}')),),
                                DataCell(Container(width: 50,child: Text('${widget.courses[index]['matiere']}')),
                                  // onTap: () =>
                                  //     _showCourseDetails(context, widget.courses[index])
                                ),
                                DataCell(
                                  Text(
                                    '${DateFormat('dd/M ').format(
                                      DateTime.parse(widget.courses[index]['date'].toString()).toLocal(),
                                    )}',
                                  ),
                                ),
                                DataCell(
                                  Center(child: Text('${widget.courses[index]['TH']}')),
                                ),
                                DataCell(
                                  Text('${widget.courses[index]['somme']}'),
                                ),
                                DataCell(
                                  Icon( widget.courses[index]['isSigne']? Icons.verified:Icons.cancel,
                                      color: widget.courses[index]['isSigne']? Colors.green: Colors.red),
                                ),
                                if (widget.role == "admin")
                                DataCell(
                                  Icon( widget.courses[index]['isPaid']? Icons.verified:Icons.cancel,
                                      color: widget.courses[index]['isPaid']? Colors.green: Colors.red),
                                ),
                                DataCell(
                                  Row(
                                    // mainAxisSize: MainAxisSize.min,
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
                                                return UpdateCoursDialog(courses: widget.courses[index],);
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
                                      Container(
                                        width: 35,
                                        child: TextButton(
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
                                                        DeleteCours(widget.courses[index]['_id']);
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

                                          child: Icon(Icons.delete, color: Colors.red),
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
            height: 600,
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
                      Text('${DateFormat(' HH:mm').format(DateTime.parse(course['date'].toString()).toLocal())}',
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
                      Text('${DateFormat(' HH:mm').format(DateTime.parse(course['date'].toString()).toLocal().add(Duration(minutes: (( course['CM']+course['TP']+course['TD'] )* 60).toInt())))}',
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
                        Text('${course['TP']}',
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
                        Text('${course['TD']}',
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
                    Text('${course['prix']* course['TH']}',
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
                      '${course['isSigne']}',
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
  final bool isSigne;
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
    required this.isSigne,
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
      isSigne: json['isSigne'],
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



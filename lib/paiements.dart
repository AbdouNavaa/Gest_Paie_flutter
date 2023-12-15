import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Ajout.dart';

class Paiements extends StatefulWidget {
  final List<dynamic> courses;

  // final String ProfId;
  // final String ProfName;
  DateTime? dateDeb;
  DateTime? dateFin;
// Calculate the sums for filtered courses

  Paiements({required this.courses,}) {}

  @override
  State<Paiements> createState() => _PaiementsState();
}

class _PaiementsState extends State<Paiements> {
  double totalType = 0;
  double somme = 0;
  void calculateTotalType() {
    if (widget.dateDeb != null && widget.dateFin != null) {
      // If date filters are applied
      totalType = widget.courses.where((course) {
        DateTime courseDate = DateTime.parse(course['date'].toString());
        return (course['isSigned'] != "pas encore" && course['isPaid'] != "pas encore") && // Filter courses with signs
            (courseDate.isAtSameMomentAs(widget.dateDeb!.toLocal()) || (courseDate.isAfter(widget.dateDeb!.toLocal()) &&
                courseDate.isBefore(widget.dateFin!.toLocal().add(Duration(days: 1)))));
      }).map((course) => double.parse(course['TH'].toString())).fold(0, (prev, amount) => prev + amount);

      somme = widget.courses.where((course) {
        DateTime courseDate = DateTime.parse(course['date'].toString());
        return ( course['isSigned'] != "pas encore" && course['isPaid'] != "pas encore") && // Filter courses with signs
            (courseDate.isAtSameMomentAs(widget.dateDeb!.toLocal()) ||
                (courseDate.isAfter(widget.dateDeb!.toLocal()) &&
                    courseDate.isBefore(
                        widget.dateFin!.toLocal().add(Duration(days: 1)))));
      }).map((course) => double.parse(course['somme'].toString())).fold(0, (prev, amount) => prev + amount);
    } else if ((widget.dateDeb != null && widget.dateFin == null) || (widget.dateDeb == null && widget.dateFin != null)) {
      // If date filters are applied
      totalType = 0;
      somme = 0;
    } else {
      // If no date filters are applied
      int startIndex = (currentPage - 1) * coursesPerPage;
      int endIndex = startIndex + coursesPerPage - 1;
      totalType = widget.courses.skip(startIndex).take(coursesPerPage).where((course) =>
      (course['signe'] != null && course['signe'] != '')).map((course) => double.parse(course['TH'].toString())).fold(0, (prev, amount) => prev + amount);
      somme = widget.courses.skip(startIndex).take(coursesPerPage).where((course) =>
      (course['signe'] != null && course['signe'] != '')).map((course) => double.parse(course['TH'].toString())).fold(0, (prev, amount) => prev + amount);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.courses;
    // groupCoursesByProfesseur();
    // calculateProfesseurTotals();
    fetchProfs().then((data) {
      setState(() {
        professeurList = data; // Assigner la liste renvoyée par emploiesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
  }

  Map<String, Map<String, dynamic>> professeurData = {};

  List<Professeur> professeurList = [];

  Professeur getProfesseurIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = professeurList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>
        Professeur(id: '', nom: '',  mobile: 0, email: '', ));
    print(professeurList);
    return professeur; // Return the ID if found, otherwise an empty string

  }

  void groupCoursesByProfesseur(DateTime? Deb, DateTime? Fin) {
    professeurData.clear(); // Efface les données existantes à chaque nouvel appel

    for (var course in widget.courses) {
      String profId = course['professeur_id'];
      DateTime courseDate = DateTime.parse(course['date'].toString());


      if (course['isSigned'] != "pas encore" && course['isPaid'] != "pas encore" &&
          (Deb == null || courseDate.isAfter(Deb!.toLocal())) &&
          (Fin == null || courseDate.isBefore(Fin!.toLocal().add(Duration(days: 1))))) {
          if (!professeurData.containsKey(profId)) {
            // Initialiser les données du professeur
            professeurData[profId] = {
              'professeur': course['professeur'],
              'email': course['email'],
              'TH_total': 0.0,
              'somme_total': 0.0,
            };
          }

          // Mettre à jour les valeurs pour 'TH_total' et 'somme_total'
          professeurData[profId]!['TH_total'] += double.parse(course['TH'].toString());
          professeurData[profId]!['somme_total'] += double.parse(course['somme'].toString());
        }
      // }
    }

    // Filtrer les professeurs avec 'TH_total' égal à 0
    if (Deb != null || Fin != null) {
      professeurData.removeWhere((key, value) => value['TH_total'] == 0.0);
    }
  }


  DateTime? _selectedDateDeb;
  DateTime? _selectedDateFin;
  int currentPage = 1;
  int coursesPerPage = 5;
  String searchQuery = '';
  bool sortByDateAscending = true;
  bool isSigned = false;




  @override
  Widget build(BuildContext context) {
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
                      groupCoursesByProfesseur(widget.dateDeb!, null);
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
                      groupCoursesByProfesseur(widget.dateDeb,widget.dateFin);
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
                      columnSpacing: 10,
                      dataRowHeight: 50,
                      headingTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Set header text color
                      ),
                      // headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xff0fb2ea)), // Set row background color
                      columns: [
                        DataColumn(label: Text('Professeur')),
                        DataColumn(label: Text('Banque')),
                        DataColumn(label: Text('Compte')),
                        DataColumn(label: Text('VHoraire')),
                        DataColumn(label: Text('Montant')),
                      ],
                      rows:
                      professeurData.entries.map(
                              (entry) {
                        String profId = entry.key;
                        Map<String, dynamic> profData = entry.value;


                        return DataRow(
                          cells: [
                            DataCell(Text(profData['professeur'].toString())),
                            DataCell(Text(getProfesseurIdFromName(profId).Banque.toString())),
                            DataCell(Text(getProfesseurIdFromName(profId).account.toString())),
                            DataCell(Text(profData['TH_total'].toString())),
                            DataCell(Text(profData['somme_total'].toString())),
                          ],
                        );

                      }).toList(),

                    ),
                  ),
                ),
              ),
            ),
          ),




        ],
      ),


    );

  }
}


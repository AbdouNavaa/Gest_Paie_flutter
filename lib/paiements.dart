import 'dart:convert';
import 'dart:typed_data';
import 'package:arabic_font/arabic_font.dart';
import 'package:dartarabic/dartarabic.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/professeures.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/services.dart';

import 'Cours.dart';
import 'home_screen.dart';

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


  DateTime defaultDateDeb = DateTime(2024, 4, 1);
  DateTime defaultDateFin = DateTime(2024, 4, 1);
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

    fetchPaie().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Categoryesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

    // Initialise les dates par défaut
    widget.dateDeb = defaultDateDeb;
    widget.dateFin = defaultDateFin;

    // Groupe les cours en utilisant les dates par défaut
    ( _selectedDateDeb != null ||_selectedDateFin != null) ? groupCoursesByProfesseur(widget.dateDeb!, widget.dateFin!)
        :
    groupCoursesByProfesseur(_selectedDateDeb, _selectedDateFin);
  }

  List<Paies>? filteredItems;
  void DeletePaie(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/paiement/$id' ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchPaie().then((data) {
        setState(() {
          filteredItems = data;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des Matieres: $error');
      });

    }

  }

  @override
  Map<String, Map<String, dynamic>> professeurData = {};
  List<String> selectedPayments = [];

  List<Professeur> professeurList = [];

  Professeur getProfesseurIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = professeurList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>
        Professeur(id: '',   user: '',  ));
    print(professeur.banque);
    return professeur; // Return the ID if found, otherwise an empty string

  }

  void groupCoursesByProfesseur(DateTime? Deb, DateTime? Fin) {
    professeurData.clear(); // Efface les données existantes à chaque nouvel appel

    totalType = 0;
    somme = 0;
    for (var course in widget.courses) {
      String profId = course['professeur'];
      // String profId = course['professeur']['_id'];
      DateTime courseDate = DateTime.parse(course['date'].toString());


      if (course['isSigned'] == "effectué" && course['isPaid'] == "en attente" &&
          (Deb == null || courseDate.isAfter(Deb!.toLocal().subtract(Duration(days: 1)))) &&
          (Fin == null || courseDate.isBefore(Fin!.toLocal().add(Duration(days: 1))))) {
          if (!professeurData.containsKey(profId)) {
            // Initialiser les données du professeur
            professeurData[profId] = {
              'professeur': ("${course['nom']} ${course['prenom']}").capitalize,
              'email': course['email'],
              'th_total': 0.0,
              'somme_total': 0.0,
              'NbC': 0.0,
            };
          }

          // Mettre à jour les valeurs pour 'th_total' et 'somme_total'
          professeurData[profId]!['th_total'] += double.parse(course['th'].toString());
          totalType += double.parse(course['th'].toString());
          professeurData[profId]!['somme_total'] += double.parse(course['somme'].toString());
          somme += double.parse(course['somme'].toString());
          professeurData[profId]!['NbC'] += professeurData.length;
        }
      // }
    }

    // Filtrer les professeurs avec 'th_total' égal à 0
    if (Deb != null || Fin != null) {
      professeurData.removeWhere((key, value) => value['th_total'] == 0.0);

    }
  }
  // void AddPaieMultiple(List<String> selectedPayments, DateTime dateDeb, DateTime dateFin, num? nbh,num? nbc,num? mt,) {
  //   for (String profId in selectedPayments) {
  //     AddPaie(profId, dateDeb, dateFin,nbh,nbc,mt);
  //   }
  // }


  DateTime? _selectedDateDeb;
  DateTime? _selectedDateFin;
  int currentPage = 1;
  int coursesPerPage = 5;
  String searchQuery = '';
  bool sortByDateAscending = true;
  bool isSigned = false;

  void AddPaie (  List<String> prof,DateTime? fromDate,DateTime? toDate,) async {

    // Check if the prix parameter is provided, otherwise use the default value of 100
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/paiement/many'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "ids":prof,
        // "nbh":nbh,
        // "nbc":nbc,
        // "totalMontant":mt,
        "fromDate":fromDate?.toIso8601String() ,
        "fin": toDate?.toIso8601String() ,
      }),
    );
    print("PaiStat${response.statusCode}");
    if (response.statusCode == 200) {
      print('Paiement  ajoute avec succes');

      // setState(() {
        // Navigator.pop(context);
      // });
    } else {
      print("Il y a un Erreur");
    }
  }

  bool showDownLoad = false;
  bool showPaid = false;
  bool showRef = false;
  bool showConf = false;

  pw.Widget _contentTable(pw.Context context) {
    const tableHeaders = [
      'Professeur',
      'Banque',
      'Numero compte',
      'Volume horaire',
      'Montant (MRU)',
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.white),
      columnWidths: {
        0: pw.IntrinsicColumnWidth(),
        1: pw.IntrinsicColumnWidth(),
        2: pw.IntrinsicColumnWidth(),
        3: pw.IntrinsicColumnWidth(),
        4: pw.IntrinsicColumnWidth(),
      },
      children: [
        pw.TableRow(decoration: pw.BoxDecoration(color: PdfColors.black),
          children: tableHeaders
              .map(
                (header) => pw.Container(
              padding: const pw.EdgeInsets.all(5),
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                header,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                  // background: pw.BoxDecoration(color: PdfColors.green),
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          )
              .toList(),
        ),
        for (var entry in professeurData.entries)
          pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  entry.value['professeur'].toString(),
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  getProfesseurIdFromName(entry.key).banque.toString(),
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  getProfesseurIdFromName(entry.key).compte.toString(),
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  entry.value['th_total'].toString(),
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  entry.value['somme_total'].toString(),
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'Montant Total ',
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                  ),
                ),
              ),

              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '',
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '',
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  totalType.toString(),
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                alignment: pw.Alignment.center,
                child: pw.Text(
                 somme.toString(),
                  style: pw.TextStyle(
                    color: PdfColors.black,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();

    // Ajoutez une page de garde
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Container(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                // En-tête
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('République Islamique de Mauritanie'),
                        pw.Text('Ministère de l\'Enseignement Supérieur \n et de la Recherche Scientifique'),
                        pw.Text('Institut Supérieur du Numérique'),
                      ],
                    ),
                    // pw.Image(pw.MemoryImage("assets/categ2.png")), // Remplacez yourImageData par les données de votre image
                    pw.SizedBox(width: 10),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(DartArabic.normalizeLetters('الجمهورية الاسلامية الموريتانية',), textDirection: pw.TextDirection.ltr,),
                        // style: GoogleFonts.notoNaskhArabic(
                        //   color: Colors.black,
                        // )
                        pw.Text('وزارة التعليم العالي \n و البحث العلمي', textDirection: pw.TextDirection.rtl),
                        pw.Text('المعهد العالي للعلوم الرقمية', textDirection: pw.TextDirection.ltr),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),
                // Titre
                pw.Text(
                  'Les état de paiement du ${_selectedDateDeb == null ? DateFormat('yyyy/MM/dd').format(widget.dateDeb!): DateFormat('yyyy/MM/dd').format(_selectedDateDeb!)} '
                      'au ${ _selectedDateFin == null ?DateFormat('yyyy/MM/dd').format(widget.dateFin!):DateFormat('yyyy/MM/dd').format(_selectedDateFin!)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 30),
                // Tableau

                _contentTable(context),
                // _footTable(context),
              ],
            ),
          );
        },
      ),
    );

    // Retournez le contenu du fichier PDF sous forme de Uint8List
    return await pdf.save();
  }

  Future<void> savePdf() async {
    // Appelez la fonction generatePdf pour obtenir le contenu du PDF
    final Uint8List generatedPdf = await generatePdf();

    // Obtenez le répertoire de documents pour enregistrer le fichier PDF
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/paiements.pdf');

    // Écrivez le fichier PDF sur le système de fichiers
    await file.writeAsBytes(generatedPdf);

    // Ouvrez le fichier PDF
    OpenFile.open(file.path);
  }




  Future<Uint8List> generateExcel() async {
    final excel.Excel excelDoc = excel.Excel.createExcel();
    final excel.Sheet sheetObject = excelDoc['Sheet1'];

    // Ajoutez les en-têtes
    sheetObject.appendRow([ 'Les état de paiement du ${_selectedDateDeb == null ? DateFormat('yyyy/MM/dd').format(widget.dateDeb!): DateFormat('yyyy/MM/dd').format(_selectedDateDeb!)} '
        'au ${ _selectedDateFin == null ?DateFormat('yyyy/MM/dd').format(widget.dateFin!):DateFormat('yyyy/MM/dd').format(_selectedDateFin!)}',
    ]);
    sheetObject.appendRow(['Professeur', 'Banque', 'Numero compte', 'Volume horaire', 'Montant (MRU)'],);

    // Ajoutez les données
    for (var entry in professeurData.entries) {
      sheetObject.appendRow([
        entry.value['professeur'].toString(),
        getProfesseurIdFromName(entry.key).banque.toString(),
        getProfesseurIdFromName(entry.key).compte.toString(),
        entry.value['th_total'].toString(),
        entry.value['somme_total'].toString(),
      ]);
    }

    // Ajoutez la ligne pour le total
    sheetObject.appendRow(['Montant Total', '', '', totalType.toString(), somme.toString()]);

    // Convertissez le fichier Excel en données binaires
    final List<int>? excelBytes = excelDoc.save();

    return Uint8List.fromList(excelBytes!);
  }

  Future<void> saveExcel() async {
    // Appelez la fonction generateExcel pour obtenir le contenu du fichier Excel
    final Uint8List generatedExcel = await generateExcel();

    // Obtenez le répertoire de documents pour enregistrer le fichier Excel
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/paiements.xlsx');

    // Écrivez le fichier Excel sur le système de fichiers
    await file.writeAsBytes(generatedExcel);

    // Ouvrez le fichier Excel
    OpenFile.open(file.path);
  }


  Future<List<List<String>>> readExcelData(String path) async {
    // Ouvrez le fichier Excel.
    var bytes = await File(path).readAsBytes();
    var exc = excel.Excel.decodeBytes(bytes);

    // Accédez à la première feuille de calcul.
    var firstSheet = exc.tables.keys.first;
    var table = exc.tables[firstSheet]!;

    // Créez une liste pour stocker les données.
    List<List<String>> data = [];

    // Parcourir les tableaux.
    for (var row in table.rows) {
      // Ignorer les premières lignes jusqu'à la ligne "Heure:"
      if (row == table.rows.first) continue;

      // Créer une nouvelle liste pour stocker les données du tableau.
      List<String> rowData = [];

      // Ajouter les données du tableau à la liste.
      for (var cell in row) {
        rowData.add(cell?.value?.toString() ?? '');
      }

      // Ajouter la liste de données à la liste principale.
      data.add(rowData);
    }

    // Retourner la liste de données.
    return data;
  }




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
                // SizedBox(width: 30,),
                Text("Paiements",style: TextStyle(fontSize: 20),)
              ],
            ),
          ),
          Divider(),


          // Padding(padding: EdgeInsets.all(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  DateTime? selectedDateDeb = await showDatePicker(
                    context: context,
                    initialDate: widget.dateDeb ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                      builder: (context, child){
                      return CalenderStyle(child: child!,);
                      }
                      );

                  if (selectedDateDeb != null) {
                    setState(() {
                      _selectedDateDeb = selectedDateDeb.toUtc();
                    });
                      groupCoursesByProfesseur(_selectedDateDeb, null);
                  }
                },
                child:_selectedDateDeb == null ?
                Row(
                  children: [
                    Text( 'Date Deb' ),
                 SizedBox(width: 20,),
                  Icon(Icons.date_range)
                  ],
                )
                    : Text(DateFormat('yyyy/MM/dd').format(_selectedDateDeb!)),
                style: TextButton.styleFrom(
                  // backgroundColor: Colors.blue,
                  // surfaceTintColor: Color(0xB0AFAFA3),

                  // side: BorderSide(color: Colors.black26),
                  foregroundColor: Colors.black, textStyle: TextStyle(fontWeight: FontWeight.bold),
                  padding:widget.dateDeb != null ? EdgeInsets.only(left: 20,right: 20): EdgeInsets.only(left: 20,right: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              TextButton(
                onPressed: () async {
                  DateTime? selectedDateFin = await showDatePicker(
                    context: context,
                    initialDate: widget.dateFin ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                      builder: (context, child){
                                                            return CalenderStyle(child: child!,);
                      }
                      );

                  if (selectedDateFin != null) {
                    setState(() {
                      _selectedDateFin = selectedDateFin.toUtc();
                    });
                      groupCoursesByProfesseur(_selectedDateDeb!, _selectedDateFin);
                  }
                },
                child:_selectedDateFin == null ?
                  Row(
                  children: [
                    Text(  'Date Fin' ),
                  SizedBox(width: 20,),
                  Icon(Icons.date_range)
                  ],
                )
        : Text(DateFormat('yyyy/MM/dd').format(_selectedDateFin!)),
                // child: Text(_selectedDateFin == null ? DateFormat('yyyy/MM/dd').format(widget.dateFin!) :DateFormat('yyyy/MM/dd').format(_selectedDateFin!) ),
                style: TextButton.styleFrom(
                  // backgroundColor: Colors.blue,
                  // side: BorderSide(color: Colors.black26),
                  foregroundColor: Colors.black, textStyle: TextStyle(fontWeight: FontWeight.bold),
                  padding:widget.dateFin != null ? EdgeInsets.only(left: 20,right: 20): EdgeInsets.only(left: 20,right: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),


          // Padding(padding: EdgeInsets.all(10)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0),
                      ),
                    ),
                    // margin: EdgeInsets.only(left: 10),
                    child: DataTable(
                      showCheckboxColumn: true,
                      showBottomBorder: true,
                      horizontalMargin: 1,
                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white70),
                      dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
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
                        DataColumn(label: Text('VH')),
                        // DataColumn(label: Text('NbC')),
                        DataColumn(label: Text('MT')),
                        // DataColumn(label: Text('Action')),
                        DataColumn(
                          label: Text('Action'),
                          onSort: (columnIndex, ascending) {
                            // Code pour gérer la sélection ici
                          },
                        ),
                      ],
                      rows:
                      professeurData.entries.map(
                              (entry) {
                            String profId = entry.key;
                            Map<String, dynamic> profData = entry.value;


                            return DataRow(
                              cells: [
                                DataCell(
                                    Container(width: 65,margin: EdgeInsets.only(left: 5),
                                        child: Text(profData['professeur'].toString().capitalize!))),
                                DataCell(Text(getProfesseurIdFromName(profId).banque.toString())),
                                DataCell(Container(width: 75,child: Text(getProfesseurIdFromName(profId).compte.toString()))),
                                DataCell(Text(profData['th_total'].toString())),
                                // DataCell(Text(profData['NbC'].toString())),
                                DataCell(Text(profData['somme_total'].toString())),
                                // DataCell(
                                //   Container(
                                //     width: 35,
                                //     child: TextButton(
                                //       onPressed: () {
                                //         _selectedDateDeb == null || _selectedDateFin == null ?
                                //         AddPaie(profId, widget.dateDeb, widget.dateFin)
                                //         :AddPaie(profId, _selectedDateDeb, _selectedDateFin);
                                //         print(profId);
                                //         setState(() {
                                //           Navigator.of(context).pop();
                                //           showDialog(
                                //               context: context,
                                //               builder: (BuildContext context) {
                                //                 return AlertDialog(
                                //                   surfaceTintColor: Color(0xB0AFAFA3),
                                //                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
                                //                   title: Row(
                                //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                //                     children: [
                                //                       Text("Alert de Succes"),
                                //                       Icon(Icons.fact_check_outlined,color: Colors.lightGreen,)
                                //                     ],
                                //                   ),
                                //                   content: Text(
                                //                       "Le paiement est en Cours il faut que son Profeseur va Confirmer"),
                                //
                                //                   actions: [
                                //                     TextButton(
                                //                       child: Text("Ok"),
                                //                       onPressed: () {
                                //                         Navigator.of(context).pop();
                                //                       },
                                //                     ),
                                //
                                //                   ],
                                //
                                //                 );});
                                //         });
                                //         print('Id: ${profId} De: ${widget.dateDeb} Vers: ${widget.dateFin}');
                                //       },// Disable button functionality
                                //
                                //       child: Icon(Icons.panorama_fish_eye, color: Colors.black54),
                                //       style: TextButton.styleFrom(
                                //         primary: Colors.white,
                                //         elevation: 0,
                                //         // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                DataCell(
                                  Checkbox(
                                    value: selectedPayments.contains(profId),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value != null && value) {
                                          selectedPayments.add(profId);
                                        } else {
                                          selectedPayments.remove(profId);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );

                          }).toList(),


                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width +35,
                    height: 30,
                    decoration: BoxDecoration(
                      // color: Colors.blue.shade100,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    // margin: EdgeInsets.only(left: 10,top: 20),
                    child: Row(
                      children: [
                        Text('Totals', style: TextStyle(fontWeight: FontWeight.bold),),

                        SizedBox(width: 232,),
                        (widget.dateDeb != null && widget.dateFin != null)?
                        Text('${totalType}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)
                            :Text('${totalType}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),),

                        SizedBox(width: 11,),

                        (widget.dateDeb != null && widget.dateFin != null)?
                        Container(child: Text('${somme}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400)))
                            :Text('${somme}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),)

                      ],
                    )
                  ),

                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Sélectionnez tous les paiements
                    selectedPayments = professeurData.keys.toList();
                  });
                },
                child: Text('Sélectionner tous'),
                style: ElevatedButton.styleFrom(
                  surfaceTintColor: Colors.white,
                  foregroundColor: Colors.black,
                  // side: BorderSide(color: Colors.black38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  // padding: EdgeInsets.only(left: 20,right: 20),
                  backgroundColor: Colors.white,
                  //   foregroundColor: Colors.black,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),

              ),
              ElevatedButton(
                onPressed: () {
                  // Confirmer et ajouter les paiements sélectionnés
                  if (selectedPayments.length == 0){
                    buildShowNullDialog(context);
                  }

                  else{
                    print('Deb${widget.dateDeb}');
                    _selectedDateDeb == null || _selectedDateFin == null ?
                    AddPaie(selectedPayments, widget.dateDeb!, widget.dateFin!,):
                    AddPaie(selectedPayments, _selectedDateDeb!, _selectedDateFin!);
                    // Remettre la liste de sélection à zéro
                    // setState(() {
                    //   // selectedPayments = [];
                    //   print('Deb1${selectedPayments}');
                    //
                    //   Navigator.of(context).pop();
                    // });
                    setState(() {
                      selectedPayments = [];
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
                                  "l\'operation est effectuée avec succès"),
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


                },
                child: Text('Confirmer la sélection'),
                style: ElevatedButton.styleFrom(
                  surfaceTintColor: Colors.white,
                  foregroundColor: Colors.black,
                  // side: BorderSide(color: Colors.black38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  backgroundColor: Colors.white,
                  //   foregroundColor: Colors.black,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),

              ),
            ],
          ),

          // TextButton(
          //   onPressed: () {
          //     // Confirmer et ajouter les paiements sélectionnés
          //     print('Deb${widget.dateDeb}');
          //     _selectedDateDeb == null || _selectedDateFin == null ?
          //     //         AddPaie(profId, widget.dateDeb, widget.dateFin)
          //     //         :AddPaie(profId, _selectedDateDeb, _selectedDateFin);
          //     //
          //     AddPaieMultiple(selectedPayments, widget.dateDeb!, widget.dateFin!):
          //     AddPaieMultiple(selectedPayments, _selectedDateDeb!, _selectedDateFin!);
          //     // Remettre la liste de sélection à zéro
          //     setState(() {
          //       selectedPayments = [];
          //       Navigator.of(context).pop();
          //     });
          //   },
          //   child: Text('Confirmer la sélection'),
          //   style: TextButton.styleFrom(
          //     side: BorderSide(color: Colors.black26),
          //     // padding: EdgeInsets.only(left: 50,right: 50),
          //     foregroundColor: Colors.black, textStyle: TextStyle(fontWeight: FontWeight.bold),
          //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //   ),
          // ),

          Padding(padding: EdgeInsets.all(50)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: ()  {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EtatPaiemens(courses: widget.courses)));

                },
                child: Text('Les Etats'),
                style: ElevatedButton.styleFrom(
                  surfaceTintColor: Colors.white,
                  foregroundColor: Colors.black,
                  // side: BorderSide(color: Colors.black38),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  backgroundColor: Colors.white,
                  //   foregroundColor: Colors.black,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),

              ),
              IconButton(onPressed: (){
              setState(() {
                showDownLoad = !showDownLoad;
              });
              }, icon: Icon(Icons.file_download_sharp))
            ],
          ),

          showDownLoad?
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  await savePdf();
                },
                child: Text('Télécharger PDF'),
                style: TextButton.styleFrom(
                  side: BorderSide(color: Colors.black26),
                  padding: EdgeInsets.only(left: 20,right: 20),
                  foregroundColor: Colors.black, textStyle: TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(width: 20,),
              TextButton(
                onPressed: () async {
                  await saveExcel();
                },
                child: Text('Télécharger Excel'),
                style: TextButton.styleFrom(
                  side: BorderSide(color: Colors.black26),
                  padding: EdgeInsets.only(left: 20,right: 20),
                  foregroundColor: Colors.black, textStyle: TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ):Container(),
          // Padding(padding: EdgeInsets.all(60)),
        ],
      ),

      // bottomNavigationBar: BottomNav(),

    );

  }

  Future<dynamic> buildShowNullDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Color(0xB0AFAFA3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),elevation: 1,
          title: Text("Alert d\'erreur",style: TextStyle(color: Colors.red.shade900),),
          content: Text(
              "Il faut sélectioner quelques elements"),
          actions: <Widget>[
            TextButton(
              child: Text("Réessayez"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class EtatPaiemens extends StatefulWidget {
  final List<dynamic> courses;

  // final String ProfId;
  // final String ProfName;
  DateTime? dateDeb;
  DateTime? dateFin;
// Calculate the sums for filtered courses

  EtatPaiemens({required this.courses,}) {}

  @override
  State<EtatPaiemens> createState() => _EtatPaiemensState();
}

class _EtatPaiemensState extends State<EtatPaiemens> {
  double totalType = 0;
  double somme = 0;
  DateTime defaultDateDeb = DateTime(2023, 10, 1);
  DateTime defaultDateFin = DateTime(2024, 4, 1);
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

    fetchPaie().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Categoryesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });

    // Initialise les dates par défaut
    widget.dateDeb = defaultDateDeb;
    widget.dateFin = defaultDateFin;

    // Groupe les cours en utilisant les dates par défaut
    groupCoursesByProfesseur(widget.dateDeb, widget.dateFin);
  }

  List<Paies>? filteredItems;
  void DeletePaie(id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);

    var response = await http.delete(Uri.parse('http://192.168.43.73:5000/paiement/$id' ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // body: jsonEncode(regBody)
    );

    var jsonResponse = jsonDecode(response.body);
    print(response.statusCode);
    if(response.statusCode ==200){
      fetchPaie().then((data) {
        setState(() {
          filteredItems = data;
        });
      }).catchError((error) {
        print('Erreur lors de la récupération des Matieres: $error');
      });

    }

  }

  @override
  Map<String, Map<String, dynamic>> professeurData = {};

  List<Professeur> professeurList = [];

  Professeur getProfesseurIdFromName(String id) {
    // Assuming you have a list of professeurs named 'professeursList'
    final professeur = professeurList.firstWhere((prof) => '${prof.id}' == id, orElse: () =>
        Professeur(id: '',   user: '',  ));
    print("Profs${professeurList}");
    return professeur; // Return the ID if found, otherwise an empty string

  }

  void groupCoursesByProfesseur(DateTime? Deb, DateTime? Fin) {
    professeurData.clear(); // Efface les données existantes à chaque nouvel appel

    totalType = 0;
    somme = 0;
    for (var course in widget.courses) {
      String profId = course['professeur'];
      DateTime courseDate = DateTime.parse(course['date'].toString());


      if (course['isSigned'] != "en attente" && course['isPaid'] != "effectué" && course['isPaid'] != "préparé" &&
          (Deb == null || courseDate.isAfter(Deb!.toLocal())) &&
          (Fin == null || courseDate.isBefore(Fin!.toLocal().add(Duration(days: 1))))) {
          if (!professeurData.containsKey(profId)) {
            // Initialiser les données du professeur
            professeurData[profId] = {
              'professeur': course['professeur'],
              'email': course['email'],
              'th_total': 0.0,
              'somme_total': 0.0,
            };
          }

          // Mettre à jour les valeurs pour 'th_total' et 'somme_total'
          professeurData[profId]!['th_total'] += double.parse(course['th'].toString());
          totalType += double.parse(course['th'].toString());
          professeurData[profId]!['somme_total'] += double.parse(course['somme'].toString());
          somme += double.parse(course['somme'].toString());
        }
      // }
    }

    // Filtrer les professeurs avec 'th_total' égal à 0
    if (Deb != null || Fin != null) {
      professeurData.removeWhere((key, value) => value['th_total'] == 0.0);

    }
  }


  DateTime? _selectedDateDeb;
  DateTime? _selectedDateFin;
  int currentPage = 1;
  int coursesPerPage = 5;
  String searchQuery = '';
  bool sortByDateAscending = true;
  bool isSigned = false;

  bool showPaid = true;
  bool showRef = false;
  bool showConf = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                }, child: Icon(Icons.arrow_back_ios_new_outlined,size: 20,),
                  style: TextButton.styleFrom(
                    backgroundColor:Colors.white ,
                    foregroundColor:Colors.black ,
                    // elevation: 10,
                    // shape: RoundedRectangleBorder(side: BorderSide(color: Colors.black26)),
                  ),
                ),
                SizedBox(width: 30,),
                Text("État de Paiement",style: TextStyle(fontSize: 25),)
              ],
            ),
          ),


          Padding(padding: EdgeInsets.all(10)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showPaid = !showPaid;
                            showRef = false;
                            showConf =false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          foregroundColor: Colors.blueGrey,
                          // side: BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          backgroundColor: Colors.white,
                          //   foregroundColor: Colors.black,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),

                        child: Row(
                          children: [
                            Text('En Cours'),
                            SizedBox(width: 5,),
                            Icon(Icons.remove_circle_outline)
                          ],
                        ),

                      ),
                      SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showPaid = false;
                            showRef = true;
                            showConf =false;
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => PaieList()));

                          });
                        },
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          foregroundColor: Colors.red,
                          // side: BorderSide(color: Colors.black38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          backgroundColor: Colors.white,
                          //   foregroundColor: Colors.black,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        child: Row(
                          children: [
                            Text('Refuser'),
                            SizedBox(width: 5,),
                            Icon(Icons.hide_source_sharp)
                          ],
                        ),
                      ),
                      SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showPaid = false;
                            showRef = false;
                            showConf = true;
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => PaieList()));

                          });
                        },
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.white,
                          foregroundColor: Colors.lightGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          backgroundColor: Colors.white,
                          textStyle: TextStyle(fontWeight: FontWeight.bold),
                          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        child: Row(
                          children: [
                            Text('Accepté'),
                            SizedBox(width: 5,),
                            Icon(Icons.credit_score)
                          ],
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
           showPaid?
           Padding(
             padding: const EdgeInsets.all(1.0),
             child: Column(
               children: [
                 SingleChildScrollView(scrollDirection: Axis.horizontal,
                   child: Container(
                     width: MediaQuery.of(context).size.width ,
                     decoration: BoxDecoration(
                       color: Colors.blue,
                       borderRadius: BorderRadius.all(
                         Radius.circular(20.0),
                       ),
                     ),
                     // margin: EdgeInsets.only(left: 10),
                     child: DataTable(
                       showCheckboxColumn: true,
                       showBottomBorder: true,
                       headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white70),
                       dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                       headingRowHeight: 50,
                       columnSpacing: 8,
                       headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
                       dataRowHeight: 50,
                       columns: [
                         DataColumn(label: Text('De')),
                         DataColumn(label: Text('Au')),
                         DataColumn(label: Text('Prof')),
                         DataColumn(label: Text('NBC')),
                         DataColumn(label: Text('NBH')),
                         DataColumn(label: Text('Confirm')),
                         DataColumn(label: Text('Action')),
                       ],
                       rows: rows(context,'vide',showPaid,Colors.blueGrey),
                     ),
                   
                   ),
                 ),
               ],
             ),
           )
               :showRef?
           Expanded(
             child: Column(
               children: [
                 SingleChildScrollView(scrollDirection: Axis.horizontal,
                   child: Container(
                     width: MediaQuery.of(context).size.width ,
                     decoration: BoxDecoration(
                       color: Colors.blue,
                       borderRadius: BorderRadius.all(
                         Radius.circular(20.0),
                       ),
                     ),
                     // margin: EdgeInsets.only(left: 10),
                     child: DataTable(
                       showCheckboxColumn: true,
                       showBottomBorder: true,
                       headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white70),
                       dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                       headingRowHeight: 50,
                       headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
                       columnSpacing: 8,
                       dataRowHeight: 50,
                       columns: [
                         DataColumn(label: Text('De')),
                         DataColumn(label: Text('Au')),
                         DataColumn(label: Text('Prof')),
                         DataColumn(label: Text('Banq')),
                         DataColumn(label: Text('MT')),
                         DataColumn(label: Text('Confirm')),
                         DataColumn(label: Text('Action')),
                       ],

                       rows: rows(context,'refusé',showRef,Colors.redAccent),
                     ),

                   ),
                 ),
               ],
             ),
           ):
           showConf?
           Expanded(
             child: Column(
               children: [
                 SingleChildScrollView(scrollDirection: Axis.horizontal,
                   child: Container(
                     width: MediaQuery.of(context).size.width ,
                     decoration: BoxDecoration(
                       color: Colors.blue,
                       borderRadius: BorderRadius.all(
                         Radius.circular(20.0),
                       ),
                     ),
                     // margin: EdgeInsets.only(left: 10),
                     child: DataTable(
                       showCheckboxColumn: true,
                       showBottomBorder: true,
                       headingRowColor: MaterialStateColor.resolveWith((states) => Colors.white70),
                       dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                       headingRowHeight: 50,
                       headingTextStyle: TextStyle(fontWeight: FontWeight.bold),
                       columnSpacing: 8,
                       dataRowHeight: 50,
                       columns: [
                         DataColumn(label: Text('De')),
                         DataColumn(label: Text('Au')),
                         DataColumn(label: Text('Prof')),
                         DataColumn(label: Text('Banq')),
                         DataColumn(label: Text('MT')),
                         DataColumn(label: Text('Confirm')),
                         DataColumn(label: Text('Action')),
                       ],
                       rows: rows(context,'accepté',showConf,Colors.green),
                     ),

                   ),
                 ),
               ],
             ),
           ):
           Expanded(
             child: Container(
               height: MediaQuery.of(context).size.height/ 1.8,
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
                     // width: MediaQuery.of(context).size.width ,
                     decoration: BoxDecoration(
                       color: Colors.white12,
                       borderRadius: BorderRadius.all(
                         Radius.circular(20.0),
                       ),
                     ),
                     // margin: EdgeInsets.only(left: 10),
                     child: Container(
                       // child: Text("Cliquer sur l'une de bouttons au dessuis \n pour avoir les differentes types de paiements",style: TextStyle(fontSize: 18),),
                     ),

                   ),
                 ),
               ),
             ),
           )
        ],
      ),

//      bottomNavigationBar: BottomNav(),

    );

  }

  List<DataRow> rows(BuildContext context,conf,show,myColor) {
    return [
                       for (var index = 0; index < (filteredItems?.length ?? 0); index++)
                       // for (var categ in filteredItems!)
                         if ((!show ||filteredItems![index].conf == conf))
                           DataRow(
                             cells: [
                               DataCell(Text('${DateFormat('dd-MM ').format(DateTime.parse(filteredItems![index].fromDate.toString()).toLocal())}',style: TextStyle(
                                 color: Colors.black,
                               ),)),
                               DataCell(Text('${DateFormat('dd-MM ').format(DateTime.parse(filteredItems![index].toDate.toString()).toLocal())}',style: TextStyle(
                                 color: Colors.black,
                               ),)),
                               DataCell(Text('${filteredItems![index].nomComp.toString().capitalize} '
                                 ,style: TextStyle(
                                 color: Colors.black,
                               ),)),
                               DataCell(Center(
                                 child: Text('${filteredItems![index].nbc}',style: TextStyle(
                                   color: Colors.black,
                                 ),),
                               )),
                               DataCell(Center(
                                 child: Text('${filteredItems![index].nbh}',style: TextStyle(
                                   color: Colors.black,
                                 ),),
                               )),
                               DataCell(Text( conf =='vide' ? 'En Cours' : conf.toString()!.capitalize!, style: TextStyle(fontWeight: FontWeight.bold,color: myColor),),
                               ),
                               DataCell(
                                 buildTextButton(context, index),
                               ),
                             ]),
                     ];
  }

  TextButton buildTextButton(BuildContext context, int index) {
    return TextButton(

                                     onPressed: ()=>_showPaieDetails(context, filteredItems![index], filteredItems![index].id), // Disable button functionality
                                     child: Icon(Icons.more_vert_outlined, color: Colors.black,),

                                   );
  }

  Future<void> _showPaieDetails(BuildContext context, Paies paie,String EleID) {
    return showModalBottomSheet(
        context: context,backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),),
        isScrollControlled: true, // Rendre le contenu déroulable

        builder: (BuildContext context){
          return Column(
            children: [
              Expanded(flex: 3,
                child: Container(margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage("images/Design35.jpg",),fit: BoxFit.cover),
                      color: Colors.white
                  ),
                  padding: EdgeInsets.only(bottom: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // CircleAvatar(
                      //   // radius: 10 * 5,
                      //   backgroundColor: Colors.black,
                      //   child: Image.asset("assets/supnum.png",width: 90),
                      //   // backgroundImage: AssetImage('assets/user1.png'),
                      // ),
                      Container(margin: EdgeInsets.only(left: MediaQuery.of(context).size.width - 40),
                        child: InkWell(
                          child: Icon(Icons.arrow_forward_ios,size: 25,color: Colors.black,),
                          onTap: (){
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(flex: 7,
                child: Container(
                  height: 500,
                  decoration: BoxDecoration(borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(25.0),
                  child: SingleChildScrollView(scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Paiement Infos", style: TextStyle(fontSize: 25, color: Colors.blueGrey),),
                        SizedBox(height: 50),
                        Row(
                          children: [
                            Text('Professeur:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                // color: Colors.lightBlue
                              ),),
                            SizedBox(width: 10,),
                            Text("${paie.nomComp.toString().capitalize}",
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
                            Text('Date Deb:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                // color: Colors.lightBlue
                              ),),
                            SizedBox(width: 10,),
                            Text("${DateFormat('dd MMMM yyyy ').format(DateTime.parse(paie.fromDate.toString()).toLocal())}",
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
                            Text('Date Fin:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                // color: Colors.lightBlue
                              ),),
                            SizedBox(width: 10,),
                            Text("${DateFormat('dd MMMM yyyy ').format(DateTime.parse(paie.toDate.toString()).toLocal())}",
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
                            Text('Banque:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                // color: Colors.lightBlue
                              ),),
                            SizedBox(width: 10,),
                            Text("${paie.banq}",
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
                            Text('Compte:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                // color: Colors.lightBlue
                              ),),
                            SizedBox(width: 10,),
                            Text("${paie.comp}",
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
                            Text('Nombre de Cours:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                // color: Colors.lightBlue
                              ),),
                            SizedBox(width: 10,),
                            Text("${paie.nbc}",
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
                            Text('Nombre d\'heures:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                // color: Colors.lightBlue
                              ),),
                            SizedBox(width: 10,),
                            Text("${paie.nbh}",
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
                            Text("${paie.totalMontant}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                                // color: Colors.lightBlue
                              ),),

                          ],
                        ),

                        SizedBox(height: 25),
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
                                      "Êtes-vous sûr de vouloir supprimer ce paiement ?"),
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

                                        // fetchCategory();
                                        DeletePaie(paie.id);
                                        print(paie.id!);
                                        // Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Le Paiement a été Supprimer avec succès.')),
                                        );
                                        setState(() {
                                          Navigator.of(context).pop();
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }, // Disable button functionality
                          child: Text('Supprimer'),
                          style: ElevatedButton.styleFrom(
                            surfaceTintColor: Colors.white,
                            // side: BorderSide(color: Colors.black38),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 5,
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.redAccent,
                            textStyle: TextStyle(fontWeight: FontWeight.bold),
                            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),

                        ),


                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }


    );
  }

}

class ExcelData {
  String day;
  String code;
  String matiere;
  String enseignant;
  String time;
  String salle;
  String type;

  ExcelData({required this.day,required this.code,required this.matiere, required this.enseignant,required this.time,required this.salle, required this.type});
}

class Paies {
  String id;
  DateTime? date;
  DateTime? fromDate;
  DateTime? toDate;
  String? prof;
  String? enseignant;
  String? nomComp;
  String? email;
  int? mobile;
  String? banq;
  String? status;
  String? conf;
  String? comp;
  num? nbh;
  num? th;
  int? nbc;
  num? totalMontant;

  Paies({
    required this.id,
    this.date,
     this.fromDate,
    this.toDate,
    this.prof,
    this.enseignant,
    this.nomComp,
    this.email,
    this.mobile,
    this.banq,
    this.status,
    this.conf,
    this.comp,
    this.nbh,
    this.th,
    this.nbc,
    this.totalMontant,
  });

  factory Paies.fromJson(Map<String, dynamic> json) {
    return Paies(
      id: json['_id'] ?? '',
      date: DateTime.parse(json['date']),
        fromDate: DateTime.parse(json['fromDate']),
      toDate: DateTime.parse(json['toDate']),
      prof: json['professeur'],
      // enseignant: json['enseignant'],
      nomComp: json['nomComplet'] ,
      // email: json['email'] ,
      // mobile: json['mobile'] ,
      banq: json['banque'],
      comp: json['accountNumero'],
      status: json['status'],
      conf: json['confirmation'],
      nbh: json['nbh'] ?? 0,
      nbc: json['nbc'] ?? 0,
      // th: json['th'] ?? 0,
      totalMontant: json['somme'] ?? 0,
    );
  }
}


Future<List<Paies>> fetchPaie() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString("token")!;
  print(token);

  final response = await http.get(
    Uri.parse('http://192.168.43.73:5000/paiement/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  print(response.statusCode);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    List<dynamic> Data = jsonResponse['paiements'];

    // print(Data);
    List<Paies> paies = Data.map((item) {
      return Paies.fromJson(item);
    }).toList();

    // print(categories);
    return paies;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Semestre');
  }
}

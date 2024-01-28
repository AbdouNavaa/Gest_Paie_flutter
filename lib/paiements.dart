import 'dart:convert';
import 'dart:typed_data';
import 'package:arabic_font/arabic_font.dart';
import 'package:dartarabic/dartarabic.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gestion_payements/professeures.dart';
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
        // print(widget.dateDeb);
        return (course['isSigned'] != "pas encore" && course['isPaid'] != "oui" && course['isPaid'] != "préparée") && // Filter courses with signs
            (courseDate.isAtSameMomentAs(widget.dateDeb!) || (courseDate.isAfter(widget.dateDeb!.toLocal()) &&
                courseDate.isBefore(widget.dateFin!.toLocal().add(Duration(days: 1)))));
      }).map((course) => double.parse(course['TH'].toString())).fold(0, (prev, amount) => prev + amount);

      somme = widget.courses.where((course) {
        DateTime courseDate = DateTime.parse(course['date'].toString());
        return ( course['isSigned'] != "pas encore" && course['isPaid'] != "oui" && course['isPaid'] != "préparée" ) && // Filter courses with signs
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
      (course['isSigned'] != null && course['isSigned'] != '')).map((course) => double.parse(course['TH'].toString())).fold(0, (prev, amount) => prev + amount);
      somme = widget.courses.skip(startIndex).take(coursesPerPage).where((course) =>
      (course['isSigned'] != null && course['isSigned'] != '')).map((course) => double.parse(course['somme'].toString())).fold(0, (prev, amount) => prev + amount);
    }
  }


  DateTime defaultDateDeb = DateTime(2024, 1, 1);
  DateTime defaultDateFin = DateTime(2024, 2, 1);
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
    // ( _selectedDateDeb != null ||_selectedDateFin != null) ? groupCoursesByProfesseur(_selectedDateDeb!, _selectedDateFin!)
    //     :
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
        Professeur(id: '',   user: '', matieres: [], ));
    print(professeurList);
    return professeur; // Return the ID if found, otherwise an empty string

  }

  void groupCoursesByProfesseur(DateTime? Deb, DateTime? Fin) {
    professeurData.clear(); // Efface les données existantes à chaque nouvel appel

    totalType = 0;
    somme = 0;
    for (var course in widget.courses) {
      String profId = course['professeur_id'];
      DateTime courseDate = DateTime.parse(course['date'].toString());


      if (course['isSigned'] != "pas encore" && course['isPaid'] != "oui" && course['isPaid'] != "préparée" &&
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
          totalType += double.parse(course['TH'].toString());
          professeurData[profId]!['somme_total'] += double.parse(course['somme'].toString());
          somme += double.parse(course['somme'].toString());
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

  void AddPaie (String prof,DateTime? fromDate,DateTime? toDate) async {

    // Check if the prix parameter is provided, otherwise use the default value of 100
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token")!;
    print(token);
    final response = await http.post(
      Uri.parse('http://192.168.43.73:5000/paiement/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "professeur":prof,
        "fromDate":fromDate?.toIso8601String() ,
        "toDate": toDate?.toIso8601String() ,
      }),
    );
    if (response.statusCode == 200) {
      print('Category ajouter avec succes');

      setState(() {
        Navigator.pop(context);
      });
    } else {
      print("SomeThing Went Wrong");
    }
  }

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
                  entry.value['TH_total'].toString(),
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
                        pw.Text(DartArabic.normalizeLetters('الجمهورية الاسلامية الموريتانية'), textDirection: pw.TextDirection.ltr),
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
    sheetObject.appendRow(['Professeur', 'Banque', 'Numero compte', 'Volume horaire', 'Montant (MRU)']);

    // Ajoutez les données
    for (var entry in professeurData.entries) {
      sheetObject.appendRow([
        entry.value['professeur'].toString(),
        getProfesseurIdFromName(entry.key).banque.toString(),
        getProfesseurIdFromName(entry.key).compte.toString(),
        entry.value['TH_total'].toString(),
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


  Future<List<ExcelData>> readFirstSheetExcelData(String path) async {
    var bytes = await File(path).readAsBytes();
    var exc = excel.Excel.decodeBytes(bytes);



    // Créez une liste pour stocker les données.
    List<ExcelData> data = [];

    for (var table in exc.tables.keys) {
      var firstSheet = exc.tables.keys.first;
      var sheet = exc.tables[firstSheet]!;

      // Ignorer les premières lignes jusqu'à la ligne "Heure:"
      int rowIndex = 0;
      while (rowIndex < sheet.maxRows && sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value?.toString() != "Heure:") {
        rowIndex++;
      }

      // Parcourir les tableaux
      for (int i = 0; i < 5; i++) {
        rowIndex++; // Ignorer la ligne vide entre les tableaux

        // Extraire le temps (première colonne de chaque tableau)
        String time = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex)).value?.toString() ?? '';

        // Parcourir les lignes du tableau
        for (int j = 2; j <= 27; j++) {
          // Ignorer les colonnes vides (E, I, M, Q)
          if (j % 5 == 0) continue;

          // Extraire les données
          String day = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: j)).value?.toString() ?? '';
          String code = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: j)).value?.toString() ?? '';
          String type = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: j)).value?.toString() ?? '';
          String salle = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: j)).value?.toString() ?? '';
          String matiere = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: j + 1)).value?.toString() ?? '';
          String enseignant = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: j + 2)).value?.toString() ?? '';

          // Ignorer les lignes où le type est "#N/A"
          if (code == "#N/A" &&  type== "#N/A" && salle == "#N/A" && matiere == "#N/A" && enseignant == "#N/A" ) {
            continue;
          }

          // Ajouter l'objet à la liste.
          data.add(ExcelData(
            time: time,
            day: day,
            code: code,
            type: type,
            salle: salle,
            matiere: matiere,
            enseignant: enseignant,
          ));
        }
      }
    }

    // Retourner la liste.
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
                SizedBox(width: 30,),
                Text("Paiements",style: TextStyle(fontSize: 25),)
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
                    initialDate: widget.dateDeb ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  );

                  if (selectedDateDeb != null) {
                    setState(() {
                      _selectedDateDeb = selectedDateDeb.toUtc();
                    });
                      groupCoursesByProfesseur(_selectedDateDeb, null);
                  }
                },
                child: Text(_selectedDateDeb == null ? 'Date Deb' : DateFormat('yyyy/MM/dd').format(_selectedDateDeb!)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white, textStyle: TextStyle(fontWeight: FontWeight.bold),
                  padding:widget.dateDeb != null ? EdgeInsets.only(left: 40,right: 40): EdgeInsets.only(left: 50,right: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  DateTime? selectedDateFin = await showDatePicker(
                    context: context,
                    initialDate: widget.dateFin ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  );

                  if (selectedDateFin != null) {
                    setState(() {
                      _selectedDateFin = selectedDateFin.toUtc();
                    });
                      groupCoursesByProfesseur(_selectedDateDeb!, _selectedDateFin);
                  }
                },
                child: Text(_selectedDateFin == null ? 'Date Fin' : DateFormat('yyyy/MM/dd').format(_selectedDateFin!) ),
                // child: Text(_selectedDateFin == null ? DateFormat('yyyy/MM/dd').format(widget.dateFin!) :DateFormat('yyyy/MM/dd').format(_selectedDateFin!) ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white, textStyle: TextStyle(fontWeight: FontWeight.bold),
                   padding:widget.dateFin != null ? EdgeInsets.only(left: 40,right: 40): EdgeInsets.only(left: 50,right: 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),

          Padding(padding: EdgeInsets.all(10)),
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
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Container(
                        // width: MediaQuery.of(context).size.width,
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
                            DataColumn(label: Text('Prof')),
                            DataColumn(label: Text('Banque')),
                            DataColumn(label: Text('Compte')),
                            DataColumn(label: Text('VH')),
                            DataColumn(label: Text('MT')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows:
                          professeurData.entries.map(
                                  (entry) {
                                String profId = entry.key;
                                Map<String, dynamic> profData = entry.value;


                                return DataRow(
                                  cells: [
                                    DataCell(
                                        Container(width: 65,
                                            child: Text(profData['professeur'].toString()))),
                                    DataCell(Text(getProfesseurIdFromName(profId).banque.toString())),
                                    DataCell(Text(getProfesseurIdFromName(profId).compte.toString())),
                                    DataCell(Text(profData['TH_total'].toString())),
                                    DataCell(Text(profData['somme_total'].toString())),
                                    DataCell(
                                      Container(
                                        width: 35,
                                        child: TextButton(
                                          onPressed: () {
                                            AddPaie(profId, widget.dateDeb, widget.dateFin);
                                            print('Id: ${profId} De: ${widget.dateDeb} Vers: ${widget.dateFin}');
                                          },// Disable button functionality

                                          child: Icon(Icons.check_box_outline_blank, color: Colors.black54),
                                          style: TextButton.styleFrom(
                                            primary: Colors.white,
                                            elevation: 0,
                                            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );

                              }).toList(),


                        ),
                      ),
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

                            SizedBox(width: 195,),
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
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await savePdf();
                },
                child: Text('Télécharger PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white, textStyle: TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(width: 20,),
              ElevatedButton(
                onPressed: () async {
                  await saveExcel();
                },
                child: Text('Télécharger Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white, textStyle: TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: ()  {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EtatPaiemens(courses: widget.courses)));

                },
                child: Text('Etats'),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.only(left: 60,right: 60),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white, textStyle: TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              ElevatedButton(
// Dans n'importe quelle partie de votre application, par exemple, dans la fonction onPressed d'un bouton
                onPressed: () async {
                  // Ouvrez une boîte de dialogue pour permettre à l'utilisateur de sélectionner un fichier
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xlsx', 'xls'],
                  );

                  if (result != null && result.files.isNotEmpty) {
                    // Récupérez le chemin du fichier sélectionné
                    String path = result.files.first.path!;

                    // Lisez les données du fichier Excel.
                    final List<ExcelData> data = await readFirstSheetExcelData(path);

                    // Afficher les données dans la console
                    for (ExcelData excelData in data) {
                      print('Jour: ${excelData.day}');
                      print('Code: ${excelData.code}');
                      print('Matiere: ${excelData.matiere}');
                      print('Enseignant: ${excelData.enseignant}');
                      // print('Heure: ${excelData.heure}');
                      print('Type: ${excelData.type}');
                      print('---------------------');
                    }
                  }
                },
                child: Text('Lire le fichier Excel'),
              ),],
          ),
          Padding(padding: EdgeInsets.all(60)),
        ],
      ),


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
        Professeur(id: '',   user: '', matieres: [], ));
    print(professeurList);
    return professeur; // Return the ID if found, otherwise an empty string

  }

  void groupCoursesByProfesseur(DateTime? Deb, DateTime? Fin) {
    professeurData.clear(); // Efface les données existantes à chaque nouvel appel

    totalType = 0;
    somme = 0;
    for (var course in widget.courses) {
      String profId = course['professeur_id'];
      DateTime courseDate = DateTime.parse(course['date'].toString());


      if (course['isSigned'] != "pas encore" && course['isPaid'] != "oui" && course['isPaid'] != "préparée" &&
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
          totalType += double.parse(course['TH'].toString());
          professeurData[profId]!['somme_total'] += double.parse(course['somme'].toString());
          somme += double.parse(course['somme'].toString());
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

  bool showPaid = false;
  bool showRef = false;
  bool showConf = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.only(left: 15, right: 15),
                            backgroundColor:  Colors.white,foregroundColor: Colors.black54,side: BorderSide(color: Colors.black12,width: 1)),
                        child: Row(
                          children: [
                            Text('En Cours'),
                            SizedBox(width: 5,),
                            Icon(Icons.indeterminate_check_box_outlined)
                          ],
                        ),

                      ),
                      SizedBox(width: 10),
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.only(left: 15, right: 15),
                            backgroundColor: showRef? Colors.white70:Colors.white,foregroundColor: Colors.black54,side: BorderSide(color: Colors.black12,width: 1)),
                        child: Row(
                          children: [
                            Text('Refuser'),
                            SizedBox(width: 5,),
                            Icon(Icons.not_interested)
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.only(left: 15, right: 15),
                            backgroundColor: showConf? Colors.white70:Colors.white,foregroundColor: Colors.black54,side: BorderSide(color: Colors.black12,width: 1)),
                        child: Row(
                          children: [
                            Text('Accepté'),
                            SizedBox(width: 5,),
                            Icon(Icons.check_circle_outline)
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
           Expanded(
             child: Container(
               width: MediaQuery.of(context).size.width,
               height: MediaQuery.of(context).size.height/ 1.8,
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
                     child: DataTable(
                       showCheckboxColumn: true,
                       showBottomBorder: true,
                       headingRowHeight: 50,
                       columnSpacing: 8,
                       dataRowHeight: 50,
                       columns: [
                         DataColumn(label: Text('De')),
                         DataColumn(label: Text('Vers')),
                         DataColumn(label: Text('Prof')),
                         DataColumn(label: Text('Banq')),
                         DataColumn(label: Text('Compte')),
                         DataColumn(label: Text('Confirme')),
                         DataColumn(label: Text('Action')),
                       ],
                       rows: [
                         for (var index = 0; index < (filteredItems?.length ?? 0); index++)
                         // for (var categ in filteredItems!)
                           if ((!showPaid ||filteredItems![index].conf == 'vide'))
                             DataRow(
                               cells: [
                                 DataCell(Text('${DateFormat('dd/MM ').format(DateTime.parse(filteredItems![index].fromDate.toString()).toLocal())}',style: TextStyle(
                                   color: Colors.black,
                                 ),)),
                                 DataCell(Text('${DateFormat('dd/MM ').format(DateTime.parse(filteredItems![index].toDate.toString()).toLocal())}',style: TextStyle(
                                   color: Colors.black,
                                 ),)),
                                 DataCell(Container(width: 60,
                                   child: Text('${filteredItems?[index].nomComp}',style: TextStyle(
                                     color: Colors.black,
                                   ),),
                                 )),
                                 DataCell(Text('${filteredItems?[index].banq}',style: TextStyle(
                                   color: Colors.black,
                                 ),)),
                                 DataCell(Text('${filteredItems?[index].comp}',style: TextStyle(
                                   color: Colors.black,
                                 ),)),
                                 DataCell(Icon( filteredItems?[index].conf =="vide"? Icons.indeterminate_check_box_outlined : filteredItems?[index].conf =="accepté"?Icons.payments_outlined:Icons.refresh_outlined,),
                                 ),
                                 DataCell(
                                   Row(
                                     children: [
                                       Container(
                                         width: 35,
                                         child: TextButton(

                                           onPressed: (){}, // Disable button functionality
                                           child: Icon(Icons.mode_edit_outline_outlined, color: Colors.black,),

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

                                                         // fetchCategory();
                                                         DeletePaie(filteredItems?[index]!.id);
                                                         print(filteredItems?[index].id!);
                                                         // Navigator.of(context).pop();
                                                         ScaffoldMessenger.of(context).showSnackBar(
                                                           SnackBar(content: Text('Le Paiement a été Supprimer avec succès.')),
                                                         );
                                                         setState(() {
                                                           // fetchCategory();
                                                         });
                                                       },
                                                     ),
                                                   ],
                                                 );
                                               },
                                             );
                                           }, // Disable button functionality
                                           child: Icon(Icons.delete_outline, color: Colors.black,),

                                         ),
                                       ),

                                     ],
                                   ),
                                 ),
                                 // DataCell(Container(width: 105,
                                 //     child: Text('${categ.description}',)),),


                               ]),
                       ],
                     ),

                   ),
                 ),
               ),
             ),
           )
               :showRef?Expanded(
             child: Container(
               width: MediaQuery.of(context).size.width,
               height: MediaQuery.of(context).size.height/ 1.8,
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
                     child: DataTable(
                       showCheckboxColumn: true,
                       showBottomBorder: true,
                       headingRowHeight: 50,
                       columnSpacing: 8,
                       dataRowHeight: 50,
                       columns: [
                         DataColumn(label: Text('De')),
                         DataColumn(label: Text('Vers')),
                         DataColumn(label: Text('Prof')),
                         DataColumn(label: Text('Banq')),
                         DataColumn(label: Text('Compte')),
                         DataColumn(label: Text('Confirme')),
                         DataColumn(label: Text('Action')),
                       ],
                       rows: [
                         for (var index = 0; index < (filteredItems?.length ?? 0); index++)
                         // for (var categ in filteredItems!)
                           if ((!showRef ||filteredItems![index].conf == 'refusé'))
                             DataRow(
                                 cells: [
                                   DataCell(Text('${DateFormat('dd/MM ').format(DateTime.parse(filteredItems![index].fromDate.toString()).toLocal())}',style: TextStyle(
                                     color: Colors.black,
                                   ),)),
                                   DataCell(Text('${DateFormat('dd/MM ').format(DateTime.parse(filteredItems![index].toDate.toString()).toLocal())}',style: TextStyle(
                                     color: Colors.black,
                                   ),)),
                                   DataCell(Container(width: 60,
                                     child: Text('${filteredItems?[index].nomComp}',style: TextStyle(
                                       color: Colors.black,
                                     ),),
                                   )),
                                   DataCell(Text('${filteredItems?[index].banq}',style: TextStyle(
                                     color: Colors.black,
                                   ),)),
                                   DataCell(Text('${filteredItems?[index].comp}',style: TextStyle(
                                     color: Colors.black,
                                   ),)),
                                   DataCell(Icon( filteredItems?[index].conf =="vide"? Icons.indeterminate_check_box_outlined : filteredItems?[index].conf =="accepté"?Icons.payments_outlined:Icons.refresh_outlined,),
                                   ),
                                   DataCell(
                                     Row(
                                       children: [
                                         Container(
                                           width: 35,
                                           child: TextButton(

                                             onPressed: (){}, // Disable button functionality
                                             child: Icon(Icons.mode_edit_outline_outlined, color: Colors.black,),

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

                                                           // fetchCategory();
                                                           DeletePaie(filteredItems?[index]!.id);
                                                           print(filteredItems?[index].id!);
                                                           // Navigator.of(context).pop();
                                                           ScaffoldMessenger.of(context).showSnackBar(
                                                             SnackBar(content: Text('Le Paiement a été Supprimer avec succès.')),
                                                           );
                                                           setState(() {
                                                             // fetchCategory();
                                                           });
                                                         },
                                                       ),
                                                     ],
                                                   );
                                                 },
                                               );
                                             }, // Disable button functionality
                                             child: Icon(Icons.delete_outline, color: Colors.black,),

                                           ),
                                         ),

                                       ],
                                     ),
                                   ),
                                   // DataCell(Container(width: 105,
                                   //     child: Text('${categ.description}',)),),


                                 ]),
                       ],
                     ),

                   ),
                 ),
               ),
             ),
           ):
           showConf?
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
                     child: DataTable(
                       showCheckboxColumn: true,
                       showBottomBorder: true,
                       headingRowHeight: 50,
                       columnSpacing: 8,
                       dataRowHeight: 50,
                       columns: [
                         DataColumn(label: Text('De')),
                         DataColumn(label: Text('Vers')),
                         DataColumn(label: Text('Prof')),
                         DataColumn(label: Text('Banq')),
                         DataColumn(label: Text('Compte')),
                         DataColumn(label: Text('Confirme')),
                         DataColumn(label: Text('Action')),
                       ],
                       rows: [
                         for (var index = 0; index < (filteredItems?.length ?? 0); index++)
                         // for (var categ in filteredItems!)
                           if ((!showConf ||filteredItems![index].conf == 'accepté'))
                             DataRow(
                                 cells: [
                                   DataCell(Text('${DateFormat('dd/MM ').format(DateTime.parse(filteredItems![index].fromDate.toString()).toLocal())}',style: TextStyle(
                                     color: Colors.black,
                                   ),)),
                                   DataCell(Text('${DateFormat('dd/MM ').format(DateTime.parse(filteredItems![index].toDate.toString()).toLocal())}',style: TextStyle(
                                     color: Colors.black,
                                   ),)),
                                   DataCell(Container(width: 60,
                                     child: Text('${filteredItems?[index].nomComp}',style: TextStyle(
                                       color: Colors.black,
                                     ),),
                                   )),
                                   DataCell(Text('${filteredItems?[index].banq}',style: TextStyle(
                                     color: Colors.black,
                                   ),)),
                                   DataCell(Text('${filteredItems?[index].comp}',style: TextStyle(
                                     color: Colors.black,
                                   ),)),
                                   DataCell(Icon( filteredItems?[index].conf =="vide"? Icons.indeterminate_check_box_outlined : filteredItems?[index].conf =="accepté"?Icons.payments_outlined:Icons.refresh_outlined,),
                                   ),
                                   DataCell(
                                     Row(
                                       children: [
                                         Container(
                                           width: 35,
                                           child: TextButton(

                                             onPressed: (){}, // Disable button functionality
                                             child: Icon(Icons.mode_edit_outline_outlined, color: Colors.black,),

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

                                                           // fetchCategory();
                                                           DeletePaie(filteredItems?[index]!.id);
                                                           print(filteredItems?[index].id!);
                                                           // Navigator.of(context).pop();
                                                           ScaffoldMessenger.of(context).showSnackBar(
                                                             SnackBar(content: Text('Le Paiement a été Supprimer avec succès.')),
                                                           );
                                                           setState(() {
                                                             // fetchCategory();
                                                           });
                                                         },
                                                       ),
                                                     ],
                                                   );
                                                 },
                                               );
                                             }, // Disable button functionality
                                             child: Icon(Icons.delete_outline, color: Colors.black,),

                                           ),
                                         ),

                                       ],
                                     ),
                                   ),
                                   // DataCell(Container(width: 105,
                                   //     child: Text('${categ.description}',)),),


                                 ]),
                       ],
                     ),

                   ),
                 ),
               ),
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
  String? nomComp;
  String? email;
  int? mobile;
  String? banq;
  String? status;
  String? conf;
  int? comp;

  Paies({
    required this.id,
    this.date,
     this.fromDate,
    this.toDate,
    this.prof,
    this.nomComp,
    this.email,
    this.mobile,
    this.banq,
    this.status,
    this.conf,
    this.comp,
  });

  factory Paies.fromJson(Map<String, dynamic> json) {
    return Paies(
      id: json['_id'] ?? '',
      date: DateTime.parse(json['date']),
        fromDate: DateTime.parse(json['fromDate']),
      toDate: DateTime.parse(json['toDate']),
      prof: json['professeur'],
      nomComp: json['nomComplet'] ,
      email: json['email'] ,
      mobile: json['mobile'] ,
      banq: json['banque'],
      comp: json['accountNumero'],
      status: json['status'],
      conf: json['confirmation'],
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

class PaieList extends StatefulWidget {
  PaieList({Key ? key}) : super(key: key);

  @override
  _PaieListState createState() => _PaieListState();
}

class _PaieListState extends State<PaieList> {


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
  void initState() {
    super.initState();
    fetchPaie().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par Categoryesseur à items
      });
    }).catchError((error) {
      print('Erreur: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        // appBar: AppBar(
        //   title: Center(child: Text(' ${filteredItems?.length} ')),
        // ),
        body: Column(
          children: [
            SizedBox(height: 40,),
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
                  Text("Liste de Paiemets",style: TextStyle(fontSize: 25),)
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                // controller: _searchController,
                onChanged: (value) async {
                  List<Paies> Payes = await fetchPaie();

                  setState(() {
                    // Implémentez la logique de filtrage ici
                    // Par exemple, filtrez les Categoryesseurs dont le name ou le préname contient la valeur saisie
                    filteredItems = Payes!.where((Paye) =>
                    Paye.prof!.toLowerCase().contains(value.toLowerCase()) ||
                        Paye.email!.toLowerCase().contains(value.toLowerCase())).toList();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Rechercher  ',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),

              )
              ,
            ),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: FutureBuilder<List<Paies>>(
                    future: fetchPaie(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {

                          return
                            ListView.builder(
                              itemCount: filteredItems?.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                return Dismissible(
                                    key: Key(filteredItems![index].id), // Provide a unique key for each item
                                    direction: DismissDirection.endToStart, // Swipe from right to left to dismiss
                                    background: Container(
                                      alignment: Alignment.center,
                                      color: Colors.white12,
                                      child: Icon(Icons.delete, color: Colors.black54),
                                    ),
                                    confirmDismiss: (direction) async {
                                      // Show the confirmation dialog when swiping to delete
                                      return await
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Confirmer la suppression"),
                                            content: Text("Êtes-vous sûr de vouloir supprimer cet élément ?"),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text("ANNULER"),
                                                onPressed: () {
                                                  Navigator.of(context).pop(false);
                                                },
                                              ),
                                              TextButton(
                                                child: Text("SUPPRIMER"),
                                                onPressed: () {
                                                  Navigator.of(context).pop(true);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    onDismissed: (direction) {
                                      // When dismissed (swiped to delete), call the delete method here
                                      DeletePaie(filteredItems![index].id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Le Paiement a été Supprimer avec succès.')),
                                      );
                                    },
                                    child:   Card(
                                  elevation: 10,
                                  margin: EdgeInsets.only(left: 15, right: 10,bottom: 10),shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20)),),
                                  child: Container(
                                    height: 140,
                                    width: MediaQuery.of(context).size.width -50,
                                    margin: EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(width: 10,),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text('De: ',style: TextStyle(
                                                      fontSize: 18
                                            ),),
                                                    Text('${DateFormat('dd/M/yy ').format(DateTime.parse(filteredItems![index].fromDate.toString()).toLocal())}',style: TextStyle(
                                                      fontSize: 18
                                                    ),),

                                                    SizedBox(width: 15,),
                                                    Text('Vers: ',style: TextStyle(
                                                        fontSize: 18
                                                    ),),
                                                    Text('${DateFormat('dd/M/yy ').format(DateTime.parse(filteredItems![index].toDate.toString()).toLocal())}',style: TextStyle(
                                                        fontSize: 18
                                                    ),),

                                                  ],
                                                ),
                                                SizedBox(height: 10,),
                                                Row(
                                                  children: [
                                                    Text('Professeur: ',style: TextStyle(
                                                      fontSize: 18
                                            ),),
                                                    Text('${filteredItems![index].nomComp}',style: TextStyle(
                                                      fontSize: 18
                                                    ),),
                                                  ],
                                                ),
                                                SizedBox(height: 10,),
                                                Row(
                                                  children: [
                                                    Text('Prof Email: ',style: TextStyle(
                                                      fontSize: 18
                                            ),),
                                                    Text('${filteredItems![index].email}',style: TextStyle(
                                                      fontSize: 18
                                                    ),),
                                                  ],
                                                ),
                                                SizedBox(height: 10,),
                                                Row(
                                                  children: [
                                                    Text('Banque: ',style: TextStyle(
                                                      fontSize: 18
                                            ),),
                                                    Text('${filteredItems![index].banq}',style: TextStyle(
                                                      fontSize: 18
                                                    ),),

                                                  ],
                                                ),
                                                SizedBox(height: 10,),
                                                Row(
                                                  children: [
                                                    Text('Compte: ',style: TextStyle(
                                                      fontSize: 18
                                            ),),
                                                    Text('${filteredItems![index].comp}',style: TextStyle(
                                                      fontSize: 18
                                                    ),),
                                                  ],
                                                ),
                                                SizedBox(height: 10,),
                                                Row(
                                                  children: [
                                                    Text('Status: ',style: TextStyle(
                                                      fontSize: 18
                                            ),),
                                                    Text('${filteredItems![index].status}',style: TextStyle(
                                                      fontSize: 18
                                                    ),),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ));
                              },
                            );




                        }
                      }
                    },
                  ),
                ),
              ),
            ),

          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          // heroTag: 'uniqueTag',
          tooltip: 'Ajouter une categorie',
          backgroundColor: Colors.white,
          label: Row(
            children: [Icon(Icons.add,color: Colors.black,)],
          ),
          onPressed: () => (){},

        ),


      ),
      // bottomNavigationBar: BottomNav(),

    );
  }



}
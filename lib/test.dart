/* ******************************************
                 *** START***
****************************************** */

import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
as charts;
import 'filliere.dart';

enum POSITIONS { endDocked, centerFloat, endFloat, centerDocked }

class LFloatingActionButton extends StatefulWidget {
  const LFloatingActionButton({super.key});

  @override
  State<LFloatingActionButton>  createState() => _LFloatingActionButtonState();
}

class _LFloatingActionButtonState extends State<LFloatingActionButton> {
  FloatingActionButtonLocation _fabLocation =
      FloatingActionButtonLocation.centerDocked;
  POSITIONS? _character = POSITIONS.centerDocked;
  bool? _isNotched = false;
  bool? _isMini = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            ListTile(
              title: const Text('Mini'),
              leading: Checkbox(
                value: _isMini,
                onChanged: (bool? bool) => <void>{
                  setState(() {
                    _isMini = bool;
                  })
                },
              ),
            ),
            ListTile(
              title: const Text('Bottom Notch'),
              leading: Checkbox(
                value: _isNotched,
                onChanged: (bool? bool) => <void>{
                  setState(() {
                    _isNotched = bool;
                  })
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Center Docked'),
              leading: Radio(
                value: POSITIONS.centerDocked,
                groupValue: _character,
                onChanged: (POSITIONS? value) {
                  setState(() {
                    _character = value;
                    _fabLocation = FloatingActionButtonLocation.centerDocked;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('End Docked'),
              leading: Radio(
                value: POSITIONS.endDocked,
                groupValue: _character,
                onChanged: (POSITIONS? value) {
                  setState(() {
                    _character = value;
                    _fabLocation = FloatingActionButtonLocation.endDocked;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('End Float'),
              leading: Radio(
                value: POSITIONS.endFloat,
                groupValue: _character,
                onChanged: (POSITIONS? value) {
                  setState(() {
                    _character = value;
                    _fabLocation = FloatingActionButtonLocation.endFloat;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Center Float'),
              leading: Radio(
                value: POSITIONS.centerFloat,
                groupValue: _character,
                onChanged: (POSITIONS? value) {
                  setState(() {
                    _character = value;
                    _fabLocation = FloatingActionButtonLocation.centerFloat;
                  });
                },
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            mini: _isMini!, onPressed: () => {}, child: const Icon(Icons.add)),
        floatingActionButtonLocation: _fabLocation,
        bottomNavigationBar: BottomAppBar(
          shape: _isNotched! ? const CircularNotchedRectangle() : null,
          child: Container(
            height: 50.0,
          ),
        ),
      ),
    );
  }
}

/* ******************************************
*********************************************
*********************************************
              *** END***
*********************************************
*********************************************
****************************************** */


class LExpansionPanelList extends StatefulWidget {
  const LExpansionPanelList({super.key});

  @override
  State<LExpansionPanelList> createState() => _LExpansionPanelListState();
}

class _LExpansionPanelListState extends State<LExpansionPanelList> {
  int index = -1;
  List<filliere>? filteredItems;

  @override
  void initState() {
    fetchfilliere().then((data) {
      setState(() {
        filteredItems = data; // Assigner la liste renvoyée par emploiesseur à items
      });




    }).catchError((error) {
      print('Erreur: $error');
    });
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: filteredItems == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            margin: EdgeInsets.only(top: 100),
            child: ExpansionPanelList(
              expansionCallback: (int i, bool isOpen) {
                setState(() {
                  index = index == i ? -1 : i;
                });
              },
              animationDuration: const Duration(seconds: 1),
              dividerColor: Colors.teal,
              elevation: 2,
              children: filteredItems!.asMap().entries.map<ExpansionPanel>((entry) {
                int i = entry.key;
                filliere fil = entry.value;
                return ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text(fil.name),
                    );
                  },
                  canTapOnHeader: true,
                  body: ListTile(
                    title: Text('Niveau: ${fil.niveau}'),
                    subtitle: fil.description != null ? Text('Description: ${fil.description}') : null,
                  ),
                  isExpanded: index == i,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}







class MyCustomWidget extends StatefulWidget {
@override
_MyCustomWidgetState createState() => _MyCustomWidgetState();
}

class _MyCustomWidgetState extends State<MyCustomWidget> {
String TapToExpandIt = 'Tap to Expand it';
String Sentence = 'Widgets that have global keys reparent their subtrees when'
' they are moved from one location in the tree to another location in the'
' tree. In order to reparent its subtree, a widget must arrive at its new'
' location the tree.';
bool isExpanded = true;
bool isExpanded2  = true;
List<filliere>? filteredItems;
List<bool> isExpandedList = [];

@override
void initState() {
  super.initState();
  _loadFiliere();
}

Future<void> _loadFiliere() async {
  List<filliere> filieres = await fetchfilliere();
  setState(() {
    filteredItems = filieres;
    isExpandedList = List<bool>.filled(filieres.length, true);
  });
}
@override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Filiere List'),
    ),
    body: filteredItems == null
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: filteredItems!.length,
      itemBuilder: (context, index) {
        return InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            setState(() {
              isExpandedList[index] = !isExpandedList[index];
            });
          },
          child: AnimatedContainer(
            margin: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            padding: EdgeInsets.all(20),
            height: isExpandedList[index] ? 70 : 200,
            curve: Curves.fastLinearToSlowEaseIn,
            duration: Duration(milliseconds: 1200),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0xff6F12E8).withOpacity(0.5),
                  blurRadius: 20,
                  offset: Offset(5, 10),
                ),
              ],
              color: Color(0xff6F12E8),
              borderRadius: BorderRadius.all(
                Radius.circular(isExpandedList[index] ? 20 : 20),
              ),
            ),
            child: SingleChildScrollView(scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        filteredItems![index].name.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Icon(
                        isExpandedList[index]
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 27,
                      ),
                    ],
                  ),
                  isExpandedList[index] ? SizedBox() : SizedBox(height: 20),
                  AnimatedCrossFade(
                    firstChild: Text(
                      '',
                      style: TextStyle(
                        fontSize: 0,
                      ),
                    ),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Niveau: ${filteredItems![index].niveau}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.7,
                          ),
                        ),
                        filteredItems![index].description != null
                            ? Text(
                          'Description: ${filteredItems![index].description}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.7,
                          ),
                        )
                            : Container(),

                      ],
                    ),
                    crossFadeState: isExpandedList[index]
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: Duration(milliseconds: 1200),
                    reverseDuration: Duration.zero,
                    sizeCurve: Curves.fastLinearToSlowEaseIn,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  }
}




/// Data class to visualize.
class _CostsData {
  final String category;
  final int cost;

  const _CostsData(this.category, this.cost);
}

class PieChartExample extends StatefulWidget {
  const PieChartExample({super.key});

  @override
  _PieChartExampleState createState() => _PieChartExampleState();
}

class _PieChartExampleState extends State<PieChartExample> {
  // Chart configs.
  bool _animate = true;
  bool _defaultInteractions = true;
  double _arcRatio = 0.8;
  charts.ArcLabelPosition _arcLabelPosition = charts.ArcLabelPosition.auto;
  charts.BehaviorPosition _titlePosition = charts.BehaviorPosition.bottom;
  charts.BehaviorPosition _legendPosition = charts.BehaviorPosition.bottom;

  // Data to render.
  final List<_CostsData> _data = [
    const _CostsData('housing', 1000),
    const _CostsData('food', 500),
    const _CostsData('health', 200),
    const _CostsData('trasport', 100),
  ];

  @override
  Widget build(BuildContext context) {
    final _colorPalettes =
    charts.MaterialPalette.getOrderedPalettes(this._data.length);
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        SizedBox(
          height: 300,
          // MUST specify the type T, see https://github.com/google/charts/issues/668#issuecomment-943556524.
          child: charts.PieChart<String>(
            // Pie chart can only render one series.
          /*seriesList=*/ [
          charts.Series<_CostsData, String>(
          id: 'Sales-1',
          colorFn: (_, idx) => _colorPalettes[idx!].shadeDefault,
          domainFn: (_CostsData sales, _) => sales.category,
          measureFn: (_CostsData sales, _) => sales.cost,
          data: this._data,
          // Set a label accessor to control the text of the arc label.
          labelAccessorFn: (_CostsData row, _) =>
          '${row.category}: ${row.cost}',
        ),
      ],
      animate: this._animate,
      defaultRenderer: charts.ArcRendererConfig(
        arcRatio: this._arcRatio,
        arcRendererDecorators: [
          charts.ArcLabelDecorator(labelPosition: this._arcLabelPosition)
        ],
      ),
      behaviors: [
        // Add title.
        charts.ChartTitle(
          'Dummy costs breakup',
          behaviorPosition: this._titlePosition,
        ),
        // Add legend. ("Datum" means the "X-axis" of each data point.)
        charts.DatumLegend(
          position: this._legendPosition,
          desiredMaxRows: 2,
        ),
      ],
    ),
    ),
    const Divider(),
    ..._controlWidgets(),
    ],
    );
  }

  /// Widgets to control the chart appearance and behavior.
  List<Widget> _controlWidgets() => <Widget>[
    SwitchListTile.adaptive(
      title: const Text('animate'),
      onChanged: (bool val) => setState(() => this._animate = val),
      value: this._animate,
    ),
    SwitchListTile(
      title: const Text('defaultInteractions'),
      onChanged: (bool val) =>
          setState(() => this._defaultInteractions = val),
      value: this._defaultInteractions,
    ),
    const ListTile(title: Text('Arc width ratio w.r.t. radius:')),
    Slider(
      divisions: 10,
      onChanged: (double val) => setState(() => this._arcRatio = val),
      value: this._arcRatio,
      label: '${this._arcRatio}',
    ),
    ListTile(
      title: const Text('arcLabelPosition:'),
      trailing: DropdownButton<charts.ArcLabelPosition>(
        value: this._arcLabelPosition,
        onChanged: (charts.ArcLabelPosition? newVal) {
          if (newVal != null) {
            setState(() => this._arcLabelPosition = newVal);
          }
        },
        items: [
          for (final val in charts.ArcLabelPosition.values)
            DropdownMenuItem(value: val, child: Text('$val'))
        ],
      ),
    ),
    ListTile(
      title: const Text('titlePosition:'),
      trailing: DropdownButton<charts.BehaviorPosition>(
        value: this._titlePosition,
        onChanged: (charts.BehaviorPosition? newVal) {
          if (newVal != null) {
            setState(() => this._titlePosition = newVal);
          }
        },
        items: [
          for (final val in charts.BehaviorPosition.values)
            DropdownMenuItem(value: val, child: Text('$val'))
        ],
      ),
    ),
    ListTile(
      title: const Text('legendPosition:'),
      trailing: DropdownButton<charts.BehaviorPosition>(
        value: this._legendPosition,
        onChanged: (charts.BehaviorPosition? newVal) {
          if (newVal != null) {
            setState(() => this._legendPosition = newVal);
          }
        },
        items: [
          for (final val in charts.BehaviorPosition.values)
            DropdownMenuItem(value: val, child: Text('$val'))
        ],
      ),
    ),
  ];
}
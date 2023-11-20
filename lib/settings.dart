import 'package:flutter/material.dart';
import 'package:gestion_payements/theme.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChanger>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
      ),
      body: Column(
        children: <Widget>[
          // ... Autres paramètres ...
          ListTile(
            title: Text('Mode Sombre'),
            trailing: Switch(
              value: themeChanger.themeData.brightness == Brightness.dark,
              onChanged: (value) {
                if (value) {
                  themeChanger.setTheme(ThemeData.dark());
                } else {
                  themeChanger.setTheme(ThemeData.light());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

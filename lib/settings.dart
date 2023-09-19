import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedFont = 'Default';
  String selectedLanguage = 'English';
  String selectedTheme = 'light'; // Add this line

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedFont,
              onChanged: (newValue) {
                setState(() {
                  selectedFont = newValue!;
                });
              },
              items: ['Default', 'Roboto', 'Arial'].map<DropdownMenuItem<String>>(
                    (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                },
              ).toList(),
            ),

            DropdownButton<String>(
              value: selectedLanguage,
              onChanged: (newValue) {
                setState(() {
                  selectedLanguage = newValue!;
                });
              },
              items: ['English', 'French', 'Spanish'].map<DropdownMenuItem<String>>(
                    (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                },
              ).toList(),
            ),

            RadioListTile(
              title: Text('Light Theme'),
              value: 'light',
              groupValue: selectedTheme, // Update this line
              onChanged: (value) {
                setState(() {
                  selectedTheme = value!; // Update the selected theme
                });
                // TODO: Update the theme based on user selection
              },
            ),
            RadioListTile(
              title: Text('Dark Theme'),
              value: 'dark',
              groupValue: selectedTheme, // Update this line
              onChanged: (value) {
                setState(() {
                  selectedTheme = value!; // Update the selected theme
                });
                // TODO: Update the theme based on user selection
              },
            ),

            Text('Hello',style: TextStyle(),)
          ],
        ),
      ),
    );
  }
}


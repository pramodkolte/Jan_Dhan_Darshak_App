import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ChangeLanguage extends StatefulWidget {
  @override
  _ChangeLanguageState createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
  List<String> _list = [
    'Bengali ( বাংলা )',
    'English ( English )',
    'Gujarati ( ગુજરાતી )',
    'Hindi ( हिंदी )',
    'Kannada ( ಕನ್ನಡ )',
    'Malayalam ( മലയാളം )',
    'Marathi ( मराठी )',
    'Nepali ( नेपाली )',
    'Odia ( ଓଡିଆ )',
    'Punjabi ( ਪੰਜਾਬੀ )',
    'Tamil ( தமிழ் )',
    'Telugu ( తెలుగు )',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          EasyLocalization.of(context)
              .delegate
              .translations
              .get('select_your_langauge'),
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.grey[700],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.white,
        child: ListView.separated(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                _list.elementAt(index),
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: () {
                context.locale =
                    EasyLocalization.of(context).supportedLocales[index];
                Navigator.of(context).pop();
              },
            );
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemCount: EasyLocalization.of(context).supportedLocales.length,
        ),
      ),
    );
  }
}

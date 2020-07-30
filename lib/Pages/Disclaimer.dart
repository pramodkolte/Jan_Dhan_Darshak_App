import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          EasyLocalization.of(context).delegate.translations.get('disclaimer'),
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.grey[700],
        ),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 12),
          ListTile(
            title: Text(
              EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('disclaimer_1'),
            ),
          ),
          ListTile(
            title: Text(
              EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('disclaimer_2'),
            ),
          ),
          ListTile(
            title: Text(
              EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('disclaimer_3'),
            ),
          ),
          ListTile(
            title: Text(
              EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('disclaimer_4'),
            ),
          ),
          ListTile(
            title: Text(
              EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('disclaimer_5'),
            ),
          ),
        ],
      ),
    );
  }
}

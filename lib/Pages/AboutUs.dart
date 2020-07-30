import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          EasyLocalization.of(context).delegate.translations.get('about_us'),
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.grey[700],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Text(
          EasyLocalization.of(context).delegate.translations.get('about_us_d'),
          style: TextStyle(
            fontSize: 19,
            wordSpacing: 2,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

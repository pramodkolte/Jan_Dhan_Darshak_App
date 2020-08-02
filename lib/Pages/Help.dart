import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Help extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          EasyLocalization.of(context).delegate.translations.get('help'),
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView(
          children: <Widget>[
            //Divider(),
            ExpansionTile(
              initiallyExpanded: true,
              title: Text(EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('geting_started')),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: Text(
                    EasyLocalization.of(context)
                        .delegate
                        .translations
                        .get('geting_started_d'),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            _buildTile(
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('prerequisites'),
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('prerequisites_d')),

            _buildTile(
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('functionalities'),
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('functionalities_d')),
            _buildTile(
                EasyLocalization.of(context).delegate.translations.get('map'),
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('map_d')),
            _buildTile(
                EasyLocalization.of(context).delegate.translations.get('zoom'),
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('zoom_d')),
            _buildTile(
                EasyLocalization.of(context).delegate.translations.get('gps'),
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('gps_d')),
            _buildTile(
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('menu_button'),
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('menu_button_d')),
            _buildTile(
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('Search'),
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('search_d')),
            _buildTile(
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('bottom_navigation'),
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('bottom_navigatio_d')),
            _buildTile(
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('languages'),
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('languages_d')),
          ],
        ),
      ),
    );
  }

  _buildTile(String title, String description) {
    return ExpansionTile(
      title: Text(title),
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Text(
            description,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

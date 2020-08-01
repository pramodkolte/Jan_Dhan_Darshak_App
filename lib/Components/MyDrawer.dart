import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  EasyLocalization.of(context)
                      .delegate
                      .translations
                      .get('jan_dhan_darshak'),
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.blueGrey,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: Navigator.of(context).pop,
                ),
              ],
            ),
            Divider(),

            //Change Language
            ListTile(
              leading: Icon(
                Icons.translate,
              ),
              title: Text(
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('change_language'),
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/changeLanguage');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.help_outline,
              ),
              title: Text(EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('help')),
              onTap: () {
                Navigator.of(context).pushNamed('/help');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info_outline,
              ),
              title: Text(EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('about_us')),
              onTap: () {
                Navigator.of(context).pushNamed('/aboutUs');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.add_location,
              ),
              title: Text(EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('missing_place_suggestion')),
              onTap: () {
                Navigator.of(context).pushNamed('/placeSuggest');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.warning,
              ),
              title: Text(EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('disclaimer')),
              onTap: () {
                Navigator.of(context).pushNamed('/disclaimer');
              },
            ),
          ],
        ),
      ),
    );
  }
}

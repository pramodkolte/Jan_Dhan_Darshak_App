import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

//my own imports
import 'package:jan_dhan_darshak/Pages/ChangeLanguage.dart';
import 'package:jan_dhan_darshak/Pages/Feedback.dart';
import 'package:jan_dhan_darshak/Pages/PlaceSuggestion.dart';
import 'package:jan_dhan_darshak/Pages/Help.dart';
import 'package:jan_dhan_darshak/Pages/AboutUs.dart';
import 'package:jan_dhan_darshak/Pages/Disclaimer.dart';
import 'package:jan_dhan_darshak/Pages/favorites.dart';
import 'package:jan_dhan_darshak/Pages/introscreen.dart';

void main() => runApp(
      EasyLocalization(
        child: MyApp(),
        supportedLocales: [
          Locale('bn'),
          Locale('en'),
          Locale('gu'),
          Locale('hi'),
          Locale('kn'),
          Locale('ml'),
          Locale('mr'),
          Locale('ne'),
          Locale('or'),
          Locale('pa'),
          Locale('ta'),
          Locale('te'),
        ],
        useOnlyLangCode: true,
        saveLocale: true,
        path: 'assets/languages',
        fallbackLocale: Locale('en'),
        preloaderWidget: Container(
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jan Dhan Darshak',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/changeLanguage': (context) => ChangeLanguage(),
        '/favourites': (context) => FavoritePlaces(),
        '/placeSuggest': (context) => PlaceSuggestion(),
        '/help': (context) => Help(),
        '/feedback': (context) => FeedbackTo(),
        '/aboutUs': (context) => AboutUs(),
        '/disclaimer': (context) => Disclaimer(),
      },
    );
  }
}

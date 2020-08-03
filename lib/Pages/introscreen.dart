import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:jan_dhan_darshak/root.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      return RootPage();
    } else {
      return IntroScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: checkFirstSeen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return snapshot.data;
          }
        });
  }
}

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('seen', true);
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RootPage()),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset(assetName, width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      imageFlex: 2,
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.only(top: 30),
    );
    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Bottom Navigation Bar",
          body: "Switch between tabs to change FTP type.",
          image: _buildImage('assets/intros/intro1.gif'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Draggable Scrollable Sheet",
          body: "Scroll the sheet for finding nearby places.",
          image: _buildImage('assets/intros/intro2.gif'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Navigation Menu",
          body: "Click to open menu options.",
          image: _buildImage('assets/intros/intro3.gif'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Place Details",
          body: "View the place by clicking on marker.",
          image: _buildImage('assets/intros/intro4.gif'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

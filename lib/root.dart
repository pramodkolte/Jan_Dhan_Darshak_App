import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jan_dhan_darshak/Components/MyHomePage.dart';

enum Status {
  NOT_DETERMINED,
  NOT_READY,
  READY,
}

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  Status status = Status.NOT_DETERMINED;
  Position _position;

  @override
  void initState() {
    super.initState();
    _getMyLocation();
  }

  _getMyLocation() {
    Geolocator().getCurrentPosition().then((currloc) {
      if (currloc != null) {
        setState(() {
          _position = currloc;
          status = Status.READY;
        });
      } else {
        setState(() {
          status = Status.NOT_READY;
        });
      }
    }).catchError((error) {
      print(error);
      setState(() {
        status = Status.NOT_READY;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case Status.NOT_DETERMINED:
        return buildLoadingScreen();
        break;
      case Status.NOT_READY:
        return buildNotReady();
        break;
      case Status.READY:
        return new MyHomePage(
          position: _position,
        );
        break;
      default:
        return buildLoadingScreen();
    }
  }

  buildLoadingScreen() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Image.asset('assets/satyamev.png'),
              ),
              Text(
                EasyLocalization.of(context)
                    .delegate
                    .translations
                    .get('jan_dhan_darshak'),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNotReady() {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Jan Dhan Darshak app needs lcation permission!',
                textAlign: TextAlign.center,
              ),
            ),
            OutlineButton(
              onPressed: _getMyLocation(),
              child: Text('Give Permission'),
            ),
          ],
        ),
      ),
    );
  }
}

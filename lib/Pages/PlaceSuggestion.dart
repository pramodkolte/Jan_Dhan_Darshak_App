import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSuggestion extends StatefulWidget {
  @override
  _PlaceSuggestionState createState() => _PlaceSuggestionState();
}

class _PlaceSuggestionState extends State<PlaceSuggestion> {
  final _formKey = new GlobalKey<FormState>();
  String _selectedType = '';
  String _typeError = '';
  String _locationError = '';

  String _selectedPlaceType = '';
  String _username = '';
  String _mobile = '';
  String _placeName = '';
  LatLng _location = LatLng(0, 0);

  _validate() {
    setState(() {
      _typeError = '';
      _locationError = '';
    });
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (_selectedPlaceType != '') {
        if (_location.latitude != 0 && _location.longitude != 0) return true;
        setState(() {
          _locationError = EasyLocalization.of(context)
              .delegate
              .translations
              .get('location_error');
        });
        return false;
      }
      setState(() {
        _typeError = EasyLocalization.of(context)
            .delegate
            .translations
            .get('type_error');
      });
      return false;
    }
    return false;
  }

  _validateAndSubmit() {
    if (_validate()) {
      try {
        Firestore.instance.collection('suggestion').add({
          'placeType': _selectedPlaceType,
          'username': _username,
          'contact': _mobile,
          'placeName': _placeName,
          'location': GeoPoint(_location.latitude, _location.longitude)
        }).then((value) {
          if (value.documentID != null && value.documentID != '')
            _showSuccessDialog(context);
          else
            _showWrongDialog(context);
        });
      } catch (e) {
        print('Error: $e');
        _showWrongDialog(context);
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Icon(Icons.cloud_done),
          content: new Text(EasyLocalization.of(context)
              .delegate
              .translations
              .get('submitted_successfully')),
          actions: <Widget>[
            new FlatButton(
              child: new Text(EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('close')),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showWrongDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Icon(Icons.warning),
          content: new Text(EasyLocalization.of(context)
              .delegate
              .translations
              .get('something_went_wrong')),
          actions: <Widget>[
            new FlatButton(
              child: new Text(EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          EasyLocalization.of(context)
              .delegate
              .translations
              .get('missing_place_suggestion'),
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.grey[700],
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: EasyLocalization.of(context)
                          .delegate
                          .translations
                          .get('your_name'),
                      border: OutlineInputBorder(
                        borderSide: new BorderSide(),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    validator: (value) {
                      if (value.isEmpty)
                        return EasyLocalization.of(context)
                            .delegate
                            .translations
                            .get('please_enter_your_name');
                      if (value.trim().length > 20)
                        return EasyLocalization.of(context)
                            .delegate
                            .translations
                            .get('your_name_is_too_long');
                      return null;
                    },
                    onSaved: (value) => _username = value.trim(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: EasyLocalization.of(context)
                          .delegate
                          .translations
                          .get('mobile_number'),
                      border: OutlineInputBorder(
                        borderSide: new BorderSide(),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    validator: (value) {
                      if (value.isEmpty)
                        return EasyLocalization.of(context)
                            .delegate
                            .translations
                            .get('please_enter_your_mobile_number');
                      if (value.trim().length != 10)
                        return EasyLocalization.of(context)
                            .delegate
                            .translations
                            .get('please_enter_10_digit_number');
                      return null;
                    },
                    onSaved: (value) => _mobile = value.trim(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: RaisedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(EasyLocalization.of(context)
                                .delegate
                                .translations
                                .get('select_type')),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text('ATM'),
                                  onTap: () {
                                    setState(() {
                                      _selectedType = 'ATM';
                                      _selectedPlaceType = 'atm';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  title: Text('Bank Branch'),
                                  onTap: () {
                                    setState(() {
                                      _selectedType = 'Bank Branch';
                                      _selectedPlaceType = 'bank';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  title: Text('Bank Mitra'),
                                  onTap: () {
                                    setState(() {
                                      _selectedType = 'Bank Mitra';
                                      _selectedPlaceType = 'bank-mitra';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  title: Text('Post Office'),
                                  onTap: () {
                                    setState(() {
                                      _selectedType = 'Post Office';
                                      _selectedPlaceType = 'post-office';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  title: Text('CSC'),
                                  onTap: () {
                                    setState(() {
                                      _selectedType = 'CSC';
                                      _selectedPlaceType = 'csc';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        children: [
                          Text(
                            EasyLocalization.of(context)
                                .delegate
                                .translations
                                .get('type'),
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(' : '),
                          SizedBox(width: 10),
                          Text(
                            _selectedType,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _typeError.length > 2
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          _typeError,
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: RaisedButton(
                    onPressed: () async {
                      await Geolocator()
                          .getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.high,
                      )
                          .then((value) {
                        setState(() {
                          _location = LatLng(value.latitude, value.longitude);
                        });
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(EasyLocalization.of(context)
                                      .delegate
                                      .translations
                                      .get('location')),
                                  OutlineButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      EasyLocalization.of(context)
                                          .delegate
                                          .translations
                                          .get('done'),
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                              content: Container(
                                height: MediaQuery.of(context).size.width,
                                width: MediaQuery.of(context).size.width,
                                child: Stack(
                                  children: [
                                    GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                            value.latitude, value.longitude),
                                        zoom: 14,
                                      ),
                                      onCameraMove: (position) {
                                        setState(() {
                                          _location = position.target;
                                        });
                                      },
                                    ),
                                    Center(
                                      child: Icon(
                                        Icons.room,
                                        size: 40,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        children: [
                          Text(
                            EasyLocalization.of(context)
                                .delegate
                                .translations
                                .get('location'),
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(' : '),
                          SizedBox(width: 10),
                          Text(
                            _location.latitude.toStringAsFixed(4) +
                                ' , ' +
                                _location.longitude.toStringAsFixed(4),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _locationError.length > 2
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          _locationError,
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: EasyLocalization.of(context)
                          .delegate
                          .translations
                          .get('missing_place_name'),
                      border: OutlineInputBorder(
                        borderSide: new BorderSide(),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    validator: (value) {
                      if (value.isEmpty)
                        return EasyLocalization.of(context)
                            .delegate
                            .translations
                            .get('please_enter_place_name');
                      if (value.trim().length > 50)
                        return EasyLocalization.of(context)
                            .delegate
                            .translations
                            .get('place_name_is_too_long');
                      return null;
                    },
                    onSaved: (value) => _placeName = value.trim(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                    alignment: Alignment.center,
                    child: RaisedButton(
                      color: Colors.blue[400],
                      onPressed: _validateAndSubmit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          EasyLocalization.of(context)
                              .delegate
                              .translations
                              .get('submit'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

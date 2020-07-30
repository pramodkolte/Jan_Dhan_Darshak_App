import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FeedbackTo extends StatefulWidget {
  final String id;
  final String type;
  final String placeName;

  const FeedbackTo({Key key, this.id, this.type, this.placeName})
      : super(key: key);
  @override
  _FeedbackToState createState() => _FeedbackToState();
}

class _FeedbackToState extends State<FeedbackTo> {
  final _formKey = new GlobalKey<FormState>();
  String _selectedFeedback = 'Select';
  String _typeError = '';
  String _username = '';
  String _mobile = '';
  String _feedback = '';

  _validate() {
    setState(() {
      _typeError = '';
    });
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (_selectedFeedback != 'Select') {
        return true;
      }
      setState(() {
        _typeError = EasyLocalization.of(context)
            .delegate
            .translations
            .get('please_select_feedback_type');
      });
      return false;
    }
    return false;
  }

  _validateAndSubmit() {
    if (_validate()) {
      try {
        Firestore.instance.collection('feedback').add({
          'username': _username,
          'contact': _mobile,
          'feedback': _feedback,
          'selectedFeedback': _selectedFeedback,
          'placeId': widget.id,
          'placeType': widget.type
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
          EasyLocalization.of(context).delegate.translations.get('feedback'),
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
                  child: Card(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            widget.placeName,
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(EasyLocalization.of(context)
                                .delegate
                                .translations
                                .get('select')),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text('Satisfied'),
                                  onTap: () {
                                    setState(() {
                                      _selectedFeedback = 'Satisfied';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  title: Text('Wrong Location'),
                                  onTap: () {
                                    setState(() {
                                      _selectedFeedback = 'Wrong Location';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  title: Text('Wrong Attributes'),
                                  onTap: () {
                                    setState(() {
                                      _selectedFeedback = 'Wrong Attributes';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  title: Text('Permanently Closed'),
                                  onTap: () {
                                    setState(() {
                                      _selectedFeedback = 'Permanently Closed';
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  title: Text('Other'),
                                  onTap: () {
                                    setState(() {
                                      _selectedFeedback = 'Other';
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
                        children: <Widget>[
                          Text(
                            _selectedFeedback,
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
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: EasyLocalization.of(context)
                          .delegate
                          .translations
                          .get('description'),
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
                            .get('please_enter_description');
                      if (value.trim().length > 50)
                        return EasyLocalization.of(context)
                            .delegate
                            .translations
                            .get('description_is_too_long');
                      return null;
                    },
                    onSaved: (value) => _feedback = value.trim(),
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

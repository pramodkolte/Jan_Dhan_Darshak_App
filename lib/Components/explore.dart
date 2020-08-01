import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jan_dhan_darshak/services/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class ExploreSheetAtm extends StatefulWidget {
  final Function(double, double, String) placeClick;
  final Function(Position, Position) directionClick;
  final myPosition;
  const ExploreSheetAtm(
      {Key key, this.placeClick, this.myPosition, this.directionClick})
      : super(key: key);
  @override
  _ExploreSheetAtmState createState() => _ExploreSheetAtmState();
}

class _ExploreSheetAtmState extends State<ExploreSheetAtm> {
  Firestore _firestore = Firestore.instance;
  List<Atm> atms = [];
  final ValueNotifier<bool> searchFieldVisibility = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    atms.clear();
    _firestore.collection('atm').getDocuments().then(
      (docs) {
        if (docs.documents.isNotEmpty) {
          for (int i = 0; i < docs.documents.length; i++) {
            var ftp = docs.documents[i].data;
            Geolocator()
                .distanceBetween(
                    widget.myPosition.latitude,
                    widget.myPosition.longitude,
                    ftp['latlong'].latitude,
                    ftp['latlong'].longitude)
                .then((value) {
              final Atm atm = Atm(
                documentId: docs.documents[i].documentID,
                latitude: ftp['latlong'].latitude,
                longitude: ftp['latlong'].longitude,
                atmCode: ftp['atm_code'],
                bank: ftp['bank'],
                pincode: ftp['pincode'],
                atmTiming: ftp['atm_timings'],
                address: ftp['address'],
                city: ftp['city'],
                district: ftp['district'],
                state: ftp['state'],
                distance: value,
              );
              setState(() {
                atms.add(atm);
                atms.sort((a, b) => a.distance.compareTo(b.distance));
              });
            });
          }
        }
      },
    );
  }

  @override
  void dispose() {
    searchFieldVisibility.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent == 1.0) {
          searchFieldVisibility.value = true;
        } else {
          searchFieldVisibility.value = false;
        }
        return true;
      },
      child: DraggableScrollableActuator(
        child: Stack(
          children: <Widget>[
            DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.1,
              maxChildSize: 1.0,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300],
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: atms.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (atms.length == 0) {
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Center(
                              child: Text('No ATM within 10 km'),
                            ),
                          ),
                        );
                      }
                      if (index == 0) {
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 5,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              SizedBox(
                                height: 12.0,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 24.0,
                                  right: 24.0,
                                ),
                                child: Text(
                                  EasyLocalization.of(context)
                                      .delegate
                                      .translations
                                      .get('nearby_atms'),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                            ],
                          ),
                        );
                      }
                      return _nearbyAtm(index - 1, context);
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                );
              },
            ),
            Positioned(
              left: 0.0,
              top: 0.0,
              right: 0.0,
              child: ValueListenableBuilder<bool>(
                valueListenable: searchFieldVisibility,
                builder: (context, value, child) {
                  return value
                      ? PreferredSize(
                          preferredSize: Size.fromHeight(65.0),
                          child: Container(
                            padding:
                                EdgeInsets.only(top: 30, left: 16, right: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              border: Border(
                                bottom: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context).dividerColor),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[300],
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(-1, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Text(
                                    EasyLocalization.of(context)
                                        .delegate
                                        .translations
                                        .get('nearby_atms'),
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  onPressed: () {
                                    searchFieldVisibility.value = false;
                                    DraggableScrollableActuator.reset(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDistance(distance) {
    String string = '';
    if (distance < 1000) {
      string = '($distance m)';
    } else {
      var dist = (distance / 1000).toStringAsFixed(1);
      string = '($dist km)';
    }
    return string;
  }

  _nearbyAtm(int index, BuildContext context) {
    return ListTile(
      onTap: () {
        searchFieldVisibility.value = false;
        DraggableScrollableActuator.reset(context);
        widget.placeClick(atms[index].latitude, atms[index].longitude,
            atms[index].documentId);
      },
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atms[index].bank + ' ATM',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  _getDistance(atms[index].distance.floor()),
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  atms[index].address,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Open ' + atms[index].atmTiming,
                  style: TextStyle(
                    color: Colors.green[400],
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: InkWell(
                    onTap: () {
                      searchFieldVisibility.value = false;
                      DraggableScrollableActuator.reset(context);
                      widget.directionClick(
                          widget.myPosition,
                          Position(
                              latitude: atms[index].latitude,
                              longitude: atms[index].longitude));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.directions,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  child: InkWell(
                    onTap: () {
                      launch('tel:9922783755');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.call,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreSheetBank extends StatefulWidget {
  final Function(double, double, String) placeClick;
  final Function(Position, Position) directionClick;
  final myPosition;
  const ExploreSheetBank(
      {Key key, this.placeClick, this.myPosition, this.directionClick})
      : super(key: key);
  @override
  _ExploreSheetBankState createState() => _ExploreSheetBankState();
}

class _ExploreSheetBankState extends State<ExploreSheetBank> {
  Firestore _firestore = Firestore.instance;
  List<Bank> banks = [];
  final ValueNotifier<bool> searchFieldVisibility = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    banks.clear();
    _firestore.collection('bank').getDocuments().then(
      (docs) {
        if (docs.documents.isNotEmpty) {
          for (int i = 0; i < docs.documents.length; i++) {
            var ftp = docs.documents[i].data;
            Geolocator()
                .distanceBetween(
                    widget.myPosition.latitude,
                    widget.myPosition.longitude,
                    ftp['latlong'].latitude,
                    ftp['latlong'].longitude)
                .then((value) {
              final Bank bank = Bank(
                documentId: docs.documents[i].documentID,
                latitude: ftp['latlong'].latitude,
                longitude: ftp['latlong'].longitude,
                ifscCode: ftp['ifscCode'],
                bankName: ftp['bank_name'],
                branch: ftp['branch'],
                bsrCode: ftp['bsrCode'],
                pincode: ftp['pincode'],
                bankTiming: ftp['bank_timings'],
                address: ftp['address'],
                city: ftp['city'],
                district: ftp['district'],
                state: ftp['state'],
                distance: value,
              );
              setState(() {
                banks.add(bank);
                banks.sort((a, b) => a.distance.compareTo(b.distance));
              });
            });
          }
        }
      },
    );
  }

  @override
  void dispose() {
    searchFieldVisibility.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent == 1.0) {
          searchFieldVisibility.value = true;
        } else {
          searchFieldVisibility.value = false;
        }
        return true;
      },
      child: DraggableScrollableActuator(
        child: Stack(
          children: <Widget>[
            DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.1,
              maxChildSize: 1.0,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300],
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: banks.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (banks.length == 0) {
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Center(
                              child: Text('No ATM within 10 km'),
                            ),
                          ),
                        );
                      }
                      if (index == 0) {
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 5,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              SizedBox(
                                height: 12.0,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 24.0,
                                  right: 24.0,
                                ),
                                child: Text(
                                  EasyLocalization.of(context)
                                      .delegate
                                      .translations
                                      .get('nearby_banks'),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                            ],
                          ),
                        );
                      }
                      return _nearbyBank(index - 1, context);
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                );
              },
            ),
            Positioned(
              left: 0.0,
              top: 0.0,
              right: 0.0,
              child: ValueListenableBuilder<bool>(
                valueListenable: searchFieldVisibility,
                builder: (context, value, child) {
                  return value
                      ? PreferredSize(
                          preferredSize: Size.fromHeight(65.0),
                          child: Container(
                            padding:
                                EdgeInsets.only(top: 30, left: 16, right: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context).dividerColor),
                              ),
                              color: Theme.of(context).colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[300],
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(-1, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Text(
                                    EasyLocalization.of(context)
                                        .delegate
                                        .translations
                                        .get('nearby_banks'),
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  onPressed: () {
                                    searchFieldVisibility.value = false;
                                    DraggableScrollableActuator.reset(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDistance(distance) {
    String string = '';
    if (distance < 1000) {
      string = '($distance m)';
    } else {
      var dist = (distance / 1000).toStringAsFixed(1);
      string = '($dist km)';
    }
    return string;
  }

  _nearbyBank(int index, BuildContext context) {
    return ListTile(
      onTap: () {
        searchFieldVisibility.value = false;
        DraggableScrollableActuator.reset(context);
        widget.placeClick(banks[index].latitude, banks[index].longitude,
            banks[index].documentId);
      },
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banks[index].bankName,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  _getDistance(banks[index].distance.floor()),
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  banks[index].address,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Open ' + banks[index].bankTiming,
                  style: TextStyle(
                    color: Colors.green[400],
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: InkWell(
                    onTap: () {
                      searchFieldVisibility.value = false;
                      DraggableScrollableActuator.reset(context);
                      widget.directionClick(
                          widget.myPosition,
                          Position(
                              latitude: banks[index].latitude,
                              longitude: banks[index].longitude));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.directions,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  child: InkWell(
                    onTap: () {
                      launch('tel:9922783755');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.call,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreSheetBankMitra extends StatefulWidget {
  final Function(double, double, String) placeClick;
  final Function(Position, Position) directionClick;
  final myPosition;
  const ExploreSheetBankMitra(
      {Key key, this.placeClick, this.myPosition, this.directionClick})
      : super(key: key);
  @override
  _ExploreSheetBankMitraState createState() => _ExploreSheetBankMitraState();
}

class _ExploreSheetBankMitraState extends State<ExploreSheetBankMitra> {
  Firestore _firestore = Firestore.instance;
  List<BankMitra> bankmitras = [];
  final ValueNotifier<bool> searchFieldVisibility = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    bankmitras.clear();
    _firestore.collection('bank-mitra').getDocuments().then(
      (docs) {
        if (docs.documents.isNotEmpty) {
          for (int i = 0; i < docs.documents.length; i++) {
            var ftp = docs.documents[i].data;
            Geolocator()
                .distanceBetween(
                    widget.myPosition.latitude,
                    widget.myPosition.longitude,
                    ftp['latlong'].latitude,
                    ftp['latlong'].longitude)
                .then((value) {
              final BankMitra bankMitra = BankMitra(
                documentId: docs.documents[i].documentID,
                latitude: ftp['latlong'].latitude,
                longitude: ftp['latlong'].longitude,
                mitraName: ftp['bankMitraName'],
                bankName: ftp['bank_name'],
                bankMitraCode: ftp['bankMitraCode'],
                contact: ftp['contact'],
                pincode: ftp['pincode'],
                address: ftp['address'],
                district: ftp['district'],
                state: ftp['state'],
                distance: value,
              );
              setState(() {
                bankmitras.add(bankMitra);
                bankmitras.sort((a, b) => a.distance.compareTo(b.distance));
              });
            });
          }
        }
      },
    );
  }

  @override
  void dispose() {
    searchFieldVisibility.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent == 1.0) {
          searchFieldVisibility.value = true;
        } else {
          searchFieldVisibility.value = false;
        }
        return true;
      },
      child: DraggableScrollableActuator(
        child: Stack(
          children: <Widget>[
            DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.1,
              maxChildSize: 1.0,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300],
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: bankmitras.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (bankmitras.length == 0) {
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Center(
                              child: Text('No ATM within 10 km'),
                            ),
                          ),
                        );
                      }
                      if (index == 0) {
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 5,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              SizedBox(
                                height: 12.0,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 24.0,
                                  right: 24.0,
                                ),
                                child: Text(
                                  EasyLocalization.of(context)
                                      .delegate
                                      .translations
                                      .get('nearby_bankmitras'),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                            ],
                          ),
                        );
                      }
                      return _nearbyBankMitra(index - 1, context);
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                );
              },
            ),
            Positioned(
              left: 0.0,
              top: 0.0,
              right: 0.0,
              child: ValueListenableBuilder<bool>(
                valueListenable: searchFieldVisibility,
                builder: (context, value, child) {
                  return value
                      ? PreferredSize(
                          preferredSize: Size.fromHeight(65.0),
                          child: Container(
                            padding:
                                EdgeInsets.only(top: 30, left: 16, right: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context).dividerColor),
                              ),
                              color: Theme.of(context).colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[300],
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(-1, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Text(
                                    EasyLocalization.of(context)
                                        .delegate
                                        .translations
                                        .get('nearby_bankmitras'),
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  onPressed: () {
                                    searchFieldVisibility.value = false;
                                    DraggableScrollableActuator.reset(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDistance(distance) {
    String string = '';
    if (distance < 1000) {
      string = '($distance m)';
    } else {
      var dist = (distance / 1000).toStringAsFixed(1);
      string = '($dist km)';
    }
    return string;
  }

  _nearbyBankMitra(int index, BuildContext context) {
    return ListTile(
      onTap: () {
        searchFieldVisibility.value = false;
        DraggableScrollableActuator.reset(context);
        widget.placeClick(bankmitras[index].latitude,
            bankmitras[index].longitude, bankmitras[index].documentId);
      },
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankmitras[index].bankName,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  bankmitras[index].mitraName,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.blue[400],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  _getDistance(bankmitras[index].distance.floor()),
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  bankmitras[index].address,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Open 10:00AM to 5:00PM',
                  style: TextStyle(
                    color: Colors.green[400],
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: InkWell(
                    onTap: () {
                      searchFieldVisibility.value = false;
                      DraggableScrollableActuator.reset(context);
                      widget.directionClick(
                          widget.myPosition,
                          Position(
                              latitude: bankmitras[index].latitude,
                              longitude: bankmitras[index].longitude));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.directions,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  child: InkWell(
                    onTap: () {
                      launch('tel:9922783755');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.call,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreSheetPostOffice extends StatefulWidget {
  final Function(double, double, String) placeClick;
  final Function(Position, Position) directionClick;
  final myPosition;
  const ExploreSheetPostOffice(
      {Key key, this.placeClick, this.myPosition, this.directionClick})
      : super(key: key);
  @override
  _ExploreSheetPostOfficeState createState() => _ExploreSheetPostOfficeState();
}

class _ExploreSheetPostOfficeState extends State<ExploreSheetPostOffice> {
  Firestore _firestore = Firestore.instance;
  List<PostOffice> postoffices = [];
  final ValueNotifier<bool> searchFieldVisibility = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    postoffices.clear();
    _firestore.collection('post-office').getDocuments().then(
      (docs) {
        if (docs.documents.isNotEmpty) {
          for (int i = 0; i < docs.documents.length; i++) {
            var ftp = docs.documents[i].data;
            Geolocator()
                .distanceBetween(
                    widget.myPosition.latitude,
                    widget.myPosition.longitude,
                    ftp['latlong'].latitude,
                    ftp['latlong'].longitude)
                .then((value) {
              final PostOffice postOffice = PostOffice(
                documentId: docs.documents[i].documentID,
                latitude: ftp['latlong'].latitude,
                longitude: ftp['latlong'].longitude,
                type: ftp['type'],
                name: ftp['name'],
                pincode: ftp['pincode'],
                district: ftp['district'],
                state: ftp['state'],
                distance: value,
              );
              setState(() {
                postoffices.add(postOffice);
                postoffices.sort((a, b) => a.distance.compareTo(b.distance));
              });
            });
          }
        }
      },
    );
  }

  @override
  void dispose() {
    searchFieldVisibility.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent == 1.0) {
          searchFieldVisibility.value = true;
        } else {
          searchFieldVisibility.value = false;
        }
        return true;
      },
      child: DraggableScrollableActuator(
        child: Stack(
          children: <Widget>[
            DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.1,
              maxChildSize: 1.0,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300],
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: postoffices.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (postoffices.length == 0) {
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Center(
                              child: Text('No ATM within 10 km'),
                            ),
                          ),
                        );
                      }
                      if (index == 0) {
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 5,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              SizedBox(
                                height: 12.0,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 24.0,
                                  right: 24.0,
                                ),
                                child: Text(
                                  EasyLocalization.of(context)
                                      .delegate
                                      .translations
                                      .get('nearby_postoffices'),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                            ],
                          ),
                        );
                      }
                      return _nearbyPostOffice(index - 1, context);
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                );
              },
            ),
            Positioned(
              left: 0.0,
              top: 0.0,
              right: 0.0,
              child: ValueListenableBuilder<bool>(
                valueListenable: searchFieldVisibility,
                builder: (context, value, child) {
                  return value
                      ? PreferredSize(
                          preferredSize: Size.fromHeight(65.0),
                          child: Container(
                            padding:
                                EdgeInsets.only(top: 30, left: 16, right: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context).dividerColor),
                              ),
                              color: Theme.of(context).colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[300],
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(-1, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Text(
                                    EasyLocalization.of(context)
                                        .delegate
                                        .translations
                                        .get('nearby_postoffices'),
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  onPressed: () {
                                    searchFieldVisibility.value = false;
                                    DraggableScrollableActuator.reset(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDistance(distance) {
    String string = '';
    if (distance < 1000) {
      string = '($distance m)';
    } else {
      var dist = (distance / 1000).toStringAsFixed(1);
      string = '($dist km)';
    }
    return string;
  }

  _nearbyPostOffice(int index, BuildContext context) {
    return ListTile(
      onTap: () {
        searchFieldVisibility.value = false;
        DraggableScrollableActuator.reset(context);
        widget.placeClick(postoffices[index].latitude,
            postoffices[index].longitude, postoffices[index].documentId);
      },
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  postoffices[index].name,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  _getDistance(postoffices[index].distance.floor()),
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'This is the sample post office address. Demonstration purpose only.',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Open 10:00AM to 5:00PM',
                  style: TextStyle(
                    color: Colors.green[400],
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: InkWell(
                    onTap: () {
                      searchFieldVisibility.value = false;
                      DraggableScrollableActuator.reset(context);
                      widget.directionClick(
                          widget.myPosition,
                          Position(
                              latitude: postoffices[index].latitude,
                              longitude: postoffices[index].longitude));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.directions,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  child: InkWell(
                    onTap: () {
                      launch('tel:9922783755');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.call,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreSheetCsc extends StatefulWidget {
  final Function(double, double, String) placeClick;
  final Function(Position, Position) directionClick;
  final myPosition;
  const ExploreSheetCsc(
      {Key key, this.placeClick, this.myPosition, this.directionClick})
      : super(key: key);
  @override
  _ExploreSheetCscState createState() => _ExploreSheetCscState();
}

class _ExploreSheetCscState extends State<ExploreSheetCsc> {
  Firestore _firestore = Firestore.instance;
  List<Csc> cscs = [];
  final ValueNotifier<bool> searchFieldVisibility = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    cscs.clear();
    _firestore.collection('csc').getDocuments().then(
      (docs) {
        if (docs.documents.isNotEmpty) {
          for (int i = 0; i < docs.documents.length; i++) {
            var ftp = docs.documents[i].data;
            Geolocator()
                .distanceBetween(
                    widget.myPosition.latitude,
                    widget.myPosition.longitude,
                    ftp['latlong'].latitude,
                    ftp['latlong'].longitude)
                .then((value) {
              final Csc csc = Csc(
                documentId: docs.documents[i].documentID,
                latitude: ftp['latlong'].latitude,
                longitude: ftp['latlong'].longitude,
                id: ftp['id'],
                name: ftp['name'],
                type: ftp['type'],
                block: ftp['block'],
                address: ftp['address'],
                district: ftp['district'],
                state: ftp['state'],
                distance: value,
              );
              setState(() {
                cscs.add(csc);
                cscs.sort((a, b) => a.distance.compareTo(b.distance));
              });
            });
          }
        }
      },
    );
  }

  @override
  void dispose() {
    searchFieldVisibility.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if (notification.extent == 1.0) {
          searchFieldVisibility.value = true;
        } else {
          searchFieldVisibility.value = false;
        }
        return true;
      },
      child: DraggableScrollableActuator(
        child: Stack(
          children: <Widget>[
            DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.1,
              maxChildSize: 1.0,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300],
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: cscs.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (cscs.length == 0) {
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: Center(
                              child: Text('No ATM within 10 km'),
                            ),
                          ),
                        );
                      }
                      if (index == 0) {
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 5,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              SizedBox(
                                height: 12.0,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 24.0,
                                  right: 24.0,
                                ),
                                child: Text(
                                  EasyLocalization.of(context)
                                      .delegate
                                      .translations
                                      .get('nearby_cscs'),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                            ],
                          ),
                        );
                      }
                      return _nearbyCsc(index - 1, context);
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                );
              },
            ),
            Positioned(
              left: 0.0,
              top: 0.0,
              right: 0.0,
              child: ValueListenableBuilder<bool>(
                valueListenable: searchFieldVisibility,
                builder: (context, value, child) {
                  return value
                      ? PreferredSize(
                          preferredSize: Size.fromHeight(65.0),
                          child: Container(
                            padding:
                                EdgeInsets.only(top: 30, left: 16, right: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context).dividerColor),
                              ),
                              color: Theme.of(context).colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[300],
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(-1, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Center(
                                  child: Text(
                                    EasyLocalization.of(context)
                                        .delegate
                                        .translations
                                        .get('nearby_cscs'),
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  onPressed: () {
                                    searchFieldVisibility.value = false;
                                    DraggableScrollableActuator.reset(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDistance(distance) {
    String string = '';
    if (distance < 1000) {
      string = '($distance m)';
    } else {
      var dist = (distance / 1000).toStringAsFixed(1);
      string = '($dist km)';
    }
    return string;
  }

  _nearbyCsc(int index, BuildContext context) {
    return ListTile(
      onTap: () {
        searchFieldVisibility.value = false;
        DraggableScrollableActuator.reset(context);
        widget.placeClick(cscs[index].latitude, cscs[index].longitude,
            cscs[index].documentId);
      },
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cscs[index].name,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  _getDistance(cscs[index].distance.floor()),
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  cscs[index].address,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Open 10:00AM to 5:00PM',
                  style: TextStyle(
                    color: Colors.green[400],
                    fontSize: 15.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: InkWell(
                    onTap: () {
                      searchFieldVisibility.value = false;
                      DraggableScrollableActuator.reset(context);
                      widget.directionClick(
                          widget.myPosition,
                          Position(
                              latitude: cscs[index].latitude,
                              longitude: cscs[index].longitude));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.directions,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  child: InkWell(
                    onTap: () {
                      launch('tel:9922783755');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.call,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

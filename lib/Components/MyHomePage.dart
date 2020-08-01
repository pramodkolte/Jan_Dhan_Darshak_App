import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jan_dhan_darshak/Components/MyDrawer.dart';
import 'package:jan_dhan_darshak/Components/explore.dart';
import 'package:jan_dhan_darshak/Pages/Feedback.dart';
import 'package:jan_dhan_darshak/Pages/search.dart';
import 'package:jan_dhan_darshak/services/models.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  final Position position;

  const MyHomePage({Key key, this.position}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController mapController;

  CameraPosition _initialPosition;
  //CameraPosition _lastMapPosition;
  MapType _currentMapType = MapType.normal;
  Firestore _firestore = Firestore.instance;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  List<Ftp> _ftps = [];
  CurrentFtp currentFtp;
  int _selectedIndex = 0;
  bool _isSearch = false;
  bool _isText;
  bool _showHeader = true;

  _placeClickCallBack(double latitude, double longitude, String markerId) {
    if (_isSearch) {
      setState(() {
        _isSearch = false;
      });
    }
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(latitude, longitude),
          zoom: 15.0,
        ),
      ),
    );
    mapController.showMarkerInfoWindow(MarkerId(markerId));
  }

  _searchCancelCallBack() {
    setState(() {
      _isSearch = false;
    });
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
    getFtps();
  }

  _onCameraMove(CameraPosition position) {
    //_lastMapPosition = position;
  }

  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  _onMenuButtonPressed() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return MyDrawer();
      },
    );
  }

  void _currentLocation() async {
    Position currentLocation = await Geolocator().getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _initialPosition = CameraPosition(
        target: LatLng(
          widget.position.latitude,
          widget.position.longitude,
        ),
        zoom: 15,
      );
      currentFtp = CurrentFtp.ATM;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildGoogleMap(),
          _showHeader ? _buildSafeArea(context) : Container(),
          IndexedStack(
            index: _selectedIndex,
            children: [
              ExploreSheetAtm(
                  placeClick: _placeClickCallBack,
                  myPosition: widget.position,
                  directionClick: _createPolylines),
              ExploreSheetBank(
                  placeClick: _placeClickCallBack,
                  myPosition: widget.position,
                  directionClick: _createPolylines),
              ExploreSheetBankMitra(
                  placeClick: _placeClickCallBack,
                  myPosition: widget.position,
                  directionClick: _createPolylines),
              ExploreSheetPostOffice(
                  placeClick: _placeClickCallBack,
                  myPosition: widget.position,
                  directionClick: _createPolylines),
              ExploreSheetCsc(
                  placeClick: _placeClickCallBack,
                  myPosition: widget.position,
                  directionClick: _createPolylines),
            ],
          ),
          _isSearch
              ? SearchPage(
                  ftps: _ftps,
                  isText: _isText,
                  searchCancelCallBack: _searchCancelCallBack,
                  placeClick: _placeClickCallBack,
                )
              : Container(),
        ],
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        itemCornerRadius: 8,
        curve: Curves.easeInBack,
        onItemSelected: (index) {
          if (_selectedIndex != index) {
            setState(() {
              _selectedIndex = index;
              currentFtp = CurrentFtp.values.elementAt(index);
              polylines.clear();
            });
            getFtps();
          }
        },
        items: [
          _barIteam(
              EasyLocalization.of(context).delegate.translations.get('atm'),
              Icons.monetization_on,
              Colors.blue[300]),
          _barIteam(
              EasyLocalization.of(context).delegate.translations.get('bank'),
              Icons.account_balance,
              Colors.pinkAccent),
          _barIteam(
              EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('bank_mitra'),
              Icons.person_pin,
              Colors.deepOrange[300]),
          _barIteam(
              EasyLocalization.of(context)
                  .delegate
                  .translations
                  .get('post_office'),
              Icons.local_post_office,
              Colors.green[300]),
          _barIteam(
              EasyLocalization.of(context).delegate.translations.get('csc'),
              Icons.supervised_user_circle,
              Colors.purpleAccent[100]),
        ],
      ),
    );
  }

  GoogleMap _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: _initialPosition,
      markers: Set<Marker>.of(markers.values),
      polylines: Set<Polyline>.of(polylines.values),
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      mapType: _currentMapType,
      compassEnabled: false,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: false,
      onTap: (argument) {
        setState(() {
          _showHeader = !_showHeader;
        });
      },
    );
  }

  SafeArea _buildSafeArea(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: _onMenuButtonPressed,
                    ),
                    Expanded(
                      child: Hero(
                        tag: 'search',
                        child: GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              EasyLocalization.of(context)
                                  .delegate
                                  .translations
                                  .get('search_here'),
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 16),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _isText = true;
                              _isSearch = true;
                            });
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: () {
                        setState(() {
                          _isText = false;
                          _isSearch = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Column(
                children: <Widget>[
                  _optionButton(_onMapTypeButtonPressed, Icons.layers),
                  SizedBox(
                    height: 20,
                  ),
                  _optionButton(_currentLocation, Icons.near_me),
                ],
              ),
            ),
          ),
          Expanded(
            child: SizedBox(),
          ),
        ],
      ),
    );
  }

  Container _optionButton(Function _onPressed, IconData _iconData) {
    return Container(
      width: 45,
      height: 45,
      child: FloatingActionButton(
        onPressed: _onPressed,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        backgroundColor: Colors.white,
        elevation: 2,
        child: Icon(
          _iconData,
          size: 30,
          color: Colors.blue,
        ),
      ),
    );
  }

  BottomNavyBarItem _barIteam(String title, IconData myIcon, Color color) {
    return BottomNavyBarItem(
      icon: Icon(
        myIcon,
        color: Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      textAlign: TextAlign.center,
      activeColor: color,
      inactiveColor: color,
    );
  }

  _createPolylines(Position start, Position destination) {
    PolylineId id = PolylineId('poly');
    polylineCoordinates = [
      LatLng(start.latitude, start.longitude),
      LatLng(destination.latitude, destination.longitude),
    ];
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 3,
    );

    setState(() {
      polylines[id] = polyline;
      _showHeader = false;
    });

    Position _northeastCoordinates;
    Position _southwestCoordinates;

    if (start.latitude <= destination.latitude &&
        start.longitude <= destination.longitude) {
      _southwestCoordinates = start;
      _northeastCoordinates = destination;
    } else if (start.latitude > destination.latitude &&
        start.longitude <= destination.longitude) {
      _southwestCoordinates =
          Position(latitude: destination.latitude, longitude: start.longitude);
      _northeastCoordinates =
          Position(latitude: start.latitude, longitude: destination.longitude);
    } else if (start.latitude <= destination.latitude &&
        start.longitude > destination.longitude) {
      _southwestCoordinates =
          Position(latitude: start.latitude, longitude: destination.longitude);
      _northeastCoordinates =
          Position(latitude: destination.latitude, longitude: start.longitude);
    } else {
      _southwestCoordinates = destination;
      _northeastCoordinates = start;
    }

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(
            _northeastCoordinates.latitude,
            _northeastCoordinates.longitude,
          ),
          southwest: LatLng(
            _southwestCoordinates.latitude,
            _southwestCoordinates.longitude,
          ),
        ),
        50.0,
      ),
    );
  }

  getFtps() {
    markers.clear();
    _ftps.clear();
    switch (currentFtp) {
      case CurrentFtp.ATM:
        print('Fetching atms');
        _firestore.collection('atm').getDocuments().then((docs) {
          if (docs.documents.isNotEmpty) {
            for (int i = 0; i < docs.documents.length; i++) {
              final documentId = docs.documents[i].documentID;
              final MarkerId markerId = MarkerId(documentId);
              final ftp = docs.documents[i].data;
              String _distance = '';
              Geolocator()
                  .distanceBetween(
                      widget.position.latitude,
                      widget.position.longitude,
                      ftp['latlong'].latitude,
                      ftp['latlong'].longitude)
                  .then((value) {
                var distance = value.floor();

                if (distance < 1000)
                  _distance = '($distance m)';
                else {
                  var dist = (distance / 1000).toStringAsFixed(1);
                  _distance = '($dist km)';
                }

                final _ftp = Ftp(
                    ftpId: documentId,
                    name: ftp['bank'],
                    address: ftp['address'],
                    extra: ftp['city'],
                    latitude: ftp['latlong'].latitude,
                    longitude: ftp['latlong'].longitude);
                final Marker marker = Marker(
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure),
                    markerId: markerId,
                    position: LatLng(
                        ftp['latlong'].latitude, ftp['latlong'].longitude),
                    infoWindow: InfoWindow(
                        title: ftp['bank'] + ' ATM',
                        snippet: _distance,
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                    child: Column(children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(height: 8.0),
                                        Container(
                                            height: 5,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        SizedBox(height: 16.0),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Text(
                                              ftp['bank'] + ' ATM',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6,
                                            )),
                                        SizedBox(height: 8.0)
                                      ]),
                                  Divider(),
                                  Expanded(
                                      child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                        Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        _createPolylines(
                                                            widget.position,
                                                            Position(
                                                                latitude: _ftp
                                                                    .latitude,
                                                                longitude: _ftp
                                                                    .longitude));
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .directions,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Directions',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ])),
                                                  InkWell(
                                                      onTap: () {
                                                        launch(
                                                            'tel:9922783755');
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .call,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Call',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ])),
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => FeedbackTo(
                                                                    id:
                                                                        documentId,
                                                                    type: 'atm',
                                                                    placeName: ftp[
                                                                            'bank'] +
                                                                        ' ATM')));
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .feedback,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Feedback',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ]))
                                                ])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.room,
                                                color: Colors.blue),
                                            title: Text(ftp['address']),
                                            subtitle: Text(_distance)),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.more_vert,
                                                color: Colors.blue),
                                            title: Text(ftp['city'] +
                                                ', ' +
                                                ftp['district'] +
                                                ', ' +
                                                ftp['state'] +
                                                ', ' +
                                                ftp['pincode'].toString())),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.access_time,
                                                color: Colors.blue),
                                            title: Text(
                                                'Open ' + ftp['atm_timings'])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.call,
                                                color: Colors.blue),
                                            title: Text('1234567890')),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.code,
                                                color: Colors.blue),
                                            title: Text('ATM Code : ' +
                                                ftp['atm_code'])),
                                        SizedBox(height: 32.0)
                                      ]))
                                ]));
                              });
                        }));
                setState(() {
                  _ftps.add(_ftp);
                  markers[markerId] = marker;
                });
              });
            }
          }
        });
        break;
      case CurrentFtp.BANK:
        print('Fetching banks');
        _firestore.collection('bank').getDocuments().then((docs) {
          if (docs.documents.isNotEmpty) {
            for (int i = 0; i < docs.documents.length; i++) {
              final documentId = docs.documents[i].documentID;
              final MarkerId markerId = MarkerId(documentId);
              final ftp = docs.documents[i].data;
              String _distance = '';
              Geolocator()
                  .distanceBetween(
                      widget.position.latitude,
                      widget.position.longitude,
                      ftp['latlong'].latitude,
                      ftp['latlong'].longitude)
                  .then((value) {
                var distance = value.floor();

                if (distance < 1000)
                  _distance = '($distance m)';
                else {
                  var dist = (distance / 1000).toStringAsFixed(1);
                  _distance = '($dist km)';
                }
                final _ftp = Ftp(
                    ftpId: documentId,
                    name: ftp['bank_name'],
                    address: ftp['address'],
                    extra: ftp['city'],
                    latitude: ftp['latlong'].latitude,
                    longitude: ftp['latlong'].longitude);
                final Marker marker = Marker(
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRose),
                    markerId: markerId,
                    position: LatLng(
                        ftp['latlong'].latitude, ftp['latlong'].longitude),
                    infoWindow: InfoWindow(
                        title: ftp['bank_name'],
                        snippet: _distance,
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                    child: Column(children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(height: 8.0),
                                        Container(
                                            height: 5,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        SizedBox(height: 16.0),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Text(ftp['bank_name'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6)),
                                        SizedBox(height: 8.0)
                                      ]),
                                  Divider(),
                                  Expanded(
                                      child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                        Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        _createPolylines(
                                                            widget.position,
                                                            Position(
                                                                latitude: _ftp
                                                                    .latitude,
                                                                longitude: _ftp
                                                                    .longitude));
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .directions,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Directions',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ])),
                                                  InkWell(
                                                      onTap: () {
                                                        launch(
                                                            'tel:9922783755');
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .call,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Call',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ])),
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => FeedbackTo(
                                                                    id:
                                                                        documentId,
                                                                    type:
                                                                        'bank',
                                                                    placeName: ftp[
                                                                        'bank_name'])));
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .feedback,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Feedback',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ]))
                                                ])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.room,
                                                color: Colors.blue),
                                            title: Text(ftp['address']),
                                            subtitle: Text(_distance)),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.more_vert,
                                                color: Colors.blue),
                                            title: Text(ftp['city'] +
                                                ', ' +
                                                ftp['district'] +
                                                ', ' +
                                                ftp['state'] +
                                                ', ' +
                                                ftp['pincode'].toString())),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.access_time,
                                                color: Colors.blue),
                                            title: Text(
                                                'Open ' + ftp['bank_timings'])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.location_city,
                                                color: Colors.blue),
                                            title: Text(ftp['branch'])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.call,
                                                color: Colors.blue),
                                            title: Text(ftp['contact'])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.code,
                                                color: Colors.blue),
                                            title: Text('IFSC Code : ' +
                                                ftp['ifscCode'])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.code,
                                                color: Colors.blue),
                                            title: Text('BSR Code : ' +
                                                ftp['bsrCode'])),
                                        SizedBox(height: 32.0)
                                      ]))
                                ]));
                              });
                        }));
                setState(() {
                  _ftps.add(_ftp);
                  markers[markerId] = marker;
                });
              });
            }
          }
        });
        break;
      case CurrentFtp.BANK_MITRA:
        print('Fetching bank-mitra');
        _firestore.collection('bank-mitra').getDocuments().then((docs) {
          if (docs.documents.isNotEmpty) {
            for (int i = 0; i < docs.documents.length; i++) {
              final documentId = docs.documents[i].documentID;
              final MarkerId markerId = MarkerId(documentId);
              final ftp = docs.documents[i].data;
              String _distance = '';
              Geolocator()
                  .distanceBetween(
                      widget.position.latitude,
                      widget.position.longitude,
                      ftp['latlong'].latitude,
                      ftp['latlong'].longitude)
                  .then((value) {
                var distance = value.floor();

                if (distance < 1000)
                  _distance = '($distance m)';
                else {
                  var dist = (distance / 1000).toStringAsFixed(1);
                  _distance = '($dist km)';
                }
                final _ftp = Ftp(
                    ftpId: documentId,
                    name: ftp['bank_name'],
                    address: ftp['address'],
                    extra: ftp['bankMitraName'],
                    latitude: ftp['latlong'].latitude,
                    longitude: ftp['latlong'].longitude);
                final Marker marker = Marker(
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange),
                    markerId: markerId,
                    position: LatLng(
                        ftp['latlong'].latitude, ftp['latlong'].longitude),
                    infoWindow: InfoWindow(
                        title: ftp['bank_name'],
                        snippet: _distance,
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                    child: Column(children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(height: 8.0),
                                        Container(
                                            height: 5,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        SizedBox(height: 16.0),
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Text(ftp['bank_name'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6)),
                                        SizedBox(height: 8.0)
                                      ]),
                                  Divider(),
                                  Expanded(
                                      child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                        Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        _createPolylines(
                                                            widget.position,
                                                            Position(
                                                                latitude: _ftp
                                                                    .latitude,
                                                                longitude: _ftp
                                                                    .longitude));
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .directions,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Directions',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ])),
                                                  InkWell(
                                                      onTap: () {
                                                        launch(
                                                            'tel:9922783755');
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .call,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Call',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ])),
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => FeedbackTo(
                                                                    id:
                                                                        documentId,
                                                                    type:
                                                                        'bank-mitra',
                                                                    placeName: ftp[
                                                                        'bank_name'])));
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .feedback,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Feedback',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ]))
                                                ])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.room,
                                                color: Colors.blue),
                                            title: Text(ftp['address']),
                                            subtitle: Text(_distance)),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.more_vert,
                                                color: Colors.blue),
                                            title: Text(ftp['district'] +
                                                ', ' +
                                                ftp['state'] +
                                                ', ' +
                                                ftp['pincode'].toString())),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.access_time,
                                                color: Colors.blue),
                                            title:
                                                Text('Open 10:00AM To 5:00PM')),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.person,
                                                color: Colors.blue),
                                            title: Text(ftp['bankMitraName'])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.call,
                                                color: Colors.blue),
                                            title: Text(ftp['contact'])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.code,
                                                color: Colors.blue),
                                            title: Text('Bank Mitra Code : ' +
                                                ftp['bankMitraCode'])),
                                        SizedBox(height: 32.0)
                                      ]))
                                ]));
                              });
                        }));
                setState(() {
                  _ftps.add(_ftp);
                  markers[markerId] = marker;
                });
              });
            }
          }
        });
        break;
      case CurrentFtp.POST_OFFICE:
        print('Fetching post-office');
        _firestore.collection('post-office').getDocuments().then((docs) {
          if (docs.documents.isNotEmpty) {
            for (int i = 0; i < docs.documents.length; i++) {
              final documentId = docs.documents[i].documentID;
              final MarkerId markerId = MarkerId(documentId);
              final ftp = docs.documents[i].data;
              String _distance = '';
              Geolocator()
                  .distanceBetween(
                      widget.position.latitude,
                      widget.position.longitude,
                      ftp['latlong'].latitude,
                      ftp['latlong'].longitude)
                  .then((value) {
                var distance = value.floor();

                if (distance < 1000)
                  _distance = '($distance m)';
                else {
                  var dist = (distance / 1000).toStringAsFixed(1);
                  _distance = '($dist km)';
                }
                final _ftp = Ftp(
                    ftpId: documentId,
                    name: ftp['name'],
                    address: ftp['address'],
                    extra: ftp['block'],
                    latitude: ftp['latlong'].latitude,
                    longitude: ftp['latlong'].longitude);
                final Marker marker = Marker(
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                    markerId: markerId,
                    position: LatLng(
                        ftp['latlong'].latitude, ftp['latlong'].longitude),
                    infoWindow: InfoWindow(
                        title: ftp['name'],
                        snippet: _distance,
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                    child: Column(children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(height: 8.0),
                                        Container(
                                            height: 5,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        SizedBox(height: 16.0),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Text(ftp['name'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6),
                                        ),
                                        SizedBox(height: 8.0)
                                      ]),
                                  Divider(),
                                  Expanded(
                                      child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                        Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        _createPolylines(
                                                            widget.position,
                                                            Position(
                                                                latitude: _ftp
                                                                    .latitude,
                                                                longitude: _ftp
                                                                    .longitude));
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .directions,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Directions',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ])),
                                                  InkWell(
                                                      onTap: () {
                                                        launch(
                                                            'tel:9922783755');
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .call,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Call',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ])),
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => FeedbackTo(
                                                                    id:
                                                                        documentId,
                                                                    type:
                                                                        'post-office',
                                                                    placeName: ftp[
                                                                        'name'])));
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .feedback,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Feedback',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ]))
                                                ])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.room,
                                                color: Colors.blue),
                                            title: Text(
                                                'This is sample address for demo purpose'),
                                            subtitle: Text(_distance)),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.more_vert,
                                                color: Colors.blue),
                                            title: Text(ftp['district'] +
                                                ', ' +
                                                ftp['state'] +
                                                ', ' +
                                                ftp['pincode'].toString())),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.access_time,
                                                color: Colors.blue),
                                            title:
                                                Text('Open 10:00AM To 5:00PM')),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.call,
                                                color: Colors.blue),
                                            title: Text('1234567890')),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.subtitles,
                                                color: Colors.blue),
                                            title: Text(ftp['type'])),
                                        SizedBox(height: 32.0)
                                      ]))
                                ]));
                              });
                        }));
                setState(() {
                  _ftps.add(_ftp);
                  markers[markerId] = marker;
                });
              });
            }
          }
        });
        break;
      case CurrentFtp.CSC:
        print('Fetching CSC');
        _firestore.collection('csc').getDocuments().then((docs) {
          if (docs.documents.isNotEmpty) {
            for (int i = 0; i < docs.documents.length; i++) {
              final documentId = docs.documents[i].documentID;
              final MarkerId markerId = MarkerId(documentId);
              final ftp = docs.documents[i].data;
              String _distance = '';
              Geolocator()
                  .distanceBetween(
                      widget.position.latitude,
                      widget.position.longitude,
                      ftp['latlong'].latitude,
                      ftp['latlong'].longitude)
                  .then((value) {
                var distance = value.floor();

                if (distance < 1000)
                  _distance = '($distance m)';
                else {
                  var dist = (distance / 1000).toStringAsFixed(1);
                  _distance = '($dist km)';
                }
                final _ftp = Ftp(
                    ftpId: documentId,
                    name: ftp['name'],
                    address: 'Sample Address',
                    extra: ftp['pincode'],
                    latitude: ftp['latlong'].latitude,
                    longitude: ftp['latlong'].longitude);
                final Marker marker = Marker(
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueMagenta),
                    markerId: markerId,
                    position: LatLng(
                        ftp['latlong'].latitude, ftp['latlong'].longitude),
                    infoWindow: InfoWindow(
                        title: ftp['name'],
                        snippet: _distance,
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Container(
                                    child: Column(children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(height: 8.0),
                                        Container(
                                            height: 5,
                                            width: 30,
                                            decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        SizedBox(height: 16.0),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Text(ftp['name'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6),
                                        ),
                                        SizedBox(height: 8.0)
                                      ]),
                                  Divider(),
                                  Expanded(
                                      child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                        Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        _createPolylines(
                                                            widget.position,
                                                            Position(
                                                                latitude: _ftp
                                                                    .latitude,
                                                                longitude: _ftp
                                                                    .longitude));
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .directions,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Directions',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ])),
                                                  InkWell(
                                                      onTap: () {
                                                        launch(
                                                            'tel:9922783755');
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .call,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Call',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ])),
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => FeedbackTo(
                                                                    id:
                                                                        documentId,
                                                                    type: 'csc',
                                                                    placeName: ftp[
                                                                        'name'])));
                                                      },
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                                child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                        Icons
                                                                            .feedback,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            25)),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey[300]))),
                                                            SizedBox(height: 8),
                                                            Text('Feedback',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue))
                                                          ]))
                                                ])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.room,
                                                color: Colors.blue),
                                            title: Text(ftp['address']),
                                            subtitle: Text(_distance)),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.more_vert,
                                                color: Colors.blue),
                                            title: Text(ftp['block'] +
                                                ', ' +
                                                ftp['district'] +
                                                ', ' +
                                                ftp['state'])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.access_time,
                                                color: Colors.blue),
                                            title:
                                                Text('Open 10:00AM To 5:00PM')),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.call,
                                                color: Colors.blue),
                                            title: Text('1234567890')),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.subtitles,
                                                color: Colors.blue),
                                            title: Text(ftp['type'])),
                                        Divider(),
                                        ListTile(
                                            leading: Icon(Icons.code,
                                                color: Colors.blue),
                                            title: Text('ID : ' + ftp['id'])),
                                        SizedBox(height: 32.0)
                                      ]))
                                ]));
                              });
                        }));
                setState(() {
                  _ftps.add(_ftp);
                  markers[markerId] = marker;
                });
              });
            }
          }
        });
        break;
    }
  }
}

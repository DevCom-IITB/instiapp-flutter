import 'package:InstiApp/src/api/request/complaint_create_request.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:flutter_google_places/flutter_google_places.dart';

class NewComplaintPage extends StatefulWidget {
  final String title = "New Complaint";
  final String apiKey = "AIzaSyAryoUjEhGTWvgrInX1rDAR3D3DEXD5Z7M";
  @override
  _NewComplaintPageState createState() => _NewComplaintPageState();
}

class _ComplaintCreateRequest {
  String description;
  String suggestions;
  String locationDetail;
  double complaintLatitude;
  double complaintLongitude;
  List<String> tags;
  List<String> images;
}

class _NewComplaintPageState extends State<NewComplaintPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();

  GoogleMapController _mapController;
  GoogleMapsPlaces _places;
  Marker _currMarker;
  LatLng _currPos;

  _ComplaintCreateRequest currRequest = _ComplaintCreateRequest();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _places = GoogleMapsPlaces(apiKey: widget.apiKey);
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);
    var complaintsBloc = bloc.complaintsBloc;
    var fab = null;

    fab = FloatingActionButton.extended(
      icon: _isSubmitting
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
              ),
            )
          : Icon(OMIcons.send),
      label: Text("Submit"),
      onPressed: () async {
        // if (_isSubmitting) {
        //   print("already submitting");
        //   return;
        // }
        // TODO: check form and send complaint
        setState(() {
          _isSubmitting = true;
        });

        var finalPos = _currPos ?? LatLng(19.133810, 72.913257);
        if (_formKey.currentState.validate()) {
          var req = ComplaintCreateRequest();
          req.complaintDescription =
              "Complaint: \n${currRequest.description}\n\n${currRequest.suggestions == null ? "" : "Suggestions: \n" + currRequest.suggestions + "\n"}";
          req.complaintLocation = currRequest.locationDetail;
          req.complaintLatitude = finalPos.latitude;
          req.complaintLongitude = finalPos.longitude;
          req.images = [];
          req.tags = [];

          var resp = await complaintsBloc.postComplaint(req);
          Navigator.of(context).pushNamed("/complaint/${resp.complaintId}");
        }

        setState(() {
          _isSubmitting = false;
        });
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: BottomDrawer(),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                OMIcons.menu,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
                // setState(() {
                //   //disable button
                //   _bottomSheetActive = true;
                // });
                // _scaffoldKey.currentState
                //     .showBottomSheet((context) {
                //       return BottomDrawer();
                //     })
                //     .closed
                //     .whenComplete(() {
                //       setState(() {
                //         _bottomSheetActive = false;
                //       });
                //     });
              },
            ),
          ],
        ),
      ),
      // bottomSheet: ,
      body: Form(
        key: _formKey,
        child: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.title,
                  style: theme.textTheme.display2
                      .copyWith(color: Colors.black, fontFamily: "Bitter"),
                ),
                // SizedBox(height: 8.0),
                // Text(event.getSubTitle(), style: theme.textTheme.title),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: TextFormField(
              maxLines: null,
              decoration: InputDecoration(
                // contentPadding:
                //     EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                border: OutlineInputBorder(),
                labelText: "Description*",
              ),
              autocorrect: true,
              validator: (value) {
                if (value.isEmpty) {
                  return "Please enter a description to your complaint/suggestion";
                }
              },
              onSaved: (v) {
                currRequest.description = v;
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: TextFormField(
              maxLines: null,
              decoration: InputDecoration(
                // contentPadding:
                //     EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                border: OutlineInputBorder(),
                labelText: "Suggestions",
              ),
              autocorrect: true,
              validator: (value) {},
              onSaved: (v) {
                currRequest.suggestions = v;
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: TextFormField(
              maxLines: null,
              decoration: InputDecoration(
                // contentPadding:
                //     EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                border: OutlineInputBorder(),
                labelText: "Location Details",
              ),
              autocorrect: true,
              validator: (value) {},
              onSaved: (v) {
                currRequest.locationDetail = v;
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: OutlineButton.icon(
              icon: Icon(OMIcons.search),
              label: Text("Search Location"),
              onPressed: () {
                _handlePressButton();
              },
            ),
          ),
          // Padding(
          //   padding:
          //       const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
          //   child: TextField(
          //     maxLines: null,
          //     decoration: InputDecoration(
          //       // contentPadding:
          //       //     EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          //       prefixIcon: Icon(OMIcons.search),
          //       border: OutlineInputBorder(),
          //       labelText: "Search Location",
          //     ),
          //     autocorrect: true,
          //     onChanged: (s) {
          //       _handlePressButton();
          //     },
          //   ),
          // ),
          SizedBox(
            height: 300,
            child: GoogleMap(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                Factory<OneSequenceGestureRecognizer>(
                  () => HorizontalDragGestureRecognizer(),
                ),
              ].toSet(),
              onMapCreated: _onMapCreated,
              options: GoogleMapOptions(
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                zoomGesturesEnabled: true,
                compassEnabled: true,
                myLocationEnabled: true,
                tiltGesturesEnabled: false,
              ),
            ),
          ),
          // Padding(
          //   padding:
          //       const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
          //   child: TextFormField(
          //     maxLines: null,
          //     decoration: InputDecoration(
          //       // contentPadding:
          //       //     EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          //       border: OutlineInputBorder(),
          //       labelText: "Tags",
          //     ),
          //     autocorrect: true,
          //     validator: (value) {},
          //   ),
          // ),
          Divider(),
          SizedBox(
            height: 54,
          )
        ]),
      ),

      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    var currLocation = await getCurrLocation();
    _currPos = currLocation;
    _currMarker = await _mapController.addMarker(MarkerOptions(
      position: currLocation,
      infoWindowText: InfoWindowText("Your Location", null),
    ));
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(currLocation, 16));
  }

  Future<LatLng> getCurrLocation() async {
    var currentLocation = <String, double>{};
    final location = LocationManager.Location();
    try {
      currentLocation = await location.getLocation();
      final lat = currentLocation["latitude"];
      final lng = currentLocation["longitude"];
      final center = LatLng(lat, lng);
      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  Future<void> _handlePressButton() async {
    try {
      final center = await getCurrLocation();
      Prediction p = await PlacesAutocomplete.show(
          context: context,
          strictbounds: center == null ? false : true,
          apiKey: widget.apiKey,
          mode: Mode.overlay,
          language: "en",
          location: center == null
              ? null
              : Location(center.latitude, center.longitude),
          radius: center == null ? null : 10000);

      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      var selLocation = LatLng(detail.result.geometry.location.lat,
          detail.result.geometry.location.lng);
      await _mapController?.removeMarker(_currMarker);
      _currPos = selLocation;
      _currMarker = await _mapController?.addMarker(MarkerOptions(
        position: selLocation,
        visible: true,
        alpha: 1.0,
        infoWindowText:
            InfoWindowText(detail.result.name, detail.result.formattedAddress),
      ));
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(selLocation, 16));
    } catch (e) {
      return;
    }
  }
}

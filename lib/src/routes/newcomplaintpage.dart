import 'dart:io';

import 'package:InstiApp/src/api/request/complaint_create_request.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:convert' as convert;

class NewComplaintPage extends StatefulWidget {
  final String title = "New Complaint";
  final String apiKey = "AIzaSyAryoUjEhGTWvgrInX1rDAR3D3DEXD5Z7M";

  static List<String> defaultTags = [
    "Used Flexes",
    "Plastic Bottles (in Hostel messes)",
    "Placards on Trees",
    "Request for donation of clothes",
    "Other donations",
    "Cattle Issues",
    "Autorickshaws",
    "Potholes in Roads",
    "Broken stormwater drains",
    "Desilting - lakes",
    "Flooding of roads and footpaths",
    "Damaged footbaths",
    "Garbage issues",
    "Illegal posters and boardings",
    "Manholes",
    "Streetlights issues",
    "Sewage drains issues",
    "Toilets infrastructural issues",
    "Fencing issues",
    "Security issues",
    "Infrastructural defaults in the academic area",
    "Cycle pooling issues",
    "Water coolers & Aqua Guards",
    "Mess menu complaints",
    "PHO cleaning complaints",
    "PHO cleaning complaints",
    "Hostel common room complaints",
    "Hostel Stationary shop complaints"
  ];

  /// Levenshtein distance
  // source: https://github.com/kseo/edit_distance/blob/master/lib/src/levenshtein.dart
  static int _distance(String s1, String s2) {
    if (s1 == s2) {
      return 0;
    }

    if (s1.length == 0) {
      return s2.length;
    }

    if (s2.length == 0) {
      return s1.length;
    }

    List<int> v0 = new List<int>(s2.length + 1);
    List<int> v1 = new List<int>(s2.length + 1);
    List<int> vtemp;

    for (var i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (var i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (var j = 0; j < s2.length; j++) {
        int cost = 1;
        if (s1.codeUnitAt(i) == s2.codeUnitAt(j)) {
          cost = 0;
        }
        v1[j + 1] = math.min(v1[j] + 1, math.min(v0[j + 1] + 1, v0[j] + cost));
      }

      vtemp = v0;
      v0 = v1;
      v1 = vtemp;
    }

    return v0[s2.length];
  }

  @override
  _NewComplaintPageState createState() => _NewComplaintPageState();
}

class _ComplaintCreateRequest {
  String description;
  String suggestions;
  String locationDetail;
  String locationDescription;
  double complaintLatitude;
  double complaintLongitude;
  List<String> tags;
  List<File> images;
}

class _NewComplaintPageState extends State<NewComplaintPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  final _chipsKey = GlobalKey<EditableChipListState>();

  static LatLng iitAreaLocation = LatLng(19.133810, 72.913257);

  GoogleMapController _mapController;
  GoogleMapsPlaces _places;
  Marker _currMarker;
  LatLng _currPos;

  _ComplaintCreateRequest currRequest = _ComplaintCreateRequest();
  TextEditingController _tagController = TextEditingController();

  TextEditingController _textTagController = TextEditingController();
  FocusNode _textTagFocusNode = FocusNode();

  bool wasTextTagEmpty = true;

  bool _isSubmitting = false;

  bool _uploadingImages = false;

  @override
  void initState() {
    super.initState();
    _places = GoogleMapsPlaces(apiKey: widget.apiKey);

    _textTagFocusNode.addListener(onTextTagFocusChange);
    _textTagController.addListener(onTextTagTextChange);
  }

  @override
  void dispose() {
    _textTagFocusNode.removeListener(onTextTagFocusChange);
    _textTagController.removeListener(onTextTagTextChange);
    _textTagFocusNode.dispose();
    _textTagController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void onTextTagFocusChange() {
    setState(() {});
  }

  void onTextTagTextChange() {
    if (wasTextTagEmpty ^ _textTagController.text.isEmpty) {
      setState(() {});
    }
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
        if (_isSubmitting) {
          print("already submitting");
          return;
        }

        setState(() {
          _isSubmitting = true;
        });

        var finalPos = _currPos ?? iitAreaLocation;
        if (_formKey.currentState.validate()) {
          var req = ComplaintCreateRequest();
          req.complaintDescription = currRequest.description;
          req.complaintSuggestions = currRequest.suggestions ?? "";
          req.complaintLocationDetails = currRequest.locationDetail ?? "";
          req.complaintLocation = currRequest.locationDescription;

          req.complaintLatitude = finalPos.latitude;
          req.complaintLongitude = finalPos.longitude;

          req.tags = _chipsKey.currentState.tags.toList();
          if (currRequest?.images?.isNotEmpty ?? false) {
            setState(() {
              _uploadingImages = true;
            });
            await Future.delayed(Duration(milliseconds: 500));

            req.images =
                await Future.wait(currRequest.images.map((File f) async {
              convert.base64Encode(await f.readAsBytes());
            }).map(
              (Future<String> base64Image) async {
                return (await complaintsBloc
                        .uploadBase64Image(await base64Image))
                    .pictureURL;
              },
            ));

            setState(() {
              _uploadingImages = false;
            });
          } else {
            req.images = [];
          }

          var resp = await complaintsBloc.postComplaint(req);
          print(resp?.complaintID);
          Navigator.of(context)
              .pushReplacementNamed("/complaint/${resp.complaintID}");
        }

        setState(() {
          _isSubmitting = false;
        });
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: BottomDrawer(),
      bottomNavigationBar: MyBottomAppBar(
        shape: RoundedNotchedRectangle(),
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
              },
            ),
          ],
        ),
      ),
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
                  style: theme.textTheme.display2,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _uploadingImages
                  ? CircularProgressIndicatorExtended(
                      label: Text("Uploading Images"),
                    )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              currRequest.images?.isNotEmpty ?? false
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.accentColor),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        height: 200,
                        child: ListView(
                          padding: EdgeInsets.all(8.0),
                          scrollDirection: Axis.horizontal,
                          children: currRequest.images.map((im) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Delete selected image?"),
                                        actions: <Widget>[
                                          FlatButton.icon(
                                            icon: Icon(OMIcons.cancel),
                                            label: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          FlatButton.icon(
                                            icon: Icon(OMIcons.deleteOutline),
                                            label: Text("Delete"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              setState(() {
                                                currRequest.images.remove(im);
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: PhotoViewableImage(
                                  FileImage(im),
                                  "${im.path}",
                                  fit: BoxFit.scaleDown,
                                  customBorder: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(6.0)),
                                      side: BorderSide(
                                        width: 2,
                                        color: theme.accentColor,
                                      )),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ))
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28),
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(text: "No "),
                          TextSpan(
                              text: "images ",
                              style: theme.textTheme.body1
                                  .copyWith(fontWeight: FontWeight.bold)),
                          TextSpan(text: "selected."),
                        ]),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: OutlineButton.icon(
                  label: Text("Upload Images"),
                  icon: Icon(OMIcons.image),
                  onPressed: () async {
                    File imageFile = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            children: <Widget>[
                              SimpleDialogOption(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(OMIcons.photoCamera),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Text("From Camera"),
                                  ],
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop(
                                      await ImagePicker.pickImage(
                                          source: ImageSource.camera));
                                },
                              ),
                              SimpleDialogOption(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(OMIcons.image),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Text("From Gallery"),
                                  ],
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop(
                                      await ImagePicker.pickImage(
                                          source: ImageSource.gallery));
                                },
                              ),
                            ],
                          );
                        });
                    if (imageFile != null) {
                      currRequest.images = currRequest.images ?? [];
                      setState(() {
                        currRequest.images.add(imageFile);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: TextFormField(
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Description*",
              ),
              autocorrect: true,
              validator: (value) {
                if (value.isEmpty) {
                  return "Please enter a description to your complaint/suggestion";
                }
                currRequest.description = value;
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: TextFormField(
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Suggestions",
              ),
              autocorrect: true,
              validator: (value) {
                currRequest.suggestions = value;
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: TextFormField(
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Location Details",
              ),
              autocorrect: true,
              validator: (value) {
                currRequest.locationDetail = value;
              },
            ),
          ),
          Divider(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: EditableChipList(
              key: _chipsKey,
              editable: true,
              preDefinedTags: NewComplaintPage.defaultTags.toSet(),
              tags: Set.from([]),
              controller: _tagController,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child: TypeAheadFormField(
              getImmediateSuggestions: true,
              onSuggestionSelected: (tag) {
                _tagController.text = tag;
                _textTagController.text = "";
              },
              suggestionsCallback: (q) {
                RegExp exp = RegExp(".*" + q.split("").join(".*") + ".*",
                    caseSensitive: false);
                return NewComplaintPage.defaultTags
                    .where((d) => exp.hasMatch(d))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              textFieldConfiguration: TextFieldConfiguration(
                  focusNode: _textTagFocusNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Tags",
                    suffixIcon: IconButton(
                      icon: (!_textTagFocusNode.hasFocus ||
                              (_textTagController.text?.isNotEmpty ?? false))
                          ? Icon(OMIcons.add)
                          : Icon(OMIcons.close),
                      onPressed: () {
                        if (_textTagController.text?.isNotEmpty ?? false) {
                          _tagController.text = _textTagController.text;
                          _textTagController.text = "";
                          _textTagFocusNode.unfocus();
                        } else {
                          _textTagFocusNode.unfocus();
                        }
                      },
                    ),
                  ),
                  controller: _textTagController,
                  onSubmitted: (s) {
                    _tagController.text = _textTagController.text;
                    _textTagController.text = "";
                  }),
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
          SizedBox(
            height: 64,
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
    _currPos = currLocation ?? iitAreaLocation;
    _currMarker = await _mapController.addMarker(MarkerOptions(
      position: currLocation ?? iitAreaLocation,
      infoWindowText: InfoWindowText(
          currLocation == null ? "IIT Area" : "Your Location", null),
    ));
    _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currLocation ?? iitAreaLocation, 16));
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
    } on PlatformException {
      currentLocation = null;
      return null;
    }
  }

  Future<void> _handlePressButton() async {
    final center = await getCurrLocation();
    try {
      Prediction p = await PlacesAutocomplete.show(
          context: context,
          strictbounds: center == null ? false : true,
          apiKey: widget.apiKey,
          mode: Mode.overlay,
          language: "en",
          location: center == null
              ? iitAreaLocation
              : Location(center.latitude, center.longitude),
          radius: center == null ? null : 10000);

      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);

      var selLocation = LatLng(detail.result.geometry.location.lat,
          detail.result.geometry.location.lng);
      await _mapController?.removeMarker(_currMarker);
      _currPos = selLocation;
      currRequest.locationDescription = detail.result.name;

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

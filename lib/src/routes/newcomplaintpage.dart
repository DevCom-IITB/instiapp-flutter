import 'dart:async';
import 'dart:io';

import 'package:InstiApp/src/api/model/venter.dart';
import 'package:InstiApp/src/api/request/complaint_create_request.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/routes/complaintpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;
import 'package:flutter_image_compress/flutter_image_compress.dart';

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

  Completer<List<TagUri>> _tagListCompleter = Completer();

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

  bool firstBuild = true;

  String _uploadingStatus = "0/0";
  String _encodingStatus = "0/0";

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
    var fab;

    if (firstBuild) {
      _tagListCompleter.complete(complaintsBloc.getAllTags());
      firstBuild = false;
    }

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
          : Icon(Icons.send_outlined),
      label: Text("Submit"),
      onPressed: () async {
        if (_isSubmitting) {
          print("already submitting");
          return;
        }

        setState(() {
          _isSubmitting = true;
        });

        var finalPos = _currPos ?? (await getCurrLocation()) ?? iitAreaLocation;
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
            var encNum = 0;
            var uploadNum = 0;
            var totNum = currRequest.images.length;

            setState(() {
              _uploadingImages = true;
              _encodingStatus = "$encNum/$totNum";
              _uploadingStatus = "$uploadNum/$totNum";
            });

            req.images =
                await Future.wait(currRequest.images.map((File f) async {
              var s = convert
                  .base64Encode(await FlutterImageCompress.compressWithFile(
                f.path,
                quality: 60,
              ));

              setState(() {
                encNum++;
                _encodingStatus = "$encNum/$totNum";
              });
              return s;
            }).map((Future<String> base64Image) async {
              var url =
                  (await complaintsBloc.uploadBase64Image(await base64Image))
                      .pictureURL;
              setState(() {
                uploadNum++;
                _uploadingStatus = "$uploadNum/$totNum";
              });
              return url;
            }));

            setState(() {
              _uploadingImages = false;
            });
          } else {
            req.images = [];
          }

          var resp = await complaintsBloc.postComplaint(req);
          print(resp?.complaintID);
          ComplaintPage.navigateWith(context, bloc, resp, replace: true);
        }

        setState(() {
          _isSubmitting = false;
        });
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      bottomNavigationBar: MyBottomAppBar(
        shape: RoundedNotchedRectangle(),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu_outlined,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(children: <Widget>[
            TitleWithBackButton(
              child: Text(
                widget.title,
                style: theme.textTheme.display2,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: _uploadingImages
                      ? CircularProgressIndicatorExtended(
                          label: Text(
                              "$_encodingStatus Encoding Images, $_uploadingStatus Uploading Images"),
                        )
                      : Container(
                          width: 0,
                          height: 0,
                        ),
                ),
                currRequest.images?.isNotEmpty ?? false
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.accentColor),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)),
                          ),
                          height: 200,
                          child: ListView(
                            padding: EdgeInsets.all(8.0),
                            scrollDirection: Axis.horizontal,
                            children: currRequest.images.map((im) {
                              return InkWell(
                                onLongPress: () {
                                  showRemoveImageDialog(context, im);
                                },
                                child: Stack(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: PhotoViewableImage(
                                        imageProvider: FileImage(im),
                                        heroTag: "${im.path}",
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
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: ClipOval(
                                          child: Container(
                                            color: theme.accentColor,
                                            child: IconButton(
                                              padding: EdgeInsets.all(0),
                                              onPressed: () {
                                                showRemoveImageDialog(
                                                    context, im);
                                              },
                                              icon: Icon(
                                                Icons.close_outlined,
                                                color:
                                                    theme.accentIconTheme.color,
                                              ),
                                              iconSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
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
                    icon: Icon(Icons.image_outlined),
                    onPressed: () async {
                      File imageFile = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              children: <Widget>[
                                SimpleDialogOption(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(Icons.photo_camera_outlined),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(Icons.image_outlined),
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
                preDefinedTags: _extractTagUris(_tagListCompleter.future),
                tags: Set.from([]),
                controller: _tagController,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
              child: TypeAheadFormField(
                autoFlipDirection: true,
                hideSuggestionsOnKeyboardHide: false,
                getImmediateSuggestions: true,
                onSuggestionSelected: (TagUri tag) {
                  _tagController.text = tag.tagUri;
                  _textTagController.text = "";
                },
                suggestionsCallback: (q) async {
                  RegExp exp = RegExp(".*" + q.split("").join(".*") + ".*",
                      caseSensitive: false);
                  return (await _tagListCompleter.future)
                      .where((t) => exp.hasMatch(t.tagUri))
                      .toList();
                },
                itemBuilder: (context, TagUri suggestion) {
                  return ListTile(
                    title: Text(suggestion.tagUri),
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
                            ? Icon(Icons.add_outlined)
                            : Icon(Icons.close_outlined),
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
                icon: Icon(Icons.search_outlined),
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
                initialCameraPosition:
                    CameraPosition(target: iitAreaLocation, zoom: 16),
                markers: _currMarker != null ? Set.from([_currMarker]) : null,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                zoomGesturesEnabled: true,
                compassEnabled: true,
                myLocationEnabled: true,
                tiltGesturesEnabled: false,
              ),
            ),
            SizedBox(
              height: 64,
            )
          ]),
        ),
      ),
      floatingActionButton: fab,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void showRemoveImageDialog(BuildContext context, File im) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete selected image?"),
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.cancel_outlined),
              label: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton.icon(
              icon: Icon(Icons.delete_outline_outlined),
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
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    var currLocation = await getCurrLocation();
    _currPos = _currPos ?? currLocation ?? iitAreaLocation;
    setState(() {
      _currMarker = Marker(
        markerId: MarkerId("$_currPos"),
        position: _currPos,
        infoWindow: InfoWindow(
          title: currLocation == null ? "IIT Area" : "Your Location",
        ),
      );
    });
    controller.moveCamera(CameraUpdate.newLatLngZoom(_currPos, 16));
  }

  Future<LatLng> getCurrLocation() async {
    // var currentLocation = <String, double>{};
    loc.LocationData currentLocation;
    final location = loc.Location();
    try {
      currentLocation = await location.getLocation();
      return LatLng(currentLocation.latitude, currentLocation.longitude);
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
      _currPos = selLocation;
      currRequest.locationDescription = detail.result.name;

      setState(() {
        _currMarker = Marker(
          markerId: MarkerId("$selLocation"),
          position: selLocation,
          visible: true,
          infoWindow: InfoWindow(
            title: detail.result.name,
            snippet: detail.result.formattedAddress,
          ),
        );
      });
      _mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(selLocation, 16));
    } catch (e) {
      return;
    }
  }

  Future<List<String>> _extractTagUris(Future<List<TagUri>> future) async {
    return (await future).map((t) => t.tagUri).toList();
  }
}

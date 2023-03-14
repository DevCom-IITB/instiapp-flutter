import 'package:InstiApp/src/api/request/postFAQ_request.dart';
import 'package:InstiApp/src/api/response/secret_response.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:InstiApp/src/api/model/event.dart';
import '../bloc_provider.dart';
import '../drawer.dart';

class QueryAddPage extends StatefulWidget {
  // initiate widgetstate Form
  _QueryAddPageState createState() => _QueryAddPageState();
}

class _QueryAddPageState extends State<QueryAddPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();

  // String? _selectedCategory;
  PostFAQRequest currRequest = PostFAQRequest();

  List<String> categories = [
    'Academic',
    'Sports',
    'Technical',
    'Cultural',
    'SMP',
  ];

  Map<String, String> valueToCategory = {
    'Academic': 'Academic',
    'Sports': 'Sports',
    'Technical': 'Technical',
    'Cultural': 'Cultural',
    'SMP': 'SMP',
  };

  // builds dropdown menu for event choice
  Widget buildDropdownMenuItemsCategory(
      BuildContext context, String? category) {
    // print("Entered build dropdown menu items");
    if (category == null) {
      return Container(
        child: Text(
          "Select a Category",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
    }
    return Container(
      child: ListTile(
        title: Text(valueToCategory[category]!),
      ),
    );
  }

  Widget _customPopupItemBuilderCategory(
      BuildContext context, String category, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text(valueToCategory[category]!),
      ),
    );
  }

  void onCategoryChange(String? category) {
    setState(() {
      currRequest.category = category;
      // _selectedCategory = category;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context)!.bloc;
    var theme = Theme.of(context);
    if (firstBuild) {
      firstBuild = false;
    }

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
              tooltip: "Show bottom sheet",
              icon: Icon(
                Icons.menu_outlined,
                semanticLabel: "Show bottom sheet",
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
          child: bloc.currSession == null
              ? Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(50),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud,
                        size: 200,
                        color: Colors.grey[600],
                      ),
                      Text(
                        "Login To Ask a Question",
                        style: theme.textTheme.headline5,
                        textAlign: TextAlign.center,
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                margin:
                                    EdgeInsets.fromLTRB(15.0, 15.0, 10.0, 5.0),
                                child: Text(
                                  "Couldn't find what you're looking for?",
                                  style: theme.textTheme.headline4,
                                )),
                            SizedBox(
                              height: 40,
                            ),
                            Container(
                                margin:
                                    EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
                                child: TextFormField(
                                  maxLength: 200,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Question",
                                  ),
                                  autocorrect: true,
                                  onChanged: (value) {
                                    setState(() {
                                      currRequest.question = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Question should not be empty';
                                    }
                                    return null;
                                  },
                                )),
                            Container(
                                margin:
                                    EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 0.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      DropdownSearch<String>(
                                        mode: Mode.DIALOG,
                                        maxHeight: 700,
                                        isFilteredOnline: false,
                                        showSearchBox: true,
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          labelText: "Category",
                                          hintText: "Category",
                                        ),
                                        items: categories,
                                        onChanged: onCategoryChange,
                                        dropdownBuilder:
                                            buildDropdownMenuItemsCategory,
                                        popupItemBuilder:
                                            _customPopupItemBuilderCategory,
                                        popupSafeArea: PopupSafeAreaProps(
                                            top: true, bottom: true),
                                        scrollbarProps: ScrollbarProps(
                                          isAlwaysShown: true,
                                          thickness: 7,
                                        ),
                                        emptyBuilder:
                                            (BuildContext context, String? _) {
                                          return Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.all(20),
                                            child: Text(
                                              "No events found. Refine your search!",
                                              style: theme.textTheme.subtitle1,
                                            ),
                                          );
                                        },
                                      ),
                                    ])),
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15.0),
                              child: TextButton(
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    try {
                                      await bloc.postFAQ(currRequest);
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil<void>(
                                              "/query", (_) => false);
                                      // } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: new Text(
                                            (currRequest.question ?? "") +
                                                ":" +
                                                (currRequest.category ?? "")),
                                        duration: new Duration(seconds: 10),
                                      ));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content:
                                            new Text("Error: " + e.toString()),
                                        duration: new Duration(seconds: 10),
                                      ));
                                    }
                                  }

                                  //log(currRequest.description);
                                },
                                child: Text('Submit Question'),
                                style: TextButton.styleFrom(
                                    primary: Colors.black,
                                    backgroundColor: Colors.amber,
                                    onSurface: Colors.grey,
                                    elevation: 5.0),
                              ),
                            ),
                          ]),
                    ),
                  ),
                )),
    );
  }
}

class VerifyCard extends StatefulWidget {
  final Event? thing;
  final bool? selected;

  VerifyCard({this.thing, this.selected});

  Card createState() => Card();
}

class Card extends State<VerifyCard> {
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    if (widget.selected ?? false) {
      return ListTile(
        title: Text(
          widget.thing?.eventName ?? "",
          style: theme.textTheme.headline6,
        ),
        enabled: true,
        leading: NullableCircleAvatar(
          widget.thing?.eventImageURL ??
              widget.thing?.eventBodies?[0].bodyImageURL ??
              "",
          Icons.event_outlined,
          heroTag: widget.thing?.eventID ?? "",
        ),
        subtitle: Text(widget.thing?.getSubTitle() ?? ""),
      );
    } else {
      return SizedBox(height: 10);
    }
  }
}

class BodyCard extends StatefulWidget {
  final Body? thing;
  final bool? selected;

  BodyCard({this.thing, this.selected});

  BodyCardState createState() => BodyCardState();
}

class BodyCardState extends State<BodyCard> {
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    if (widget.selected ?? false) {
      return ListTile(
        title: Text(
          widget.thing?.bodyName ?? "",
          style: theme.textTheme.headline6,
        ),
        enabled: true,
        leading: NullableCircleAvatar(
          widget.thing?.bodyImageURL ?? widget.thing?.bodyImageURL ?? "",
          Icons.event_outlined,
          heroTag: widget.thing?.bodyID ?? "",
        ),
        subtitle: Text(widget.thing?.bodyShortDescription ?? ""),
      );
    } else {
      return SizedBox(height: 10);
    }
  }
}

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  bool processing = false;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (Platform.isAndroid) {
  //     controller!.pauseCamera();
  //   }
  //   controller!.resumeCamera();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var bloc = BlocProvider.of(context)!.bloc;

    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;

    void getOfferedAchievements(String url) async {
      if (url.contains("https://www.insti.app/achievement-new/")) {
        var uri = url.substring(url.lastIndexOf("/") + 1);

        var offerid = uri.substring(0, uri.indexOf("s=") - 1);
        var secret = uri.substring(uri.lastIndexOf("s=") + 2);
        // if offerid is null return or scan again
        if (offerid == '' || secret == '') {
          bool? addToCal = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text("Invalid Achievement Code"),
                    actions: <Widget>[
                      TextButton(
                        child: Text("Scan Again"),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          controller?.resumeCamera();
                          processing = false;
                        },
                      ),
                      TextButton(
                        child: Text("Return"),
                        onPressed: () {
                          controller?.dispose();
                          processing = false;
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ));
          if (addToCal == null) {
            return;
          }
        }
        // check for a secret if offerid exists
        else {
          var achievements = bloc.achievementBloc;
          SecretResponse? offer =
              await achievements.postAchievementOffer(offerid, secret);
          if (offer != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(offer.message ?? "")),
            );
            controller?.dispose();
            processing = false;
            Navigator.of(context).pop();
          }
        }
      } else {
        bool? addToCal = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Invalid Qr Code"),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Scan Again"),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        controller?.resumeCamera();
                        processing = false;
                      },
                    ),
                    TextButton(
                      child: Text("Return"),
                      onPressed: () {
                        controller?.dispose();
                        processing = false;
                        Navigator.of(context).pop(true);
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                ));
        if (addToCal == null) {
          return;
        }
        //processing=true;
      }
    }

    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: (QRViewController controller) {
        setState(() {
          this.controller = controller;
        });
        controller.scannedDataStream.listen((scanData) {
          setState(() {
            result = scanData;
            if (!processing) {
              getOfferedAchievements(result!.code ?? "");
              processing = true;
              controller.pauseCamera();
            }
          });
        });
      },
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

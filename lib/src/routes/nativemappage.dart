import 'dart:async';
import 'dart:collection';

import 'package:InstiApp/src/api/model/venue.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rxdart/rxdart.dart';

class NativeMapPage extends StatefulWidget {
  @override
  _NativeMapPageState createState() => _NativeMapPageState();
}

class _NativeMapPageState extends State<NativeMapPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  PhotoViewControllerBase<PhotoViewControllerValue> controller =
      PhotoViewController();

  StreamSubscription<List<PhotoViewControllerValue>> scaleSubscription;

  bool firstBuild = true;

  double markerScale = 0.069;

  @override
  void initState() {
    super.initState();
    scaleSubscription = Observable(controller.outputStateStream)
        .bufferTime(Duration(milliseconds: 800))
        .listen((List<PhotoViewControllerValue> values) {
      if (values.isNotEmpty) {
        print(values.last.scale);
        if (mounted) {
          setState(() {
            markerScale = values.last.scale;
          });
        } else {
          markerScale = values.last.scale;
        }
      }
      print("Called");
    });
  }

  @override
  void dispose() {
    scaleSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context).bloc;
    var theme = Theme.of(context);
    var mapBloc = bloc.mapBloc;

    if (firstBuild) {
      mapBloc.updateLocations();
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: NavDrawer(),
      bottomNavigationBar: MyBottomAppBar(
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
      body: SafeArea(
        child: PhotoView.customChild(
          child: Container(
            child: StreamBuilder(
              stream: mapBloc.locations,
              builder: (BuildContext context,
                  AsyncSnapshot<UnmodifiableListView<Venue>> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Stack(
                    children: snapshot.data
                        .map((v) => _buildMarker(bloc, theme, v))
                        .toList(),
                  );
                } else {
                  return Container();
                }
              },
            ),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/map/assets/map.webp"))),
          ),
          childSize: Size(5430, 3575),
          backgroundDecoration: BoxDecoration(color: bloc.brightness.toColor()),
          minScale: PhotoViewComputedScale.contained,
          controller: controller,
        ),
      ),
    );
  }

  Widget _buildMarker(InstiAppBloc bloc, ThemeData theme, Venue v) {
    return Positioned(
        left: v.venuePixelX.toDouble(),
        top: v.venuePixelY.toDouble(),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: theme.canvasColor,
              ),
              child: Text(
                v.venueName,
                style: theme.textTheme.display1,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: theme.canvasColor,
              ),
              child: IconButton(
                iconSize: 96,
                onPressed: () {
                  print(v.venueName);
                },
                icon: Icon(
                  OMIcons.locationOn,
                  size: 96,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ));
  }
}

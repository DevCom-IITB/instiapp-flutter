import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/community_bloc.dart';
import 'package:InstiApp/src/utils/customappbar.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/routes/communitydetails.dart';
import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
// import 'package:flutter/rendering.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  Body? body;
  FocusNode _focusNode = FocusNode();
  ScrollController? _hideButtonController;
  TextEditingController? _searchFieldController;
  double isFabVisible = 0;
  bool loadingFollow = false;

  bool searchMode = false;
  IconData actionIcon = Icons.search_outlined;

  bool firstBuild = true;

  @override
  void initState() {
    super.initState();

    _searchFieldController = TextEditingController();
    _hideButtonController = ScrollController();
    _hideButtonController!.addListener(() {
      if (isFabVisible == 1 && _hideButtonController!.offset < 100) {
        setState(() {
          isFabVisible = 0;
        });
      } else if (isFabVisible == 0 && _hideButtonController!.offset > 100) {
        setState(() {
          isFabVisible = 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchFieldController?.dispose();
    _hideButtonController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    var communityBloc = bloc.communityBloc;
    if (firstBuild) {
      communityBloc.query = "";
      communityBloc.refresh();
      firstBuild = false;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      appBar: CustomAppBar(
        appBarSearchStyle: AppBarSearchStyle(
          focusNode: _focusNode,
          hintText: "Search Communities",
          onChanged: (query) {
            if (query.length > 2) {
              communityBloc.query = query;
              communityBloc.refresh();
            }
          },
          onSubmitted: (query) {
            communityBloc.query = query;
            communityBloc.refresh();
          },
        ),
        searchIcon: true,
        title: "Community",
      ),
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
        child: GestureDetector(
          onTap: () {
            _focusNode.unfocus();
          },
          child: RefreshIndicator(
            onRefresh: () {
              return communityBloc.refresh();
            },
            child: ListView(
                controller: _hideButtonController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<List<Community>>(
                      stream: communityBloc.communities,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Community>> snapshot) {
                        return Column(
                          children:
                              _buildContent(snapshot, theme, communityBloc),
                        );
                      },
                    ),
                  ),
                ]),
          ),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: isFabVisible == 0
          ? null
          : FloatingActionButton(
              tooltip: "Go to the Top",
              onPressed: () {
                _hideButtonController!.animateTo(0.0,
                    curve: Curves.fastOutSlowIn,
                    duration: const Duration(milliseconds: 600));
              },
              child: Icon(Icons.keyboard_arrow_up_outlined),
            ),
    );
  }

  List<Widget> _buildContent(AsyncSnapshot<List<Community>> snapshot,
      ThemeData theme, CommunityBloc communityBloc) {
    if (snapshot.hasData) {
      var communities = snapshot.data!;
      if (communities.isEmpty == true) {
        return [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
            child:
                Text.rich(TextSpan(style: theme.textTheme.headline6, children: [
              TextSpan(text: "Nothing found for the query "),
              TextSpan(
                  text: "\"${communityBloc.query}\"",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: "."),
            ])),
          )
        ];
      }
      //move to next page

      return (communities
          .map((c) => _buildListTile(c, theme, communityBloc))
          .toList());
    } else {
      return [
        Center(
            child: CircularProgressIndicatorExtended(
          label: Text("Loading the some default bodies"),
        ))
      ];
    }
  }

//RELATED TO TILES
  Widget _buildListTile(
    Community community,
    ThemeData theme,
    CommunityBloc bloc,
  ) {
    
    var borderRadius = const BorderRadius.all(Radius.circular(10));
    var InstiBloc = BlocProvider.of(context)!.bloc;
    // print(community.isUserFollowing);
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(0, 255, 255, 255), width: 0),
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          fit: BoxFit
              .cover, //I assumed you want to occupy the entire space of the card
          image: community.coverImg != null
              ? CachedNetworkImageProvider(community.coverImg!)
              : CachedNetworkImageProvider(
                  "https://devcom-iitb.org/images/logos/DC_logo.png"),
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            child: ListTile(
              horizontalTitleGap: 0,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
              leading: community.logoImg != null
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3,
                            color: Colors.black.withOpacity(0.25),
                          ),
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.25),
                            spreadRadius: -2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: NullableCircleAvatar(
                        community.logoImg!,
                        Icons.group,
                        heroTag: community.id,
                        radius: 15,
                        backgroundColor: Colors.white,
                      ),
                    )
                  : null,
              title: Text(
                community.name ?? "Some community",
                style: theme.textTheme.subtitle1?.copyWith(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textColor: Color.fromARGB(255, 221, 215, 255),
              trailing: PopupMenuButton<int>(
                itemBuilder: (context) => [
                  // popupmenu item 1
                  PopupMenuItem(
                    value: 1,
                    // row has two child icon and text.
                    child: Row(
                      children: [
                        Icon(Icons.people_alt),
                        SizedBox(
                          // sized box with width 10
                          width: 10,
                        ),
                        Text((community.isUserFollowing ?? false)
                            ? "Leave"
                            : "Join")
                      ],
                    ),
                    onTap: () async {
                      if (InstiBloc.currSession == null) {
                        return;
                      }
                      setState(() {
                        loadingFollow = true;
                      });

                      await InstiBloc.updateFollowCommunity(community);
                      setState(() {
                        loadingFollow = false;
                        // event has changes
                      });
                    },
                  ),
                  // popupmenu item 2
                  PopupMenuItem(
                    value: 2,
                    // row has two child icon and text
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(
                          // sized box with width 10
                          width: 10,
                        ),
                        Text("Share")
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 3,
                    // row has two child icon and text
                    child: Row(
                      children: [
                        Icon(Icons.push_pin_outlined),
                        SizedBox(
                          // sized box with width 10
                          width: 10,
                        ),
                        Text("Pin")
                      ],
                    ),
                  ),
                ],
                // offset: Offset(0, 100),
                elevation: 2,
                tooltip: "More",
                icon: Icon(Icons.more_vert,
                    color: Color.fromARGB(255, 252, 250, 250)),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((community.followersCount ?? "0").toString() +
                      " followers"),
                  SizedBox(height: 10),
                  Text(
                    community.about ?? "",
                    style: TextStyle(
                      color: Color.fromARGB(255, 243, 243, 243),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              onTap: () {
                CommunityDetails.navigateWith(context, bloc, community);
              },
            ),
          ),
        ),
      ),
    );
  }
}

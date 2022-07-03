import 'package:InstiApp/src/api/response/explore_response.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/api/model/createPost.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/material.dart';

class Group extends StatefulWidget {
  final String? ID;
  final String? name;
  final String? followerCount;
  //CreatePost? post;
  //final String title;

  Group({this.ID, this.name, this.followerCount});

  static void navigateWith(BuildContext context, Group? group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/groups/${(group)?.ID}",
        ),
        builder: (context) => Group(
          ID: group?.ID,
          name: group?.name,
          followerCount: group?.followerCount,
        ),
      ),
    );
  }

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<CreatePost> posts = [
    CreatePost(id: '1', content: 'First Post', user: 'Person')
  ];
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var bloc = BlocProvider.of(context)!.bloc;
    var exploreBloc = bloc.exploreBloc;
    // var p = ModalRoute.of(context)!.settings.arguments;
    // List<CreatePost> q = [

    // ];
    // posts.addAll(q);

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
        child: GestureDetector(
          child: ListView(children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<ExploreResponse>(
                stream: exploreBloc.explore,
                builder: (BuildContext context,
                    AsyncSnapshot<ExploreResponse> snapshot) {
                  return Column(
                    children: _buildContent(posts, snapshot, theme),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton.extended(
        tooltip: "Create Post",
        onPressed: () {
          Navigator.of(context).pushNamed("/posts/add");
        },
        icon: Icon(Icons.add),
        label: Text('Discussion'),
        backgroundColor: Colors.blue[600],
      ),
      
    );
  }
}

List<Widget> _buildContent(List<CreatePost> posts,
    AsyncSnapshot<ExploreResponse> snapshot, ThemeData theme) {
  if (snapshot.hasData) {
    var bodies = snapshot.data!.bodies;

    if (bodies?.isEmpty == true) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
          child:
              Text.rich(TextSpan(style: theme.textTheme.headline6, children: [
            TextSpan(text: "Nothing found for the query "),
            TextSpan(
                text: "here", style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: "."),
          ])),
        )
      ];
    }
    //move to next page
    return (posts
            .map((p) => _buildListTile(
                p.id ?? "",
                p.user ?? "",
                p.content ?? "",
                Icons.people_outline_outlined,
                () => {},
                theme))
            .toList() ??
        []);
  } else {
    return [
      Center(
          child: CircularProgressIndicatorExtended(
        label: Text("Loading the some default bodies"),
      ))
    ];
  }

  //RELATED TO TILES
}

Widget _buildListTile(String id, String createdBy, String postContent,
    IconData fallbackIcon, VoidCallback onClick, ThemeData theme) {
  var borderRadius = const BorderRadius.all(Radius.circular(10));
  return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        title: Text(
          postContent,
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
        ),
        textColor: Colors.white,
        subtitle: Text(createdBy),
        onTap: onClick,
        tileColor: Colors.grey[400],
      ));
}

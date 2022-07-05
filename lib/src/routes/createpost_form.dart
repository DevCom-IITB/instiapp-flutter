import 'package:InstiApp/src/api/model/user.dart';
import 'package:flutter/material.dart';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/createPost.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import '../bloc_provider.dart';
import '../drawer.dart';

class CreatePostPage extends StatefulWidget {
  // initiate widgetstate Form
  _CreatePostPage createState() => _CreatePostPage();
}

class _CreatePostPage extends State<CreatePostPage> {
  int number = 0;
  bool selectedE = false;
  bool selectedB = false;
  bool selectedS = false;
  List<CreatePost>? posts;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey1 = GlobalKey<FormState>();

  CreatePost currRequest1 = CreatePost();

  Widget buildDropdownMenuItemsBody(BuildContext context, Body? body) {
    // print("Entered build dropdown menu items");
    if (body == null) {
      return Container(
        child: Text(
          "Search for an organisation",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
    }
    // print(body);
    return Container(
      child: ListTile(
        title: Text(body.bodyName!),
      ),
    );
  }

  Widget buildDropdownMenuItemsSkill(BuildContext context, Skill? body) {
    // print("Entered build dropdown menu items");
    if (body == null) {
      return Container(
        child: Text(
          "Search for a skill",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
    }
    // print(body);
    return Container(
      child: ListTile(
        title: Text(body.title!),
      ),
    );
  }

  void onBodyChange(Body? body) {
    setState(() {
      selectedB = true;
      // currRequest1.body = body;
      // currRequest1.bodyID = body?.bodyID!;
      // _selectedBody = body!;
    });
  }

  void onSkillChange(Skill? body) {
    setState(() {
      selectedS = true;
      // currRequest2.title = body?.title;
      // currRequest2.body = body?.body!;
      //_selectedSkill = body!;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    // print(_selectedBody);
    var bloc = BlocProvider.of(context)!.bloc;
    var theme = Theme.of(context);
    if (firstBuild) {
      firstBuild = false;
    }

    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
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
                    _scaffoldKey.currentState!.openDrawer();
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
                          "Login To Make Post",
                          style: theme.textTheme.headline5,
                          textAlign: TextAlign.center,
                        )
                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  )
                : NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[];
                    },
                    body: TabBarView(
                      // These are the contents of the tab views, below the tabs.
                      children: ["Associations", "Skills"].map((name) {
                        return SafeArea(
                          top: false,
                          bottom: false,
                          child: Builder(
                            // This Builder is needed to provide a BuildContext that is "inside"
                            // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
                            // find the NestedScrollView.
                            builder: (BuildContext context) {
                              var delegates = {
                                "Associations": RefreshIndicator(
                                  onRefresh: () => bloc.updateEvents(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(7.0),
                                    child: SingleChildScrollView(
                                      child: Form(
                                        key: _formKey1,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      15.0, 15.0, 10.0, 5.0),
                                                  child: Text(
                                                    'New Discussion',
                                                    style: theme
                                                        .textTheme.headline4,
                                                  )),
                                              SizedBox(
                                                height: 40,
                                              ),
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    15.0, 5.0, 15.0, 10.0),
                                              ),
                                              Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      15.0, 5.0, 15.0, 10.0),
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    maxLines: null,
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 0, 100),
                                                      border:
                                                          OutlineInputBorder(),
                                                      labelText:
                                                          "Write something...",
                                                    ),
                                                    autocorrect: true,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        currRequest1.content =
                                                            value;
                                                        currRequest1.user =
                                                            "test user";
                                                      });
                                                    },
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Post content should not be empty';
                                                      }
                                                      return null;
                                                    },
                                                  )),
                                              Container(
                                                width: double.infinity,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 15.0),
                                                child: TextButton(
                                                  onPressed: () {
                                                    posts?.add(currRequest1);

                                                    // Navigator.of(context).push(
                                                    //   MaterialPageRoute(
                                                    //       builder: (context) =>
                                                    //           Group(),
                                                    //       settings:
                                                    //           RouteSettings(
                                                    //         arguments: posts,
                                                    //       )),
                                                    // );
                                                  },
                                                  child: Text('Post'),
                                                  style: TextButton.styleFrom(
                                                      primary: Colors.black,
                                                      backgroundColor:
                                                          Color(0xffffd740),
                                                      onSurface: Colors.grey,
                                                      elevation: 5.0),
                                                ),
                                              ),
                                            ]),
                                      ),
                                    ),
                                  ),
                                )
                              };
                              return delegates[name]!;
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ));
  }
}

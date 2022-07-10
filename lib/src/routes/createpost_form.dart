import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:flutter/material.dart';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/createPost.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import '../bloc_provider.dart';
import '../drawer.dart';
import 'communitydetails.dart';

class CreatePostPage extends StatefulWidget {
  // initiate widgetstate Form
  _CreatePostPage createState() => _CreatePostPage();
}

class _CreatePostPage extends State<CreatePostPage> {
  int number = 0;
  bool selectedE = false;
  bool selectedB = false;
  bool selectedS = false;
  bool click = true;
  List<CreatePost>? posts;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey1 = GlobalKey<FormState>();

  CreatePost currRequest1 = CreatePost();

  Community? get community => null;

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
              : RefreshIndicator(
                  onRefresh: () => bloc.updateEvents(),
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Form(
                      key: _formKey1,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 50,
                                  child: TextButton(
                                    onPressed: () {
                                      posts?.add(currRequest1);
                                    },
                                    child: Icon(Icons.close),
                                    style: TextButton.styleFrom(
                                        primary: Colors.black,
                                        backgroundColor: theme.canvasColor,
                                        onSurface: Colors.grey,
                                        elevation: 0.0),
                                  ),
                                ),
                                Container(
                                    child: Text('Create Post',
                                        style: TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                        ))),
                                Container(
                                  width: 65,
                                  child: TextButton(
                                    onPressed: () {
                                      

                                      Navigator.of(context).pop();
                                      //   MaterialPageRoute(
                                      //       builder: (context) =>
                                      //           Group(),
                                      //       settings:
                                      //           RouteSettings(
                                      //         arguments: posts,
                                      //       )),
                                      // );
                                    },
                                    child: Text(
                                      'POST',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    // style: TextButton.styleFrom(
                                    //     primary: Color.fromARGB(255, 255, 255, 255),
                                    //     backgroundColor: Colors.blue,
                                    //     onSurface:
                                    //         Colors.grey,
                                    //     elevation: 5.0),
                                    style: ButtonStyle(
                                        foregroundColor: MaterialStateProperty
                                            .all(Colors.white),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Color.fromARGB(
                                                    255, 72, 115, 235)),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ))),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 1,
                                          color: theme
                                              .colorScheme.surfaceVariant))),
                              child: ListTile(
                                leading: NullableCircleAvatar(
                                  (click == true)
                                      ? "https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Elon_Musk_Royal_Society_%28crop2%29.jpg/1200px-Elon_Musk_Royal_Society_%28crop2%29.jpg"
                                      : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSM9q9XJKxlskry5gXTz1OXUyem5Ap59lcEGg&usqp=CAU",
                                  Icons.person,
                                  radius: 22,
                                ),
                                title: Text(
                                  (click == true)
                                      ? "Account Name"
                                      : 'Anonymous',
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                subtitle: ElevatedButton.icon(
                                  label: Text(
                                    (click == true) ? 'Public' : 'Anonymous',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      click = !click;
                                    });
                                  },
                                  icon: Icon((click == true)
                                      ? Icons.public
                                      : Icons.sentiment_neutral),
                                  style: ButtonStyle(
                                      foregroundColor: (click == true)
                                          ? MaterialStateProperty.all(
                                              Colors.grey)
                                          : MaterialStateProperty.all(
                                              Colors.white),
                                      backgroundColor: (click == true)
                                          ? MaterialStateProperty.all(
                                              Colors.white)
                                          : MaterialStateProperty.all(
                                              Colors.black),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              side: BorderSide(
                                                  color: Colors.grey)))),
                                ),
                              ),
                            ),
                            ConstrainedBox(
                              // margin: EdgeInsets.fromLTRB(5.0, 5.0, 15.0, 0.0),
                              constraints: new BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height / 2.5,
                                //minHeight: MediaQuery.of(context).size.height/3,
                              ),
                              child: SingleChildScrollView(
                                child: Container(
                                    // margin:
                                    //     EdgeInsets.fromLTRB(5.0, 5.0, 15.0, 0),
                                    child: TextFormField(
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 100,
                                  decoration: InputDecoration(
                                    hintText: "Write your Post..",
                                    // contentPadding:
                                    //     EdgeInsets.fromLTRB(0, 0, 0, 400),
                                  ),
                                  autocorrect: true,
                                  onChanged: (value) {
                                    setState(() {
                                      currRequest1.content = value;
                                      currRequest1.user = "test user";
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Post content should not be empty';
                                    }
                                    return null;
                                  },
                                )),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
        ),
        persistentFooterButtons: [
          ConstrainedBox(
           constraints: new BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height / 5,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    title: Text('Attach Photos/Videos'),
                    leading: Icon(Icons.attach_file),
                  ),
                  ListTile(
                    dense: true,
                    title: Text('Attach Photos/Videos'),
                    leading: Icon(Icons.attach_file),
                  ),
                  ListTile(
                    dense: true,
                    title: Text('Attach Photos/Videos'),
                    leading: Icon(Icons.attach_file),
                  ),
                  ListTile(
                    dense: true,
                    title: Text('Insert Links'),
                    leading: Icon(Icons.link),
                  ),
                  ListTile(
                    title: Text('Attach Photos/Videos'),
                    leading: Icon(Icons.attach_file),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

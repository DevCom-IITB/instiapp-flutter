// import 'dart:html';

import 'dart:convert';

import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/api/response/image_upload_response.dart';
import 'package:flutter/material.dart';

import 'package:InstiApp/src/utils/common_widgets.dart';
import '../api/request/image_upload_request.dart';
import '../bloc_provider.dart';
import '../drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:textfield_tags/textfield_tags.dart';

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
  // File? imageFile;

  // List<CreatePost>? posts;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey1 = GlobalKey<FormState>();

  CommunityPost currRequest1 = CommunityPost();

  // Community? get community => null;

  List<String> tags = ["InstiApp", "IIT Bombay"];
  List<String> location = ["Gymkhana", "IIT Bombay"];
  List<String> interests = ["tennis", "anime"];

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
    var profile = bloc.currSession?.profile;
    if (firstBuild) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      if (args != null) {
        currRequest1.community = args;
      }

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
                                      Navigator.of(context).pop();
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
                                      // CommunityPost post = )

                                      bloc.communityPostBloc
                                          .createCommunityPost(currRequest1);

                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'POST',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
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
                                      ? profile?.userProfilePictureUrl ?? " "
                                      : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSM9q9XJKxlskry5gXTz1OXUyem5Ap59lcEGg&usqp=CAU",
                                  Icons.person,
                                  radius: 22,
                                ),
                                title: Text(
                                  (click == true)
                                      ? profile?.userName ?? " "
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
                              constraints: new BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height / 2.6,
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
                                    ),
                                    autocorrect: true,
                                    onChanged: (value) {
                                      setState(() {
                              
                                        currRequest1.content = value;
                                        currRequest1.postedBy = profile;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Post content should not be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
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
                      onTap: () async {
                        final ImagePicker _picker = ImagePicker();
                        final XFile? pi = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (pi != null) {
                          String img64 = base64Encode(
                              (await pi.readAsBytes()).cast<int>());
                          // print(img64);
                          ImageUploadRequest IUReq =
                              ImageUploadRequest(base64Image: img64);
                          ImageUploadResponse resp = await bloc.client
                              .uploadImage(bloc.getSessionIdHeader(), IUReq);
                          // print(resp.pictureURL);
                          setState(() {
                            List<String>? listOfUrls = [];
                            listOfUrls.add(resp.pictureURL ?? "");
                            currRequest1.imageUrl = listOfUrls;
                          });
                        }
                      } // => getImage(source: ImageSource.camera),
                      ),
                  // ListTile(
                  //   dense: true,
                  //   title: Text('Insert Links'),
                  //   leading: Icon(Icons.link),
                  //   onTap: () {},
                  // ),
                  // ListTile(
                  //   dense: true,
                  //   title: Text('Tags'),
                  //   leading: Icon(Icons.bookmark_add_outlined),
                  //   onTap: () {},
                  // ),
                  ExpansionTile(
                    leading: Icon(Icons.bookmark_add_outlined),
                    title: Text('Tags'),
                    children: [
                      TextFieldTags(
                        textSeparators: [
                          " ", //seperate with space
                          ',' //sepearate with comma as well
                        ],
                        initialTags: tags,
                        onTag: (tag) {
                          tags.add(tag);
                        },
                        onDelete: (tag) {
                          tags.remove(tag);
                        },
                        validator: (tag) {
                          //add validation for tags
                          if (tag.length < 2) {
                            return "Enter tag up to 2 characters.";
                          }
                          return null;
                        },
                        tagsStyler: TagsStyler(
                            //styling tag style
                            tagTextStyle:
                                TextStyle(fontWeight: FontWeight.normal),
                            tagDecoration: BoxDecoration(
                              color: Color.fromARGB(255, 210, 216, 221),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            tagCancelIcon: Icon(Icons.cancel_outlined,
                                size: 18.0,
                                color: Color.fromARGB(255, 6, 10, 15)),
                            tagPadding: EdgeInsets.all(6.0)),
                        textFieldStyler: TextFieldStyler(
                            //styling tag text field
                            textFieldBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 140, 160, 175),
                              width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        )),
                      ),
                    ],
                  ),
                  // ListTile(
                  //   dense: true,
                  //   title: Text('Location'),
                  //   leading: Icon(Icons.location_on_outlined),
                  //   onTap: () {},
                  // ),
                  ExpansionTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text('Location'),
                    children: [
                      TextFieldTags(
                        textSeparators: [
                          " ", //seperate with space
                          ',' //sepearate with comma as well
                        ],
                        initialTags: location,
                        onTag: (tag) {
                          location.add(tag);
                        },
                        onDelete: (tag) {
                          location.remove(tag);
                        },
                        validator: (tag) {
                          //add validation for tags
                          if (location.length < 2) {
                            return "Enter location up to 2 characters.";
                          }
                          return null;
                        },
                        tagsStyler: TagsStyler(
                            //styling tag style
                            tagTextStyle:
                                TextStyle(fontWeight: FontWeight.normal),
                            tagDecoration: BoxDecoration(
                              color: Color.fromARGB(255, 210, 216, 221),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            tagCancelIcon: Icon(Icons.cancel_outlined,
                                size: 18.0,
                                color: Color.fromARGB(255, 6, 10, 15)),
                            tagPadding: EdgeInsets.all(6.0)),
                        textFieldStyler: TextFieldStyler(
                            //styling tag text field
                            textFieldBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 140, 160, 175),
                              width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        )),
                      ),
                    ],
                  ),
                  // ListTile(
                  //   dense: true,
                  //   title: Text('Interests'),
                  //   leading: Icon(Icons.interests),
                  //   onTap: () {},
                  // ),
                  ExpansionTile(
                    leading: Icon(Icons.interests),
                    title: Text('Interests'),
                    children: [
                      TextFieldTags(
                        textSeparators: [
                          " ", //seperate with space
                          ',' //sepearate with comma as well
                        ],
                        initialTags: interests,
                        onTag: (tag) {
                          interests.add(tag);
                        },
                        onDelete: (tag) {
                          interests.remove(tag);
                        },
                        validator: (tag) {
                          //add validation for tags
                          if (interests.length < 2) {
                            return "Enter interests up to 2 characters.";
                          }
                          return null;
                        },
                        tagsStyler: TagsStyler(
                            //styling tag style
                            tagTextStyle:
                                TextStyle(fontWeight: FontWeight.normal),
                            tagDecoration: BoxDecoration(
                              color: Color.fromARGB(255, 210, 216, 221),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            tagCancelIcon: Icon(Icons.cancel_outlined,
                                size: 18.0,
                                color: Color.fromARGB(255, 6, 10, 15)),
                            tagPadding: EdgeInsets.all(6.0)),
                        textFieldStyler: TextFieldStyler(
                            //styling tag text field
                            textFieldBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 140, 160, 175),
                              width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        )),
                      ),
                    ],
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

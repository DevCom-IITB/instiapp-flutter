// import 'dart:html';

import 'dart:convert';
import 'dart:developer' as d;
import 'dart:io';
import 'dart:math';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/response/image_upload_response.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/routes/userpage.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:path_provider/path_provider.dart';
import '../api/request/image_upload_request.dart';
import '../bloc_provider.dart';
import '../drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:flutter/src/widgets/framework.dart';

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

  List<File> imageFiles = [];

  // List<CreatePost>? posts;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey1 = GlobalKey<FormState>();

  CommunityPost currRequest1 = CommunityPost();

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
                                    onPressed: () async {
                                      // CommunityPost post = )
                                      currRequest1.imageUrl = [];
                                      for (int i = 0;
                                          i < imageFiles.length;
                                          i++) {
                                        ImageUploadResponse resp =
                                            await bloc.client.uploadImage(
                                                bloc.getSessionIdHeader(),
                                                imageFiles[i]);
                                        currRequest1.imageUrl!
                                            .add(resp.pictureURL!);
                                      }
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
                                      ? profile?.userProfilePictureUrl ?? ""
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
                                    MediaQuery.of(context).size.height / 3,
                              ),
                              child: SingleChildScrollView(
                                child: Container(
                                  child: TextFormField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
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
                            SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: imageFiles
                                      .asMap()
                                      .entries
                                      .map((e) => _buildImage(
                                            e.value,
                                            e.key,
                                          ))
                                      .toList(),
                                ))
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
                      final XFile? pi =
                          await _picker.pickImage(source: ImageSource.gallery);

                      if (pi != null) {
                        // ImageUploadResponse resp = await bloc.client
                        //     .uploadImage(
                        //         bloc.getSessionIdHeader(), File(pi.path));
                        // print(resp.pictureURL);
                        setState(() {
                          imageFiles.add(File(pi.path));
                        });
                      }
                    },
                  ),
                  DropdownMultiSelect<dynamic>(
                    load: null,
                    update: (tags) {
                      currRequest1.bodies = tags
                          ?.where((element) => element.runtimeType == Body)
                          .map((e) => e as Body)
                          .toList();
                      currRequest1.users = tags
                          ?.where((element) => element.runtimeType == User)
                          .map((e) => e as User)
                          .toList();
                    },
                    onFind: (String? query) async {
                      List<Body> list1 =
                          await bloc.achievementBloc.searchForBody(query);
                      List<User> list2 =
                          await bloc.achievementBloc.searchForUser(query);
                      List<dynamic> list = [...list1, ...list2];
                      return list;
                    },
                    singularObjectName: "Tag",
                    pluralObjectName: "Tags",
                  ),
                  DropdownMultiSelect<Interest>(
                    update: (interests) {
                      currRequest1.interests = interests;
                    },
                    load: null,
                    onFind: bloc.achievementBloc.searchForInterest,
                    singularObjectName: "interest",
                    pluralObjectName: "interests",
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImage(File file, int index) {
    return Stack(
      children: [
        Image.file(
          file,
          height: MediaQuery.of(context).size.height / 7.5,
          width: MediaQuery.of(context).size.height / 7.5,
          fit: BoxFit.scaleDown,
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  imageFiles.removeAt(index);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

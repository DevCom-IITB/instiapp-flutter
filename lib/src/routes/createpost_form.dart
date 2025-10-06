import 'dart:io';

import 'package:InstiApp/src/api/model/body.dart';
import 'package:InstiApp/src/api/model/community.dart';
import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/api/response/image_upload_response.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../bloc_provider.dart';
import '../drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

class NavigateArguments {
  final Community? community;
  final CommunityPost? post;

  NavigateArguments({this.community, this.post});
}

class CreatePostPage extends StatefulWidget {
  // initiate widgetstate Form
  _CreatePostPage createState() => _CreatePostPage();
}

class _CreatePostPage extends State<CreatePostPage> {
  FocusNode _focusNode = FocusNode();
  int number = 0;
  bool selectedE = false;
  bool selectedB = false;
  bool selectedS = false;
  bool click = true;
  bool Poll = false;

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
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color.fromRGBO(253, 253, 253, 1),
    ));
    // print(_selectedBody);
    var bloc = BlocProvider.of(context)!.bloc;
    var profile = bloc.currSession?.profile;
    if (firstBuild) {
      currRequest1.featured = false;
      final args =
          ModalRoute.of(context)!.settings.arguments as NavigateArguments?;
      if (args != null) {
        if (args.post != null) {
          isEditing = true;
          currRequest1 = args.post!;
        } else {
          currRequest1.community = args.community;
        }
      }
      firstBuild = false;
    }
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          resizeToAvoidBottomInset: true,
          key: _scaffoldKey,
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
                          textAlign: TextAlign.center,
                        )
                      ],
                      crossAxisAlignment: CrossAxisAlignment.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => bloc.updateEvents(),
                    child: Form(
                      key: _formKey1,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.width(16, context)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: Responsive.height(52, context),
                                      width: Responsive.width(52, context),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            Responsive.width(100, context)),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: TextButton(
                                        onPressed: () {},
                                        child: IconButton(
                                            icon: SvgPicture.asset(
                                              'assets/blogs/arrow-left.svg',
                                              height: Responsive.height(
                                                  24, context),
                                              width:
                                                  Responsive.width(24, context),
                                              fit: BoxFit.none,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            }),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        if (_formKey1.currentState
                                                ?.validate() ??
                                            false) {
                                          if (currRequest1.imageUrl == null)
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
                                          currRequest1.deleted = false;
                                          currRequest1.anonymous ??= false;
                                          currRequest1.hasUserReported = false;
                                          if (isEditing) {
                                            bloc.communityPostBloc
                                                .updateCommunityPost(
                                                    currRequest1);
                                          } else {
                                            bloc.communityPostBloc
                                                .createCommunityPost(
                                                    currRequest1);
                                          }
                                          Navigator.of(context)
                                              .pop(currRequest1);
                                        }
                                      },
                                      child: Container(
                                        height: 35,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 6),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFF306FDC),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          spacing: 8,
                                          children: [
                                            Text(
                                              'Post',
                                              style: TextStyle(
                                                color: const Color(0xFFF6F6F6),
                                                fontSize: 16,
                                                fontFamily: 'DM Sans',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: Responsive.width(24, context),
                                    right: Responsive.width(16, context)),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.only(
                                              top: Responsive.height(
                                                  13, context)),
                                          child: Icon(
                                            Icons.person,
                                            size:
                                                Responsive.height(36, context),
                                          )),
                                      SizedBox(
                                          width: Responsive.width(16, context)),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                  height: Responsive.height(
                                                      4, context)),
                                              Text(
                                                'Posting on Insight Discussions forum',
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xFF7E8287),
                                                  fontSize: 13,
                                                  fontFamily: 'DM Sans',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextFormField(
                                                focusNode: _focusNode,
                                                autofocus: true,
                                                initialValue:
                                                    currRequest1.content,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                maxLines: null,
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xFF0F1620),
                                                  fontSize: 16,
                                                  fontFamily: 'DM Sans',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textAlignVertical:
                                                    TextAlignVertical.top,
                                                decoration: InputDecoration(
                                                  hintText: "What's happening?",
                                                  hintStyle: TextStyle(
                                                    color:
                                                        const Color(0xFF0F1620),
                                                    fontSize: 16,
                                                    fontFamily: 'DM Sans',
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  isDense: true,
                                                ),
                                                autocorrect: true,
                                                onChanged: (value) {
                                                  setState(() {
                                                    currRequest1.content =
                                                        value;
                                                    currRequest1.postedBy =
                                                        profile;
                                                  });
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Post content should not be empty';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              if (Poll)
                                                Container(
                                                  child: PollCreator(
                                                    onClose: () {
                                                      setState(() {
                                                        Poll = false;
                                                      });
                                                    },
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.width(8.0, context),
                                    vertical: Responsive.height(8.0, context)),
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      spacing: 8,
                                      children: [
                                        Container(
                                          height:
                                              Responsive.width(77.62, context),
                                          width:
                                              Responsive.height(77.76, context),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Responsive.width(
                                                          16.9, context)),
                                              color: Color.fromRGBO(
                                                  246, 246, 246, 1),
                                              border: Border.all(
                                                width: 1.50,
                                                color: const Color(0xFFD2D5DA),
                                              )),
                                          child: InkWell(
                                            onTap: () async {
                                              final ImagePicker _picker =
                                                  ImagePicker();
                                              final XFile? pi =
                                                  await _picker.pickImage(
                                                      source:
                                                          ImageSource.camera);
                    
                                              if (pi != null) {
                                                ImageUploadResponse resp =
                                                    await bloc.client.uploadImage(
                                                        bloc.getSessionIdHeader(),
                                                        File(pi.path));
                                                print(resp.pictureURL);
                                                if (await pi.length() /
                                                        1000000 <=
                                                    10) {
                                                  setState(() {
                                                    imageFiles
                                                        .add(File(pi.path));
                                                  });
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Image size should be less than 10MB"),
                                                  ));
                                                }
                                              }
                                            },
                                            child: SvgPicture.asset(
                                                "assets/communities/camera.svg",
                                                height: Responsive.height(
                                                    24, context),
                                                width: Responsive.width(
                                                    24, context),
                                                fit: BoxFit.none),
                                          ),
                                        ),
                                        ...(currRequest1.imageUrl ?? [])
                                            .asMap()
                                            .entries
                                            .map((e) => _buildImageUrl(
                                                  e.value,
                                                  e.key,
                                                )),
                                        ...imageFiles
                                            .asMap()
                                            .entries
                                            .map((e) => _buildImageFile(
                                                  e.value,
                                                  e.key,
                                                )),
                                      ],
                                    ))),
                            Container(
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(246, 246, 246, 1),
                              ),
                              padding: EdgeInsets.only(
                                  left: Responsive.width(14, context),
                                  right: Responsive.width(8.2, context),
                                  bottom: Responsive.height(6, context),
                                  top: Responsive.height(6, context)),
                              child: Row(
                                spacing: 14,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        onTap: () async {
                                          final ImagePicker _picker =
                                              ImagePicker();
                                          final XFile? pi =
                                              await _picker.pickImage(
                                                  source: ImageSource.gallery);
                    
                                          if (pi != null) {
                                            ImageUploadResponse resp =
                                                await bloc.client.uploadImage(
                                                    bloc.getSessionIdHeader(),
                                                    File(pi.path));
                                            print(resp.pictureURL);
                                            if (await pi.length() / 1000000 <=
                                                10) {
                                              setState(() {
                                                imageFiles.add(File(pi.path));
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Image size should be less than 10MB"),
                                              ));
                                            }
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(
                                            Responsive.width(6, context)),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  Responsive.width(6, context),
                                              vertical:
                                                  Responsive.width(6, context)),
                                          child: SvgPicture.asset(
                                            'assets/communities/image.svg',
                                            height:
                                                Responsive.height(22, context),
                                            width:
                                                Responsive.width(22, context),
                                            fit: BoxFit.none,
                                          ),
                                        )),
                                  ),
                                  Container(
                                    width: Responsive.width(1, context),
                                    height: Responsive.height(20, context),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(210, 213, 218, 1),
                                      borderRadius: BorderRadius.circular(
                                          Responsive.width(2, context)),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                          Responsive.width(6, context)),
                                      onTap: () {},
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Responsive.width(6, context),
                                            vertical:
                                                Responsive.width(6, context)),
                                        child: SvgPicture.asset(
                                          'assets/communities/file-text.svg',
                                          height:
                                              Responsive.height(22, context),
                                          width: Responsive.width(22, context),
                                          fit: BoxFit.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: Responsive.width(1, context),
                                    height: Responsive.height(20, context),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(210, 213, 218, 1),
                                      borderRadius: BorderRadius.circular(
                                          Responsive.width(2, context)),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                          Responsive.width(6, context)),
                                      onTap: () {
                                        setState(() {
                                          Poll = true;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Responsive.width(6, context),
                                            vertical:
                                                Responsive.width(6, context)),
                                        child: SvgPicture.asset(
                                          'assets/communities/bar-chart-2.svg',
                                          height:
                                              Responsive.height(22, context),
                                          width: Responsive.width(22, context),
                                          color:
                                              Color.fromRGBO(48, 111, 220, 1),
                                          fit: BoxFit.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ]),
                    )
                    // padding: const EdgeInsets.all(7.0),
                    // child: Form(
                    //   key: _formKey1,
                    //   child: Column(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             Container(
                    //               width: 50,
                    //               child: TextButton(
                    //                 onPressed: () {
                    //                   Navigator.of(context).pop();
                    //                 },
                    //                 child: Icon(Icons.close),
                    //                 style: TextButton.styleFrom(
                    //                     foregroundColor: Colors.black, backgroundColor: theme.canvasColor, disabledForegroundColor: Colors.grey.withOpacity(0.38),
                    //                     elevation: 0.0),
                    //               ),
                    //             ),
                    //             Container(
                    //                 child: Text('Create Post',
                    //                     style: TextStyle(
                    //                       fontSize: 24.0,
                    //                       fontWeight: FontWeight.bold,
                    //                     ))),
                    //             Container(
                    //               width: 65,
                    //               child: TextButton(
                    //                 onPressed: () async {
                    //                   // CommunityPost post = )
                    //                   if (currRequest1.imageUrl == null)
                    //                     currRequest1.imageUrl = [];
                    //                   for (int i = 0;
                    //                       i < imageFiles.length;
                    //                       i++) {
                    //                     ImageUploadResponse resp =
                    //                         await bloc.client.uploadImage(
                    //                             bloc.getSessionIdHeader(),
                    //                             imageFiles[i]);
                    //                     currRequest1.imageUrl!
                    //                         .add(resp.pictureURL!);
                    //                   }
                    //                   currRequest1.deleted = false;
                    //                   currRequest1.anonymous ??= false;
                    //                   currRequest1.hasUserReported = false;
                    //                   if (isEditing) {
                    //                     bloc.communityPostBloc
                    //                         .updateCommunityPost(currRequest1);
                    //                   } else {
                    //                     bloc.communityPostBloc
                    //                         .createCommunityPost(currRequest1);
                    //                   }
        
                    //                   Navigator.of(context).pop(currRequest1);
                    //                 },
                    //                 child: Text(
                    //                   isEditing ? 'EDIT' : 'POST',
                    //                   style: TextStyle(
                    //                     fontSize: 14.0,
                    //                     fontWeight: FontWeight.bold,
                    //                     letterSpacing: 1.0,
                    //                   ),
                    //                 ),
                    //                 style: ButtonStyle(
                    //                     foregroundColor: WidgetStateProperty
                    //                         .all(Colors.white),
                    //                     backgroundColor:
                    //                         WidgetStateProperty.all(
                    //                             Color.fromARGB(
                    //                                 255, 72, 115, 235)),
                    //                     shape: WidgetStateProperty.all<
                    //                             RoundedRectangleBorder>(
                    //                         RoundedRectangleBorder(
                    //                       borderRadius:
                    //                           BorderRadius.circular(50),
                    //                     ))),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         SizedBox(
                    //           height: 15,
                    //         ),
                    //         Container(
                    //           decoration: BoxDecoration(
                    //               border: Border(
                    //                   bottom: BorderSide(
                    //                       width: 1,
                    //                       color: theme
                    //                           .colorScheme.surfaceContainerHighest))),
                    //           child: ListTile(
                    //             leading: NullableCircleAvatar(
                    //               (click == true)
                    //                   ? profile?.userProfilePictureUrl ?? ""
                    //                   : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSM9q9XJKxlskry5gXTz1OXUyem5Ap59lcEGg&usqp=CAU",
                    //               Icons.person,
                    //               radius: 22,
                    //             ),
                    //             title: Text(
                    //               (click == true)
                    //                   ? profile?.userName ?? " "
                    //                   : 'Anonymous',
                    //               style: TextStyle(
                    //                 fontSize: 17.0,
                    //                 fontWeight: FontWeight.bold,
                    //                 letterSpacing: 0.3,
                    //               ),
                    //             ),
                    //             subtitle: ElevatedButton.icon(
                    //               label: Text(
                    //                 (click == true) ? 'Public' : 'anonymous',
                    //                 style: TextStyle(
                    //                   fontWeight: FontWeight.bold,
                    //                   letterSpacing: 0.3,
                    //                 ),
                    //               ),
                    //               onPressed: () {
                    //                 setState(() {
                    //                   click = !click;
                    //                   currRequest1.anonymous = !click;
                    //                 });
                    //               },
                    //               icon: Icon((click == true)
                    //                   ? Icons.public
                    //                   : Icons.sentiment_neutral),
                    //               style: ButtonStyle(
                    //                   foregroundColor: (click == true)
                    //                       ? WidgetStateProperty.all(
                    //                           Colors.grey)
                    //                       : WidgetStateProperty.all(
                    //                           Colors.white),
                    //                   backgroundColor: (click == true)
                    //                       ? WidgetStateProperty.all(
                    //                           Colors.white)
                    //                       : WidgetStateProperty.all(
                    //                           Colors.black),
                    //                   shape: WidgetStateProperty.all<
                    //                           RoundedRectangleBorder>(
                    //                       RoundedRectangleBorder(
                    //                           borderRadius:
                    //                               BorderRadius.circular(50),
                    //                           side: BorderSide(
                    //                               color: Colors.grey)))),
                    //             ),
                    //           ),
                    //         ),
                    //         ConstrainedBox(
                    //           constraints: new BoxConstraints(
                    //             maxHeight:
                    //                 MediaQuery.of(context).size.height / 3,
                    //           ),
                    //           child: SingleChildScrollView(
                    //             child: Container(
                    //               child: TextFormField(
                    //                 initialValue: currRequest1.content,
                    //                 keyboardType: TextInputType.multiline,
                    //                 maxLines: null,
                    //                 decoration: InputDecoration(
                    //                   hintText: "Write your Post..",
                    //                 ),
                    //                 autocorrect: true,
                    //                 onChanged: (value) {
                    //                   setState(() {
                    //                     currRequest1.content = value;
                    //                     currRequest1.postedBy = profile;
                    //                   });
                    //                 },
                    //                 validator: (value) {
                    //                   if (value == null || value.isEmpty) {
                    //                     return 'Post content should not be empty';
                    //                   }
                    //                   return null;
                    //                 },
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         SingleChildScrollView(
                    //             scrollDirection: Axis.horizontal,
                    //             child: Row(
                    //               children: [
                    //                 ...(currRequest1.imageUrl ?? [])
                    //                     .asMap()
                    //                     .entries
                    //                     .map((e) => _buildImageUrl(
                    //                           e.value,
                    //                           e.key,
                    //                         )),
                    //                 ...imageFiles
                    //                     .asMap()
                    //                     .entries
                    //                     .map((e) => _buildImageFile(
                    //                           e.value,
                    //                           e.key,
                    //                         )),
                    //               ],
        
                    ),
          ),
        ),
      ),
      // persistentFooterButtons: [
      //   ConstrainedBox(
      //     constraints: new BoxConstraints(
      //       maxHeight: MediaQuery.of(context).size.height / 5,
      //     ),
      //     child: SingleChildScrollView(
      //       child: Column(
      //         children: [
      //           ListTile(
      //             dense: true,
      //             title: Text('Attach Photos/Videos'),
      //             leading: Icon(Icons.attach_file),
      //             onTap: () async {
      //               final ImagePicker _picker = ImagePicker();
      //               final XFile? pi =
      //                   await _picker.pickImage(source: ImageSource.gallery);

      //               if (pi != null) {
      //                 // ImageUploadResponse resp = await bloc.client
      //                 //     .uploadImage(
      //                 //         bloc.getSessionIdHeader(), File(pi.path));
      //                 // print(resp.pictureURL);
      //                 if (await pi.length() / 1000000 <= 10) {
      //                   setState(() {
      //                     imageFiles.add(File(pi.path));
      //                   });
      //                 } else {
      //                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //                     content:
      //                         Text("Image size should be less than 10MB"),
      //                   ));
      //                 }
      //               }
      //             },
      //           ),
      //           DropdownMultiSelect<dynamic>(
      //             load: Future.value([
      //               ...(currRequest1.bodies ?? []),
      //               ...(currRequest1.users ?? [])
      //             ]),
      //             update: (tags) {
      //               currRequest1.bodies = tags
      //                   ?.where((element) => element.runtimeType == Body)
      //                   .map((e) => e as Body)
      //                   .toList();
      //               currRequest1.users = tags
      //                   ?.where((element) => element.runtimeType == User)
      //                   .map((e) => e as User)
      //                   .toList();
      //             },
      //             onFind: (String? query) async {
      //               List<Body> list1 =
      //                   await bloc.achievementBloc.searchForBody(query);
      //               List<User> list2 =
      //                   await bloc.achievementBloc.searchForUser(query);
      //               List<dynamic> list = [...list1, ...list2];
      //               return list;
      //             },
      //             singularObjectName: "Tag",
      //             pluralObjectName: "Tags",
      //           ),
      //           DropdownMultiSelect<Interest>(
      //             update: (interests) {
      //               currRequest1.interests = interests;
      //             },
      //             load: Future.value(currRequest1.interests ?? []),
      //             onFind: bloc.achievementBloc.searchForInterest,
      //             singularObjectName: "interest",
      //             pluralObjectName: "interests",
      //           ),
      //         ],
      //       ),
      //     ),
      //   )
      // ],
    );
  }

  Widget _buildImageUrl(String url, int index) {
    return Stack(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(Responsive.width(16.9, context)),
          ),
          child: Image.network(
            url,
            height: Responsive.height(77.62, context),
            width: Responsive.width(77.62, context),
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  currRequest1.imageUrl!.removeAt(index);
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageFile(File file, int index) {
    return Stack(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(Responsive.width(16.9, context)),
          ),
          child: Image.file(
            file,
            height: Responsive.height(77.62, context),
            width: Responsive.width(77.62, context),
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          right: Responsive.width(-10, context),
          top: Responsive.height(-10, context),
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
//   class DashedLinePainter extends CustomPainter {
//     @override
//     void paint(Canvas canvas, Size size) {
//       double dashWidth = 4, dashSpace = 4, startX = 0;
//       final paint = Paint()
//         ..color = Colors.grey.shade300
//         ..strokeWidth = 1;
//       while (startX < size.width) {
//         canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
//         startX += dashWidth + dashSpace;
//       }
//     }

//     @override
//     bool shouldRepaint(CustomPainter oldDelegate) => false;
//   }

//   class PollCreator extends StatefulWidget {
//   @override
//   _PollCreatorState createState() => _PollCreatorState();
// }
// class _PollCreatorState extends State<PollCreator> {
//   // Initializing with values from the image for demonstration
//   final TextEditingController _questionController =
//       TextEditingController(text: 'Party Timings????');
//   final List<TextEditingController> _optionControllers = [
//     TextEditingController(text: '9-10PM'),
//     TextEditingController(text: 'After 10'),
//   ];
//   bool _allowMultipleAnswers = true;

//   @override
//   void dispose() {
//     _questionController.dispose();
//     for (var controller in _optionControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   // Custom painter for the dashed line

//   @override
//   Widget build(BuildContext context) {
//     // Using a standard Card widget for the container with elevation
//     return Card(
//       elevation: 4,
//       shadowColor: Colors.black.withOpacity(0.1),
//       margin: EdgeInsets.symmetric(
//         horizontal: Responsive.width(16, context),
//         vertical: Responsive.height(16, context),
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       color: Colors.white,
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: Responsive.width(16, context),
//           vertical: Responsive.height(12, context),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min, // To make the card wrap content
//           children: [
//             // ## Header: "Create Poll" and Close Button ##
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Create Poll',
//                   style: TextStyle(
//                     color: const Color(0xFF0F1620),
//                     fontSize: Responsive.text(18, context),
//                     fontFamily: 'DM Sans',
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () {
//                     // TODO: Implement close functionality
//                     Navigator.of(context).pop();
//                   },
//                   borderRadius: BorderRadius.circular(12),
//                   child: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFF97153), // Orange color from image
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.close,
//                       color: Colors.white,
//                       size: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: Responsive.height(16, context)),

//             // ## Question Text Field ##
//             TextField(
//               controller: _questionController,
//               decoration: InputDecoration(
//                 hintText: "Ask a question",
//                 prefixIcon: Container(
//                   margin: const EdgeInsets.all(10),
//                   padding: const EdgeInsets.all(2),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE6EEFD),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: const Text(
//                     'T',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Color(0xFF306FDC),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: EdgeInsets.symmetric(
//                   vertical: Responsive.height(12, context),
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: const Color(0xFFD2D5DA), width: 1),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: const Color(0xFFD2D5DA), width: 1),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.blue, width: 1.5),
//                 ),
//               ),
//               style: const TextStyle(
//                 color: Color(0xCC0F1620),
//                 fontSize: 14,
//                 fontFamily: 'DM Sans',
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//             SizedBox(height: Responsive.height(12, context)),

//             // ## Options List ##
//             // Using a Column instead of ReorderableListView for simpler layout matching
//             // If reordering is essential, this can be converted back with custom styling.
//             Column(
//               children: [
//                 ..._optionControllers.map((controller) {
//                   return Column(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: controller,
//                               decoration: InputDecoration(
//                                 hintText: "Option",
//                                 border: InputBorder.none,
//                                 enabledBorder: InputBorder.none,
//                                 focusedBorder: InputBorder.none,
//                                 contentPadding: EdgeInsets.symmetric(
//                                   vertical: Responsive.height(14, context),
//                                 ),
//                                 isDense: true,
//                               ),
//                             ),
//                           ),
//                           Icon(Icons.drag_handle, color: Colors.grey.shade400),
//                         ],
//                       ),
//                       Divider(height: 1, color: Colors.grey.shade200),
//                     ],
//                   );
//                 }).toList(),

//                 // ## "Add Option" Button ##
//                 InkWell(
//                    onTap: () {
//                     setState(() {
//                       _optionControllers.add(TextEditingController());
//                     });
//                   },
//                   child: Padding(
//                      padding: EdgeInsets.symmetric(
//                       vertical: Responsive.height(14, context),
//                     ),
//                     child: Row(
//                       children: [
//                         Text(
//                           'Add option',
//                           style: TextStyle(
//                             color: Colors.grey.shade600,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             // ## Dashed Divider ##
//             CustomPaint(
//               painter: DashedLinePainter(),
//               child: Container(
//                 height: 1,
//               ),
//             ),
//             SizedBox(height: Responsive.height(8, context)),

//             // ## "Allow multiple answers" Toggle ##
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Allow multiple answers',
//                   style: TextStyle(
//                     color: Color(0xFF306FDC),
//                     fontSize: 14,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Switch(
//                   value: _allowMultipleAnswers,
//                   onChanged: (value) {
//                     setState(() {
//                       _allowMultipleAnswers = value;
//                     });
//                   },
//                   activeColor: Colors.white,
//                   activeTrackColor: const Color(0xFF306FDC),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class PollCreator extends StatefulWidget {
  final VoidCallback? onClose;
  const PollCreator({
    Key? key,
    this.onClose,
  }) : super(key: key);
  @override
  _PollCreatorState createState() => _PollCreatorState();
}

class _PollCreatorState extends State<PollCreator> {
  TextEditingController questionController = TextEditingController();
  List<TextEditingController> optionControllers = [TextEditingController()];
  bool allowMultipleAnswers = false;

  Widget buildCustomSwitch() {
    return GestureDetector(
      onTap: () {
        setState(() {
          allowMultipleAnswers = !allowMultipleAnswers;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: Responsive.width(35, context),
        height: Responsive.height(19, context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.width(10, context)),
          color: allowMultipleAnswers
              ? const Color.fromRGBO(37, 99, 235, 1)
              : Colors.grey[300],
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: allowMultipleAnswers
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: Responsive.width(15, context), // ✅ Custom thumb width
            height: Responsive.height(15, context), // ✅ Custom thumb height
            margin: EdgeInsets.all(Responsive.width(
                2, context)), // ✅ Custom gap between track and thumb
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 300,
      margin: EdgeInsets.only(
          // left: Responsive.width(76, context),
          // right: Responsive.width(16, context),
          bottom: Responsive.height(16, context),
          top: Responsive.height(16, context)),
      child: Container(
        decoration: ShapeDecoration(
          color: const Color(0xFFF6F6F6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.width(16, context),
            vertical: Responsive.height(12, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create Poll',
                    style: TextStyle(
                      color: const Color(0xFF0F1620),
                      fontSize: Responsive.text(16, context),
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  InkWell(
                    onTap: widget.onClose,
                    child: SvgPicture.asset("assets/communities/x-circle.svg",
                        height: Responsive.height(24, context),
                        width: Responsive.width(24, context)),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.height(12, context)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD2D5DA),
                  width: 1,
                ),
                color: const Color(0xFFFFFFFF),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.width(16, context),
                  vertical: Responsive.height(9, context)),
              child: TextField(
                maxLines: null,
                controller: questionController,
                decoration: InputDecoration(
                  hintText: "Ask question",
                  hintStyle: TextStyle(
                    color: const Color(0xFF7E8287),
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w400,
                  ),

                  border: InputBorder.none, // Remove border
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero, // Remove padding
                  isDense: true,
                ),
                style: TextStyle(
                  color: const Color(0xCC0F1620),
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: Responsive.height(12, context)),

            /// Options List
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD2D5DA),
                  width: 1,
                ),
                color: const Color(0xFFFFFFFF),
              ),
              child: Column(
                children: [
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: optionControllers.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      setState(() {
                        final item = optionControllers.removeAt(oldIndex);
                        optionControllers.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        key: ValueKey(index),
                        child: Container(
                          padding: EdgeInsets.only(
                            top: Responsive.height(9, context),
                            bottom: Responsive.height(7, context),
                            left: Responsive.width(16, context),
                            right: Responsive.height(12, context),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: const Color(0xFFD2D5DA), width: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                  "assets/communities/align-justify.svg",
                                  height: Responsive.height(18, context),
                                  width: Responsive.width(8, context)),
                              SizedBox(width: Responsive.width(8, context)),
                              Expanded(
                                child: TextField(
                                  maxLines: null,
                                  controller: optionControllers[index],
                                  decoration: InputDecoration(
                                    hintText: "Option",
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF7E8287),
                                      fontSize: 14,
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none, // Remove border
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.zero, // Remove padding
                                    isDense: true,
                                    // border: OutlineInputBorder(),
                                  ),
                                  style: TextStyle(
                                    color: const Color(0xCC0F1620),
                                    fontSize: 14,
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              SizedBox(width: Responsive.width(8, context)),
                              if (index > 0)
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  padding: EdgeInsets.zero, // Remove padding
                                  constraints:
                                      BoxConstraints(), // Remove minimum size constraints
                                  iconSize: 20,
                                  onPressed: () {
                                    setState(() {
                                      optionControllers.removeAt(index);
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: Responsive.height(9, context),
                      bottom: Responsive.height(7, context),
                      left: Responsive.width(16, context),
                      right: Responsive.height(12, context),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          optionControllers.add(TextEditingController());
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add option',
                            style: TextStyle(
                              color: const Color(0xFFBEBEBE),
                              fontSize: 14,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SvgPicture.asset("assets/communities/plus.svg",
                              height: Responsive.height(19.2, context),
                              width: Responsive.width(19.2, context))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: Responsive.height(16, context)),

            /// Allow Multiple Answers Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Allow multiple answers',
                  style: TextStyle(
                    color: const Color(0xFF306FDC),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                buildCustomSwitch(),
                // Transform.scale(
                //   scale: 0.9,
                //   child: CupertinoSwitch(
                //     value: allowMultipleAnswers,
                //     onChanged: (value) {
                //       setState(() {
                //         allowMultipleAnswers = value;
                //       });
                //     },
                //     activeColor: const Color.fromRGBO(37, 99, 235, 1),
                //     trackColor: Colors.grey[300],
                //     thumbColor: Colors.white,
                //   ),
                // ),
                // Switch(
                //   value: allowMultipleAnswers,
                //   onChanged: (value) {
                //     setState(() {
                //       allowMultipleAnswers = value;
                //     });
                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

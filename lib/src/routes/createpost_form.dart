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
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

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
  bool isPoll = false;
  Map<String, dynamic>? pollData;

  List<File> imageFiles = [];
  Set<int> loadedImageIndices = {}; // Track which images are fully loaded
  // List<PlatformFile> attachedFiles = []; // For general files
  // List<File> documentFiles = []; // For document files

  // List<CreatePost>? posts;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey1 = GlobalKey<FormState>();

  CommunityPost currRequest1 = CommunityPost();

  @override
  void initState() {
    super.initState();
  }

  bool firstBuild = true;
  bool posting = false;
  bool isEditing = false;
//For user view
//

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
          isPoll = args.post!.isPoll ?? false;
          pollData = {
            'poll_question': args.post!.poll?.question ?? '',
            'poll_allow_multiple_answers':
                args.post!.poll?.allowMultipleAnswers ?? false,
            'poll_options': args.post!.poll?.options
                    ?.map((option) => option.text)
                    .toList() ??
                [],
          };
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
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.width(50, context),
                        vertical: Responsive.height(50, context)),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud,
                          size: Responsive.height(200, context),
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
                                        posting = true;
                                        setState(() {});
                                        if (_formKey1.currentState
                                                ?.validate() ??
                                            false) {
                                          if (isPoll && pollData != null) {
                                            final question =
                                                pollData!['poll_question']
                                                    as String?;
                                            final options =
                                                pollData!['poll_options']
                                                    as List<String>?;
                                            if (question == null ||
                                                question.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Please enter a poll question'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            if (options == null ||
                                                options.length < 2) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Please provide at least 2 poll options'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            // Validate that options are not empty
                                            final validOptions = options
                                                .where((option) =>
                                                    option.trim().isNotEmpty)
                                                .toList();
                                            if (validOptions.length < 2) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Please provide at least 2 non-empty poll options'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }
                                          }

                                          if (currRequest1.imageUrl == null)
                                            currRequest1.imageUrl = [];
                                          // If editing, only add new images (imageFiles contains only new ones)
                                          // If creating, add all images from imageFiles
                                          for (int i = 0;
                                              i < imageFiles.length;
                                              i++) {
                                                try{
                                            ImageUploadResponse resp =
                                                await bloc.client.uploadImage(
                                                    bloc.getSessionIdHeader(),
                                                    imageFiles[i]);
                                            // Check if image URL already exists to avoid duplicates
                                            if (!currRequest1.imageUrl!
                                                .contains(resp.pictureURL!)) {
                                              currRequest1.imageUrl!
                                                  .add(resp.pictureURL!);
                                            }} catch(e){
                                                  ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Error uploading image: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                                  posting = false;
                                                  return;
                                                }
                                          }
                                          // for (int i = 0;
                                          //     i < documentFiles.length;
                                          //     i++) {
                                          //   ImageUploadResponse resp =
                                          //       await bloc.client.uploadImage(
                                          //           bloc.getSessionIdHeader(),
                                          //           documentFiles[i]);
                                          //   currRequest1.imageUrl!
                                          //       .add(resp.pictureURL!);
                                          // }
                                          currRequest1.deleted = false;
                                          currRequest1.anonymous ??= false;
                                          currRequest1.hasUserReported = false;
                                          currRequest1.isPoll = isPoll;
                                          if (isPoll && pollData != null) {
                                            final List<PollOption>
                                                optionsForApi =
                                                (pollData!['poll_options']
                                                        as List<String>)
                                                    .map((text) =>
                                                        PollOption(text: text))
                                                    .toList();

                                            // Create a clean poll object with only the fields the backend needs.
                                            final Poll pollForApi = Poll(
                                              question:
                                                  pollData!['poll_question'],
                                              allowMultipleAnswers: pollData![
                                                  'poll_allow_multiple_answers'],
                                              options: optionsForApi,
                                            );
                                            currRequest1.poll = pollForApi;
                                          }
                                          try {
                                            if (isEditing) {
                                              bloc.communityPostBloc
                                                  .updateCommunityPost(
                                                      currRequest1);                                              
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Post updated successfully'),
                                                  backgroundColor: Colors.green,
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            } else {
                                              bloc.communityPostBloc
                                                  .createCommunityPost(
                                                      currRequest1);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Post created successfully'),
                                                  backgroundColor: Colors.green,
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Error uploading post: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            posting = false;
                                            return;
                                          }
                                          Navigator.of(context)
                                              .pop(currRequest1);
                                        }
                                      },
                                      child: Container(
                                        height: Responsive.height(35, context),
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Responsive.width(16, context),
                                            vertical:
                                                Responsive.height(6, context)),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFF306FDC),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                Responsive.width(100, context)),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              posting ? 'Posting...' : 'Post',
                                              style: TextStyle(
                                                color: const Color(0xFFF6F6F6),
                                                fontSize: Responsive.text(
                                                    16, context),
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
                            Container(
                              margin: EdgeInsets.only(
                                  top: Responsive.height(4, context),
                                  bottom: Responsive.height(4, context),
                                  left: Responsive.width(24, context)),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    click = !click;
                                    currRequest1.anonymous = !click;
                                  });
                                },
                                child: Anonymous(click),
                              ),
                            ),
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
                                            top:
                                                Responsive.height(13, context)),
                                        child: Image.network(
                                          currRequest1.postedBy
                                                  ?.userProfilePictureUrl ??
                                              '',
                                          width: Responsive.width(36, context),
                                          height:
                                              Responsive.height(36, context),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Image.asset(
                                            "assets/communities/image 214.png",
                                            height:
                                                Responsive.height(36, context),
                                            width:
                                                Responsive.width(36, context),
                                          ),
                                        ),
                                      ),
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
                                                  fontSize: Responsive.text(
                                                      13, context),
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
                                                  fontSize: Responsive.text(
                                                      16, context),
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
                                                    fontSize: Responsive.text(
                                                        16, context),
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
                                              if (isPoll)
                                                Container(
                                                  child: PollCreator(
                                                    onClose: () {
                                                      setState(() {
                                                        isPoll = false;
                                                      });
                                                    },
                                                    initialData: pollData,
                                                    onPollDataChanged: (data) {
                                                      setState(() {
                                                        pollData = data;
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
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
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
                                        // ...(attachedFiles)
                                        //     .asMap()
                                        //     .entries
                                        //     .map((e) => _buildAttachedFile(
                                        //           e.value,
                                        //           e.key,
                                        //         )),
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
                                                source: ImageSource.camera);

                                        if (pi != null) {
                                          // ImageUploadResponse resp =
                                          //     await bloc.client.uploadImage(
                                          //         bloc.getSessionIdHeader(),
                                          //         File(pi.path));
                                          // print(resp.pictureURL);
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
                                                Responsive.width(8, context),
                                            vertical:
                                                Responsive.height(6, context)),
                                        child: SvgPicture.asset(
                                          'assets/communities/camera.svg',
                                          height:
                                              Responsive.height(26, context),
                                          width: Responsive.width(26, context),
                                          color:
                                              Color.fromRGBO(48, 111, 220, 1),
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
                                                  Responsive.width(8, context),
                                              vertical: Responsive.height(
                                                  6, context)),
                                          child: SvgPicture.asset(
                                            'assets/communities/image.svg',
                                            height:
                                                Responsive.height(26, context),
                                            width:
                                                Responsive.width(26, context),
                                          ),
                                        )),
                                  ),

                                  // Material(
                                  //   color: Colors.transparent,
                                  //   child: InkWell(
                                  //     borderRadius: BorderRadius.circular(
                                  //         Responsive.width(6, context)),
                                  //     onTap: () {
                                  //       _pickFiles();
                                  //     },
                                  //     child: Container(
                                  //       padding: EdgeInsets.symmetric(
                                  //           horizontal:
                                  //               Responsive.width(6, context),
                                  //           vertical:
                                  //               Responsive.width(6, context)),
                                  //       child: SvgPicture.asset(
                                  //         'assets/communities/file-text.svg',
                                  //         height:
                                  //             Responsive.height(22, context),
                                  //         width: Responsive.width(22, context),
                                  //         fit: BoxFit.none,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),

                                  //-------------------------
                                  //Uncomment for Poll
                                  // Container(
                                  //   width: 1,
                                  //   height: Responsive.height(20, context),
                                  //   decoration: BoxDecoration(
                                  //     color: Color.fromRGBO(210, 213, 218, 1),
                                  //     borderRadius: BorderRadius.circular(2),
                                  //   ),
                                  // ),
                                  // Material(
                                  //   color: Colors.transparent,
                                  //   child: InkWell(
                                  //     borderRadius: BorderRadius.circular(
                                  //         Responsive.width(6, context)),
                                  //     onTap: () {
                                  //       setState(() {
                                  //         isPoll = true;
                                  //       });
                                  //     },
                                  //     child: Container(
                                  //       padding: EdgeInsets.symmetric(
                                  //           horizontal:
                                  //               Responsive.width(8, context),
                                  //           vertical:
                                  //               Responsive.height(6, context)),
                                  //       child: SvgPicture.asset(
                                  //         'assets/communities/bar-chart-2.svg',
                                  //         height:
                                  //             Responsive.height(26, context),
                                  //         width: Responsive.width(26, context),
                                  //         color:
                                  //             Color.fromRGBO(48, 111, 220, 1),
                                  //         fit: BoxFit.none,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            )
                          ]),
                    )),
          ),
        ),
      ),
    );
  }

  Widget Anonymous(bool isano) {
    return isano
        ? Container(
            margin: EdgeInsets.only(right: Responsive.width(24, context)),
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.width(10, context),
                vertical: Responsive.height(4, context)),
            decoration: BoxDecoration(
                border: Border.all(color: Color.fromRGBO(48, 111, 220, 1)),
                borderRadius:
                    BorderRadius.circular(Responsive.width(100, context))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset("assets/communities/globe.svg",
                    height: Responsive.height(20, context),
                    width: Responsive.width(20, context),
                    color: Color.fromRGBO(48, 111, 220, 1)),
                SizedBox(width: Responsive.width(4, context)),
                Text(
                  "Public",
                  style: TextStyle(
                    color: Color.fromRGBO(48, 111, 220, 1),
                    fontSize: Responsive.text(16, context),
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(
                horizontal: Responsive.width(10, context),
                vertical: Responsive.height(4, context)),
            decoration: BoxDecoration(
                border: Border.all(color: Color.fromRGBO(48, 111, 220, 1)),
                color: Color.fromRGBO(48, 111, 220, 1),
                borderRadius:
                    BorderRadius.circular(Responsive.width(100, context))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  "assets/communities/mdi_anonymous.svg",
                  height: Responsive.height(20, context),
                  width: Responsive.width(20, context),
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
                SizedBox(width: Responsive.width(4, context)),
                Text(
                  "Anonymous",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: Responsive.text(16, context),
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
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
    bool isLoaded = loadedImageIndices.contains(index);

    return Stack(
      key: ValueKey('image_$index'),
      children: [
        Container(
          margin: EdgeInsets.only(right: Responsive.width(8, context)),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(Responsive.width(16.9, context)),
          ),
          child: Stack(
            children: [
              Image.file(
                file,
                height: Responsive.height(77.62, context),
                width: Responsive.width(77.62, context),
                fit: BoxFit.fill,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (!isLoaded && frame != null) {
                    Future.microtask(() {
                      setState(() {
                        loadedImageIndices.add(index);
                      });
                    });
                  }
                  return child;
                },
              ),
              if (!isLoaded)
                Container(
                  height: Responsive.height(77.62, context),
                  width: Responsive.width(77.62, context),
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          right: Responsive.width(13, context),
          top: Responsive.height(3, context),
          child: SizedBox(
            height: Responsive.height(20, context),
            width: Responsive.width(20, context),
            child: Material(
              color: Colors.white70,
              shape: const CircleBorder(),
              child: IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(Icons.close),
                constraints: BoxConstraints(),
                iconSize: Responsive.width(20, context),
                onPressed: () {
                  setState(() {
                    imageFiles.removeAt(index);
                    loadedImageIndices.remove(index);
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PollCreator extends StatefulWidget {
  final VoidCallback? onClose;
  final Function(Map<String, dynamic>)? onPollDataChanged;
  final Map<String, dynamic>? initialData;

  const PollCreator({
    Key? key,
    this.onClose,
    this.initialData,
    this.onPollDataChanged,
  }) : super(key: key);
  @override
  _PollCreatorState createState() => _PollCreatorState();
}

class _PollCreatorState extends State<PollCreator> {
  TextEditingController questionController = TextEditingController();
  List<TextEditingController> optionControllers = [];
  bool allowMultipleAnswers = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      allowMultipleAnswers =
          widget.initialData!['poll_allow_multiple_answers'] ?? false;
      questionController.text = widget.initialData!['poll_question'] ?? '';

      final pollOptions = widget.initialData!['poll_options'];
      if (pollOptions != null && pollOptions is List) {
        optionControllers = pollOptions
            .map((option) => TextEditingController(text: option))
            .cast<TextEditingController>()
            .toList();
      } else {
        optionControllers = [
          TextEditingController(),
          TextEditingController(),
        ];
      }
    } else {
      optionControllers = [
        TextEditingController(),
        TextEditingController(),
      ];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePollData();
    });
  }

  void _updatePollData() {
    if (!mounted) return;
    final pollData = {
      'poll_question': questionController.text.trim(),
      'poll_allow_multiple_answers': allowMultipleAnswers,
      'poll_options': optionControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList(),
    };

    if (widget.onPollDataChanged != null) {
      Future.microtask(() => widget.onPollDataChanged!(pollData));
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget buildCustomSwitch() {
    return GestureDetector(
      onTap: () {
        setState(() {
          allowMultipleAnswers = !allowMultipleAnswers;
          _updatePollData();
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
              child: TextFormField(
                maxLines: null,
                controller: questionController,
                onChanged: (value) {
                  _updatePollData();
                },
                decoration: InputDecoration(
                  hintText: "Ask question",
                  hintStyle: TextStyle(
                    color: const Color(0xFF7E8287),
                    fontSize: Responsive.text(14, context),
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
                  fontSize: Responsive.text(14, context),
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
                  width: Responsive.width(1, context),
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
                        _updatePollData();
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
                                  onChanged: (value) {
                                    _updatePollData();
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Option",
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF7E8287),
                                      fontSize: Responsive.text(14, context),
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
                                    fontSize: Responsive.text(14, context),
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
                                  iconSize: Responsive.width(20, context),
                                  onPressed: () {
                                    setState(() {
                                      optionControllers[index].dispose();
                                      optionControllers.removeAt(index);
                                      _updatePollData();
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
                          _updatePollData();
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add option',
                            style: TextStyle(
                              color: const Color(0xFFBEBEBE),
                              fontSize: Responsive.text(14, context),
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
                    fontSize: Responsive.text(14, context),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                buildCustomSwitch(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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



      //For uploading Files
        // Widget _buildAttachedFile(PlatformFile file, int index) {
//     String fileName = file.name;
//     String fileExtension = path.extension(fileName).toLowerCase();
//     int fileSize = file.size;
//     String fileSizeText = _formatFileSize(fileSize);

//     IconData fileIcon = _getFileIcon(fileExtension);
//     Color fileColor = _getFileColor(fileExtension);

//     return Stack(
//       children: [
//         Container(
//           width: Responsive.width(77.62, context),
//           height: Responsive.height(77.62, context),
//           clipBehavior: Clip.antiAlias,
//           decoration: BoxDecoration(
//             borderRadius:
//                 BorderRadius.circular(Responsive.width(16.9, context)),
//             border: Border.all(color: Colors.grey.shade300, width: 1),
//           ),
//           child: Icon(
//             size: Responsive.height(77.62, context),
//             fileIcon,
//             color: fileColor,
//             // size: Responsive.height(77.62, context),
//           ),
//         ),
//         Positioned(
//           right: -10,
//           top: -10,
//           child: Container(
//             child: IconButton(
//               icon: Icon(Icons.close),
//               onPressed: () {
//                 setState(() {
//                   attachedFiles.removeAt(index);
//                   if (index < documentFiles.length) {
//                     documentFiles.removeAt(index);
//                   }
//                 });
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

// // Helper method to format file size
//   String _formatFileSize(int bytes) {
//     if (bytes < 1024) return '$bytes B';
//     if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
//     if (bytes < 1024 * 1024 * 1024)
//       return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
//     return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
//   }

// // Helper method to get file icon
//   IconData _getFileIcon(String extension) {
//     switch (extension) {
//       case '.pdf':
//         return Icons.picture_as_pdf;
//       case '.doc':
//       case '.docx':
//         return Icons.description;
//       case '.txt':
//         return Icons.text_snippet;
//       case '.jpg':
//       case '.jpeg':
//       case '.png':
//       case '.gif':
//         return Icons.image;
//       case '.mp4':
//       case '.avi':
//       case '.mov':
//         return Icons.video_file;
//       case '.mp3':
//       case '.wav':
//       case '.aac':
//         return Icons.audio_file;
//       case '.zip':
//       case '.rar':
//         return Icons.archive;
//       default:
//         return Icons.insert_drive_file;
//     }
//   }

// // Helper method to get file color
//   Color _getFileColor(String extension) {
//     switch (extension) {
//       case '.pdf':
//         return Colors.red;
//       case '.doc':
//       case '.docx':
//         return Colors.blue;
//       case '.txt':
//         return Colors.grey;
//       case '.jpg':
//       case '.jpeg':
//       case '.png':
//       case '.gif':
//         return Colors.green;
//       case '.mp4':
//       case '.avi':
//       case '.mov':
//         return Colors.purple;
//       case '.mp3':
//       case '.wav':
//       case '.aac':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   Future<void> _pickFiles() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.any,
//         allowMultiple: true,
//         allowedExtensions: null, // Allow all file types
//       );

//       if (result != null) {
//         setState(() {
//           // Add selected files to the list
//           attachedFiles.addAll(result.files);

//           // Convert PlatformFile to File for upload
//           for (PlatformFile platformFile in result.files) {
//             if (platformFile.path != null) {
//               documentFiles.add(File(platformFile.path!));
//             }
//           }
//         });

//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('${result.files.length} file(s) selected'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error selecting files: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
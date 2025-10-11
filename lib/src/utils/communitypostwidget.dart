import 'dart:async';

import 'package:InstiApp/constants.dart';
import 'package:InstiApp/src/api/model/communityPost.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/community_post_bloc.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/routes/communitypostpage.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/utils/share_url_maker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class Communitypostwidget extends StatefulWidget {
  final CommunityPost communityPost;
  final void Function()? onPressedComment;
  final bool shouldTap;
  final CPType postType;
  //Map<String,String> c;
  Communitypostwidget({required this.communityPost,this.onPressedComment,this.shouldTap = true,this.postType = CPType.All,});

  @override
  State<Communitypostwidget> createState() => _CommunitypostwidgetState();
}

class _CommunitypostwidgetState extends State<Communitypostwidget> {
  bool contentExpanded = false;
  bool isAnon = false;
  late CommunityPost communityPost;
  @override
  void initState() {
    super.initState();
    communityPost = widget.communityPost;
    isAnon = widget.postType == CPType.All
        ? (communityPost.anonymous == true)
        : false;
  }
  bool showSelf() {
    if (widget.postType == CPType.YourPosts) return true;
    return !(communityPost.deleted == true);
  }

  int _calculateContentChars() {
    return widget.postType == CPType.Featured
        ? communityPost.imageUrl == null || communityPost.imageUrl!.isEmpty
            ? 300
            : 50
        : 300;
  }

  int _calculateTotalReactions() {
    if (communityPost.reactionCount == null) return 0;

    int total = 0;
    communityPost.reactionCount!.forEach((key, value) {
      total += value;
    });
    return total;
  }
  void Function()? _getContentTapHandler(){}
  void Function()? _getCommentHandler(){ return () => CommunityPostPage.navigateWith(context,
              BlocProvider.of(context)!.bloc.communityPostBloc, communityPost); }
  Constants myConstants = Constants();
  Widget footer(String reactionCount, String commentCount){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(Icons.emoji_emotions_outlined, size: 20, color: Color.fromRGBO(68, 68, 68, 1)),
            SizedBox(width: 6,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.5),
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                color: myConstants.instiappGrey
              ),
              child: Row(
                children: [
                  Image.asset("assets/communities/emojis/laugh.png",height: 18.5,width: 18.5,),
                  Image.asset("assets/communities/emojis/cry.png",height: 18.5,width: 18.5,)
                ],
              ),
            ),
            SizedBox(width: 6,),
            Text(
              reactionCount
            )
          ]
          
        ),
        SizedBox(width: 25),
        Dash(
          direction: Axis.vertical,
          length: 25,
          dashLength: 25,
          dashGap: 0,
          dashColor: Color(0xFFD9D9D9),
        ),
        SizedBox(width: 25),
        Icon(Icons.chat_bubble_outline,size: 15,color: Color(0XFF444444)),
        SizedBox(width: 7,),
        Text(
          commentCount+" comments"
        ),
        SizedBox(width: 25),
        Dash(
          direction: Axis.vertical,
          length: 25,
          dashLength: 25,
          dashGap: 0,
          dashColor: Color(0xFFD9D9D9),
        ),
        SizedBox(width: 25),
        Icon(Icons.share_outlined, size: 16,),
        SizedBox(width: 6,),
        Text(
          "Share"
        )


      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    final content = communityPost.content ?? "";
    final contentChars = _calculateContentChars();
    final numReactions = _calculateTotalReactions();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey
                ),
                
              ),
              SizedBox(width: 12),
              Expanded(
                //width: 327,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 4),
                    _buildContent(content, contentChars),
                    if (communityPost.imageUrl != null &&
                      communityPost.imageUrl!.isNotEmpty)
                        _buildImages(),                  
                    if (communityPost.isPoll == true && communityPost.poll != null)
                    SizedBox(height: 16),
                    if (communityPost.isPoll == true && communityPost.poll != null)
                    PollViewer(
                      poll: communityPost.poll!,
                      onVoted: (List<String> selectedOptionIds) {
                        // print("User voted for options: $selectedOptionIds");
                        BlocProvider.of(context)!
                            .bloc
                            .communityPostBloc
                            .voteOnPoll(communityPost.id!, selectedOptionIds);
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 16),
        _buildFooter(numReactions),
        SizedBox(height: 16),
        // Dash(
        //   direction: Axis.horizontal,
        //   dashLength:MediaQuery.of(context).size.width- 32,
        //   length: MediaQuery.of(context).size.width- 32,
        //   dashGap: 0,
        //   dashColor: Color(0xFFDADADA),
        // ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 1,
          color: Color(0xFFDADADA),
        )
      ],
    );
    // return Column(
    //   //mainAxisAlignment: MainAxisAlignment.start,
    //   children: [
    //     SizedBox(height: 16),
    //     Row(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Container(
    //           height: 40,
    //           width: 40,
    //           decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(20),
    //             color: Colors.grey
    //           ),
    //         ),
    //         SizedBox(width: 12,),
    //         Container(
    //           width: 327,
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                 children: [
    //                   Row(
    //                     children: [
    //                       Text(
    //                         widget.c["name"]??"",
    //                         style: TextStyle(
    //                           fontSize: 18,
    //                           fontWeight: FontWeight.w700,
    //                         )
    //                       ),
    //                       SizedBox(width: 13,),
    //                       Text(
    //                         widget.c["date"]??"",
    //                         style: TextStyle(
    //                           fontSize: 12,
    //                           fontWeight: FontWeight.w400
    //                         ),
    //                       ),
                          
    //                     ],
    //                   ),
    //                   Container(
    //                       height: 24,
    //                       width: 24,
    //                       //color: Colors.purple,
    //                       decoration: BoxDecoration(
    //                         borderRadius: BorderRadius.circular(12),
    //                         color: myConstants.instiappGrey
    //                       ),
    //                       child: Icon(Icons.delete_outline,color: Color(0XFFF8471B),size: 20),
    //                   )
    //                 ],
    //               ),
    //               SizedBox(height: 4),
    //               Text(
    //                 "Just wanted to get your thoughts on when we should kick off the party! We want to make sure it works for most of you. Please vote for your preferred timing below and feel free to drop any suggestions.",
    //                 style: TextStyle(
    //                   fontSize: 16
    //                 ),
    //               )
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //     SizedBox(height: 16),
    //     footer("2", "2"),
    //     SizedBox(height: 16,),
    //     Dash(
    //       direction: Axis.horizontal,
    //       length: 379,
    //       dashLength: 379,
    //       dashColor: myConstants.instiappGrey,
    //     )
    //   ],
    // );
  }

  Widget _buildHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Left side: name + date
      Row(
        children: [
          Text(
            isAnon
                ? "Anonymous User"
                : communityPost.postedBy?.userName ?? "Anonymous user",
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 13),
          Text(
            DateFormat("dd MMM, yyyy")
                .format(DateTime.parse(communityPost.timeOfCreation!)),
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(68, 68, 68, 1),
            ),
          ),
        ],
      ),

      // Right side: delete button (only for "Your Posts")
      if (widget.postType == CPType.YourPosts)
        GestureDetector(
          onTap: () {
            // Add your delete logic here (e.g., show confirmation, call API, etc.)
          },
          child: Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: myConstants.instiappGrey,
            ),
            child: Icon(
              Icons.delete_outline,
              color: Color(0xFFF8471B),
              size: 20,
            ),
          ),
        ),
    ],
  );
  }
  Widget _buildContent(String content, int contentChars) {
    return GestureDetector(
      onTap: _getContentTapHandler,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableLinkify(
            text: content.length > contentChars && !contentExpanded
                ? content.substring(0, contentChars) +
                    (contentExpanded ? "" : "...")
                : content,
            onOpen: (link) async {
              if (await canLaunchUrl(Uri.parse(link.url))) {
                await launchUrl(Uri.parse(link.url),
                    mode: LaunchMode.externalApplication);
              }
            },
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              color: Colors.black,
              height: 1.25,
            ),
          ),
          if (!contentExpanded && content.length > contentChars)
            GestureDetector(
              onTap: () => setState(() {
                contentExpanded = true;
              }),
              child: Text(
                'Read More',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  color: Color.fromRGBO(48, 111, 220, 1),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildImages() {
    final images = communityPost.imageUrl!;
    final imageCount = images.length;
    for(int i =0 ; i<imageCount; i++){
      images[i]=fixImageUrl(images[i]);
    }


    if (imageCount == 0) return Container();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12, bottom: 0),
      child: _buildImageGrid(images, imageCount),
    );
  }

  Widget _buildFeaturedImages() {
    final images = communityPost.imageUrl!;
    if (images.isEmpty) return Container();

    // For featured posts, show only first image
    return Container(
      width: double.infinity,
      height: 180,
      margin: EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          images[0],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Color(0xFFF0F0F0),
              child: Icon(Icons.error_outline, color: Color(0xFF666666)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> images, int imageCount) {
    switch (imageCount) {
      case 1:
        return FutureBuilder<ImageInfo>(
          future: _getImageInfo(images[0]),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Color(0xFFF0F0F0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final imageInfo = snapshot.data;
            final aspectRatio = imageInfo != null
                ? imageInfo.image.width / imageInfo.image.height
                : 16 / 9;

            return AspectRatio(
              aspectRatio: aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  images[0],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Color(0xFFF0F0F0),
                      child:
                          Icon(Icons.error_outline, color: Color(0xFF666666)),
                    );
                  },
                ),
              ),
            );
          },
        );

      case 2:
        return FutureBuilder<List<ImageInfo?>>(
          future: Future.wait([
            _getImageInfo(images[0]),
            _getImageInfo(images[1]),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container(
                height: 200,
                child: Row(
                  children: [
                    Expanded(child: _buildImagePlaceholder()),
                    SizedBox(width: 4),
                    Expanded(child: _buildImagePlaceholder()),
                  ],
                ),
              );
            }

            final imageInfos = snapshot.data!;
            final aspectRatio1 = imageInfos[0] != null
                ? imageInfos[0]!.image.width / imageInfos[0]!.image.height
                : 1.0;
            final aspectRatio2 = imageInfos[1] != null
                ? imageInfos[1]!.image.width / imageInfos[1]!.image.height
                : 1.0;

            // Calculate height that maintains both aspect ratios
            final availableWidth = MediaQuery.of(context).size.width -
                92; // 60px avatar + 32px padding
            final gapWidth = 4.0;
            final totalWidth = availableWidth - gapWidth;

            final width1 =
                totalWidth * (aspectRatio1 / (aspectRatio1 + aspectRatio2));
            final width2 = totalWidth - width1;
            final height1 = width1 / aspectRatio1;
            final height2 = width2 / aspectRatio2;

            final containerHeight = height1 > height2 ? height1 : height2;

            return Container(
              height: containerHeight,
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[0],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: gapWidth),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[1],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

      case 3:
        return Container(
          height: 200,
          child: Row(
            children: [
              // Big image on left (50% width)
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  child: Image.network(
                    images[0],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  ),
                ),
              ),
              SizedBox(width: 4),
              // Two small images on right (50% width total)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                        ),
                        child: Image.network(
                          images[1],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(8),
                        ),
                        child: Image.network(
                          images[2],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 4:
        return LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final spacing = 4.0;
            final itemSize = (totalWidth - spacing) / 2; // each square

            return Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[0],
                        width: itemSize,
                        height: itemSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
                    ),
                    SizedBox(width: spacing),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[1],
                        width: itemSize,
                        height: itemSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[2],
                        width: itemSize,
                        height: itemSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
                    ),
                    SizedBox(width: spacing),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[3],
                        width: itemSize,
                        height: itemSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );

      default: // 5 or more
        return LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final spacing = 4.0;

            // Calculate widths
            final leftWidth = (totalWidth - spacing) / 2;
            final rightWidth = (totalWidth - spacing) / 2;
            final gridItemSize = (rightWidth - spacing) / 2;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Big left image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Image.network(
                    images[0],
                    width: leftWidth,
                    height: leftWidth, // square
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImagePlaceholder(),
                  ),
                ),
                SizedBox(width: spacing),
                // Right 2x2 grid
                Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          //borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            images[1],
                            width: gridItemSize,
                            height: gridItemSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                          ),
                        ),
                        SizedBox(width: spacing),
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12)
                          ),
                          child: Image.network(
                            images[2],
                            width: gridItemSize,
                            height: gridItemSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing),
                    Row(
                      children: [
                        ClipRRect(
                          //borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            images[3],
                            width: gridItemSize,
                            height: gridItemSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                          ),
                        ),
                        SizedBox(width: spacing),
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(12)
                          ),
                          child: Stack(
                            children: [
                              Image.network(
                                images[4],
                                width: gridItemSize,
                                height: gridItemSize,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildImagePlaceholder(),
                              ),
                              if (images.length > 5)
                                Positioned.fill(
                                  child: Container(
                                    color: Color(0xB3000000),
                                    child: Center(
                                      child: Text(
                                        "+${images.length - 5}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15.29
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            );
          },
        );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Color(0xFFF0F0F0),
      child: Icon(Icons.error_outline, color: Color(0xFF666666)),
    );
  }

  Future<ImageInfo> _getImageInfo(String imageUrl) async {
    final completer = Completer<ImageInfo>();
    final imageStream =
        NetworkImage(imageUrl).resolve(ImageConfiguration.empty);
    print(imageStream);

    final listener =
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      completer.complete(info);
    });

    imageStream.addListener(listener);
    return completer.future;
  }

  BorderRadius _getGridImageBorderRadius(int index, int total) {
    switch (total) {
      case 4:
        switch (index) {
          case 0:
            return BorderRadius.only(topLeft: Radius.circular(8));
          case 1:
            return BorderRadius.only(topRight: Radius.circular(8));
          case 2:
            return BorderRadius.only(bottomLeft: Radius.circular(8));
          case 3:
            return BorderRadius.only(bottomRight: Radius.circular(8));
          default:
            return BorderRadius.circular(8);
        }
      default:
        return BorderRadius.circular(6);
    }
  }
  Widget _buildFooter(int numReactions) {
    final commentsCount = communityPost.commentsCount ?? 0;

    switch (widget.postType) {
      case CPType.All:
      case CPType.YourPosts:
        return Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reactions
              _buildReactionButton(numReactions),
              SizedBox(width: 25),
              Container(
                height: 24,
                width: 1,
                color: Color.fromRGBO(217, 217, 217, 1),
              ),
              SizedBox(width: 25),
              // Comments
              _buildCommentButton(commentsCount),
              SizedBox(width: 25),
              Container(
                height: 24,
                width: 1,
                color: Color.fromRGBO(217, 217, 217, 1),
              ),
              SizedBox(width: 25),
              // Share
              _buildShareButton(),
            ],
          ),
        );

      case CPType.PendingPosts:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFF0F0F0),
                ),
                child: Text(
                  "Disapprove",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    color: Color(0xFF666666),
                  ),
                ),
                onPressed: () {
                  BlocProvider.of(context)!
                      .bloc
                      .communityPostBloc
                      .updateCommunityPostStatus(communityPost.id!, 2);
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF1DA1F2),
                ),
                child: Text(
                  "Approve",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  BlocProvider.of(context)!
                      .bloc
                      .communityPostBloc
                      .updateCommunityPostStatus(communityPost.id!, 1);
                },
              ),
            ),
          ],
        );

      case CPType.ReportedContent:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFF0F0F0),
                ),
                child: Text(
                  "Ignore",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    color: Color(0xFF666666),
                  ),
                ),
                onPressed: () {
                  BlocProvider.of(context)!
                      .bloc
                      .communityPostBloc
                      .updateCommunityPostStatus(communityPost.id!, 1);
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFFF24822),
                ),
                child: Text(
                  "Delete",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  BlocProvider.of(context)!
                      .bloc
                      .communityPostBloc
                      .updateCommunityPostStatus(communityPost.id!, 2);
                },
              ),
            ),
          ],
        );

      default:
        return Container();
    }
  }
  Widget _buildReactionButton(int numReactions) {
    final bloc = BlocProvider.of(context)!.bloc;

    return PopupMenuButton<int>(
      onSelected: (val) => _handleReactionSelection(val, bloc),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<int>>[
          _buildReactionMenu(),
        ];
      },
      child: Row(
        children: [
          communityPost.userReaction == -1
              ? Icon(Icons.emoji_emotions_outlined,
                  size: 20, color: Color.fromRGBO(68, 68, 68, 1))
              : Image.asset(_getEmojiPath(communityPost.userReaction!),
                  width: 20),
          SizedBox(width: 6),
          if (communityPost.reactionCount != null &&
              communityPost.reactionCount!.isNotEmpty)
              Builder(builder: (_) {
              // Sort by count (descending)
              final sorted = communityPost.reactionCount!.entries.toList()
              ..sort((a, b) => (b.value ?? 0).compareTo(a.value ?? 0));
              // Take top 2 only
              final topReactions = sorted.take(2).toList();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 1.75),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: topReactions.map((entry) {
                    final emojiIndex = int.tryParse(entry.key) ?? 0;
                    final emojiPath = _getEmojiPath(emojiIndex);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Image.asset(emojiPath, width: 18.5, height: 18.5),
                    );
                    }).toList(),
                    ),
                );
          }),
          SizedBox(width: 6),
          Text(
            '$numReactions',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: Color.fromRGBO(68, 68, 68, 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentButton(int commentsCount) {
    return GestureDetector(
      onTap: widget.onPressedComment ?? _getCommentHandler(),
      child: Row(
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 20, color: Color.fromRGBO(68, 68, 68, 1)),
          SizedBox(width: 6),
          Text(
            '$commentsCount comments',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: Color.fromRGBO(68, 68, 68, 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () => Share.share(
          "Check this post: ${ShareURLMaker.getCommunityPostURL(communityPost)}"),
      child: Row(
        children: [
          Icon(Icons.share_outlined, size: 20, color: Color(0xFF666666)),
          SizedBox(
            width: 6,
          ),
          Text(
            'Share',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: Color.fromRGBO(68, 68, 68, 1),
            ),
          ),
        ],
      ),
    );
  }
  void _handleReactionSelection(int val, InstiAppBloc bloc) async {
    await bloc.communityPostBloc
        .updateUserCommunityPostReaction(communityPost, val);

    setState(() {
      if ((communityPost.userReaction ?? -1) != -1) {
        communityPost.reactionCount![communityPost.userReaction!.toString()] =
            (communityPost.reactionCount![
                        communityPost.userReaction!.toString()] ??
                    1) -
                1;
      }
      communityPost.reactionCount![val.toString()] =
          (communityPost.reactionCount![val.toString()] ?? 0) +
              ((communityPost.userReaction ?? -1) == val ? 0 : 1);
      communityPost.userReaction = communityPost.userReaction == val ? -1 : val;
    });
  }

  List<String> _getEmojis() {
    return [
      "assets/communities/emojis/like.png",
      "assets/communities/emojis/love.png",
      "assets/communities/emojis/laugh.png",
      "assets/communities/emojis/surprise.png",
      "assets/communities/emojis/cry.png",
      "assets/communities/emojis/angry.png",
    ];
  }

  String _getEmojiPath(int index) {
    final emojis = _getEmojis();
    return index >= 0 && index < emojis.length ? emojis[index] : emojis[0];
  }

  PopupMenuWidget<int> _buildReactionMenu() {
    return PopupMenuWidget<int>(
      height: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _getEmojis()
              .asMap()
              .entries
              .map(
                (e) => Container(
                  color: e.key == communityPost.userReaction
                      ? Color(0xFF1DA1F2).withOpacity(0.2)
                      : Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(e.key),
                    child: Image.asset(e.value, width: 30),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}


class PollOption extends StatefulWidget {
  final String title;
  final String voteCount;
  final double votePercentage; // A value between 0.0 and 1.0
  final bool isSelected;
  final VoidCallback onTap;

  const PollOption({
    super.key,
    required this.title,
    required this.voteCount,
    required this.votePercentage,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<PollOption> createState() => _PollOptionState();
}

class _PollOptionState extends State<PollOption> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Row for radio button, title, and vote count ---
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected ? const Color(0xFF306FDC) : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected ? const Color(0xFF306FDC) : const Color(0xFF7E8287),
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Color(0xCC0F1620),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.voteCount,
                style: const TextStyle(
                  color: Color(0xCC0F1620),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
      
          // --- Progress Bar ---
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2D5DA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Container(
                    width: constraints.maxWidth * widget.votePercentage,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF306FDC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}


// 2. The Main Widget Using the Reusable PollOption
class PollViewer extends StatefulWidget {
  final Poll poll;
  final Function(List<String> selectedOptionIds) onVoted;

  const PollViewer({
    Key? key,
    required this.poll,
    required this.onVoted,
  }) : super(key: key);

  @override
  State<PollViewer> createState() => _PollViewerState();
}

class _PollViewerState extends State<PollViewer> {
  late Set<String> _selectedOptionIds;
  late bool _hasAlreadyVoted;

    @override
  void initState() {
    super.initState();
    _selectedOptionIds = widget.poll.options
            ?.where((opt) => opt.userVoted == true)
            .map((opt) => opt.id!)
            .toSet() ??
        {};
    // print("Initial selected options: $_selectedOptionIds");
    _hasAlreadyVoted = widget.poll.userVoted ?? _selectedOptionIds.isNotEmpty;
  }

  void _handleVote(String tappedOptionId) async {
    final prevSelected = Set<String>.from(_selectedOptionIds);
    final prevOptionVotes = widget.poll.options
            ?.map((o) => o.voteCount ?? 0)
            .toList(growable: false) ??
        [];
    final prevUserVotedFlags =
        widget.poll.options?.map((o) => o.userVoted ?? false).toList() ?? [];
    final prevTotalVotes = widget.poll.totalVotes ?? 0;

    setState(() {
      if (widget.poll.allowMultipleAnswers == true) {
        if (_selectedOptionIds.contains(tappedOptionId)) {
          _selectedOptionIds.remove(tappedOptionId);
          final idx = widget.poll.options!
              .indexWhere((opt) => opt.id == tappedOptionId);
          if (idx != -1) {
            widget.poll.options![idx].voteCount =
                (widget.poll.options![idx].voteCount ?? 1) - 1;
            if ((widget.poll.options![idx].voteCount ?? 0) < 0) {
              widget.poll.options![idx].voteCount = 0;
            }
            widget.poll.options![idx].userVoted = false;
            widget.poll.totalVotes = (widget.poll.totalVotes ?? 0) - 1;
            if ((widget.poll.totalVotes ?? 0) < 0) widget.poll.totalVotes = 0;
          }
        } else {
          // select -> increment
          _selectedOptionIds.add(tappedOptionId);
          final idx = widget.poll.options!
              .indexWhere((opt) => opt.id == tappedOptionId);
          if (idx != -1) {
            widget.poll.options![idx].voteCount =
                (widget.poll.options![idx].voteCount ?? 0) + 1;
            widget.poll.options![idx].userVoted = true;
            widget.poll.totalVotes = (widget.poll.totalVotes ?? 0) + 1;
          }
        }
      } else {
        // single-select behavior
        final previouslySelected =
            _selectedOptionIds.isNotEmpty ? _selectedOptionIds.first : null;
        if (previouslySelected == tappedOptionId) {
          // unselect the only selection
          _selectedOptionIds.clear();
          final idx = widget.poll.options!
              .indexWhere((opt) => opt.id == tappedOptionId);
          if (idx != -1) {
            widget.poll.options![idx].voteCount =
                (widget.poll.options![idx].voteCount ?? 1) - 1;
            widget.poll.options![idx].userVoted = false;
            widget.poll.totalVotes = (widget.poll.totalVotes ?? 0) - 1;
            if ((widget.poll.totalVotes ?? 0) < 0) widget.poll.totalVotes = 0;
          }
        } else {
          // switch selection
          _selectedOptionIds = {tappedOptionId};
          // decrement old
          if (previouslySelected != null) {
            final oldIdx = widget.poll.options!
                .indexWhere((opt) => opt.id == previouslySelected);
            if (oldIdx != -1) {
              widget.poll.options![oldIdx].voteCount =
                  (widget.poll.options![oldIdx].voteCount ?? 1) - 1;
              widget.poll.options![oldIdx].userVoted = false;
              if ((widget.poll.options![oldIdx].voteCount ?? 0) < 0)
                widget.poll.options![oldIdx].voteCount = 0;
            }
          }
          // increment new
          final newIdx =
              widget.poll.options!.indexWhere((opt) => opt.id == tappedOptionId);
          if (newIdx != -1) {
            widget.poll.options![newIdx].voteCount =
                (widget.poll.options![newIdx].voteCount ?? 0) + 1;
            widget.poll.options![newIdx].userVoted = true;
          }
          // adjust total (if switching, total stays same; if new selection from none, increment)
          if (previouslySelected == null) {
            widget.poll.totalVotes = (widget.poll.totalVotes ?? 0) + 1;
          }
        }
      }
    });

    // Call the provided callback and await if it returns a Future.
    try {
      final result = widget.onVoted(_selectedOptionIds.toList());
      if (result is Future) await result;
      // success -> keep optimistic UI
    } catch (e) {
      // revert to previous state on failure
      setState(() {
        _selectedOptionIds = prevSelected;
        widget.poll.totalVotes = prevTotalVotes;
        for (int i = 0;
            i < (widget.poll.options?.length ?? 0) &&
                i < prevOptionVotes.length;
            i++) {
          widget.poll.options![i].voteCount = prevOptionVotes[i];
          widget.poll.options![i].userVoted = prevUserVotedFlags[i];
        }
      });
      // optionally show error feedback:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register vote. Please try again.')),
      );
    }
  }
// ...existing code...

  @override
  Widget build(BuildContext context) {
    print("Building PollViewer with selected options:" + widget.poll.options![0].userVoted.toString());
    final totalVotes = widget.poll.totalVotes ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          width: 1,
          color: const Color(0xFFD2D5DA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Header Text ---
          Text(
            widget.poll.question ?? "Poll Question",
            style: TextStyle(
              color: Color(0xFF0F1620),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.poll.allowMultipleAnswers == true
                ? 'Select one or more'
                : 'Select one',
            style: TextStyle(
              color: Color(0xFF7E8287),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),

          // --- Poll Options ---
          // PollOption(
          //   title: '9:30 - 10:30 PM',
          //   voteCount: '0',
          //   votePercentage: 0.0,
          //   isSelected: false,
          //   onTap: () => _handleVote('option1'),
          // ),
          // const SizedBox(height: 16),
          // PollOption(
          //   title: 'After 9 PM',
          //   voteCount: '22',
          //   votePercentage: 0.65, // Example percentage
          //   isSelected: true,
          // ),
          // const SizedBox(height: 16),
          // const PollOption(
          //   title: 'Tomorrow | suggest timings etc etc abcde',
          //   voteCount: '152',
          //   votePercentage: 0.9, // Example percentage
          //   isSelected: false,
          // ),
          ...?widget.poll.options?.map((option) {
            final isSelected = _selectedOptionIds.contains(option.id);
            final double percentage = totalVotes > 0 ? (option.voteCount ?? 0) / totalVotes : 0.0;
            return PollOption(
              title: option.text ?? 'Option',
              voteCount: (option.voteCount ?? 0).toString(),
              votePercentage: percentage,
              isSelected: isSelected,
              onTap: () => {_handleVote(option.id!),},
            );
          })
        ],
      ),
    );
  }}

//remove this when on prod
  String fixImageUrl(String? url) {
  if (url == null || url.isEmpty) return "";
  
  // Replace localhost with your ngrok URL
  if (url.startsWith("http://localhost:8000")) {
    return url.replaceFirst(
      "http://localhost:8000", 
      "https://fc37c3e64571.ngrok-free.app"  // Your actual server URL
    );
  }
  
  return url;
}
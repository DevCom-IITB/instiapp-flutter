import 'dart:core';

import 'package:InstiApp/src/blocs/blog_bloc.dart';
import 'package:InstiApp/src/routes/blogpage.dart';
import 'package:flutter/material.dart';

class QueryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlogPage(
      loginNeeded: false,
      postType: PostType.Query,
      title: "FAQs",
    );
  }
}



// import 'package:InstiApp/src/api/response/explore_response.dart';
// import 'package:InstiApp/src/bloc_provider.dart';
// import 'package:InstiApp/src/drawer.dart';
// import 'package:InstiApp/src/utils/common_widgets.dart';
// import 'package:InstiApp/src/utils/title_with_backbutton.dart';
// import 'package:flutter/material.dart';

// class QueryPage extends StatefulWidget {
//   final String title = "FAQs";
//   const QueryPage({Key key}) : super(key: key);

//   @override
//   _QueryPageState createState() => _QueryPageState();
// }

// class _QueryPageState extends State<QueryPage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       GlobalKey<RefreshIndicatorState>();

//   FocusNode _focusNode = FocusNode();
//   ScrollController _hideButtonController;
//   TextEditingController _searchFieldController;
//   double isFabVisible = 0;

//   bool searchMode = false;
//   IconData actionIcon = Icons.search_outlined;

//   String currCat;

//   @override
//   void initState() {
//     super.initState();
//     _searchFieldController = TextEditingController();
//     _hideButtonController = ScrollController();
//     _hideButtonController.addListener(() {
//       if (isFabVisible == 1 && _hideButtonController.offset < 100) {
//         setState(() {
//           isFabVisible = 0;
//         });
//       } else if (isFabVisible == 0 && _hideButtonController.offset > 100) {
//         setState(() {
//           isFabVisible = 1;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     ThemeData theme = Theme.of(context);
//     var bloc = BlocProvider.of(context).bloc;
//     var exploreBloc = bloc.exploreBloc;

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       key: _scaffoldKey,
//       drawer: NavDrawer(),
//       bottomNavigationBar: MyBottomAppBar(
//         shape: RoundedNotchedRectangle(),
//         child: new Row(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
//             IconButton(
//               tooltip: "Show bottom sheet",
//               icon: Icon(
//                 Icons.menu_outlined,
//                 semanticLabel: "Show bottom sheet",
//               ),
//               onPressed: () {
//                 _scaffoldKey.currentState.openDrawer();
//               },
//             ),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: GestureDetector(
//           onTap: () {
//             _focusNode.unfocus();
//           },
//           child: ListView(controller: _hideButtonController, children: <Widget>[
//             RefreshIndicator(
//               key: _refreshIndicatorKey,
//               onRefresh: () {
//                 return exploreBloc.refresh();
//               },
//               child: TitleWithBackButton(
//                 child: Row(
//                   mainAxisSize: MainAxisSize.max,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     Expanded(
//                       child: Text(
//                         widget.title,
//                         style: theme.textTheme.headline3,
//                       ),
//                     ),
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 500),
//                       // width: searchMode ? 0.0 : null,
//                       // height: searchMode ? 0.0 : null,
//                       decoration: searchMode
//                           ? null
//                           : ShapeDecoration(
//                               shape: CircleBorder(
//                                   side: BorderSide(color: theme.primaryColor))),
//                       child: searchMode
//                           ? buildDropdownButton(theme)
//                           : IconButton(
//                               tooltip: "Search ${widget.title}",
//                               padding: EdgeInsets.all(16.0),
//                               icon: Icon(
//                                 actionIcon,
//                                 color: theme.primaryColor,
//                               ),
//                               color: theme.cardColor,
//                               onPressed: () {
//                                 setState(() {
//                                   actionIcon = Icons.close_outlined;
//                                   searchMode = !searchMode;
//                                 });
//                               },
//                             ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             !searchMode
//                 ? SizedBox(
//                     height: 0,
//                   )
//                 : PreferredSize(
//                     preferredSize: Size.fromHeight(72),
//                     child: AnimatedContainer(
//                       color: theme.canvasColor,
//                       padding: EdgeInsets.all(8.0),
//                       duration: Duration(milliseconds: 500),
//                       child: Column(
//                         children: [
//                           TextField(
//                             controller: _searchFieldController,
//                             cursorColor: theme.textTheme.bodyText2.color,
//                             style: theme.textTheme.bodyText2,
//                             focusNode: _focusNode,
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(30)),
//                               labelStyle: theme.textTheme.bodyText2,
//                               hintStyle: theme.textTheme.bodyText2,
//                               prefixIcon: Icon(
//                                 Icons.search_outlined,
//                               ),
//                               suffixIcon: IconButton(
//                                 tooltip: "Search events, bodies, users...",
//                                 icon: Icon(
//                                   actionIcon,
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     actionIcon = Icons.search_outlined;
//                                     exploreBloc.query = "";
//                                     exploreBloc.refresh();
//                                     searchMode = !searchMode;
//                                   });
//                                 },
//                               ),
//                               hintText: "Search events, bodies, users...",
//                             ),
//                             onChanged: (query) async {
//                               if (query.length > 4) {
//                                 exploreBloc.query = query;
//                                 exploreBloc.refresh();
//                               }
//                             },
//                             onSubmitted: (query) async {
//                               exploreBloc.query = query;
//                               await exploreBloc.refresh();
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: StreamBuilder<ExploreResponse>(
//                 stream: exploreBloc.explore,
//                 builder: (BuildContext context,
//                     AsyncSnapshot<ExploreResponse> snapshot) {
//                   return Column(
//                     children: [SizedBox()],
//                   );
//                 },
//               ),
//             ),
//           ]),
//         ),
//       ),
//       floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
//       floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
//       floatingActionButton: isFabVisible == 0
//           ? null
//           : FloatingActionButton(
//               tooltip: "Go to the Top",
//               onPressed: () {
//                 _hideButtonController.animateTo(0.0,
//                     curve: Curves.fastOutSlowIn,
//                     duration: const Duration(milliseconds: 600));
//               },
//               child: Icon(Icons.keyboard_arrow_up_outlined),
//             ),
//     );
//   }

  // Widget buildDropdownButton(ThemeData theme) {
  //   List<Map<String, String>> categories = [
  //     {'value': 'cat1', 'name': 'category1'},
  //     {'value': 'cat2', 'name': 'category2'},
  //     {'value': 'cat3', 'name': 'category3'},
  //   ];
  //   return DropdownButton<String>(
  //     hint: Text("Category"),
  //     value: currCat,
  //     items: categories
  //         .map((cat) => DropdownMenuItem<String>(
  //               child: Text(
  //                 cat['name'],
  //               ),
  //               value: cat['value'],
  //             ))
  //         .toList(),
  //     style: theme.textTheme.subtitle1,
  //     onChanged: (c) {
  //       setState(() {
  //         currCat = c;
  //       });
  //     },
  //   );
  // }
// }

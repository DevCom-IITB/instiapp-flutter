import 'package:InstiApp/src/blocs/achievementform_bloc.dart';
import 'package:InstiApp/src/utils/title_with_backbutton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:InstiApp/src/drawer.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import 'package:InstiApp/src/blocs/buynsell_post_block.dart';

import '../api/model/buynsellPost.dart';
import '../bloc_provider.dart';

class BuyAndSellInfoPage extends StatefulWidget {
  final Future<BuynSellPost?> post;

  BuyAndSellInfoPage({required this.post});

  static void navigateWith(
      BuildContext context, BuynSellPost bloc, BuynSellPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(
          name: "/${post.id ?? ""}",
        ),
        builder: (context) => BuyAndSellInfoPage(
          post: bloc.getBuynSellPost(post.id ?? ""),
        ),
      ),
    );
  }

  @override
  State<BuyAndSellInfoPage> createState() => _BuyAndSellInfoPageState();
}

class _BuyAndSellInfoPageState extends State<BuyAndSellInfoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  BuynSellPost? bnsPost;

  @override
  void initState() {
    super.initState();
    widget.post.then((bnsPost) {
      if (this.mounted) {
        setState(() {
          this.bnsPost = bnsPost;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //Map data = ModalRoute.of(context).settings.arguments;
    //str_id = data?['str_id'];
    // ignore: avoid_print
    print(bnsPost?.name);
    var bloc = BlocProvider.of(context)!.bloc;
    var theme = Theme.of(context);

    double screen_h = MediaQuery.of(context).size.height;
    double screen_w = MediaQuery.of(context).size.width;
    double myfont = ((18 / 274.4) * screen_h);

    return Center(
        child: Scaffold(
            key: _scaffoldKey,
            drawer: NavDrawer(),
            bottomNavigationBar: MyBottomAppBar(
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.menu_outlined,
                      semanticLabel: "Show navigation drawer",
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TitleWithBackButton(
                        child: Text(
                          bnsPost!.name ?? "",
                          style: theme.textTheme.headline3,
                        ),
                      ), //Row
                      CachedNetworkImage(
                        imageUrl: (bnsPost?.imageUrl ?? "")
                            .replaceFirst('localhost', '192.168.1.101'),
                        placeholder: (context, url) => new Image.asset(
                          'assets/buy&sell/No-image-found.jpg',
                          fit: BoxFit.fill,
                        ),
                        errorWidget: (context, url, error) => new Image.asset(
                          'assets/buy&sell/No-image-found.jpg',
                          fit: BoxFit.fill,
                        ),
                        fit: BoxFit.fill,
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(25, 15, 25, 0),
                          child: Text((bnsPost?.description ?? ""),
                              style: TextStyle(color: Colors.grey))),
                      Padding(
                          padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                          child: Divider(
                            color: Colors.grey,
                          )),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.fromLTRB(25, 10, 25, 0),
                                child: Text(
                                    'Contact Details - ' +
                                        (bnsPost?.contactDetails ?? ""),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)))
                          ]),
                    ]),
              ),
            ) //Column
            ));
  }
}

import 'package:flutter/material.dart';
import 'package:InstiApp/src/utils/common_widgets.dart';
import '../api/model/buynsellPost.dart';

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
    List<String>? imageList = bnsPost?.imageUrl;
    double screen_wr = MediaQuery.of(context).size.width;
    double screen_hr = MediaQuery.of(context).size.height;
    double x, y;

    var theme = Theme.of(context);

    screen_hr >= screen_wr ? x = 0.35 : x = 1;
    screen_hr >= screen_wr ? y = 0.9 : y = 0.8;
    var screen_w = screen_wr * y;
    var screen_h = screen_hr * x;

    return Scaffold(
      bottomNavigationBar: MyBottomAppBar(
        shape: RoundedNotchedRectangle(),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu_outlined,
                color: Colors.blue.withOpacity(0),
                semanticLabel: "Show navigation drawer",
              ),
              onPressed: () {
                // _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            padding: EdgeInsets.only(top: 32, left: 16),
            alignment: Alignment.topLeft,
            child: Container(
              padding: EdgeInsets.only(top: 32, left: 16),
              alignment: Alignment.topLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blueAccent,
                    width: 2.0,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_outlined,
                      color: Colors.blueAccent),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(screen_w * 0.1, 15, 0, 0),
                child: SizedBox(
                  height: screen_h / 1.2,
                  width: screen_w / 1,
                  child: ImageCarousel(imageList!),
                ),
              ),
              Spacer(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(screen_w * 0.1, 11, 0, 0),
                  child: Text("Brand Name",
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: Colors.black)
                      // style: TextStyle(
                      //     fontSize: myfont / 1.3, fontWeight: FontWeight.w100),
                      )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(screen_w * 0.1, 3, 0, 0),
                  child: Text(bnsPost?.name ?? "",
                      style: theme.textTheme.headline5!
                          .copyWith(fontWeight: FontWeight.bold)
                      // style: TextStyle(
                      //     fontSize: myfont * 1.5, fontWeight: FontWeight.w700),
                      )),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              margin: EdgeInsets.fromLTRB(screen_w * 0.1, 5, 0, 0),
              child: Text("Condition -" + (bnsPost?.condition ?? '0') + '/10',
                  style:
                      theme.textTheme.headline6!.copyWith(color: Colors.black)
                  // style: TextStyle(fontSize: myfont, fontWeight: FontWeight.w100),
                  ),
            )
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              width: screen_w * 0.9,
              margin: EdgeInsets.fromLTRB(screen_w * 0.1, 8, 0, 0),
              child: Text(bnsPost?.description ?? "",
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style:
                      theme.textTheme.bodySmall!.copyWith(color: Colors.black54)
                  // style: TextStyle(
                  //     fontSize: myfont * 0.75, fontWeight: FontWeight.w100),
                  ),
            ),
          ]),
          SizedBox(height: screen_h * 0.28),
          Row(
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(screen_w * 0.1, 8, 0, 0),
                  child: Text(
                      'Contact Details - ' + (bnsPost?.contactDetails ?? ""),
                      style: theme.textTheme.headline6!
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 17)
                      // style: TextStyle(
                      //     fontSize: myfont, fontWeight: FontWeight.w600),
                      )),
              Container(
                  margin: EdgeInsets.fromLTRB(screen_w * 0.3, 11, 0, 0),
                  child: Column(
                    children: [
                      Text(
                          "Negotiable -" +
                              ((bnsPost?.negotiable ?? false) ? "Yes" : "No"),
                          style:
                              theme.textTheme.headline6!.copyWith(fontSize: 17)
                          // style: TextStyle(
                          //     fontSize: myfont, fontWeight: FontWeight.w500),
                          ),
                      Text(
                          (bnsPost!.action == 'giveaway'
                              ? "Give Away"
                              : "Price - ₹" + (bnsPost!.price ?? 0).toString()),
                          style: theme.textTheme.headline4!
                              .copyWith(fontWeight: FontWeight.bold)
                          // style: TextStyle(
                          //     fontSize: myfont * 1.5,
                          //     fontWeight: FontWeight.w800),
                          )
                    ],
                  ))
            ],
          )

          // Add more widgets below the image card
        ]),
      ),
    );
  }
}

class ImageCarousel extends StatefulWidget {
  final List<String> imageList;

  ImageCarousel(this.imageList);

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double screen_wr = MediaQuery.of(context).size.width;
    double screen_hr = MediaQuery.of(context).size.height;
    double x, y;

    screen_hr >= screen_wr ? x = 0.35 : x = 1;
    screen_hr >= screen_wr ? y = 0.9 : y = 0.8;
    var screen_w = screen_wr * y;
    var screen_h = screen_hr * x;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Container(
                child: SizedBox(
                  height: screen_h * 0.7,
                  width: screen_w * 0.6,
                  child: PageView.builder(
                    itemCount: widget.imageList.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            widget.imageList[index],
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.imageList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 10, screen_h * 0.005),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentIndex == index
                            ? Colors.blue
                            : Colors.transparent,
                        width: 1.75,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: screen_h * 0.25,
                      width: screen_w * 0.1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.imageList[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildDotIndicator(),
        ),
      ],
    );
  }

  List<Widget> _buildDotIndicator() {
    List<Widget> dots = [];
    for (int i = 0; i < widget.imageList.length; i++) {
      dots.add(
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == i ? Colors.blueGrey : Colors.grey,
            ),
          ),
        ),
      );
    }
    return dots;
  }
}

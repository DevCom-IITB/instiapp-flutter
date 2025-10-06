import 'dart:collection';

import 'package:InstiApp/constants.dart';
import 'package:InstiApp/src/routes/community.dart';
import 'package:InstiApp/src/routes/communitypage.dart';
import 'package:InstiApp/src/routes/communitypostpage.dart';
import 'package:InstiApp/src/routes/explorepage.dart';
import 'package:InstiApp/src/api/model/mess.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/routes/qr_encryption.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:qr_flutter/qr_flutter.dart';
import "notificationspage.dart";
import 'feedpage.dart';

import 'package:InstiApp/src/routes/userpage.dart';
import 'package:InstiApp/src/api/model/user.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';

class Responsive {
  final BuildContext context;
  final double baseWidth;  
  final double baseHeight;

  Responsive(this.context, {this.baseWidth = 411, this.baseHeight = 914});

  double w(double px) => MediaQuery.of(context).size.width * (px / baseWidth);
  double h(double px) => MediaQuery.of(context).size.height * (px / baseHeight);
  double sp(double px) => w(px); // scale text with width
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String currentpage = 'homepage';
  Constants myConstants = Constants();
  List<String> navIconPaths = [
    'assets/homepage/icons/home.svg',
    'assets/homepage/icons/loader.svg',
    'assets/homepage/icons/search.svg',
    'assets/homepage/icons/message-square.svg',
    //'assets/homepage/icons/map.svg'
  ];
  Map<String,String> navIcons= {
    "Home": 'assets/homepage/icons/home.svg',
    "Feed": 'assets/homepage/icons/loader.svg',
    "Explore": 'assets/homepage/icons/search.svg',
    "Communities": 'assets/homepage/icons/message-square.svg',
  };
  
  List<String> get navIconLabels => navIcons.keys.toList();

  List<String> days = ['Mon', 'Tue'];
  List<String> hostel = ['H-1', 'H-2'];
  List<String> meals = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];
  List<String> mealTime = ['7:30 AM -10:00 AM','12:30 PM - 2:00 PM','4:30 PM - 6:00 PM','7:30 PM - 10:00 PM'];
  List<String> navLabels = ["Home","Feed","Explore","Communities"];
  // String _dropdownHostel='1';
  String _selectedHostel='1';
  String _selectedDay='Monday';
  int selectedMeal=0;
  String label="Home";
  // String _dropdownDay='Mon';
  bool showQR=false;
  String selectedNavIcon='assets//homepage/icons/home.svg';
  bool selectedIcon=true;
  bool firstBuild = true;
  bool error=false;
  bool loading=true;
  String qrString="";
  String _formatMeal(String? meal) {
  return (meal ?? '')
      .split(RegExp(r'[\n,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .join(' • ');
}
  String _mealString(List<Hostel> hostels) {
      if (_selectedHostel.isEmpty) return 'No menu';
      // 1. pick hostel
      final hostel = hostels
          .firstWhere((h) => h.shortName == _selectedHostel, orElse: () => Hostel());
      // 2. pick day (Mon=1 … Sun=7)
      final dayIndex = HostelMess.dayToName.entries
          .firstWhere((e) => e.value.startsWith(_selectedDay), orElse: () => const MapEntry(1,'Monday'))
          .key;
      final mess = hostel.mess?.firstWhere((m) => m.day == dayIndex, orElse: () => HostelMess());
      // 3. pick meal
      switch (selectedMeal) {
        case 0: 
          print("Breakfast is: ${mess?.breakfast}");
          return _formatMeal(mess?.breakfast);
        case 1: return _formatMeal(mess?.lunch);
        case 2: return _formatMeal(mess?.snacks);
        case 3: return _formatMeal(mess?.dinner);
        default: return '—';
      }
    }
    void generateQR() {
  setState(() {
    loading = true;
    error = false;
  });

  final profile = BlocProvider.of(context)!.bloc.currSession?.profile;

  if (profile != null) {
    final qr_encryption = QREncryption(profile);
    final qr = qr_encryption.Encrypt();

    setState(() {
      qrString = qr;
      loading = false;
    });
  } else {
    setState(() {
      error = true;
      loading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    var bloc = BlocProvider.of(context)!.bloc;
    if (firstBuild) {
      bloc.updateHostels();
      generateQR();
      firstBuild = false;
    }

    return Scaffold(
      body: Stack(
        children: [
          if(currentpage == 'homepage')
          Homepagewidget(),
          if (currentpage == 'explore')
          ExplorePage(),
          if (currentpage == 'Feed')
            FeedPage(),
          if(currentpage=='CommunityPage')
            // Communities(),
            CommunityPage(),
            //CommunityPostPage(communityPostFuture: communityPostFuture),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: responsive.h(20)),
              child: navBar(),
            ),
          ),
        ],
      ),
    );
  }
  List<String> daysList=HostelMess.dayToName.values.map((d) => d.substring(0, 1)).toList();
  List<String> daysKeys=HostelMess.dayToName.values.map((d) => d.substring(0 )).toList();
  void _openFilterBottomSheet(List<Hostel> hostels){
    final responsive = Responsive(context);
    String tempSelectedDay=_selectedDay;
    String tempSelectedHostel=_selectedHostel;
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context){
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.6632,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16)
                  )
                ),
                // height: MediaQuery.of(context).size.height * responsive.h(0.6632),
                // height: responsive.h(0.6632),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: responsive.w(16),vertical: responsive.h(24)),
                      child: Text(
                        "Mess Menu for...",
                        style: TextStyle(
                          fontSize: responsive.sp(20),
                          fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                    Container(
                      width: responsive.w(412),
                      height: responsive.h(52),
                      child: Row(
                        children: [
                          Container(
                            width: responsive.w(129),
                            height: responsive.h(52),
                            color: myConstants.instiappGrey,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(responsive.w(16), responsive.h(16), responsive.w(84), responsive.h(15)),
                                  child: Text(
                                    "Day",
                                    style: TextStyle(
                                      fontSize: responsive.sp(16),
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: responsive.w(0),
                                  right: responsive.w(124),
                                  child: Container(
                                    width: responsive.w(4),
                                    height: responsive.h(52),
                                    decoration: BoxDecoration(
                                      color: myConstants.instiappBlue,
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(5)
                                      )
                                    ),
                                  )
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: responsive.w(282),
                            height: responsive.h(52),
                            color: myConstants.instiappGrey,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(responsive.w(11), responsive.h(12), responsive.w(5), responsive.h(10)),
                              child: Row(
                                children: [
                                  for(int i=0;i<daysList.length;i++) ...[
                                    dayContainer(
                                      daysList[i],
                                      tempSelectedDay == daysKeys[i],
                                      (){
                                        setModalState((){
                                          tempSelectedDay=daysKeys[i];
                                        });
                                      }
                                      ),
                                    SizedBox(width: responsive.w(8),)
                                  ]
                                    
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: responsive.h(8),),
                    Container(
                      width: responsive.w(412),
                      height: responsive.h(348),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: responsive.w(125),
                                height: responsive.h(52),
                                color: myConstants.instiappGrey,
                                child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(responsive.w(16), responsive.h(16), responsive.w(51), responsive.h(15)),
                                  child: Text(
                                    "Hostel",
                                    style: TextStyle(
                                      fontSize: responsive.sp(16),
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: responsive.w(0),
                                  right: responsive.w(120),
                                  child: Container(
                                    width: responsive.w(4),
                                    height: responsive.h(52),
                                    decoration: BoxDecoration(
                                      color: myConstants.instiappBlue,
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(5)
                                      )
                                    ),
                                  )
                                )
                              ],
                            ),
                              ),
                              Container(
                                width: responsive.w(125),
                                height: responsive.h(296),
                                
                                decoration: BoxDecoration(
                                  color: Color(0xFFF6F6F6),
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(16)
                                  )
                                ),
                                //child: Text("data"),
                              )
                            ],
                          ),
                          Container(
                            width: responsive.w(286),
                            height: responsive.h(348),
                            padding: EdgeInsets.only(top: responsive.h(16),left: responsive.w(20)),
                            color: myConstants.instiappGrey,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...hostels.map((h){
                                    final value = h.shortName!;
                                    final name=(value =='tansa'||value =='qip')
                                    ? value
                                    : 'Hostel ${value}';
                                    final isSelected = tempSelectedHostel == h.shortName;
                                    // return RadioListTile(
                                    //   value: value, 
                                    //   groupValue: _selectedHostel, 
                                    //   onChanged: (newValue){
                                    //     setModalState((){
                                    //       _selectedHostel=newValue as String;
                                    //     });
                                    //   },
                                    //   title: Text(
                                    //     name,
                                    //     style: TextStyle(
                                    //       fontWeight: FontWeight.w500
                                    //     ),
                                    //   ),
                                    //   activeColor: myConstants.instiappBlue,
                                    //   contentPadding: EdgeInsets.zero,
                                    //   dense: true,
                                    //   visualDensity: VisualDensity(vertical: -3),
                                    //   );
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            setModalState((){
                                               tempSelectedHostel = h.shortName!;
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                width: responsive.w(16),
                                                height: responsive.h(16),
                                                
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Color(0xFFD2D5DA),
                                                    width: responsive.w(1.5)
                                                  )
                                                ),
                                                child: isSelected
                                                ? Center(
                                                  child: Container(
                                                    height: responsive.h(14),
                                                    width: responsive.w(14),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: isSelected ? myConstants.instiappBlue: Colors.transparent,
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        height: responsive.h(6),
                                                        width: responsive.w(6),
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: isSelected ? Colors.white: Colors.transparent,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                : null
                                              ),
                                              SizedBox(width: responsive.w(12),),
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        SizedBox(height: responsive.h(16),)
                                      ],
                                    );
                                  }).toList()
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: responsive.h(27)),
                    Container(
                      padding: EdgeInsets.only(right: responsive.w(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                              setState(() {
                                _selectedDay=tempSelectedDay;
                                _selectedHostel=tempSelectedHostel;
                              });
                            },
                            child: Container(
                              height: responsive.h(60),
                              width: responsive.w(165),
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                    image: AssetImage(
                                      "assets/buynsell/filterbutton.png"),
                                      fit: BoxFit.cover,
                                ),
                                color: myConstants.instiappDark,
                                borderRadius: BorderRadius.circular(50)
                              ),
                              child: Center(
                                child: Text(
                                  "Apply",
                                  style: TextStyle(
                                    fontSize: responsive.sp(18),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        );
      }
      );
  }
  Widget dayContainer(String day,bool isSelected, VoidCallback onTap){
    final responsive = Responsive(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: responsive.h(30),
        width: responsive.w(30),
        padding: EdgeInsets.symmetric(vertical: responsive.h(3),horizontal: responsive.w(7)),
        decoration: BoxDecoration(
          color: isSelected? myConstants.instiappBlue:Colors.white,
          borderRadius: BorderRadius.circular(8)
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: responsive.w(18),
              fontWeight: FontWeight.w600,
              color: isSelected? Colors.white:Colors.black
            ),
          ),
        ),
      ),
    );
  }
  Widget services(String name, String path, Map<String,dynamic> services_icon) {
    final responsive = Responsive(context);
    return InkWell(
      onTap: () {
        if (name == "Buy & Sell") {
          Navigator.of(context).pushNamed('/buynsell');
        } else if (name == "Lost & Found") {
          Navigator.of(context).pushNamed('/settings');
        } else if (name == "Blogs") {
          Navigator.of(context).pushNamed('/placeblog');
        } else if (name == "Quick Links") {
          Navigator.of(context).pushNamed('/quicklinks');
        }
      },
      child: Container(
        height: responsive.h(94),
        width: responsive.w(180),
        decoration: BoxDecoration(
            color: myConstants.instiappGrey,
            borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Positioned(
                left: responsive.w(12),
                top: responsive.h(12),
                //right: 72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      services_icon["Title"],
                      style: TextStyle(
                        color: const Color(0xFF0F1620),
                        fontSize: responsive.sp(16),
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      services_icon["Subtitle"],
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: responsive.sp(11),
                        fontWeight: FontWeight.w500
                      ),
                    )
                  ],
                )),
            services_icon["Title"]=="Buy & Sell"? Positioned(
              bottom: responsive.h(12),
              left: responsive.w(12),
              child: Container(
                width: responsive.w(37), 
                height: responsive.h(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: myConstants.instiappBlue
                ),
                child: Center(
                  child: Text(
                    "New!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.sp(10),
                    ),
                  ),
                ),
              )
            )
            : SizedBox(),
            Positioned(
              right: services_icon["Positions"][2],
              left:services_icon["Positions"][0],
              bottom: services_icon["Positions"][3],
              top: services_icon["Positions"][1],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: services_icon["Title"]=="Quick Links"? Image.asset(services_icon["Path"]):SvgPicture.asset(
                    services_icon["Path"],
                    
                  ),
              )
              ),
            // Positioned(
            //     left: 95,
            //     top: 12,
            //     right: 0,
            //     bottom: 0,
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(12),
            //       child: SvgPicture.asset(
            //         'assets/homepage/icons/star.svg',
            //       ),
            //     )),
            // Positioned(
            //     left: 122,
            //     top: 31,
            //     right: 0,
            //     bottom: 0,
            //     child: SvgPicture.asset('assets/homepage/icons/${path}.svg'))
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget customAppBar() {
    final responsive = Responsive(context);
    final bloc = BlocProvider.of(context)!.bloc;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: myConstants.instiappWhite,
      elevation: 0,
      flexibleSpace: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder<Session?>(
              stream: bloc.session,
              builder: (context, snapshot) {
                final isLoggedIn = snapshot.hasData && snapshot.data?.profile != null;
                final user = snapshot.data?.profile;
                
                Widget avatarContent;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  avatarContent = Center(child: CircularProgressIndicator(strokeWidth: 2));
                } else if (snapshot.hasError) {
                  avatarContent = Icon(Icons.error_outline, size: 28, color: Colors.red);
                } else if (isLoggedIn) {
                  avatarContent = ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      user!.userProfilePictureUrl ?? '',
                      width: responsive.w(44),
                      height: responsive.h(44),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: responsive.sp(28),
                        color: Colors.grey,
                      ),
                    ),
                  );
                } else {
                  avatarContent = Icon(
                    Icons.person_outline,
                    size: responsive.sp(28),
                    color: Colors.red,
                  );
                }
                
                return InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    if (isLoggedIn) {
                      UserPage.navigateWith(context, bloc, user);
                    } else {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  child: Container(
                    width: responsive.w(52),
                    height: responsive.h(52),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: avatarContent,
                  ),
                );
              },
            ),
            Container(
              width: responsive.w(52),
              height: responsive.h(52),
              child: Stack(
                children: [
                  Container(
                    height: responsive.h(52),
                    width: responsive.w(52),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/homepage/images/instiappnew.png'),
                            fit: BoxFit.cover)),
                  )
                ],
              ),
            ),
            Container(
              width: responsive.w(52),
              height: responsive.h(52),
              child: Stack(
                children: [
                  Container(
                    height: responsive.h(52),
                    width: responsive.w(52),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: myConstants.instiappGrey),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      NotificationsPage()));
                            },
                            child: Center(
                              child: Container(
                                width: responsive.w(24),
                                height: responsive.h(24),
                                child: SvgPicture.asset(
                                  'assets/homepage/icons/bell.svg',
                                ),
                              ),
                            ),
                          )
                        ],
                      ))
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget Homepagewidget() {
    final responsive = Responsive(context);
    var bloc = BlocProvider.of(context)!.bloc;
    return Scaffold(
      backgroundColor: myConstants.instiappWhite,
      
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52),
        child: customAppBar()
        ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: responsive.h(100)),
            //margin: EdgeInsets.only(left: 10,right: 0),
            child: Column(
              children: [
                SizedBox(height: responsive.h(20)),
                Dash(
                  direction: Axis.horizontal,
                  length: responsive.w(368),
                  dashLength: 6,
                  dashGap: 7,
                  dashColor: Color(0xFFDADADA),
                ),
                SizedBox(height: responsive.h(20)),
                Stack(
                  children: [
                    StreamBuilder<UnmodifiableListView<Hostel>>(
                    stream: bloc.hostels,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                    final hostels = snapshot.data!;
                    return Padding(
                      padding: EdgeInsets.only(left: responsive.w(21),right: responsive.w(22)),
                      child: qrClosed(hostels),
                    );
                    },
                    ),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: Offset(0, 0.01), // Slide in from below (20% of height)
                          end: Offset.zero,
                        ).animate(animation);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                      child: showQR
                      ? Padding(
                        key: ValueKey('qrOpen'),
                        padding: EdgeInsets.only(left: responsive.w(14),right: responsive.w(13)),
                        child: qrOpen(
                          loading: loading,
                          error: error,
                          qrString: qrString
                        ),
                      )
                      : SizedBox.shrink(key: ValueKey('empty'))
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: responsive.w(21),right: responsive.w(22)),
                  child: servicesWidget(),
                ),
              ], 
            ),
          ),
        ],
      ),
    );
  }

  Widget servicesWidget() {
    final responsive = Responsive(context);
    return Column(
      children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Services',
                        style: TextStyle(
                          fontSize: responsive.sp(20),
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w700
                        ),
                        ),
                    ],
                ),
                SizedBox(height: responsive.h(16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    services("Buy & Sell","bns_new",
                    {
                      "Title": "Buy & Sell",
                      "Path": 'assets/homepage/icons/bns_new.svg',
                      "Subtitle": "Deals made easy",
                      // "Icon Height": 75.67,
                      // "Icon Width": 90.8,
                      "Positions": [97.0,14.5,-11.0,-7.8,-7.81]
                    }
                    ),
                    SizedBox(width: responsive.w(8)),
                    services("Maps","maps_new",
                    {
                      "Title": "Maps",
                      "Path": 'assets/homepage/icons/maps_new.svg',
                      "Subtitle": "Navigate Insti",
                      // "Icon Height": 72.0,
                      // "Icon Width": 76.0,
                      "Positions": [111.0,28.0,-1.0,-6.0,0.0]
                    }
                    )
                  ],
                ),
                SizedBox(height: responsive.h(8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    services("Blogs","blogs_new",
                    {
                      "Title": "Blogs",
                      "Path": 'assets/homepage/icons/blogs_new.svg',
                      "Subtitle": "",
                      // "Icon Height": 77.54,
                      // "Icon Width": 72.0,
                      "Positions": [107.46,23.0,-1.0,-1.0,0.0]
                    }
                    ),
                    SizedBox(width: responsive.w(8)),
                    services("Quick Links","blogs_new",
                    {
                      "Title": "Quick Links",
                      "Path": 'assets/homepage/images/quicklinks_new.png',
                      "Subtitle": "Useful Insti Links",
                      // "Icon Height": 77.7,
                      // "Icon Width": 80.18,
                      "Positions": [107.72,16.52,-6.0,-6.5,4.71]
                    }
                    )
                  ],
                ),
      ],
    );
  }

  Widget navBar() {
    final responsive = Responsive(context);
    return Container(
      height: responsive.h(80),
      width: responsive.w(396),
      decoration: BoxDecoration(
          color: myConstants.instiappDark,
          borderRadius: BorderRadius.circular(50)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: navIcons.entries.map((entry) {
          String label = entry.key;
          String path = entry.value;
          selectedIcon = path == selectedNavIcon;
          return SizedBox(
            width: responsive.w(87),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // if (selectedIcon)
                  
                //   SvgPicture.asset(
                //     'assets/homepage/icons/icon1.svg',
                //     width: 69,
                //     height: 10,
                //     colorFilter:
                //         ColorFilter.mode(Colors.white, BlendMode.srcIn),
                //   )
                // else
                //   SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedNavIcon = path;
                    });
                    if (path == 'assets/homepage/icons/search.svg') {
                        currentpage = 'explore';
                        
                    } else if (path ==
                        'assets/homepage/icons/message-square.svg') {
                        currentpage = 'CommunityPage';
                        
                    // } else if (path == 'assets/homepage/icons/map.svg') {
                    //     currentpage = 'Map';  
                    } else if (path == 'assets/homepage/icons/loader.svg') {
                        currentpage = 'Feed';
                        
                    } else if (path == 'assets/homepage/icons/home.svg') {
                        currentpage = 'homepage';
                        
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        width: responsive.w(63),
                        height: responsive.h(33),
                        decoration: BoxDecoration(
                          color: selectedIcon ? myConstants.instiappBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(79.67)
                        ),
                        child: Center(
                          child: Container(
                            width: responsive.w(24),
                            height: responsive.w(24),
                            child: SvgPicture.asset(
                              path,
                              colorFilter: ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.h(2)),
                      Text(
                        label,
                        style: TextStyle(
                          color: selectedIcon ? myConstants.instiappBlue : Colors.white,
                        ),
                      )
                    ],
                  ),
                  
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget qrOpen({
    required bool loading,
    required bool error,
    required String qrString,
  }) {
    final responsive = Responsive(context);
    return Stack(
      children: [
        Center(
          child: SvgPicture.asset(
            'assets/homepage/icons/bigborder.svg',
            height: responsive.h(380),
            width: responsive.w(382),
            fit: BoxFit.fill
            ),
        ),
        Container(
        width: responsive.w(380),
        height: responsive.h(380),
        child: Padding(
          padding: EdgeInsets.fromLTRB(responsive.w(16), responsive.h(16), responsive.w(16), responsive.h(0)),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,            
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      print("clicked");
                      generateQR();
                    },
                    child: Container(
                      width: responsive.w(50),
                      height: responsive.h(50),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEBEB),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: responsive.w(24),
                          height: responsive.h(24),
                          child: SvgPicture.asset(
                              'assets/homepage/icons/refresh.svg'),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'My QR',
                    style: TextStyle(
                      color: myConstants.instiappBlue,
                      fontSize: responsive.sp(20),
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showQR = false;
                      });
                    },
                    child: Container(
                      width: responsive.w(50),
                      height: responsive.h(50),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEBEB),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: responsive.w(29),
                          height: responsive.h(29),
                          child: SvgPicture.asset(
                              'assets/homepage/icons/arrow_down.svg'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: responsive.h(26), bottom: responsive.h(28)),
                  child: SizedBox(
                    width: responsive.w(197),
                    height: responsive.h(197),
                    child: loading
                      ? CircularProgressIndicator()
                      :error
                        ?Center(child: Text("Please log in to view QR"))
                        : QrImageView(
                          data: '${qrString}',
                          size: responsive.sp(197),
                          embeddedImage: AssetImage('assets/buynsell/DevcomLogo.png'),
                          ),
                  ),
                ),
              ),
              Center(
                child: loading
                ? CircularProgressIndicator()
                : error
                ? SizedBox()
                : Text(
                  'Mess • Gym • Swimming & more...',
                  style: TextStyle(
                    color: const Color(0xFF15202D),
                    fontSize: responsive.sp(14),
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
      ],
    );
  }

  Widget qrClosed(List<Hostel> hostels) {
  final responsive = Responsive(context);
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mess Menu',
            style: TextStyle(
              color: const Color(0xFF15202D),
              fontSize: responsive.sp(20),
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: (){
              _openFilterBottomSheet(hostels);
            },
            child: Container(
              width: responsive.w(94),
              height: responsive.h(40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: myConstants.instiappGrey,
                border: Border.all(
                  color: Color(0xFF7E8287),
                  width: responsive.w(1)
                )
              ),
              padding: EdgeInsets.fromLTRB(responsive.w(16), responsive.h(11), responsive.w(4), responsive.h(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${_selectedDay.substring(0,3)}, H-${_selectedHostel}",
                    style: TextStyle(
                      color: Color(0xCC0F1620),
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  // SizedBox(width: 8),
                  // Container(
                  //   height: 20,
                  //   width: 20,
                  //   child: Icon(Icons.keyboard_arrow_down),
                  // )
                ],
              ),
            ),
          )
          // Row(
          //   children: [
          //     Container(
          //       height: 40,
          //       width: 78.5,
          //       decoration: BoxDecoration(
          //         color: myConstants.instiappGrey,
          //         borderRadius: BorderRadius.circular(20),
          //       ),
          //       child: Center(
          //         child: DropdownButton(
          //           items: HostelMess.dayToName.values
          //                   .map((d) => DropdownMenuItem(value: d.substring(0,3), child: Text(d.substring(0,3))))
          //                   .toList(),
          //           onChanged: (String? newDay) {
          //             setState(() {
          //               _dropdownDay = newDay!;
          //             });
          //           },
          //           value: _dropdownDay,
          //           icon: Icon(Icons.keyboard_arrow_down),
          //           style: TextStyle(
          //             color: Colors.grey[800],
          //             fontWeight: FontWeight.w400,
          //           ),
          //           underline: SizedBox(),
          //         ),
          //       ),
          //     ),
          //     SizedBox(width: 8),
          //     Container(
          //       height: 40,
          //       width: 78.5,
          //       decoration: BoxDecoration(
          //         color: myConstants.instiappGrey,
          //         borderRadius: BorderRadius.circular(20),
          //       ),
          //       padding: EdgeInsets.only(left: 10),
          //       child: DropdownButton(
          //         items: hostels.map((h){
          //           final name=(h.shortName! =='tansa'||h.shortName! =='qip')
          //           ? h.shortName!
          //           : 'H-${h.shortName!}';
          //           return DropdownMenuItem(
          //             value: h.shortName!,
          //             child: Text(name)
          //             );
          //         }).toList(),
          //         onChanged: (String? newValue) {
          //           setState(() {
          //             _dropdownHostel = newValue!;
          //           });
          //         },
          //         value: _dropdownHostel,
          //         icon: Padding(
          //           padding: const EdgeInsets.only(left: 7),
          //           child: Icon(Icons.keyboard_arrow_down),
          //         ),
          //         style: TextStyle(
          //           color: Colors.grey[800],
          //           fontWeight: FontWeight.w400,
          //         ),
          //         underline: SizedBox(),
                  
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
      SizedBox(height: responsive.h(20)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: responsive.w(110),
            height: responsive.h(184),
            child: Column(
              children: [
                for (int i = 0; i < meals.length; i++) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMeal = i;
                      });
                    },
                    child: Container(
                      height: responsive.h(40),
                      width: responsive.w(120),
                      decoration: BoxDecoration(
                        color: selectedMeal == i
                            ? myConstants.instiappBlue
                            : myConstants.instiappGrey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          meals[i],
                          style: TextStyle(
                            color: selectedMeal == i
                                ? Colors.white
                                : Color(0xCC0F1620),
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: responsive.sp(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (i != meals.length - 1) SizedBox(height: responsive.h(8)),
                ],
              ],
            ),
          ),
          SizedBox(width: responsive.w(8)),
          SizedBox(
            width: responsive.w(250),
            height: responsive.h(184),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: myConstants.instiappBlue,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    width: responsive.w(242),
                    height: responsive.h(129),
                    decoration: BoxDecoration(
                      color: myConstants.instiappWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _mealString(hostels),
                        style: TextStyle(
                          color: const Color(0xFF1B3252),
                          fontSize: responsive.sp(14),
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                          height: responsive.h(1.31),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: responsive.h(8), horizontal: responsive.w(18)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          mealTime[selectedMeal],
                          style: TextStyle(
                            color: myConstants.instiappWhite,
                            fontSize: responsive.sp(14),
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          width: responsive.w(40),
                          height: responsive.h(30),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: responsive.w(1), color: Colors.white),
                              borderRadius: BorderRadius.circular(80),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: responsive.h(20)),
      Dash(
        direction: Axis.horizontal,
        length: responsive.w(368),
        dashLength: 6,
        dashGap: 7,
        dashColor: Color(0xFFDADADA),
      ),
      SizedBox(height: responsive.h(20)),
      GestureDetector(
        onTap: () {
          setState(() {
            showQR = true;
          });
        },
        child: Container(
          height: responsive.h(96),
          width: responsive.w(380),
          child: Stack(
            children: [
              SvgPicture.asset(
                'assets/homepage/icons/border.svg',
                width: responsive.w(368),
                fit: BoxFit.fill,
                ),
              Container(
              height: responsive.h(96),
              width: responsive.w(368),
              padding: EdgeInsets.fromLTRB(responsive.w(16), responsive.h(8), responsive.w(16), responsive.h(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'My QR',
                        style: TextStyle(
                          color: Color(0xFF275489),
                          fontSize: responsive.sp(20),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Mess • Gym • Swimming & more...',
                        style: TextStyle(
                          color: const Color(0xFF15202D),
                          fontSize: responsive.sp(14),
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: responsive.h(75),
                    width: responsive.w(75),
                    child: SvgPicture.asset('assets/homepage/icons/qr.svg'),
                  ),
                ],
              ),
            )
            ],
          ),
        ),
      ),
      SizedBox(height: responsive.h(20)),
      Dash(
        direction: Axis.horizontal,
        length: responsive.w(368),
        dashLength: 6,
        dashGap: 7,
        dashColor: Color(0xFFDADADA),
      ),
      SizedBox(height: responsive.h(20)),
    ],
  );
} 
}

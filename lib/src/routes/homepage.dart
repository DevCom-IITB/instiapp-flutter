import 'dart:collection';

import 'package:InstiApp/constants.dart';
import 'package:InstiApp/src/routes/explorepage.dart';
import 'package:InstiApp/src/api/model/mess.dart';
import 'package:InstiApp/src/bloc_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dash/flutter_dash.dart';
import "notificationspage.dart";
import 'feedpage.dart';

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
    'assets/homepage/icons/map.svg'
  ];
  List<String> days = ['Mon', 'Tue'];
  List<String> hostel = ['H-1', 'H-2'];
  List<String> meals = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];
  Map<String, Map<String, Map<String, List<String>>>> messMenu = {
    "H-1": {
      "Mon": {
        "Breakfast": ["H-1 Mon Breakfast"],
        "Lunch": ["H-1 Mon Lunch"],
        "Snacks": ["H-1 Mon Snacks"],
        "Dinner": ["H-1 Mon Dinner"]
      },
      "Tue": {
        "Breakfast": ["H-1 Tue Breakfast"],
        "Lunch": ["H-1 Tue Lunch"],
        "Snacks": ["H-1 Tue Snacks"],
        "Dinner": ["H-1 Tue Dinner"]
      }
    },
    "H-2": {
      "Mon": {
        "Breakfast": ["H-2 Mon Breakfast"],
        "Lunch": ["H-2 Mon Lunch"],
        "Snacks": ["H-2 Mon Snacks"],
        "Dinner": ["H-2 Mon Dinner"]
      },
      "Tue": {
        "Breakfast": ["H-2 Tue Breakfast"],
        "Lunch": ["H-2 Tue Lunch"],
        "Snacks": ["H-2 Tue Snacks"],
        "Dinner": ["H-2 Tue Dinner"]
      }
    }
  };
  List<String> currentMealItems() {
    return messMenu[_dropdownHostel]?[_dropdownDay]?[meals[selectedMeal]] ?? [];
  }
  String _dropdownHostel='1';
  int selectedMeal=0;
  String _dropdownDay='Mon';
  bool showQR=false;
  String selectedNavIcon='assets//homepage/icons/home.svg';
  bool selectedIcon=false;
  bool firstBuild = true;
  String _formatMeal(String? meal) {
  return (meal ?? '')
      .split(RegExp(r'[\n,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .join(' • ');
}
  String _mealString(List<Hostel> hostels) {
      if (_dropdownHostel.isEmpty) return 'No menu';
      // 1. pick hostel
      final hostel = hostels
          .firstWhere((h) => h.shortName == _dropdownHostel, orElse: () => Hostel());
      // 2. pick day (Mon=1 … Sun=7)
      final dayIndex = HostelMess.dayToName.entries
          .firstWhere((e) => e.value.startsWith(_dropdownDay), orElse: () => const MapEntry(1,'Monday'))
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

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of(context)!.bloc;
    if (firstBuild) {
      bloc.updateHostels();
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
          Align(
            alignment: Alignment.bottomCenter,
            child: navBar(),
          ),
        ],
      ),
    );
  }

  Widget services(String name, String path) {
    return InkWell(
      onTap: () {
        if (name == "Buy & Sell") {
        } else if (name == "Lost & Found") {
          Navigator.of(context).pushNamed('/settings');
        } else if (name == "Blogs") {
          Navigator.of(context).pushNamed('/placeblog');
        } else if (name == "Quick Links") {}
      },
      child: Container(
        height: 94,
        width: 180,
        decoration: BoxDecoration(
            color: myConstants.instiappGrey,
            borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Positioned(
                left: 17,
                top: 14,
                right: 72,
                child: Text(
                  name,
                  style: TextStyle(
                    color: const Color(0xFF0F1620),
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                  ),
                )),
            Positioned(
                left: 95,
                top: 12,
                right: 0,
                bottom: 0,
                child: SvgPicture.asset(
                  'assets/homepage/icons/star.svg',
                )),
            Positioned(
                left: 122,
                top: 31,
                right: 0,
                bottom: 0,
                child: SvgPicture.asset('assets/homepage/icons/${path}.svg'))
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget customAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: myConstants.instiappWhite,
      elevation: 0,
      flexibleSpace: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              child: Stack(
                children: [
                  Positioned(
                      left: 4,
                      right: 4,
                      top: 4,
                      bottom: 4,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: Colors.white,
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/homepage/images/profilenew.jpg'),
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter)),
                      ))
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              child: Stack(
                children: [
                  Positioned(
                      left: 4,
                      right: 4,
                      top: 4,
                      bottom: 4,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/homepage/images/instiappnew.png'),
                                fit: BoxFit.cover)),
                      ))
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              child: Stack(
                children: [
                  Positioned(
                      left: 4,
                      right: 4,
                      top: 4,
                      bottom: 4,
                      child: Container(
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
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(
                                      'assets/homepage/icons/bell.svg',
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )))
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget Homepagewidget() {
    var bloc = BlocProvider.of(context)!.bloc;
    if (firstBuild) {
      bloc.updateHostels();
      firstBuild = false;
    }
    return Scaffold(
      backgroundColor: myConstants.instiappWhite,
      appBar: customAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            //margin: EdgeInsets.only(left: 10,right: 0),
            child: Padding(
              padding: const EdgeInsets.only(left: 21,right: 22),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Dash(
                    direction: Axis.horizontal,
                    length: 368,
                    dashLength: 6,
                    dashGap: 7,
                    dashColor: Color(0xFFDADADA),
                  ),
                  SizedBox(height: 20),
                  if(showQR)
                    qrOpen()
                  else
                    StreamBuilder<UnmodifiableListView<Hostel>>(
                      stream: bloc.hostels,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
              
                      final hostels = snapshot.data!;
                      print("Available hostels: ${hostels.map((h) => h.shortName).toList()}");
                      print("Selected: $_dropdownHostel");
                      return qrClosed(hostels);
                      },
                    ),
                  servicesWidget(),
                ], 
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget servicesWidget() {
    return Column(
      children: [
        SizedBox(height: 20),
        Dash(
          direction: Axis.horizontal,
          length: 368,
          dashLength: 6,
          dashGap: 7,
          dashColor: Color(0xFFDADADA),
        ),
        SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w700
                        ),
                        ),
                    ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    services("Buy & Sell","buy_and_sell"),
                    SizedBox(width: 8),
                    services("Lost & Found","lost_and_found")
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    services("Blogs","blogs"),
                    SizedBox(width: 8),
                    services("Quick Links","quick_links")
                  ],
                ),
      ],
    );
  }

  Widget navBar() {
    return Container(
      height: 80,
      width: 396,
      decoration: BoxDecoration(
          color: myConstants.instiappDark,
          borderRadius: BorderRadius.circular(50)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: navIconPaths.map((path) {
          selectedIcon = path == selectedNavIcon;
          return SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (selectedIcon)
                  SvgPicture.asset(
                    'assets/homepage/icons/icon1.svg',
                    width: 69,
                    height: 10,
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  )
                else
                  SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedNavIcon = path;
                    });
                    if (path == 'assets/homepage/icons/search.svg') {
                        currentpage = 'explore';
                    } else if (path ==
                        'assets/homepage/icons/message-square.svg') {
                        currentpage = 'Community';
                    } else if (path == 'assets/homepage/icons/map.svg') {
                        currentpage = 'Map';
                    } else if (path == 'assets/homepage/icons/loader.svg') {
                        currentpage = 'Feed';
                    } else if (path == 'assets/homepage/icons/home.svg') {
                        currentpage = 'homepage';
                    }
                  },
                  icon: SvgPicture.asset(
                    path,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                        selectedIcon ? myConstants.instiappBlue : Colors.white,
                        BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget qrOpen() {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: myConstants.instiappBlue,
          width: 6,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Container(
        width: 380,
        height: 380,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEBEB),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                            'assets/homepage/icons/refresh.svg'),
                      ),
                    ),
                  ),
                  Text(
                    'My QR',
                    style: TextStyle(
                      color: myConstants.instiappBlue,
                      fontSize: 20,
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
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBEBEB),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 29,
                          height: 29,
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
                  padding: const EdgeInsets.only(top: 26, bottom: 32),
                  child: SizedBox(
                    width: 197,
                    height: 197,
                    child: SvgPicture.asset('assets/homepage/icons/bigqr.svg'),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Mess • Gym • Swimming & more...',
                  style: TextStyle(
                    color: const Color(0xFF15202D),
                    fontSize: 14,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget qrClosed(List<Hostel> hostels) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          
          children: [
            Text(
              'Mess Menu',
              style: TextStyle(
                color: const Color(0xFF15202D),
                fontSize: 20,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                Container(
                  height: 40,
                  width: 78.5,
                  decoration: BoxDecoration(
                    color: myConstants.instiappGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: DropdownButton(
                      items: HostelMess.dayToName.values
                              .map((d) => DropdownMenuItem(value: d.substring(0,3), child: Text(d.substring(0,3))))
                              .toList(),
                      onChanged: (String? newDay) {
                        setState(() {
                          _dropdownDay = newDay!;
                        });
                      },
                      value: _dropdownDay,
                      icon: Icon(Icons.keyboard_arrow_down),
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w400,
                      ),
                      underline: SizedBox(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  height: 40,
                  width: 78.5,
                  decoration: BoxDecoration(
                    color: myConstants.instiappGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.only(left: 10),
                  child: DropdownButton(
                    items: hostels.map((h){
                      final name=(h.shortName! =='tansa'||h.shortName! =='qip')
                      ? h.shortName!
                      : 'H-${h.shortName!}';
                      return DropdownMenuItem(
                        value: h.shortName!,
                        child: Text(name)
                        );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _dropdownHostel = newValue!;
                      });
                    },
                    value: _dropdownHostel,
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 7),
                      child: Icon(Icons.keyboard_arrow_down),
                    ),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w400,
                    ),
                    underline: SizedBox(),
                    
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            height: 184,
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
                      height: 40,
                      width: 120,
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
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (i != meals.length - 1) SizedBox(height: 8),
                ],
              ],
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 250,
            height: 184,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: myConstants.instiappDark,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    width: 242,
                    height: 129,
                    decoration: BoxDecoration(
                      color: myConstants.instiappWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _mealString(hostels),
                        style: TextStyle(
                          color: const Color(0xFF1B3252),
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                          height: 1.31,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "12:30 PM - 2:30 PM",
                          style: TextStyle(
                            color: myConstants.instiappWhite,
                            fontSize: 14,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 30,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1, color: Colors.white),
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
      SizedBox(height: 20),
      GestureDetector(
        onTap: () {
          setState(() {
            showQR = true;
          });
        },
        child: Material(
          color: Color(0xFFF1F5F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: myConstants.instiappBlue,
              width: 6,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Container(
            height: 96,
            width: 368,
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Mess • Gym • Swimming & more...',
                      style: TextStyle(
                        color: const Color(0xFF15202D),
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 75,
                  width: 75,
                  child: SvgPicture.asset('assets/homepage/icons/qr.svg'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
} 
}

import 'package:InstiApp/constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dash/flutter_dash.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Constants myConstants=Constants();
  List<IconData> navIcons=[Icons.home,Icons.circle,Icons.search,Icons.message,Icons.map];
  List<String> navIconPaths=['assets/icons/home.svg','assets/icons/loader.svg','assets/icons/search.svg','assets/icons/message-square.svg','assets/icons/map.svg'];
  List<String> days=['Mon','Tue'];
  List<String> hostel=['H-1','H-2'];
  List<String> meals=['Breakfast','Lunch','Snacks','Dinner'];
  Map<String, Map<String, Map<String, List<String>>>> messMenu={
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
  List<String> currentMealItems(){
    return messMenu[_dropdownHostel]?[_dropdownDay]?[meals[selectedMeal]]??[];
  }
  String _dropdownHostel='H-2';
  int selectedMeal=0;
  String _dropdownDay='Mon';
  bool showQR=false;
  String selectedNavIcon='assets/icons/home.svg';
  bool selectedIcon=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:myConstants.instiappWhite,
      appBar: customAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            //margin: EdgeInsets.only(left: 10,right: 0),
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
                  qrClosed(),
                servicesWidget(),
              ], 
            ),
          ),
          Align(alignment: Alignment.bottomCenter,child: navBar(),)
        ],
      ),
    );
  }
  Widget services(String name,String path){
    return Container(
        height: 94,
        width: 180,
        decoration: BoxDecoration(
          color: myConstants.instiappGrey,
            borderRadius: BorderRadius.circular(12)
        ),
        child: Stack(
          children: [
              Positioned(
                left: 17,
                top: 14,
                right: 72,
                child:Text(
                  name,
                  style: TextStyle(
                    color: const Color(0xFF0F1620),
                    fontSize: 16,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                  ),
                  )
                ),
              Positioned(
                left: 95,
                top: 12,
                right: 0,
                bottom: 0,
                child: SvgPicture.asset(
                  'assets/icons/star.svg',
                )
              ),
              Positioned(
                left: 122,
                top: 31,
                right: 0,
                bottom: 0,
                child: SvgPicture.asset(
                  'assets/icons/${path}.svg'
                )
              )
            ],
          ),
        );
  }
  PreferredSizeWidget customAppBar(){
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: myConstants.instiappWhite,
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 0),
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
                              image: AssetImage('assets/images/profilenew.jpg'),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter
                            )
                          ),
                          
                        )
                        )
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
                              image: AssetImage('assets/images/instiappnew.png'),
                              fit: BoxFit.cover
                            )
                          ),
                          
                        )
                        )
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
                            color: myConstants.instiappGrey
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  child: SvgPicture.asset(
                                    'assets/icons/bell.svg'
                                  ),
                                ),
                              )
                            ],
                          )
                        )
                        )
                    ],
                  ),
                ),
              ],
            ),
            )
          ),
    );
  }
  Widget servicesWidget(){
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
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
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
  Widget navBar(){
    return Container(
      height: 80,
      width: 396,
      decoration: BoxDecoration(
        color: myConstants.instiappDark,
        borderRadius: BorderRadius.circular(50)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: navIconPaths.map((path){
          selectedIcon=path==selectedNavIcon;
          return SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if(selectedIcon)
                  SvgPicture.asset(
                    'assets/icons/icon1.svg',
                    width: 69,
                    height: 10,
                    colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  )
                else 
                  SizedBox(height: 10),
                IconButton(
                  onPressed: (){
                    setState(() {
                      selectedNavIcon=path;
                    });
                  }, 
                  icon: SvgPicture.asset(
                    path,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(selectedIcon?myConstants.instiappBlue:Colors.white, BlendMode.srcIn),
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
                        child: SvgPicture.asset('assets/icons/refresh.svg'),
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
                          child: SvgPicture.asset('assets/icons/arrow_down.svg'),
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
                    child: SvgPicture.asset('assets/icons/bigqr.svg'),
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

  Widget qrClosed() {
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
                      items: days.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(day),
                        );
                      }).toList(),
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
                  child: Center(
                    child: DropdownButton(
                      items: hostel.map((String hostel) {
                        return DropdownMenuItem(
                          value: hostel,
                          child: Text(hostel),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _dropdownHostel = newValue!;
                        });
                      },
                      value: _dropdownHostel,
                      icon: Icon(Icons.keyboard_arrow_down),
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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
            width: 120,
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
                    child: SizedBox(
                      width: 210,
                      height: 97,
                      child: Text(
                        currentMealItems().join(' • ').isEmpty
                            ? 'No menu found for the chosen slot'
                            : currentMealItems().join(' • '),
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
            width: 380,
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
                  child: SvgPicture.asset('assets/icons/qr.svg'),
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


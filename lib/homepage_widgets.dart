import 'package:InstiApp/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Constants myConstants=Constants();
List<String> navIconPaths=['assets/icons/home.svg','assets/icons/loader.svg','assets/icons/search.svg','assets/icons/message-square.svg','assets/icons/map.svg'];
String selectedNavIcon='assets/icons/home.svg';
bool selectedIcon=false;

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

  Widget servicesWidget(){
    return Column(
      children: [
        SizedBox(height: 40),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 26,
        children: navIconPaths.map((path){
          selectedIcon=path==selectedNavIcon;
          return IconButton(
            onPressed: (){
              
            }, 
            icon: SvgPicture.asset(
              path,
              colorFilter: ColorFilter.mode(selectedIcon?myConstants.instiappBlue:Colors.white, BlendMode.srcIn),
            ),
            );
        }).toList(),
      ),
    );
  }

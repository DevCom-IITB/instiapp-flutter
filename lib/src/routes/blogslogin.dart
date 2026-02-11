import 'package:InstiApp/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class BlogsLogin extends StatefulWidget {
  const BlogsLogin({super.key});

  @override
  State<BlogsLogin> createState() => _BlogsLoginState();
}

class _BlogsLoginState extends State<BlogsLogin> {
  Constants myConstants=Constants();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFF6F6F6),
          //backgroundColor: Colors.red[200],
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
                              color: myConstants.instiappGrey),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed('/feed');
                                },
                                child: Center(
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(
                                      'assets/quicklinks/icons/arrow_left.svg',
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )))
                ],
              ),
            ),
            Text(
              "Blogs",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700
              ),
            ),
            Container(
              width: 52,
              height: 52,
            ),
          ],
        ),
      )),
    ),
      ),
      body: Center(
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 182),
            Container(
              width: 300,
              height: 279.64,
              child: Stack(
                children: [
                  Positioned(
                    top: 4.17,
                    right: 107.32,
                    left: 56.16,
                    bottom: 142.7,
                    child: SvgPicture.asset('assets/blogslogin/icon1.svg')
                  ),
                  Positioned(
                    top: 29.15,
                    right: 0,
                    left: 192.11,
                    bottom: 26.02,
                    child: SvgPicture.asset('assets/blogslogin/icon2.svg')
                  ),
                  Positioned(
                    top: 222.56,
                    right: 107.68,
                    left: 56.23,
                    bottom: 11.54,
                    child: SvgPicture.asset(
                      'assets/blogslogin/icon3.svg',
                      width: 136.09,)
                  ),
                  Positioned(
                    top: 136.62,
                    right: 52.79,
                    left: 1.16,
                    bottom: 56.69,
                    child: SvgPicture.asset('assets/blogslogin/icon9.svg')
                  ),
                  Positioned(
                    top: 94.98,
                    right: 243.66,
                    left: 11.01,
                    bottom: 135.98,
                    child: SvgPicture.asset('assets/blogslogin/icon4.svg')
                  ),
                  Positioned(
                    top: 32.86,
                    right: 243.65,
                    left: 36.79,
                    bottom: 207.33,
                    child: SvgPicture.asset('assets/blogslogin/icon5.svg')
                  ),
                  Positioned(
                    top: 25.29,
                    right: 137.51,
                    left: 87.03,
                    bottom: 165.67,
                    child: SvgPicture.asset('assets/blogslogin/icon7.svg')
                  ),
                  Positioned(
                    top: 222.55,
                    right: 243.6,
                    left: 35.35,
                    bottom: 37.77,
                    child: SvgPicture.asset('assets/blogslogin/icon6.svg')
                  ),
                  Positioned(
                    top: 95.04,
                    right: 19.09,
                    left: 208.08,
                    bottom: 112.41,
                    child: SvgPicture.asset('assets/blogslogin/icon8.svg')
                  ),
                  Positioned(
                    top: 167.91,
                    right: 163.49,
                    left: 112.74,
                    bottom: 88.04,
                    child: SvgPicture.asset('assets/blogslogin/dot.svg')
                  ),
                  Positioned(
                    top: 167.91,
                    right: 249.8,
                    left: 26.93,
                    bottom: 88.04,
                    child: SvgPicture.asset('assets/blogslogin/dot.svg')
                  ),
                  Positioned(
                    top: 167.91,
                    right: 206.39,
                    left: 69.93,
                    bottom: 88.04,
                    child: SvgPicture.asset('assets/blogslogin/dot.svg')
                  ),
                  Positioned(
                    top: 167.91,
                    right: 120.48,
                    left: 155.62,
                    bottom: 88.04,
                    child: SvgPicture.asset('assets/blogslogin/dot.svg')
                  ),
                  Positioned(
                    top: 167.91,
                    right: 77.69,
                    left: 198.43,
                    bottom: 88.04,
                    child: SvgPicture.asset('assets/blogslogin/dot.svg')
                  ),
                  Positioned(
                    top: 0,
                    right: 79,
                    left: 210.69,
                    bottom: 269.49,
                    child: SvgPicture.asset('assets/blogslogin/dot2.svg')
                  ),
                  Positioned(
                    top: 249.45,
                    right: 55.54,
                    left: 234.18,
                    bottom: 20.01,
                    child: SvgPicture.asset('assets/blogslogin/dot2.svg')
                  ),
                  Positioned(
                    top: 50.46,
                    right: 62.21,
                    left: 217.3,
                    bottom: 208.68,
                    child: SvgPicture.asset('assets/blogslogin/star1.svg')
                  ),
                  Positioned(
                    top: 264.41,
                    right: 259.58,
                    left: 25.29,
                    bottom: 0,
                    child: SvgPicture.asset('assets/blogslogin/star2.svg')
                  ),
                  Positioned(
                    top: 85.68,
                    right: 290.58,
                    left: 0,
                    bottom: 184.61,
                    child: SvgPicture.asset('assets/blogslogin/star3.svg')
                  ),
                ],
              ),
            ),
            SizedBox(height: 35),
            Text(
              "You haven't Registered!",
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF494949),
                fontWeight: FontWeight.w700
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 52,
              width: 364,
              child: Text(
                "Register on placement portal to view blogs.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7C7C7C)
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: (){
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: Container(
                height: 52,
                width: 364,
                decoration: BoxDecoration(
                  color: myConstants.instiappBlue,
                  borderRadius: BorderRadius.circular(50)
                ),
                child: Center(
                  child: Text(
                    "Register Now",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
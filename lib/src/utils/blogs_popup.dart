import 'package:flutter/material.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:InstiApp/src/routes/blogpage.dart';
import 'package:InstiApp/src/routes/researchblogpage.dart';


class BlogsPopup extends StatelessWidget {
  final BuildContext hostContext;

  const BlogsPopup({Key? key, required this.hostContext}) : super(key: key);

  void _closeSheetAndNavigate(BuildContext sheetContext, Widget page) {
    Navigator.of(sheetContext).pop();
    Future.microtask(() {
      Navigator.of(hostContext).push(
        MaterialPageRoute(builder: (context) => page),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.width(412, context),
      padding: EdgeInsets.only(
        top: Responsive.height(16, context),
        left: Responsive.width(16, context),
        right: Responsive.width(16, context),
        bottom: Responsive.height(24, context),
      ),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF6F6F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Responsive.width(16, context)),
            topRight: Radius.circular(Responsive.width(16, context)),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Header row: back arrow | title | close ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Blogs',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: Responsive.width(24, context),
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              
            ],
          ),

          SizedBox(height: Responsive.height(12, context)),

          // ── Divider ──
          // Container(
          //   width: double.infinity,
          //   height: 1,
          //   color: const Color(0xFFDADADA),
          // ),
          Dash(
                  direction: Axis.horizontal,
                  length: Responsive.width(368, context),
                  dashLength: 6,
                  dashGap: 7,
                  dashColor: Color(0xFFDADADA),
                ),

          SizedBox(height: Responsive.height(16, context)),

          // ── "Track Your Results" label ──
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Track Your Results',
              style: TextStyle(
                color: Colors.black,
                fontSize: Responsive.width(20, context),
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(height: Responsive.height(10, context)),

          // ── Two-column card grid ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── LEFT: Placement card (tall) ──
              GestureDetector(
                onTap: () {
                  _closeSheetAndNavigate(context, BlogPage(blogState: 0));
                },
                child: _PlacementCard(context: context),
              ),

              SizedBox(width: Responsive.width(16, context)),

              // ── RIGHT: Internship + Research stacked ──
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _closeSheetAndNavigate(context, BlogPage(blogState: 1));
                      },
                      child: _SmallCard(
                        context: context,
                        title: 'Internship',
                        subtitle: 'Internship Shortlist\nUpdates',
                        imageWidget: SvgPicture.asset('assets/blogs/internship_blog_icon.svg', width: Responsive.width(140, context)),
                      ),
                    ),
                    SizedBox(height: Responsive.height(16, context)),
                    GestureDetector(
                      onTap: () {
                        _closeSheetAndNavigate(context, ResearchBlogPage());
                      },
                      child: _SmallCard(
                        context: context,
                        title: 'Research',
                        subtitle: 'Explore Research\nProjects',
                        imageWidget: SvgPicture.asset('assets/blogs/research_blog_icon.svg', width: Responsive.width(80, context)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: Responsive.height(20, context)),
        ],
      ),
    );
  }
}
class _PlacementCard extends StatelessWidget {
  final BuildContext context;
  const _PlacementCard({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Container(
      width: Responsive.width(178, context),
      height: Responsive.height(314, context),
      padding: EdgeInsets.fromLTRB(Responsive.width(16, context), Responsive.height(16, context), Responsive.width(0, context), Responsive.height(0, context)),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFEFEFEF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.width(14, context)),
        ),
      ),
      child: Stack(
        children: [
          // Text content at top
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Placement',
                style: TextStyle(
                  color: const Color(0xFF0F1620),
                  fontSize: Responsive.width(16, context),
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Responsive.height(2, context)),
              Text(
                'Campus Placement\nUpdates',
                style: TextStyle(
                  color: const Color(0xFF0F1620).withOpacity(0.65),
                  fontSize: Responsive.width(12, context),
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: Responsive.height(10, context)),
              // "Name mentioned!" badge
              // Container(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: Responsive.width(8, context),
              //     vertical: Responsive.height(4, context),
              //   ),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFF306FDC),
              //     borderRadius: BorderRadius.circular(4),
              //   ),
              //   child: Text(
              //     'Name mentioned!',
              //     style: TextStyle(
              //       color: Colors.white,
              //       fontSize: Responsive.width(10, context),
              //       fontFamily: 'DM Sans',
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
            ],
          ),
          // Illustration at bottom
          
          Positioned(
            bottom: 0,
            left: 0,
            right: -55,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset('assets/blogs/placement_blog_icon.svg', width: Responsive.width(110, context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String subtitle;
  final Widget imageWidget;

  const _SmallCard({
    required this.context,
    required this.title,
    required this.subtitle,
    required this.imageWidget,
  });

  @override
  Widget build(BuildContext ctx) {
    return Container(
      width: double.infinity,
      height: Responsive.height(149, context),
      padding: EdgeInsets.fromLTRB(Responsive.width(16, context), Responsive.height(16, context), Responsive.width(0, context), Responsive.height(0, context)),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFEFEFEF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.width(14, context)),
        ),
      ),
      child: Stack(
        children: [
          // Text at top-left
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF0F1620),
                  fontSize: Responsive.width(16, context),
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Responsive.height(2, context)),
              Text(
                subtitle,
                style: TextStyle(
                  color: const Color(0xFF0F1620).withOpacity(0.65),
                  fontSize: Responsive.width(12, context),
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          // Illustration at bottom-right
          Positioned(
            bottom: 5,
            right: 5,
            child: imageWidget,
          ),
        ],
      ),
    );
  }
}

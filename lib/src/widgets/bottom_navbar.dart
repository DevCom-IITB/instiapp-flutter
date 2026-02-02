import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:InstiApp/constants.dart';
import 'package:InstiApp/main.dart' as main_app;

class NavBarItem {
  final String label;
  final String iconPath;

  const NavBarItem({
    required this.label,
    required this.iconPath,
  });
}

class Responsive {
  final BuildContext context;
  final double baseWidth;
  final double baseHeight;
  final double bottomPadding;

  Responsive(this.context, {this.baseWidth = 411, this.baseHeight = 914, this.bottomPadding = 0});

  double w(double px) => MediaQuery.of(context).size.width * (px / baseWidth);
  double h(double px) => (MediaQuery.of(context).size.height - bottomPadding) * (px / baseHeight);
  double sp(double px) => w(px);
}

class InstiBottomNavBar extends StatelessWidget {
  final List<NavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double height;
  final double width;

  const InstiBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.height = 90,
    this.width = 396,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context, bottomPadding: main_app.systemBottomPadding);
    final constants = Constants();

    final navBarHeight = responsive.h(height);
    final navBarWidth = responsive.w(width);

    // === EXACT ratios from original design ===
    final indicatorWidth = navBarWidth * (63 / 396);
    final indicatorHeight = navBarHeight * (33 / 90);
    final iconSize = navBarWidth * (24 / 396);

    return Container(    
      
      height: navBarHeight,
      width: navBarWidth,
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO( 246,246, 246,1), width: 5),
        color: constants.instiappDark,
        borderRadius: BorderRadius.circular(navBarHeight / 2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.w(16.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = currentIndex == index;
        
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(index),
              child: SizedBox(
                width: indicatorWidth * 1.3, // spreads horizontally
                height: navBarHeight,        // full vertical tap area
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: indicatorWidth,
                      height: indicatorHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedScale(
                            scale: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            child: Container(
                              width: indicatorWidth,
                              height: indicatorHeight,
                              decoration: BoxDecoration(
                                color: constants.instiappBlue,
                                borderRadius: BorderRadius.circular(responsive.h(79.67)),
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            item.iconPath,
                            width: iconSize,
                            height: iconSize,
                            colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(isSelected ? 1 : 0.7),
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: responsive.h(2)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: isSelected
                              ? constants.instiappBlue
                              : Colors.white.withOpacity(0.7),
                          fontSize: responsive.sp(12),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

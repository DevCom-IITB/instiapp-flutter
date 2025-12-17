import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:InstiApp/constants.dart';

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

  Responsive(this.context, {this.baseWidth = 411, this.baseHeight = 914});

  double w(double px) => MediaQuery.of(context).size.width * (px / baseWidth);
  double h(double px) => MediaQuery.of(context).size.height * (px / baseHeight);
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
    this.height = 80,
    this.width = 396,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final constants = Constants();

    final navBarHeight = responsive.h(height);
    final navBarWidth = responsive.w(width);

    // === EXACT ratios from original design ===
    final itemWidth = navBarWidth * (87 / 396);
    final indicatorWidth = navBarWidth * (63 / 396);
    final indicatorHeight = navBarHeight * (33 / 80);
    final iconSize = navBarWidth * (24 / 396);

    return Container(
      height: navBarHeight,
      width: navBarWidth,
      decoration: BoxDecoration(
        color: constants.instiappDark,
        borderRadius: BorderRadius.circular(navBarHeight / 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = currentIndex == index;

          return SizedBox(
            width: itemWidth,
            child: GestureDetector(
              onTap: () => onTap(index),
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
                              borderRadius:
                                  BorderRadius.circular(79.67),
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
                  SizedBox(
                    width: itemWidth,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: isSelected
                              ? constants.instiappBlue
                              : Colors.white.withOpacity(0.7),
                          fontSize: responsive.sp(12),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

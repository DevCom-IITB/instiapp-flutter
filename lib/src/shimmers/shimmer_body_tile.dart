import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';

class BodyTileShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.height(10, context),
        horizontal: Responsive.width(16, context),
      ),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: Responsive.width(73, context),
              height: Responsive.width(73, context),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(Responsive.width(16, context)),
              ),
            ),
          ),
          SizedBox(width: Responsive.width(16, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerLine(
                  context,
                  width: double.infinity,
                  height: Responsive.height(18, context),
                ),
                SizedBox(height: Responsive.height(8, context)),
                _shimmerLine(
                  context,
                  width: Responsive.width(150, context),
                  height: Responsive.height(14, context),
                ),
                SizedBox(height: Responsive.height(8, context)),
                _shimmerLine(
                  context,
                  width: Responsive.width(80, context),
                  height: Responsive.height(14, context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerLine(BuildContext context,
      {required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(Responsive.height(4, context)),
        ),
      ),
    );
  }
}

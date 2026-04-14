import 'package:flutter/material.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';

class ResearchCard extends StatelessWidget {
  final String title;
  final String professor;
  final String description;
  final String tag;
  final String imageUrl;

  const ResearchCard({
    Key? key,
    required this.title,
    required this.professor,
    required this.description,
    required this.tag,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.width(16, context),
        vertical: Responsive.height(8, context),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(Responsive.width(10, context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left accent bar and Image
          IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: Responsive.width(6, context),
                  decoration: BoxDecoration(
                    color: const Color(0xFF306FDC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Responsive.width(10, context)),
                      bottomLeft:
                          Radius.circular(Responsive.width(10, context)),
                    ),
                  ),
                ),
                Container(
                  width: Responsive.width(113, context),
                  height: Responsive.height(189, context),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageUrl.startsWith('http')
                          ? NetworkImage(imageUrl)
                          : AssetImage(imageUrl) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content Area
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(Responsive.width(16, context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: Responsive.text(16, context),
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: Responsive.height(8, context)),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'By ',
                          style: TextStyle(
                            color: const Color(0xFF306FDC),
                            fontSize: Responsive.text(14, context),
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        TextSpan(
                          text: professor,
                          style: TextStyle(
                            color: const Color(0xFF306FDC),
                            fontSize: Responsive.text(14, context),
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.height(8, context)),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF3C424A),
                      fontSize: Responsive.text(12, context),
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  SizedBox(height: Responsive.height(8, context)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1B3252),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: const Color(0xFFF6F6F6),
                        fontSize: Responsive.text(10, context),
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:InstiApp/src/utils/responsivenew.dart';

class ResearchDetailPage extends StatelessWidget {
  final String title;
  final String professor;
  final String imageUrl;

  // Project Details
  final String duration;
  final String weeklyTimeCommitment;
  final String campusStayRequired;

  // Eligibility Criteria
  final String cpi;
  final String yearOfStudy;

  // Description
  final String description;

  const ResearchDetailPage({
    required this.title,
    required this.professor,
    required this.imageUrl,
    required this.duration,
    required this.weeklyTimeCommitment,
    required this.campusStayRequired,
    required this.cpi,
    required this.yearOfStudy,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          // ── Scrollable Content ────────────────────────────────────
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: Responsive.height(100.0, context), // space for bottom bar
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Image ──────────────────────────────────────
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: Responsive.height(220.0, context),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Back button
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: Responsive.width(16.0, context),
                          top: Responsive.height(8.0, context),
                        ),
                        child: Container(
                          height: Responsive.height(36.0, context),
                          width: Responsive.width(36.0, context),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.arrow_back,
                                color: Colors.black,
                                size: Responsive.height(20.0, context)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    ),
                    // Bookmark button
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: Responsive.width(16.0, context),
                          top: Responsive.height(8.0, context),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            height: Responsive.height(36.0, context),
                            width: Responsive.width(36.0, context),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.bookmark_border,
                                  color: Colors.black,
                                  size: Responsive.height(20.0, context)),
                              onPressed: () {
                                // TODO: bookmark action
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(16.0, context),
                    vertical: Responsive.height(16.0, context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ─────────────────────────────────────
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: Responsive.text(22.0, context),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DM Sans',
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: Responsive.height(6.0, context)),

                      // ── Professor ─────────────────────────────────
                      Text(
                        'by $professor',
                        style: TextStyle(
                          fontSize: Responsive.text(14.0, context),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'DM Sans',
                          color: const Color(0xFF306FDC), // blue
                        ),
                      ),
                      SizedBox(height: Responsive.height(20.0, context)),

                      // ── Project Details ───────────────────────────
                      _sectionHeading('Project Details', context),
                      SizedBox(height: Responsive.height(8.0, context)),
                      _detailRow('Duration:', duration, context),
                      _detailRow('Weekly Time Commitment:', weeklyTimeCommitment, context),
                      _detailRow('Campus Stay Required:', campusStayRequired, context),
                      SizedBox(height: Responsive.height(20.0, context)),

                      // ── Eligibility Criteria ──────────────────────
                      _sectionHeading('Eligibility Criteria', context),
                      SizedBox(height: Responsive.height(8.0, context)),
                      _detailRow('CPI:', cpi, context),
                      _detailRow('Year of Study:', yearOfStudy, context),
                      SizedBox(height: Responsive.height(20.0, context)),

                      // ── Description ───────────────────────────────
                      _sectionHeading('Description', context),
                      SizedBox(height: Responsive.height(8.0, context)),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: Responsive.text(14.0, context),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'DM Sans',
                          color: Colors.black,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Action Bar ─────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: const Color(0xFFF6F6F6),
              padding: EdgeInsets.only(
                left: Responsive.width(16.0, context),
                right: Responsive.width(16.0, context),
                top: Responsive.height(12.0, context),
                bottom: Responsive.height(24.0, context),
              ),
              child: Row(
                children: [
                  // Share button
                  Container(
                    height: Responsive.height(48.0, context),
                    width: Responsive.width(48.0, context),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.share_outlined,
                          color: Colors.black,
                          size: Responsive.height(22.0, context)),
                      onPressed: () {
                        // TODO: share action
                      },
                    ),
                  ),
                  SizedBox(width: Responsive.width(12.0, context)),

                  // Apply button
                  Expanded(
                    child: SizedBox(
                      height: Responsive.height(48.0, context),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF306FDC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: Icon(Icons.open_in_new,
                            color: Colors.white,
                            size: Responsive.height(18.0, context)),
                        label: Text(
                          'Apply',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.text(16.0, context),
                            fontWeight: FontWeight.w700,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                        onPressed: () {
                          // TODO: apply action (likely launches ReaCH URL)
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.width(12.0, context)),

                  // WhatsApp button
                  Container(
                    height: Responsive.height(48.0, context),
                    width: Responsive.width(48.0, context),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366), // WhatsApp green
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      // TODO: replace with assets/research/whatsapp.svg when available
                      icon: Icon(Icons.chat,
                          color: Colors.white,
                          size: Responsive.height(22.0, context)),
                      onPressed: () {
                        // TODO: open WhatsApp group link
                      },
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

  // ── Helpers ────────────────────────────────────────────────────────

  Widget _sectionHeading(String text, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Responsive.text(16.0, context),
        fontWeight: FontWeight.w700,
        fontFamily: 'DM Sans',
        color: Colors.black,
      ),
    );
  }

  /// Renders a label + highlighted value on the same line
  /// e.g. "Duration:  3 Months" where "3 Months" is blue
  Widget _detailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.height(4.0, context)),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: Responsive.text(14.0, context),
            fontFamily: 'DM Sans',
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF306FDC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
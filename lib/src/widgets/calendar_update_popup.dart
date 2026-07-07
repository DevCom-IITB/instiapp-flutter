import 'package:flutter/material.dart';

/// First-launch announcement popup advertising the new in-app calendar.
///
/// Visual reference: Figma frame "Calendar update popup" (Mess Menu / Feed
/// screen). The calendar screenshot inside the blue banner is a static
/// image asset rather than a rebuilt widget tree, since it's purely
/// decorative and never changes at runtime.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   barrierColor: Colors.black.withOpacity(0.5),
///   builder: (dialogContext) => CalendarUpdatePopup(
///     onLater: () => Navigator.of(dialogContext).pop(),
///     onUpdateNow: () {
///       Navigator.of(dialogContext).pop();
///       // navigate to / open the calendar tab
///     },
///   ),
/// );
/// ```
class CalendarUpdatePopup extends StatelessWidget {
  final VoidCallback onLater;
  final VoidCallback onUpdateNow;

  const CalendarUpdatePopup({
    super.key,
    required this.onLater,
    required this.onUpdateNow,
  });

  // Figma frame is designed at a 411px reference width.
  static const double _baseWidth = 411;
  static const double _cardWidthPx = 359;
  static const double _bannerHeightPx = 226;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / _baseWidth;
    // Clamp so the card doesn't get absurdly large/small on tablets or tiny screens.
    final cardWidth = (_cardWidthPx * scale).clamp(280.0, 380.0);
    final bannerHeight = cardWidth * (_bannerHeightPx / _cardWidthPx);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: cardWidth,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _previewBanner(cardWidth, bannerHeight),
            SizedBox(height: cardWidth * 0.025),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.06),
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Insti',
                      style: TextStyle(
                        color: Color(0xFF306FDC),
                        fontSize: 20,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '- Calendar is out!',
                      style: TextStyle(
                        color: Color(0xFF0F1620),
                        fontSize: 20,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.06),
              child: const Text(
                'All your schedules in one place.',
                style: TextStyle(
                  color: Color(0xCC0F1620),
                  fontSize: 16,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: cardWidth * 0.08),
            Padding(
              padding: EdgeInsets.only(right: cardWidth * 0.03, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onLater,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                    child: const Text(
                      'Later',
                      style: TextStyle(
                        color: Color(0xFF306FDC),
                        fontSize: 16,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onUpdateNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF306FDC),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    child: const Text(
                      'Update now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top banner: blue rounded card with the static calendar screenshot
  /// (slightly tilted + scaled up so rotation never reveals empty edges)
  /// and a bottom gradient for visual depth, matching the Figma frame.
  Widget _previewBanner(double cardWidth, double bannerHeight) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: cardWidth,
        height: bannerHeight,
        color: const Color(0xFF306FDC),
        padding: const EdgeInsets.all(8), // white inset "frame" look
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Transform.rotate(
                  angle: -0.06,
                  child: Transform.scale(
                    scale: 1.2,
                    child: Image.asset(
                      // TODO: export the "calendar mockup" Figma frame as a
                      // PNG (2x/3x) and place it at this path.
                      'assets/homepage/images/calendar_preview.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF6F6F6),
                        child: const Center(
                          child: Icon(Icons.calendar_month,
                              color: Color(0xFF306FDC), size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Darkens the lower portion slightly for visual depth.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

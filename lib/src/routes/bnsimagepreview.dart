import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:InstiApp/src/api/model/buynsellPost.dart';

class ImagePreviewPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final BuynSellPost post;

  const ImagePreviewPage({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
    required this.post,
  }) : super(key: key);

  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color.fromRGBO(235, 235, 235, 0.8),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.arrow_back, color: Colors.black, size: 28),
              ),
            ),
          ),
        ),
        title: Text(
          '${_currentIndex + 1}/${widget.imageUrls.length}',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4,
            heroAttributes:
                PhotoViewHeroAttributes(tag: widget.imageUrls[index]),
          );
        },
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(widget.post),
    );
  }

  Widget _buildBottomActionBar(BuynSellPost post) {
    String phoneNumber = post.contactDetails ?? '';
    return Container(
      alignment: Alignment.topCenter,
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildShareButton(post),
              _buildCopyNumberButton(phoneNumber),
              _buildWhatsAppButton(phoneNumber),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton(BuynSellPost post) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4, left: 4),
      decoration: BoxDecoration(
        color: Color.fromRGBO(45, 70, 108, 1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.share, color: Colors.white),
        onPressed: () async {
          final deepLink = 'https://www.insti.app/buynsell/${post.id}';

          final shareText = '${post.name}\n'
              '${post.price != null ? '₹${post.price}' : 'Giveaway'}\n'
              'Check it out: $deepLink';

          await Share.share(
            shareText,
            subject: '${post.name} on InstiApp',
          );
        },
      ),
    );
  }

  Widget _buildCopyNumberButton(String phoneNumber) {
    return Expanded(
      child: Container(
        height: 52,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color.fromRGBO(48, 111, 220, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            ),
          ),
          icon: Icon(Icons.copy, size: 28, color: Colors.white),
          label: Text(
            _formatPhoneNumber(phoneNumber),
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              letterSpacing: 1.1,
            ),
          ),
          onPressed: () {
            if (phoneNumber.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No phone number available")),
              );
              return;
            }

            Clipboard.setData(ClipboardData(text: phoneNumber));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Phone number copied!")),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWhatsAppButton(String phoneNumber) {
    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.only(left: 12, top: 4, bottom: 4, right: 4),
      decoration: BoxDecoration(
        color: Color.fromRGBO(37, 211, 102, 1),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.hardEdge,
      child: IconButton(
        iconSize: 24,
        icon: SizedBox(
          width: 24,
          height: 24,
          child: Image.asset('assets/buynsell/whatsapplogo.png'),
        ),
        onPressed: () async {
          if (phoneNumber.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No phone number available")),
            );
            return;
          }

          final whatsappNumber = _getWhatsAppNumber(phoneNumber);
          final url = 'https://wa.me/$whatsappNumber';
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch WhatsApp')),
            );
          }
        },
      ),
    );
  }

  // Helper Methods
  String _formatPhoneNumber(String number) {
    if (number.isEmpty) return 'No Number';
    if (number.length != 10) return number;
    return '${number.substring(0, 4)} ${number.substring(4, 7)} ${number.substring(7)}';
  }

  String _getWhatsAppNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';
    // Add country code only if it's a 10-digit number
    return phoneNumber.length == 10 ? '91$phoneNumber' : phoneNumber;
  }
}

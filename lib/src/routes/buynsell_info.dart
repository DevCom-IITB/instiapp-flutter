// class BuyAndSellInfoPage extends StatefulWidget {
//   final Future<BuynSellPost?> post;

//   BuyAndSellInfoPage({required this.post});

//   static void navigateWith(
//       BuildContext context, BuynSellPost bloc, BuynSellPost post) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         settings: RouteSettings(
//           name: "/${post.id ?? ""}",
//         ),
//         builder: (context) => BuyAndSellInfoPage(
//           post: bloc.getBuynSellPost(post.id ?? ""),
//         ),
//       ),
//     );
//   }

//   @override
//   State<BuyAndSellInfoPage> createState() => _BuyAndSellInfoPageState();
// }

// class _BuyAndSellInfoPageState extends State<BuyAndSellInfoPage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

//   BuynSellPost? bnsPost;

//   @override
//   void initState() {
//     super.initState();
//     widget.post.then((bnsPost) {
//       if (this.mounted) {
//         setState(() {
//           this.bnsPost = bnsPost;
//         });
//       }
//     });
//   }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:InstiApp/src/api/model/buynsellPost.dart';
import '../widgets/dotted_divider.dart';
import 'bnsimagepreview.dart';
import 'package:InstiApp/src/blocs/buynsell_post_bloc.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'bnscreatepost.dart';

class BuyAndSellInfoPage extends StatefulWidget {
  final String postId;
  final BuynSellPost? initialPost;
  final bool isMyPost;
  // final Function(String id, bool isBookmarked) onBookmarkChanged;

  const BuyAndSellInfoPage({
    Key? key,
    required this.postId,
    this.initialPost,
    this.isMyPost = false,
    // required this.onBookmarkChanged,
  }) : super(key: key);

  @override
  _BuyAndSellInfoPageState createState() => _BuyAndSellInfoPageState();
}

class _BuyAndSellInfoPageState extends State<BuyAndSellInfoPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  late Future<BuynSellPost?> _postFuture;
  late BuynSellPostBloc _bloc;
  // bool _isBookmarked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of(context)!.bloc.buynSellPostBloc;
    _postFuture = widget.initialPost != null
        ? Future.value(widget.initialPost)
        : _bloc.getBuynSellPost(widget.postId);
  }

  Future<void> _refresh() async {
    setState(() {
      _postFuture = _bloc.getBuynSellPost(widget.postId);
    });
    await _postFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BuynSellPost?>(
      future: _postFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorState(snapshot.error);
        }

        final post = snapshot.data!;
        return _buildContent(post);
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Failed to load product',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _refresh,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuynSellPost post) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = 350.0;
    final isSold = !post.status!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(post, imageHeight, screenWidth),
                _buildProductInfo(post, screenWidth),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _buildBackButton(),
          ),
          if (widget.isMyPost)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: _buildEditDeleteMenu(post, isSold),
            ),
        ],
      ),
      bottomNavigationBar: widget.isMyPost
          ? _buildOwnerBottomBar(post, isSold)
          : _buildBottomActionBar(post),
    );
  }

  Widget _buildEditDeleteMenu(BuynSellPost post, bool isSold) {
    return isSold
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(),
                  iconSize: 32,
                  icon: const Icon(
                    Icons.delete_outline_outlined,
                    size: 32,
                    color: Colors.red,
                  ),
                  onPressed: () => {_confirmDelete(post.id)},
                ),
              ],
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(),
                  iconSize: 32,
                  icon: const Icon(
                    Icons.delete_outline_outlined,
                    size: 32,
                    color: Colors.red,
                  ),
                  onPressed: () => {_confirmDelete(post.id)},
                ),
                IconButton(
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(),
                  iconSize: 32,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 32,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    _navigateToEditPage(post);
                  },
                ),
              ],
            ),
          );
  }

  void _confirmDelete(String? id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _bloc.deleteBuynSellPost(id!);
              Navigator.pop(context);
              Navigator.pop(context);
              await _bloc.refresh();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToEditPage(BuynSellPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostItemFlow(
          isEditable: true,
          existingPost: post,
        ),
      ),
    ).then((_) async {
      Navigator.pop(context);
      await _bloc.refresh();
    });
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacementNamed('/feed');
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.arrow_back, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  // Widget _buildBookmarkButton(BuynSellPost post) {
  //   return Padding(
  //     padding: const EdgeInsets.only(right: 12.0, top: 8.0),
  //     child: GestureDetector(
  //       onTap: () {
  //         setState(() {
  //           _isBookmarked = !_isBookmarked;
  //           widget.onBookmarkChanged(post.id ?? '', _isBookmarked);
  //         });
  //       },
  //       child: Container(
  //         width: 48,
  //         height: 48,
  //         decoration: BoxDecoration(
  //           color: Colors.black.withOpacity(0.5),
  //           shape: BoxShape.circle,
  //         ),
  //         child: Center(
  //           child: Icon(
  //             _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
  //             color: Colors.white,
  //             size: 32,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildImageGallery(
      BuynSellPost post, double imageHeight, double screenWidth) {
    final images = post.imageUrl ?? [];

    return Container(
      width: double.infinity,
      height: imageHeight,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          if (images.isNotEmpty) _buildImagePager(images, imageHeight, post),
          if (images.isEmpty) _buildPlaceholderImage(),
          if (images.length > 1) ...[
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildSmartDots(images.length),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 15,
              child: _buildImageCounter(images.length),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePager(
      List<String> images, double imageHeight, BuynSellPost post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewPage(
              imageUrls: images,
              initialIndex: _currentImageIndex,
              post: post,
            ),
          ),
        );
      },
      child: PageView.builder(
        controller: _pageController,
        itemCount: images.length,
        onPageChanged: (index) => setState(() => _currentImageIndex = index),
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: images[index],
            width: MediaQuery.of(context).size.width,
            height: imageHeight,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholderImage(),
            errorWidget: (context, url, error) => _buildPlaceholderImage(),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Image.asset('assets/buynsell/DevcomLogo.png'),
      ),
    );
  }

  Widget _buildImageCounter(int imageCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${_currentImageIndex + 1}/$imageCount',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildProductInfo(BuynSellPost post, double screenWidth) {
    final userName = post.user?.userName ?? 'Unknown';
    final rollNumber = post.user?.userLDAPId ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceRow(post),
          const SizedBox(height: 16),
          _buildTitle(post),
          const SizedBox(height: 16),
          _buildSellerInfo(userName, rollNumber, post.timeBefore),
          const DottedDivider(padding: EdgeInsets.fromLTRB(0, 8, 8, 24)),
          _buildDescriptionSection(post),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuynSellPost post) {
    final isGiveaway = post.action == 'giveaway';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (isGiveaway)
          Text(
            'Giveaway',
            style: TextStyle(
              fontSize: 24,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹${post.price ?? 0}',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (post.originalPrice != null && post.originalPrice! > 0)
                Text(
                  'Bought at ₹${post.originalPrice}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        if (!isGiveaway)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    (post.negotiable ?? false) ? Color(0xFF67BC00) : Colors.red,
              ),
            ),
            child: Text(
              (post.negotiable ?? false) ? 'Negotiable' : 'Fixed Price',
              style: TextStyle(
                color:
                    (post.negotiable ?? false) ? Color(0xFF67BC00) : Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(BuynSellPost post) {
    return Text(
      post.name ?? 'Untitled',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSellerInfo(
      String userName, String rollNumber, String? timeBefore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(userName, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Text(
              '($rollNumber)',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        Text(
          timeBefore ?? 'Recently',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuynSellPost post) {
    final description = _buildFullDescription(post);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  String _buildFullDescription(BuynSellPost post) {
    final description = post.description ?? '';
    final brand = post.brand == null || post.brand!.isEmpty
        ? ''
        : 'Brand: ${post.brand}\n';
    final condition =
        post.condition != null ? 'Condition: ${post.condition}/10\n' : '';
    final warranty = post.warranty != null
        ? 'Warranty: ${post.warranty! ? "Yes" : "No"}\n'
        : '';
    final packaging = post.packaging != null
        ? 'Packaging: ${post.packaging! ? "Yes" : "No"}\n'
        : '';

    return '$brand$condition$warranty$packaging$description';
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
          image: DecorationImage(
            image: AssetImage('assets/buynsell/bottomnavbar.png'),
            fit: BoxFit.cover,
          ),
          color: Color(0xFF0F1620),
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

  Widget _buildOwnerBottomBar(BuynSellPost post, bool isSold) {
    return isSold
        ? Container(
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
                image: DecorationImage(
                  image: AssetImage('assets/buynsell/bottomnavbar.png'),
                  fit: BoxFit.cover,
                ),
                color: Color(0xFF0F1620),
                borderRadius: BorderRadius.circular(50),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSoldIndicator(post),
                  ],
                ),
              ),
            ),
          )
        : Container(
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
                image: DecorationImage(
                  image: AssetImage('assets/buynsell/bottomnavbar.png'),
                  fit: BoxFit.cover,
                ),
                color: Color(0xFF0F1620),
                borderRadius: BorderRadius.circular(50),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShareButton(post),
                    _buildMarkSoldButton(post),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildSoldIndicator(BuynSellPost post) {
    return Expanded(
      child: Container(
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(21, 32, 46, 1),
            borderRadius: BorderRadius.circular(48),
            border: Border.all(color: Color.fromRGBO(126, 130, 135, 1), width: 2)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline,
                color: Color.fromRGBO(126, 130, 135, 1),
                size: 16
              ),
              SizedBox(width: 6),
              Text(
                'Sold',
                style: TextStyle(
                  color: Color.fromRGBO(126, 130, 135, 1),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
        ),
      ),
    );
  }

  Widget _buildMarkSoldButton(BuynSellPost post) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: 4),
        height: 52,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color.fromRGBO(48, 111, 220, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            ),
          ),
          onPressed: () {
            _confirmMarkAsSold(post);
          },
          label: Text(
            "Mark as Sold",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmMarkAsSold(BuynSellPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Sold'),
        content: const Text('Are you sure you want to mark this item as sold?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _bloc.markAsSold(post.id!);
              Navigator.pop(context);
              Navigator.pop(context);
              await _bloc.refresh();
            },
            child: const Text('Confirm'),
          ),
        ],
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

  List<Widget> _buildSmartDots(int total) {
    const maxVisibleDots = 7;
    if (total <= maxVisibleDots) {
      return List.generate(total, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentImageIndex == index ? Colors.white : Colors.grey,
          ),
        );
      });
    }

    int start = (_currentImageIndex - maxVisibleDots ~/ 2)
        .clamp(0, total - maxVisibleDots);

    return List.generate(maxVisibleDots, (i) {
      int actualIndex = start + i;
      double size = 8;
      if (i == 0 && actualIndex != 0) size = 5;
      if (i == maxVisibleDots - 1 && actualIndex != total - 1) size = 5;

      return AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: size,
        height: size,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentImageIndex == actualIndex ? Colors.white : Colors.grey,
        ),
      );
    });
  }
}

// import 'package:InstiApp/src/utils/common_widgets.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import '../api/model/buynsellPost.dart';

// class BuyAndSellInfoPage extends StatefulWidget {
//   final Future<BuynSellPost?> post;

//   BuyAndSellInfoPage({required this.post});

//   static void navigateWith(
//       BuildContext context, BuynSellPost bloc, BuynSellPost post) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         settings: RouteSettings(
//           name: "/${post.id ?? ""}",
//         ),
//         builder: (context) => BuyAndSellInfoPage(
//           post: bloc.getBuynSellPost(post.id ?? ""),
//         ),
//       ),
//     );
//   }

//   @override
//   State<BuyAndSellInfoPage> createState() => _BuyAndSellInfoPageState();
// }

// class _BuyAndSellInfoPageState extends State<BuyAndSellInfoPage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

//   BuynSellPost? bnsPost;

//   @override
//   void initState() {
//     super.initState();
//     widget.post.then((bnsPost) {
//       if (this.mounted) {
//         setState(() {
//           this.bnsPost = bnsPost;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<String>? imageList = bnsPost?.imageUrl;
//     double screen_wr = MediaQuery.of(context).size.width;
//     double screen_hr = MediaQuery.of(context).size.height;
//     double x, y;

//     var theme = Theme.of(context);

//     screen_hr >= screen_wr ? x = 0.35 : x = 1;
//     screen_hr >= screen_wr ? y = 0.9 : y = 0.8;
//     var screen_w = screen_wr * y;
//     var screen_h = screen_hr * x;

//     return Scaffold(
//       bottomNavigationBar: MyBottomAppBar(
//         shape: RoundedNotchedRectangle(),
//         child: new Row(
//           mainAxisSize: MainAxisSize.max,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
//             IconButton(
//               icon: Icon(
//                 Icons.menu_outlined,
//                 color: Colors.blue.withOpacity(0),
//                 semanticLabel: "Show navigation drawer",
//               ),
//               onPressed: () {
//                 _scaffoldKey.currentState?.openDrawer();
//               },
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(children: [
//           Container(
//             padding: EdgeInsets.only(top: 32, left: 16),
//             alignment: Alignment.topLeft,
//             child: Container(
//               padding: EdgeInsets.only(top: 32, left: 16),
//               alignment: Alignment.topLeft,
//               child: DecoratedBox(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Colors.blueAccent,
//                     width: 2.0,
//                   ),
//                 ),
//                 child: IconButton(
//                   icon: Icon(Icons.arrow_back_ios_outlined,
//                       color: Colors.blueAccent),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Container(
//                 margin: EdgeInsets.fromLTRB(screen_w * 0.1, 15, 0, 0),
//                 child: SizedBox(
//                   height: screen_h / 1.2,
//                   width: screen_w / 1,
//                   child: ImageCarousel(imageList),
//                 ),
//               ),
//               Spacer(),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Container(
//                   margin: EdgeInsets.fromLTRB(screen_w * 0.1, 11, 0, 0),
//                   child: Container(
//                     width: screen_w,
//                     child: Text(bnsPost?.brand ?? "",
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: theme.textTheme.titleLarge?.copyWith(
//                             fontWeight: FontWeight.w100, fontSize: 20)),
//                   )
//                   // style: TextStyle(
//                   //     fontSize: myfont / 1.3, fontWeight: FontWeight.w100),
//                   ),
//             ],
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Container(
//                 margin: EdgeInsets.fromLTRB(screen_w * 0.1, 3, 0, 0),
//                 child: Text(
//                   '${bnsPost?.user?.userName ?? ""} (${bnsPost?.user?.userLDAPId ?? ""})',
//                 ),
//               ),
//             ],
//           ),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Container(
//                   width: screen_w * 0.9,
//                   margin: EdgeInsets.fromLTRB(screen_w * 0.1, 3, 0, 0),
//                   child: Text(bnsPost?.name ?? "",
//                       maxLines: 3,
//                       overflow: TextOverflow.ellipsis,
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         // fontSize: 30,
//                         fontSize: 30,
//                       )
//                       // style: TextStyle(
//                       //     fontSize: myfont * 1.5, fontWeight: FontWeight.w700),
//                       )),
//             ],
//           ),
//           Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//             Container(
//               margin: EdgeInsets.fromLTRB(screen_w * 0.1, 5, 0, 0),
//               child: Text("Condition - " + (bnsPost?.condition ?? '0') + '/10',
//                   style: theme.textTheme.titleLarge
//                       ?.copyWith(fontSize: 15, fontWeight: FontWeight.w500)
//                   // style: TextStyle(fontSize: myfont, fontWeight: FontWeight.w100),
//                   ),
//             )
//           ]),
//           Column(children: [
//             Container(
//               width: screen_w * 0.9,
//               height: screen_h * 0.5,
//               margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
//               child: Text(bnsPost?.description ?? "",
//                   maxLines: 10,
//                   overflow: TextOverflow.ellipsis,
//                   softWrap: false,
//                   style: theme.textTheme.bodySmall?.copyWith(fontSize: 13)
//                   // style: TextStyle(
//                   //     fontSize: myfont * 0.75, fontWeight: FontWeight.w100),
//                   ),
//             ),
//             SizedBox(
//               height: screen_h * 0.07,
//             ),
//             SizedBox(
//               width: screen_w,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               'Phone number - ' +
//                                   (bnsPost?.contactDetails ?? ""),
//                               style: theme.textTheme.headlineMedium?.copyWith(
//                                   fontSize: 20, fontWeight: FontWeight.w400),
//                             ),
//                           ],
//                         ),
//                         Container(
//                           child: Row(
//                             children: [
//                               Text(
//                                 "Negotiable - " +
//                                     ((bnsPost?.negotiable ?? false)
//                                         ? "Yes"
//                                         : "No"),
//                                 style: theme.textTheme.headlineMedium?.copyWith(
//                                     fontSize: 20, fontWeight: FontWeight.w400),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Container(
//                           child: Text(
//                             (bnsPost?.action == 'giveaway'
//                                 ? "GiveAway"
//                                 : "Price - ₹" +
//                                     (bnsPost?.price ?? 0).toString()),
//                             style: theme.textTheme.headlineMedium?.copyWith(
//                                 fontSize: 20, fontWeight: FontWeight.w400),
//                             textAlign: TextAlign.left,
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                   Spacer(),
//                 ],
//               ),
//             ),
//           ]),

//           // Add more widgets below the image card
//         ]),
//       ),
//     );
//   }
// }

// class ImageCarousel extends StatefulWidget {
//   final List<String>? imageList;

//   ImageCarousel(this.imageList);

//   @override
//   _ImageCarouselState createState() => _ImageCarouselState();
// }

// class _ImageCarouselState extends State<ImageCarousel> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     double screen_wr = MediaQuery.of(context).size.width;
//     double screen_hr = MediaQuery.of(context).size.height;
//     double x, y;

//     screen_hr >= screen_wr ? x = 0.35 : x = 1;
//     if (0.5 <= screen_hr / screen_wr && screen_hr / screen_wr <= 1) {
//       x = 0.8;
//     }
//     screen_hr >= screen_wr ? y = 0.9 : y = 0.8;
//     var screen_w = screen_wr * y;
//     var screen_h = screen_hr * x;

//     if (widget.imageList == null || widget.imageList!.isEmpty) {
//       return Container(
//         child: Center(child: Image.asset('assets/buynsell/DevcomLogo.png')),
//       );
//     }

//     return Row(
//       children: [
//         Expanded(
//           flex: 3,
//           child: Row(
//             children: [
//               Container(
//                 child: SizedBox(
//                   height: screen_h * 0.7,
//                   width: screen_w * 0.6,
//                   child: PageView.builder(
//                     itemCount: widget.imageList?.length,
//                     onPageChanged: (index) {
//                       setState(() {
//                         _currentIndex = index;
//                       });
//                     },
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _currentIndex = index;
//                           });
//                         },
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(15.0),
//                           child: CachedNetworkImage(
//                             imageUrl: widget.imageList?[index] ?? "",
//                             fit: BoxFit.fitHeight,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),
//               SizedBox(height: 10),
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             itemCount: widget.imageList?.length,
//             itemBuilder: (context, index) {
//               return GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _currentIndex = index;
//                   });
//                 },
//                 child: Container(
//                   margin: EdgeInsets.fromLTRB(0, 10, 10, screen_h * 0.005),
//                   child: Container(
//                     margin: EdgeInsets.symmetric(vertical: 5),
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: _currentIndex == index
//                             ? Colors.blue
//                             : Colors.transparent,
//                         width: 1.75,
//                         style: BorderStyle.solid,
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: SizedBox(
//                       height: screen_h * 0.25,
//                       width: screen_w * 0.1,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: CachedNetworkImage(
//                           imageUrl: widget.imageList?[index] ?? "",
//                           width: 80,
//                           height: 80,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: _buildDotIndicator(),
//         ),
//       ],
//     );
//   }

//   List<Widget> _buildDotIndicator() {
//     List<Widget> dots = [];
//     for (int i = 0; i < (widget.imageList?.length ?? 0); i++) {
//       dots.add(
//         Padding(
//           padding: const EdgeInsets.all(5.0),
//           child: GestureDetector(
//             onTap: () {
//               setState(() {
//                 _currentIndex = i;
//               });
//             },
//             child: Container(
//               width: 6,
//               height: 6,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: _currentIndex == i ? Colors.blueGrey : Colors.grey,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//     return dots;
//   }
// }
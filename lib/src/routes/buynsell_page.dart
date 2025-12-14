import 'package:InstiApp/src/api/model/buynsellPost.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/blocs/buynsell_post_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../api/model/user.dart';
import 'buynsell_info.dart';

import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import 'bnscreatepost.dart';
import 'package:InstiApp/src/utils/responsive.dart';
import 'package:InstiApp/src/widgets/custom_dialog.dart';

class BuySellPage extends StatefulWidget {
  const BuySellPage({super.key});

  @override
  State<BuySellPage> createState() => _BuySellPageState();
}

class _BuySellPageState extends State<BuySellPage> {
  int _currentFilter = 1; // 0 = All, 1 = Available, 2 = Sold
  int _currentTab = 0;
  String _searchQuery = '';

  late BuynSellPostBloc buynSellPostBloc;
  late InstiAppBloc bloc;
  User? profile;

  // Filter state
  Set<String>? _selectedCategories;
  bool? _isNegotiable;
  String? _sortBy = 'Recently Added';

  final List<String> _filterTabs = ['Sort', 'Filter'];
  int _selectedFilterTabIndex = 0;

  // void _onBookmarkPressed() {}
  // void _onBookmarkPost(String id, bool isBookmarked) {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = BlocProvider.of(context)!.bloc;
    buynSellPostBloc = bloc.buynSellPostBloc;
    profile = bloc.currSession?.profile;
    buynSellPostBloc.refresh();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = bloc.currSession != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: SafeArea(
          child: !isLoggedIn
              ? Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(RS.sw(context, 50)),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud,
                        size: RS.sw(context, 200),
                        color: Colors.grey[600],
                      ),
                      Text(
                        "Login To View Buy and Sell Posts",
                        textAlign: TextAlign.center,
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                )
              : Column(
                  children: [
                    SizedBox(height: RS.sh(context, 4)),
                    CustomAppBar(
                      title: _currentTab == 0 ? 'Buy & Sell' : 'Posted By You',
                      other: Icons.bookmark_border_rounded,
                      // onOther: _onBookmarkPressed,
                    ),
                    _buildSearchBar(),
                    _buildFilterChips(),
                    SizedBox(height: RS.sh(context, 16)),
                    Expanded(
                      child: StreamBuilder<List<BuynSellPost>>(
                        stream: buynSellPostBloc.buynsellposts,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
      
                          if (snapshot.hasError) {
                            return Center(child: Text('Error loading posts'));
                          }
      
                          final posts = snapshot.data ?? [];
      
                          List<BuynSellPost> filteredPosts = posts.where((post) {
                            // 1. Exclude deleted posts
                            if (post.deleted == true) return false;
      
                            // 2. Apply tab filter (My Posts)
                            if (_currentTab == 1) {
                              if (post.user?.userID != profile?.userID)
                                return false;
                            }
      
                            // 3. Apply availability filter
                            if (_currentFilter == 1 && (!post.status!) == true)
                              return false; // Available
                            if (_currentFilter == 2 && (!post.status!) == false)
                              return false; // Sold
      
                            // 4. Apply search filter
                            if (_searchQuery.isNotEmpty) {
                              final title = post.name?.toLowerCase() ?? '';
                              if (!title.contains(_searchQuery.toLowerCase()))
                                return false;
                            }
      
                            // 5. Apply category filter (updated for multiple selection)
                            if (_selectedCategories != null &&
                                _selectedCategories!.isNotEmpty) {
                              if (!_selectedCategories!.contains(post.category)) {
                                return false;
                              }
                            }
      
                            // 6. Apply negotiable filter
                            if (_isNegotiable != null &&
                                post.negotiable != _isNegotiable) {
                              return false;
                            }
      
                            return true;
                          }).toList();
      
                          // 7. Apply sorting
                          if (_sortBy == 'Price: Low to High') {
                            filteredPosts.sort(
                                (a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
                          } else if (_sortBy == 'Price: High to Low') {
                            filteredPosts.sort(
                                (a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
                          } else if (_sortBy == 'Recently Added') {
                            // Already sorted by server - no action needed
                          } else if (_sortBy == 'Oldest First') {
                            filteredPosts = filteredPosts.reversed.toList();
                          }
      
                          // Handle empty state
                          if (filteredPosts.isEmpty) {
                            String message = _currentTab == 1
                                ? "You haven't posted anything yet"
                                : "No posts available";
      
                            return Center(
                              child: Text(
                                message,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            );
                          }
      
                          return RefreshIndicator(
                            onRefresh: () async {
                              await buynSellPostBloc.refresh();
                            },
                            displacement: 40,
                            edgeOffset: 0,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredPosts.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: RS.sh(context, 16)),
                              itemBuilder: (context, index) =>
                                  _buildProductItem(filteredPosts[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildProductItem(BuynSellPost post) {
    final currentUser = bloc.currSession?.profile;
    final isCurrentUserPost =
        (_currentTab == 1 && post.user?.userID == currentUser?.userID);

    final isNegotiable = post.negotiable ?? false;
    final isSold = !post.status!;
    final isGiveaway = post.action == 'giveaway';

    void navigateToDetail() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuyAndSellInfoPage(
            postId: post.id!,
            initialPost: post,
            isMyPost: isCurrentUserPost ? true : false,
            // onBookmarkChanged: (id, isBookmarked) {
            //   _onBookmarkPost(id, isBookmarked);
            // },
          ),
        ),
      );
    }

    return Container(
      height: RS.sh(context, 254),
      padding: EdgeInsets.only(right: RS.sw(context, 16)),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(RS.s(context, 16)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              // Image Container
              Opacity(
                opacity: isSold && _currentFilter == 0 ? 0.6 : 1.0,
                child: GestureDetector(
                  onTap: navigateToDetail,
                  child: Container(
                    width: RS.sw(context, 154),
                    height: RS.sh(context, 254),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: post.imageUrl?.isNotEmpty == true
                            ? post.imageUrl![0]
                            : '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: Image.asset(
                            'assets/buynsell/DevcomLogo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Image.asset(
                            'assets/buynsell/DevcomLogo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bookmark Button
              // Positioned(
              //   top: 8,
              //   left: 8,
              //   child: Container(
              //     height: 32,
              //     width: 32,
              //     padding: EdgeInsets.zero,
              //     decoration: BoxDecoration(
              //       color: Colors.black45,
              //       shape: BoxShape.circle,
              //     ),
              //     child: IconButton(
              //         padding: EdgeInsets.zero,
              //         icon: Icon(
              //           Icons.bookmark_border,
              //           color: Colors.white,
              //           size: 20,
              //         ),
              //         onPressed: () {
              //           _onBookmarkPost(
              //               post.id ?? '1', post.isBookmarked ?? false);
              //         }),
              //   ),
              // ),

              // Edit/Delete Buttons (for user's posts)
              if (isCurrentUserPost && !isSold)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
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
                          icon: const Icon(
                            Icons.delete_outline_outlined,
                            size: 24,
                            color: Colors.red,
                          ),
                          onPressed: () => {_confirmDelete(post.id)},
                        ),
                        IconButton(
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 24,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            _navigateToEditPage(post);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              if (isCurrentUserPost && isSold)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
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
                          icon: const Icon(
                            Icons.delete_outline_outlined,
                            size: 24,
                            color: Colors.red,
                          ),
                          onPressed: () => {_confirmDelete(post.id)},
                        ),
                      ],
                    ),
                  ),
                ),

              // Mark as Sold Button
              if (isCurrentUserPost && !isSold)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color.fromRGBO(48, 111, 220, 1),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                                color: Color.fromRGBO(48, 111, 220, 1),
                                width: 2)),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    onPressed: () => _confirmMarkAsSold(post),
                    child: const Text('Mark Sold'),
                  ),
                ),

              // Sold Indicator
              if (isCurrentUserPost && isSold)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(239, 239, 239, 1),
                      border: Border.all(
                        color: Color.fromRGBO(126, 130, 135, 1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: Color.fromRGBO(126, 130, 135, 1),
                              size: 16),
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
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.name ?? "Untitled Item",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color.fromRGBO(41, 41, 41, 1)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isGiveaway ? "Free" : "₹${post.price ?? 0}",
                            style: const TextStyle(
                                fontSize: 24,
                                color: Color.fromRGBO(48, 111, 220, 1),
                                fontWeight: FontWeight.w700),
                          ),
                          if (post.originalPrice != null)
                            Text(
                              'Bought at ₹${post.originalPrice}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color.fromRGBO(126, 130, 135, 1)),
                            ),
                        ],
                      ),

                      // Condition Tag
                      isSold
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black),
                              ),
                              child: Text(
                                'Sold',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isGiveaway
                                      ? Color.fromRGBO(48, 111, 220, 1)
                                      : (isNegotiable
                                          ? const Color(0xFF67BC00)
                                          : Colors.red),
                                ),
                              ),
                              child: Text(
                                isGiveaway
                                    ? 'GiveAway'
                                    : (isNegotiable
                                        ? 'Negotiable'
                                        : 'Fixed Price'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isGiveaway
                                      ? Color.fromRGBO(48, 111, 220, 1)
                                      : (isNegotiable
                                          ? const Color(0xFF67BC00)
                                          : Colors.red),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.description ?? "No description",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color.fromRGBO(126, 130, 135, 1),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.timeBefore ?? "Recently",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromRGBO(126, 130, 135, 1)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Full-area InkWell for taps
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: navigateToDetail,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String? id) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Confirm Delete',
        content1: 'Are you sure you want to delete this post?',
        content2: 'This cannot be undone.',
        showLoadingState: true,
        loadingText: 'Deleting...',
        options: [
          DialogOption(
            text: 'Cancel',
            onPressed: (ctx, setProcessing) => Navigator.pop(ctx),
          ),
          DialogOption(
            text: 'Delete',
            onPressed: (ctx, setProcessing) async {
              try {
                await bloc.buynSellPostBloc.deleteBuynSellPost(id!);
                Navigator.pop(ctx);
                Navigator.pop(context); // Pop the original context
                await bloc.buynSellPostBloc.refresh();
              } catch (e) {
                setProcessing(false);
                // Handle error if needed
              } finally {
                bloc.buynSellPostBloc.refresh();
              }
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  void _confirmMarkAsSold(BuynSellPost post) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Mark as Sold',
        content1: 'Are you sure you want to mark this item as sold?',
        content2: '',
        showLoadingState: true,
        loadingText: 'Updating...',
        options: [
          DialogOption(
            text: 'Cancel',
            onPressed: (ctx, setProcessing) => Navigator.pop(ctx),
          ),
          DialogOption(
            text: 'Confirm',
            onPressed: (ctx, setProcessing) async {
              try {
                await bloc.buynSellPostBloc.markAsSold(post.id!);
                Navigator.pop(ctx);
                Navigator.pop(context); // Pop the original context
                await bloc.buynSellPostBloc.refresh();
              } catch (e) {
                setProcessing(false);
                // Handle error if needed
              } finally {
                bloc.buynSellPostBloc.refresh();
              }
            },
            isPrimary: true,
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
      await bloc.buynSellPostBloc.refresh();
    });
  }

  Widget _buildBottomNavBar() {
    return Container(
      alignment: Alignment.topCenter,
      height: RS.sh(context, 88),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/buynsell/bottomnavbar.png'),
            fit: BoxFit.cover,
          ),
          color: const Color(0xFF0F1620),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Row(
                children: [
                  _buildBottomNavButton(
                    Icons.groups_outlined,
                    _currentTab == 0,
                    () {
                      if (_currentTab == 0) return;
                      setState(() => _currentTab = 0);
                      buynSellPostBloc.refresh();
                    },
                  ),
                  _buildBottomNavButton(
                    Icons.person_outline,
                    _currentTab == 1,
                    () {
                      if (_currentTab == 1) return;
                      setState(() => _currentTab = 1);
                      buynSellPostBloc.refresh();
                    },
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PostItemFlow(),
                  ),
                ).then((_) async {
                  await buynSellPostBloc.refresh();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF306FDC),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Post Item',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavButton(
    IconData icon,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color:
            isActive ? const Color(0xFF306FDC) : Color.fromRGBO(21, 32, 46, 1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: RS.sh(context, 50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RS.s(context, 50)),
        image: DecorationImage(
          image: AssetImage("assets/buynsell/searchborder.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Center(
        child: Row(
          children: [
            const Icon(Icons.search, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: const InputDecoration.collapsed(
                  hintText: 'Search items...',
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'Filters',
              _isAnyFilterActive,
              icon: Icons.tune,
              icon2: Icons.keyboard_arrow_down_outlined,
              onTap: () {
                _openFilterBottomSheet();
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Available',
              _currentFilter == 1,
              onTap: () {
                setState(() => _currentFilter = 1);
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Sold',
              _currentFilter == 2,
              onTap: () {
                setState(() => _currentFilter = 2);
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'All',
              _currentFilter == 0,
              onTap: () {
                setState(() => _currentFilter = 0);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected, {
    IconData? icon,
    IconData? icon2,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: RS.sh(context, 36),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFF306FDC) : const Color(0xFFEFEFEF),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF306FDC)
                  : const Color(0xFFD2D5DA),
            ),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.black,
              ),
            if (icon != null) const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (icon2 != null)
              const SizedBox(
                width: 8,
              ),
            if (icon2 != null)
              Icon(
                icon2,
                size: 20,
                color: isSelected ? Colors.white : Colors.black,
              ),
          ],
        ),
      ),
    );
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(246, 246, 246, 1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(246, 246, 246, 1),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter By',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Navigation Rail
                        Container(
                          width: 100,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(246, 246, 246, 1),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(24)),
                          ),
                          child: Column(
                            children: [
                              ..._filterTabs.asMap().entries.map((entry) {
                                final index = entry.key;
                                final label = entry.value;
                                final isSelected =
                                    index == _selectedFilterTabIndex;

                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      _selectedFilterTabIndex = index;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 0),
                                    decoration: BoxDecoration(
                                      // 1. base color: white if not selected, grey if selected
                                      color: isSelected
                                          ? Color.fromRGBO(239, 239, 239, 1)
                                          : Color.fromRGBO(246, 246, 246, 1),
                                      // 2. gradient only on selected: blue line → grey
                                      gradient: isSelected
                                          ? const LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              stops: [
                                                0.0,
                                                0.05,
                                                0.06,
                                                0.7,
                                                0.99
                                              ],
                                              colors: [
                                                Color.fromRGBO(48, 111, 220, 1),
                                                Color.fromRGBO(48, 111, 220, 1),
                                                Color.fromRGBO(
                                                    48, 111, 220, 0.2),
                                                Color.fromRGBO(
                                                    239, 239, 239, 0.4),
                                                Color.fromRGBO(
                                                    239, 239, 239, 0.8)
                                              ],
                                            )
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        label,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),

                        // Content area
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(239, 239, 239, 1),
                              borderRadius: BorderRadius.only(
                                topLeft: _selectedFilterTabIndex == 0
                                    ? Radius.circular(0)
                                    : Radius.circular(24),
                                bottomLeft: Radius.circular(24),
                              ),
                            ),
                            child: _buildFilterTabPanel(setModalState),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Footer buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(246, 246, 246, 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Clear Filters Button
                        SizedBox(
                          width: RS.sw(context, 165),
                          height: RS.sh(context, 60),
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                _sortBy = 'Recently Added';
                                _selectedCategories = null;
                                _isNegotiable = null;
                              });
                              setState(() {});
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: EdgeInsets.zero, // ensure height fits
                            ),
                            child: const Text(
                              "Clear All",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),

                        // Apply Filters Button
                        SizedBox(
                          width: RS.sw(context, 165),
                          height: RS.sh(context, 60),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage(
                                      "assets/buynsell/filterbutton.png"),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: const Text(
                                  "Apply",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool get _isAnyFilterActive {
    return _sortBy != 'Recently Added' ||
        (_selectedCategories != null && _selectedCategories!.isNotEmpty) ||
        _isNegotiable != null;
  }

  Widget _buildFilterTabPanel(StateSetter setModalState) {
    switch (_filterTabs[_selectedFilterTabIndex]) {
      case 'Sort':
        return _buildSortPanel(setModalState);
      case 'Filter':
        return _buildFilterPanel(setModalState);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSortPanel(StateSetter setModalState) {
    return Theme(
      data: ThemeData.light(),
      child: RadioTheme(
        data: ThemeData.light().radioTheme.copyWith(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Color.fromRGBO(48, 111, 220, 1);
                }
                return null;
              }),
            ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildSortOption(
              'Recently Added',
              'Recently Added',
              setModalState,
              isDefault: true,
            ),
            _buildSortOption(
              'Oldest First',
              'Oldest First',
              setModalState,
            ),
            _buildSortOption(
              'Price: Low to High',
              'Price: Low to High',
              setModalState,
            ),
            _buildSortOption(
              'Price: High to Low',
              'Price: High to Low',
              setModalState,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel(StateSetter setModalState) {
    final categories = [
      'Gadgets',
      'Appliances',
      'Mattress',
      'Bicycle',
      'Tickets',
      'Academic',
      'Clothes',
      'Sports',
      'Furniture',
      'Others'
    ];

    return Theme(
      data: ThemeData.light(),
      child: RadioTheme(
        data: ThemeData.light().radioTheme.copyWith(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Color.fromRGBO(48, 111, 220, 1);
                }
                return null;
              }),
            ),
        child: CheckboxTheme(
          data: ThemeData.light().checkboxTheme.copyWith(
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Color.fromRGBO(48, 111, 220, 1);
                  }
                  return null;
                }),
                // side: const BorderSide(color: Colors.grey, width: 2),
              ),
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSectionTitle('By Category'),
                ...categories.map((category) =>
                    _buildCheckboxOption(category, setModalState)),
                const SizedBox(height: 16),
                _buildSectionTitle('By Negotiability'),
                _buildRadioOption('Yes', true, setModalState),
                _buildRadioOption('No', false, setModalState),
                _buildRadioOption('Any', null, setModalState, isDefault: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildRadioOption<T>(
    String title,
    bool? value,
    StateSetter setModalState, {
    bool isDefault = false,
  }) {
    return RadioListTile<bool?>(
      title: Text(
        title,
        style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Color.fromRGBO(15, 22, 32, 0.8),
            fontWeight: FontWeight.w500),
      ),
      value: value,
      groupValue: _isNegotiable,
      onChanged: (v) => setModalState(() {
        _isNegotiable = v;
      }),
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildSortOption(
    String title,
    String value,
    StateSetter setModalState, {
    bool isDefault = false,
  }) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          color: Color.fromRGBO(15, 22, 32, 0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
      value: value,
      groupValue: _sortBy ?? (isDefault ? value : null),
      onChanged: (v) => setModalState(() => _sortBy = v!),
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildCheckboxOption(String category, StateSetter setModalState) {
    final isSelected = _selectedCategories?.contains(category) ?? false;
    return CheckboxListTile(
      title: Text(
        category,
        style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Color.fromRGBO(15, 22, 32, 0.8),
            fontWeight: FontWeight.w500),
      ),
      value: isSelected,
      onChanged: (v) => setModalState(() {
        _selectedCategories ??= <String>{};
        v!
            ? _selectedCategories!.add(category)
            : _selectedCategories!.remove(category);
      }),
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
    );
  }
}

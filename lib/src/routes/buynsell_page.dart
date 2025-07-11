import 'package:InstiApp/src/api/model/buynsellPost.dart';
import 'package:InstiApp/src/bloc_provider.dart';
import 'package:InstiApp/src/blocs/ia_bloc.dart';
import 'package:InstiApp/src/blocs/buynsell_post_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/model/user.dart';
import 'buynsell_info.dart';

import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import 'bnscreatepost.dart';

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

  final List<String> _filterTabs = ['Sort', 'Category', 'Negotiable'];
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

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: !isLoggedIn
            ? Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(50),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud,
                      size: 200,
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
                  const SizedBox(height: 4),
                  CustomAppBar(
                    title: _currentTab == 0 ? 'Buy & Sell' : 'Posted By You',
                    other: Icons.bookmark_border_rounded,
                    // onOther: _onBookmarkPressed,
                  ),
                  _buildSearchBar(),
                  _buildFilterChips(),
                  const SizedBox(height: 16),
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
                                const SizedBox(height: 16),
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
    );
  }

  Widget _buildProductItem(BuynSellPost post) {
    final currentUser = bloc.currSession?.profile;
    final isCurrentUserPost =
        (_currentTab == 1 && post.user?.userID == currentUser?.userID);

    final isNegotiable = post.negotiable ?? false;
    final isSold = !post.status!;

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
      height: 254,
      padding: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(16),
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
                    width: 154,
                    height: 254,
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
                                fontSize: 16, fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.action == 'giveaway'
                                ? "Giveaway"
                                : "₹${post.price ?? 0}",
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
                                  fontWeight: FontWeight.w600,
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
                                  color: isNegotiable
                                      ? const Color(0xFF67BC00)
                                      : Colors.red,
                                ),
                              ),
                              child: Text(
                                isNegotiable ? 'Negotiable' : 'Fixed Price',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isNegotiable
                                      ? const Color(0xFF67BC00)
                                      : Colors.red,
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

  // Add these new methods for the additional functionality
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
              await bloc.buynSellPostBloc.deleteBuynSellPost(id!);
              Navigator.pop(context);
              await bloc.buynSellPostBloc.refresh();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
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
              await bloc.buynSellPostBloc.markAsSold(post.id!);
              Navigator.pop(context);
              await bloc.buynSellPostBloc.refresh();
            },
            child: const Text('Confirm'),
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
        color: isActive ? const Color(0xFF306FDC) : Colors.black,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFF1B3252), width: 1.5),
      ),
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
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
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
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
                            color: Colors.white,
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
                                        vertical: 18, horizontal: 0),
                                    decoration: BoxDecoration(
                                      // 1. base color: white if not selected, grey if selected
                                      color: isSelected
                                          ? Color.fromRGBO(239, 239, 239, 1)
                                          : Colors.white,
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
                                          fontWeight: FontWeight.w600,
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
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Clear Filters Button
                        SizedBox(
                          width: 165,
                          height: 60,
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
                          width: 165,
                          height: 60,
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
      case 'Category':
        return _buildCategoryPanel(setModalState);
      case 'Negotiable':
        return _buildNegotiablePanel(setModalState);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSortPanel(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sort By',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: [
              _buildSortOption(
                'Recently Added',
                'Recently Added',
                setModalState,
                isDefault: true,
              ),
              const SizedBox(height: 12),
              _buildSortOption(
                'Oldest First',
                'Oldest First',
                setModalState,
              ),
              const SizedBox(height: 12),
              _buildSortOption(
                'Price: Low to High',
                'Price: Low to High',
                setModalState,
              ),
              const SizedBox(height: 12),
              _buildSortOption(
                'Price: High to Low',
                'Price: High to Low',
                setModalState,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortOption(
    String title,
    String value,
    StateSetter setModalState, {
    bool isDefault = false,
  }) {
    final isSelected = _sortBy == value || (isDefault && _sortBy == null);
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F5FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF306FDC) : const Color(0xFFEEF2F6),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF306FDC) : Colors.black,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF306FDC))
            : null,
        onTap: () => setModalState(() => _sortBy = value),
      ),
    );
  }

  Widget _buildCategoryPanel(StateSetter setModalState) {
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
      'Others',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Categories',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Select one or more categories',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(3),
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected =
                      _selectedCategories?.contains(category) ?? false;

                  return Container(
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFF0F5FF) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF306FDC)
                            : const Color(0xFFEEF2F6),
                        width: 1.5,
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        category,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF306FDC)
                              : Colors.black,
                        ),
                      ),
                      value: isSelected,
                      onChanged: (value) {
                        setModalState(() {
                          _selectedCategories ??= <String>{};
                          if (value == true) {
                            _selectedCategories!.add(category);
                          } else {
                            _selectedCategories!.remove(category);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      activeColor: const Color(0xFF306FDC),
                      tileColor: Colors.transparent,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNegotiablePanel(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Product Price Negotiability',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Column(
            children: [
              _buildNegotiableOption('Yes', true, setModalState),
              const SizedBox(height: 12),
              _buildNegotiableOption('No', false, setModalState),
              const SizedBox(height: 12),
              _buildNegotiableOption('Any', null, setModalState),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNegotiableOption(
    String title,
    bool? value,
    StateSetter setModalState,
  ) {
    final isSelected = _isNegotiable == value;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F5FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF306FDC) : const Color(0xFFEEF2F6),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF306FDC) : Colors.black,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF306FDC))
            : null,
        onTap: () => setModalState(() => _isNegotiable = value),
      ),
    );
  }
}

// import 'package:InstiApp/src/api/model/buynsellPost.dart';
// import 'package:InstiApp/src/bloc_provider.dart';
// import 'package:InstiApp/src/blocs/buynsell_post_bloc.dart';
// import 'package:InstiApp/src/drawer.dart';
// import 'package:InstiApp/src/utils/common_widgets.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';

// import '../api/model/user.dart';
// import '../utils/title_with_backbutton.dart';

// class BuySellPage extends StatefulWidget {
//   BuySellPage({Key? key}) : super(key: key);
//   //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

//   @override
//   State<BuySellPage> createState() => _BuySellPageState();
// }

// class _BuySellPageState extends State<BuySellPage> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Sellpage(),
//     );
//   }
// }

// class Sellpage extends StatefulWidget {
//   const Sellpage({Key? key}) : super(key: key);

//   @override
//   State<Sellpage> createState() => _SellpageState();
// }

// class _SellpageState extends State<Sellpage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

//   BnSType bnstype = BnSType.All;
//   bool firstBuild = true;
//   bool MyPosts = false;

//   late double x;

//   @override
//   void initState() {
//     super.initState();
//   }

//   Widget build(BuildContext context) {
//     BuynSellPostBloc buynSellPostBloc =
//         BlocProvider.of(context)!.bloc.buynSellPostBloc;

//     User? profile = BlocProvider.of(context)!.bloc.currSession?.profile;
//     if (firstBuild) {
//       buynSellPostBloc.refresh();
//     }

//     double screen_wr = MediaQuery.of(context).size.width;
//     double screen_hr = MediaQuery.of(context).size.height;
//     double y;
//     var bloc = BlocProvider.of(context)!.bloc;
//     var theme = Theme.of(context);
//     bool isLoggedIn = bloc.currSession != null;

//     screen_hr >= screen_wr ? x = 0.35 : x = 0.80;
//     if (1 >= screen_hr / screen_wr && screen_hr / screen_wr >= 0.5) {
//       x = 0.35;
//     }
//     screen_hr >= screen_wr ? y = 0.9 : y = 0.5;
//     double screen_w = screen_wr * y;
//     double screen_h = 270;

//     double myfont = ((18 / 274.4) * screen_h);
//     return Scaffold(
//         key: _scaffoldKey,
//         drawer: NavDrawer(),
//         bottomNavigationBar: MyBottomAppBar(
//           shape: RoundedNotchedRectangle(),
//           notchMargin: 4.0,
//           child: new Row(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               IconButton(
//                 icon: Icon(
//                   Icons.menu_outlined,
//                   semanticLabel: "Show navigation drawer",
//                 ),
//                 onPressed: () {
//                   _scaffoldKey.currentState?.openDrawer();
//                 },
//               ),
//             ],
//           ),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
//         floatingActionButton: isLoggedIn
//             ? FloatingActionButton.extended(
//                 icon: Icon(Icons.add_outlined),
//                 label: Text("Add Item"),
//                 onPressed: () {
//                   Navigator.of(context).pushNamed("/buyandsell/category");
//                 },
//               )
//             : SizedBox(
//                 height: 0,
//                 width: 0,
//               ),
//         body: SafeArea(
//           child: !isLoggedIn
//               ? Container(
//                   alignment: Alignment.center,
//                   padding: EdgeInsets.all(50),
//                   child: Column(
//                     children: [
//                       Icon(
//                         Icons.cloud,
//                         size: 200,
//                         color: Colors.grey[600],
//                       ),
//                       Text(
//                         "Login To View Buy and Sell Posts",
//                         style: theme.textTheme.headlineSmall,
//                         textAlign: TextAlign.center,
//                       )
//                     ],
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                   ),
//                 )
//               : SingleChildScrollView(
//                   child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     TitleWithBackButton(
//                       child: Text(
//                         "Buy & Sell (Beta)",
//                         style: theme.textTheme.headlineMedium,
//                       ),
//                     ),
//                     Center(
//                         child: Column(
//                       children: [
//                         Row(children: [
//                           Expanded(
//                               child: Container(
//                             padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
//                             child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(15)), backgroundColor: theme.cardColor,
//                                     side: BorderSide(
//                                       width: 2,
//                                       color: MyPosts
//                                           ? theme.cardColor
//                                           : Colors.blue,
//                                     )),
//                                 // color: !MyPosts
//                                 //     ? theme.bottomAppBarColor
//                                 //     : theme.cardColor,
//                                 onPressed: () => {
//                                       setState(() {
//                                         MyPosts = false;
//                                       }),
//                                       buynSellPostBloc.refresh()
//                                     },
//                                 child: Text(
//                                   "All Posts",
//                                   style: theme.textTheme.titleLarge,
//                                 )),
//                           )),
//                           Expanded(
//                               child: Container(
//                             padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
//                             child: ElevatedButton(
//                               child: Text("Your Posts",
//                                   style: theme.textTheme.titleLarge),
//                               onPressed: () => {
//                                 setState(() {
//                                   MyPosts = true;
//                                 }),
//                                 buynSellPostBloc.refresh()
//                               },
//                               style: ElevatedButton.styleFrom(
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(15)), backgroundColor: theme.cardColor,
//                                   side: BorderSide(
//                                     width: 2,
//                                     color: !MyPosts
//                                         ? theme.cardColor
//                                         : Colors.blue,
//                                   )),
//                               // color: MyPosts
//                               //     ? theme.bottomAppBarColor
//                               //     : theme.cardColor,
//                             ),
//                           )),
//                         ]),
//                         StreamBuilder<List<BuynSellPost>>(
//                             stream: buynSellPostBloc.buynsellposts,
//                             builder: (BuildContext context,
//                                 AsyncSnapshot<List<BuynSellPost>> snapshot) {
//                               return ListView.builder(
//                                 primary: false,
//                                 shrinkWrap: true,
//                                 itemCount: MyPosts
//                                     ? (snapshot.hasData
//                                         ? snapshot.data!
//                                             .where((post) =>
//                                                 post.user?.userID ==
//                                                     profile?.userID &&
//                                                 post.deleted != true)
//                                             .length
//                                         : 0)
//                                     : (snapshot.hasData
//                                         ? snapshot.data!
//                                             .where(
//                                                 (post) => post.deleted != true)
//                                             .length
//                                         : 0),
//                                 itemBuilder: (_, index) {
//                                   if (!snapshot.hasData) {
//                                     return Center(
//                                         child:
//                                             CircularProgressIndicatorExtended(
//                                       label: Text("Loading..."),
//                                     ));
//                                   }
//                                   return _buildContent(screen_h, screen_w,
//                                       index, myfont, context, snapshot);
//                                 },
//                               );
//                             }),
//                       ],
//                     )),
//                   ],
//                 )),
//         ));
//   }

//   Widget _buildContent(double screen_h, double screen_w, int index,
//       double myfont, BuildContext context, AsyncSnapshot snapshot) {
//     List<BuynSellPost> posts = snapshot.data!;
//     var theme = Theme.of(context);
//     var bloc = BlocProvider.of(context)!.bloc;
//     User? profile = bloc.currSession?.profile;
//     if (MyPosts) {
//       posts = posts
//           .where((post) =>
//               post.user?.userID == profile?.userID && post.deleted != true)
//           .toList();
//     } else {
//       posts = snapshot.data;
//       posts = posts.where((post) => post.deleted != true).toList();
//     }

//     return Center(
//       child: (SizedBox(
//         height: screen_h * 0.7,
//         width: screen_w * 1.2,
//         child: Card(
//           color: theme.cardColor,
//           margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
//           child: InkWell(
//             onTap: () {
//               Navigator.of(context)
//                   .pushNamed("/buyandsell/info" + (posts[index].id ?? ""));
//             },
//             child: SizedBox(
//                 child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.only(
//                       topRight: Radius.circular(10),
//                       topLeft: Radius.circular(10)),
//                   child: Row(
//                     children: [
//                       Center(
//                         child: Container(
//                           padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
//                           height: screen_h,
//                           width: screen_h * 0.20 / 0.43,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.only(
//                                 topRight: Radius.circular(10),
//                                 bottomLeft: Radius.circular(10)),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(10),
//                                 topLeft: Radius.circular(10)),
//                             child: CachedNetworkImage(
//                               imageUrl: posts[index].imageUrl?[0] ?? '',
//                               placeholder: (context, url) => Image.asset(
//                                 'assets/buynsell/DevcomLogo.png',
//                                 fit: BoxFit.fill,
//                               ),
//                               errorWidget: (context, url, error) =>
//                                   new Image.asset(
//                                 'assets/buynsell/DevcomLogo.png',
//                                 fit: BoxFit.fill,
//                               ),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
//                   margin:
//                       EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 11, 0, 50),
//                   child: Text(
//                     posts[index].name ?? "",
//                     style: theme.textTheme.titleLarge,
//                     //style: TextStyle(
//                     //     fontSize: (myfont.toInt()).toDouble(),
//                     //     fontWeight: FontWeight.w600),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//                 Container(
//                   margin:
//                       EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 105, 10, 0),
//                   child: Text(
//                     (posts[index].brand ?? "").length <= 10
//                         ? posts[index].brand ?? ""
//                         : (posts[index].brand ?? "").substring(0, 10) + '...',
//                     style: theme.textTheme.bodyMedium,
//                     maxLines: 1,
//                   ),
//                 ),
//                 Container(
//                     margin: EdgeInsets.fromLTRB(
//                         screen_w * 0.7, 110, screen_h * 0.04 / 1.5, 1),
//                     child: MyPosts
//                         ? ClipRRect(
//                             borderRadius: BorderRadius.circular(5),
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                               ),
//                               onPressed: () {
//                                 showDialog(
//                                   context: context,
//                                   builder: (ctx) => AlertDialog(
//                                     title: const Text("Delete Item"),
//                                     content: const Text(
//                                         "Are you sure you want to delete this item?"),
//                                     actions: <Widget>[
//                                       TextButton(
//                                         onPressed: () {
//                                           posts[index].deleted = true;
//                                           bloc.buynSellPostBloc
//                                               .updateBuynSellPost(posts[index]);
//                                           Navigator.of(ctx).pop();
//                                           bloc.buynSellPostBloc.refresh();
//                                         },
//                                         child: Text("Delete",
//                                             maxLines: 1,
//                                             style: TextStyle(
//                                                 fontSize:
//                                                     12.5 / 338 * screen_w)),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                               child: Text("Delete",
//                                   maxLines: 1,
//                                   style: TextStyle(
//                                       fontSize: 12.5 / 338 * screen_w)),
//                             ))
//                         : Row(
//                             children: [
//                               Spacer(),
//                               Text(
//                                 (posts[index].action == 'giveaway'
//                                     ? "GiveAway"
//                                     : "₹" +
//                                         (posts[index].price ?? 0).toString()),
//                                 style: theme.textTheme.bodyLarge,

//                                 // style:
//                                 //     TextStyle(fontSize: w, fontWeight: FontWeight.w800),
//                               )
//                             ],
//                           )),
//                 Container(
//                   child: MyPosts
//                       ? Container()
//                       : Row(
//                           children: [
//                             Icon(
//                               Icons.access_time,
//                               size: ((myfont / 18 * 12).toInt()).toDouble(),
//                             ),
//                             Text(' ' + (posts[index].timeBefore ?? ""),
//                                 style: theme.textTheme.bodyLarge!.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 )
//                                 //theme.textTheme.labelSmall
//                                 // style: TextStyle(
//                                 //     fontWeight: FontWeight.w600,
//                                 //     fontSize: ((myfont / 19 * 12).toInt()).toDouble()),
//                                 ),
//                           ],
//                         ),
//                   margin:
//                       EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 135, 0, 0),
//                 ),
//                 Container(
//                     child: Text(
//                       "Condition: " + (posts[index].condition ?? "") + "/10",
//                       style: //TextStyle(
//                           theme.textTheme.bodyMedium,
//                       // fontSize: ((myfont / 18 * 12).toInt()).toDouble()),
//                     ),
//                     margin:
//                         EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 35, 0, 0)),
//                 Container(
//                     padding: EdgeInsets.fromLTRB(0, 13, 10, 0),
//                     child: Text(
//                       (posts[index].description ?? ""), maxLines: 2,

//                       overflow: TextOverflow.ellipsis,
//                       style: theme.textTheme.bodyMedium,
//                       // style: TextStyle(
//                       //     fontWeight: FontWeight.w500,
//                       //     fontSize: ((myfont / 16 * 12).toInt()).toDouble()),
//                     ),
//                     margin:
//                         EdgeInsets.fromLTRB(screen_h * 0.20 / 0.43, 43, 0, 0)),
//                 Row(
//                   children: [
//                     Spacer(),
//                     Container(),
//                   ],
//                 )
//               ],
//             )),
//           ),
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//             side: BorderSide(color: Colors.blue),
//           ),
//         ),
//       )),
//     );
//   }
// }

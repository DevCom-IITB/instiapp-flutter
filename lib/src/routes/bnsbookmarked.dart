import 'package:flutter/material.dart';
import '../widgets/appbar.dart';

class SavedPostsPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(String id, bool isBookmarked) onBookmarkChanged;

  const SavedPostsPage({
    super.key,
    required this.items,
    required this.onBookmarkChanged,
  });

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  String _searchQuery = '';
  int _currentFilter = 0; // 0 = All, 1 = Available, 2 = Sold

  // Filter state
  String? _selectedCategory;
  bool? _isNegotiable;
  String? _sortBy;
  final List<String> _filterTabs = ['Sort', 'Category', 'Negotiable'];
  int _selectedFilterTabIndex = 0;

  late List<Map<String, dynamic>> _displayedItems;

  @override
  void initState() {
    super.initState();
    _updateDisplayedItems();
  }

  void _updateDisplayedItems() {
    setState(() {
      _displayedItems =
          widget.items.where((item) {
            if (!item['isBookmarked']) return false;
            if (_currentFilter == 1 && item['sold'] != false) return false;
            if (_currentFilter == 2 && item['sold'] != true) return false;
            if (_searchQuery.isNotEmpty &&
                !item['title'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                )) {
              return false;
            }
            if (_selectedCategory != null &&
                item['category'] != _selectedCategory)
              return false;
            if (_isNegotiable != null && item['isNegotiable'] != _isNegotiable)
              return false;
            return true;
          }).toList()..sort((a, b) {
            if (_sortBy == 'Price: Low to High') {
              return a['price'].compareTo(b['price']);
            } else if (_sortBy == 'Price: High to Low') {
              return b['price'].compareTo(a['price']);
            }
            return 0;
          });
    });
  }

  String _formatTimeDifference(DateTime postedAt) {
    final now = DateTime.now();
    final difference = now.difference(postedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            CustomAppBar(title: 'Saved Posts'),
            _buildSearchBar(),
            _buildFilterChips(),
            const SizedBox(height: 16),
            Expanded(
              child: _displayedItems.isEmpty
                  ? const Center(child: Text('No saved posts'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _displayedItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          _buildProductItem(_displayedItems[index]),
                    ),
            ),
          ],
        ),
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
                hintText: 'Search saved items...',
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _updateDisplayedItems();
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
              false,
              icon: Icons.tune,
              onTap: () {
                _openFilterBottomSheet();
                _updateDisplayedItems();
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Available',
              _currentFilter == 1,
              onTap: () {
                setState(() => _currentFilter = 1);
                _updateDisplayedItems();
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Sold',
              _currentFilter == 2,
              onTap: () {
                setState(() => _currentFilter = 2);
                _updateDisplayedItems();
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'All',
              _currentFilter == 0,
              onTap: () {
                setState(() => _currentFilter = 0);
                _updateDisplayedItems();
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

  Widget _buildProductItem(Map<String, dynamic> item) {
    return Opacity(
      opacity: item['sold'] && _currentFilter == 0 ? 0.7 : 1.0,
      child: Container(
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
                Container(
                  width: 154,
                  height: 254,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    image: const DecorationImage(
                      image: NetworkImage("https://picsum.photos/154/254"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    height: 32,
                    width: 32,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        item['isBookmarked']
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        final newStatus = !item['isBookmarked'];
                        widget.onBookmarkChanged(item['id'], newStatus);

                        setState(() {
                          item['isBookmarked'] = newStatus;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${item['price']}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF306FDC),
                          ),
                        ),
                        Text('Bought at ₹${item['originalPrice']}'),
                      ],
                    ),
                    item['sold']
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
                                fontSize: 16,
                                color: Colors.black,
                              ),
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
                                color: item['isNegotiable']
                                    ? const Color(0xFF67BC00)
                                    : Colors.red,
                              ),
                            ),
                            child: Text(
                              item['isNegotiable']
                                  ? 'Negotiable'
                                  : 'Fixed Price',
                              style: TextStyle(
                                fontSize: 12,
                                color: item['isNegotiable']
                                    ? const Color(0xFF67BC00)
                                    : Colors.red,
                              ),
                            ),
                          ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['description'],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14),
                            const SizedBox(width: 4),
                            Text(_formatTimeDifference(item['postedAt'])),
                          ],
                        ),
                      ],
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

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 608,
              child: Column(
                children: [
                  Container(
                    height: 520,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        NavigationRail(
                          selectedIndex: _selectedFilterTabIndex,
                          onDestinationSelected: (index) {
                            setModalState(() {
                              _selectedFilterTabIndex = index;
                            });
                          },
                          labelType: NavigationRailLabelType.all,
                          destinations: _filterTabs
                              .map(
                                (e) => NavigationRailDestination(
                                  icon: const Icon(Icons.filter_alt),
                                  label: Text(e),
                                ),
                              )
                              .toList(),
                        ),
                        const VerticalDivider(),
                        Expanded(child: _buildFilterTabPanel(setModalState)),
                      ],
                    ),
                  ),
                  Divider(height: 2),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setModalState(() {
                            _sortBy = null;
                            _selectedCategory = null;
                            _isNegotiable = null;
                          });
                          setState(() {});
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                        ),
                        child: const Text(
                          "Clear Filters",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text("Apply Filters"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterTabPanel(StateSetter setModalState) {
    switch (_filterTabs[_selectedFilterTabIndex]) {
      case 'Sort':
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    RadioListTile<String?>(
                      title: const Text('Price: Low to High'),
                      value: 'Price: Low to High',
                      groupValue: _sortBy,
                      onChanged: (value) =>
                          setModalState(() => _sortBy = value),
                    ),
                    RadioListTile<String?>(
                      title: const Text('Price: High to Low'),
                      value: 'Price: High to Low',
                      groupValue: _sortBy,
                      onChanged: (value) =>
                          setModalState(() => _sortBy = value),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 'Category':
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
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...categories.map(
                      (cat) => RadioListTile<String?>(
                        title: Text(cat),
                        value: cat,
                        groupValue: _selectedCategory,
                        onChanged: (value) =>
                            setModalState(() => _selectedCategory = value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 'Negotiable':
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    RadioListTile<bool?>(
                      title: const Text("Yes"),
                      value: true,
                      groupValue: _isNegotiable,
                      onChanged: (value) =>
                          setModalState(() => _isNegotiable = value),
                    ),
                    RadioListTile<bool?>(
                      title: const Text("No"),
                      value: false,
                      groupValue: _isNegotiable,
                      onChanged: (value) =>
                          setModalState(() => _isNegotiable = value),
                    ),
                    RadioListTile<bool?>(
                      title: const Text("Any"),
                      value: null,
                      groupValue: _isNegotiable,
                      onChanged: (value) =>
                          setModalState(() => _isNegotiable = value),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }
}

import 'dart:io';
import 'package:InstiApp/src/api/model/buynsellPost.dart';
import 'package:InstiApp/src/api/model/user.dart';
import '../bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/appbar.dart';
import '../widgets/dotted_divider.dart';
import '../widgets/buttons.dart';

class PostItemFlow extends StatefulWidget {
  const PostItemFlow({super.key});

  @override
  State<PostItemFlow> createState() => _PostItemFlowState();
}

class _PostItemFlowState extends State<PostItemFlow> {
  int _currentStep = 0;
  final List<XFile> _images = [];
  String? _selectedCategory;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _boughtPriceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  bool _isNegotiable = true;
  bool _isGiveAway = false;

  BuynSellPost bnsPost = BuynSellPost();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Gadgets', 'icon': 'assets/categories/gadgets.png'},
    {'name': 'Appliances', 'icon': 'assets/categories/appliances.png'},
    {'name': 'Mattress', 'icon': 'assets/categories/mattress.png'},
    {'name': 'Bicycle', 'icon': 'assets/categories/bicycle.png'},
    {'name': 'Tickets', 'icon': 'assets/categories/tickets.png'},
    {'name': 'Academic', 'icon': 'assets/categories/academic.png'},
    {'name': 'Clothes', 'icon': 'assets/categories/clothes.png'},
    {'name': 'Sports', 'icon': 'assets/categories/sports.png'},
    {'name': 'Furniture', 'icon': 'assets/categories/furniture.png'},
    {'name': 'Others', 'icon': 'assets/categories/other.png'},
  ];

  void _nextStep() {
    setState(() => _currentStep++);
  }

  void _prevStep() {
    setState(() => _currentStep--);
  }

  @override
  void initState() {
    super.initState();
    bnsPost.warranty = false;
    bnsPost.negotiable = false;
    bnsPost.packaging = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            CustomAppBar(
              title: 'Create Post',
              onBack: _confirmExit,
              onOther: null,
            ),
            _buildProgressIndicator(),
            _defaultDetails(),
            const DottedDivider(),
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildImageUploadPage(),
                  _buildCategoryPage(),
                  _buildDetailsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Post?'),
        content: const Text(
          'All your progress will be lost. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (shouldExit == true) {
      Navigator.pop(context);
    }
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressStep(0, "Images"),
          _buildProgressLine(0),
          _buildProgressStep(1, "Category"),
          _buildProgressLine(1),
          _buildProgressStep(2, "Details"),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label) {
    if (_currentStep > step) {
      return Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF306FDC),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check, color: Colors.white, size: 20),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Color(0xFF306FDC), fontSize: 14)),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _currentStep == step
                    ? Color(0xFF306FDC)
                    : Colors.grey[400]!,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '0${step + 1}',
              style: TextStyle(
                color: _currentStep == step
                    ? Color(0xFF306FDC)
                    : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _currentStep >= step
                  ? Color(0xFF306FDC)
                  : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildProgressLine(int step) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          height: 2,
          color: _currentStep > step ? Color(0xFF306FDC) : Colors.grey[300],
        ),
      ),
    );
  }

  Widget _defaultDetails() {
    return Container(
      // padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      height: 58,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility_outlined, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Your Name and LDAP will be visible by default',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadPage() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Add Product Images',
              style: TextStyle(
                color: Color(0xFF306FDC),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Camera Button
              SizedBox(
                width: 185,
                height: 80,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey[200], // Greyish white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    side: const BorderSide(color: Colors.grey), // Light border
                  ),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (image != null) {
                      setState(() => _images.add(image));
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Take',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            'Image',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),

              // Upload Button
              SizedBox(
                width: 185,
                height: 80,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey[200], // Greyish white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    side: const BorderSide(color: Colors.grey), // Light border
                  ),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final images = await picker.pickMultiImage();
                    setState(() => _images.addAll(images));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Upload',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          Text(
                            'Image',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                      const Icon(Icons.upload, size: 48, color: Colors.blue),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_images.isNotEmpty)
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_images[index].path),
                            width: 160,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Remove Image'),
                                  content: const Text(
                                    'Are you sure you want to remove this image?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                setState(() => _images.removeAt(index));
                              }
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(255, 255, 255, 0.6),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              const SizedBox(width: 16),
              Expanded(
                child: DecoratedButton(
                  text: 'Continue',
                  onPressed: _images.isNotEmpty ? _nextStep : null,
                  backgroundColor: const Color(0xFF0F1620),
                  textColor: Colors.white,
                  backgroundImageAsset: 'assets/buynsell/button_bg.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPage() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Select Item Category',
            style: TextStyle(
              color: Color(0xFF306FDC),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.25,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category['name'];

              return InkWell(
                onTap: () {
                  setState(() => _selectedCategory = category['name']);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ), // Your control
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        category['icon'],
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          category['name'],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DecoratedButton(
                  text: 'Back',
                  onPressed: _prevStep,
                  backgroundColor: const Color(0xFF0F1620),
                  textColor: Colors.white,
                  backgroundImageAsset: 'assets/buynsell/button_bg.png',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DecoratedButton(
                  text: 'Continue',
                  onPressed: _selectedCategory != null ? _nextStep : null,
                  backgroundColor: const Color(0xFF0F1620),
                  textColor: Colors.white,
                  backgroundImageAsset: 'assets/buynsell/button_bg.png',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add Item Details',
                  style: TextStyle(
                    color: Color(0xFF306FDC),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Images preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (_images.isNotEmpty) _buildImagePreview(0),
                      if (_images.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: _buildImagePreview(1),
                        ),
                      if (_images.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('All Images'),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                      itemCount: _images.length,
                                      itemBuilder: (context, index) {
                                        return Stack(
                                          children: [
                                            Image.file(
                                              File(_images[index].path),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(
                                                    () =>
                                                        _images.removeAt(index),
                                                  );
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 230, 230, 230),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '+${_images.length - 2}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Selected category
                  if (_selectedCategory != null)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 230, 230, 230),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Image.asset(
                          _categories.firstWhere(
                            (c) => c['name'] == _selectedCategory,
                          )['icon'],
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // Form fields

              // Title
              RichText(
                text: const TextSpan(
                  text: 'Title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  hintText: 'Enter item name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price and Bought At
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Price',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _isGiveAway ? _buildGiveAwayDisplay() :
                        TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            hintText: 'Enter Price',
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                left: 8,
                              ), // optional: aligns with text vertically
                              child: Text(
                                '₹',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black, // or grey
                                ),
                              ),
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Bought at',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _boughtPriceController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            hintText: 'Enter Price',
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                left: 8,
                              ), // optional: aligns with text vertically
                              child: Text(
                                '₹',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black, // or grey
                                ),
                              ),
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Price Type (ChoiceChips)
              if (!_isGiveAway)
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Negotiable'),
                    selected: _isNegotiable,
                    onSelected: (selected) {
                      setState(() => _isNegotiable = true);
                    },
                    selectedColor: Color(0xFF306FDC),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: _isNegotiable ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    checkmarkColor: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Fixed'),
                    selected: !_isNegotiable,
                    onSelected: (selected) {
                      setState(() => _isNegotiable = false);
                    },
                    selectedColor: Color(0xFF306FDC),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: !_isNegotiable ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    checkmarkColor: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Give Away'),
                    selected: _isGiveAway,
                    onSelected: (selected) {
                      setState(() {
                        _isGiveAway = true;
                        _priceController.text = '0';
                      });
                    },
                    selectedColor: Colors.green[200],
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: _isGiveAway ? Colors.green : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    checkmarkColor: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              RichText(
                text: const TextSpan(
                  text: 'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                buildCounter:
                    (
                      BuildContext context, {
                      required int currentLength,
                      required bool isFocused,
                      required int? maxLength,
                    }) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Character Limit',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '$currentLength/$maxLength',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: 'Enter Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                maxLength: 250,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mobile Number
              RichText(
                text: const TextSpan(
                  text: '10-Digit Mobile Number',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: 'Enter your mobile number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your mobile number';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: DecoratedButton(
                      text: 'Back',
                      onPressed: _prevStep,
                      backgroundColor: const Color(0xFF0F1620),
                      textColor: Colors.white,
                      backgroundImageAsset: 'assets/buynsell/button_bg.png',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DecoratedButton(
                      text: 'Post',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Save the post data
                          final postData = {
                            'images': _images.map((img) => img.path).toList(),
                            'category': _selectedCategory,
                            'title': _titleController.text,
                            'price': _isGiveAway ? 0.0 : double.parse(_priceController.text),
                            'isGiveAway': _isGiveAway,
                            'isNegotiable': _isGiveAway ? false : _isNegotiable,
                            'originalPrice': _boughtPriceController.text.isNotEmpty
                                ? double.parse(_boughtPriceController.text)
                                : null,
                            'description': _descController.text,
                            'mobile': _mobileController.text,
                          };
                          print('Post data: $postData');
                          // Here you would typically:
                          // 1. Upload images to storage
                          // 2. Save post data to database
                          // 3. Navigate to success screen or back to home
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item posted successfully!'),
                            ),
                          );
                          Navigator.pop(context); // Return to previous screen
                        }
                      },
                      backgroundColor: const Color(0xFF0F1620),
                      textColor: Colors.white,
                      backgroundImageAsset: 'assets/buynsell/button_bg.png',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(_images[index].path),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () async {
              final confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Remove Image'),
                  content: const Text(
                    'Are you sure you want to remove this image?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                setState(() => _images.removeAt(index));
              }
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGiveAwayDisplay() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Give Away',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isGiveAway = false;
                  _priceController.text = '';
                  _isNegotiable = true; // Reset to negotiable
                });
              },
              child: Icon(Icons.close, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

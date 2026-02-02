import 'dart:io';
import 'package:InstiApp/src/api/model/buynsellPost.dart';
import 'package:InstiApp/src/api/response/image_upload_response.dart';
import '../bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/appbar.dart';
import '../widgets/dotted_divider.dart';
import '../widgets/buttons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:InstiApp/src/utils/responsive.dart';
import 'package:InstiApp/src/widgets/custom_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PostItemFlow extends StatefulWidget {
  final bool isEditable;
  final BuynSellPost? existingPost;
  const PostItemFlow({
    super.key,
    this.isEditable = false,
    this.existingPost,
  });

  @override
  State<PostItemFlow> createState() => _PostItemFlowState();
}

class _PostItemFlowState extends State<PostItemFlow> {
  late bool _isEditMode;
  List<String> _existingImageUrls = [];

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
  bool isPosting = false;

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

  /// Compress image to 60% quality
  Future<File> _compressImage(File imageFile) async {
    final String targetPath = imageFile.absolute.path.replaceAll(
      RegExp(r'\.(?=jpg|jpeg|png|gif|bmp)'),
      '_compressed.',
    );
    
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 60, // 60% quality
      format: CompressFormat.jpeg,
    );

    if (result != null) {
      return File(result.path);
    }
    return imageFile; // Return original if compression fails
  }

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.isEditable;

    if (_isEditMode && widget.existingPost != null) {
      final post = widget.existingPost!;

      _titleController.text = post.name ?? '';
      _priceController.text = post.price?.toString() ?? '';
      _boughtPriceController.text = post.originalPrice?.toString() ?? '';
      _descController.text = post.description ?? '';
      _mobileController.text = post.contactDetails ?? '';
      _isNegotiable = post.negotiable ?? false;
      _isGiveAway = post.action == 'giveaway';
      _selectedCategory = post.category ?? 'Others';
      // Check if category exists in frontend list
      final categoryExists =
          _categories.any((c) => c['name'] == _selectedCategory);

      // Fallback to 'Others' if not found
      if (!categoryExists) {
        _selectedCategory = 'Others';
      }

      _existingImageUrls = List.from(post.imageUrl ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            CustomAppBar(
              title: _isEditMode ? 'Edit Post' : 'Create Post',
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
      builder: (context) => CustomDialog(
        title: 'Discard Changes',
        content1: 'Are you sure you want to discard changes?',
        content2: 'This cannot be undone.',
        imageAssetPath: 'assets/buynsell/discard.png',
        options: [
          DialogOption(
            text: 'Cancel',
            onPressed: (ctx, setProcessing) => Navigator.pop(ctx, false),
          ),
          DialogOption(
            text: 'Discard',
            onPressed: (ctx, setProcessing) => Navigator.pop(ctx, true),
            isPrimary: true,
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
      padding: EdgeInsets.symmetric(vertical: RS.sh(context, 16), horizontal: 16),
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
            width: RS.s(context, 32),
            height: RS.s(context, 32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF306FDC),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check, color: Colors.white, size: RS.s(context, 20)),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Color(0xFF306FDC), fontSize: RS.sp(context, 14))),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            width: RS.s(context, 32),
            height: RS.s(context, 32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _currentStep == step
                    ? Color(0xFF306FDC)
                    : Color.fromRGBO(126, 130, 135, 1),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '0${step + 1}',
              style: TextStyle(
                color: _currentStep == step
                    ? Color(0xFF306FDC)
                    : Color.fromRGBO(126, 130, 135, 1),
                fontSize: RS.sp(context, 14),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _currentStep >= step
                  ? Color(0xFF306FDC)
                  : Color.fromRGBO(126, 130, 135, 1),
              fontSize: RS.sp(context, 14),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildProgressLine(int step) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(top: RS.sh(context, 16)),
        child: Container(
          height: 2,
          color: _currentStep > step
              ? Color(0xFF306FDC)
              : Color.fromRGBO(126, 130, 135, 1),
        ),
      ),
    );
  }

  Widget _defaultDetails() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, RS.sh(context, 4), 16, RS.sh(context, 16)),
      height: RS.sh(context, 58),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(210, 213, 218, 1), width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_outlined,
            size: RS.s(context, 20),
            color: Color.fromRGBO(27, 50, 82, 1),
          ),
          const SizedBox(width: 8),
          Text(
            'Your Name and LDAP will be visible by default',
            style:
                TextStyle(fontSize: RS.sp(context, 14), color: Color.fromRGBO(27, 50, 82, 1)),
          ),
        ],
      ),
    );
  }

  Widget _buttonContent({
    required String title1,
    required String title2,
    required String asset,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title1,
              style: TextStyle(
                fontSize: RS.sp(context, 14),
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(15, 22, 32, 0.8),
              ),
            ),
            Text(
              title2,
              style: TextStyle(
                fontSize: RS.sp(context, 14),
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(15, 22, 32, 0.8),
              ),
            ),
          ],
        ),
        Image.asset(
          asset,
          width: RS.sw(context, 42),
          height: RS.sh(context, 36),
        ),
      ],
    );
  }

  Widget _buildImageUploadPage() {
    final totalImages = _existingImageUrls.length + _images.length;

    return Container(
      padding: EdgeInsets.fromLTRB(16, RS.sh(context, 20), 16, RS.sh(context, 16)),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(bottom: RS.sh(context, 8)),
            child: Text(
              'Add Product Images',
              style: TextStyle(
                color: Color(0xFF306FDC),
                fontSize: RS.sp(context, 20),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Row(
            children: [
              // Camera Button
              Expanded(
                child: SizedBox(
                  height: RS.sh(context, 80),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(239, 239, 239, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      side: BorderSide.none,
                    ),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final image =
                          await picker.pickImage(source: ImageSource.camera);

                      if (image != null) {
                        await Future.delayed(const Duration(milliseconds: 100));

                        final file = File(image.path);
                        if (await file.exists()) {
                          final appDir =
                              await getApplicationDocumentsDirectory();
                          final fileName = path.basename(image.path);

                          final imagesDir =
                              Directory('${appDir.path}/user_images');
                          if (!await imagesDir.exists()) {
                            await imagesDir.create(recursive: true);
                          }

                          // Compress the image to 50% quality
                          File compressedFile = await _compressImage(file);
                          final savedFile = await compressedFile
                              .copy('${imagesDir.path}/$fileName');

                          setState(() => _images.add(XFile(savedFile.path)));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Could not access the captured image."),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    child: _buttonContent(
                      title1: 'Take',
                      title2: 'Image',
                      asset: 'assets/buynsell/Camera.png',
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Upload Button
              Expanded(
                child: SizedBox(
                  height: RS.sh(context, 80),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(239, 239, 239, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      side: BorderSide.none,
                    ),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedImages = await picker.pickMultiImage();

                      if (pickedImages.isNotEmpty) {
                        final validImages = <XFile>[];
                        int skipped = 0;

                        final appDir =
                            await getApplicationDocumentsDirectory();
                        final imagesDir =
                            Directory('${appDir.path}/user_images');

                        if (!await imagesDir.exists()) {
                          await imagesDir.create(recursive: true);
                        }

                        for (final image in pickedImages) {
                          final file = File(image.path);
                          if (await file.exists()) {
                            final fileName =
                                path.basename(image.path);
                            // Compress the image to 50% quality
                            File compressedFile = await _compressImage(file);
                            final savedFile = await compressedFile.copy(
                                '${imagesDir.path}/$fileName');
                            validImages.add(XFile(savedFile.path));
                          } else {
                            skipped++;
                          }
                        }

                        if (validImages.isNotEmpty) {
                          setState(() => _images.addAll(validImages));
                        }

                        if (skipped > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Skipped $skipped image(s) that could not be loaded."),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    child: _buttonContent(
                      title1: 'Upload',
                      title2: 'Image',
                      asset: 'assets/buynsell/Upload.png',
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: RS.sh(context, 20)),
          if (totalImages > 0)
            SizedBox(
              height: RS.sh(context, 220),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: totalImages,
                itemBuilder: (context, index) {
                  if (index < _existingImageUrls.length) {
                    return _buildExistingImageItem(index, totalImages);
                  } else {
                    return _buildNewImageItem(
                        index - _existingImageUrls.length, totalImages);
                  }
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
                  onPressed: totalImages > 0 ? _nextStep : null,
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

  // Builds an item for existing image (from server)
  Widget _buildExistingImageItem(int index, int totalImages) {
    final isFirst = index == 0;
    final isLast = index == totalImages - 1;

    return Padding(
      padding: EdgeInsets.only(
        left: isFirst ? 0 : 8,
        right: isLast ? 0 : 8,
      ),
      child: Stack(
        children: [
          // Network image for existing URLs
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              _existingImageUrls[index],
              width: RS.sw(context, 160),
              height: RS.sh(context, 200),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                return progress == null
                    ? child
                    : Container(
                        width: RS.sw(context, 160),
                        height: RS.sh(context, 200),
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: RS.sw(context, 160),
                  height: RS.sh(context, 200),
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 50),
                );
              },
            ),
          ),
          // Remove button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removeExistingImage(index),
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
  }

  // Builds an item for newly added image (from device)
  Widget _buildNewImageItem(int index, int totalImages) {
    final isFirst = index == 0;
    final isLast = index == totalImages - 1;

    return Padding(
      padding: EdgeInsets.only(
        left: isFirst ? 0 : 8,
        right: isLast ? 0 : 8,
      ),
      child: Stack(
        children: [
          // File image for new selections
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(_images[index].path),
              width: RS.sw(context, 160),
              height: RS.sh(context, 200),
              fit: BoxFit.cover,
            ),
          ),
          // Remove button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removeNewImage(index),
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
  }

  // Handles removal of existing images (from server)
  Future<void> _removeExistingImage(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Remove Image',
        content1: 'Are you sure you want to remove this image?',
        content2: 'This cannot be undone.',
        // imageAssetPath: 'assets/buynsell/discard.png', // Add your image // IMAGEDOODLE
        showLoadingState: false, // No loading state needed for instant operation
        options: [
          DialogOption(
            text: 'Cancel',
            onPressed: (ctx, setProcessing) => Navigator.pop(ctx, false),
          ),
          DialogOption(
            text: 'Remove',
            onPressed: (ctx, setProcessing) => Navigator.pop(ctx, true),
            isPrimary: true,
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _existingImageUrls.removeAt(index);
      });
    }
  }

  // Handles removal of new images (from device)
  Future<void> _removeNewImage(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Remove Image',
        content1: 'Are you sure you want to remove this image?',
        content2: 'This cannot be undone.',
        // imageAssetPath: 'assets/buynsell/discard.png', // Add your image // IMAGEDOODLE
        showLoadingState: false, // No loading state needed for instant operation
        options: [
          DialogOption(
            text: 'Cancel',
            onPressed: (ctx, setProcessing) => Navigator.pop(ctx, false),
          ),
          DialogOption(
            text: 'Remove',
            onPressed: (ctx, setProcessing) => Navigator.pop(ctx, true),
            isPrimary: true,
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _images.removeAt(index);
      });
    }
  }

  Widget _buildCategoryPage() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(16, RS.sh(context, 20), 16, 0),
          alignment: Alignment.centerLeft,
          child: Text(
            'Select Item Category',
            style: TextStyle(
              color: Color(0xFF306FDC),
              fontSize: RS.sp(context, 20),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(16, RS.sh(context, 8), 16, 0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.25,
              mainAxisSpacing: RS.s(context, 10),
              crossAxisSpacing: RS.s(context, 10),
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
                    color: isSelected
                        ? Color(0xFFE9E9E9)
                        : Color.fromRGBO(239, 239, 239, 1),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: Color.fromRGBO(48, 111, 220, 1),
                            width: 1.5,
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ), // Your control
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        category['icon'],
                        width: RS.s(context, 64),
                        height: RS.s(context, 64),
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          category['name'],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color.fromRGBO(15, 22, 32, 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: RS.sh(context, 16)),
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

  Widget _buildImageGridItem(int index) {
    final isExisting = index < _existingImageUrls.length;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: isExisting
              ? Image.network(
                  _existingImageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : Image.file(
                  File(_images[index - _existingImageUrls.length].path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () {
              isExisting
                  ? _removeExistingImage(index)
                  : _removeNewImage(index - _existingImageUrls.length);
            },
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.6),
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsPage() {
    final totalImages = _existingImageUrls.length + _images.length;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: RS.sh(context, 16)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (totalImages > 0) _buildImagePreview(0),
                      if (totalImages > 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: _buildImagePreview(1),
                        ),
                      if (totalImages > 2)
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
                                        childAspectRatio: 1,
                                      ),
                                      itemCount: totalImages,
                                      itemBuilder: (context, index) {
                                        return _buildImageGridItem(index);
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
                              width: RS.sw(context, 60),
                              height: RS.sh(context, 60),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(239, 239, 239, 1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  '+${totalImages - 2}',
                                  style: TextStyle(
                                    fontSize: RS.sp(context, 24),
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(126, 130, 135, 1),
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
                      width: RS.sw(context, 60),
                      height: RS.sh(context, 60),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(239, 239, 239, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Image.asset(
                          _getCategoryIcon(_selectedCategory!),
                          // _categories.firstWhere(
                          //   (c) => c['name'] == _selectedCategory,
                          // )['icon'],
                          width: RS.sw(context, 48),
                          height: RS.sh(context, 48),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: RS.sh(context, 20)),

              // Heading
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add Item Details',
                  style: TextStyle(
                    color: Color(0xFF306FDC),
                    fontSize: RS.sp(context, 20),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              SizedBox(height: RS.sh(context, 20)),

              // Form fields
              // Title
              RichText(
                text: TextSpan(
                  text: 'Title',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(21, 32, 45, 1),
                      fontSize: RS.sp(context, 16)),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              SizedBox(height: RS.sh(context, 8)),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: RS.s(context, 12),
                    horizontal: RS.s(context, 16),
                  ),
                  hintText: 'Enter item name',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(126, 130, 135, 1),
                    fontSize: RS.sp(context, 14),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(210, 213, 218, 1),
                      width: 1,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: RS.sh(context, 16)),

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
                          text: TextSpan(
                            text: 'Price',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 32, 45, 1),
                                fontSize: RS.sp(context, 16)),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: RS.sh(context, 8)),
                        _isGiveAway
                            ? _buildGiveAwayDisplay()
                            : TextFormField(
                                controller: _priceController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: RS.sh(context, 12),
                                    horizontal: RS.sw(context, 16),
                                  ),
                                  hintText: 'Enter Selling Price',
                                  hintStyle: TextStyle(
                                    color: Color.fromRGBO(126, 130, 135, 1),
                                    fontSize: RS.sp(context, 14),
                                  ),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(
                                      left: RS.s(context, 8),
                                    ),
                                    child: Text(
                                      '₹',
                                      style: TextStyle(
                                        fontSize: RS.sp(context, 16),
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 0,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(210, 213, 218, 1),
                                      width: 1,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
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
                  SizedBox(width: RS.sw(context, 16)),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Bought at',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(21, 32, 45, 1),
                                fontSize: RS.sp(context, 16)),
                          ),
                        ),
                        SizedBox(height: RS.sh(context, 8)),
                        TextFormField(
                          controller: _boughtPriceController,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: RS.s(context, 12),
                              horizontal: RS.s(context, 16),
                            ),
                            hintText: 'Cost Price',
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(126, 130, 135, 1),
                              fontSize: RS.sp(context, 14),
                            ),
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                left: RS.s(context, 8),
                              ),
                              child: Text(
                                '₹',
                                style: TextStyle(
                                  fontSize: RS.sp(context, 16),
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(210, 213, 218, 1),
                                width: 1,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: RS.sh(context, 16)),

              // Price Type (ChoiceChips)
              if (!_isGiveAway)
                Row(
                  children: [
                    ChoiceChip(
                      padding: EdgeInsets.all(RS.s(context, 8)),
                      label: Text('Negotiable',
                          style: TextStyle(
                              fontSize: RS.sp(context, 14), fontWeight: FontWeight.w500)),
                      selected: _isNegotiable,
                      onSelected: (selected) {
                        setState(() => _isNegotiable = true);
                      },
                      selectedColor: Color(0xFF306FDC),
                      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
                      labelStyle: TextStyle(
                        color: _isNegotiable ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                          color: Color.fromRGBO(210, 213, 218, 1), width: 1),
                      checkmarkColor: Colors.white,
                    ),
                    SizedBox(width: RS.sw(context, 8)),
                    ChoiceChip(
                      padding: EdgeInsets.all(RS.s(context, 8)),
                      label: Text('Fixed',
                          style: TextStyle(
                              fontSize: RS.sp(context, 14), fontWeight: FontWeight.w500)),
                      selected: !_isNegotiable,
                      onSelected: (selected) {
                        setState(() => _isNegotiable = false);
                      },
                      selectedColor: Color(0xFF306FDC),
                      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
                      labelStyle: TextStyle(
                        color: !_isNegotiable ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                          color: Color.fromRGBO(210, 213, 218, 1), width: 1),
                      checkmarkColor: Colors.white,
                    ),
                    SizedBox(width: RS.sw(context, 8)),
                    ChoiceChip(
                      padding: EdgeInsets.all(RS.s(context, 8)),
                      label: Text(
                        'Give-Away',
                        style: TextStyle(
                            fontSize: RS.sp(context, 14), fontWeight: FontWeight.w500),
                      ),
                      selected: _isGiveAway,
                      onSelected: (selected) {
                        setState(() {
                          _isGiveAway = true;
                          _priceController.text = '0';
                        });
                      },
                      selectedColor: Colors.green[200],
                      backgroundColor: Color.fromRGBO(239, 239, 239, 1),
                      labelStyle: TextStyle(
                        color: _isGiveAway ? Colors.green : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(
                          color: Color.fromRGBO(210, 213, 218, 1), width: 1),
                      checkmarkColor: Colors.green,
                    ),
                  ],
                ),
              SizedBox(height: RS.sh(context, 16)),

              // Description
              RichText(
                text: TextSpan(
                  text: 'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(21, 32, 45, 1),
                    fontSize: RS.sp(context, 16),
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              SizedBox(height: RS.sh(context, 8)),
              TextFormField(
                controller: _descController,
                buildCounter: (
                  BuildContext context, {
                  required int currentLength,
                  required bool isFocused,
                  required int? maxLength,
                }) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Character Limit',
                        style: TextStyle(fontSize: RS.sp(context, 12), color: Colors.grey),
                      ),
                      Text(
                        '$currentLength/$maxLength',
                        style: TextStyle(
                          fontSize: RS.sp(context, 12),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: RS.s(context, 12),
                    horizontal: RS.s(context, 16),
                  ),
                  hintText: 'Enter Description',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(126, 130, 135, 1),
                    fontSize: RS.sp(context, 14),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(210, 213, 218, 1),
                      width: 1,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
              SizedBox(height: RS.sh(context, 16)),

              // Mobile Number
              RichText(
                text: TextSpan(
                  text: '10-Digit Mobile Number',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(21, 32, 45, 1),
                      fontSize: RS.sp(context, 16)),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              SizedBox(height: RS.sh(context, 8)),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: RS.s(context, 12),
                    horizontal: RS.s(context, 16),
                  ),
                  hintText: 'Enter your mobile number',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(126, 130, 135, 1),
                    fontSize: RS.sp(context, 14),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(210, 213, 218, 1),
                      width: 1,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
              SizedBox(height: RS.sh(context, 30)),
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
                  SizedBox(width: 16),
                  Expanded(
                    child: DecoratedButton(
                      text: isPosting ? 'Posting...' : 'Post',
                      onPressed: (totalImages == 0) ? () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add at least one image to post'),
                          ),
                        );
                      } : (isPosting)  ? null
                        : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => isPosting = true);

                          final bloc = BlocProvider.of(context)!.bloc;
                          late BuynSellPost bnsPost;

                          if (_isEditMode) {
                            bnsPost = widget.existingPost!;
                          } else {
                            bnsPost = BuynSellPost();
                          }

                          bnsPost
                            ..name = _titleController.text.trim()
                            ..description = _descController.text.trim()
                            ..contactDetails = _mobileController.text.trim()
                            ..negotiable = _isGiveAway ? false : _isNegotiable
                            ..action = _isGiveAway ? "giveaway" : "sell"
                            ..originalPrice =
                                int.tryParse(_boughtPriceController.text.trim())
                            ..price = _isGiveAway
                                ? 0
                                : int.tryParse(_priceController.text.trim()) ?? 0
                            ..category = (_selectedCategory != null &&
                                    _categories.any(
                                        (c) => c['name'] == _selectedCategory))
                                ? _selectedCategory
                                : 'Others';

                          try {
                            final List<String> imageUrls = [];

                            if (_isEditMode) {
                              imageUrls.addAll(_existingImageUrls);
                            }

                            for (final XFile image in _images) {
                              final file = File(image.path);

                              // Compress image to 50% quality before uploading
                              final compressedFile = await _compressImage(file);

                              final ImageUploadResponse resp =
                                  await bloc.client.uploadImage(
                                bloc.getSessionIdHeader(),
                                compressedFile,
                              );

                              imageUrls.add(resp.pictureURL!);
                            }

                            bnsPost.imageUrl = imageUrls;

                            if (_isEditMode) {
                              await bloc.buynSellPostBloc.updateBuynSellPost(bnsPost);
                            } else {
                              await bloc.buynSellPostBloc.createBuynSellPost(bnsPost);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _isEditMode
                                      ? 'Post updated successfully!'
                                      : 'Item posted successfully!',
                                ),
                              ),
                            );

                            Navigator.pop(context);
                          } catch (e) {
                            String msg = 'Error posting item';

                            if (e is DioException) {
                              msg = e.response?.data?.toString() ?? e.message ?? msg;
                            } else {
                              msg = e.toString();
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)),
                            );
                          }
                          finally {
                            setState(() => isPosting = false);
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

  String _getCategoryIcon(String categoryName) {
    try {
      return _categories.firstWhere(
        (c) => c['name'] == categoryName,
      )['icon'];
    } catch (e) {
      return 'assets/categories/other.png';
    }
  }

  Widget _buildImagePreview(int index) {
    final totalImages = _existingImageUrls.length + _images.length;
    if (index >= totalImages) return const SizedBox.shrink();

    final isExisting = index < _existingImageUrls.length;
    final imageWidget = isExisting
        ? Image.network(
            _existingImageUrls[index],
            width: RS.sw(context, 60),
            height: RS.sh(context, 60),
            fit: BoxFit.cover,
          )
        : Image.file(
            File(_images[index - _existingImageUrls.length].path),
            width: RS.sw(context, 60),
            height: RS.sh(context, 60),
            fit: BoxFit.cover,
          );

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageWidget,
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () {
              if (isExisting) {
                _removeExistingImage(index);
              } else {
                _removeNewImage(index - _existingImageUrls.length);
              }
            },
            child: Container(
              width: RS.sw(context, 20),
              height: RS.sh(context, 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.6),
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 14),
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: RS.sw(context, 12), vertical: RS.sh(context, 9)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Give Away',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: RS.sp(context, 16),
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

import 'package:flutter/material.dart';
import '../widgets/dotted_divider.dart';
import 'package:InstiApp/src/utils/responsive.dart';

class CustomDialog extends StatefulWidget {
  final String title;
  final String content1;
  final String content2;
  final List<DialogOption> options;
  final String? imageAssetPath;
  final bool showLoadingState;
  final String loadingText;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.content1,
    required this.content2,
    required this.options,
    this.imageAssetPath,
    this.showLoadingState = false,
    this.loadingText = 'Processing...',
  }) : super(key: key);

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  bool _isProcessing = false;

  void _setProcessingState(bool processing) {
    if (mounted) {
      setState(() {
        _isProcessing = processing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RS.s(context, 20))),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: RS.sw(context, 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: RS.sp(context, 20),
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(15, 22, 32, 1),
                fontFamily: 'DM Sans',
              ),
            ),
            
            const SizedBox(height: 8),
            const DottedDivider(padding: EdgeInsets.zero),
            const SizedBox(height: 8),
            
            // Content1
            Text(
              widget.content1,
              style: TextStyle(
                fontSize: RS.sp(context, 16),
                color: Color.fromRGBO(15, 22, 32, 0.8),
                height: 1.4,
                fontFamily: 'DM Sans',
              ),
            ),

            // Content2
            if (widget.content2.isNotEmpty) ...[
              Text(
                widget.content2,
                style: TextStyle(
                  fontSize: RS.sp(context, 16),
                  color: Color.fromRGBO(15, 22, 32, 0.8),
                  height: 1.4,
                  fontFamily: 'DM Sans',
                ),
              ),
            ],
            
            // Image (222x222)
            if (widget.imageAssetPath != null) ...[
              Center(
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.center,
                    widthFactor: 0.8,
                    heightFactor: 0.85,
                    child: Image.asset(
                      widget.imageAssetPath!,
                      width: RS.s(context, 220),
                      height: RS.s(context, 220),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],

            if (widget.imageAssetPath == null) const SizedBox(height: 16),
            
            // Options/Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: widget.options.map((option) => 
                _buildDialogButton(option, context, _isProcessing)
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton(DialogOption option, BuildContext context, bool isProcessing) {
    final isDisabled = isProcessing && option.isPrimary;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: isDisabled ? null : () {
          if (widget.showLoadingState && option.isPrimary) {
            _setProcessingState(true);
          }
          option.onPressed(context, _setProcessingState);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled 
              ? Colors.grey
              : (option.isPrimary 
                  ? Color.fromRGBO(48, 111, 220, 1)
                  : Colors.white),
          foregroundColor: isDisabled 
              ? Colors.white
              : (option.isPrimary 
                  ? Colors.white 
                  : Color.fromRGBO(48, 111, 220, 1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: isDisabled || option.isPrimary 
                ? BorderSide.none 
                : const BorderSide(color: Color.fromRGBO(48, 111, 220, 1), width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          elevation: 0,
        ),
        child: Text(
          isDisabled ? widget.loadingText : option.text,
          style: TextStyle(
            fontSize: RS.sp(context, 16),
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
    );
  }
}

class DialogOption {
  final String text;
  final Function(BuildContext, void Function(bool)) onPressed;
  final bool isPrimary;

  const DialogOption({
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
  });
}
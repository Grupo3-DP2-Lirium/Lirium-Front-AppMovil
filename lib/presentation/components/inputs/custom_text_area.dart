import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';

class CustomTextArea extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final Function(String)? onChanged;
  final IconData? prefixIcon;

  const CustomTextArea({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.maxLines = 4,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.prefixIcon,
  });

  @override
  State<CustomTextArea> createState() => _CustomTextAreaState();
}

class _CustomTextAreaState extends State<CustomTextArea> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasValue =>
      widget.controller != null && widget.controller!.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      validator: widget.validator,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      keyboardType: TextInputType.multiline,
      textAlignVertical: TextAlignVertical.top,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        alignLabelWithHint: true,
        prefixIcon: widget.prefixIcon != null
            ? Padding(
          padding: const EdgeInsets.only(bottom: 40), // Alinear arriba
          child: Icon(
            widget.prefixIcon,
            color: _isFocused ? AppColors.primary : AppColors.textSecondary,
          ),
        )
            : null,

        labelStyle: TextStyle(
          fontSize: _isFocused || _hasValue ? 14 : 16,
          color: _isFocused
              ? AppColors.primary
              : widget.enabled
              ? AppColors.textSecondary
              : AppColors.inactive,
          fontWeight: _isFocused || _hasValue ? FontWeight.w500 : FontWeight.normal,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,

        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[400],
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),

        filled: true,
        fillColor: widget.enabled ? Colors.grey[50] : Colors.grey[100],

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        counterStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
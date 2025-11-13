import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/common/app_colors.dart';
import 'package:intl/intl.dart';

class CustomDateField extends StatefulWidget {
  final String label;
  final DateTime? value;
  final Function(DateTime?) onChanged;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  const CustomDateField({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  @override
  State<CustomDateField> createState() => _CustomDateFieldState();
}

class _CustomDateFieldState extends State<CustomDateField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value != null
          ? DateFormat('dd/MM/yyyy').format(widget.value!)
          : '',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(CustomDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value != null
          ? DateFormat('dd/MM/yyyy').format(widget.value!)
          : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    if (!widget.enabled) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: true,
      enabled: widget.enabled,
      onTap: _selectDate,
      validator: (value) {
        if (widget.validator != null) {
          return widget.validator!(widget.value);
        }
        return null;
      },
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: const Icon(Icons.calendar_today, size: 20),

        // Floating label style
        labelStyle: TextStyle(
          fontSize: _isFocused || widget.value != null ? 14 : 16,
          color: _isFocused
              ? AppColors.primary
              : widget.enabled
              ? AppColors.textSecondary
              : AppColors.inactive,
          fontWeight: _isFocused || widget.value != null ? FontWeight.w500 : FontWeight.normal,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,

        // Border styles
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

        // Fill colors
        filled: true,
        fillColor: widget.enabled ? Colors.grey[50] : Colors.grey[100],

        // Content padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
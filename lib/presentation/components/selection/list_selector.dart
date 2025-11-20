import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/components.dart';

class AppDropdownField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> options;
  final String? Function(String?)? validator;
  final String? header;
  final bool? enable;

  const AppDropdownField({
    super.key,
    required this.controller,
    required this.options,
    this.validator,
    this.header,
    this.enable = true,
  });

  @override
  State<AppDropdownField> createState() => _AppDropdownFieldState();
}

class _AppDropdownFieldState extends State<AppDropdownField> {
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleDropdown() {
    // Solo abrir el dropdown si 'enable' es verdadero
    if (widget.enable ?? true) {
      if (_isOpen) {
        _removeOverlay();
      } else {
        _showOverlay();
      }
    }
  }

  void _showOverlay() {
    final RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 🟢 Cierra al hacer tap fuera
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),

          // 🟢 Dropdown correctamente pegado al widget
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height,
            width: size.width,
            child: Material(
              elevation: 4,
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: widget.options.length,
                  itemBuilder: (context, index) {
                    final option = widget.options[index];
                    return ListTile(
                      title: Text(option, style: const TextStyle(color: Colors.grey)),
                      onTap: () {
                        widget.controller.text = option;
                        _removeOverlay();
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isOpen = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: _toggleDropdown,
      child: AbsorbPointer(
        child: AppTextField(
          hintText: "Selecciona una opción",
          controller: widget.controller,
          label: widget.header,
          floatingLabel: true,
          enabled: widget.enable!,
          suffixIcon: const Icon(Icons.arrow_drop_down),
          validator: widget.validator,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}
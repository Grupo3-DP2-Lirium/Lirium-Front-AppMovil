import 'package:flutter/material.dart';

class PhoneField extends StatefulWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PhoneField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  String _selectedCountryCode = '+1';
  String _selectedFlag = '🇺🇸';

  final List<Map<String, String>> _countries = [
    {'code': '+1', 'flag': '🇺🇸', 'name': 'Estados Unidos'},
    {'code': '+52', 'flag': '🇲🇽', 'name': 'México'},
    {'code': '+34', 'flag': '🇪🇸', 'name': 'España'},
    {'code': '+54', 'flag': '🇦🇷', 'name': 'Argentina'},
    {'code': '+57', 'flag': '🇨🇴', 'name': 'Colombia'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Country code selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_selectedFlag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedCountryCode,
                underline: const SizedBox(),
                items: _countries.map((country) {
                  return DropdownMenuItem(
                    value: country['code'],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(country['flag']!),
                        const SizedBox(width: 8),
                        Text(country['code']!),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCountryCode = value!;
                    _selectedFlag = _countries.firstWhere(
                      (country) => country['code'] == value,
                    )['flag']!;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Phone number field
        Expanded(
          child: TextFormField(
            controller: widget.controller,
            keyboardType: TextInputType.phone,
            validator: widget.validator,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: 'Número de teléfono',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String get fullPhoneNumber =>
      '$_selectedCountryCode${widget.controller?.text ?? ''}';
}

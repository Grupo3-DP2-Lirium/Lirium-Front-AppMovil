import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/components.dart';

class DateTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;

  const DateTextField({
    super.key,
    required this.hintText,
    required this.controller,
  });

  @override
  State<DateTextField> createState() => _DateTextFieldState();
}

class _DateTextFieldState extends State<DateTextField> {
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale("es"),
    );

    if (picked != null) {
      setState(() {
        widget.controller.text =
        "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectDate, // Abre calendario al tocar todo el TextField
      child: AbsorbPointer(
        child: AppTextField(
          controller: widget.controller,
          enabled: true,
          hintText: widget.hintText,
          suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
          // Aquí pasamos el color gris al texto seleccionado
          obscureText: false
        ),
      ),
    );
  }
}

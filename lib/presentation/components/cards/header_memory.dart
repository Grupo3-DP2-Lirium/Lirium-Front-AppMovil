import 'package:flutter/material.dart';
import 'package:flutter_frontend/presentation/components/buttons/pop_menu_button.dart';

class HeaderWithActions extends StatelessWidget {
  final String userName;
  final DateTime createdDate;
  final List<PopupMenuOption> menuOptions;

  const HeaderWithActions({
    super.key,
    required this.userName,
    required this.createdDate,
    required this.menuOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // Display formatted date of memory creation
              Text(
                "${createdDate.day.toString().padLeft(2, '0')}/${createdDate.month.toString().padLeft(2, '0')}/${createdDate.year}",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          // CustomPopupMenu for actions (edit, delete, etc.)
          CustomPopupMenu(
            options: menuOptions,
          ),
        ],
      ),
    );
  }
}

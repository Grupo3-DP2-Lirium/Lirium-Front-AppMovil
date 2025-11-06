import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppPopupButton {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  AppPopupButton({
    required this.text,
    required this.onPressed,
    this.color,
  });
}

Future<void> appPopupButtonDefault({
  required BuildContext context,
  required String title,
  required String message,
  required List<AppPopupButton> buttons, // 1 o 2 botones
  bool isLoading = false,
}) async {
  assert(buttons.isNotEmpty && buttons.length <= 2,
  "El pop-up solo puede tener 1 o 2 botones");

  return showDialog(
    context: context,
    barrierDismissible: !isLoading,
    builder: (_) => Center(
      child: Container(
        width: 294,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.black),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                Column(
                  children: const [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Procesando ...",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    if (buttons.length == 1)
                      SizedBox(
                        width: 294,
                        height: 60,
                        child: CupertinoButton.filled(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          child: Text(
                            buttons[0].text,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            buttons[0].onPressed();
                          },
                        ),
                      )
                    else
                      Row(
                        children: buttons.map((btn) {
                          int index = buttons.indexOf(btn);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: index == 1 ? 8 : 0,
                                  right: index == 0 ? 8 : 0),
                              child: SizedBox(
                                height: 60,
                                child: CupertinoButton.filled(
                                  borderRadius: BorderRadius.circular(12),
                                  color: btn.color ?? (
                                      buttons.length == 1 ? AppColors.primary :
                                      (index == 0 ? Colors.grey[200] : AppColors.primary)),
                                  onPressed: btn.onPressed,
                                  child: Text(
                                    btn.text,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                      index == 0 ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
import 'package:flutter/material.dart';

Widget primaryButton({
  required String text,
  required VoidCallback onPressed,
  Color backgroundColor = const Color(0xFF5DCCFC),
  Color textColor = const Color(0xFFFFFFFF),
  double width = double.infinity,
  double height = 52.0,
  double borderRadius = 8.0,
}) {
  return SizedBox(
    width: width,
    height: height,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

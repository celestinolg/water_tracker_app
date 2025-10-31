import 'package:flutter/material.dart';

AppBar buildAppBar() {
  return AppBar(
    backgroundColor: Color(0xFFF4F8FB),
    elevation: 0,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Good Morning,",
          style: TextStyle(
            color: Color(0xFF90A5B4),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          "Aashifa Sheikh",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ],
    ),
    actions: [
      Container(
        margin: EdgeInsets.only(right: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.white,
        ),
        child: IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications, color: Color(0xFF5DCCFC)),
        ),
      ),
    ],
  );
}

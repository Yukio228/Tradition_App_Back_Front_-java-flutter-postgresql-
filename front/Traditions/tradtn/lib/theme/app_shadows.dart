import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x338B5CF6),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}


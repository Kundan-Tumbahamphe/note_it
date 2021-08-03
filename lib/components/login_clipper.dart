import 'package:flutter/material.dart';

class LoginClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    final path = Path();
    final centerPoint = Offset(size.width / 2, size.height);
    final endPoint = Offset(size.width, 4 * size.height / 5);

    path.lineTo(0, 4 * size.height / 5);
    path.quadraticBezierTo(
        centerPoint.dx, centerPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}

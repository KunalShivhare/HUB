import 'package:flutter/material.dart';

class ClipPathClass23 extends CustomClipper<Path> {
  double _size = 0;
  ClipPathClass23(this._size);

  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.quadraticBezierTo(0, size.height-_size, _size, size.height-_size);
    path.lineTo(size.width-_size, size.height-_size);
    path.quadraticBezierTo(size.width, size.height-_size, size.width, size.height);
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}


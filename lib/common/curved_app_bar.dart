import 'package:flutter/material.dart';

class CustomCurvedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomCurvedAppBar({
    super.key,
    required this.child,
    this.preferredSize = const Size.fromHeight(kToolbarHeight + 20),
  });

  final Widget child;
  @override
  final Size preferredSize; // Required for PreferredSizeWidget

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurvedEdges(),
      child: Container(
        color: Theme.of(context).primaryColor, // Optional: Background color
        child: child,
      ),
    );
  }
}

class CurvedEdges extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);

    final firstCurve = Offset(0, size.height - 20);
    final lastCurve = Offset(30, size.height - 20);
    path.quadraticBezierTo(firstCurve.dx, firstCurve.dy, lastCurve.dx, lastCurve.dy);

    final secondFirstCurve = Offset(0, size.height - 20);
    final secondLastCurve = Offset(size.width - 30, size.height - 20);
    path.quadraticBezierTo(secondFirstCurve.dx, secondFirstCurve.dy, secondLastCurve.dx, secondLastCurve.dy);

    final thirdFirstCurve = Offset(size.width, size.height - 20);
    final thirdLastCurve = Offset(size.width, size.height);
    path.quadraticBezierTo(thirdFirstCurve.dx, thirdFirstCurve.dy, thirdLastCurve.dx, thirdLastCurve.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false; // Returning false as the clipper won't dynamically change
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A kind of element
class OvalWidget extends StatelessWidget {
  const OvalWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(100, 100),
            painter: _OvalPainter(),
          ),
        ],
      ),
    );
  }
}

class _OvalPainter extends CustomPainter {
  _OvalPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    Path path = Path();

    paint.style = PaintingStyle.fill;
    paint.color = Colors.red;

    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawShadow(
      path.shift(const Offset(0.1, 0.1)),
      Colors.black,
      0.1,
      true,
    );
    canvas.drawPath(path, paint);

    paint.strokeWidth = 0.2;
    paint.color = Colors.blueGrey;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

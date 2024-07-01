import 'dart:ui';

import 'package:flutter/material.dart';

/// A kind of element
class LineWidget extends StatelessWidget {
  Offset start;
  Offset end;

  LineWidget({
    super.key,
    required this.start,
    required this.end
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (end.dx - start.dx).abs(),
      height: (end.dy - start.dy).abs(),
      child: Stack(
        children: [
          CustomPaint(
            size: Size((end.dx - start.dx).abs(), (end.dy - start.dy).abs()),
            painter: _LinePainter(start: start, end:end),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  Offset start;
  Offset end;

  _LinePainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.4;
    paint.color = Colors.grey;

    Offset x = Offset(start.dx + 50, start.dy - 50);
    Offset y = Offset(end.dx + 50, end.dy - 50);
    canvas.drawLine(x, y, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

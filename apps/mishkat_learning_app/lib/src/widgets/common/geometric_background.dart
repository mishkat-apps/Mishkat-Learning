import 'dart:math' as math;
import 'package:flutter/material.dart';

class GeometricBackground extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final double opacity;

  const GeometricBackground({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFF0E6B5B),
    this.opacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: baseColor),
        Positioned.fill(
          child: CustomPaint(
            painter: _GeometricPainter(
              color: Colors.white.withValues(alpha: opacity),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _GeometricPainter extends CustomPainter {
  final Color color;

  _GeometricPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 100.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawIslamicStar(canvas, Offset(x, y), 40, paint);
      }
    }
  }

  void _drawIslamicStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 8;
    const innerRadius = 25.0;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : innerRadius;
      final angle = (i * math.pi) / points;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

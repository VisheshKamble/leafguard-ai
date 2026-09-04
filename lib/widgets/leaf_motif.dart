import 'package:flutter/material.dart';

/// A single stylised leaf silhouette -- literal to the app's subject matter
/// (this is an app about leaves) rather than decoration for its own sake.
/// Used as a quiet watermark behind hero content: splash, the dashboard
/// header, auth screens. Never the focal point, always low-opacity.
class LeafMotif extends StatelessWidget {
  final double size;
  final Color color;
  final double rotation;

  const LeafMotif({
    super.key,
    this.size = 120,
    required this.color,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: CustomPaint(
        size: Size(size, size),
        painter: _LeafPainter(color: color),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  final Color color;
  _LeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final blade = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.02)
      ..quadraticBezierTo(
        size.width * 0.98,
        size.height * 0.36,
        size.width * 0.5,
        size.height * 0.98,
      )
      ..quadraticBezierTo(
        size.width * 0.02,
        size.height * 0.36,
        size.width * 0.5,
        size.height * 0.02,
      )
      ..close();
    canvas.drawPath(path, blade);

    final vein = Paint()
      ..color = Color.lerp(color, const Color(0xFF000000), 0.18)!
      ..strokeWidth = size.width * 0.018
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.12),
      Offset(size.width * 0.5, size.height * 0.88),
      vein,
    );
    for (final t in [0.32, 0.5, 0.68]) {
      canvas.drawLine(
        Offset(size.width * 0.5, size.height * t),
        Offset(size.width * (0.5 - 0.22 * (1 - t)), size.height * (t - 0.08)),
        vein,
      );
      canvas.drawLine(
        Offset(size.width * 0.5, size.height * t),
        Offset(size.width * (0.5 + 0.22 * (1 - t)), size.height * (t - 0.08)),
        vein,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) => oldDelegate.color != color;
}

/// A pair of oversized, softly rotated leaves anchored to opposite corners
/// -- the standard hero-banner treatment used behind splash, dashboard, and
/// auth headers. `IgnorePointer` keeps it from stealing taps; callers clip
/// this within a rounded container so the leaves bleed off the edge rather
/// than floating awkwardly inside it.
class LeafPatternBackground extends StatelessWidget {
  final Color color;
  const LeafPatternBackground({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -28,
            child: LeafMotif(size: 150, color: color, rotation: 0.55),
          ),
          Positioned(
            left: -46,
            bottom: -34,
            child: LeafMotif(size: 110, color: color, rotation: -0.35),
          ),
        ],
      ),
    );
  }
}

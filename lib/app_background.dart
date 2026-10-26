import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Photo background (assets/images/bg.jpg) + animated colour wash + floating bubbles.
/// If the photo is missing, the animated gradient still looks good.
class AppBackground extends StatefulWidget {
  final Widget child;
  final String image;
  const AppBackground({super.key, required this.child, this.image = 'assets/images/bg.jpg'});
  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 25))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      Container(color: const Color(0xFF1A237E)),
      Image.asset(widget.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
      AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final t = _c.value * 2 * math.pi;
          return Stack(fit: StackFit.expand, children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(math.cos(t), math.sin(t)),
                  end: Alignment(-math.cos(t), -math.sin(t)),
                  colors: [
                    const Color(0xFF1A237E).withOpacity(0.80),
                    const Color(0xFF6A1B9A).withOpacity(0.70),
                    const Color(0xFF00897B).withOpacity(0.65),
                  ],
                ),
              ),
            ),
            for (int i = 0; i < 7; i++)
              Align(
                alignment: Alignment(
                  math.sin(t + i * 1.7) * 0.9,
                  math.cos(t * (i.isEven ? 1 : -1) + i * 2.1) * 0.9,
                ),
                child: Container(
                  width: 50.0 + i * 22,
                  height: 50.0 + i * 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
          ]);
        },
      ),
      widget.child,
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class CrystalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final Color? borderColor;

  const CrystalCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: height ?? double.infinity,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (borderColor ?? const Color(0xFF6B4EE6)).withOpacity(0.5),
            const Color(0xFF00D9FF).withOpacity(0.2),
          ],
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          height: height,
          child: child,
        ),
      ),
    );
  }
}

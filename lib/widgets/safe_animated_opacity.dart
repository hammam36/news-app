import 'package:flutter/material.dart';

class SafeAnimatedOpacity extends StatelessWidget {
  final Widget child;
  final double opacity;
  final Duration duration;

  const SafeAnimatedOpacity({
    super.key,
    required this.child,
    required this.opacity,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity.clamp(0.0, 1.0),
      duration: duration,
      child: child,
    );
  }
}
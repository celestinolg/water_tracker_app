import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, animatedValue, child) {
        return Text('$animatedValue', style: style);
      },
    );
  }
}

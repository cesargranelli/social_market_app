import 'package:flutter/material.dart';

class TransitionSlide extends StatelessWidget {
  static const Offset rightLeft = Offset(1.0, 0.0);
  static const Offset downUp = Offset(0.0, 1.0);
  static const Offset leftRight = Offset(-1.0, 0.0);
  static const Offset upDown = Offset(0.0, -1.0);

  final Widget child;
  final Animation<double> animation;
  final Offset direction;

  const TransitionSlide({
    super.key,
    required this.child,
    required this.animation,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: direction,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
      child: child,
    );
  }
}

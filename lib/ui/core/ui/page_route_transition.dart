import 'package:flutter/material.dart';

import 'transition_slide.dart';

class PageRouteTransition<T> extends PageRouteBuilder<dynamic> {
  final Widget pageRoute;

  PageRouteTransition({required this.pageRoute, required super.pageBuilder}) {
    PageRouteBuilder(
      pageBuilder: pageBuilder,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return TransitionSlide(
          animation: animation,
          direction: TransitionSlide.downUp,
          child: child,
        );
      },
    );
  }
}

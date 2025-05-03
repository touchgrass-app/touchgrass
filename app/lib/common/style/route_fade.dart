import 'package:flutter/material.dart';

class RouteFade extends PageRouteBuilder {
  final Widget page;

  RouteFade({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 40),
        );
} 
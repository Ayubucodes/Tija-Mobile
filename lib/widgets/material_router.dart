import 'package:flutter/material.dart';

class MaterialRouter {
  static void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ));
  }
}

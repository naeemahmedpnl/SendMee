// import 'package:flutter/material.dart';

// PageRouteBuilder animatedRoute(Widget page) {
//   return PageRouteBuilder(
//     transitionDuration: Duration(milliseconds: 100),
//     pageBuilder: (context, animation, secondaryAnimation) => page,
    
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//   var curve = Curves.easeInOut;
//   var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

//   return ScaleTransition(
//     scale: animation.drive(tween),
//     child: child,
//   );
// }
//   );
// }

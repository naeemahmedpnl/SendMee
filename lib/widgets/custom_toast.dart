// import 'package:flutter/material.dart';

// class CustomToast extends StatelessWidget {
//   final String message;
//   final bool isError;

//   const CustomToast({
//     Key? key, 
//     required this.message, 
//     this.isError = false
//   }) : super(key: key);

//   static void show(BuildContext context, String message, {bool isError = false}) {
//     final overlayState = Overlay.of(context);
    
//     OverlayEntry? overlayEntry;

//     overlayEntry = OverlayEntry(
//       builder: (BuildContext context) {
//         final screenSize = MediaQuery.of(context).size;
        
//         return SafeArea(
//           child: Stack(  // Added Stack widget here
//             children: [
//               Positioned(
//                 bottom: 16,
//                 width: screenSize.width,
//                 child: Material(
//                   color: Colors.transparent,
//                   child: StatefulBuilder(
//                     builder: (context, setState) {
//                       return TweenAnimationBuilder<double>(
//                         tween: Tween(begin: 0.0, end: 1.0),
//                         duration: const Duration(milliseconds: 300),
//                         onEnd: () {
//                           Future.delayed(const Duration(milliseconds: 1500), () {
//                             if (overlayEntry?.mounted ?? false) {
//                               setState(() {});
//                               Future.delayed(
//                                 const Duration(milliseconds: 300), 
//                                 () {
//                                   overlayEntry?.remove();
//                                 }
//                               );
//                             }
//                           });
//                         },
//                         builder: (context, value, child) {
//                           return Transform.translate(
//                             offset: Offset(0, 50 - (50 * value)),
//                             child: Opacity(
//                               opacity: value,
//                               child: child,
//                             ),
//                           );
//                         },
//                         child: _ToastContent(
//                           message: message,
//                           isError: isError,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );

//     overlayState.insert(overlayEntry);
//   }

//   @override
//   Widget build(BuildContext context) => _ToastContent(
//     message: message,
//     isError: isError,
//   );
// }

// class _ToastContent extends StatelessWidget {
//   final String message;
//   final bool isError;

//   const _ToastContent({
//     Key? key,
//     required this.message,
//     this.isError = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(25.0),
//         color: isError ? Colors.red.shade800 : Colors.green.shade800,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: Text(
//           message,
//           style: const TextStyle(
//             color: Colors.white, 
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }

// extension ToastExtension on BuildContext {
//   void showToast(String message, {bool isError = false}) {
//     CustomToast.show(this, message, isError: isError);
//   }
// }
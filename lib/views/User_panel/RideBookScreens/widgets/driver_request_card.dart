

import 'package:flutter/material.dart';

import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';

class CustomDriverCard extends StatelessWidget {
  final String driverName;
  final String driverRating;
  final String driverImageUrl;
  final String price;
  final String arrivalTime;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final String tripId;
  final String driverToPickupInfo;
  final double? timerProgress;

  const CustomDriverCard({super.key, 
    required this.driverName,
    required this.driverRating,
    required this.driverImageUrl,
    required this.price,
    required this.arrivalTime,
    required this.onAccept,
    required this.onDecline,
    required this.tripId,
    required this.driverToPickupInfo,
    this.timerProgress,
  });

  Color _getProgressColor(double progress) {
    if (progress > 0.6) return Colors.green;
    if (progress > 0.3) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
  

  
// In CustomDriverCard build method:
String fullImageUrl = driverImageUrl.isNotEmpty 
    ? driverImageUrl  
    : '';


    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.9,
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Animated Timer Progress Bar
          if (timerProgress != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Stack(
                children: [
                  // Base Progress Bar with Animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 3,
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(
                        begin: _getProgressColor(timerProgress!),
                        end: _getProgressColor(timerProgress!),
                      ),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, color, child) {
                        return LinearProgressIndicator(
                          value: timerProgress!,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(color!),
                        );
                      },
                    ),
                  ),
                  // Pulse Effect for Low Time
                  if (timerProgress! < 0.3)
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.5, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return AnimatedOpacity(
                            opacity: value,
                            duration: const Duration(milliseconds: 500),
                            child: LinearProgressIndicator(
                              
                              value: timerProgress!,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(timerProgress!).withOpacity(0.3)
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  CircleAvatar(
            radius: screenSize.width * 0.08,
            backgroundColor: Colors.grey[200],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenSize.width * 0.08),
              child: fullImageUrl.isNotEmpty
                  ? Image.network(
                      fullImageUrl,
                      width: screenSize.width * 0.16,
                      height: screenSize.width * 0.16,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Image.asset(
                          "assets/images/profile.png",
                          width: screenSize.width * 0.16,
                          height: screenSize.width * 0.16,
                          fit: BoxFit.cover,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      "assets/images/profile.png",
                      width: screenSize.width * 0.16,
                      height: screenSize.width * 0.16,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName,
                            style: AppTextTheme.getLightTextTheme(context).titleLarge,
                          ),
                          Text(
                            driverRating,
                            style: AppTextTheme.getLightTextTheme(context).titleSmall?.copyWith(color: Colors.amber),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$$price',
                          style: AppTextTheme.getLightTextTheme(context).headlineMedium?.copyWith(color: AppColors.primary),
                        ),
                        if (timerProgress != null)
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: (timerProgress! * 30) + 1,
                              end: timerProgress! * 30,
                            ),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, child) {
                              return Text(
                                '${value.toStringAsFixed(0)}s',
                                style: TextStyle(
                                  color: _getProgressColor(timerProgress!),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  driverToPickupInfo,
                  style: AppTextTheme.getLightTextTheme(context).titleSmall?.copyWith(color: Colors.green),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildAnimatedButton(
                        onTap: onDecline,
                        text: "Decline",
                        isAccept: false,
                      ),
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      flex: 4,
                      child: _buildAnimatedButton(
                        onTap: onAccept,
                        text: "Accept",
                        isAccept: true,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton({
    required VoidCallback onTap,
    required String text,
    required bool isAccept,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: isAccept ? Colors.yellow : Colors.transparent,
                border: Border.all(
                  color: isAccept ? Colors.yellow : AppColors.primary,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  text,
                  style: AppTextTheme.getLightTextTheme(context).titleLarge,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// class CustomDriverCard extends StatelessWidget {
//   final String driverName;
//   final String driverRating;
//   final String driverImageUrl;
//   final String price;
//   final String arrivalTime;
//   final VoidCallback onAccept;
//   final VoidCallback onDecline;
//   final String tripId;
//   final String driverToPickupInfo;
//   final double? timerProgress; // Add this

//   CustomDriverCard({
//     required this.driverName,
//     required this.driverRating,
//     required this.driverImageUrl,
//     required this.price,
//     required this.arrivalTime,
//     required this.onAccept,
//     required this.onDecline,
//     required this.tripId,
//     required this.driverToPickupInfo,
//     this.timerProgress, // Add this
//   });

//   Color _getProgressColor(double progress) {
//     if (progress > 0.6) return Colors.green;
//     if (progress > 0.3) return Colors.orange;
//     return Colors.red;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Container(
//       width: screenWidth * 0.9,
//       height: 190,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           // Timer Progress Indicator
//           if (timerProgress != null)
//             ClipRRect(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(10),
//                 topRight: Radius.circular(10),
//               ),
//               child: LinearProgressIndicator(
//                 value: timerProgress!,
//                 backgroundColor: Colors.grey[300],
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   _getProgressColor(timerProgress!),
//                 ),
//                 minHeight: 3, // Make it thin and elegant
//               ),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     CircleAvatar(
//                       radius: 30,
//                       backgroundImage: driverImageUrl.isNotEmpty
//                           ? NetworkImage(driverImageUrl)
//                           : AssetImage("assets/images/profile.png") as ImageProvider,
//                     ),
//                     const SizedBox(width: 15),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             driverName,
//                             style: AppTextTheme.getLightTextTheme(context).titleLarge,
//                           ),
//                           Text(
//                             driverRating,
//                             style: AppTextTheme.getLightTextTheme(context).titleSmall?.copyWith(color: Colors.amber),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           '\$$price',
//                           style: AppTextTheme.getLightTextTheme(context).headlineMedium?.copyWith(color: AppColors.primary),
//                         ),
//                         if (timerProgress != null)
//                           Text(
//                             '${(timerProgress! * 30).toStringAsFixed(0)}s',
//                             style: TextStyle(
//                               color: _getProgressColor(timerProgress!),
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   driverToPickupInfo,
//                   style: AppTextTheme.getLightTextTheme(context).titleSmall?.copyWith(color: Colors.green),
//                 ),
//                 const SizedBox(height: 5),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Expanded(
//                       flex: 4,
//                       child: GestureDetector(
//                         onTap: onDecline,
//                         child: Container(
//                           height: 45,
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: AppColors.primary,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Center(
//                             child: Text(
//                               "Decline",
//                               style: AppTextTheme.getLightTextTheme(context).titleLarge,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 25),
//                     Expanded(
//                       flex: 4,
//                       child: GestureDetector(
//                         onTap: onAccept,
//                         child: Container(
//                           height: 45,
//                           decoration: BoxDecoration(
//                             color: Colors.yellow,
//                             border: Border.all(
//                               color: Colors.yellow,
//                               width: 1,
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Center(
//                             child: Text(
//                               "Accept",
//                               style: AppTextTheme.getLightTextTheme(context).titleLarge,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
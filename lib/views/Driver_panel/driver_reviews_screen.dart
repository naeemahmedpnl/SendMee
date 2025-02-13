


import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rideapp/utils/routes/driver_panel_routes.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';
import 'package:rideapp/viewmodel/provider/ratings_provider/driver_rating_provider.dart';
import 'package:rideapp/widgets/custom_button.dart';

class DriverReviewsView extends StatefulWidget {
  const DriverReviewsView({super.key});

  @override
  State<DriverReviewsView> createState() => _DriverReviewsViewState();
}

class _DriverReviewsViewState extends State<DriverReviewsView> {
  final List<bool> _isSelected = List.generate(8, (index) => false);
  bool _isSubmitting = false;

  void _showErrorSnackBar(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.warning_amber_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade700 : Colors.orange.shade700,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _handleRatingSubmission(BuildContext context) async {
    if (_isSubmitting) return;

    final provider = Provider.of<DriverRatingProvider>(context, listen: false);
    
    // Validate rating
    if (provider.rating == null || provider.rating == 0) {
      _showErrorSnackBar(
        context, 
        'driverReviews.pleaseSelectRating'.tr(),
        isError: false
      );
      return;
    }

    // Validate feedback selection
    if (!_isSelected.contains(true)) {
      _showErrorSnackBar(
        context, 
        'driverReviews.selectFeedback'.tr(),
        isError: false
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      // Generate feedback string from selected criteria
      List<String> selectedCriteria = [];
      for (int i = 0; i < _isSelected.length; i++) {
        if (_isSelected[i]) {
          selectedCriteria.add(_getButtonLabel(i).tr());
        }
      }
      String feedback = selectedCriteria.join(', ');
      provider.setFeedback(feedback);

      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      'driverReviews.submitting'.tr(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final success = await provider.submitRating();
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success) {
          // Show success animation before navigation
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 50,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'driverReviews.thankYouFeedback'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          );

          // Navigate after delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context); // Close success dialog
              Navigator.pushReplacementNamed(context, AppDriverRoutes.rideBooking);
            }
          });
        } else {
          _showErrorSnackBar(
            context,
            provider.errorMessage ?? 'driverReviews.errorSubmitting'.tr(),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar(
          context,
          'driverReviews.unexpectedError'.tr(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getButtonLabel(int index) {
    switch (index) {
      case 0:
        return 'driverReviews.criteria.punctuality';
      case 1:
        return 'driverReviews.criteria.communication';
      case 2:
        return 'driverReviews.criteria.payment';
      case 3:
        return 'driverReviews.criteria.vehicleRespect';
      case 4:
        return 'driverReviews.criteria.cleanliness';
      case 5:
        return 'driverReviews.criteria.friendliness';
      case 6:
        return 'driverReviews.criteria.safetyDriving';
      case 7:
        return 'driverReviews.criteria.navigation';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: SafeArea(
        child: Consumer<DriverRatingProvider>(
          builder: (context, ratingProvider, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, 
                  vertical: 40
                ),
                child: Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.yellow,
                                width: 2,
                              )
                            ),
                            child: const CircleAvatar(
                              backgroundImage: AssetImage(
                                "assets/images/profile.png"
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(
                            child: Text(
                              'driverReviews.rateRideWith'.tr(args: ['julia']),
                              style: AppTextTheme.getLightTextTheme(context).headlineMedium,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < (ratingProvider.rating ?? 0) 
                                ? Icons.star 
                                : Icons.star_border,
                              color: AppColors.buttonColor,
                              size: 40,
                            ),
                            onPressed: () {
                              if (ratingProvider.rating == index + 1) {
                                ratingProvider.setRating(0);
                              } else {
                                ratingProvider.setRating(index + 1);
                              }
                            },
                          );
                        }),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Center(
                        child: Text(
                          'driverReviews.whatWentPerfect'.tr(),
                          style: AppTextTheme.getLightTextTheme(context).headlineSmall,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.035),
                      Wrap(
                        spacing: screenWidth * 0.04,
                        runSpacing: screenHeight * 0.02,
                        children: List.generate(
                          _isSelected.length,
                          (index) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(screenWidth * 0.42, screenHeight * 0.06),
                                backgroundColor: _isSelected[index]
                                    ? AppColors.buttonColor
                                    : const Color.fromARGB(217, 187, 187, 187),
                                foregroundColor: _isSelected[index]
                                    ? Colors.black
                                    : const Color(0xffD9D9D9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isSelected[index] = !_isSelected[index];
                                });
                              },
                              child: FittedBox(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    _getButtonLabel(index).tr(),
                                    style: AppTextTheme.getLightTextTheme(context).bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.040),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                        child: CustomButton(
                          text: _isSubmitting 
                            ? 'driverReviews.submitting'.tr() 
                            : 'driverReviews.submit'.tr(),
                          textStyle: AppTextTheme.getLightTextTheme(context).bodyLarge!,
                          onPressed: _isSubmitting 
                            ? () {} 
                            : () => _handleRatingSubmission(context),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
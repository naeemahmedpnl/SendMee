
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/ratings_provider/rating_provider.dart';
import 'package:sendme/viewmodel/provider/ridebook_provider.dart';
import 'package:sendme/widgets/custom_button.dart';
import 'package:sendme/utils/routes/user_panel_routes.dart';
// import 'package:sendme/widgets/custom_toast.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class RideReviewScreen extends StatefulWidget {
  @override
  _RideReviewScreenState createState() => _RideReviewScreenState();
}

class _RideReviewScreenState extends State<RideReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final rideProvider = Provider.of<RideProvider>(context);
    final ratingProvider = Provider.of<RatingProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 22.0,
              right: 22.0,
              top: 35.0,
              bottom: 22.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'review.thanks_message'.tr(args: ['Naeem']),
                  style: AppTextTheme.getLightTextTheme(context).headlineMedium,
                ),
                Text(
                  'review.enjoy_message'.tr(),
                  style: AppTextTheme.getLightTextTheme(context).bodyLarge,
                ),
                const SizedBox(height: 20.0),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'review.trip_route'.tr(),
                    style: AppTextTheme.getLightTextTheme(context).headlineMedium,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5FFE8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          const Icon(Icons.location_on_outlined, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              rideProvider.pickupAddress,
                              style: AppTextTheme.getLightTextTheme(context).bodyLarge,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          const Icon(Icons.location_on, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              rideProvider.dropoffAddress,
                              style: AppTextTheme.getLightTextTheme(context).bodyLarge,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),

                SizedBox(
                  height: screenHeight * 0.15,
                  width: double.infinity,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(24.8607, 67.0011),
                      zoom: 12.0,
                    ),
                    markers: _createMarkers(),
                  ),
                ),
                const SizedBox(height: 20.0),

                _buildRatingSection(context, ratingProvider),

                const SizedBox(height: 30.0),
                CustomButton(
                  text: 'review.submit_rating'.tr(),
                  onPressed: () => _submitRating(context, ratingProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Set<Marker> _createMarkers() {
    return <Marker>{
      Marker(
        markerId: const MarkerId('start'),
        position: const LatLng(-25.7479, 28.2293),
        infoWindow: InfoWindow(title: 'review.start_point'.tr()),
      ),
      Marker(
        markerId: const MarkerId('end'),
        position: const LatLng(-25.7479, 28.2293),
        infoWindow: InfoWindow(title: 'review.end_point'.tr()),
      ),
    };
  }

  Widget _buildRatingSection(BuildContext context, RatingProvider ratingProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'review.trip_rating_question'.tr(),
            style: AppTextTheme.getLightTextTheme(context).bodyLarge,
          ),
          const SizedBox(height: 10.0),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  ratingProvider.setRating(index + 1);
                },
                child: Icon(
                  index < (ratingProvider.rating ?? 0)
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.yellowAccent,
                  size: 32.0,
                ),
              );
            }),
          ),
          const SizedBox(height: 10.0),
          TextField(
            onChanged: (value) {
              ratingProvider.setFeedback(value);
            },
            decoration: InputDecoration(
              hintText: 'review.comments_hint'.tr(),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(color: Colors.black87),
            ),
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  void _submitRating(BuildContext context, RatingProvider ratingProvider) async {
    try {
      if (ratingProvider.rating == null) {
        developer.log('Rating not selected', name: 'RideReviewScreen');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('review.select_rating_error'.tr())),
        );
        return;
      }

      log(
        'Submitting rating: ${ratingProvider.rating}, feedback: ${ratingProvider.feedback}',
        name: 'RideReviewScreen'
      );
      bool success = await ratingProvider.submitRating();

      if (success) {
        log('Rating submitted successfully', name: 'RideReviewScreen');
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('currentTripId');
        
        log('Removed currentTripId from SharedPreferences', name: 'RideReviewScreen');

        // CustomToast.show(context, 'review.rating_success'.tr());

        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.parcelScreen,
          (Route<dynamic> route) => false,
        );
      } else {
        // CustomToast.show(context, 'review.rating_failed'.tr());
      }
    } catch (e, stackTrace) {
      log(
        'Error in _submitRating',
        error: e,
        stackTrace: stackTrace,
        name: 'RideReviewScreen',
      );
      // CustomToast.show(context, 'review.error_message'.tr());
    }
  }
}
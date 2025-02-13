import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rideapp/views/Driver_panel/add_card_details_view.dart';
import 'package:rideapp/views/Driver_panel/driver_authentication/driver_login.dart';
import 'package:rideapp/views/Driver_panel/driver_overview_view.dart';
import 'package:rideapp/views/Driver_panel/driver_registration/driver_signup_parcel_view.dart';
import 'package:rideapp/views/Driver_panel/driver_registration/driver_signup_view.dart';
import 'package:rideapp/views/Driver_panel/driver_reviews_screen.dart';
import 'package:rideapp/views/Driver_panel/form_registration/basic_info_view.dart';
import 'package:rideapp/views/Driver_panel/form_registration/driver_license_view.dart';
import 'package:rideapp/views/Driver_panel/form_registration/id_confirmation.dart';
import 'package:rideapp/views/Driver_panel/form_registration/proof_of_address.dart';
import 'package:rideapp/views/Driver_panel/form_registration/vehicle_info_view.dart';
// import 'package:rideapp/views/Driver_panel/messages/inbox_screen.dart';
import 'package:rideapp/views/Driver_panel/notifications_view.dart';
import 'package:rideapp/views/Driver_panel/payment_successful_view.dart';
import 'package:rideapp/views/Driver_panel/profile_screens/profile_view.dart';
import 'package:rideapp/views/Driver_panel/ride_screens/payment_details.dart';
import 'package:rideapp/views/Driver_panel/ride_screens/payment_method.dart';
import 'package:rideapp/views/Driver_panel/ride_screens/pick_up.dart';
import 'package:rideapp/views/Driver_panel/ride_screens/reached.dart';
import 'package:rideapp/views/Driver_panel/ride_screens/ride_booking_view.dart';
// import 'package:rideapp/views/Driver_panel/ride_screens/rider_history.dart';
import 'package:rideapp/views/Driver_panel/support_view.dart';
import 'package:rideapp/views/Driver_panel/vechile_info/brand_details_view.dart';
import 'package:rideapp/views/Driver_panel/vechile_info/vehicle_photos_view.dart';
import 'package:rideapp/views/Driver_panel/vechile_info/vehicle_registration_view.dart';
import 'package:rideapp/views/Driver_panel/wallet_view.dart';
import 'package:rideapp/views/Driver_panel/widgets/cancelrequest.dart';
import 'package:rideapp/views/User_panel/common_splash_view.dart';

// import '../../views/Driver_panel/ride_screens/rider_history.dart';

class AppDriverRoutes {
  static const String commonSplash = '/';

  // Driver Routes...
  static const String driverOverview = "/driver_overview";
  static const String driverSignup = "/driver_signup";
  static const String driverSignupParcel = "/driver_signup_parcel";
  static const String basicInfo = "/driverbasic_info";
  static const String driverLicense = "/driver_license";
  static const String idInfo = "/driver_id_info";
  static const String cnicInfo = "/driver_cnic_info";
  static const String vehicleInfo = "/driver_vehicle_info";
  static const String brandDetails = "/driver_brand_details";
  static const String vehiclePhotos = "/driver_vehicle_photos";
  static const String vehicleRegistration = "/driver_vehicle_registration";
  static const String rideBooking = "/driver_ride_booking";
  static const String profile = "/driver_profile";
  static const String messages = "/driver_messages";
  static const String wallet = "/driver_wallet";
  static const String notifications = "/driver_notifications";
  static const String support = "/driver_support";
  static const String showrides = "/drivershow_rides";
  static const String showridesdetails = "/drivershow_rides_details";
  static const String getdirection = "/driver_get_direction";
  static const String driverreached = "/driver_reched_screen";
  static const String paymentdetails = "/driver_payment_details";
  static const String paymentmethod = "/driver_payment_method";
  static const String paymentsuccesful = "/driver_payment_successful";
  static const String driverreview = "/driver_reviews_screen";
  static const String addcarddetails = "/driver_addcard_details";
  static const String driverlogin = "/driver_login_view";
  static const String drivercancelride = "/driver_cancel_ride";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case commonSplash:
      //   return MaterialPageRoute(builder: (context) => const CommonSplashView());
      case driverOverview:
        return MaterialPageRoute(
            builder: (context) => const DriverOverviewView());
      case driverSignup:
        return MaterialPageRoute(
            builder: (context) => const DriverSignupView());
      case driverSignupParcel:
        return MaterialPageRoute(
            builder: (context) => const DriverSignupParcelView());
      case basicInfo:
        return MaterialPageRoute(builder: (context) => const BasicInfoView());
      case driverLicense:
        return MaterialPageRoute(
            builder: (context) => const DriverLicenseView());
      case idInfo:
        return MaterialPageRoute(builder: (context) => const ProofOfAddress());
      case cnicInfo:
        return MaterialPageRoute(builder: (context) => const IdConfirmation());
      case vehicleInfo:
        return MaterialPageRoute(builder: (context) => const VehicleInfoView());
      case brandDetails:
        return MaterialPageRoute(
            builder: (context) => const BrandDetailsView());
      case vehiclePhotos:
        return MaterialPageRoute(
            builder: (context) => const VehiclePhotosView());
      case vehicleRegistration:
        return MaterialPageRoute(
            builder: (context) => const VehicleRegistrationView());
      case rideBooking:
        return MaterialPageRoute(builder: (context) => const RideBookingView());
      case profile:
        return MaterialPageRoute(builder: (context) => ProfileView());
      // case messages:
      //   return MaterialPageRoute(builder: (context) => MessagesScreen());
      case getdirection:
        final Map<String, dynamic> args =
            settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (context) => GetDirection(tripData: args));
      case wallet:
        return MaterialPageRoute(builder: (context) => WalletView());
      case driverreached:
        return MaterialPageRoute(builder: (context) => const ReachedScreen());
      case notifications:
        return MaterialPageRoute(
            builder: (context) => const NotificationsView());
      case paymentdetails:
        return MaterialPageRoute(builder: (context) => PaymentDetails());
      case paymentmethod:
        return MaterialPageRoute(
          builder: (context) => PaymentMethodScreen(
            estimatedFare: settings.arguments != null
                ? (settings.arguments as Map)['estimatedFare'] as String
                : null,
          ),
        );
      case paymentsuccesful:
        return MaterialPageRoute(
            builder: (context) => const PaymentSuccessfulView());
      case driverreview:
        return MaterialPageRoute(
            builder: (context) => const DriverReviewsView());
      case addcarddetails:
        return MaterialPageRoute(
            builder: (context) => const AddCardDetailsView());
      case drivercancelride:
        final args = settings.arguments as Map<String, dynamic>?;

        if (args != null &&
            args.containsKey('tripId') &&
            args.containsKey('fullData')) {
          log('Received data in drivercancelride route: $args',
              name: 'AppDriverRoutes');

          return MaterialPageRoute(
            builder: (context) => DriverCancelTripScreen(
              tripId: args['tripId'],
              tripData: args['fullData'],
            ),
          );
        } else {
          log('Invalid or missing data in drivercancelride route',
              name: 'AppDriverRoutes');
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(
                child: Text('Error: Invalid or missing trip data'),
              ),
            ),
          );
        }

      case driverlogin:
        return MaterialPageRoute(builder: (context) => const DriverLoginView());
      // case showridesdetails:
      //  final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
      //   return MaterialPageRoute(builder: (context) =>  ShowRiderDetails(
      //     tripData: args
      //   ));
      case support:
        return MaterialPageRoute(builder: (context) => SupportView());
      //   case showrides:
      //     return  MaterialPageRoute(
      // builder: (context) => RideDetailsScreen(rideDetails: {

      // },)
      // );
      default:
        return MaterialPageRoute(builder: (context) => CommonSplashView());
    }
  }
}

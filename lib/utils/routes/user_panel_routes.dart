import 'package:flutter/material.dart';
// Authentication Views
import 'package:sendme/views/User_panel/Authentication/change_password.dart';
import 'package:sendme/views/User_panel/Authentication/forgotpassword.dart';
import 'package:sendme/views/User_panel/Authentication/otp_screen.dart';
import 'package:sendme/views/User_panel/Authentication/reset_password.dart';
import 'package:sendme/views/User_panel/Authentication/user_account_view.dart';
import 'package:sendme/views/User_panel/Authentication/user_login_view.dart';
import 'package:sendme/views/User_panel/Authentication/user_signup_view.dart';
// Ride Booking Views
import 'package:sendme/views/User_panel/parcel_deliver/choose_driver.dart';
// import 'package:sendme/views/User_panel/RideBookScreens/payment_method_screen.dart';
import 'package:sendme/views/User_panel/parcel_deliver/rating_screen.dart';
import 'package:sendme/views/User_panel/parcel_deliver/show_rider_details.dart';
// import 'package:sendme/views/User_panel/RideBookScreens/widgets/drop_off_location.dart';
// Other Views
import 'package:sendme/views/User_panel/Support/support_screen.dart';
import 'package:sendme/views/User_panel/common_splash_view.dart';
import 'package:sendme/views/User_panel/history_screens/history_screen.dart';
import 'package:sendme/views/User_panel/parcel_deliver/parcel_booking.dart';
// Parcel Delivery Views
import 'package:sendme/views/User_panel/parcel_deliver/parcel_screen.dart';
import 'package:sendme/views/User_panel/parcel_deliver/recieving_parcel_screen.dart';
import 'package:sendme/views/User_panel/parcel_deliver/sending_parcel_screen.dart';
// Profile and Settings Views
import 'package:sendme/views/User_panel/profile_Screens/edit_profile.dart';
import 'package:sendme/views/User_panel/profile_Screens/profile_screen.dart';
import 'package:sendme/views/User_panel/profile_Screens/wallet_details.dart';

import '../../views/User_panel/Authentication/pessenger_id.dart';
// import '../../views/User_panel/parcel_deliver/payment_method_screen.dart';

class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route Names
  static const String commonSplash = '/';

  // Authentication Routes
  static const String userSignup = '/user_signup';
  static const String userAccountCreate = '/user_account_create';
  static const String userLogin = '/user_login';
  static const String userForgotPassword = '/user_forgotpassword';
  static const String resetPasswordScreen = '/user_resetpassword';
  static const String otpScreen = '/otp_screen';
  static const String changePassword = '/change_password';
  static const String idConfirmation = '/id_confirmation';

  // Main App Routes
  // static const String parcelScreen = '/user_home';
  static const String profileScreen = '/profile_screen';
  static const String editProfileScreen = '/edit_profile_screen';
  static const String historyScreen = '/history_screen';
  static const String walletScreen = '/wallet_screen';
  static const String supportScreen = '/support_screen';

  // Ride Booking Routes
  static const String rideBook = '/ride_book';
  static const String rideDetails = '/show_ride_details';
  static const String chooseDriver = '/choose_driver';
  static const String showRiderDetails = '/ride_details_screen';
  // static const String paymentMethod = '/payment_method_screen';
  static const String ratingScreen = '/rating_screen';
  static const String dropOffLocation = '/dropoff_location';

  // Parcel Delivery Routes
  static const String parcelScreen = '/parcel_screen';
  static const String parcelReceivingScreen = '/parcel_receiving_screen';
  static const String parcelSendingScreen = '/parcel_sending_screen';

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    try {
      return _getRoute(settings);
    } catch (e) {
      return _errorRoute();
    }
  }

  // Private helper method to generate routes
  static Route<dynamic> _getRoute(RouteSettings settings) {
    switch (settings.name) {
      // Splash and Auth Routes
      case commonSplash:
        return _buildRoute(CommonSplashView());

      case userSignup:
        return _buildRoute(const UserSignupView());

      case userAccountCreate:
        return _buildRoute(const UserAccountCreateView());

       case idConfirmation:
        return _buildRoute(const IdConfirmation());

      case userLogin:
        return _buildRoute(UserLoginView());

      case userForgotPassword:
        return _buildRoute(const UserForgotPassword());

      case changePassword:
        return _buildRoute(const ChangePassword());

      case otpScreen:
        return _buildRoute(const OtpScreen());

      case resetPasswordScreen:
        return _buildRoute(ResetPasswordScreen(
          email: settings.arguments as String,
        ));

      // Main App Routes
      case parcelScreen:
        return _buildRoute(const ParcelScreen());

      case profileScreen:
        return _buildRoute(const ProfileScreen());

      case editProfileScreen:
        return _buildRoute(const EditProfileScreen(userData: {}));

      case historyScreen:
        return _buildRoute(const HistoryScreen());

      case walletScreen:
        return _buildRoute(WalletScreen());

      case supportScreen:
        return _buildRoute(SupportScreen());

      // Ride Booking Routes
      case rideBook:
        return _buildRoute(const ParcelBookScreen());

      case rideDetails:
        return _handleRideDetailsRoute(settings);

      case chooseDriver:
        return _buildRoute(const ChooseDriverScreen(tripId: ''));

      // case paymentMethod:
      //   return _buildRoute(PaymentMethodScreen(
      //     estimatedFare: settings.arguments != null
      //         ? (settings.arguments as Map)['estimatedFare'] as String
      //         : null, 
      //   ));

      case ratingScreen:
        return _buildRoute(RideReviewScreen());

      // case dropOffLocation:
      //   return _buildRoute(RideBookingScreen());

      // Parcel Delivery Routes
      case parcelScreen:
        return _buildRoute(const ParcelScreen());

      case parcelReceivingScreen:
        return _buildRoute(ParcelRecievingScreen());

      case parcelSendingScreen:
        return _buildRoute(const ParcelSendingScreen());

      default:
        return _buildRoute(CommonSplashView());
    }
  }

  // Helper method to handle ride details route
  // In your route configuration
static Route<dynamic> _handleRideDetailsRoute(RouteSettings settings) {
  final args = settings.arguments as Map<String, dynamic>;
  return MaterialPageRoute(
    builder: (context) => ShowRiderDetails(
      tripDetails: args['tripDetails'],
      initialTripDetails: args['initialTripDetails'],
   
    )
  );
}
  // static Route<dynamic> _handleRideDetailsRoute(RouteSettings settings) {
  //   final args = settings.arguments as Map<dynamic, dynamic>;
  //   return _buildRoute(ShowRiderDetails(
  //     tripDetails: args['tripDetails'],
  //     initialTripDetails: args['initialTripDetails'],
  //   ));
  // }

  // Helper method to build MaterialPageRoute
  static MaterialPageRoute _buildRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }

  // Error route
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Error: Route not found'),
        ),
      ),
    );
  }
}




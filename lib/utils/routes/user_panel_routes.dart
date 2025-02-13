import 'package:flutter/material.dart';
// Authentication Views
import 'package:rideapp/views/User_panel/Authentication/change_password.dart';
import 'package:rideapp/views/User_panel/Authentication/forgotpassword.dart';
import 'package:rideapp/views/User_panel/Authentication/otp_screen.dart';
import 'package:rideapp/views/User_panel/Authentication/reset_password.dart';
import 'package:rideapp/views/User_panel/Authentication/user_account_view.dart';
import 'package:rideapp/views/User_panel/Authentication/user_login_view.dart';
import 'package:rideapp/views/User_panel/Authentication/user_signup_view.dart';
// Ride Booking Views
import 'package:rideapp/views/User_panel/RideBookScreens/choose_driver.dart';
import 'package:rideapp/views/User_panel/RideBookScreens/payment_method_screen.dart';
import 'package:rideapp/views/User_panel/RideBookScreens/rating_screen.dart';
import 'package:rideapp/views/User_panel/RideBookScreens/ride_book_screen.dart';
import 'package:rideapp/views/User_panel/RideBookScreens/show_rider_details.dart';
// import 'package:rideapp/views/User_panel/RideBookScreens/widgets/drop_off_location.dart';
// Other Views
import 'package:rideapp/views/User_panel/Support/support_screen.dart';
import 'package:rideapp/views/User_panel/common_splash_view.dart';
import 'package:rideapp/views/User_panel/history_screens/history_screen.dart';
import 'package:rideapp/views/User_panel/parcel_deliver/parcel_booking.dart';
// Parcel Delivery Views
import 'package:rideapp/views/User_panel/parcel_deliver/parcel_screen.dart';
import 'package:rideapp/views/User_panel/parcel_deliver/recieving_parcel_screen.dart';
import 'package:rideapp/views/User_panel/parcel_deliver/sending_parcel_screen.dart';
// Profile and Settings Views
import 'package:rideapp/views/User_panel/profile_Screens/edit_profile.dart';
import 'package:rideapp/views/User_panel/profile_Screens/profile_screen.dart';
import 'package:rideapp/views/User_panel/profile_Screens/wallet_details.dart';

import '../../views/User_panel/Authentication/pessenger_id.dart';

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
  static const String paymentMethod = '/payment_method_screen';
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

      case paymentMethod:
        return _buildRoute(PaymentMethodScreen(
          estimatedFare: settings.arguments != null
              ? (settings.arguments as Map)['estimatedFare'] as String
              : null, 
        ));

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
  static Route<dynamic> _handleRideDetailsRoute(RouteSettings settings) {
    final args = settings.arguments as Map<dynamic, dynamic>;
    return _buildRoute(ShowRiderDetails(
      tripDetails: args['tripDetails'],
      initialTripDetails: args['initialTripDetails'],
    ));
  }

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






// import 'package:flutter/material.dart';
// // import 'package:rideapp/views/Driver_panel/ride_screens/rider_history.dart';
// import 'package:rideapp/views/User_panel/Authentication/change_password.dart';
// import 'package:rideapp/views/User_panel/Authentication/reset_password.dart';
// import 'package:rideapp/views/User_panel/RideBookScreens/choose_driver.dart';
// import 'package:rideapp/views/User_panel/RideBookScreens/rating_screen.dart';
// import 'package:rideapp/views/User_panel/RideBookScreens/ride_book_screen.dart';
// import 'package:rideapp/views/User_panel/RideBookScreens/show_rider_details.dart';
// import 'package:rideapp/views/User_panel/RideBookScreens/widgets/drop_off_location.dart';
// import 'package:rideapp/views/User_panel/Support/support_screen.dart';
// import 'package:rideapp/views/User_panel/Authentication/forgotpassword.dart';
// import 'package:rideapp/views/User_panel/Authentication/otp_screen.dart';
// import 'package:rideapp/views/User_panel/Authentication/user_account_view.dart';
// import 'package:rideapp/views/User_panel/Authentication/user_login_view.dart';
// import 'package:rideapp/views/User_panel/Authentication/user_signup_view.dart';
// // import 'package:rideapp/views/User_panel/RideBookScreens/choose_driver.dart';
// import 'package:rideapp/views/User_panel/RideBookScreens/payment_method_screen.dart';

// import 'package:rideapp/views/User_panel/common_splash_view.dart';
// import 'package:rideapp/views/User_panel/history_screens/history_screen.dart';
// // import 'package:rideapp/views/User_panel/messages/inbox_screen.dart';
// // import 'package:rideapp/views/User_panel/messages/messages_screen.dart';
// import 'package:rideapp/views/User_panel/parcel_deliver/parcel_screen.dart';
// import 'package:rideapp/views/User_panel/parcel_deliver/recieving_parcel_screen.dart';
// import 'package:rideapp/views/User_panel/parcel_deliver/sending_parcel_screen.dart';
// import 'package:rideapp/views/User_panel/profile_Screens/edit_profile.dart';
// import 'package:rideapp/views/User_panel/profile_Screens/profile_screen.dart';
// import 'package:rideapp/views/User_panel/profile_Screens/wallet_details.dart';
// import 'package:rideapp/views/User_panel/user_home_view.dart'; 

// class AppRoutes {
//   static const String commonSplash = '/';
//   // static const String panelselect = 'panel_select';
//   static const String userSignup = '/user_signup';
//   static const String userAccountCreate = '/user_account_create';
//   static const String userLogin = '/user_login';
//   static const String userForgotPassword = '/user_forgotpassword';
//   static const String resetPasswordScreen = '/user_resetpassword';
//   static const String otpScreen = '/otp_screen';
//   static const String parcelScreen = '/user_home';
//   static const String rideBook = '/ride_book';
//   static const String rideDetails = '/show_ride_details';
//   static const String chooseDriver = '/choose_driver';
//   static const String showRiderDetails = '/ride_details_screen';
//   static const String paymentmethod = '/payment_method_screen';
//   static const String ratingscreen = '/rating_screen';
//   static const String profilescreen = '/profile_screen';
//   static const String editprofilescreen = '/edit_profile_screen';
//   static const String historyscreen = '/history_screen';
//   static const String walletscreen = '/wallet_screen';
//   static const String messagescreen = '/message_screen';
//   static const String chatscreen = '/chat_screen';
//   static const String parcelscreen = '/parcel_screen';
//   static const String parcelrecievingscreen = '/parcel_recieving_screen';
//   static const String parcelsendingscreen = '/parcel_sending_screen';
//   static const String supportscreen = '/support_screen';
//   static const String changepassword = '/changePassword';
//   static const String dropofflocation = '/dropofflocation';
  
//   // static get result => null;

//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case commonSplash:
//         return MaterialPageRoute(builder: (context) => CommonSplashView());
   
//       case userSignup:
//         return MaterialPageRoute(builder: (context) => const UserSignupView());
//       case userAccountCreate:
//         return MaterialPageRoute(builder: (context) => const UserAccountCreateView());
//       case userLogin:
//         return MaterialPageRoute(builder: (context) => UserLoginView());
//       case userForgotPassword:
//         return MaterialPageRoute(builder: (context) => const UserForgotPassword());
//       case changepassword:
//         return MaterialPageRoute(builder: (context) => const ChangePassword());
//       case otpScreen:
//         return MaterialPageRoute(builder: (context) => const OtpScreen());
//       case parcelScreen:
//         return MaterialPageRoute(builder: (context) => const parcelScreenView());
//       case resetPasswordScreen: 
//         return MaterialPageRoute(builder: (context) =>  ResetPasswordScreen(
//           email: settings.arguments as String,
//         ));
//       case rideBook:
//         return MaterialPageRoute(builder: (context) => const  RideHomeScreen()); 
//       // case rideDetails:
//       //   return MaterialPageRoute(builder: (context) => const ShowRiderDetails(
//       //     tripDetails: {},
//       //     initialTripDetails: {},
        
//       //   ));
//       case chooseDriver:
//         return MaterialPageRoute(builder: (context)=> const ChooseDriverScreen(
//           tripId: '',
       
          
//         ));
       
//     case rideDetails:
//         final args = settings.arguments as Map<dynamic, dynamic>;
//         return MaterialPageRoute(
//           builder: (context) => ShowRiderDetails(
//             tripDetails: (args['tripDetails']),
//             initialTripDetails: (args['initialTripDetails']),
//           ),
//         );

//   //     case AppRoutes.showRiderDetails:
//   // // final args = settings.arguments as Map<String, dynamic>;
//   // return MaterialPageRoute(
//   //   builder: (context) => ShowRiderDetails(rideDetails: {

//   //   },
//   //     // driverData: args['driverData'] as Map<String, dynamic>,
//   //   ),
//   // );
//       case paymentmethod:
//         return MaterialPageRoute(builder: (context) => PaymentMethodScreen());
//       case ratingscreen:
//         return MaterialPageRoute(builder: (context) => RideReviewScreen());
//       case profilescreen:
//         return MaterialPageRoute(builder: (context) =>  const ProfileScreen());
//       case dropofflocation:
//         return MaterialPageRoute(builder: (context) =>  RideBookingScreen(
          
//           ));
//       case editprofilescreen:
//         return MaterialPageRoute(builder: (context) =>  const EditProfileScreen(
//          userData:{
          
//          }
//         ));
//       case historyscreen:
//         return MaterialPageRoute(builder: (context) => const  HistoryScreen());
//       case walletscreen:
//         return MaterialPageRoute(builder: (context) =>  WalletScreen());
//       // case messagescreen:
//       //   return MaterialPageRoute(builder: (context) =>  MessagesScreen());
//       // case chatscreen:
//       //   return MaterialPageRoute(builder: (context) =>  ChatScreen());
//       case parcelscreen:
//         return MaterialPageRoute(builder: (context) => const ParcelScreen());
//       case parcelrecievingscreen:
//         return MaterialPageRoute(builder: (context)=>  ParcelRecievingScreen());
//       case parcelsendingscreen:
//         return MaterialPageRoute(builder: (context)=> const  ParcelSendingScreen());
//       case supportscreen:
//         return MaterialPageRoute(builder: (context)=>  SupportScreen());
//       default:
//         return MaterialPageRoute(builder: (context) => CommonSplashView());
//     }
//   }


// }
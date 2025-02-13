import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isStripeInitialized = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get baseUrl => Constants.apiBaseUrl;

  static const String _stripePublishableKey =
      'pk_test_51OO3YAIfSqUzfjxeDct2UULl9mnE7RkQnSeWSgg1RtekLTMwsXy6YbGhdhcPcT5xez6ZBXkBTSSyj9uvjWgO2TTh00BuOLVeuQ';

  PaymentProvider() {
    initializeStripe();
  }

  Future<void> initializeStripe() async {
    if (_isStripeInitialized) return;

    try {
      log('Initializing Stripe with live key...');
      Stripe.publishableKey = _stripePublishableKey;
      await Stripe.instance.applySettings();

      _isStripeInitialized = true;
      log('Stripe initialized successfully in live mode');
    } catch (e) {
      log('Stripe initialization error: $e');
      _errorMessage = 'Error al inicializar el sistema de pago';
      _isStripeInitialized = false;
      notifyListeners();
    }
  }

  Future<bool> makePayment(amount) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Clean and validate amount
      final cleanAmount = _cleanAmount(amount);
      if (double.tryParse(cleanAmount) == null ||
          double.parse(cleanAmount) <= 0) {
        throw 'Monto inválido';
      }

      log('Processing payment for amount: MXN \$$cleanAmount');

      // Ensure Stripe is initialized
      if (!_isStripeInitialized) {
        await initializeStripe();
        if (!_isStripeInitialized) {
          throw 'Error de inicialización de Stripe';
        }
      }

      // Create payment intent
      final paymentIntentResult = await _createPaymentIntent(cleanAmount);
      if (paymentIntentResult == null ||
          paymentIntentResult['clientSecret'] == null) {
        throw 'Error al crear la intención de pago';
      }

      // Initialize and present payment sheet
      await _initializePaymentSheet(paymentIntentResult['clientSecret']);
      await Stripe.instance.presentPaymentSheet();

      log('Payment completed successfully');
      return true;
    } catch (e) {
      log('Payment error occurred: $e');

      if (e is StripeException) {
        _handleStripeError(e);
      } else {
        _handleError(e.toString());
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _handleStripeError(StripeException e) {
    log('Stripe Error Details:');
    log('Code: ${e.error.code}');
    log('Message: ${e.error.message}');
    log('LocalizedMessage: ${e.error.localizedMessage}');
    log('StripeErrorCode: ${e.error.stripeErrorCode}');

    _handleError(_getReadableStripeError(e));
  }

  String _getReadableStripeError(StripeException e) {
    switch (e.error.code) {
      case FailureCode.Canceled:
        return 'Pago cancelado';
      case FailureCode.Failed:
        if (e.error.stripeErrorCode == 'card_declined') {
          return 'Tarjeta rechazada';
        } else if (e.error.stripeErrorCode == 'expired_card') {
          return 'Tarjeta expirada';
        } else if (e.error.stripeErrorCode == 'incorrect_cvc') {
          return 'CVC incorrecto';
        } else if (e.error.stripeErrorCode == 'insufficient_funds') {
          return 'Fondos insuficientes';
        } else if (e.error.stripeErrorCode == 'invalid_card') {
          return 'Tarjeta inválida';
        }
        return 'Error en el pago: ${e.error.localizedMessage}';
      default:
        return 'Error en el pago: Intente nuevamente';
    }
  }

  Future<void> _initializePaymentSheet(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Ride App',
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: const PaymentSheetAppearanceColors(
              // Primary brand color
              primary: Color(0xFF2962FF),
              // Background color of the payment sheet
              background: Colors.white,
              // Color for components like text fields
              componentBackground: Color(0xFFF8F9FA),
              // Border color for components
              componentBorder: Color(0xFFE9ECEF),
              // Divider color
              componentDivider: Color(0xFFE9ECEF),
              // Primary text color
              primaryText: Color(0xFF1A1F36),
              // Secondary text color
              secondaryText: Color(0xFF697386),
              // Text color on components
              componentText: Color(0xFF1A1F36),
              // Icon color
              icon: Color(0xFF2962FF),
              // Error color
              error: Color(0xFFFF3B30),
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: const PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFF2962FF),
                  text: Colors.white,
                  border: Color(0xFF2962FF),
                ),
              ),
              shapes: PaymentSheetPrimaryButtonShape(
                blurRadius: 8,
                borderWidth: 0,
                shadow: PaymentSheetShadowParams(
                  color: const Color(0xFF2962FF).withOpacity(0.25),
                  offset: const PaymentSheetShadowOffset(x: 4, y: 4),
                ),
              ),
            ),
            shapes: PaymentSheetShape(
              borderWidth: 1,
              borderRadius: 12,
              shadow: PaymentSheetShadowParams(
                color: Colors.black.withOpacity(0.1),
                offset: const PaymentSheetShadowOffset(x: 4, y: 4),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      log('Error initializing payment sheet: $e');
      throw 'Error al inicializar el pago';
    }
  }

  Future<Map<String, dynamic>?> _createPaymentIntent(String amount) async {
    try {
      final amountInCentavos = (double.parse(amount) * 100).round();

      final Map<String, dynamic> body = {
        'amount': amountInCentavos,
        'currency': 'mxn',
        'payment_method_types[]': 'card'
      };

      log('Creating payment intent with amount: $amountInCentavos centavos');

      final response = await http.post(
        Uri.parse('$baseUrl/stripe/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      log('Payment intent response status: ${response.statusCode}');
      log('Payment intent response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw 'Error del servidor: ${response.statusCode}';
    } catch (e) {
      log('Error creating payment intent: $e');
      throw 'Error al procesar el pago';
    }
  }

  String _cleanAmount(String amount) {
    // Remove any currency symbols, spaces, and non-numeric characters except decimal point
    String cleaned = amount.replaceAll(RegExp(r'[^0-9.]'), '');
    // Ensure only one decimal point
    int decimalCount = '.'.allMatches(cleaned).length;
    if (decimalCount > 1) {
      int firstDecimalIndex = cleaned.indexOf('.');
      cleaned = cleaned.substring(0, firstDecimalIndex + 1) +
          cleaned.substring(firstDecimalIndex + 1).replaceAll('.', '');
    }
    return cleaned;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _handleError(String error) {
    log('Payment error: $error');
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> updateWalletBalance(String userId, double amount) async {
    try {
      log('Updating wallet balance for user: $userId with amount: $amount');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/update-wallet-balance'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
        }),
      );

      log('Wallet update response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Wallet balance updated successfully. New balance: ${data['newWalletBalance']}');
        return true;
      } else {
        final error = jsonDecode(response.body)['error'];
        throw error ?? 'Failed to update wallet balance';
      }
    } catch (e) {
      log('Error updating wallet balance: $e');
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> processFullPayment(String amount, String userId) async {
    try {
      log('Starting full payment process for user: $userId');

      // First process Stripe payment
      final stripeSuccess = await makePayment(amount);

      if (stripeSuccess) {
        log('Stripe payment successful, updating wallet');

        // If Stripe payment successful, update wallet balance
        final walletSuccess = await updateWalletBalance(
          userId,
          double.parse(amount),
        );

        return walletSuccess;
      }

      return false;
    } catch (e) {
      log('Error in full payment process: $e');
      _errorMessage = 'Payment failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

// For wallet payment
  Future<bool> makeWalletPayment(String estimatedFare) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Get driver ID
      String? driverId = prefs.getString('driverId');
      String? userId = prefs.getString('userId');
      if (driverId == null) throw 'Driver ID not found';
      log('Driver IDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD: $driverId');

      if (userId == null) throw 'Driver ID not found';
      log('User IDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD: $userId');

      // Parse amount
      if (estimatedFare.isEmpty) throw 'Invalid amount';
      double amount = double.parse(estimatedFare);

      // Prepare request
      final requestBody = {
        "senderId": userId,
        "recipientId": driverId,
        "amount": amount
      };

      // Make API call
      final response = await http.post(
          Uri.parse('https://m5nkcs2p-3000.inc1.devtunnels.ms/auth/transferFromWallet'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody));

      // Log response
      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');
      log('============= End Wallet Payment =======wefwefwerwerwerwerwerwerwerwerwer======\n');

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw json.decode(response.body)['message'] ?? 'Payment failed';
      }
    } catch (e) {
      log('Wallet Payment Error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getWalletPayment( int amountInCents) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      log('Token not found');
      return false;
    }
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/stripe/create-oxxo-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('Wallet Payment Response: $responseData');
        return true;
      } else {
        _errorMessage = 'Payment failed. Please try again.';
        log('Paymenttttttt Error: ${response.body}');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error processing payment: $e';
      log('Payment Exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

//     Future<bool> getWalletPayment(int amount) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? token = prefs.getString('token');
//   if (token == null) {
//     log('Token not found');
//     return false;
//   }

//   try {
//     _isLoading = true;
//     _errorMessage = null;
//     notifyListeners();

//     final response = await http.get(
//       Uri.parse('$baseUrl/stripe/create-oxxo-payment?amount=$amount'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       log('Wallet Payment Response: $responseData');
//       return true;
//     } else {
//       _errorMessage = 'Payment failed. Please try again.';
//       log('Payment Error: ${response.body}');
//       return false;
//     }
//   } catch (e) {
//     _errorMessage = 'Error processing payment: $e';
//     log('Payment Exception: $e');
//     return false;
//   } finally {
//     _isLoading = false;
//     notifyListeners();
//   }
// }
}

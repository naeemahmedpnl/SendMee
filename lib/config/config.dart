import 'package:flutter_stripe/flutter_stripe.dart';

class StripeConfig {
  static const String publishableKey = 'your_publishable_key';
  
  static Future<void> init() async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }
}
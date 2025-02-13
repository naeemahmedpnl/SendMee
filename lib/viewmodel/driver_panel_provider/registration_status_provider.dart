import 'package:flutter/material.dart';

class RegistrationStatusProvider with ChangeNotifier {
  bool isBasicIntroCompleted = false;

  void toggleBasicIntroCompletionStatus() {
    isBasicIntroCompleted = !isBasicIntroCompleted;
    notifyListeners();
  }
}

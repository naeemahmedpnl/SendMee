// lib/models/radio_selection_model.dart
import 'package:flutter/material.dart';

class RadioSelectionModel with ChangeNotifier {
  String? _selectedOption;

  String? get selectedOption => _selectedOption;

  void selectOption(String? option) {
    _selectedOption = option;
    notifyListeners(); 
  }
}

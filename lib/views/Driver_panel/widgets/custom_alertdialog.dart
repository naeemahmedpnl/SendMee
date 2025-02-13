import 'package:flutter/material.dart';
import 'package:sendme/views/Driver_panel/widgets/custom_text_field.dart';
import 'package:sendme/widgets/custom_button.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_text_theme.dart';
import 'custom_snackbar.dart';

class CustomAlertDialog extends StatefulWidget {
  final String title;
  final String lableDisplayedText;
  final Function(String)? onSave;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.lableDisplayedText,
    this.onSave,
  });

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  final TextEditingController _numberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _saveData() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    
    if (widget.onSave != null) {
      widget.onSave!(_numberController.text);
    }
    
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackbar.buildCustomSnackbar(displayText: "Successfully saved!"),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      backgroundColor: AppColors.backgroundDark,
      title: Text(widget.title),
      content: SizedBox(
        height: screenHeight * 0.09,
        width: screenWidth * 0.75,
        child: Form(
          key: _formKey,
          child: CustomTextFormField(
            hintText: widget.lableDisplayedText,
            
            controller: _numberController,
            validator: (value) {
              if (value == null || value.isEmpty || value.trim().length < 6) {
                return '*Please enter at least 6 characters.';
              }
              return null;
            },
        
          ),
        ),
      ),
      actions: [
        CustomButton(
          text: "Save",
          textStyle: AppTextTheme.getLightTextTheme(context).bodyLarge!,
          onPressed: _saveData,
        ),
      ],
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/views/Driver_panel/vechile_info/widgets/image_picker.dart';
import 'package:sendme/views/Driver_panel/widgets/custom_text_field.dart';
import 'package:sendme/widgets/custom_button.dart';

class RegistrationFormWidget extends StatefulWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;
  final VoidCallback onPickFrontSideImage;
  final VoidCallback onPickBackSideImage;
  final File? pickedFrontSideImage;
  final File? pickedBackSideImage;

  const RegistrationFormWidget({
    required this.controller,
    required this.formKey,
    required this.onSave,
    required this.onPickFrontSideImage,
    required this.onPickBackSideImage,
    this.pickedFrontSideImage,
    this.pickedBackSideImage,
    Key? key,
  }) : super(key: key);

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Form(
      key: widget.formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: screenHeight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Vehicle Production Year",
              style: AppTextTheme.getDarkTextTheme(context).bodyLarge,
            ),
            SizedBox(height: screenHeight * 0.003),
            CustomTextFormField(
              icon: Icons.numbers,
              hintText: "",
              controller: widget.controller,
              onSaved: (value) {},
              validator: (value) {
                if (value == null || value.isEmpty || value.trim().length < 8) {
                  return '*Please enter at least 8 characters.';
                }
                return null;
              },
              isNumber: true,
            ),
            ImagePickerWidget(
              context: context,
              imageFile: widget.pickedFrontSideImage,
              label: "Certificate of vehicle registration (Front side)",
              onPickImage: widget.onPickFrontSideImage,
            ),
            ImagePickerWidget(
              context: context,
              imageFile: widget.pickedBackSideImage,
              label: "Certificate of vehicle registration (Back side)",
              onPickImage: widget.onPickBackSideImage,
            ),
            SizedBox(height: screenHeight * 0.02),
            CustomButton(
              text: "Save",
              textStyle: AppTextTheme.getLightTextTheme(context).headlineSmall!,
              onPressed: widget.onSave,
              borderRadius: 44,
            ),
          ],
        ),
      ),
    );
  }
}

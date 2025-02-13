import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';
import 'package:rideapp/views/Driver_panel/widgets/custom_text_field.dart';
import 'package:rideapp/widgets/custom_button.dart';

class AddCardDetailsView extends StatefulWidget {
  const AddCardDetailsView({super.key});

  @override
  State<AddCardDetailsView> createState() => _AddCardDetailsViewState();
}

class _AddCardDetailsViewState extends State<AddCardDetailsView> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;

  void _addCardDetails() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          "Add Card Details",
          style: AppTextTheme.getDarkTextTheme(context).headlineSmall,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.backgroundLight,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: screenHeight * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Card Details",
                  style: AppTextTheme.getDarkTextTheme(context).titleLarge,
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                Container(
                  height: screenHeight * 0.62,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.02),
                            child: Text(
                              "Add Card",
                              style: AppTextTheme.getLightTextTheme(context)
                                  .titleLarge,
                            ),
                          ),
                          Text(
                            "Enter the card details",
                            style: AppTextTheme.getLightTextTheme(context)
                                .titleMedium,
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Text(
                            "Account holder name",
                            style: AppTextTheme.getLightTextTheme(context)
                                .bodyLarge,
                          ),
                          SizedBox(
                            height: screenHeight * 0.002,
                          ),
                          SizedBox(
                            child: CustomTextFormField(
                  
                              hintText: "",
                              fillColor:
                                  const Color.fromARGB(255, 173, 173, 173),
                              filled: true,
                              style: AppTextTheme.getLightTextTheme(context)
                                  .titleLarge,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '* Please enter account holder name';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.005,
                          ),
                          Text(
                            "Card number",
                            style: AppTextTheme.getLightTextTheme(context)
                                .bodyLarge,
                          ),
                          SizedBox(
                            height: screenHeight * 0.002,
                          ),
                          SizedBox(
                            child: CustomTextFormField(
                              // contentPadding: const EdgeInsets.symmetric(
                              //     vertical: 10, horizontal: 20.0),
                              hintText: "",
                              fillColor:
                                  const Color.fromARGB(255, 173, 173, 173),
                              filled: true,
                              style: AppTextTheme.getLightTextTheme(context)
                                  .titleLarge,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 8) {
                                  return '* Please enter atleast 8 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.005,
                          ),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Expiration Date",
                                    style:
                                        AppTextTheme.getLightTextTheme(context)
                                            .bodyLarge,
                                  ),
                                  Container(
                                    height: screenHeight * 0.06,
                                    width: screenWidth * 0.38,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 173, 173, 173),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: screenWidth * 0.03),
                                          child: Text(
                                            _selectedDate == null
                                                ? "Date"
                                                : DateFormat.yMMMd()
                                                    .format(_selectedDate!),
                                            style: const TextStyle(
                                              color: Color(0xff666666),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            showDatePicker(
                                              context: context,
                                              firstDate: DateTime(2024, 1, 1),
                                              lastDate: DateTime(2024, 12, 31),
                                            ).then(
                                              (pickedDate) {
                                                setState(() {
                                                  _selectedDate = pickedDate!;
                                                });
                                              },
                                            );
                                          },
                                          icon: Image.asset(
                                              "assets/icons/calender.png"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: screenWidth * 0.08,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "CVV",
                                    style:
                                        AppTextTheme.getLightTextTheme(context)
                                            .bodyLarge,
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.32,
                                    child: CustomTextFormField(
                                      hintText: "",
                                      fillColor: const Color.fromARGB(
                                          255, 173, 173, 173),
                                      filled: true,
                                      isNumber: true,
                                      style: AppTextTheme.getLightTextTheme(
                                              context)
                                          .titleLarge,
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            value.trim().length < 3) {
                                          return '* Please enter atleast 3 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.05,
                          ),
                          CustomButton(
                            text: "Add Card",
                            textStyle: AppTextTheme.getLightTextTheme(context)
                                .bodyLarge!,
                            onPressed: _addCardDetails,
                            borderRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
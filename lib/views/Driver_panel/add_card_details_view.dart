import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/widgets/custom_button.dart';

import '../../utils/theme/app_colors.dart';

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
        title: const Text(
          "Add Card Details",
          style: TextStyle(
            color: Color(0xffB1A0A0),
            fontFamily: "Montserrat",
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xffB1A0A0),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // padding:
          // const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 40),
                child: Text(
                  "Add Card Details",
                  style: TextStyle(
                    color: Color(0xffB1A0A0),
                    fontWeight: FontWeight.w600,
                    fontFamily: "Montserrat",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: screenHeight * 0.55,
                  width: screenWidth * 0.85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add Card",
                            style: TextStyle(
                              color: AppTextTheme.getLightTextTheme(context)
                                  .headlineMedium!
                                  .color,
                              fontSize: 14,
                              fontWeight:
                                  AppTextTheme.getLightTextTheme(context)
                                      .headlineLarge!
                                      .fontWeight,
                              fontFamily: "Montserrat",
                            ),
                          ),
                          Text(
                            "Enter the card details",
                            style: TextStyle(
                              color: AppTextTheme.getLightTextTheme(context)
                                  .bodyMedium!
                                  .color,
                              fontFamily: "Montserrat",
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.005,
                          ),
                          Text(
                            "Account holder name",
                            style: TextStyle(
                              color: AppTextTheme.getLightTextTheme(context)
                                  .bodyMedium!
                                  .color,
                              fontWeight:
                                  AppTextTheme.getLightTextTheme(context)
                                      .titleLarge!
                                      .fontWeight,
                              fontFamily: "Montserrat",
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.002,
                          ),
                          SizedBox(
                            child: TextFormField(
                              style: const TextStyle(
                                color: Color(0xff666666),
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w600,
                              ),
                              onSaved: (value) {
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '* Please enter account holder name';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                fillColor:
                                    const Color.fromARGB(255, 173, 173, 173),
                                helperText: " ",
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 12.0),
                                hintStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 248, 209, 109),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2),
                                  borderRadius: BorderRadius.circular(
                                      8), // same shape as other borders
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2),
                                  borderRadius: BorderRadius.circular(
                                      8), // same shape as other borders
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   height: screenHeight * 0.001,
                          // ),
                          Text(
                            "Card number",
                            style: TextStyle(
                              color: AppTextTheme.getLightTextTheme(context)
                                  .bodyMedium!
                                  .color,
                              fontWeight:
                                  AppTextTheme.getLightTextTheme(context)
                                      .titleLarge!
                                      .fontWeight,
                              fontFamily: "Montserrat",
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.002,
                          ),
                          SizedBox(
                            child: TextFormField(
                              style: const TextStyle(
                                color: Color(0xff666666),
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w600,
                              ),
                              onSaved: (value) {
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 8) {
                                  return '* Please enter atleast 8 characters';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                fillColor:
                                    const Color.fromARGB(255, 173, 173, 173),
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 12.0),
                                hintStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 248, 209, 109),
                                      width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2),
                                  borderRadius: BorderRadius.circular(
                                      8), // same shape as other borders
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2),
                                  borderRadius: BorderRadius.circular(
                                      8), // same shape as other borders
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Expiration Date",
                                    style: TextStyle(
                                      color: AppTextTheme.getLightTextTheme(
                                              context)
                                          .bodyMedium!
                                          .color,
                                      fontWeight:
                                          AppTextTheme.getLightTextTheme(
                                                  context)
                                              .titleLarge!
                                              .fontWeight,
                                      fontFamily: "Montserrat",
                                    ),
                                  ),
                                  Container(
                                    height: screenHeight * 0.04,
                                    width: screenWidth * 0.36,
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
                                              "assets/Icons/calender.png"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 50,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "CVV",
                                    style: TextStyle(
                                      color: AppTextTheme.getLightTextTheme(
                                              context)
                                          .bodyMedium!
                                          .color,
                                      fontWeight:
                                          AppTextTheme.getLightTextTheme(
                                                  context)
                                              .titleLarge!
                                              .fontWeight,
                                      fontFamily: "Montserrat",
                                    ),
                                  ),
                                  // Container(
                                  //   height: screenHeight * 0.06,
                                  //   width: screenWidth * 0.2,
                                  //   decoration: BoxDecoration(
                                  //     color:
                                  //         const Color.fromARGB(255, 173, 173, 173),
                                  //     borderRadius: BorderRadius.circular(8),
                                  //   ),
                                  //   child:
                                  SizedBox(
                                    width: screenWidth * 0.32,
                                    // height: screenHeight * 0.04,
                                    // height: 50,
                                    child: TextFormField(
                                      style: const TextStyle(
                                        color: Color(0xff666666),
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                      ),
                                      onSaved: (value) {
                                      },
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            value.trim().length < 3) {
                                          return '* Please enter atleast 3 characters';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        fillColor: const Color.fromARGB(
                                            255, 173, 173, 173),
                                        filled: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                // vertical: 6.0,
                                                horizontal: 12.0),
                                        hintStyle: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.white, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Color.fromARGB(
                                                  255, 248, 209, 109),
                                              width: 2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          // gapPadding: 10,
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 2),
                                          borderRadius: BorderRadius.circular(
                                              8), // same shape as other borders
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 2),
                                          borderRadius: BorderRadius.circular(
                                              8), // same shape as other borders
                                        ),
                                      ),
                                    ),
                                  ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.022,
                          ),
                          CustomButton(
                            text: "Add Card",
                            textStyle: TextStyle(
                              fontWeight:
                                  AppTextTheme.getLightTextTheme(context)
                                      .headlineMedium!
                                      .fontWeight,
                              color: AppTextTheme.getLightTextTheme(context)
                                  .headlineMedium!
                                  .color,
                              fontSize: AppTextTheme.getLightTextTheme(context)
                                  .titleLarge!
                                  .fontSize,
                              fontFamily: "Montserrat",
                            ),
                            onPressed: _addCardDetails,
                            borderRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

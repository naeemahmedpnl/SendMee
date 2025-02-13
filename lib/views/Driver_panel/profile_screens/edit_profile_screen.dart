import 'package:flutter/material.dart';
import 'package:rideapp/utils/routes/driver_panel_routes.dart';
import 'package:rideapp/utils/theme/app_colors.dart';
import 'package:rideapp/utils/theme/app_text_theme.dart';
import 'package:rideapp/widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Andriew Julia');
  final _phoneController = TextEditingController(text: '+923150362310');
  final _addressController = TextEditingController(
      text: 'Gulshan-e-Jamal Block C Gulshan e Jamal, Karachi');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      Text(
                        "Edit Profile",
                        style: AppTextTheme.getDarkTextTheme(context)
                            .headlineSmall,
                      ),
                      const SizedBox(width: 50),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone No',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Save Changes",
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Handle the form submission logic here
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppDriverRoutes.addcarddetails);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Add Card Details",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isKeyboardVisible)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Keyboard is visible'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

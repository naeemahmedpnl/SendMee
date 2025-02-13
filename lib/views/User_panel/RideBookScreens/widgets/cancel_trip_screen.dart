

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rideapp/viewmodel/provider/cancel_trip_request.dart';
import 'package:rideapp/widgets/custom_button.dart';
import 'package:rideapp/utils/routes/user_panel_routes.dart';

class UserCancelTripScreen extends StatefulWidget {
  final Map<String, dynamic> tripDetails;
  final Map<String, dynamic> initialTripDetails;
  
  const UserCancelTripScreen({
    Key? key, 
    required this.tripDetails, 
    required this.initialTripDetails
  }) : super(key: key);

  @override
  _UserCancelTripScreenState createState() => _UserCancelTripScreenState();
}

class _UserCancelTripScreenState extends State<UserCancelTripScreen> {
  String? _selectedOption;

  final List<String> _cancellationReasons = [
    'cancel_trip.reason_no_need',
    'cancel_trip.reason_change_booking',
    'cancel_trip.reason_no_contact',
    'cancel_trip.reason_driver_issue',
    'cancel_trip.reason_plan_changed',
    'cancel_trip.reason_other'
  ];

  Future<void> _cancelTrip(BuildContext context) async {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('cancel_trip.select_reason_error'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final provider = Provider.of<CancelTripRequest>(context, listen: false);
      final tripId = widget.initialTripDetails['_id'];

      final success = await provider.cancelTrip(tripId, _selectedOption!);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('cancel_trip.success_message'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.parcelScreen);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'cancel_trip.error_message'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('cancel_trip.error_message'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('cancel_trip.title'.tr()),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'cancel_trip.reason_prompt'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Optional debug info - uncomment if needed
              // if (kDebugMode) ...[
              //   Text('Trip ID: ${widget.initialTripDetails['_id']}', 
              //        style: const TextStyle(color: Colors.white)),
              //   Text('Pickup: ${widget.initialTripDetails['pickup']}', 
              //        style: const TextStyle(color: Colors.white)),
              //   Text('Destination: ${widget.initialTripDetails['destination']}', 
              //        style: const TextStyle(color: Colors.white)),
              //   Text('Driver: ${widget.initialTripDetails['driver']['username']}', 
              //        style: const TextStyle(color: Colors.white)),
              //   Text('Estimated Fare: \$${widget.initialTripDetails['driverEstimatedFare']}', 
              //        style: const TextStyle(color: Colors.white)),
              // ],
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _cancellationReasons.length,
                  itemBuilder: (context, index) => 
                    _buildRadioOption(_cancellationReasons[index]),
                ),
              ),
              Consumer<CancelTripRequest>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'cancel_trip.confirm_button'.tr(),
                       onPressed: () => _cancelTrip(context),
                    isLoading: provider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          value.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        leading: Radio<String>(
          value: value,
          groupValue: _selectedOption,
          activeColor: Colors.deepOrange,
          onChanged: (String? newValue) {
            setState(() {
              _selectedOption = newValue;
            });
          },
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
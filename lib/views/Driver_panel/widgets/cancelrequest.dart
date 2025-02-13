
import 'dart:developer' as developer;
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendme/utils/routes/driver_panel_routes.dart';
import 'package:sendme/viewmodel/provider/cancel_trip_request.dart';
import 'package:sendme/widgets/custom_button.dart';

class DriverCancelTripScreen extends StatefulWidget {
   final String tripId;
  final Map<String, dynamic> tripData;
  
  const DriverCancelTripScreen({Key? key,  required this.tripId,
    required this.tripData,}) : super(key: key);

  @override
  _DriverCancelTripScreenState createState() => _DriverCancelTripScreenState();
}

class _DriverCancelTripScreenState extends State<DriverCancelTripScreen> {
  String? _selectedOption;


@override
  void initState() {
    super.initState();
    log('DriverDriverCancelTripScreen initialized with tripId: ${widget.tripId}', name: 'DriverDriverCancelTripScreen');
  }


  final List<String> _cancellationReasons = [
    "I don't need a ride anymore",
    "I want to change my booking details.",
    "I couldn't contact the captain.",
    "Driver isn't moving or asked me to cancel.",
    "Plan changed",
    "Other"
  ];

  Future<void> _cancelTrip(BuildContext context) async {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason for cancellation')),
      );
      return;
    }

    final provider = Provider.of<CancelTripRequest>(context, listen: false);
    final tripId = widget.tripData['result']['_id'];

    // Log the trip ID being used
    developer.log('Cancelling trip with ID: $tripId', name: 'DriverCancelTripScreen');

    final success = await provider.cancelTrip(tripId, _selectedOption!);

    if (!mounted) return;

    if (success) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip cancelled successfully')),
      );
      Navigator.pushReplacementNamed(context, AppDriverRoutes.rideBooking);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to cancel trip')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Log the full trip data received
    developer.log('Full trip data received: ${widget.tripData}', name: 'DriverCancelTripScreen');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Cancel Trip'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell us why you want to cancel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _cancellationReasons.map((reason) => _buildRadioOption(reason)).toList(),
              ),
            ),
            Consumer<CancelTripRequest>(
              builder: (context, provider, child) {
                return CustomButton(
                  text: "Cancel Trip",
                  onPressed: () => _cancelTrip(context),
                  isLoading: provider.isLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    return ListTile(
      title: Text(value, style: const TextStyle(color: Colors.white)),
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
    );
  }
}
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:sendme/viewmodel/provider/trip_history_provider.dart';
import 'package:sendme/widgets/custom_button.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    // Initialize trip data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripHistoryProvider>(context, listen: false).fetchTrips();
    });
  }

  // Helper method to get the appropriate trip list based on status
  List<Map<String, dynamic>> _getFilteredData(TripHistoryProvider provider) {
    // First, get the appropriate trip list based on the selected index
    List<TripModel> trips = switch (_selectedIndex) {
      0 => provider.pendingTrips,
      1 => provider.completedTrips,
      2 => provider.cancelledTrips,
      _ => []
    };

    // Convert each trip to a map and format the values appropriately
    return trips.map((trip) {
      final map = trip.toMap();
      
      // Format currency values consistently
      map['amount'] = '\$${trip.estimatedFare.toStringAsFixed(2)}';
      map['baseFare'] = '\$${trip.baseFare.toStringAsFixed(2)}';
      map['distanceFare'] = '\$${trip.distanceFare.toStringAsFixed(2)}';
      map['platformFee'] = '\$${trip.platformFee.toStringAsFixed(2)}';
      map['totalAmount'] = '\$${trip.totalAmount.toStringAsFixed(2)}';
      
      // Add service-specific information
      if (trip.serviceType == 'parcel') {
        map['serviceInfo'] = 'Parcel Delivery';
        if (trip.parcelType != null) {
          map['serviceInfo'] += ' (${trip.parcelType})';
        }
      }
      
      // Format status for display
      map['status'] = trip.status.replaceAll('_', ' ').toUpperCase();
      
      return map;
    }).toList();
  }

  // Helper method to get status-specific colors
  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'completed' => Colors.green,
      'started' => Colors.blue,
      'driver_accepted' => Colors.orange,
      'cancelled' || 'rejected' => Colors.red,
      _ => Colors.grey
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'history.title'.tr(),
          style: AppTextTheme.getLightTextTheme(context).headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<TripHistoryProvider>(
          builder: (context, provider, child) {
            // Show loading indicator while fetching data
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show error state with retry button if there's an error
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.error!,
                      style: AppTextTheme.getLightTextTheme(context).titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Retry',
                      onPressed: () => provider.fetchTrips(),
                    ),
                  ],
                ),
              );
            }

            final filteredData = _getFilteredData(provider);

            return Column(
              children: [
                _buildStatusTabs(MediaQuery.of(context).size.width),
                const SizedBox(height: 10),
                Expanded(
                  child: filteredData.isEmpty
                      ? _buildEmptyState()
                      : _buildTripsList(filteredData),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final messages = {
      0: 'No pending trips',
      1: 'No completed trips',
      2: 'No cancelled trips'
    };
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            messages[_selectedIndex] ?? 'No trips found',
            style: AppTextTheme.getLightTextTheme(context).headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(List<Map<String, dynamic>> trips) {
    return ListView.builder(
      itemCount: trips.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) => _buildHistoryItem(trips[index]),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _showDetailsDialog(item),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.buttonColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['serviceInfo'] ?? item['serviceType'] ?? 'Trip',
                        style: AppTextTheme.getLightTextTheme(context).titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['dateTime'],
                        style: AppTextTheme.getLightTextTheme(context).bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['amount'],
                        style: AppTextTheme.getLightTextTheme(context).headlineLarge,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['status'],
                          style: TextStyle(
                            color: _getStatusColor(item['status']),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 

  Widget _buildStatusTabs(double screenWidth) {
    final statuses = [
      'history.status.pending'.tr(),
      'history.status.completed'.tr(),
      'history.status.cancelled'.tr()
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 18.0, right: 18.0),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.buttonColor),
        ),
        child: Row(
          children: statuses.asMap().entries.map((entry) {
            return Expanded(
              child: _buildStatusButton(entry.value, entry.key, screenWidth),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusButton(String text, int index, double screenWidth) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        height: 55,
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }


  void _showDetailsDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _DetailsDialog(item: item),
    );
  }
}

class _DetailsDialog extends StatefulWidget {
  final Map<String, dynamic> item;

  const _DetailsDialog({Key? key, required this.item}) : super(key: key);

  @override
  _DetailsDialogState createState() => _DetailsDialogState();
}

class _DetailsDialogState extends State<_DetailsDialog> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogHeader(),
            const SizedBox(height: 16),
            _buildDialogTabs(),
            const SizedBox(height: 16),
            _buildDialogContent(),
            _buildDoneButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Column(
      children: [
        Text(
          widget.item['serviceInfo'] ?? widget.item['serviceType'] ?? 'Trip Details',
          style: AppTextTheme.getPrimaryTextTheme(context).headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          widget.item['dateTime'],
          style: AppTextTheme.getLightTextTheme(context).bodyMedium,
        ),
      ],
    );
  }

  Widget _buildDialogTabs() {
    final tabs = widget.item['serviceType'] == 'parcel' 
        ? ['Summary', 'Receipt', 'Parcel Info']
        : ['Summary', 'Receipt'];

    return Container(
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.backgroundLight),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          return Expanded(
            child: _buildDialogTabButton(entry.value, entry.key),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDialogContent() {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: SingleChildScrollView(
        child: switch (_selectedIndex) {
          0 => _buildSummaryContent(),
          1 => _buildReceiptContent(),
          2 => _buildParcelContent(),
          _ => const SizedBox(),
        },
      ),
    );
  }

  Widget _buildSummaryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Details',
          style: AppTextTheme.getLightTextTheme(context).titleLarge,
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Status', widget.item['status']),
        _buildInfoRow('Pickup', widget.item['pickupAddress']),
        _buildInfoRow('Destination', widget.item['destinationAddress']),
        _buildInfoRow('Service Type', widget.item['serviceType'].toUpperCase()),
        if (widget.item['parcelType'] != null)
          _buildInfoRow('Delivery Type', widget.item['parcelType'].toUpperCase()),
      ],
    );
  }

  Widget _buildReceiptContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fare Breakdown',
          style: AppTextTheme.getLightTextTheme(context).titleLarge,
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Base Fare', widget.item['baseFare']),
        _buildInfoRow(
          'Distance (${widget.item['distanceKm']} km)', 
          widget.item['distanceFare']
        ),
        _buildInfoRow('Platform Fee', widget.item['platformFee']),
        const Divider(color: Colors.black26, thickness: 1),
        _buildInfoRow('Total Amount', widget.item['totalAmount']),
      ],
    );
  }

  Widget _buildParcelContent() {
    if (widget.item['serviceType'] != 'parcel') {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parcel Information',
          style: AppTextTheme.getLightTextTheme(context).titleLarge,
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Sender Name', widget.item['senderName'] ?? 'N/A'),
        _buildInfoRow('Sender Phone', widget.item['senderPhone'] ?? 'N/A'),
        _buildInfoRow('Receiver Name', widget.item['receiverName'] ?? 'N/A'),
        _buildInfoRow('Receiver Phone', widget.item['receiverPhone'] ?? 'N/A'),
        if (widget.item['packageDetails'] != null) ...[
          const Divider(color: Colors.black26, thickness: 1),
          Text(
            'Package Details',
            style: AppTextTheme.getLightTextTheme(context).titleMedium,
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Max Dimensions', 
            widget.item['packageDetails']['maxDimensions'] ?? 'N/A'),
          _buildInfoRow('Max Weight', 
            '${widget.item['packageDetails']['maxWeight']} kg'),
          _buildInfoRow('Description', 
            widget.item['packageDetails']['description'] ?? 'N/A'),
        ],
      ],
    );
  }





  Widget _buildDialogTabButton(String text, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        height: double.infinity,
        margin: const EdgeInsets.all(2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.buttonColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextTheme.getLightTextTheme(context).titleMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextTheme.getLightTextTheme(context).titleLarge,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: CustomButton(
          text: 'history.button.done'.tr(),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

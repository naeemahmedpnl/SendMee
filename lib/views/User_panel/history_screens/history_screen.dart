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
    // Use addPostFrameCallback to avoid the build-time provider access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripHistoryProvider>(context, listen: false).fetchTrips();
    });
  }

  List<Map<String, dynamic>> _getFilteredData(TripHistoryProvider provider) {
    List<TripModel> trips;

    switch (_selectedIndex) {
      case 0:
        trips = provider.pendingTrips;
        break;
      case 1:
        trips = provider.completedTrips;
        break;
      case 2:
        trips = provider.cancelledTrips;
        break;
      default:
        trips = [];
    }

    return trips.map((trip) => trip.toMap()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'history.title'.tr(),
          style: AppTextTheme.getLightTextTheme(context).headlineMedium
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<TripHistoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final filteredData = _getFilteredData(provider);

            return Column(
              children: [
                _buildStatusTabs(screenWidth),
                const SizedBox(height: 10),
                Expanded(
                  child: filteredData.isEmpty
                    ? Center(
                        child: Text(
                          'No trips found',
                          style: AppTextTheme.getLightTextTheme(context).headlineMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) => _buildHistoryItem(filteredData[index]),
                      ),
                ),
              ],
            );
          },
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
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['id'],
                    style: AppTextTheme.getLightTextTheme(context).headlineMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['dateTime'],
                    style: AppTextTheme.getLightTextTheme(context).titleMedium,
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
                    item['amount'].toString(),
                    style: AppTextTheme.getLightTextTheme(context).headlineLarge
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['status'],
                    style: AppTextTheme.getPrimaryTextTheme(context).titleMedium,
                  ),
                ],
              ),
            ),
          ],
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
    return Center(
      child: Text(
        widget.item['id'],
        style: AppTextTheme.getPrimaryTextTheme(context).headlineSmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDialogTabs() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.backgroundLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDialogTabButton('history.tabs.summary'.tr(), 0),
          ),
          Expanded(
            child: _buildDialogTabButton('history.tabs.receipt'.tr(), 1),
          ),
        ],
      ),
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

  Widget _buildDialogContent() {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: SingleChildScrollView(
        child: _selectedIndex == 0 ? _buildSummaryContent() : _buildReceiptContent(),
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

  Widget _buildSummaryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'history.summary.address'.tr(),
          style: AppTextTheme.getLightTextTheme(context).titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Pickup Address', widget.item['pickupAddress']),
        _buildInfoRow('Destination Address', widget.item['destinationAddress']),
        _buildInfoRow('Booking Time', widget.item['dateTime']),
        _buildInfoRow('Status', widget.item['status']),
      ],
    );
  }
Widget _buildReceiptContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Base Fare', '${widget.item['baseFare']}'),
        _buildInfoRow('Distance (${widget.item['distanceKm']} km)', '${widget.item['distanceFare']}'),
        _buildInfoRow('Platform Fee', '${widget.item['platformFee']}'),
        const Divider(color: Colors.black26, thickness: 1),
        _buildInfoRow('Total Amount', '${widget.item['totalAmount']}'),
      ],
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

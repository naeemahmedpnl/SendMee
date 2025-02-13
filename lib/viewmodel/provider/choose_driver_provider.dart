import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sendme/utils/location_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer' as dev;
import 'dart:convert';

class ChooseDriverProvider with ChangeNotifier {
  IO.Socket? socket;
  Map<String, dynamic> driverData = {};
  bool isDriverAccepted = false;
  bool isConnected = false;

  void connectToSocket(String apiBaseUrl, String tripId) {
    dev.log("ChooseDriverProvider - Attempting to connect to socket");
    socket = IO.io(apiBaseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket?.connect();

    socket?.onConnect((_) {
      dev.log('ChooseDriverProvider - Socket connected successfully');
      isConnected = true;
      notifyListeners();
      joinTripRoom(tripId);
    });

    socket?.onDisconnect((_) {
      dev.log('ChooseDriverProvider - Socket disconnected');
      isConnected = false;
      notifyListeners();
    });

    socket?.onConnectError((err) => dev.log('ChooseDriverProvider - Socket connect error: $err'));
    socket?.onError((err) => dev.log('ChooseDriverProvider - Socket error: $err'));

    socket?.on('driver_accepted_trip', (data) {
      dev.log('ChooseDriverProvider - Received driver_accepted_trip event: ${json.encode(data)}');
      handleDriverAccepted(data);
    });

    socket?.on('driver_location_updated', (data) {
      dev.log('ChooseDriverProvider - Received driver_location_updated event: ${json.encode(data)}');
      updateDriverLocation(data);
    });

    dev.log('ChooseDriverProvider - All socket event listeners set up');
  }

  void joinTripRoom(String tripId) {
    socket?.emit('join-room', tripId);
    dev.log('ChooseDriverProvider - Emitted join-room event for tripId: $tripId');
  }

  void handleDriverAccepted(dynamic data) {
    dev.log('ChooseDriverProvider - handleDriverAccepted called with data: ${json.encode(data)}');
    
    driverData = {
      'tripId': data['_id'],
      'status': data['status'],
      'driver': {
        'id': data['driver']['_id'],
        'name': data['driver']['username'] ?? 'Unknown Driver',
        'profilePicture': data['driver']['profilePicture'],
        'ratingAverage': data['driver']['ratingAverage'],
        'tripsCount': data['driver']['tripsCount'],
        'vehicleDetails': data['driver']['vehicleDetails'],
      },
      'driverEstimatedFare': data['driverEstimatedFare'],
      'pickup': data['pickup'],
      'destination': data['destination'],
      'driverLocation': data['driverLocation'],
      'driverToPickupInfo': 'Calculating...',
    };
    isDriverAccepted = true;
    notifyListeners();
    calculateDriverToPickupInfo();
  }

  Future<void> calculateDriverToPickupInfo() async {
    dev.log('ChooseDriverProvider - Calculating driver to pickup info');
    if (driverData['driverLocation'] != null && driverData['pickup'] != null) {
      LatLng driverLatLng = LatLng(
        driverData['driverLocation']['latitude'],
        driverData['driverLocation']['longitude']
      );
      LatLng pickupLatLng = _parseLatLng(driverData['pickup']);
      
      Map<String, dynamic> info = await LocationUtils.calculateDriverToPickupDistanceAndTime(
        driverLatLng,
        pickupLatLng
      );
      
      dev.log('ChooseDriverProvider - Driver to pickup info calculated: $info');
      
      driverData['driverToPickupInfo'] = "To pickup: ${info['distance']} | ${info['duration']}";
      notifyListeners();
    } else {
      dev.log('ChooseDriverProvider - Unable to calculate driver to pickup info: driverLocation or pickup is null');
    }
  }

  LatLng _parseLatLng(String latLngString) {
    List<String> parts = latLngString.split(',');
    return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  }

  void updateDriverLocation(dynamic data) {
    dev.log('ChooseDriverProvider - Updating driver location: ${json.encode(data)}');
    if (driverData['driverLocation'] != null) {
      driverData['driverLocation'] = data['location'];
      notifyListeners();
      calculateDriverToPickupInfo();
    }
  }

  void reset() {
    driverData = {};
    isDriverAccepted = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    dev.log('ChooseDriverProvider - dispose');
    socket?.disconnect();
    socket?.dispose();
  }
}


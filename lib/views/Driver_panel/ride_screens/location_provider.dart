
// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// // import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:sendme/utils/constant/api_base_url.dart';
// // import 'package:sendme/views/Driver_panel/ride_screens/location.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class TripProvider extends ChangeNotifier {
//   // Socket instance
//   late IO.Socket socket;

//   // Base URL
//   String get baseUrl => Constants.apiBaseUrl;

//   // Trip State
//   String? currentTripId;
//   bool isMovingToPickup = true;
//   bool hasPickedUpPassenger = false;
//   bool isNear500m = false;
//   bool hasArrivedAtDestination = false;

//   // Map State
//   List<LatLng> routePoints = [];
//   int currentRouteIndex = 0;
//   Set<Marker> markers = {};
//   Set<Polyline> polylines = {};
//   LatLng? driverPosition;

//   TripProvider() {
//     _initializeSocket();
//   }

//   void _initializeSocket() {
//     socket = IO.io(baseUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     socket.onConnect((_) {
//       debugPrint('Socket Connected');
//       // Listen for any trip updates from passenger
//       socket.on('trip_status_update', _handleTripStatusUpdate);
//     });

//     socket.onError((error) => debugPrint('Socket Error: $error'));
//     socket.onDisconnect((_) => debugPrint('Socket Disconnected'));
//   }

//   void _handleTripStatusUpdate(dynamic data) {
//     if (data['status'] == 'cancelled') {
//       hasArrivedAtDestination = true;
//       notifyListeners();
//     }
//   }


//   // API Methods
//   Future<void> startTrip(
//       String tripId, LatLng pickupLocation, LatLng dropoffLocation) async {
//     log('Starting trip', name: 'TripProvider');
//     log('Trip ID: $tripId', name: 'TripProvider');
//     log('Pickup Location: ${pickupLocation.latitude},${pickupLocation.longitude}',
//         name: 'TripProvider');

//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/trip/start/$tripId'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'latitude': driverPosition?.latitude,
//           'longitude': driverPosition?.longitude,
//         }),
//       );

//       if (response.statusCode == 200) {
//         log('Trip started successfully', name: 'TripProvider');
//         currentTripId = tripId;
//         hasPickedUpPassenger = true;
//         isMovingToPickup = false;
//         notifyListeners();
//       } else {
//         log('Failed to start trip: ${response.body}',
//             name: 'TripProvider', error: true);
//         throw Exception('Failed to start trip: ${response.body}');
//       }
//     } catch (e) {
//       log('Start trip API error', name: 'TripProvider', error: e);
//       throw Exception('Start trip API error: $e');
//     }
//   }

//   Future<void> updateDriverLocationAPI(String tripId, LatLng position) async {
//     final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       log("Token for API call: $token");

//       if (token == null) {
//         log("Token not found");
//         return;
//       };

//     log('Updating driver location', name: 'TripProvider');
//     log('Current Position: ${position.latitude},${position.longitude}',
//         name: 'TripProvider');
//     log('Moving to ${isMovingToPickup ? "Pickup" : "Destination"}',
//         name: 'TripProvider');

//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/trip/update-driver-location/$tripId'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'latitude': position.latitude,
//           'longitude': position.longitude,
//         }),
//       );

//       if (response.statusCode == 200) {
//         log('Location updated successfully', name: 'TripProvider');
//         driverPosition = position;
//         _updateDriverMarker(position);
//         notifyListeners();
//       } else {
//         log('Failed to update location: ${response.body}',
//             name: 'TripProvider', error: true);
//         throw Exception('Failed to update location: ${response.body}');
//       }
//     } catch (e) {
//       log('Update location API error', name: 'TripProvider', error: e);
//       throw Exception('Update location API error: $e');
//     }
//   }

//   Future<void> endTripAPI() async {
//     log('Ending trip', name: 'TripProvider');
//     log('Trip ID: $currentTripId', name: 'TripProvider');

//     try {
//       if (currentTripId == null) {
//         log('No active trip to end', name: 'TripProvider', error: true);
//         throw Exception('No active trip');
//       }

//       final response = await http.put(
//         Uri.parse('$baseUrl/trip/completed/$currentTripId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         log('Trip completed successfully', name: 'TripProvider');
//         hasArrivedAtDestination = true;
//         notifyListeners();
//       } else {
//         log('Failed to complete trip: ${response.body}',
//             name: 'TripProvider', error: true);
//         throw Exception('Failed to complete trip: ${response.body}');
//       }
//     } catch (e) {
//       log('Complete trip API error', name: 'TripProvider', error: e);
//       throw Exception('Complete trip API error: $e');
//     }
//   }

//   // Enhanced State Methods with Logging
//   void setPickedUpPassenger(bool status) {
//     log('Setting pickupPassenger: $status', name: 'TripProvider');
//     hasPickedUpPassenger = status;
//     isMovingToPickup = !status;
//     notifyListeners();
//   }

//   void setIsNear500m(bool status) {
//     log('Setting isNear500m: $status', name: 'TripProvider');
//     isNear500m = status;
//     notifyListeners();
//   }

//   // Map Update Methods
//   void _updateDriverMarker(LatLng position) {
//     markers.removeWhere((marker) => marker.markerId.value == 'driver');
//     markers.add(
//       Marker(
//         markerId: const MarkerId('driver'),
//         position: position,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         infoWindow: const InfoWindow(title: 'Driver Location'),
//       ),
//     );
//   }

//   // State Update Methods
//   void updateDriverPosition(LatLng newPosition) {
//     driverPosition = newPosition;
//     _updateDriverMarker(newPosition);
//     notifyListeners();
//   }

//   void setRoutePoints(List<LatLng> points) {
//     routePoints = points;
//     notifyListeners();
//   }

//   void setMarkers(Set<Marker> newMarkers) {
//     markers = newMarkers;
//     notifyListeners();
//   }

//   void setPolylines(Set<Polyline> newPolylines) {
//     polylines = newPolylines;
//     notifyListeners();
//   }

//   void setArrivedAtDestination(bool status) {
//     hasArrivedAtDestination = status;
//     notifyListeners();
//   }
// }



import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendme/utils/constant/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class TripProvider extends ChangeNotifier {

  // Socket instance
  IO.Socket? socket;
  bool _disposed = false;

  // Connectivity check
  final Connectivity _connectivity = Connectivity();
  bool isOffline = false;
  
  // Retry mechanism
  int maxRetries = 3;
  
  // Keep track of pending operations for retries
  List<Map<String, dynamic>> _pendingUploads = [];

  // Base URL
  String get baseUrl => Constants.apiBaseUrl;

  // Trip State
  String? currentTripId;
  bool isMovingToPickup = true;
  bool hasPickedUpPassenger = false;
  bool isNear500m = false;
  bool hasArrivedAtDestination = false;

  // Map State
  List<LatLng> routePoints = [];
  int currentRouteIndex = 0;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  LatLng? driverPosition;

  // Image handling
  File? deliveryProofImage;
  bool isUploadingImage = false;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Error state
  String? lastError;
  bool hasNetworkError = false;

  TripProvider() {
    _initializeConnectivity();
    _initializeSocket();
  }



Future<void> _initializeConnectivity() async {
  // Listen for connectivity changes
  _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  
  // Check initial connectivity
  try {
    final results = await _connectivity.checkConnectivity();
    await _updateConnectionStatus(results);
  } catch (e) {
    log('Failed to check connectivity: $e', name: 'TripProvider');
  }
}

Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
  bool wasOffline = isOffline;
  
  // We're offline if ALL connections are none or if there are no connections
  isOffline = results.isEmpty || results.every((result) => result == ConnectivityResult.none);
  
  log('Connectivity changed: $results, isOffline: $isOffline', name: 'TripProvider');
  
  // If we were offline but now have connection, retry pending operations
  if (wasOffline && !isOffline) {
    log('Connection restored - retrying pending operations', name: 'TripProvider');
    _retryPendingOperations();
  }
  
  if (!_disposed) notifyListeners();
}


  Future<void> _retryPendingOperations() async {
    // Try to reconnect socket
    _reconnectSocket();
    
    // Process any pending uploads
    if (_pendingUploads.isNotEmpty) {
      log('Retrying ${_pendingUploads.length} pending uploads', name: 'TripProvider');
      
      List<Map<String, dynamic>> uploads = List.from(_pendingUploads);
      _pendingUploads.clear();
      
      for (var upload in uploads) {
        if (upload['type'] == 'completeTrip') {
          await endTripAPI(
            serviceType: upload['serviceType'],
            retry: false // Avoid infinite recursion
          );
        }
      }
    }
  }
  
  void _reconnectSocket() {
    if (socket == null || !socket!.connected) {
      log('Attempting to reconnect socket', name: 'TripProvider');
      _initializeSocket();
    }
  }

  void _initializeSocket() {
    try {
      socket = IO.io(baseUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
      });

      socket?.onConnect((_) {
        log('Socket Connected', name: 'TripProvider');
        hasNetworkError = false;
        if (!_disposed) notifyListeners();
        // Listen for any trip updates from passenger
        socket?.on('trip_status_update', _handleTripStatusUpdate);
      });

      socket?.onError((error) {
        log('Socket Error: $error', name: 'TripProvider');
        hasNetworkError = true;
        if (!_disposed) notifyListeners();
      });
      
      socket?.onConnectError((error) {
        log('Socket Connection Error: $error', name: 'TripProvider');
        hasNetworkError = true;
        if (!_disposed) notifyListeners();
      });

      socket?.onDisconnect((_) {
        log('Socket Disconnected', name: 'TripProvider');
      });
      
      socket?.onReconnect((_) {
        log('Socket Reconnected', name: 'TripProvider');
        hasNetworkError = false;
        if (!_disposed) notifyListeners();
      });
    } catch (e) {
      log('Socket initialization error: $e', name: 'TripProvider');
      hasNetworkError = true;
      if (!_disposed) notifyListeners();
    }
  }

  void _handleTripStatusUpdate(dynamic data) {
    if (data['status'] == 'cancelled') {
      hasArrivedAtDestination = true;
      if (!_disposed) notifyListeners();
    }
  }

  // Method to capture an image with better resource management
  Future<bool> captureDeliveryProofImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera, 
        imageQuality: 80,
        maxWidth: 1280,
        maxHeight: 720,
      );
      
      if (image != null) {
        // First, dispose any existing image file
        if (deliveryProofImage != null) {
          try {
            // Clear previous image
            deliveryProofImage = null;
          } catch (e) {
            log('Error disposing previous image: $e', name: 'TripProvider');
          }
        }
        
        deliveryProofImage = File(image.path);
        lastError = null;
        if (!_disposed) notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      log('Error capturing image: $e', name: 'TripProvider');
      lastError = 'Failed to capture image: $e';
      if (!_disposed) notifyListeners();
      return false;
    }
  }
  
  // Save image locally for offline mode
  Future<bool> _saveImageLocally() async {
    if (deliveryProofImage == null) return false;
    
    try {
      // Generate a unique filename
      final prefs = await SharedPreferences.getInstance();
      final tripImagesJson = prefs.getString('trip_images') ?? '{}';
      final tripImages = json.decode(tripImagesJson) as Map<String, dynamic>;
      
      if (currentTripId != null) {
        // Store the path to this image
        tripImages[currentTripId!] = deliveryProofImage!.path;
        await prefs.setString('trip_images', json.encode(tripImages));
        log('Saved image locally for trip: $currentTripId', name: 'TripProvider');
        return true;
      }
      return false;
    } catch (e) {
      log('Error saving image locally: $e', name: 'TripProvider');
      return false;
    }
  }
  
 
  // Method to clear the image if user wants to retake
  void clearDeliveryProofImage() {
    deliveryProofImage = null;
    lastError = null;
    if (!_disposed) notifyListeners();
  }

  // API Methods with improved error handling
  Future<void> startTrip(
      String tripId, LatLng pickupLocation, LatLng dropoffLocation) async {
    log('Starting trip', name: 'TripProvider');
    log('Trip ID: $tripId', name: 'TripProvider');
    log('Pickup Location: ${pickupLocation.latitude},${pickupLocation.longitude}',
        name: 'TripProvider');

    if (isOffline) {
      lastError = 'No internet connection. Please try again when connectivity is restored.';
      if (!_disposed) notifyListeners();
      throw Exception('No internet connection');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/trip/start/$tripId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': driverPosition?.latitude,
          'longitude': driverPosition?.longitude,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        log('Trip started successfully', name: 'TripProvider');
        currentTripId = tripId;
        hasPickedUpPassenger = true;
        isMovingToPickup = false;
        hasNetworkError = false;
        lastError = null;
        if (!_disposed) notifyListeners();
      } else {
        log('Failed to start trip: ${response.body}',
            name: 'TripProvider');
        lastError = 'Failed to start trip: ${response.body}';
        if (!_disposed) notifyListeners();
        throw Exception('Failed to start trip: ${response.body}');
      }
    } catch (e) {
      log('Start trip API error', name: 'TripProvider', error: e);
      
      if (e is SocketException || e is TimeoutException) {
        hasNetworkError = true;
        lastError = 'Connection issue. Please check your internet connection.';
      } else {
        lastError = 'Failed to start trip: $e';
      }
      
      if (!_disposed) notifyListeners();
      throw Exception('Start trip API error: $e');
    }
  }

  Future<Map<String, dynamic>?> updateDriverLocationAPI(String tripId, LatLng position) async {
  if (_disposed) {
    log('Ignoring update - provider disposed', name: 'TripProvider');
    return null;
  }
  
  if (isOffline) return null; // Skip updates if offline

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      log("Token not found", name: 'TripProvider');
      return null;
    }

    log('Updating driver location', name: 'TripProvider');
    log('Current Position: ${position.latitude},${position.longitude}', name: 'TripProvider');

    final response = await http.put(
      Uri.parse('$baseUrl/trip/update-driver-location/$tripId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'latitude': position.latitude,
        'longitude': position.longitude,
      }),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Location update timed out');
      },
    );

    final responseBody = jsonDecode(response.body);
    
    if (response.statusCode == 200 && responseBody['success'] == true) {
      log('Location updated successfully', name: 'TripProvider');
      driverPosition = position;
      _updateDriverMarker(position);
      hasNetworkError = false;
      if (!_disposed) notifyListeners();
      return responseBody;
    } else {
      log('Failed to update location: ${response.body}', name: 'TripProvider');
      return responseBody; // Return response for error handling
    }
  } catch (e) {
    log('Update location API error', name: 'TripProvider', error: e);

    if (e is SocketException || e is TimeoutException) {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        isOffline = true;
        if (!_disposed) notifyListeners();
      }
    }

    return {'success': false, 'message': 'Update location API error: $e'};
  }
}


  // Future<void> updateDriverLocationAPI(String tripId, LatLng position) async {
  //   if (_disposed) {
  //     log('Ignoring update - provider disposed', name: 'TripProvider');
  //     return;
  //   }
    
  //   // Skip location updates if offline to prevent log spam
  //   if (isOffline) {
  //     return;
  //   }
    
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token');
      
  //     if (token == null) {
  //       log("Token not found", name: 'TripProvider');
  //       return;
  //     }

  //     log('Updating driver location', name: 'TripProvider');
  //     log('Current Position: ${position.latitude},${position.longitude}',
  //         name: 'TripProvider');
  //     log('Moving to ${isMovingToPickup ? "Pickup" : "Destination"}',
  //         name: 'TripProvider');

  //     final response = await http.put(
  //       Uri.parse('$baseUrl/trip/update-driver-location/$tripId'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json'
  //       },
  //       body: jsonEncode({
  //         'latitude': position.latitude,
  //         'longitude': position.longitude,
  //       }),
  //     ).timeout(
  //       const Duration(seconds: 10),
  //       onTimeout: () {
  //         throw TimeoutException('Location update timed out');
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       log('Location updated successfully', name: 'TripProvider');
  //       driverPosition = position;
  //       _updateDriverMarker(position);
  //       hasNetworkError = false;
  //       if (!_disposed) notifyListeners();
  //     } else {
  //       log('Failed to update location: ${response.body}',
  //           name: 'TripProvider');
  //       throw Exception('Failed to update location: ${response.body}');
  //     }
  //   } catch (e) {
  //     // Don't show errors for location updates in UI, but log them
  //     log('Update location API error', name: 'TripProvider', error: e);
      
  //     if (e is SocketException || e is TimeoutException) {
  //       // Check connectivity
  //       final result = await _connectivity.checkConnectivity();
  //       if (result == ConnectivityResult.none) {
  //         isOffline = true;
  //         if (!_disposed) notifyListeners();
  //       }
  //     }
      
  //     throw Exception('Update location API error: $e');
  //   }
  // }


 // Updated method to end trip with optional image upload and retry logic
  Future<void> endTripAPI({String? serviceType, bool retry = true}) async {
    try {
      if (currentTripId == null) {
        throw Exception('No active trip');
      }
      
      // Check connectivity first
      if (isOffline) {
        log('Device is offline - saving operation for later', name: 'TripProvider');
        lastError = 'No internet connection. Your trip will be completed when connectivity is restored.';
        
        // Save the operation for retry when connectivity is restored
        if (retry) {
          _pendingUploads.add({
            'type': 'completeTrip',
            'tripId': currentTripId,
            'serviceType': serviceType,
            'timestamp': DateTime.now().millisecondsSinceEpoch
          });
          
          // For parcel deliveries, save the image locally
          if (serviceType == 'parcel' && deliveryProofImage != null) {
            await _saveImageLocally();
          }
        }
        
        // Still mark trip as completed in UI, even if it's pending server sync
        hasArrivedAtDestination = true;
        isUploadingImage = false;
        if (!_disposed) notifyListeners();
        return;
      }
      
      isUploadingImage = true;
      lastError = null;
      if (!_disposed) notifyListeners();
      
      // If this is a parcel delivery and we have an image
      if (serviceType == 'parcel' && deliveryProofImage != null) {
        // Make sure the file exists and is readable
        if (!await deliveryProofImage!.exists()) {
          throw Exception('Image file does not exist or was deleted');
        }
        
        try {
          // Create multipart request with retry logic
          for (int attempt = 0; attempt < maxRetries; attempt++) {
            try {
              var request = http.MultipartRequest(
                'PUT',
                Uri.parse('$baseUrl/trip/completed/$currentTripId'),
              );
              
              // Add the image file
              var imageFile = await http.MultipartFile.fromPath(
                'deliveryProofImage',
                deliveryProofImage!.path,
                contentType: MediaType('image', 'jpeg'),
              );
              request.files.add(imageFile);
              
              // Add current location
              if (driverPosition != null) {
                request.fields['latitude'] = driverPosition!.latitude.toString();
                request.fields['longitude'] = driverPosition!.longitude.toString();
              }
              
              // Send the request with timeout
              var streamedResponse = await request.send().timeout(
                const Duration(seconds: 15),
                onTimeout: () {
                  throw TimeoutException('Request timed out');
                },
              );
              
              var response = await http.Response.fromStream(streamedResponse);
              
              if (response.statusCode == 200) {
                log('Trip completed successfully with image', name: 'TripProvider');
                hasArrivedAtDestination = true;
                deliveryProofImage = null;
                isUploadingImage = false;
                hasNetworkError = false;
                if (!_disposed) notifyListeners();
                return;
              } else {
                log('Request failed with status: ${response.statusCode}', name: 'TripProvider');
                // Only throw on the final attempt
                if (attempt == maxRetries - 1) {
                  throw Exception('Failed to complete trip: ${response.body}');
                }
              }
            } catch (e) {
              log('Attempt ${attempt + 1} failed: $e', name: 'TripProvider');
              // Only throw on the final attempt
              if (attempt == maxRetries - 1) {
                rethrow;
              }
              
              // Wait before retrying
              await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
            }
          }
        } catch (e) {
          log('All retry attempts failed: $e', name: 'TripProvider');
          
          // Save for later retry if connection issue
          if (e is SocketException || e is TimeoutException) {
            if (retry) {
              _pendingUploads.add({
                'type': 'completeTrip',
                'tripId': currentTripId,
                'serviceType': serviceType,
                'timestamp': DateTime.now().millisecondsSinceEpoch
              });
              
              await _saveImageLocally();
              
              // Still mark as complete in UI to allow user to continue
              hasArrivedAtDestination = true;
              lastError = 'Connection issue. Your trip will be completed when connectivity is restored.';
            }
          } else {
            lastError = 'Failed to upload image: $e';
          }
          
          isUploadingImage = false;
          hasNetworkError = true;
          if (!_disposed) notifyListeners();
          throw Exception('Error uploading image: $e');
        }
      } else {
        // Regular trip completion without image - also with retries
        for (int attempt = 0; attempt < maxRetries; attempt++) {
          try {
            final response = await http.put(
              Uri.parse('$baseUrl/trip/completed/$currentTripId'),
              headers: {'Content-Type': 'application/json'},
              body: driverPosition != null 
                  ? jsonEncode({
                      'latitude': driverPosition!.latitude,
                      'longitude': driverPosition!.longitude,
                    })
                  : null,
            ).timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                throw TimeoutException('Request timed out');
              },
            );

            if (response.statusCode == 200) {
              log('Regular trip completed successfully', name: 'TripProvider');
              hasArrivedAtDestination = true;
              isUploadingImage = false;
              hasNetworkError = false;
              if (!_disposed) notifyListeners();
              return;
            } else {
              log('Request failed with status: ${response.statusCode}', name: 'TripProvider');
              // Only throw on the final attempt
              if (attempt == maxRetries - 1) {
                throw Exception('Failed to complete trip: ${response.body}');
              }
            }
          } catch (e) {
            log('Attempt ${attempt + 1} failed: $e', name: 'TripProvider');
            // Only throw on the final attempt
            if (attempt == maxRetries - 1) {
              // Save for later retry if connection issue
              if (e is SocketException || e is TimeoutException) {
                if (retry) {
                  _pendingUploads.add({
                    'type': 'completeTrip',
                    'tripId': currentTripId,
                    'timestamp': DateTime.now().millisecondsSinceEpoch
                  });
                  
                  // Still mark as complete in UI to allow user to continue
                  hasArrivedAtDestination = true;
                  lastError = 'Connection issue. Your trip will be completed when connectivity is restored.';
                }
              } else {
                lastError = 'Failed to complete trip: $e';
              }
              
              isUploadingImage = false;
              hasNetworkError = true;
              if (!_disposed) notifyListeners();
              throw Exception('Complete trip API error: $e');
            }
            
            // Wait before retrying
            await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
          }
        }
      }
    } catch (e) {
      isUploadingImage = false;
      if (e is SocketException || e is TimeoutException) {
        hasNetworkError = true;
      }
      
      if (!_disposed) notifyListeners();
      log('Complete trip API error', name: 'TripProvider', error: e);
      throw Exception('Complete trip API error: $e'); 
    }
  }
  


  @override
  void dispose() {
    _disposed = true;
    
    // Clean up socket connection
    if (socket != null) {
      if (socket!.connected) {
        socket!.disconnect();
      }
      socket!.dispose();
      socket = null;
    }
    
    // Clean up image
    deliveryProofImage = null;
    
    super.dispose();
  }

  
 


  // Map Update Methods
  void _updateDriverMarker(LatLng position) {
    markers.removeWhere((marker) => marker.markerId.value == 'driver');
    markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Driver Location'),
      ),
    );
  }

  // State Update Methods
  void updateDriverPosition(LatLng newPosition) {
    driverPosition = newPosition;
    _updateDriverMarker(newPosition);
    if (!_disposed) notifyListeners();
  }

  void setRoutePoints(List<LatLng> points) {
    routePoints = points;
    if (!_disposed) notifyListeners();
  }

  void setMarkers(Set<Marker> newMarkers) {
    markers = newMarkers;
    if (!_disposed) notifyListeners();
  }

  void setPolylines(Set<Polyline> newPolylines) {
    polylines = newPolylines;
    if (!_disposed) notifyListeners();
  }

  void setArrivedAtDestination(bool status) {
    hasArrivedAtDestination = status;
    if (!_disposed) notifyListeners();
  }

}
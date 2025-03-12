

import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sendme/utils/theme/app_colors.dart';
import 'package:sendme/utils/theme/app_text_theme.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddressSearch extends SearchDelegate<Map<String, dynamic>> {
  static final _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']; 
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';
  
  late LatLng _currentLocation;
  late String _countryCode;
  bool _isLocationInitialized = false;

  final http.Client _client;

  AddressSearch({http.Client? client}) : _client = client ?? http.Client();

  Future<void> _initializeLocation() async {
  if (_isLocationInitialized) return;

  try {
    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || 
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    _currentLocation = LatLng(position.latitude, position.longitude);

    // Use reverse geocoding to determine country
    _countryCode = await _getCountryCode(position.latitude, position.longitude);
    
    _isLocationInitialized = true;
  } catch (e) {
    // Fallback to default location in Zimbabwe (using Harare coordinates)
    _currentLocation = const LatLng(-17.8292, 31.0522);
    _countryCode = 'zw'; // Zimbabwe country code
    _isLocationInitialized = true;
  }
}

Future<String> _getCountryCode(double lat, double lng) async {
  final params = {
    'latlng': '$lat,$lng',
    'key': _apiKey,
  };

  final uri = Uri.parse('$_baseUrl/geocode/json').replace(queryParameters: params);
  
  try {
    final response = await _client.get(uri);
    final result = json.decode(response.body);
    
    if (result['status'] == 'OK') {
      // Loop through address components to find country code
      for (var component in result['results'][0]['address_components']) {
        if (component['types'].contains('country')) {
          return component['short_name'].toLowerCase();
        }
      }
    }
    return 'zw'; 
  } catch (e) {
    return 'zw'; 
  }
}

  // Future<void> _initializeLocation() async {
  //   if (_isLocationInitialized) return;

  //   try {
  //     // Request location permission
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //     }

  //     if (permission == LocationPermission.denied || 
  //         permission == LocationPermission.deniedForever) {
  //       throw Exception('Location permission denied');
  //     }

  //     // Get current position
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high
  //     );
  //     _currentLocation = LatLng(position.latitude, position.longitude);

  //     // Determine country based on coordinates
  //     if (_isInMexico(position.latitude, position.longitude)) {
  //       _countryCode = 'mx';
  //     } else {
  //       _countryCode = 'pk';
  //     }

  //     _isLocationInitialized = true;
  //   } catch (e) {
  //     // Fallback to default location (Mexico City)
  //     _currentLocation = const LatLng(-25.7479, 28.2293);
  //     _countryCode = 'mx';
  //     _isLocationInitialized = true;
  //   }
  // }

 
 
 
 
  bool _isInMexico(double lat, double lng) {
    // Rough boundaries for Mexico
    return lat >= 14.5 && lat <= 32.7 && lng >= -118.4 && lng <= -86.7;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(color: AppColors.backgroundDark, fontSize: 18),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.backgroundDark),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () => query = '',
    )
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back_ios),
    onPressed: () => close(context, {}),
  );

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

@override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (query.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'addressSearch.startTyping'.tr(),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _getAddressSuggestions(query),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'addressSearch.locationError'.tr(),
                       textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                     Text(
                      'addressSearch.networkError'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.place, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'addressSearch.locationError'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'addressSearch.error'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final suggestion = snapshot.data![index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: AppColors.primary),
                  title: Text(
                    suggestion['description'] as String,
                    style: AppTextTheme.getLightTextTheme(context).bodyMedium,
                  ),
                  onTap: () => _onSuggestionSelected(context, suggestion),
                );
              },
            );
          },
        );
      },
    );
  }

  void _onSuggestionSelected(BuildContext context, Map<String, dynamic> suggestion) async {
    try {
      final placeDetails = await _getPlaceDetails(suggestion['place_id'] as String);
      close(context, {
        'address': suggestion['description'] as String,
        'latLng': placeDetails,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text('addressSearch.error'.tr()),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getAddressSuggestions(String query) async {
    if (query.length < 3) return [];

    await _initializeLocation(); 

    final params = {
      'input': query,
      'components': 'country:$_countryCode',
      'location': '${_currentLocation.latitude},${_currentLocation.longitude}',
      'radius': '50000',
      'strictbounds': 'true',
      'key': _apiKey,
    };

    final uri = Uri.parse('$_baseUrl/place/autocomplete/json').replace(queryParameters: params);

    try {
      final response = await _client.get(uri);
      return _handleResponse(response, (json) {
        return (json['predictions'] as List)
            .map<Map<String, dynamic>>((p) => {
                  'description': p['description'],
                  'place_id': p['place_id'],
                })
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to fetch suggestions: $e');
    }
  }

  Future<LatLng> _getPlaceDetails(String placeId) async {
    final params = {
      'place_id': placeId,
      'fields': 'geometry',
      'key': _apiKey,
    };

    final uri = Uri.parse('$_baseUrl/place/details/json').replace(queryParameters: params);

    try {
      final response = await _client.get(uri);
      return _handleResponse(response, (json) {
        final location = json['result']['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      });
    } catch (e) {
      throw Exception('Failed to fetch place details: $e');
    }
  }

  T _handleResponse<T>(http.Response response, T Function(dynamic json) handler) {
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return handler(result);
      } else {
        throw Exception('API Error: ${result['status']} - ${result['error_message']}');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  @override
  void close(BuildContext context, Map<String, dynamic> result) {
    _client.close();
    super.close(context, result);
  }
}
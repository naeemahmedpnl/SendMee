class DriverRegistrationModel {
  String? username;
  String? address;
  String? phone;
  String? profilePicture;
  String? dob;
  String? driverLicense;
  String? voterID;
  String? passport;
  String? proofOfAddress;
  String? motorcycleLicensePlateNumber;
  String? motorcycleColor;
  String? motorcycleYear;
  String? motorcycleModel;
  List<String> motorcyclePhotos;
  String? serviceType; // Added service type field

  DriverRegistrationModel({
    this.username,
    this.address,
    this.phone,
    this.profilePicture,
    this.dob,
    this.driverLicense,
    this.voterID,
    this.passport,
    this.proofOfAddress,
    this.motorcycleLicensePlateNumber,
    this.motorcycleColor,
    this.motorcycleYear,
    this.motorcycleModel,
    List<String>? motorcyclePhotos,
    this.serviceType, // Added parameter
  }) : motorcyclePhotos = motorcyclePhotos ?? [];

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': address,
        'phone': phone,
        'profilePicture': profilePicture,
        'dob': dob,
        'driverLicense': driverLicense,
        'voterID': voterID,
        'passport': passport,
        'proofOfAddress': proofOfAddress,
        'motorcycleLicensePlateNumber': motorcycleLicensePlateNumber,
        'motorcycleColor': motorcycleColor,
        'motorcycleYear': motorcycleYear,
        'motorcycleModel': motorcycleModel,
        'motorcyclePhotos': motorcyclePhotos,
        'serviceType': serviceType, // Add to JSON serialization
      };

  factory DriverRegistrationModel.fromJson(Map<String, dynamic> json) =>
      DriverRegistrationModel(
        username: json['username'],
        address: json['address'],
        phone: json['phone'],
        profilePicture: json['profilePicture'],
        dob: json['dob'],
        driverLicense: json['driverLicense'],
        voterID: json['voterID'],
        passport: json['passport'],
        proofOfAddress: json['proofOfAddress'],
        motorcycleLicensePlateNumber: json['motorcycleLicensePlateNumber'],
        motorcycleColor: json['motorcycleColor'],
        motorcycleYear: json['motorcycleYear'],
        motorcycleModel: json['motorcycleModel'],
        motorcyclePhotos: List<String>.from(json['motorcyclePhotos'] ?? []),
        serviceType: json['serviceType'], // Load from JSON
      );

  // Helper method to check if motorcycle details are complete
  bool get hasMotorcycleDetails {
    return motorcycleLicensePlateNumber?.isNotEmpty == true &&
        motorcycleColor?.isNotEmpty == true &&
        motorcycleYear?.isNotEmpty == true &&
        motorcycleModel?.isNotEmpty == true;
  }
}
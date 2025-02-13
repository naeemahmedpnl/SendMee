// class DriverRegistrationModel {
//   String? username;
//   String? address;
  
//   String? phone;
//   String? profilePicture;
//   String? driverLicense;
//   String? voterID;
//   String? passport;
//   String? proofOfAddress;
//   String? motorcycleLicensePlateNumber;
//   String? motorcycleColor;
//   String? motorcycleYear;
//   String? motorcycleModel;
//   List<String> motorcyclePhotos; 

//   DriverRegistrationModel({
//     this.username,
//     this.address,
//     this.phone,
//     this.profilePicture,
//     this.driverLicense,
//     this.voterID,
//     this.passport,
//     this.proofOfAddress,
//     this.motorcycleLicensePlateNumber,
//     this.motorcycleColor,
//     this.motorcycleYear,
//     this.motorcycleModel,
//     List<String>? motorcyclePhotos,
//   }) : motorcyclePhotos = motorcyclePhotos ?? []; 



//   Map<String, dynamic> toJson() => {
//     'username': username,
//     'email': address,
//     'phone': phone,
//     'profilePicture': profilePicture,
//     'driverLicense': driverLicense,
//     'voterID': voterID,
//     'passport': passport,
//     'proofOfAddress': proofOfAddress,
//     'motorcycleLicensePlateNumber': motorcycleLicensePlateNumber,
//     'motorcycleColor': motorcycleColor,
//     'motorcycleYear': motorcycleYear,
//     'motorcycleModel': motorcycleModel,
//     'motorcyclePhotos': motorcyclePhotos,
//   };

//   factory DriverRegistrationModel.fromJson(Map<String, dynamic> json) => 
//     DriverRegistrationModel(
//       username: json['username'],
//       address: json['address'],
//       phone: json['phone'],
//       profilePicture: json['profilePicture'],
//       driverLicense: json['driverLicense'],
//       voterID: json['voterID'],
//       passport: json['passport'],
//       proofOfAddress: json['proofOfAddress'],
//       motorcycleLicensePlateNumber: json['motorcycleLicensePlateNumber'],
//       motorcycleColor: json['motorcycleColor'],
//       motorcycleYear: json['motorcycleYear'],
//       motorcycleModel: json['motorcycleModel'],
//       motorcyclePhotos: List<String>.from(json['motorcyclePhotos'] ?? []),
//     );

//   // Helper method to check if motorcycle details are complete
//   bool get hasMotorcycleDetails {
//     return motorcycleLicensePlateNumber?.isNotEmpty == true &&
//            motorcycleColor?.isNotEmpty == true &&
//            motorcycleYear?.isNotEmpty == true &&
//            motorcycleModel?.isNotEmpty == true;
//   }
// }


class DriverRegistrationModel {
  String? username;
  String? address;
  String? phone;
  String? profilePicture;
  String? dob; // Changed to String type for DOB
  String? driverLicense;
  String? voterID;
  String? passport;
  String? proofOfAddress;
  String? motorcycleLicensePlateNumber;
  String? motorcycleColor;
  String? motorcycleYear;
  String? motorcycleModel;
  List<String> motorcyclePhotos;

  DriverRegistrationModel({
    this.username,
    this.address,
    this.phone,
    this.profilePicture,
    this.dob, // Updated parameter name
    this.driverLicense,
    this.voterID,
    this.passport,
    this.proofOfAddress,
    this.motorcycleLicensePlateNumber,
    this.motorcycleColor,
    this.motorcycleYear,
    this.motorcycleModel,
    List<String>? motorcyclePhotos,
  }) : motorcyclePhotos = motorcyclePhotos ?? [];

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': address,
        'phone': phone,
        'profilePicture': profilePicture,
        'dob': dob, // Store DOB as string
        'driverLicense': driverLicense,
        'voterID': voterID,
        'passport': passport,
        'proofOfAddress': proofOfAddress,
        'motorcycleLicensePlateNumber': motorcycleLicensePlateNumber,
        'motorcycleColor': motorcycleColor,
        'motorcycleYear': motorcycleYear,
        'motorcycleModel': motorcycleModel,
        'motorcyclePhotos': motorcyclePhotos,
      };

  factory DriverRegistrationModel.fromJson(Map<String, dynamic> json) =>
      DriverRegistrationModel(
        username: json['username'],
        address: json['address'],
        phone: json['phone'],
        profilePicture: json['profilePicture'],
        dob: json['dob'], // Load DOB as string
        driverLicense: json['driverLicense'],
        voterID: json['voterID'],
        passport: json['passport'],
        proofOfAddress: json['proofOfAddress'],
        motorcycleLicensePlateNumber: json['motorcycleLicensePlateNumber'],
        motorcycleColor: json['motorcycleColor'],
        motorcycleYear: json['motorcycleYear'],
        motorcycleModel: json['motorcycleModel'],
        motorcyclePhotos: List<String>.from(json['motorcyclePhotos'] ?? []),
      );

  // Helper method to check if motorcycle details are complete
  bool get hasMotorcycleDetails {
    return motorcycleLicensePlateNumber?.isNotEmpty == true &&
        motorcycleColor?.isNotEmpty == true &&
        motorcycleYear?.isNotEmpty == true &&
        motorcycleModel?.isNotEmpty == true;
  }
}
class User {
  String? fcmToken;
  String id;
  String registrationType;
  String phone;
  String otp;
  String? profilePicture;
  DateTime otpExpire;
  DateTime createdAt;
  bool isSuperAdmin;
  bool isDriver;
  String serviceType;
  String driverRoleStatus;
  String passengerStatus;
  int v;
  String? email;
  String? username;
  PassengerDetails? passengerDetails;
  final double walletBalance;
  TotalRides totalRides;
  final double totalEarningsAsDriver;
  String? stripeAccountId;     
  String? stripeAccountLink;    

  User({
    this.fcmToken,
    required this.id,
    required this.registrationType,
    required this.phone,
    required this.otp,
    required this.otpExpire,
    required this.createdAt,
        this.serviceType = 'bike',
    this.profilePicture,
    required this.isSuperAdmin,
    required this.driverRoleStatus,
    required this.passengerStatus,
    required this.isDriver,
    required this.v,
    this.email,
    this.username,
    this.passengerDetails,
    required this.walletBalance,
    required this.totalRides,
    required this.totalEarningsAsDriver,
    this.stripeAccountId,       
    this.stripeAccountLink,    
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fcmToken: json['fcmToken'],
      id: json['_id'] ?? '',
      registrationType: json['registrationType'] ?? '',
      phone: json['phone'] ?? '',
      otp: json['otp'] ?? '',
      isDriver: json['isDriver'] ?? false,
      otpExpire:
          DateTime.parse(json['otpExpire'] ?? DateTime.now().toIso8601String()),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
       serviceType: json['driverDetails']?['serviceType'] ?? 'bike',
      isSuperAdmin: json['isSuperAdmin'] ?? false,
      driverRoleStatus: json['driverRoleStatus'] ?? '',
      passengerStatus: json['PassengerStatus'] ?? '',
      v: (json['__v'] ?? 0).toInt(),
      email: json['email'],
      username: json['username'],
      profilePicture: json['profilePicture'],
      passengerDetails: json['passengerDetails'] != null
          ? PassengerDetails.fromJson(json['passengerDetails'])
          : null,

      walletBalance:
          (json['walletBalance'] ?? 0).toDouble(),
      totalEarningsAsDriver: (json['totalEarningsAsDriver'] ?? 0).toDouble(),
      totalRides: TotalRides.fromJson(json['totalRides'] ?? {}),
      stripeAccountId: json['stripeAccountId'],    
      stripeAccountLink: json['stripeAccountLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fcmToken': fcmToken,
      '_id': id,
      'registrationType': registrationType,
      'phone': phone,
      'otp': otp,
      'otpExpire': otpExpire.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isSuperAdmin': isSuperAdmin,
       'serviceType': serviceType, 
      'driverRoleStatus': driverRoleStatus,
      'PassengerStatus': passengerStatus,
      'isDriver': isDriver,
      'profilePicture': profilePicture,
      '__v': v,
      'email': email,
      'username': username,
      'passengerDetails': passengerDetails?.toJson(),
      'walletBalance': walletBalance,
      'totalRides': totalRides.toJson(),
      'totalEarningsAsDriver': totalEarningsAsDriver,
      'stripeAccountId': stripeAccountId,      
      'stripeAccountLink': stripeAccountLink,     
    };
  }
}

class PassengerDetails {
  String id;
  String user;
  List<Rating> rating;
  int v;
  double ratingAverage;

  PassengerDetails({
    required this.id,
    required this.user,
    required this.rating,
    required this.v,
    required this.ratingAverage,
  });

  factory PassengerDetails.fromJson(Map<String, dynamic> json) {
    return PassengerDetails(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      rating: (json['rating'] as List<dynamic>?)
              ?.map((e) => Rating.fromJson(e))
              .toList() ??
          [],
      v: json['__v'] ?? 0,
      ratingAverage: (json['ratingAverage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'rating': rating.map((e) => e.toJson()).toList(),
      '__v': v,
      'ratingAverage': ratingAverage,
    };
  }
}

class Rating {
  int rating;
  String from;
  String id;

  Rating({
    required this.rating,
    required this.from,
    required this.id,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rating: json['rating'] ?? 0,
      from: json['from'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'from': from,
      '_id': id,
    };
  }
}

class TotalRides {
  int asPassenger;
  int asDriver;
  int total;

  TotalRides({
    required this.asPassenger,
    required this.asDriver,
    required this.total,
  });

  factory TotalRides.fromJson(Map<String, dynamic> json) {
    return TotalRides(
      asPassenger: (json['asPassenger'] ?? 0).toInt(),
      asDriver: (json['asDriver'] ?? 0).toInt(),
      total: (json['total'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asPassenger': asPassenger,
      'asDriver': asDriver,
      'total': total,
    };
  }
}

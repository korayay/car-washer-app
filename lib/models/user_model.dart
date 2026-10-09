enum UserRole { customer, washer, admin }

class UserModel {
  final String id;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final bool isActive;
  
  // Yıkamacıya özel alanlar
  final double? rating;
  final int? totalJobs;
  final bool? isAvailable;
  final List<String>? serviceAreas;
  final String? licenseNumber;
  final String? vehicleInfo;
  
  // Kullanıcıya özel alanlar
  final String? address;
  final Map<String, double>? location; // lat, lng
  final int? totalBookings;
  
  // Puan ve rozet sistemi
  final int points;
  final List<String> achievements;
  final int totalEcoWashes;
  final DateTime? lastWashDate;

  UserModel({
    required this.id,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.isActive = true,
    this.rating,
    this.totalJobs,
    this.isAvailable,
    this.serviceAreas,
    this.licenseNumber,
    this.vehicleInfo,
    this.address,
    this.location,
    this.totalBookings,
    this.points = 0,
    this.achievements = const [],
    this.totalEcoWashes = 0,
    this.lastWashDate,
  });

  String get fullName => '$firstName $lastName';
  
  bool get isWasher => role == UserRole.washer;
  bool get isCustomer => role == UserRole.customer;
  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerified': isVerified,
      'isActive': isActive,
      'rating': rating,
      'totalJobs': totalJobs,
      'isAvailable': isAvailable,
      'serviceAreas': serviceAreas,
      'licenseNumber': licenseNumber,
      'vehicleInfo': vehicleInfo,
      'address': address,
      'location': location,
      'totalBookings': totalBookings,
      'points': points,
      'achievements': achievements,
      'totalEcoWashes': totalEcoWashes,
      'lastWashDate': lastWashDate?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.customer,
      ),
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      rating: map['rating']?.toDouble(),
      totalJobs: map['totalJobs'],
      isAvailable: map['isAvailable'],
      serviceAreas: map['serviceAreas']?.cast<String>(),
      licenseNumber: map['licenseNumber'],
      vehicleInfo: map['vehicleInfo'],
      address: map['address'],
      location: map['location'] != null ? Map<String, double>.from(map['location']) : null,
      totalBookings: map['totalBookings'],
      points: map['points'] ?? 0,
      achievements: map['achievements']?.cast<String>() ?? [],
      totalEcoWashes: map['totalEcoWashes'] ?? 0,
      lastWashDate: map['lastWashDate'] != null ? DateTime.parse(map['lastWashDate']) : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    bool? isActive,
    double? rating,
    int? totalJobs,
    bool? isAvailable,
    List<String>? serviceAreas,
    String? licenseNumber,
    String? vehicleInfo,
    String? address,
    Map<String, double>? location,
    int? totalBookings,
    int? points,
    List<String>? achievements,
    int? totalEcoWashes,
    DateTime? lastWashDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalJobs: totalJobs ?? this.totalJobs,
      isAvailable: isAvailable ?? this.isAvailable,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      address: address ?? this.address,
      location: location ?? this.location,
      totalBookings: totalBookings ?? this.totalBookings,
      points: points ?? this.points,
      achievements: achievements ?? this.achievements,
      totalEcoWashes: totalEcoWashes ?? this.totalEcoWashes,
      lastWashDate: lastWashDate ?? this.lastWashDate,
    );
  }
} 
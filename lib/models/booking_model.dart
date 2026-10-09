enum BookingStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
  disputed
}

enum WashType {
  dryClean,
  greenShine, 
  greenCabin,
  greenPlus,
  greenDeluxe,
  greenDeluxeMonthly
}

enum VehicleType {
  car,
  suv,
  truck,
  motorcycle
}

// WashType için extension - fiyat ve açıklama bilgileri
extension WashTypeExtension on WashType {
  String get displayName {
    switch (this) {
      case WashType.dryClean:
        return 'Dry Clean';
      case WashType.greenShine:
        return 'Green Shine';
      case WashType.greenCabin:
        return 'Green Cabin';
      case WashType.greenPlus:
        return 'Green Plus';
      case WashType.greenDeluxe:
        return 'Green Deluxe';
      case WashType.greenDeluxeMonthly:
        return 'Clean Club';
    }
  }

  String get description {
    switch (this) {
      case WashType.dryClean:
        return 'Hızlı susuz temizlik, özel kimyasal formül';
      case WashType.greenShine:
        return 'Sadece dış temizlik, parlatma dahil';
      case WashType.greenCabin:
        return 'Sadece iç temizlik, detaylı vakumlama';
      case WashType.greenPlus:
        return 'İç + dış detaylı temizlik';
      case WashType.greenDeluxe:
        return 'Komple temizlik + cilalama, premium ürünler';
      case WashType.greenDeluxeMonthly:
        return 'Aylık üyelik paketi - Ayda 4 kez komple temizlik';
    }
  }

  double get price {
    switch (this) {
      case WashType.dryClean:
        return 150.0;
      case WashType.greenShine:
        return 200.0;
      case WashType.greenCabin:
        return 240.0;
      case WashType.greenPlus:
        return 360.0;
      case WashType.greenDeluxe:
        return 460.0;
      case WashType.greenDeluxeMonthly:
        return 800.0;
    }
  }

  String get priceText {
    if (this == WashType.greenDeluxeMonthly) {
      return '${price.toInt()}₺/ay';
    }
    return '${price.toInt()}₺';
  }

  // Tahmini süre (dakika)
  int get estimatedDuration {
    switch (this) {
      case WashType.dryClean:
        return 20;
      case WashType.greenShine:
        return 30;
      case WashType.greenCabin:
        return 40;
      case WashType.greenPlus:
        return 60;
      case WashType.greenDeluxe:
        return 90;
      case WashType.greenDeluxeMonthly:
        return 90;
    }
  }

  // Eco-friendly mi?
  bool get isEcoFriendly {
    switch (this) {
      case WashType.dryClean:
        return false; // Kimyasal kullanır, su tasarrufu ama eco değil
      case WashType.greenShine:
      case WashType.greenCabin:
      case WashType.greenPlus:
      case WashType.greenDeluxe:
      case WashType.greenDeluxeMonthly:
        return true; // Green serisi eco-friendly
    }
  }

  // Premium hizmet mi?
  bool get isPremium {
    switch (this) {
      case WashType.greenDeluxe:
      case WashType.greenDeluxeMonthly:
        return true;
      default:
        return false;
    }
  }
}

class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? washerId;
  final String? washerName;
  final String? washerPhone;
  final BookingStatus status;
  final WashType washType;
  final VehicleType vehicleType;
  final String vehicleModel;
  final String vehicleColor;
  final String vehiclePlate;
  final String address;
  final Map<String, double> location; // lat, lng
  final DateTime scheduledDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double price;
  final String? notes;
  final String? beforePhotoUrl;
  final String? afterPhotoUrl;
  final double? rating;
  final String? review;
  final bool isEcoFriendly;
  final bool isPaid;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.washerId,
    this.washerName,
    this.washerPhone,
    required this.status,
    required this.washType,
    required this.vehicleType,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.vehiclePlate,
    required this.address,
    required this.location,
    required this.scheduledDate,
    required this.createdAt,
    required this.updatedAt,
    required this.price,
    this.notes,
    this.beforePhotoUrl,
    this.afterPhotoUrl,
    this.rating,
    this.review,
    this.isEcoFriendly = false,
    this.isPaid = false,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  // Display metodları
  String get washTypeDisplayName {
    return washType.displayName;
  }

  String get washTypeDescription {
    return washType.description;
  }

  String get washTypePriceText {
    return washType.priceText;
  }

  int get estimatedDuration {
    return washType.estimatedDuration;
  }

  String get vehicleTypeDisplayName {
    switch (vehicleType) {
      case VehicleType.car:
        return 'Otomobil';
      case VehicleType.suv:
        return 'SUV';
      case VehicleType.truck:
        return 'Kamyonet';
      case VehicleType.motorcycle:
        return 'Motosiklet';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case BookingStatus.pending:
        return 'Beklemede';
      case BookingStatus.accepted:
        return 'Kabul Edildi';
      case BookingStatus.inProgress:
        return 'Devam Ediyor';
      case BookingStatus.completed:
        return 'Tamamlandı';
      case BookingStatus.cancelled:
        return 'İptal Edildi';
      case BookingStatus.disputed:
        return 'Anlaşmazlık';
    }
  }

  bool get isActive => status == BookingStatus.pending || 
                      status == BookingStatus.accepted || 
                      status == BookingStatus.inProgress;

  bool get isCompleted => status == BookingStatus.completed;

  bool get canCancel => status == BookingStatus.pending || 
                       status == BookingStatus.accepted;

  bool get canRate => status == BookingStatus.completed && rating == null;

  // Hesaplanmış değerler
  Duration? get actualDuration {
    if (startedAt != null && completedAt != null) {
      return completedAt!.difference(startedAt!);
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'washerId': washerId,
      'washerName': washerName,
      'washerPhone': washerPhone,
      'status': status.name,
      'washType': washType.name,
      'vehicleType': vehicleType.name,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'vehiclePlate': vehiclePlate,
      'address': address,
      'location': location,
      'scheduledDate': scheduledDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'price': price,
      'notes': notes,
      'beforePhotoUrl': beforePhotoUrl,
      'afterPhotoUrl': afterPhotoUrl,
      'rating': rating,
      'review': review,
      'isEcoFriendly': isEcoFriendly,
      'isPaid': isPaid,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      washerId: map['washerId'],
      washerName: map['washerName'],
      washerPhone: map['washerPhone'],
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      washType: WashType.values.firstWhere(
        (e) => e.name == map['washType'],
        orElse: () => WashType.dryClean, // Changed default to dryClean
      ),
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.name == map['vehicleType'],
        orElse: () => VehicleType.car,
      ),
      vehicleModel: map['vehicleModel'] ?? '',
      vehicleColor: map['vehicleColor'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      address: map['address'] ?? '',
      location: Map<String, double>.from(map['location'] ?? {'lat': 0.0, 'lng': 0.0}),
      scheduledDate: DateTime.parse(map['scheduledDate'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      price: map['price']?.toDouble() ?? 0.0,
      notes: map['notes'],
      beforePhotoUrl: map['beforePhotoUrl'],
      afterPhotoUrl: map['afterPhotoUrl'],
      rating: map['rating']?.toDouble(),
      review: map['review'],
      isEcoFriendly: map['isEcoFriendly'] ?? false,
      isPaid: map['isPaid'] ?? false,
      acceptedAt: map['acceptedAt'] != null ? DateTime.parse(map['acceptedAt']) : null,
      startedAt: map['startedAt'] != null ? DateTime.parse(map['startedAt']) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      cancelledAt: map['cancelledAt'] != null ? DateTime.parse(map['cancelledAt']) : null,
      cancellationReason: map['cancellationReason'],
    );
  }

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? washerId,
    String? washerName,
    String? washerPhone,
    BookingStatus? status,
    WashType? washType,
    VehicleType? vehicleType,
    String? vehicleModel,
    String? vehicleColor,
    String? vehiclePlate,
    String? address,
    Map<String, double>? location,
    DateTime? scheduledDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? price,
    String? notes,
    String? beforePhotoUrl,
    String? afterPhotoUrl,
    double? rating,
    String? review,
    bool? isEcoFriendly,
    bool? isPaid,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      washerId: washerId ?? this.washerId,
      washerName: washerName ?? this.washerName,
      washerPhone: washerPhone ?? this.washerPhone,
      status: status ?? this.status,
      washType: washType ?? this.washType,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      address: address ?? this.address,
      location: location ?? this.location,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      beforePhotoUrl: beforePhotoUrl ?? this.beforePhotoUrl,
      afterPhotoUrl: afterPhotoUrl ?? this.afterPhotoUrl,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
      isPaid: isPaid ?? this.isPaid,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
} 
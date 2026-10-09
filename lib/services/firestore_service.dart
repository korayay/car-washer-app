import 'dart:async';
import '../models/user_model.dart';

// Mock Firestore Service - Firebase olmadan çalışır
class MockQuerySnapshot {
  final List<MockDocumentSnapshot> docs;
  
  MockQuerySnapshot(this.docs);
}

class MockDocumentSnapshot {
  final String id;
  final Map<String, dynamic> data;
  
  MockDocumentSnapshot(this.id, this.data);
  
  Map<String, dynamic>? call() => data;
  bool get exists => data.isNotEmpty;
}

class FirestoreService {
  // In-memory veri depolama
  static final Map<String, Map<String, dynamic>> _users = {};
  static final Map<String, Map<String, dynamic>> _bookings = {};
  static int _bookingCounter = 4; // booking_1, booking_2, booking_3 var
  
  FirestoreService() {
    _initializeMockData();
  }
  
  // Kullanıcı işlemleri
  Future<void> createUser(UserModel user) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _users[user.id] = user.toMap();
      print('Mock: Kullanıcı oluşturuldu: ${user.id}');
    } catch (e) {
      throw Exception('Kullanıcı oluşturma hatası: $e');
    }
  }
  
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _users[userId];
    } catch (e) {
      throw Exception('Kullanıcı getirme hatası: $e');
    }
  }
  
  Future<void> updateUser(UserModel user) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      if (_users.containsKey(user.id)) {
        _users[user.id] = user.toMap();
        print('Mock: Kullanıcı güncellendi: ${user.id}');
      }
    } catch (e) {
      throw Exception('Kullanıcı güncelleme hatası: $e');
    }
  }
  
  Future<void> deleteUser(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _users.remove(userId);
      print('Mock: Kullanıcı silindi: $userId');
    } catch (e) {
      throw Exception('Kullanıcı silme hatası: $e');
    }
  }
  
  // Kullanıcı listeleme
  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    int limit = 20,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      var users = _users.entries.map((entry) => {
        'id': entry.key,
        ...entry.value,
      }).toList();
      
      if (role != null) {
        users = users.where((user) => user['role'] == role).toList();
      }
      
      return users.take(limit).toList();
    } catch (e) {
      throw Exception('Kullanıcı listeleme hatası: $e');
    }
  }
  
  // Rezervasyon işlemleri
  Future<String> createBooking(Map<String, dynamic> bookingData) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      final bookingId = 'booking_${_bookingCounter++}';
      bookingData['id'] = bookingId;
      bookingData['createdAt'] = DateTime.now().toIso8601String();
      
      _bookings[bookingId] = bookingData;
      print('Mock: Rezervasyon oluşturuldu: $bookingId');
      
      return bookingId;
    } catch (e) {
      throw Exception('Rezervasyon oluşturma hatası: $e');
    }
  }
  
  Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return _bookings[bookingId];
    } catch (e) {
      throw Exception('Rezervasyon getirme hatası: $e');
    }
  }
  
  Future<void> updateBooking(String bookingId, Map<String, dynamic> data) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      
      if (_bookings.containsKey(bookingId)) {
        _bookings[bookingId]!.addAll(data);
        _bookings[bookingId]!['updatedAt'] = DateTime.now().toIso8601String();
        print('Mock: Rezervasyon güncellendi: $bookingId');
      }
    } catch (e) {
      throw Exception('Rezervasyon güncelleme hatası: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final allBookings = _bookings.entries.map((entry) => {
        'id': entry.key,
        ...entry.value,
      }).toList();
      
      return allBookings;
    } catch (e) {
      throw Exception('Tüm rezervasyonlar getirme hatası: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final userBookings = _bookings.entries
          .where((entry) => entry.value['customerId'] == userId)
          .map((entry) => {
            'id': entry.key,
            ...entry.value,
          })
          .toList();
      
      // Tarihe göre sırala
      userBookings.sort((a, b) => 
        DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
      
      return userBookings;
    } catch (e) {
      throw Exception('Kullanıcı rezervasyonları getirme hatası: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getWasherBookings(String washerId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final washerBookings = _bookings.entries
          .where((entry) => entry.value['washerId'] == washerId)
          .map((entry) => {
            'id': entry.key,
            ...entry.value,
          })
          .toList();
      
      // Tarihe göre sırala
      washerBookings.sort((a, b) => 
        DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
      
      return washerBookings;
    } catch (e) {
      throw Exception('Yıkamacı rezervasyonları getirme hatası: $e');
    }
  }
  
  // Yakındaki rezervasyonlar
  Future<List<Map<String, dynamic>>> getNearbyBookings(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      print('Mock: getNearbyBookings çağrıldı');
      print('Mock: Toplam rezervasyon sayısı: ${_bookings.length}');
      
      // Tüm rezervasyonları log'la
      _bookings.forEach((id, data) {
        print('Mock: Rezervasyon $id - Status: ${data['status']}');
      });
      
      // Mock veri: bekleyen rezervasyonları döndür
      final nearbyBookings = _bookings.entries
          .where((entry) {
            final isPending = entry.value['status'] == 'pending';
            print('Mock: ${entry.key} rezervasyonu pending mi? $isPending (status: ${entry.value['status']})');
            return isPending;
          })
          .map((entry) => {
            'id': entry.key,
            ...entry.value,
          })
          .toList();
      
      print('Mock: Bulunan pending rezervasyon sayısı: ${nearbyBookings.length}');
      
      return nearbyBookings;
    } catch (e) {
      throw Exception('Yakındaki rezervasyonlar getirme hatası: $e');
    }
  }
  
  // Real-time güncellemeler (Mock StreamController kullanarak)
  Stream<MockQuerySnapshot> getBookingsStream({String? userId, String? washerId}) {
    final controller = StreamController<MockQuerySnapshot>();
    
    Timer.periodic(const Duration(seconds: 2), (timer) {
      final filteredBookings = _bookings.entries.where((entry) {
        if (userId != null) {
          return entry.value['customerId'] == userId;
        } else if (washerId != null) {
          return entry.value['washerId'] == washerId;
        }
        return true;
      }).toList();
      
      final docs = filteredBookings.map((entry) => 
        MockDocumentSnapshot(entry.key, entry.value)
      ).toList();
      
      controller.add(MockQuerySnapshot(docs));
    });
    
    return controller.stream;
  }
  
  Stream<MockDocumentSnapshot> getBookingStream(String bookingId) {
    final controller = StreamController<MockDocumentSnapshot>();
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final booking = _bookings[bookingId];
      if (booking != null) {
        controller.add(MockDocumentSnapshot(bookingId, booking));
      }
    });
    
    return controller.stream;
  }
  
  // Static data initialization
  static void _initializeMockData() {
    if (_users.isNotEmpty) return; // Zaten yüklenmiş
    
    print('Mock: Veri yükleniyor...');
    
    // Mock müşteri kullanıcıları
    _users['customer1'] = {
      'id': 'customer1',
      'firstName': 'Ahmet',
      'lastName': 'Yılmaz',
      'email': 'ahmet@example.com',
      'phoneNumber': '+905551234567',
      'role': 'customer',
      'isVerified': true,
      'isActive': true,
      'totalBookings': 15,
      'points': 320,
      'achievements': ['first_user', 'eco_friendly', 'vip_customer'],
      'totalEcoWashes': 8,
      'lastWashDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    _users['customer2'] = {
      'id': 'customer2',
      'firstName': 'Ayşe',
      'lastName': 'Kaya',
      'email': 'ayse@example.com',
      'phoneNumber': '+905552345678',
      'role': 'customer',
      'isVerified': true,
      'isActive': true,
      'totalBookings': 3,
      'points': 60,
      'achievements': ['first_user'],
      'totalEcoWashes': 2,
      'lastWashDate': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      'createdAt': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Mock yıkamacı kullanıcıları
    _users['washer1'] = {
      'id': 'washer1',
      'firstName': 'Mehmet',
      'lastName': 'Öz',
      'email': 'mehmet@example.com',
      'phoneNumber': '+905553456789',
      'role': 'washer',
      'isVerified': true,
      'isActive': true,
      'isAvailable': true,
      'rating': 4.8,
      'totalJobs': 247,
      'serviceAreas': ['Kadıköy', 'Üsküdar', 'Ataşehir'],
      'licenseNumber': 'YK123456',
      'vehicleInfo': 'Ford Transit - 34 ABC 123',
      'points': 0,
      'achievements': [],
      'totalEcoWashes': 0,
      'lastWashDate': null,
      'createdAt': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    _users['washer2'] = {
      'id': 'washer2',
      'firstName': 'Ali',
      'lastName': 'Demir',
      'email': 'ali@example.com',
      'phoneNumber': '+905554567890',
      'role': 'washer',
      'isVerified': true,
      'isActive': true,
      'isAvailable': false,
      'rating': 4.6,
      'totalJobs': 189,
      'serviceAreas': ['Beşiktaş', 'Şişli', 'Sarıyer'],
      'licenseNumber': 'YK789012',
      'vehicleInfo': 'Volkswagen Crafter - 34 DEF 456',
      'points': 0,
      'achievements': [],
      'totalEcoWashes': 0,
      'lastWashDate': null,
      'createdAt': DateTime.now().subtract(const Duration(days: 85)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    // Mock admin kullanıcısı
    _users['admin1'] = {
      'id': 'admin1',
      'firstName': 'Fatma',
      'lastName': 'Admin',
      'email': 'admin@gleam.com',
      'phoneNumber': '+905550987654',
      'role': 'admin',
      'isVerified': true,
      'isActive': true,
      'points': 0,
      'achievements': [],
      'totalEcoWashes': 0,
      'lastWashDate': null,
      'createdAt': DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    // Mock rezervasyonlar - Test için farklı durumlar
    _bookings['booking_1'] = {
      'id': 'booking_1',
      'customerId': 'customer1',
      'customerName': 'Ahmet Yılmaz',
      'customerPhone': '+905551234567',
      'washerId': 'washer1',
      'washerName': 'Mehmet Öz',
      'washerPhone': '+905553456789',
      'status': 'pending',
      'washType': 'dryClean',
      'vehicleType': 'car',
      'vehicleModel': 'Toyota Corolla',
      'vehicleColor': 'Beyaz',
      'vehiclePlate': '34 ABC 123',
      'address': 'Kadıköy Meydanı, Kadıköy, İstanbul',
      'location': {'lat': 40.9917, 'lng': 29.0278},
      'scheduledDate': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      'createdAt': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
      'updatedAt': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
      'price': 150.0,
      'notes': 'Hızlı yıkama talebi',
      'isEcoFriendly': false,
      'isPaid': false,
    };

    _bookings['booking_2'] = {
      'id': 'booking_2',
      'customerId': 'customer1',
      'customerName': 'Ahmet Yılmaz',
      'customerPhone': '+905551234567',
      'washerId': 'washer1',
      'washerName': 'Mehmet Öz',
      'washerPhone': '+905553456789',
      'status': 'accepted',
      'washType': 'greenShine',
      'vehicleType': 'suv',
      'vehicleModel': 'BMW X3',
      'vehicleColor': 'Siyah',
      'vehiclePlate': '34 XYZ 789',
      'address': 'Ataşehir, İstanbul',
      'location': {'lat': 40.9923, 'lng': 29.1244},
      'scheduledDate': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'updatedAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      'acceptedAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      'price': 240.0, // Green Shine (200₺) + SUV %20 ekstra = 240₺
      'notes': 'Normal yıkama',
      'isEcoFriendly': false,
      'isPaid': false,
    };

    _bookings['booking_3'] = {
      'id': 'booking_3',
      'customerId': 'customer2',
      'customerName': 'Ayşe Kaya',
      'customerPhone': '+905552345678',
      'washerId': 'washer1',
      'washerName': 'Mehmet Öz',
      'washerPhone': '+905553456789',
      'status': 'inProgress',
      'washType': 'greenDeluxe',
      'vehicleType': 'car',
      'vehicleModel': 'Mercedes C180',
      'vehicleColor': 'Gümüş',
      'vehiclePlate': '34 DEF 456',
      'address': 'Üsküdar, İstanbul',
      'location': {'lat': 41.0214, 'lng': 29.0061},
      'scheduledDate': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'updatedAt': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
      'acceptedAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'startedAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      'price': 460.0,
      'notes': 'Premium detay yıkama, iç-dış komple',
      'isEcoFriendly': true,
      'isPaid': false,
      'beforePhotoUrl': 'https://via.placeholder.com/400x300/cccccc/000000?text=Before',
    };
    
    print('Mock: ${_users.length} kullanıcı ve ${_bookings.length} rezervasyon yüklendi');
  }
} 
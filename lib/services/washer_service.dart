import '../models/user_model.dart';
import '../models/booking_model.dart';
import 'firestore_service.dart';

class WasherService {
  final FirestoreService _firestoreService = FirestoreService();
  
  Future<List<UserModel>> getAvailableWashers(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final washersData = await _firestoreService.getUsers(
        role: UserRole.washer.name,
        limit: 50,
      );
      
      return washersData
          .map((data) => UserModel.fromMap(data))
          .where((washer) => washer.isAvailable == true)
          .toList();
    } catch (e) {
      throw Exception('Yıkamacı listesi getirme hatası: $e');
    }
  }
  
  Future<List<BookingModel>> getAvailableJobs(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      print('WasherService: getAvailableJobs çağrıldı');
      
      final jobsData = await _firestoreService.getNearbyBookings(
        latitude,
        longitude,
        radiusKm,
      );
      
      print('WasherService: FirestoreService\'ten ${jobsData.length} iş alındı');
      
      final bookingModels = jobsData.map((data) {
        print('WasherService: İş dönüştürülüyor - ID: ${data['id']}, Status: ${data['status']}');
        try {
          final booking = BookingModel.fromMap(data);
          print('WasherService: İş başarıyla dönüştürüldü - ${booking.id}');
          return booking;
        } catch (e) {
          print('WasherService: İş dönüştürme hatası - ${data['id']}: $e');
          rethrow;
        }
      }).toList();
      
      print('WasherService: Toplam ${bookingModels.length} BookingModel oluşturuldu');
      
      return bookingModels;
    } catch (e) {
      print('WasherService: getAvailableJobs hatası: $e');
      throw Exception('Mevcut işler getirme hatası: $e');
    }
  }
  
  Future<UserModel?> getWasherById(String washerId) async {
    try {
      final data = await _firestoreService.getUserById(washerId);
      if (data != null) {
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Yıkamacı getirme hatası: $e');
    }
  }
  
  Future<bool> updateWasherAvailability(String washerId, bool isAvailable) async {
    try {
      final userData = await _firestoreService.getUserById(washerId);
      if (userData != null) {
        final user = UserModel.fromMap(userData);
        final updatedUser = user.copyWith(
          isAvailable: isAvailable,
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateUser(updatedUser);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Yıkamacı durum güncelleme hatası: $e');
    }
  }
  
  Future<bool> updateWasherLocation(String washerId, double latitude, double longitude) async {
    // Bu örnekte basit bir yaklaşım kullanıyoruz
    // Gerçek uygulamada GeoPoint kullanılacak
    return true;
  }
  
  Future<bool> updateWasherServiceAreas(String washerId, List<String> serviceAreas) async {
    try {
      final userData = await _firestoreService.getUserById(washerId);
      if (userData != null) {
        final user = UserModel.fromMap(userData);
        final updatedUser = user.copyWith(
          serviceAreas: serviceAreas,
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateUser(updatedUser);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Hizmet alanları güncelleme hatası: $e');
    }
  }
  
  Future<List<UserModel>> searchWashers(String query) async {
    try {
      final washersData = await _firestoreService.getUsers(
        role: UserRole.washer.name,
        limit: 50,
      );
      
      return washersData
          .map((data) => UserModel.fromMap(data))
          .where((washer) => 
            washer.firstName.toLowerCase().contains(query.toLowerCase()) ||
            washer.lastName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Yıkamacı arama hatası: $e');
    }
  }
  
  Future<Map<String, dynamic>> getWasherStatistics(String washerId) async {
    try {
      // Demo istatistikler
      return {
        'totalJobs': 150,
        'completedJobs': 145,
        'cancelledJobs': 5,
        'averageRating': 4.7,
        'totalEarnings': 12500.0,
        'thisMonthJobs': 25,
        'thisMonthEarnings': 2100.0,
      };
    } catch (e) {
      throw Exception('İstatistik getirme hatası: $e');
    }
  }
  
  Future<List<BookingModel>> getWasherHistory(String washerId, {int limit = 20}) async {
    try {
      final bookingsData = await _firestoreService.getWasherBookings(washerId);
      return bookingsData.map((data) => BookingModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Yıkamacı geçmişi getirme hatası: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getWasherReviews(String washerId, {int limit = 10}) async {
    try {
      // Demo yorumlar
      return [
        {
          'rating': 5.0,
          'review': 'Harika bir hizmet! Çok memnun kaldım.',
          'customerName': 'Ahmet K.',
          'date': '2024-01-15',
        },
        {
          'rating': 4.5,
          'review': 'Zamanında geldi ve işini profesyonelce yaptı.',
          'customerName': 'Mehmet S.',
          'date': '2024-01-10',
        },
      ];
    } catch (e) {
      throw Exception('Yorumlar getirme hatası: $e');
    }
  }
  
  Future<bool> becomeWasher(String userId, Map<String, dynamic> washerData) async {
    try {
      final userData = await _firestoreService.getUserById(userId);
      if (userData != null) {
        final user = UserModel.fromMap(userData);
        final updatedUser = user.copyWith(
          role: UserRole.washer,
          licenseNumber: washerData['licenseNumber'],
          vehicleInfo: washerData['vehicleInfo'],
          serviceAreas: washerData['serviceAreas'],
          isAvailable: true,
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateUser(updatedUser);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Yıkamacı olma hatası: $e');
    }
  }
  
  Future<bool> verifyWasher(String washerId, bool isVerified) async {
    try {
      final userData = await _firestoreService.getUserById(washerId);
      if (userData != null) {
        final user = UserModel.fromMap(userData);
        final updatedUser = user.copyWith(
          isVerified: isVerified,
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateUser(updatedUser);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Yıkamacı doğrulama hatası: $e');
    }
  }
} 
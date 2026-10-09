import '../models/booking_model.dart';
import 'firestore_service.dart';

class BookingService {
  final FirestoreService _firestoreService = FirestoreService();
  
  Future<String?> createBooking(BookingModel booking) async {
    try {
      final bookingData = booking.toMap();
      final bookingId = await _firestoreService.createBooking(bookingData);
      return bookingId;
    } catch (e) {
      throw Exception('Rezervasyon oluşturma hatası: $e');
    }
  }
  
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final data = await _firestoreService.getBookingById(bookingId);
      if (data != null) {
        return BookingModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Rezervasyon getirme hatası: $e');
    }
  }
  
  Future<List<BookingModel>> getAllBookings() async {
    try {
      final bookingsData = await _firestoreService.getAllBookings();
      return bookingsData.map((data) => BookingModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Tüm rezervasyonlar getirme hatası: $e');
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final bookingsData = await _firestoreService.getUserBookings(userId);
      return bookingsData.map((data) => BookingModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Kullanıcı rezervasyonları getirme hatası: $e');
    }
  }
  
  Future<List<BookingModel>> getWasherBookings(String washerId) async {
    try {
      final bookingsData = await _firestoreService.getWasherBookings(washerId);
      return bookingsData.map((data) => BookingModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Yıkamacı rezervasyonları getirme hatası: $e');
    }
  }
  
  Future<bool> acceptBooking(String bookingId, String washerId) async {
    try {
      final updateData = {
        'status': BookingStatus.accepted.name,
        'washerId': washerId,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      await _firestoreService.updateBooking(bookingId, updateData);
      return true;
    } catch (e) {
      throw Exception('Rezervasyon kabul etme hatası: $e');
    }
  }
  
  Future<bool> startJob(String bookingId) async {
    try {
      final updateData = {
        'status': BookingStatus.inProgress.name,
        'startTime': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      await _firestoreService.updateBooking(bookingId, updateData);
      return true;
    } catch (e) {
      throw Exception('İş başlatma hatası: $e');
    }
  }
  
  Future<bool> completeJob(String bookingId, String? beforePhotoUrl, String? afterPhotoUrl) async {
    try {
      final updateData = {
        'status': BookingStatus.completed.name,
        'endTime': DateTime.now().toIso8601String(),
        'beforePhotoUrl': beforePhotoUrl,
        'afterPhotoUrl': afterPhotoUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      await _firestoreService.updateBooking(bookingId, updateData);
      return true;
    } catch (e) {
      throw Exception('İş tamamlama hatası: $e');
    }
  }
  
  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      final updateData = {
        'status': BookingStatus.cancelled.name,
        'cancelReason': reason,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      await _firestoreService.updateBooking(bookingId, updateData);
      return true;
    } catch (e) {
      throw Exception('Rezervasyon iptal etme hatası: $e');
    }
  }
  
  Future<bool> rateBooking(String bookingId, double rating, String? review) async {
    try {
      final updateData = {
        'rating': rating,
        'review': review,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      await _firestoreService.updateBooking(bookingId, updateData);
      return true;
    } catch (e) {
      throw Exception('Değerlendirme hatası: $e');
    }
  }
  
  Future<bool> updatePaymentStatus(String bookingId, String paymentId) async {
    try {
      final updateData = {
        'isPaid': true,
        'paymentId': paymentId,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      await _firestoreService.updateBooking(bookingId, updateData);
      return true;
    } catch (e) {
      throw Exception('Ödeme durumu güncelleme hatası: $e');
    }
  }
  
  Future<List<BookingModel>> getNearbyBookings(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final bookingsData = await _firestoreService.getNearbyBookings(
        latitude,
        longitude,
        radiusKm,
      );
      return bookingsData.map((data) => BookingModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Yakındaki rezervasyonlar getirme hatası: $e');
    }
  }
} 
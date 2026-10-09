import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';
import '../services/notification_service.dart';
import '../services/firestore_service.dart';
import '../services/pricing_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final PaymentService _paymentService = PaymentService();
  final NotificationService _notificationService = NotificationService();
  
  List<BookingModel> _bookings = [];
  BookingModel? _currentBooking;
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  BookingModel? get currentBooking => _currentBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BookingModel> get activeBookings => _bookings.where((b) => b.isActive).toList();
  List<BookingModel> get completedBookings => _bookings.where((b) => b.isCompleted).toList();
  List<BookingModel> get userBookings => _bookings;
  List<BookingModel> get recentBookings => _bookings.take(3).toList();

  Future<void> loadBookings(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _bookings = await _bookingService.getUserBookings(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserBookings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Gerçek kullanıcı ID'sini al
      // Bu metod context'e erişemediği için AuthProvider'dan direkt alamayız
      // Bu durumda loadBookings(userId) metodunu kullanmak daha uygun
      // Geçici çözüm: tüm rezervasyonları getir
      _bookings = await _bookingService.getAllBookings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWasherBookings(String washerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _bookings = await _bookingService.getWasherBookings(washerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final booking = await _bookingService.getBookingById(bookingId);
      if (booking != null) {
        _currentBooking = booking;
      }
      return booking;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking(BookingModel booking) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final bookingId = await _bookingService.createBooking(booking);
      if (bookingId != null) {
        final newBooking = booking.copyWith(id: bookingId);
        _bookings.insert(0, newBooking);
        _currentBooking = newBooking;
        
        // Yıkamacılara bildirim gönder
        await _notificationService.notifyWashersForNewBooking(newBooking);
        
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptBooking(String bookingId, String washerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _bookingService.acceptBooking(bookingId, washerId);
      if (success) {
        await _updateBookingInList(bookingId);
        
        // Müşteriye bildirim gönder
        if (_currentBooking != null) {
          await _notificationService.notifyCustomerBookingAccepted(_currentBooking!);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startJob(String bookingId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _bookingService.startJob(bookingId);
      if (success) {
        await _updateBookingInList(bookingId);
        
        // Müşteriye bildirim gönder
        if (_currentBooking != null) {
          await _notificationService.notifyCustomerJobStarted(_currentBooking!);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeJob(String bookingId, String? beforePhotoUrl, String? afterPhotoUrl) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _bookingService.completeJob(bookingId, beforePhotoUrl, afterPhotoUrl);
      if (success) {
        await _updateBookingInList(bookingId);
        
        // Puan kazanma ve achievement logic'i
        if (_currentBooking != null) {
          await _awardPointsAndAchievements(_currentBooking!);
        }
        
        // Müşteriye bildirim gönder
        if (_currentBooking != null) {
          await _notificationService.notifyCustomerJobCompleted(_currentBooking!);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _bookingService.cancelBooking(bookingId, reason);
      if (success) {
        await _updateBookingInList(bookingId);
        
        // İlgili taraflara bildirim gönder
        if (_currentBooking != null) {
          await _notificationService.notifyBookingCancelled(_currentBooking!);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rateBooking(String bookingId, double rating, String? review) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _bookingService.rateBooking(bookingId, rating, review);
      if (success) {
        await _updateBookingInList(bookingId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> processPayment(String bookingId, double amount) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final paymentResult = await _paymentService.processPayment(bookingId, amount);
      if (paymentResult['success'] == true) {
        await _bookingService.updatePaymentStatus(bookingId, paymentResult['paymentId']);
        await _updateBookingInList(bookingId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateBookingInList(String bookingId) async {
    final updatedBooking = await _bookingService.getBookingById(bookingId);
    if (updatedBooking != null) {
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = updatedBooking;
      }
      _currentBooking = updatedBooking;
    }
  }

  void setCurrentBooking(BookingModel booking) {
    _currentBooking = booking;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Kullanıcı bilgilerini güncelle
  void updateUser(UserModel user) {
    notifyListeners();
  }
  
  Future<void> _awardPointsAndAchievements(BookingModel booking) async {
    try {
      final firestoreService = FirestoreService();
      final userData = await firestoreService.getUserById(booking.customerId);
      
      if (userData == null) return;
      
      // Map'i UserModel'e dönüştür
      final user = UserModel.fromMap(userData);
      
      // Puan hesaplama
      int pointsToAdd = 20; // Base points
      
      // Eco-friendly bonus
      if (booking.washType.isEcoFriendly) {
        pointsToAdd += 10;
      }
      
      // Premium service bonus
      if (booking.washType.isPremium) {
        pointsToAdd += 15;
      }
      
      final newPoints = user.points + pointsToAdd;
      int newEcoWashes = user.totalEcoWashes;
      
      if (booking.washType.isEcoFriendly) {
        newEcoWashes++;
      }
      
      // Achievement kontrolü
      final newAchievements = List<String>.from(user.achievements);
      
      // İlk kullanıcı rozeti
      if (user.totalBookings == 0 && !newAchievements.contains('first_user')) {
        newAchievements.add('first_user');
      }
      
      // Çevre dostu rozeti
      if (newEcoWashes >= 5 && !newAchievements.contains('eco_friendly')) {
        newAchievements.add('eco_friendly');
      }
      
      // VIP müşteri rozeti
      if ((user.totalBookings ?? 0) + 1 >= 10 && !newAchievements.contains('vip_customer')) {
        newAchievements.add('vip_customer');
      }
      
      // Kullanıcıyı güncelle
      final updatedUser = user.copyWith(
        points: newPoints,
        achievements: newAchievements,
        totalEcoWashes: newEcoWashes,
        totalBookings: (user.totalBookings ?? 0) + 1,
        lastWashDate: DateTime.now(),
      );
      
      await firestoreService.updateUser(updatedUser);
      
    } catch (e) {
      if (kDebugMode) {
        print('Error awarding points: $e');
      }
    }
  }

  // Fiyat hesaplama
  double calculatePrice(WashType washType, VehicleType vehicleType, bool isEcoFriendly) {
    final pricingData = PricingService().calculateDynamicPrice(
      washType: washType,
      vehicleType: vehicleType,
    );
    
    return pricingData.finalPrice.roundToDouble();
  }

  // Detaylı fiyat bilgisi
  PricingData calculateDetailedPrice(WashType washType, VehicleType vehicleType, {DateTime? scheduledTime}) {
    return PricingService().calculateDynamicPrice(
      washType: washType,
      vehicleType: vehicleType,
      scheduledTime: scheduledTime,
    );
  }
} 
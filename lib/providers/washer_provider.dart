import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../services/washer_service.dart';
import '../services/booking_service.dart';

class WasherProvider extends ChangeNotifier {
  final WasherService _washerService = WasherService();
  final BookingService _bookingService = BookingService();
  
  List<UserModel> _availableWashers = [];
  List<BookingModel> _availableJobs = [];
  List<BookingModel> _nearbyJobs = [];
  List<BookingModel> _washerJobs = [];
  List<BookingModel> _activeJobs = [];
  List<BookingModel> _completedJobs = [];
  UserModel? _selectedWasher;
  bool _isLoading = false;
  String? _error;

  List<UserModel> get availableWashers => _availableWashers;
  List<BookingModel> get availableJobs => _availableJobs;
  List<BookingModel> get nearbyJobs => _nearbyJobs;
  List<BookingModel> get washerJobs => _washerJobs;
  List<BookingModel> get activeJobs => _activeJobs;
  List<BookingModel> get completedJobs => _completedJobs;
  UserModel? get selectedWasher => _selectedWasher;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Dashboard için hesaplanmış değerler
  int get todayJobs {
    final today = DateTime.now();
    return _completedJobs.where((job) {
      final jobDate = job.createdAt;
      return jobDate.year == today.year &&
             jobDate.month == today.month &&
             jobDate.day == today.day;
    }).length;
  }

  double get monthlyEarnings {
    final now = DateTime.now();
    return _completedJobs.where((job) {
      final jobDate = job.createdAt;
      return jobDate.year == now.year && jobDate.month == now.month;
    }).fold(0.0, (sum, job) => sum + job.price);
  }

  // Yakındaki işleri yükle
  Future<void> loadNearbyJobs() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      print('WasherProvider: loadNearbyJobs başlıyor');
      
      // Mock konum (gerçek uygulamada GPS'den alınacak)
      _nearbyJobs = await _washerService.getAvailableJobs(41.0082, 28.9784, 10.0);
      
      print('WasherProvider: _nearbyJobs listesine ${_nearbyJobs.length} iş atandı');
      _nearbyJobs.forEach((job) {
        print('WasherProvider: Job ${job.id} - ${job.status.name} - ${job.washTypeDisplayName}');
      });
      
    } catch (e) {
      print('WasherProvider: loadNearbyJobs hatası: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      print('WasherProvider: loadNearbyJobs tamamlandı, notifyListeners çağrıldı');
    }
  }

  // Yıkamacının işlerini yükle
  Future<void> loadWasherJobs() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Mock yıkamacı ID'si (gerçek uygulamada auth'dan alınacak)
      const String washerId = 'washer1';
      
      final allJobs = await _washerService.getWasherHistory(washerId, limit: 100);
      
      // İşleri duruma göre ayır
      _activeJobs = allJobs.where((job) => 
        job.status == BookingStatus.accepted || 
        job.status == BookingStatus.inProgress
      ).toList();
      
      _completedJobs = allJobs.where((job) => 
        job.status == BookingStatus.completed
      ).toList();
      
      _washerJobs = allJobs;
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Yıkamacı müsaitlik durumunu güncelle
  Future<void> updateAvailability(bool isAvailable) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Mock yıkamacı ID'si (gerçek uygulamada auth'dan alınacak)
      const String washerId = 'washer1';
      
      final success = await updateWasherAvailability(washerId, isAvailable);
      if (success) {
        // Başarılı
        print('Mock: Yıkamacı müsaitlik durumu güncellendi: $isAvailable');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // İş kabul et
  Future<bool> acceptJob(String jobId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      print('WasherProvider: İş kabul ediliyor: $jobId');
      
      // Gerçek booking service kullan
      const String washerId = 'washer1'; // Mock yıkamacı ID
      final success = await _bookingService.acceptBooking(jobId, washerId);
      
      if (success) {
        // Yerel listeleri güncelle
        await _refreshJobLists();
        print('WasherProvider: İş başarıyla kabul edildi: $jobId');
        return true;
      }
      
      return false;
    } catch (e) {
      print('WasherProvider: İş kabul etme hatası: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // İş başlat
  Future<bool> startJob(String jobId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      print('WasherProvider: İş başlatılıyor: $jobId');
      
      // Gerçek booking service kullan
      final success = await _bookingService.startJob(jobId);
      
      if (success) {
        // Yerel listeleri güncelle
        await _refreshJobLists();
        print('WasherProvider: İş başarıyla başlatıldı: $jobId');
        return true;
      }
      
      return false;
    } catch (e) {
      print('WasherProvider: İş başlatma hatası: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // İş tamamla
  Future<bool> completeJob(String jobId, String? beforePhotoUrl, String? afterPhotoUrl) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      print('WasherProvider: İş tamamlanıyor: $jobId');
      
      // Gerçek booking service kullan
      final success = await _bookingService.completeJob(jobId, beforePhotoUrl, afterPhotoUrl);
      
      if (success) {
        // Yerel listeleri güncelle
        await _refreshJobLists();
        print('WasherProvider: İş başarıyla tamamlandı: $jobId');
        return true;
      }
      
      return false;
    } catch (e) {
      print('WasherProvider: İş tamamlama hatası: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // İş iptal et
  Future<bool> cancelJob(String jobId, String reason) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Mock işlem
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Job durumunu güncelle
      final jobIndex = _activeJobs.indexWhere((job) => job.id == jobId);
      if (jobIndex != -1) {
        _activeJobs[jobIndex] = _activeJobs[jobIndex].copyWith(
          status: BookingStatus.cancelled,
          cancelledAt: DateTime.now(),
          cancellationReason: reason,
        );
      }
      
      print('Mock: İş iptal edildi: $jobId, Sebep: $reason');
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // İş detaylarını getir
  Future<BookingModel?> getJobById(String jobId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      print('WasherProvider: İş detayları getiriliyor: $jobId');
      
      // Gerçek booking service kullan
      final job = await _bookingService.getBookingById(jobId);
      
      if (job != null) {
        print('WasherProvider: İş detayları bulundu: ${job.id} - Status: ${job.status.name}');
        return job;
      } else {
        print('WasherProvider: İş bulunamadı: $jobId');
        return null;
      }
    } catch (e) {
      print('WasherProvider: İş detayları getirme hatası: $e');
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fotoğraf yükle
  Future<String?> uploadPhoto(String filePath, String jobId, String photoType) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Mock fotoğraf yükleme
      await Future.delayed(const Duration(seconds: 2));
      
      final mockUrl = 'https://example.com/photos/$jobId/${photoType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      print('Mock: Fotoğraf yüklendi: $photoType -> $mockUrl');
      return mockUrl;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // GPS konumunu güncelle
  Future<bool> updateLocation(double latitude, double longitude) async {
    try {
      // Mock GPS güncelleme
      await Future.delayed(const Duration(milliseconds: 300));
      
      print('Mock: GPS konumu güncellendi: $latitude, $longitude');
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Mesai durumunu değiştir
  Future<bool> toggleWorkStatus() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('Mock: Mesai durumu değiştirildi');
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableWashers(double latitude, double longitude, double radiusKm) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _availableWashers = await _washerService.getAvailableWashers(latitude, longitude, radiusKm);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableJobs(double latitude, double longitude, double radiusKm) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _availableJobs = await _washerService.getAvailableJobs(latitude, longitude, radiusKm);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> getWasherById(String washerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final washer = await _washerService.getWasherById(washerId);
      if (washer != null) {
        _selectedWasher = washer;
      }
      return washer;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateWasherAvailability(String washerId, bool isAvailable) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _washerService.updateWasherAvailability(washerId, isAvailable);
      if (success) {
        // Yerel listeyi güncelle
        final index = _availableWashers.indexWhere((w) => w.id == washerId);
        if (index != -1) {
          _availableWashers[index] = _availableWashers[index].copyWith(isAvailable: isAvailable);
        }
        
        if (_selectedWasher?.id == washerId) {
          _selectedWasher = _selectedWasher!.copyWith(isAvailable: isAvailable);
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

  Future<bool> updateWasherLocation(String washerId, double latitude, double longitude) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _washerService.updateWasherLocation(washerId, latitude, longitude);
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateWasherServiceAreas(String washerId, List<String> serviceAreas) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _washerService.updateWasherServiceAreas(washerId, serviceAreas);
      if (success) {
        // Yerel listeyi güncelle
        final index = _availableWashers.indexWhere((w) => w.id == washerId);
        if (index != -1) {
          _availableWashers[index] = _availableWashers[index].copyWith(serviceAreas: serviceAreas);
        }
        
        if (_selectedWasher?.id == washerId) {
          _selectedWasher = _selectedWasher!.copyWith(serviceAreas: serviceAreas);
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

  Future<List<UserModel>> searchWashers(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final washers = await _washerService.searchWashers(query);
      return washers;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getWasherStatistics(String washerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final stats = await _washerService.getWasherStatistics(washerId);
      return stats;
    } catch (e) {
      _error = e.toString();
      return {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<BookingModel>> getWasherHistory(String washerId, {int limit = 20}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final history = await _washerService.getWasherHistory(washerId, limit: limit);
      return history;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getWasherReviews(String washerId, {int limit = 10}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final reviews = await _washerService.getWasherReviews(washerId, limit: limit);
      return reviews;
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> becomeWasher(String userId, Map<String, dynamic> washerData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _washerService.becomeWasher(userId, washerData);
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyWasher(String washerId, bool isVerified) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final success = await _washerService.verifyWasher(washerId, isVerified);
      if (success) {
        // Yerel listeyi güncelle
        final index = _availableWashers.indexWhere((w) => w.id == washerId);
        if (index != -1) {
          _availableWashers[index] = _availableWashers[index].copyWith(isVerified: isVerified);
        }
        
        if (_selectedWasher?.id == washerId) {
          _selectedWasher = _selectedWasher!.copyWith(isVerified: isVerified);
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

  // Yıkamacı filtreleme
  List<UserModel> filterWashers({
    double? minRating,
    bool? isVerified,
    List<String>? serviceAreas,
  }) {
    List<UserModel> filtered = List.from(_availableWashers);
    
    if (minRating != null) {
      filtered = filtered.where((w) => (w.rating ?? 0) >= minRating).toList();
    }
    
    if (isVerified != null) {
      filtered = filtered.where((w) => w.isVerified == isVerified).toList();
    }
    
    if (serviceAreas != null && serviceAreas.isNotEmpty) {
      filtered = filtered.where((w) {
        if (w.serviceAreas == null) return false;
        return serviceAreas.any((area) => w.serviceAreas!.contains(area));
      }).toList();
    }
    
    return filtered;
  }

  // Yıkamacı sıralama
  List<UserModel> sortWashers(List<UserModel> washers, String sortBy) {
    switch (sortBy) {
      case 'rating':
        washers.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'totalJobs':
        washers.sort((a, b) => (b.totalJobs ?? 0).compareTo(a.totalJobs ?? 0));
        break;
      case 'name':
        washers.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
    }
    return washers;
  }

  void setSelectedWasher(UserModel washer) {
    _selectedWasher = washer;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper method to refresh job lists after accepting a job
  Future<void> _refreshJobLists() async {
    await loadNearbyJobs();
    await loadWasherJobs();
  }
} 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/booking_model.dart';

// Mock Notification Service - Firebase olmadan çalışır
class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    // Local notifications başlatma
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(initSettings);
    print('Mock: Notification service başlatıldı');
  }
  
  Future<String?> getToken() async {
    try {
      // Mock FCM token
      final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      print('Mock: FCM token: $mockToken');
      return mockToken;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> subscribeToTopic(String topic) async {
    try {
      print('Mock: Topic\'e abone olundu: $topic');
    } catch (e) {
      print('Mock: Topic abone olma hatası: $e');
    }
  }
  
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      print('Mock: Topic aboneliği iptal edildi: $topic');
    } catch (e) {
      print('Mock: Topic abonelik iptal hatası: $e');
    }
  }
  
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'gleam_channel',
      'Gleam Notifications',
      channelDescription: 'Notifications for Gleam app',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      0,
      title,
      body,
      details,
      payload: payload,
    );
    
    print('Mock: Bildirim gösterildi - $title: $body');
  }
  
  // Rezervasyon bildirimleri
  Future<void> notifyWashersForNewBooking(BookingModel booking) async {
    await showLocalNotification(
      title: 'Yeni İş Fırsatı!',
      body: '${booking.address} adresinde ${booking.washTypeDisplayName} için yeni rezervasyon',
      payload: 'booking_${booking.id}',
    );
  }
  
  Future<void> notifyCustomerBookingAccepted(BookingModel booking) async {
    await showLocalNotification(
      title: 'Rezervasyon Kabul Edildi',
      body: 'Rezervasyonunuz ${booking.washerName} tarafından kabul edildi',
      payload: 'booking_${booking.id}',
    );
  }
  
  Future<void> notifyCustomerJobStarted(BookingModel booking) async {
    await showLocalNotification(
      title: 'Yıkama Başladı',
      body: '${booking.washerName} araç yıkama işlemini başlattı',
      payload: 'booking_${booking.id}',
    );
  }
  
  Future<void> notifyCustomerJobCompleted(BookingModel booking) async {
    await showLocalNotification(
      title: 'Yıkama Tamamlandı',
      body: 'Araç yıkama işlemi tamamlandı. Değerlendirme yapabilirsiniz.',
      payload: 'booking_${booking.id}',
    );
  }
  
  Future<void> notifyBookingCancelled(BookingModel booking) async {
    await showLocalNotification(
      title: 'Rezervasyon İptal Edildi',
      body: 'Rezervasyonunuz iptal edildi',
      payload: 'booking_${booking.id}',
    );
  }
  
  Future<void> notifyPaymentReceived(double amount) async {
    await showLocalNotification(
      title: 'Ödeme Alındı',
      body: '${amount.toStringAsFixed(2)} TL ödemeniz başarıyla alındı',
    );
  }
  
  Future<void> notifyWeatherAlert(String message) async {
    await showLocalNotification(
      title: 'Hava Durumu Uyarısı',
      body: message,
    );
  }
} 
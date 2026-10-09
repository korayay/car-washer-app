// Mock Auth Service - Firebase olmadan çalışır
class MockUser {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  
  MockUser({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
  });
}

class AuthService {
  MockUser? _currentUser;
  String? _verificationId;
  
  // Mevcut kullanıcı
  MockUser? get currentUser => _currentUser;
  
  // Giriş durumu akışı (StreamController kullanarak)
  Stream<MockUser?> get authStateChanges async* {
    yield _currentUser;
  }
  
  // Email ile giriş
  Future<MockUser?> signInWithEmail(String email, String password) async {
    try {
      // Mock giriş - herhangi bir email/şifre kabul eder
      await Future.delayed(const Duration(seconds: 1)); // Gerçek API çağrısı simülasyonu
      
      // Email'e göre doğru mock user ID döndür
      String uid;
      switch (email.toLowerCase()) {
        case 'ahmet@example.com':
          uid = 'customer1';
          break;
        case 'ayse@example.com':
          uid = 'customer2';
          break;
        case 'mehmet@example.com':
          uid = 'washer1';
          break;
        case 'ali@example.com':
          uid = 'washer2';
          break;
        case 'admin@gleam.com':
          uid = 'admin1';
          break;
        default:
          // Yeni kullanıcı için random ID
          uid = DateTime.now().millisecondsSinceEpoch.toString();
          break;
      }
      
      _currentUser = MockUser(
        uid: uid,
        email: email,
        displayName: email.split('@')[0],
      );
      
      print('Mock: Email ile giriş yapıldı: $email -> UID: $uid');
      return _currentUser;
    } catch (e) {
      throw Exception('Giriş hatası: $e');
    }
  }
  
  // Email ile kayıt
  Future<MockUser?> signUpWithEmail(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = MockUser(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        displayName: email.split('@')[0],
      );
      
      print('Mock: Email ile kayıt yapıldı: $email');
      return _currentUser;
    } catch (e) {
      throw Exception('Kayıt hatası: $e');
    }
  }
  
  // Telefon ile giriş
  Future<bool> signInWithPhoneNumber(String phoneNumber) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock verification ID oluştur
      _verificationId = DateTime.now().millisecondsSinceEpoch.toString();
      
      print('Mock: SMS gönderildi: $phoneNumber');
      print('Mock: Verification ID: $_verificationId');
      print('Mock: Test OTP kodu: 123456');
      
      return true;
    } catch (e) {
      throw Exception('SMS gönderme hatası: $e');
    }
  }
  
  // OTP doğrulama
  Future<MockUser?> verifyOTP(String verificationId, String otp) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock OTP doğrulama - 123456 kabul eder
      if (otp == '123456') {
        _currentUser = MockUser(
          uid: DateTime.now().millisecondsSinceEpoch.toString(),
          phoneNumber: '+90555000000', // Mock telefon numarası
          displayName: 'Test Kullanıcı',
        );
        
        print('Mock: OTP doğrulandı: $otp');
        return _currentUser;
      } else {
        throw Exception('Geçersiz OTP kodu');
      }
    } catch (e) {
      throw Exception('OTP doğrulama hatası: $e');
    }
  }
  
  // Şifre değiştirme
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      print('Mock: Şifre değiştirildi');
    } catch (e) {
      throw Exception('Şifre değiştirme hatası: $e');
    }
  }
  
  // Şifre sıfırlama
  Future<void> resetPassword(String email) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      print('Mock: Şifre sıfırlama e-postası gönderildi: $email');
    } catch (e) {
      throw Exception('Şifre sıfırlama hatası: $e');
    }
  }
  
  // Çıkış
  Future<void> signOut() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = null;
      print('Mock: Çıkış yapıldı');
    } catch (e) {
      throw Exception('Çıkış hatası: $e');
    }
  }
  
  // Hesap silme
  Future<void> deleteAccount() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = null;
      print('Mock: Hesap silindi');
    } catch (e) {
      throw Exception('Hesap silme hatası: $e');
    }
  }
} 
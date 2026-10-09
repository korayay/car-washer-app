class PaymentService {
  Future<Map<String, dynamic>> processPayment(String bookingId, double amount) async {
    try {
      // Demo ödeme işlemi
      await Future.delayed(const Duration(seconds: 2));
      
      // Başarılı ödeme simülasyonu
      return {
        'success': true,
        'paymentId': 'payment_${DateTime.now().millisecondsSinceEpoch}',
        'transactionId': 'txn_${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'currency': 'TRY',
        'status': 'completed',
        'processedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Ödeme işlemi hatası: $e');
    }
  }
  
  Future<bool> refundPayment(String paymentId, double amount) async {
    try {
      // Demo iade işlemi
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      throw Exception('İade işlemi hatası: $e');
    }
  }
  
  Future<Map<String, dynamic>> getPaymentDetails(String paymentId) async {
    try {
      // Demo ödeme detayları
      return {
        'paymentId': paymentId,
        'amount': 150.0,
        'currency': 'TRY',
        'status': 'completed',
        'method': 'credit_card',
        'processedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Ödeme detayları getirme hatası: $e');
    }
  }
} 
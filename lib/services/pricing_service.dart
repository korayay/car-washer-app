import 'dart:math';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';

enum DemandLevel {
  low,    // Düşük talep -%15
  normal, // Normal fiyat
  high,   // Yüksek talep +%10
  peak,   // Pik saat +%20
}

class PricingData {
  final double basePrice;
  final double finalPrice;
  final double discountPercentage;
  final DemandLevel demandLevel;
  final String explanation;
  final bool hasPromotion;

  const PricingData({
    required this.basePrice,
    required this.finalPrice,
    required this.discountPercentage,
    required this.demandLevel,
    required this.explanation,
    required this.hasPromotion,
  });
}

class PricingService {
  static final PricingService _instance = PricingService._internal();
  factory PricingService() => _instance;
  PricingService._internal();

  // Mock demand data - gerçek uygulamada server'dan gelir
  DemandLevel getCurrentDemandLevel() {
    final hour = DateTime.now().hour;
    final random = Random();
    
    // Pik saatler: 8-10, 17-19
    if ((hour >= 8 && hour <= 10) || (hour >= 17 && hour <= 19)) {
      return random.nextBool() ? DemandLevel.peak : DemandLevel.high;
    }
    
    // Gece saatleri: düşük talep
    if (hour >= 22 || hour <= 6) {
      return DemandLevel.low;
    }
    
    // Diğer saatler: rastgele
    final demands = [DemandLevel.low, DemandLevel.normal, DemandLevel.high];
    return demands[random.nextInt(demands.length)];
  }

  PricingData calculateDynamicPrice({
    required WashType washType,
    required VehicleType vehicleType,
    DateTime? scheduledTime,
  }) {
    // Base price hesaplama
    final basePrice = _getBasePrice(washType, vehicleType);
    
    // Demand level hesaplama
    final demandLevel = scheduledTime != null 
        ? _getDemandLevelForTime(scheduledTime)
        : getCurrentDemandLevel();
    
    // Dynamic pricing hesaplama
    double multiplier = _getDemandMultiplier(demandLevel);
    
    // Random promotion chance
    final hasPromotion = Random().nextDouble() < 0.2; // %20 şans
    if (hasPromotion && demandLevel == DemandLevel.low) {
      multiplier -= 0.1; // Extra %10 indirim
    }
    
    final finalPrice = basePrice * multiplier;
    final discountPercentage = ((basePrice - finalPrice) / basePrice) * 100;
    
    return PricingData(
      basePrice: basePrice,
      finalPrice: finalPrice,
      discountPercentage: discountPercentage,
      demandLevel: demandLevel,
      explanation: _getExplanation(demandLevel, hasPromotion),
      hasPromotion: hasPromotion,
    );
  }

  double _getBasePrice(WashType washType, VehicleType vehicleType) {
    double basePrice = washType.price;
    
    // Vehicle type multiplier
    switch (vehicleType) {
      case VehicleType.car:
        break; // No change
      case VehicleType.suv:
        basePrice *= 1.2; // %20 extra
        break;
      case VehicleType.truck:
        basePrice *= 1.5; // %50 extra
        break;
      case VehicleType.motorcycle:
        basePrice *= 0.7; // %30 discount
        break;
    }
    
    return basePrice;
  }

  DemandLevel _getDemandLevelForTime(DateTime time) {
    final hour = time.hour;
    
    // Pik saatler
    if ((hour >= 8 && hour <= 10) || (hour >= 17 && hour <= 19)) {
      return DemandLevel.peak;
    }
    
    // Gece saatleri
    if (hour >= 22 || hour <= 6) {
      return DemandLevel.low;
    }
    
    // Hafta sonu kontrolü
    final isWeekend = time.weekday >= 6;
    if (isWeekend && hour >= 10 && hour <= 16) {
      return DemandLevel.high;
    }
    
    return DemandLevel.normal;
  }

  double _getDemandMultiplier(DemandLevel level) {
    switch (level) {
      case DemandLevel.low:
        return 0.85; // %15 indirim
      case DemandLevel.normal:
        return 1.0;  // Normal fiyat
      case DemandLevel.high:
        return 1.1;  // %10 artış
      case DemandLevel.peak:
        return 1.2;  // %20 artış
    }
  }

  String _getExplanation(DemandLevel level, bool hasPromotion) {
    String base = '';
    
    switch (level) {
      case DemandLevel.low:
        base = 'Düşük talep - İndirimli fiyat!';
        break;
      case DemandLevel.normal:
        base = 'Normal fiyat';
        break;
      case DemandLevel.high:
        base = 'Yüksek talep - Artışlı fiyat';
        break;
      case DemandLevel.peak:
        base = 'Pik saat - Premium fiyat';
        break;
    }
    
    if (hasPromotion) {
      base += ' + Özel kampanya!';
    }
    
    return base;
  }

  List<String> getPricingTips() {
    return [
      '🕘 Sabah 8-10 ve akşam 17-19 arası pik saatlerdir',
      '🌙 Gece saatleri en uygun fiyatlardır',
      '📅 Hafta içi genelde daha ekonomiktir',
      '⏰ Esnek saatlerde rezervasyon yapın',
      '💡 Bildirimlerle özel kampanyaları kaçırmayın',
    ];
  }
}

extension DemandLevelExtension on DemandLevel {
  String get displayName {
    switch (this) {
      case DemandLevel.low:
        return 'Düşük Talep';
      case DemandLevel.normal:
        return 'Normal';
      case DemandLevel.high:
        return 'Yüksek Talep';
      case DemandLevel.peak:
        return 'Pik Saat';
    }
  }

  String get emoji {
    switch (this) {
      case DemandLevel.low:
        return '📉';
      case DemandLevel.normal:
        return '📊';
      case DemandLevel.high:
        return '📈';
      case DemandLevel.peak:
        return '🔥';
    }
  }

  Color get color {
    switch (this) {
      case DemandLevel.low:
        return const Color(0xFF4CAF50); // Green
      case DemandLevel.normal:
        return const Color(0xFF2196F3); // Blue
      case DemandLevel.high:
        return const Color(0xFFFF9800); // Orange
      case DemandLevel.peak:
        return const Color(0xFFF44336); // Red
    }
  }
} 
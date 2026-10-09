import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking_model.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  BookingModel? _booking;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Her 5 saniyede bir otomatik refresh
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        print('BookingDetails: Otomatik refresh - ${DateTime.now()}');
        _loadBookingDetails(silent: true);
      }
    });
  }

  Future<void> _loadBookingDetails({bool silent = false}) async {
    final bookingProvider = context.read<BookingProvider>();
    
    if (!silent) {
      setState(() {
        _isLoading = true;
      });
    }
    
    final booking = await bookingProvider.getBookingById(widget.bookingId);
    
    if (mounted) {
      setState(() {
        _booking = booking;
        if (!silent) {
          _isLoading = false;
        }
      });
      
      if (booking != null) {
        print('BookingDetails: Güncellendi - Status: ${booking.status.name}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        GoRouter.of(context).go(AppRoutes.home);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rezervasyon Detayları'),
          actions: [
            if (_booking != null && _booking!.canCancel)
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'cancel':
                      _showCancelDialog();
                      break;
                    case 'edit':
                      // TODO: Düzenleme sayfasına git
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Düzenle'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red),
                        SizedBox(width: 8),
                        Text('İptal Et', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _booking == null
                ? const Center(child: Text('Rezervasyon bulunamadı'))
                : RefreshIndicator(
                    onRefresh: _loadBookingDetails,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusCard(),
                          const SizedBox(height: 16),
                          _buildServiceInfo(),
                          const SizedBox(height: 16),
                          _buildVehicleInfo(),
                          const SizedBox(height: 16),
                          _buildLocationInfo(),
                          const SizedBox(height: 16),
                          _buildScheduleInfo(),
                          if (_booking!.washerId != null) ...[
                            const SizedBox(height: 16),
                            _buildWasherInfo(),
                          ],
                          if (_booking!.beforePhotoUrl != null || _booking!.afterPhotoUrl != null) ...[
                            const SizedBox(height: 16),
                            _buildPhotosSection(),
                          ],
                          if (_booking!.canRate) ...[
                            const SizedBox(height: 16),
                            _buildRatingSection(),
                          ],
                          const SizedBox(height: 16),
                          _buildPaymentInfo(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
        bottomNavigationBar: _buildBottomActions(),
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusColor = _getStatusColor(_booking!.status);
    final statusText = _booking!.statusDisplayName;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor,
            statusColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(_booking!.status),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _booking!.status == BookingStatus.pending 
                          ? (_booking!.washerName ?? 'Yıkamacı atanıyor...')
                          : (_booking!.washerName ?? 'Mehmet Öz'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rezervasyon #${_booking!.id.substring(0, 8)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Canlı durum indicator
              if (_booking!.status == BookingStatus.inProgress)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress timeline
          _buildProgressTimeline(),
          
          if (_booking!.status == BookingStatus.inProgress) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.cleaning_services, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Yıkama işlemi devam ediyor...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Live indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'CANLI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressTimeline() {
    final steps = [
      {'status': BookingStatus.pending, 'title': 'Talep'},
      {'status': BookingStatus.accepted, 'title': 'Kabul'},
      {'status': BookingStatus.inProgress, 'title': 'Yıkama'},
      {'status': BookingStatus.completed, 'title': 'Tamamlandı'},
    ];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: steps.map((step) {
          final status = step['status'] as BookingStatus;
          final title = step['title'] as String;
          final isCompleted = _getStatusIndex(_booking!.status) >= _getStatusIndex(status);
          final isCurrent = _booking!.status == status;
          
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.white : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                  child: isCompleted 
                    ? Icon(
                        status == BookingStatus.completed ? Icons.check : Icons.circle,
                        color: _getStatusColor(_booking!.status),
                        size: 16,
                      )
                    : null,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: isCompleted ? Colors.white : Colors.white.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  int _getStatusIndex(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending: return 0;
      case BookingStatus.accepted: return 1;
      case BookingStatus.inProgress: return 2;
      case BookingStatus.completed: return 3;
      case BookingStatus.cancelled: return -1;
      case BookingStatus.disputed: return -1;
    }
  }

  Widget _buildServiceInfo() {
    return _InfoCard(
      title: 'Hizmet Bilgileri',
      icon: Icons.local_car_wash,
      children: [
        _InfoRow(
          label: 'Hizmet Tipi',
          value: _booking!.washTypeDisplayName,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Eco-friendly etiketi
              if (_booking!.washType.isEcoFriendly)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ECO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Premium etiketi
              if (_booking!.washType.isPremium) ...[
                if (_booking!.washType.isEcoFriendly) const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_booking!.isEcoFriendly)
          _InfoRow(
            label: 'Özel',
            value: 'Çevre Dostu Yıkama',
            valueColor: AppTheme.greenPrimary,
          ),
        _InfoRow(
          label: 'Fiyat',
          value: '${_booking!.price.toStringAsFixed(0)}₺',
          valueColor: AppTheme.primaryColor,
        ),
        if (_booking!.estimatedDuration != null)
          _InfoRow(
            label: 'Tahmini Süre',
            value: '${_booking!.estimatedDuration} dakika',
          ),
      ],
    );
  }

  Widget _buildVehicleInfo() {
    return _InfoCard(
      title: 'Araç Bilgileri',
      icon: Icons.directions_car,
      children: [
        _InfoRow(
          label: 'Araç Tipi',
          value: _booking!.vehicleTypeDisplayName,
        ),
        _InfoRow(
          label: 'Model',
          value: _booking!.vehicleModel,
        ),
        _InfoRow(
          label: 'Renk',
          value: _booking!.vehicleColor,
        ),
        _InfoRow(
          label: 'Plaka',
          value: _booking!.vehiclePlate,
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return _InfoCard(
      title: 'Konum Bilgileri',
      icon: Icons.location_on,
      children: [
        _InfoRow(
          label: 'Adres',
          value: _booking!.address,
          multiline: true,
        ),
      ],
      trailing: TextButton.icon(
        onPressed: _openInMaps,
        icon: const Icon(Icons.directions),
        label: const Text('Haritada Aç'),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildScheduleInfo() {
    final scheduledDateTime = _booking!.scheduledDate;
    final startedTime = _booking!.startedAt;
    final completedTime = _booking!.completedAt;
    
    return _InfoCard(
      title: 'Zaman Bilgileri',
      icon: Icons.schedule,
      children: [
        _InfoRow(
          label: 'Tarih',
          value: '${scheduledDateTime.day}/${scheduledDateTime.month}/${scheduledDateTime.year}',
        ),
        _InfoRow(
          label: 'Saat',
          value: '${scheduledDateTime.hour.toString().padLeft(2, '0')}:${scheduledDateTime.minute.toString().padLeft(2, '0')}',
        ),
        if (startedTime != null)
          _InfoRow(
            label: 'Başlangıç',
            value: '${startedTime.hour.toString().padLeft(2, '0')}:${startedTime.minute.toString().padLeft(2, '0')}',
          ),
        if (completedTime != null)
          _InfoRow(
            label: 'Bitiş',
            value: '${completedTime.hour.toString().padLeft(2, '0')}:${completedTime.minute.toString().padLeft(2, '0')}',
          ),
        if (_booking!.actualDuration != null)
          _InfoRow(
            label: 'Gerçek Süre',
            value: '${_booking!.actualDuration!.inMinutes} dakika',
          ),
      ],
    );
  }

  Widget _buildWasherInfo() {
    return _InfoCard(
      title: 'Yıkamacı Bilgileri',
      icon: Icons.person,
      children: [
        // Yıkamacı profil kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              // Yıkamacı bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _booking!.status == BookingStatus.pending 
                          ? (_booking!.washerName ?? 'Yıkamacı atanıyor...')
                          : (_booking!.washerName ?? 'Mehmet Öz'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '4.8 (127 değerlendirme)',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3 yıl deneyim • Çevre dostu',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_booking!.washerPhone != null) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor, width: 1.5),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.phone, color: AppTheme.primaryColor, size: 20),
                      onPressed: () => _callWasher(_booking!.washerPhone!),
                      tooltip: 'Ara',
                      style: IconButton.styleFrom(
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Araç bilgileri
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.grey50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.local_shipping, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ford Transit - 34 ABC 123',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _trackWasher(),
                icon: Icon(Icons.my_location, size: 16),
                label: Text('Takip Et'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return _InfoCard(
      title: 'Öncesi & Sonrası Fotoğraflar',
      icon: Icons.photo_camera,
      children: [
        if (_booking!.beforePhotoUrl != null && _booking!.afterPhotoUrl != null)
          // Before/After karşılaştırması
          Column(
            children: [
              // Fotoğraf başlıkları
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'ÖNCE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'SONRA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Fotoğraflar
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showPhoto(_booking!.beforePhotoUrl!),
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(_booking!.beforePhotoUrl!),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Büyüt',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showPhoto(_booking!.afterPhotoUrl!),
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(_booking!.afterPhotoUrl!),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Büyüt',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Sonuç mesajı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.successGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Araç yıkama işlemi başarıyla tamamlandı!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          // Tek fotoğraf varsa
          Column(
            children: [
              if (_booking!.beforePhotoUrl != null) ...[
                Text(
                  'Başlangıç Fotoğrafı',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showPhoto(_booking!.beforePhotoUrl!),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(_booking!.beforePhotoUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
              
              if (_booking!.afterPhotoUrl != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Tamamlanmış Fotoğraf',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showPhoto(_booking!.afterPhotoUrl!),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(_booking!.afterPhotoUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return _InfoCard(
      title: 'Hizmeti Değerlendirin',
      icon: Icons.star_rate,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.amber.shade50,
                Colors.orange.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.star_rate, color: Colors.amber, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Memnun kaldınız mı?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        Text(
                          'Değerlendirmeniz diğer kullanıcılara yardımcı olur',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showRatingDialog,
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Değerlendirme Yap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return _InfoCard(
      title: 'Ödeme Bilgileri',
      icon: Icons.payment,
      children: [
        _InfoRow(
          label: 'Toplam Tutar',
          value: '${_booking!.price.toStringAsFixed(0)}₺',
          valueColor: AppTheme.primaryColor,
        ),
        _InfoRow(
          label: 'Ödeme Durumu',
          value: _booking!.isPaid ? 'Ödendi' : 'Ödenmedi',
          valueColor: _booking!.isPaid ? Colors.green : Colors.orange,
        ),
      ],
    );
  }

  Widget? _buildBottomActions() {
    if (_booking == null) return null;

    final List<Widget> actions = [];

    switch (_booking!.status) {
      case BookingStatus.pending:
        actions.add(
          Expanded(
            child: OutlinedButton(
              onPressed: _showCancelDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('İptal Et'),
            ),
          ),
        );
        break;
        
      case BookingStatus.accepted:
        actions.addAll([
          Expanded(
            child: OutlinedButton(
              onPressed: _showCancelDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('İptal Et'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _callWasher(_booking!.washerPhone!),
              icon: const Icon(Icons.phone),
              label: const Text('Yıkamacıyı Ara'),
            ),
          ),
        ]);
        break;
        
      case BookingStatus.inProgress:
        actions.add(
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _callWasher(_booking!.washerPhone!),
              icon: const Icon(Icons.phone),
              label: const Text('Yıkamacıyı Ara'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
        );
        break;
        
      case BookingStatus.completed:
        if (!_booking!.isPaid) {
          actions.add(
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _processPayment,
                icon: const Icon(Icons.payment),
                label: const Text('Ödeme Yap'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          );
        }
        break;
        
      default:
        break;
    }

    if (actions.isEmpty) return null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(children: actions),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.disputed:
        return Colors.red.shade800;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.accepted:
        return Icons.check_circle_outline;
      case BookingStatus.inProgress:
        return Icons.cleaning_services;
      case BookingStatus.completed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
      case BookingStatus.disputed:
        return Icons.error;
    }
  }

  void _openInMaps() async {
    final lat = _booking!.location['lat'] ?? 0.0;
    final lng = _booking!.location['lng'] ?? 0.0;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _callWasher(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _trackWasher() async {
    final lat = _booking!.location['lat'] ?? 0.0;
    final lng = _booking!.location['lng'] ?? 0.0;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _showPhoto(String photoUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Fotoğraf'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Image.network(
              photoUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: AppTheme.grey200,
                  child: const Center(
                    child: Text('Fotoğraf yüklenemedi'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rezervasyonu İptal Et'),
        content: const Text(
          'Bu rezervasyonu iptal etmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    double rating = 5.0;
    String review = '';
    final TextEditingController reviewController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık ve yıkamacı bilgisi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _booking!.washerName ?? 'Yıkamacı',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Hizmeti nasıl buldunuz?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Yıldız değerlendirmesi
                Text(
                  rating == 1 ? 'Çok Kötü' :
                  rating == 2 ? 'Kötü' :
                  rating == 3 ? 'Orta' :
                  rating == 4 ? 'İyi' : 'Mükemmel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: rating <= 2 ? Colors.red :
                           rating == 3 ? Colors.orange :
                           rating == 4 ? Colors.blue : Colors.green,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Animated yıldızlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSelected = index < rating;
                    return GestureDetector(
                      onTap: () => setState(() => rating = index + 1.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isSelected ? Icons.star : Icons.star_border,
                          color: isSelected 
                            ? (rating <= 2 ? Colors.red :
                               rating == 3 ? Colors.orange :
                               rating == 4 ? Colors.blue : Colors.green)
                            : Colors.grey.shade300,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 24),
                
                // Yorum alanı
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      hintText: 'Deneyiminizi paylaşın... (opsiyonel)',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 3,
                    onChanged: (value) => review = value,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: rating <= 2 
                            ? LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600])
                            : rating == 3 
                              ? LinearGradient(colors: [Colors.orange.shade400, Colors.orange.shade600])
                              : rating == 4
                                ? LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade600])
                                : LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _submitRating(rating, review);
                          },
                          icon: const Icon(Icons.send, color: Colors.white),
                          label: const Text(
                            'Gönder',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cancelBooking() async {
    final bookingProvider = context.read<BookingProvider>();
    final success = await bookingProvider.cancelBooking(
      _booking!.id,
      'Müşteri tarafından iptal edildi',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rezervasyon iptal edildi')),
      );
      _loadBookingDetails();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookingProvider.error ?? 'İptal işlemi başarısız')),
      );
    }
  }

  Future<void> _submitRating(double rating, String review) async {
    final bookingProvider = context.read<BookingProvider>();
    final success = await bookingProvider.rateBooking(
      _booking!.id,
      rating,
      review.isNotEmpty ? review : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Değerlendirmeniz kaydedildi')),
      );
      _loadBookingDetails();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookingProvider.error ?? 'Değerlendirme gönderilemedi')),
      );
    }
  }

  Future<void> _processPayment() async {
    final bookingProvider = context.read<BookingProvider>();
    final success = await bookingProvider.processPayment(
      _booking!.id,
      _booking!.price,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ödeme başarılı')),
      );
      _loadBookingDetails();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookingProvider.error ?? 'Ödeme başarısız')),
      );
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool multiline;
  final Widget? trailing;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.multiline = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
} 
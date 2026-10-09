import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../../providers/washer_provider.dart';
import '../../models/booking_model.dart';
import '../../config/theme.dart';

class WasherJobDetailsScreen extends StatefulWidget {
  final String jobId;

  const WasherJobDetailsScreen({
    super.key,
    required this.jobId,
  });

  @override
  State<WasherJobDetailsScreen> createState() => _WasherJobDetailsScreenState();
}

class _WasherJobDetailsScreenState extends State<WasherJobDetailsScreen> {
  BookingModel? _job;
  bool _isLoading = true;
  String? _beforePhotoUrl;
  String? _afterPhotoUrl;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Her 3 saniyede bir otomatik refresh (yıkamacı için daha sık)
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        print('WasherJobDetails: Otomatik refresh - ${DateTime.now()}');
        _loadJobDetails(silent: true);
      }
    });
  }

  Future<void> _loadJobDetails({bool silent = false}) async {
    final washerProvider = context.read<WasherProvider>();
    
    if (!silent) {
      setState(() {
        _isLoading = true;
      });
    }
    
    final job = await washerProvider.getJobById(widget.jobId);
    
    if (mounted) {
      setState(() {
        _job = job;
        if (!silent) {
          _isLoading = false;
        }
      });
      
      if (job != null) {
        print('WasherJobDetails: Güncellendi - Status: ${job.status.name}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İş Detayları'),
        actions: [
          if (_job != null && _job!.customerPhone.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () => _callCustomer(_job!.customerPhone),
              tooltip: 'Müşteriyi Ara',
            ),
          if (_job?.location != null)
            IconButton(
              icon: const Icon(Icons.directions),
              onPressed: _openInMaps,
              tooltip: 'Navigasyon',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _job == null
              ? const Center(child: Text('İş bulunamadı'))
              : RefreshIndicator(
                  onRefresh: _loadJobDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusCard(),
                        const SizedBox(height: 16),
                        _buildCustomerInfo(),
                        const SizedBox(height: 16),
                        _buildJobDetails(),
                        const SizedBox(height: 16),
                        _buildLocationInfo(),
                        const SizedBox(height: 16),
                        _buildPhotosSection(),
                        if (_job!.status == BookingStatus.inProgress && _job!.startedAt != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.play_circle, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'İş Devam Ediyor',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Başlama: ${_job!.startedAt!.hour.toString().padLeft(2, '0')}:${_job!.startedAt!.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildStatusCard() {
    final statusColor = _getStatusColor(_job!.status);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [statusColor, statusColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(_job!.status),
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _job!.statusDisplayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _job!.washTypeDisplayName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Eco-friendly etiketi
                        if (_job!.washType.isEcoFriendly)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ECO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // Premium etiketi
                        if (_job!.washType.isPremium) ...[
                          if (_job!.washType.isEcoFriendly) const SizedBox(width: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'İş #${_job!.id}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_job!.price.toStringAsFixed(0)}₺',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _job!.washTypeDisplayName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (_job!.status == BookingStatus.inProgress && _job!.startedAt != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Başlama: ${_job!.startedAt!.hour.toString().padLeft(2, '0')}:${_job!.startedAt!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getElapsedTime(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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

  Widget _buildCustomerInfo() {
    return _InfoCard(
      title: 'Müşteri Bilgileri',
      icon: Icons.person,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                _job!.customerName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _job!.customerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        _job!.customerPhone,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () => _callCustomer(_job!.customerPhone),
                  icon: Icon(Icons.phone, color: Colors.green),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: () => _sendSms(_job!.customerPhone),
                  icon: Icon(Icons.sms, color: Colors.blue),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJobDetails() {
    return _InfoCard(
      title: 'İş Detayları',
      icon: Icons.work,
      children: [
        _InfoRow(
          label: 'Hizmet Tipi',
          value: _job!.washTypeDisplayName,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Eco-friendly etiketi
              if (_job!.washType.isEcoFriendly)
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
              if (_job!.washType.isPremium) ...[
                if (_job!.washType.isEcoFriendly) const SizedBox(width: 4),
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
        _InfoRow(
          label: 'Araç Tipi',
          value: _job!.vehicleTypeDisplayName,
        ),
        _InfoRow(
          label: 'Araç Modeli',
          value: _job!.vehicleModel,
        ),
        _InfoRow(
          label: 'Renk',
          value: _job!.vehicleColor,
        ),
        _InfoRow(
          label: 'Plaka',
          value: _job!.vehiclePlate,
        ),
        if (_job!.isEcoFriendly)
          _InfoRow(
            label: 'Özel',
            value: 'Çevre Dostu Yıkama',
            valueColor: AppTheme.greenPrimary,
            trailing: Icon(Icons.eco, color: AppTheme.greenPrimary, size: 16),
          ),
        _InfoRow(
          label: 'Planlanan Tarih',
          value: '${_job!.scheduledDate.day}/${_job!.scheduledDate.month}/${_job!.scheduledDate.year}',
        ),
        _InfoRow(
          label: 'Planlanan Saat',
          value: '${_job!.scheduledDate.hour.toString().padLeft(2, '0')}:${_job!.scheduledDate.minute.toString().padLeft(2, '0')}',
        ),
        if (_job!.notes?.isNotEmpty == true)
          _InfoRow(
            label: 'Notlar',
            value: _job!.notes!,
            multiline: true,
          ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return _InfoCard(
      title: 'Konum Bilgileri',
      icon: Icons.location_on,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: _openInMaps,
            icon: const Icon(Icons.directions),
            label: const Text('Navigasyon'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      children: [
        _InfoRow(
          label: 'Adres',
          value: _job!.address,
          multiline: true,
        ),
        if (_job!.location['lat'] != null && _job!.location['lng'] != null)
          _InfoRow(
            label: 'Koordinatlar',
            value: '${_job!.location['lat']!.toStringAsFixed(6)}, ${_job!.location['lng']!.toStringAsFixed(6)}',
          ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return _InfoCard(
      title: 'Fotoğraflar',
      icon: Icons.photo_camera,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Öncesi',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (_job!.beforePhotoUrl == null)
                        TextButton(
                          onPressed: () => _takePhoto(isAfter: false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Ekle',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _job!.beforePhotoUrl != null 
                        ? () => _showPhoto(_job!.beforePhotoUrl!)
                        : () => _takePhoto(isAfter: false),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.grey200,
                        borderRadius: BorderRadius.circular(8),
                        border: _beforePhotoUrl != null || _job!.beforePhotoUrl != null
                            ? null
                            : Border.all(
                                color: AppTheme.primaryColor,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                      ),
                      child: _job!.beforePhotoUrl != null || _beforePhotoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _beforePhotoUrl ?? _job!.beforePhotoUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.error),
                                  );
                                },
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  color: AppTheme.primaryColor,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Fotoğraf çek',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Sonrası',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (_job!.afterPhotoUrl == null && _job!.status == BookingStatus.inProgress)
                        TextButton(
                          onPressed: () => _takePhoto(isAfter: true),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Ekle',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _job!.afterPhotoUrl != null 
                        ? () => _showPhoto(_job!.afterPhotoUrl!)
                        : _job!.status == BookingStatus.inProgress
                            ? () => _takePhoto(isAfter: true)
                            : null,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.grey200,
                        borderRadius: BorderRadius.circular(8),
                        border: _afterPhotoUrl != null || _job!.afterPhotoUrl != null
                            ? null
                            : _job!.status == BookingStatus.inProgress
                                ? Border.all(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                    style: BorderStyle.solid,
                                  )
                                : null,
                      ),
                      child: _job!.afterPhotoUrl != null || _afterPhotoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _afterPhotoUrl ?? _job!.afterPhotoUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.error),
                                  );
                                },
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _job!.status == BookingStatus.inProgress
                                      ? Icons.add_a_photo
                                      : Icons.photo,
                                  color: _job!.status == BookingStatus.inProgress
                                      ? AppTheme.primaryColor
                                      : Colors.grey,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _job!.status == BookingStatus.inProgress
                                      ? 'Fotoğraf çek'
                                      : 'Henüz yok',
                                  style: TextStyle(
                                    color: _job!.status == BookingStatus.inProgress
                                        ? AppTheme.primaryColor
                                        : Colors.grey,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeTracker() {
    return _InfoCard(
      title: 'Zaman Takibi',
      icon: Icons.timer,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Başlama Saati',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _job!.startedAt != null
                            ? '${_job!.startedAt!.hour.toString().padLeft(2, '0')}:${_job!.startedAt!.minute.toString().padLeft(2, '0')}'
                            : 'Henüz başlamadı',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue, size: 32),
                      Text(
                        _getElapsedTime(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Tahmini Bitiş',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _getEstimatedEndTime(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _buildActionButtons() {
    if (_job == null) return null;

    final List<Widget> actions = [];

    switch (_job!.status) {
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
              onPressed: _startJob,
              icon: const Icon(Icons.play_arrow),
              label: const Text('İşe Başla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ]);
        break;

      case BookingStatus.inProgress:
        actions.add(
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _beforePhotoUrl != null || _job!.beforePhotoUrl != null
                  ? _completeJob
                  : null,
              icon: const Icon(Icons.check_circle),
              label: const Text('İşi Tamamla'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ),
        );
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

  String _getElapsedTime() {
    if (_job!.startedAt == null) return '00:00';
    
    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _job!.startedAt!.hour,
      _job!.startedAt!.minute,
    );
    
    final elapsed = now.difference(startDateTime);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _getEstimatedEndTime() {
    if (_job!.startedAt == null) return '--:--';
    
    final estimatedDuration = _getEstimatedDuration();
    final startDateTime = DateTime.now().copyWith(
      hour: _job!.startedAt!.hour,
      minute: _job!.startedAt!.minute,
    );
    
    final endTime = startDateTime.add(Duration(minutes: estimatedDuration));
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  int _getEstimatedDuration() {
    switch (_job!.washType) {
      case WashType.dryClean:
        return 20;
      case WashType.greenShine:
        return 30;
      case WashType.greenCabin:
        return 40;
      case WashType.greenPlus:
        return 60;
      case WashType.greenDeluxe:
        return 90;
      case WashType.greenDeluxeMonthly:
        return 90;
    }
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

  void _callCustomer(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _sendSms(String phoneNumber) async {
    final url = 'sms:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openInMaps() async {
    final lat = _job!.location['lat'] ?? 0.0;
    final lng = _job!.location['lng'] ?? 0.0;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _takePhoto({required bool isAfter}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isAfter ? "Sonrası" : "Öncesi"} Fotoğrafı',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImageFromCamera(isAfter: isAfter);
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImageFromGallery(isAfter: isAfter);
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickImageFromCamera({required bool isAfter}) {
    // Mock fotoğraf URL'i
    final mockPhotoUrl = 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
    
    setState(() {
      if (isAfter) {
        _afterPhotoUrl = mockPhotoUrl;
      } else {
        _beforePhotoUrl = mockPhotoUrl;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${isAfter ? "Sonrası" : "Öncesi"} fotoğrafı çekildi')),
    );
  }

  void _pickImageFromGallery({required bool isAfter}) {
    // Mock fotoğraf URL'i
    final mockPhotoUrl = 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
    
    setState(() {
      if (isAfter) {
        _afterPhotoUrl = mockPhotoUrl;
      } else {
        _beforePhotoUrl = mockPhotoUrl;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${isAfter ? "Sonrası" : "Öncesi"} fotoğrafı seçildi')),
    );
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

  Future<void> _startJob() async {
    final washerProvider = context.read<WasherProvider>();
    final success = await washerProvider.startJob(_job!.id);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İş başlatıldı!')),
      );
      _loadJobDetails();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(washerProvider.error ?? 'İş başlatılamadı'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeJob() async {
    if (_beforePhotoUrl == null && _job!.beforePhotoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce öncesi fotoğrafını çekin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final washerProvider = context.read<WasherProvider>();
    final success = await washerProvider.completeJob(
      _job!.id,
      _beforePhotoUrl ?? _job!.beforePhotoUrl,
      _afterPhotoUrl ?? _job!.afterPhotoUrl,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İş tamamlandı!')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(washerProvider.error ?? 'İş tamamlanamadı'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşi İptal Et'),
        content: const Text(
          'Bu işi iptal etmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final washerProvider = context.read<WasherProvider>();
              final success = await washerProvider.cancelJob(
                _job!.id,
                'Yıkamacı tarafından iptal edildi',
              );
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('İş iptal edildi')),
                );
                context.pop();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(washerProvider.error ?? 'İş iptal edilemedi'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );
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
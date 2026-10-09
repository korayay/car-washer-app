import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/washer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import 'washer_analysis_screen.dart';

class WasherDashboardScreen extends StatefulWidget {
  const WasherDashboardScreen({super.key});

  @override
  State<WasherDashboardScreen> createState() => _WasherDashboardScreenState();
}

class _WasherDashboardScreenState extends State<WasherDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;
      if (currentUser != null) {
        context.read<WasherProvider>().loadNearbyJobs();
        context.read<WasherProvider>().loadWasherJobs();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gleam İş Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Bildirimler
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.go(AppRoutes.profile);
                  break;
                case 'settings':
                  context.go(AppRoutes.settings);
                  break;
                case 'analysis':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WasherAnalysisScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Ayarlar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'analysis',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('Analizler'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Yakındaki İşler'),
            Tab(text: 'Aktif İşler'),
            Tab(text: 'Geçmiş'),
          ],
        ),
      ),
      body: Consumer2<WasherProvider, AuthProvider>(
        builder: (context, washerProvider, authProvider, child) {
          final user = authProvider.currentUser;
          
          return Column(
            children: [
              _buildStatusHeader(user, washerProvider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNearbyJobsTab(washerProvider),
                    _buildActiveJobsTab(washerProvider),
                    _buildHistoryTab(washerProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleAvailability,
        backgroundColor: _isAvailable ? Colors.green : Colors.red,
        icon: Icon(_isAvailable ? Icons.pause : Icons.play_arrow),
        label: Text(_isAvailable ? 'Çalışıyor' : 'Durduruldu'),
      ),
    );
  }

  Widget _buildStatusHeader(UserModel? user, WasherProvider washerProvider) {
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _isAvailable ? Colors.green : Colors.red,
            (_isAvailable ? Colors.green : Colors.red).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
        child: Text(
                  user.firstName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: _isAvailable ? Colors.green : Colors.red,
                    fontSize: 24,
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
                      user.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isAvailable ? 'Aktif - Müsait' : 'Pasif - Durduruldu',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${(user.rating ?? 0.0).toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (user.rating ?? 0.0).round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.white,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatusCard(
                  title: 'Bugünkü İşler',
                  value: '${washerProvider.todayJobs}',
                  icon: Icons.today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusCard(
                  title: 'Bu Ay Kazanç',
                  value: '${washerProvider.monthlyEarnings.toStringAsFixed(0)}₺',
                  icon: Icons.attach_money,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatusCard(
                  title: 'Toplam İş',
                  value: '${user.totalJobs ?? 0}',
                  icon: Icons.work,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyJobsTab(WasherProvider washerProvider) {
    if (washerProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final nearbyJobs = washerProvider.nearbyJobs;
    
    if (nearbyJobs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.location_searching,
        title: 'Yakında İş Yok',
        subtitle: 'Şu anda bölgenizde müsait iş bulunmuyor.\nBirazdan tekrar kontrol edin.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await washerProvider.loadNearbyJobs();
        // Debug için ekstra log
        print('Debug: Nearby jobs yüklendi, sayı: ${washerProvider.nearbyJobs.length}');
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: nearbyJobs.length,
        itemBuilder: (context, index) {
          final job = nearbyJobs[index];
          return _JobCard(
            booking: job,
            onAccept: () => _acceptJob(job),
            onViewDetails: () => _viewJobDetails(job),
            isNearby: true,
          );
        },
      ),
    );
  }

  Widget _buildActiveJobsTab(WasherProvider washerProvider) {
    if (washerProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeJobs = washerProvider.activeJobs;
    
    if (activeJobs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.work_outline,
        title: 'Aktif İş Yok',
        subtitle: 'Şu anda aktif işiniz bulunmuyor.\nYakındaki işlerden kabul edebilirsiniz.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => washerProvider.loadWasherJobs(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeJobs.length,
        itemBuilder: (context, index) {
          final job = activeJobs[index];
          return _JobCard(
            booking: job,
            onViewDetails: () => _viewJobDetails(job),
            onUpdateStatus: () => _updateJobStatus(job),
            isActive: true,
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab(WasherProvider washerProvider) {
    if (washerProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final completedJobs = washerProvider.completedJobs;
    
    if (completedJobs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'Geçmiş İş Yok',
        subtitle: 'Henüz tamamlanmış işiniz bulunmuyor.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => washerProvider.loadWasherJobs(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: completedJobs.length,
        itemBuilder: (context, index) {
          final job = completedJobs[index];
          return _JobCard(
            booking: job,
            onViewDetails: () => _viewJobDetails(job),
            isHistory: true,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAvailability() {
    setState(() {
      _isAvailable = !_isAvailable;
    });
    
    final washerProvider = context.read<WasherProvider>();
    washerProvider.updateAvailability(_isAvailable);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isAvailable 
              ? 'Artık yeni işler alabilirsiniz' 
              : 'İş alma durduruldu',
        ),
        backgroundColor: _isAvailable ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _acceptJob(BookingModel job) async {
    final washerProvider = context.read<WasherProvider>();
    final success = await washerProvider.acceptJob(job.id);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İş kabul edildi!')),
      );
      _tabController.animateTo(1); // Aktif İşler sekmesine geç
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(washerProvider.error ?? 'İş kabul edilemedi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewJobDetails(BookingModel job) {
    context.go('${AppRoutes.washerJobDetails}/${job.id}');
  }

  void _updateJobStatus(BookingModel job) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'İş Durumu Güncelle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            if (job.status == BookingStatus.accepted)
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.blue),
                title: const Text('İşe Başla'),
                subtitle: const Text('Yıkama işlemini başlat'),
                onTap: () {
                  Navigator.pop(context);
                  _startJob(job);
                },
              ),
            
            if (job.status == BookingStatus.inProgress)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('İşi Tamamla'),
                subtitle: const Text('Yıkama işlemini tamamla'),
                onTap: () {
                  Navigator.pop(context);
                  _completeJob(job);
                },
              ),
            
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('İşi İptal Et'),
              subtitle: const Text('Bu işten vazgeç'),
              onTap: () {
                Navigator.pop(context);
                _cancelJob(job);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startJob(BookingModel job) async {
    final washerProvider = context.read<WasherProvider>();
    final success = await washerProvider.startJob(job.id);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İş başlatıldı!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(washerProvider.error ?? 'İş başlatılamadı'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeJob(BookingModel job) async {
    final washerProvider = context.read<WasherProvider>();
    
    // TODO: Fotoğraf yükleme ekranına yönlendir
    final success = await washerProvider.completeJob(job.id, null, null);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İş tamamlandı!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(washerProvider.error ?? 'İş tamamlanamadı'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelJob(BookingModel job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşi İptal Et'),
        content: const Text('Bu işi iptal etmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hayır'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Evet'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final washerProvider = context.read<WasherProvider>();
      final success = await washerProvider.cancelJob(job.id, 'Yıkamacı tarafından iptal edildi');
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İş iptal edildi')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(washerProvider.error ?? 'İş iptal edilemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onAccept;
  final VoidCallback? onViewDetails;
  final VoidCallback? onUpdateStatus;
  final bool isNearby;
  final bool isActive;
  final bool isHistory;

  const _JobCard({
    required this.booking,
    this.onAccept,
    this.onViewDetails,
    this.onUpdateStatus,
    this.isNearby = false,
    this.isActive = false,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _getStatusColor().withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getServiceIcon(),
                  color: _getStatusColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          booking.washTypeDisplayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Eco-friendly etiketi
                        if (booking.washType.isEcoFriendly)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ECO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // Premium etiketi
                        if (booking.washType.isPremium) ...[
                          if (booking.washType.isEcoFriendly) const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      booking.vehicleTypeDisplayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${booking.price.toStringAsFixed(0)}₺',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.statusDisplayName,
                      style: TextStyle(
                        fontSize: 10,
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                booking.customerName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.directions_car, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${booking.vehicleColor} ${booking.vehicleModel}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  booking.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isNearby) ...[
                const SizedBox(width: 8),
                Text(
                  '2.5 km', // Mock mesafe
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${booking.scheduledDate.day}/${booking.scheduledDate.month} ${booking.scheduledDate.hour.toString().padLeft(2, '0')}:${booking.scheduledDate.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              if (booking.isEcoFriendly) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.greenPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.eco,
                        size: 12,
                        color: AppTheme.greenPrimary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Çevre Dostu',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.greenPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              if (isNearby && onAccept != null) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check),
                    label: const Text('Kabul Et'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              if (isActive && onUpdateStatus != null) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onUpdateStatus,
                    icon: const Icon(Icons.update),
                    label: const Text('Durum Güncelle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Detaylar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (booking.status) {
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

  IconData _getServiceIcon() {
    switch (booking.washType) {
      case WashType.dryClean:
        return Icons.water_drop_outlined;
      case WashType.greenShine:
        return Icons.eco_outlined;
      case WashType.greenCabin:
        return Icons.clean_hands_outlined;
      case WashType.greenPlus:
        return Icons.star_outline;
      case WashType.greenDeluxe:
        return Icons.diamond_outlined;
      case WashType.greenDeluxeMonthly:
        return Icons.subscriptions_outlined;
    }
  }
} 
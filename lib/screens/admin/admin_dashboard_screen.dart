import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/user_model.dart';
import '../../models/booking_model.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock veriler - gerçek uygulamada API'den gelecek
  final List<UserModel> _users = [];
  final List<BookingModel> _bookings = [];
  final List<_Dispute> _disputes = [];
  
  // İstatistikler
  int _totalUsers = 0;
  int _activeWashers = 0;
  int _totalBookings = 0;
  int _pendingBookings = 0;
  int _disputedBookings = 0;
  double _totalRevenue = 0.0;
  double _monthlyRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    // Mock veriler
    setState(() {
      _totalUsers = 1247;
      _activeWashers = 89;
      _totalBookings = 3456;
      _pendingBookings = 23;
      _disputedBookings = 7;
      _totalRevenue = 245780.50;
      _monthlyRevenue = 45230.25;
    });

    // Mock kullanıcılar
    _users.addAll([
      UserModel(
        id: '1',
        firstName: 'Ahmet',
        lastName: 'Yılmaz',
        email: 'ahmet@example.com',
        phoneNumber: '+90 532 123 4567',
        role: UserRole.customer,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        totalBookings: 15,
      ),
      UserModel(
        id: '2',
        firstName: 'Mehmet',
        lastName: 'Öz',
        email: 'mehmet@example.com',
        phoneNumber: '+90 533 987 6543',
        role: UserRole.washer,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
        totalJobs: 127,
        rating: 4.8,
        isAvailable: true,
      ),
    ]);

    // Mock anlaşmazlıklar
    _disputes.addAll([
      _Dispute(
        id: '1',
        bookingId: 'booking_1',
        customerId: '1',
        washerId: '2',
        reason: 'Hizmet kalitesi yetersiz',
        description: 'Araç yeterince temizlenmemiş, su lekeleri kalmış.',
        status: _DisputeStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now(),
      ),
      _Dispute(
        id: '2',
        bookingId: 'booking_2',
        customerId: '3',
        washerId: '4',
        reason: 'Zamanında gelmedi',
        description: 'Yıkamacı belirlenen saate 1 saat geç geldi.',
        status: _DisputeStatus.resolved,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        resolvedAt: DateTime.now().subtract(const Duration(hours: 12)),
        resolution: 'Yıkamacıya uyarı verildi, müşteriye indirim uygulandı.',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
                case 'logout':
                  _showLogoutDialog();
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
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Çıkış', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Genel Bakış'),
            Tab(text: 'Kullanıcılar'),
            Tab(text: 'Rezervasyonlar'),
            Tab(text: 'Anlaşmazlıklar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUsersTab(),
          _buildBookingsTab(),
          _buildDisputesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genel Bakış',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Üst istatistik kartları
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _StatCard(
                title: 'Toplam Kullanıcı',
                value: _totalUsers.toString(),
                icon: Icons.people,
                color: Colors.blue,
                subtitle: '+23 bu ay',
              ),
              _StatCard(
                title: 'Aktif Yıkamacı',
                value: _activeWashers.toString(),
                icon: Icons.local_car_wash,
                color: Colors.green,
                subtitle: '+5 bu hafta',
              ),
              _StatCard(
                title: 'Toplam Rezervasyon',
                value: _totalBookings.toString(),
                icon: Icons.event,
                color: Colors.orange,
                subtitle: '+156 bu ay',
              ),
              _StatCard(
                title: 'Bekleyen İşler',
                value: _pendingBookings.toString(),
                icon: Icons.pending,
                color: Colors.purple,
                subtitle: 'Acil değil',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Gelir kartları
          Row(
            children: [
              Expanded(
                child: _RevenueCard(
                  title: 'Toplam Gelir',
                  amount: _totalRevenue,
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RevenueCard(
                  title: 'Bu Ay',
                  amount: _monthlyRevenue,
                  icon: Icons.trending_up,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Hızlı eylemler
          _QuickActions(
            onUserManagement: () => _tabController.animateTo(1),
            onBookingManagement: () => _tabController.animateTo(2),
            onDisputeResolution: () => _tabController.animateTo(3),
            onSystemSettings: _showSystemSettings,
          ),
          
          const SizedBox(height: 24),
          
          // Son aktiviteler
          _RecentActivity(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Kullanıcı ara...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // Arama fonksiyonu
                  },
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  // Filtreleme
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('Tüm Kullanıcılar'),
                  ),
                  const PopupMenuItem(
                    value: 'customers',
                    child: Text('Müşteriler'),
                  ),
                  const PopupMenuItem(
                    value: 'washers',
                    child: Text('Yıkamacılar'),
                  ),
                  const PopupMenuItem(
                    value: 'verified',
                    child: Text('Doğrulanmış'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return _UserCard(
                user: user,
                onTap: () => _showUserDetails(user),
                onAction: (action) => _handleUserAction(user, action),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rezervasyon ara...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('Tümü'),
                  ),
                  const PopupMenuItem(
                    value: 'pending',
                    child: Text('Bekleyen'),
                  ),
                  const PopupMenuItem(
                    value: 'active',
                    child: Text('Aktif'),
                  ),
                  const PopupMenuItem(
                    value: 'completed',
                    child: Text('Tamamlanan'),
                  ),
                  const PopupMenuItem(
                    value: 'cancelled',
                    child: Text('İptal Edilen'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<BookingProvider>(
            builder: (context, bookingProvider, child) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 10, // Mock veri
                itemBuilder: (context, index) {
                  return _BookingCard(
                    booking: _createMockBooking(index),
                    onTap: (booking) => _showBookingDetails(booking),
                    onAction: (booking, action) => _handleBookingAction(booking, action),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDisputesTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<_DisputeStatus>(
                  decoration: const InputDecoration(
                    labelText: 'Durum Filtresi',
                    border: OutlineInputBorder(),
                  ),
                  items: _DisputeStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getDisputeStatusText(status)),
                    );
                  }).toList(),
                  onChanged: (status) {
                    // Filtreleme
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _exportDisputes,
                icon: const Icon(Icons.download),
                label: const Text('Dışa Aktar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _disputes.length,
            itemBuilder: (context, index) {
              final dispute = _disputes[index];
              return _DisputeCard(
                dispute: dispute,
                onTap: () => _showDisputeDetails(dispute),
                onResolve: () => _resolveDispute(dispute),
              );
            },
          ),
        ),
      ],
    );
  }

  BookingModel _createMockBooking(int index) {
    return BookingModel(
      id: 'booking_$index',
      customerId: 'customer_$index',
      customerName: 'Müşteri ${index + 1}',
      customerPhone: '+90 532 ${100 + index} ${200 + index} ${300 + index}',
      status: BookingStatus.values[index % BookingStatus.values.length],
      washType: WashType.values[index % WashType.values.length],
      vehicleType: VehicleType.values[index % VehicleType.values.length],
      vehicleModel: 'Model ${index + 1}',
      vehicleColor: ['Beyaz', 'Siyah', 'Gri', 'Mavi'][index % 4],
      vehiclePlate: '34 ABC ${100 + index}',
      address: 'Adres ${index + 1}, İstanbul',
      location: {'lat': 41.0082 + index * 0.001, 'lng': 28.9784 + index * 0.001},
      scheduledDate: DateTime.now().add(Duration(days: index)),
      createdAt: DateTime.now().subtract(Duration(hours: index)),
      updatedAt: DateTime.now().subtract(Duration(hours: index)),
      price: 50.0 + (index * 25),
      isEcoFriendly: index % 3 == 0,
    );
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(user.firstName.substring(0, 1)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getRoleDisplayName(user.role),
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _DetailRow('E-posta', user.email),
              _DetailRow('Telefon', user.phoneNumber),
              _DetailRow('Doğrulanmış', user.isVerified ? 'Evet' : 'Hayır'),
              _DetailRow('Kayıt Tarihi', '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
              
              if (user.isCustomer) ...[
                const Divider(),
                _DetailRow('Toplam Rezervasyon', '${user.totalBookings ?? 0}'),
              ],
              
              if (user.isWasher) ...[
                const Divider(),
                _DetailRow('Toplam İş', '${user.totalJobs ?? 0}'),
                _DetailRow('Puan Ortalaması', '${user.rating?.toStringAsFixed(1) ?? 'N/A'}'),
                _DetailRow('Durum', user.isAvailable == true ? 'Müsait' : 'Meşgul'),
              ],
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _suspendUser(user);
                      },
                      child: const Text('Askıya Al'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _sendMessage(user);
                      },
                      child: const Text('Mesaj Gönder'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(BookingModel booking) {
    context.go('${AppRoutes.bookingDetails}/${booking.id}');
  }

  void _showDisputeDetails(_Dispute dispute) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Anlaşmazlık Detayları',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _DetailRow('ID', dispute.id),
              _DetailRow('Rezervasyon', dispute.bookingId),
              _DetailRow('Sebep', dispute.reason),
              _DetailRow('Durum', _getDisputeStatusText(dispute.status)),
              _DetailRow('Tarih', '${dispute.createdAt.day}/${dispute.createdAt.month}/${dispute.createdAt.year}'),
              
              const SizedBox(height: 16),
              
              const Text(
                'Açıklama:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(dispute.description),
              
              if (dispute.resolution != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Çözüm:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(dispute.resolution!),
              ],
              
              const SizedBox(height: 24),
              
              if (dispute.status == _DisputeStatus.pending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _resolveDispute(dispute);
                    },
                    child: const Text('Çöz'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _resolveDispute(_Dispute dispute) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anlaşmazlığı Çöz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Çözüm açıklaması',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                dispute.status = _DisputeStatus.resolved;
                dispute.resolution = controller.text;
                dispute.resolvedAt = DateTime.now();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Anlaşmazlık çözüldü')),
              );
            },
            child: const Text('Çöz'),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(UserModel user, String action) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'suspend':
        _suspendUser(user);
        break;
      case 'message':
        _sendMessage(user);
        break;
    }
  }

  void _handleBookingAction(BookingModel booking, String action) {
    switch (action) {
      case 'view':
        _showBookingDetails(booking);
        break;
      case 'cancel':
        _cancelBooking(booking);
        break;
    }
  }

  void _suspendUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcıyı Askıya Al'),
        content: Text('${user.fullName} kullanıcısını askıya almak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.fullName} askıya alındı')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Askıya Al'),
          ),
        ],
      ),
    );
  }

  void _sendMessage(UserModel user) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.fullName}\'a Mesaj Gönder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Mesaj',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mesaj gönderildi')),
              );
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rezervasyonu İptal Et'),
        content: const Text('Bu rezervasyonu iptal etmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hayır'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rezervasyon iptal edildi')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );
  }

  void _showSystemSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sistem ayarları yakında')),
    );
  }

  void _exportDisputes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anlaşmazlıklar dışa aktarılıyor...')),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Admin panelinden çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
              if (mounted) {
                context.go(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Müşteri';
      case UserRole.washer:
        return 'Yıkamacı';
      case UserRole.admin:
        return 'Yönetici';
    }
  }

  String _getDisputeStatusText(_DisputeStatus status) {
    switch (status) {
      case _DisputeStatus.pending:
        return 'Bekliyor';
      case _DisputeStatus.investigating:
        return 'İnceleniyor';
      case _DisputeStatus.resolved:
        return 'Çözüldü';
      case _DisputeStatus.rejected:
        return 'Reddedildi';
    }
  }
}

// Widget sınıfları ve yardımcı sınıflar...
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _RevenueCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${amount.toStringAsFixed(2)}₺',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onUserManagement;
  final VoidCallback onBookingManagement;
  final VoidCallback onDisputeResolution;
  final VoidCallback onSystemSettings;

  const _QuickActions({
    required this.onUserManagement,
    required this.onBookingManagement,
    required this.onDisputeResolution,
    required this.onSystemSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hızlı Eylemler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _ActionButton(
                title: 'Kullanıcı Yönetimi',
                icon: Icons.people,
                color: Colors.blue,
                onTap: onUserManagement,
              ),
              _ActionButton(
                title: 'Rezervasyon Yönetimi',
                icon: Icons.event,
                color: Colors.green,
                onTap: onBookingManagement,
              ),
              _ActionButton(
                title: 'Anlaşmazlık Çözümü',
                icon: Icons.gavel,
                color: Colors.orange,
                onTap: onDisputeResolution,
              ),
              _ActionButton(
                title: 'Sistem Ayarları',
                icon: Icons.settings,
                color: Colors.purple,
                onTap: onSystemSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
        child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Son Aktiviteler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(_getActivityIcon(index)),
                ),
                title: Text(_getActivityTitle(index)),
                subtitle: Text(_getActivitySubtitle(index)),
                trailing: Text(_getActivityTime(index)),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(int index) {
    final icons = [
      Icons.person_add,
      Icons.event,
      Icons.gavel,
      Icons.star,
      Icons.warning,
    ];
    return icons[index % icons.length];
  }

  String _getActivityTitle(int index) {
    final titles = [
      'Yeni kullanıcı kaydı',
      'Rezervasyon oluşturuldu',
      'Anlaşmazlık çözüldü',
      'Yeni değerlendirme',
      'Sistem uyarısı',
    ];
    return titles[index % titles.length];
  }

  String _getActivitySubtitle(int index) {
    final subtitles = [
      'Ahmet Yılmaz sisteme katıldı',
      'Premium yıkama rezervasyonu',
      'Müşteri şikayeti giderildi',
      '5 yıldız puan verildi',
      'Sunucu yoğunluğu tespit edildi',
    ];
    return subtitles[index % subtitles.length];
  }

  String _getActivityTime(int index) {
    final times = [
      '2 dk önce',
      '15 dk önce',
      '1 saat önce',
      '3 saat önce',
      '5 saat önce',
    ];
    return times[index % times.length];
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final Function(String) onAction;

  const _UserCard({
    required this.user,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.firstName.substring(0, 1)),
        ),
        title: Text(user.fullName),
        subtitle: Text('${user.email} • ${_getRoleText(user.role)}'),
        trailing: PopupMenuButton<String>(
          onSelected: onAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('Detayları Gör'),
            ),
            const PopupMenuItem(
              value: 'message',
              child: Text('Mesaj Gönder'),
            ),
            const PopupMenuItem(
              value: 'suspend',
              child: Text('Askıya Al'),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Müşteri';
      case UserRole.washer:
        return 'Yıkamacı';
      case UserRole.admin:
        return 'Yönetici';
    }
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final Function(BookingModel) onTap;
  final Function(BookingModel, String) onAction;

  const _BookingCard({
    required this.booking,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('${booking.customerName} - ${booking.washTypeDisplayName}'),
        subtitle: Text('${booking.vehicleModel} • ${booking.price.toStringAsFixed(0)}₺'),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => onAction(booking, action),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('Detayları Gör'),
            ),
            if (booking.status != BookingStatus.completed && 
                booking.status != BookingStatus.cancelled)
              const PopupMenuItem(
                value: 'cancel',
                child: Text('İptal Et'),
              ),
          ],
        ),
        onTap: () => onTap(booking),
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final _Dispute dispute;
  final VoidCallback onTap;
  final VoidCallback onResolve;

  const _DisputeCard({
    required this.dispute,
    required this.onTap,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(dispute.reason),
        subtitle: Text('${dispute.bookingId} • ${_getStatusText(dispute.status)}'),
        trailing: dispute.status == _DisputeStatus.pending
            ? ElevatedButton(
                onPressed: onResolve,
                child: const Text('Çöz'),
              )
            : Icon(_getStatusIcon(dispute.status)),
        onTap: onTap,
      ),
    );
  }

  String _getStatusText(_DisputeStatus status) {
    switch (status) {
      case _DisputeStatus.pending:
        return 'Bekliyor';
      case _DisputeStatus.investigating:
        return 'İnceleniyor';
      case _DisputeStatus.resolved:
        return 'Çözüldü';
      case _DisputeStatus.rejected:
        return 'Reddedildi';
    }
  }

  IconData _getStatusIcon(_DisputeStatus status) {
    switch (status) {
      case _DisputeStatus.pending:
        return Icons.pending;
      case _DisputeStatus.investigating:
        return Icons.search;
      case _DisputeStatus.resolved:
        return Icons.check_circle;
      case _DisputeStatus.rejected:
        return Icons.cancel;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// Yardımcı sınıflar
class _Dispute {
  final String id;
  final String bookingId;
  final String customerId;
  final String washerId;
  final String reason;
  final String description;
  _DisputeStatus status;
  final DateTime createdAt;
  DateTime? resolvedAt;
  String? resolution;
  DateTime? updatedAt;

  _Dispute({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.washerId,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.resolution,
    this.updatedAt,
  });
}

enum _DisputeStatus {
  pending,
  investigating,
  resolved,
  rejected,
} 
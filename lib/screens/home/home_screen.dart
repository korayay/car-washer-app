import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/washer_provider.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _refreshTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Her 10 saniyede bir booking listesini güncelle
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        print('HomeScreen: Otomatik booking refresh - ${DateTime.now()}');
        _refreshBookings();
      }
    });
  }

  Future<void> _refreshBookings() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user != null) {
      if (user.isCustomer) {
        await context.read<BookingProvider>().loadBookings(user.id);
      } else if (user.isWasher) {
        await context.read<WasherProvider>().loadWasherJobs();
      }
    }
  }

  Future<void> _initializeData() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser != null) {
      // User role kontrolü yap ve doğru sayfaya yönlendir
      if (currentUser.isWasher) {
        context.go(AppRoutes.washerDashboard);
        return;
      } else if (currentUser.isAdmin) {
        context.go(AppRoutes.adminDashboard);
        return;
      }
      
      // Customer ise normal booking verilerini yükle
      await context.read<BookingProvider>().loadBookings(currentUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF00BCD4), // Cyan
                    Color(0xFF00E676), // Green
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00BCD4).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Gleam',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Bildirimler sayfası
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          _BookingsTab(),
          _ServicesTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Rezervasyonlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_car_wash_outlined),
            activeIcon: Icon(Icons.local_car_wash),
            label: 'Hizmetler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _goToBookingWithType(BuildContext context, WashType washType) {
    // TODO: Booking screen'e wash type ile git
    context.go(AppRoutes.booking);
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, BookingProvider>(
      builder: (context, authProvider, bookingProvider, child) {
        final user = authProvider.currentUser;
        final recentBookings = bookingProvider.recentBookings.take(3).toList();

        return RefreshIndicator(
          onRefresh: () async {
            if (user != null) {
              await bookingProvider.loadBookings(user.id);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hoş geldin mesajı
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Merhaba ${user?.firstName ?? 'Kullanıcı'}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Arabanızı temizlemek için hazır mısınız?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go(AppRoutes.booking),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Hemen Rezervasyon Yap',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Hızlı erişim hizmetleri
                Text(
                  'Hizmetlerimiz',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Hizmet seçenekleri - 6 adet
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 48) / 2,
                      child: _ServiceCard(
                        washType: WashType.dryClean,
                        title: 'Dry Clean',
                        subtitle: '150₺ - Hızlı',
                        icon: Icons.water_drop_outlined,
                        color: Colors.lightBlue,
                        onTap: () => _goToBookingWithType(context, WashType.dryClean),
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 48) / 2,
                      child: _ServiceCard(
                        washType: WashType.greenShine,
                        title: 'Green Shine',
                        subtitle: '200₺ - Dış yıkama',
                        icon: Icons.eco_outlined,
                        color: Colors.green,
                        onTap: () => _goToBookingWithType(context, WashType.greenShine),
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 48) / 2,
                      child: _ServiceCard(
                        washType: WashType.greenCabin,
                        title: 'Green Cabin',
                        subtitle: '240₺ - İç temizlik',
                        icon: Icons.clean_hands_outlined,
                        color: Colors.teal,
                        onTap: () => _goToBookingWithType(context, WashType.greenCabin),
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 48) / 2,
                      child: _ServiceCard(
                        washType: WashType.greenPlus,
                        title: 'Green Plus',
                        subtitle: '360₺ - Komple',
                        icon: Icons.star_outline,
                        color: Colors.orange,
                        onTap: () => _goToBookingWithType(context, WashType.greenPlus),
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 48) / 2,
                      child: _ServiceCard(
                        washType: WashType.greenDeluxe,
                        title: 'Green Deluxe',
                        subtitle: '460₺ - Premium',
                        icon: Icons.diamond_outlined,
                        color: Colors.purple,
                        onTap: () => _goToBookingWithType(context, WashType.greenDeluxe),
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 48) / 2,
                      child: _ServiceCard(
                        washType: WashType.greenDeluxeMonthly,
                        title: 'Clean Club',
                        subtitle: '800₺/ay - Üyelik',
                        icon: Icons.subscriptions_outlined,
                        color: Colors.deepPurple,
                        onTap: () => _goToBookingWithType(context, WashType.greenDeluxeMonthly),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Hava durumu bilgisi
                _buildWeatherSection(),

                const SizedBox(height: 24),

                // Neden bizi seçmelisiniz?
                Text(
                  'Neden Biz?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _WhyChooseUsCard(
                  icon: Icons.flash_on,
                  title: 'Kapınızda Hızlı Hizmet',
                  subtitle: 'Sadece 20 dakikada parıl parıl temizlik',
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _WhyChooseUsCard(
                  icon: Icons.eco,
                  title: 'Çevre Dostu Teknoloji',
                  subtitle: 'Su tasarrufu ve organik ürünlerle temizlik',
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _WhyChooseUsCard(
                  icon: Icons.star_rate,
                  title: 'Uzman Ekibimiz',
                  subtitle: 'Deneyimli profesyonellerden kaliteli hizmet',
                  color: Colors.purple,
                ),
                const SizedBox(height: 12),
                _WhyChooseUsCard(
                  icon: Icons.phone_android,
                  title: 'Anında Rezervasyon',
                  subtitle: 'Tek dokunuşla istediğin zamana randevu al',
                  color: Colors.teal,
                ),

                const SizedBox(height: 24),

                // Son rezervasyonlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Son Rezervasyonlar',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Tüm rezervasyonlar sayfasına git
                      },
                      child: const Text('Tümünü Gör'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (recentBookings.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.grey100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_car_wash_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz rezervasyonunuz yok',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'İlk rezervasyonunuzu yapmak için yukarıdaki butonu kullanın',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...recentBookings.map((booking) => GestureDetector(
                    onTap: () => context.go('/booking/details/${booking.id}'),
                    child: _BookingCard(booking: booking),
                  )),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToBookingWithType(BuildContext context, WashType washType) {
    // TODO: Booking screen'e wash type ile git
    context.go(AppRoutes.booking);
  }

  Widget _buildWeatherSection() {
    return FutureBuilder<WeatherData>(
      future: WeatherService().getCurrentWeather(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.cyan.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final weather = snapshot.data!;
        final isGoodTime = WeatherService().isGoodTimeForWash(weather);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isGoodTime 
                ? [Colors.green.shade50, Colors.blue.shade50]
                : [Colors.orange.shade50, Colors.red.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isGoodTime 
                ? Colors.green.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      weather.condition.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.thermostat,
                              color: AppTheme.primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${weather.temperature.round()}°C',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.water_drop,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '%${weather.humidity.round()}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weather.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isGoodTime 
                        ? Icons.check_circle 
                        : Icons.warning_amber_rounded,
                      color: isGoodTime 
                        ? Colors.green 
                        : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        WeatherService().getCarWashRecommendation(weather),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isGoodTime 
                            ? Colors.green.shade800 
                            : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, BookingProvider>(
      builder: (context, authProvider, bookingProvider, child) {
        final user = authProvider.currentUser;
        
        return RefreshIndicator(
          onRefresh: () async {
            if (user != null) {
              await bookingProvider.loadBookings(user.id);
            }
          },
          child: bookingProvider.userBookings.isEmpty
              ? const Center(
                  child: Text('Rezervasyonunuz bulunmuyor'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookingProvider.userBookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookingProvider.userBookings[index];
                    return GestureDetector(
                      onTap: () => context.go('/booking/details/${booking.id}'),
                      child: _BookingCard(booking: booking),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hizmet Paketlerimiz',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _ServiceDetailCard(
                  washType: WashType.dryClean,
                  title: 'Dry Clean',
                  price: '150₺',
                  duration: '20 dakika',
                  features: [
                    'Hızlı susuz temizlik',
                    'Özel kimyasal formül',
                    'Su tasarrufu sağlar',
                    'Pratik ve etkili',
                  ],
                  color: Colors.lightBlue,
                ),
                _ServiceDetailCard(
                  washType: WashType.greenShine,
                  title: 'Green Shine',
                  price: '200₺',
                  duration: '30 dakika',
                  features: [
                    'Sadece dış temizlik',
                    'Parlatma işlemi',
                    'Jant temizliği',
                    'Cam temizliği',
                  ],
                  color: Colors.green,
                ),
                _ServiceDetailCard(
                  washType: WashType.greenCabin,
                  title: 'Green Cabin',
                  price: '240₺',
                  duration: '40 dakika',
                  features: [
                    'Sadece iç temizlik',
                    'Detaylı vakumlama',
                    'Koltuk temizliği',
                    'Gösterge paneli temizliği',
                  ],
                  color: Colors.teal,
                ),
                _ServiceDetailCard(
                  washType: WashType.greenPlus,
                  title: 'Green Plus',
                  price: '360₺',
                  duration: '60 dakika',
                  features: [
                    'İç + dış detaylı temizlik',
                    'Motor bölümü temizliği',
                    'Bagaj temizliği',
                    'Detaylı cam temizliği',
                  ],
                  color: Colors.orange,
                ),
                _ServiceDetailCard(
                  washType: WashType.greenDeluxe,
                  title: 'Green Deluxe',
                  price: '460₺',
                  duration: '90 dakika',
                  features: [
                    'Komple temizlik',
                    'Cilalama işlemi',
                    'Premium ürünler',
                    'Koltuk şampuanlama',
                  ],
                  color: Colors.purple,
                ),
                _ServiceDetailCard(
                  washType: WashType.greenDeluxeMonthly,
                  title: 'Clean Club',
                  price: '800₺/ay',
                  duration: '90 dakika',
                  features: [
                    'Ayda 4 kez temizlik',
                    'Tüm premium hizmetler',
                    'Özel müşteri takibi',
                    'Öncelikli randevu',
                  ],
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profil kartı
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryColor,
        child: Text(
                        user?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'Kullanıcı',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Menü seçenekleri
              Expanded(
                child: ListView(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: 'Profil Bilgileri',
                      onTap: () => context.go(AppRoutes.profile),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Ayarlar',
                      onTap: () => context.go(AppRoutes.settings),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.help_outline,
                      title: 'Yardım',
                      onTap: () {
                        // Yardım sayfası
                      },
                    ),
                    _ProfileMenuItem(
                      icon: Icons.logout,
                      title: 'Çıkış Yap',
                      onTap: () async {
                        await authProvider.signOut();
                        if (context.mounted) {
                          context.go(AppRoutes.login);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final WashType washType;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.washType,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ),
                // Eco-friendly etiketi
                if (washType.isEcoFriendly)
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
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            // Premium etiketi
            if (washType.isPremium)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
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
              ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.washTypeDisplayName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.statusDisplayName,
                  style: TextStyle(
                    color: _getStatusColor(booking.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.address,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${booking.price.toStringAsFixed(0)}₺',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.primaryColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.go('${AppRoutes.bookingDetails}/${booking.id}');
                },
                child: const Text('Detaylar'),
              ),
            ],
          ),
        ],
      ),
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
}

class _ServiceDetailCard extends StatelessWidget {
  final WashType washType;
  final String title;
  final String price;
  final String duration;
  final List<String> features;
  final Color color;

  const _ServiceDetailCard({
    required this.washType,
    required this.title,
    required this.price,
    required this.duration,
    required this.features,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.local_car_wash, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Eco-friendly etiketi
                        if (washType.isEcoFriendly)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'ECO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // Premium etiketi
                        if (washType.isPremium) ...[
                          if (washType.isEcoFriendly) const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 16,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Süre: $duration',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: color, size: 16),
                const SizedBox(width: 8),
                Text(
                  feature,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Booking screen'e washType ile git
                context.go(AppRoutes.booking);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: const Text('Rezervasyon Yap'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
} 

class _EcoFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _EcoFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WhyChooseUsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _WhyChooseUsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
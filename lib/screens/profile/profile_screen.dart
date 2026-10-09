import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/user_model.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

// Achievement data class
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

// Achievement definitions
const Map<String, Achievement> achievements = {
  'first_user': Achievement(
    id: 'first_user',
    name: 'İlk Kullanıcı',
    description: 'Gleam\'e hoş geldin! İlk rezervasyonunu yaptın.',
    icon: Icons.celebration,
    color: Colors.purple,
  ),
  'eco_friendly': Achievement(
    id: 'eco_friendly',
    name: 'Çevre Dostu',
    description: '5 adet çevre dostu yıkama tamamladın.',
    icon: Icons.eco,
    color: Colors.green,
  ),
  'vip_customer': Achievement(
    id: 'vip_customer',
    name: 'VIP Müşteri',
    description: '10 adet yıkama tamamladın.',
    icon: Icons.diamond,
    color: Colors.amber,
  ),
  'loyal_customer': Achievement(
    id: 'loyal_customer',
    name: 'Sadık Müşteri',
    description: 'Bir ayda 4\'ten fazla yıkama yaptırdın.',
    icon: Icons.favorite,
    color: Colors.red,
  ),
};

extension AchievementExtension on String {
  Achievement? get achievement => achievements[this];
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final authProvider = context.read<AuthProvider>();
            final user = authProvider.currentUser;
            
            if (user != null) {
              if (user.isWasher) {
                context.go(AppRoutes.washerDashboard);
              } else if (user.isAdmin) {
                context.go(AppRoutes.adminDashboard);
              } else {
                context.go(AppRoutes.home);
              }
            } else {
              context.go(AppRoutes.login);
            }
          },
        ),
        title: const Text('Profilim'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _cancelEditing,
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: _saveChanges,
                  child: const Text('Kaydet'),
                ),
              ],
            ),
        ],
      ),
      body: Consumer2<AuthProvider, BookingProvider>(
        builder: (context, authProvider, bookingProvider, child) {
          final user = authProvider.currentUser;
          
          // Kullanıcı bilgisi yoksa login sayfasına yönlendir
          if (user == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppRoutes.login);
            });
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 24),
                _buildProfileForm(user),
                const SizedBox(height: 24),
                _buildStatsSection(user, bookingProvider),
                const SizedBox(height: 24),
                if (user.isCustomer) _buildAchievementsSection(user),
                if (user.isCustomer) const SizedBox(height: 24),
                _buildMenuSection(),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: user.profileImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          user.profileImageUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              user.firstName.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        user.firstName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: GestureDetector(
                    onTap: _changeProfileImage,
                    child: Icon(
                      Icons.camera_alt,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getRoleDisplayName(user.role),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (user.isVerified) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'Doğrulanmış Hesap',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          if (user.isCustomer) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${user.points}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Puan',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white30,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco, color: Colors.green.shade300, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${user.totalEcoWashes}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Çevre Dostu',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white30,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.military_tech, color: Colors.orange.shade300, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${user.achievements.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Rozet',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileForm(UserModel user) {
    return Container(
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Kişisel Bilgiler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Ad',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ad gerekli';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Soyad',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Soyad gerekli';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emailController,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'E-posta gerekli';
                }
                if (!value.contains('@')) {
                  return 'Geçerli bir e-posta adresi girin';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _phoneController,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Telefon numarası gerekli';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _addressController,
              enabled: _isEditing,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Adres',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(UserModel user, BookingProvider bookingProvider) {
    return Container(
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
              Icon(Icons.analytics, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'İstatistikler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (user.isCustomer) ...[
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Toplam\nRezervasyon',
                    value: '${user.totalBookings ?? 0}',
                    icon: Icons.local_car_wash,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Aktif\nRezervasyon',
                    value: '${bookingProvider.activeBookings.length}',
                    icon: Icons.pending,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Tamamlanan\nHizmet',
                    value: '${bookingProvider.completedBookings.length}',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Üyelik\nSüresi',
                    value: _getMembershipDuration(user.createdAt),
                    icon: Icons.schedule,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ] else if (user.isWasher) ...[
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Toplam\nİş',
                    value: '${user.totalJobs ?? 0}',
                    icon: Icons.work,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Puan\nOrtalama',
                    value: '${(user.rating ?? 0.0).toStringAsFixed(1)}',
                    icon: Icons.star,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Durum',
                    value: user.isAvailable == true ? 'Müsait' : 'Meşgul',
                    icon: Icons.circle,
                    color: user.isAvailable == true ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Deneyim',
                    value: _getExperienceLevel(user.totalJobs ?? 0),
                    icon: Icons.trending_up,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(UserModel user) {
    return Container(
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
              Icon(Icons.emoji_events, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Rozetler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (user.achievements.isEmpty)
            const Center(
              child: Text(
                'Henüz rozetiniz yok. Yeni rozetler kazanmak için daha fazla hizmet alın.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (user.achievements ?? []).length,
              itemBuilder: (context, index) {
                final achievementId = (user.achievements ?? [])[index];
                final achievement = achievementId.achievement;
                
                if (achievement == null) return const SizedBox.shrink();
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: achievement.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: achievement.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: achievement.color.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          achievement.icon, 
                          color: achievement.color, 
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: achievement.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              achievement.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
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
              Icon(Icons.menu, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Hesap İşlemleri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _MenuTile(
            icon: Icons.settings,
            title: 'Ayarlar',
            subtitle: 'Uygulama ayarları ve tercihler',
            onTap: () => context.go(AppRoutes.settings),
          ),
          
          _MenuTile(
            icon: Icons.security,
            title: 'Güvenlik',
            subtitle: 'Şifre değiştir, güvenlik ayarları',
            onTap: _showSecurityOptions,
          ),
          
          _MenuTile(
            icon: Icons.help,
            title: 'Yardım & Destek',
            subtitle: 'SSS, iletişim, geri bildirim',
            onTap: _showHelpOptions,
          ),
          
          _MenuTile(
            icon: Icons.privacy_tip,
            title: 'Gizlilik',
            subtitle: 'Gizlilik politikası, veri yönetimi',
            onTap: _showPrivacyOptions,
          ),
          
          _MenuTile(
            icon: Icons.logout,
            title: 'Çıkış Yap',
            subtitle: 'Hesabından güvenli çıkış',
            onTap: _showLogoutDialog,
            textColor: Colors.red,
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

  String _getMembershipDuration(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} gün';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} ay';
    } else {
      return '${(difference.inDays / 365).floor()} yıl';
    }
  }

  String _getExperienceLevel(int totalJobs) {
    if (totalJobs < 10) return 'Yeni';
    if (totalJobs < 50) return 'Deneyimli';
    if (totalJobs < 100) return 'Uzman';
    return 'Master';
  }

  void _changeProfileImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profil Fotoğrafı',
              style: TextStyle(
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
                      _pickImageFromCamera();
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
                      _pickImageFromGallery();
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

  void _pickImageFromCamera() {
    // TODO: Kamera ile fotoğraf çekme
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kamera özelliği yakında eklenecek')),
    );
  }

  void _pickImageFromGallery() {
    // TODO: Galeriden fotoğraf seçme
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Galeri özelliği yakında eklenecek')),
    );
  }

  void _cancelEditing() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber;
      _addressController.text = user.address ?? '';
    }
    setState(() => _isEditing = false);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user == null) return;

    final updatedUser = user.copyWith(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text.isNotEmpty ? _addressController.text : null,
    );

    final success = await authProvider.updateProfile(updatedUser);
    
    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil güncellendi')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Güncelleme başarısız'),
        ),
      );
    }
  }

  void _showSecurityOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Güvenlik Ayarları',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Şifre Değiştir'),
              subtitle: const Text('Hesap şifrenizi değiştirin'),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('Biyometrik Giriş'),
              subtitle: const Text('Parmak izi ile giriş ayarları'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Yakında eklenecek')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mevcut Şifre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre (Tekrar)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Şifreler eşleşmiyor')),
                );
                return;
              }
              
              Navigator.pop(context);
              
              final authProvider = context.read<AuthProvider>();
              final success = await authProvider.changePassword(
                currentPasswordController.text,
                newPasswordController.text,
              );
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Şifre başarıyla değiştirildi')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(authProvider.error ?? 'Şifre değiştirilemedi')),
                );
              }
            },
            child: const Text('Değiştir'),
          ),
        ],
      ),
    );
  }

  void _showHelpOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Yardım & Destek',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Sıkça Sorulan Sorular'),
              onTap: () {
                Navigator.pop(context);
                // TODO: SSS sayfasına git
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Bizi Arayın'),
              subtitle: const Text('+90 850 000 0000'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Arama yap
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('E-posta Gönder'),
              subtitle: const Text('destek@gleam.com'),
              onTap: () {
                Navigator.pop(context);
                // TODO: E-posta gönder
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gizlilik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text('Gizlilik Politikası'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Gizlilik politikası sayfasına git
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Hesabı Sil'),
              subtitle: const Text('Hesabınızı kalıcı olarak silin'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteAccountDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Bu işlem geri alınamaz. Tüm verileriniz kalıcı olarak silinecek. Devam etmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final authProvider = context.read<AuthProvider>();
              final success = await authProvider.deleteAccount();
              
              if (success && mounted) {
                context.go(AppRoutes.login);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(authProvider.error ?? 'Hesap silinemedi')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
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
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
} 
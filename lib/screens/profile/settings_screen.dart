import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Ayar değişkenleri
  bool _notificationsEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'tr';
  String _selectedCurrency = 'TRY';
  double _notificationVolume = 0.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationSettings(),
          const SizedBox(height: 16),
          _buildAppearanceSettings(),
          const SizedBox(height: 16),
          _buildPrivacyAndSecurity(),
          const SizedBox(height: 16),
          _buildLanguageAndRegion(),
          const SizedBox(height: 16),
          _buildDataAndStorage(),
          const SizedBox(height: 16),
          _buildSupportAndInfo(),
          const SizedBox(height: 16),
          _buildAccountActions(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _SettingsSection(
      title: 'Bildirimler',
      icon: Icons.notifications,
      children: [
        _SwitchTile(
          title: 'Tüm Bildirimleri Aç',
          subtitle: 'Uygulama bildirimlerini yönet',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
              if (!value) {
                _pushNotifications = false;
                _emailNotifications = false;
                _smsNotifications = false;
              }
            });
          },
        ),
        
        if (_notificationsEnabled) ...[
          _SwitchTile(
            title: 'Push Bildirimleri',
            subtitle: 'Anında bildirimler al',
            value: _pushNotifications,
            onChanged: (value) => setState(() => _pushNotifications = value),
          ),
          
          _SwitchTile(
            title: 'E-posta Bildirimleri',
            subtitle: 'Önemli güncellemeler için e-posta al',
            value: _emailNotifications,
            onChanged: (value) => setState(() => _emailNotifications = value),
          ),
          
          _SwitchTile(
            title: 'SMS Bildirimleri',
            subtitle: 'Kritik durumlar için SMS al',
            value: _smsNotifications,
            onChanged: (value) => setState(() => _smsNotifications = value),
          ),
          
          const Divider(),
          
          _SwitchTile(
            title: 'Ses',
            subtitle: 'Bildirim sesleri',
            value: _soundEnabled,
            onChanged: (value) => setState(() => _soundEnabled = value),
          ),
          
          if (_soundEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bildirim Ses Seviyesi',
                    style: TextStyle(fontSize: 14),
                  ),
                  Slider(
                    value: _notificationVolume,
                    onChanged: (value) => setState(() => _notificationVolume = value),
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          
          _SwitchTile(
            title: 'Titreşim',
            subtitle: 'Bildirim titreşimleri',
            value: _vibrationEnabled,
            onChanged: (value) => setState(() => _vibrationEnabled = value),
          ),
        ],
      ],
    );
  }

  Widget _buildAppearanceSettings() {
    return _SettingsSection(
      title: 'Görünüm',
      icon: Icons.palette,
      children: [
        _SwitchTile(
          title: 'Koyu Tema',
          subtitle: 'Karanlık modu etkinleştir',
          value: _darkModeEnabled,
          onChanged: (value) => setState(() => _darkModeEnabled = value),
        ),
        
        _ListTile(
          title: 'Tema Rengi',
          subtitle: 'Uygulama ana rengini seç',
          icon: Icons.color_lens,
          onTap: _showColorPicker,
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
        ),
        
        _ListTile(
          title: 'Font Boyutu',
          subtitle: 'Metin boyutunu ayarla',
          icon: Icons.text_fields,
          onTap: _showFontSizeSelector,
          trailing: const Text(
            'Orta',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyAndSecurity() {
    return _SettingsSection(
      title: 'Gizlilik ve Güvenlik',
      icon: Icons.security,
      children: [
        _SwitchTile(
          title: 'Konum Hizmetleri',
          subtitle: 'Yakın yıkamacıları bulmak için konum kullan',
          value: _locationEnabled,
          onChanged: (value) => setState(() => _locationEnabled = value),
        ),
        
        _SwitchTile(
          title: 'Biyometrik Kimlik Doğrulama',
          subtitle: 'Parmak izi veya yüz tanıma ile giriş',
          value: _biometricEnabled,
          onChanged: (value) => setState(() => _biometricEnabled = value),
        ),
        
        _ListTile(
          title: 'Şifre Değiştir',
          subtitle: 'Hesap şifrenizi güncelleyin',
          icon: Icons.lock,
          onTap: _showChangePasswordDialog,
        ),
        
        _ListTile(
          title: 'İki Faktörlü Kimlik Doğrulama',
          subtitle: 'Hesap güvenliğini artırın',
          icon: Icons.security,
          onTap: _show2FASettings,
        ),
        
        _ListTile(
          title: 'Gizlilik Ayarları',
          subtitle: 'Veri paylaşımı ve gizlilik kontrolü',
          icon: Icons.privacy_tip,
          onTap: _showPrivacySettings,
        ),
        
        _ListTile(
          title: 'Oturum Geçmişi',
          subtitle: 'Aktif oturumları görüntüle ve yönet',
          icon: Icons.history,
          onTap: _showSessionHistory,
        ),
      ],
    );
  }

  Widget _buildLanguageAndRegion() {
    return _SettingsSection(
      title: 'Dil ve Bölge',
      icon: Icons.language,
      children: [
        _ListTile(
          title: 'Dil',
          subtitle: _getLanguageDisplayName(_selectedLanguage),
          icon: Icons.translate,
          onTap: _showLanguageSelector,
        ),
        
        _ListTile(
          title: 'Para Birimi',
          subtitle: _getCurrencyDisplayName(_selectedCurrency),
          icon: Icons.monetization_on,
          onTap: _showCurrencySelector,
        ),
        
        _ListTile(
          title: 'Tarih ve Saat Formatı',
          subtitle: 'Bölgesel ayarlar',
          icon: Icons.access_time,
          onTap: _showDateTimeSettings,
        ),
      ],
    );
  }

  Widget _buildDataAndStorage() {
    return _SettingsSection(
      title: 'Veri ve Depolama',
      icon: Icons.storage,
      children: [
        _ListTile(
          title: 'Önbellek Temizle',
          subtitle: 'Geçici dosyaları sil (24 MB)',
          icon: Icons.clear_all,
          onTap: _clearCache,
        ),
        
        _ListTile(
          title: 'Fotoğraf Kalitesi',
          subtitle: 'Yüklenen fotoğrafların kalitesi',
          icon: Icons.photo_camera,
          onTap: _showPhotoQualitySettings,
          trailing: const Text(
            'Yüksek',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        
        _ListTile(
          title: 'Otomatik Yedekleme',
          subtitle: 'Verilerinizi güvenli bir şekilde yedekleyin',
          icon: Icons.backup,
          onTap: _showBackupSettings,
        ),
        
        _ListTile(
          title: 'Veri Kullanımı',
          subtitle: 'Ağ trafiği istatistikleri',
          icon: Icons.data_usage,
          onTap: _showDataUsage,
        ),
      ],
    );
  }

  Widget _buildSupportAndInfo() {
    return _SettingsSection(
      title: 'Destek ve Bilgi',
      icon: Icons.help,
      children: [
        _ListTile(
          title: 'Yardım Merkezi',
          subtitle: 'SSS ve kullanım kılavuzu',
          icon: Icons.help_outline,
          onTap: _openHelpCenter,
        ),
        
        _ListTile(
          title: 'Bize Ulaşın',
          subtitle: 'Destek ekibiyle iletişime geçin',
          icon: Icons.contact_support,
          onTap: _contactSupport,
        ),
        
        _ListTile(
          title: 'Geri Bildirim Gönder',
          subtitle: 'Uygulamamızı değerlendirin',
          icon: Icons.feedback,
          onTap: _sendFeedback,
        ),
        
        _ListTile(
          title: 'Uygulamayı Değerlendir',
          subtitle: 'App Store / Play Store\'da değerlendirin',
          icon: Icons.star,
          onTap: _rateApp,
        ),
        
        _ListTile(
          title: 'Hakkında',
          subtitle: 'Sürüm 1.0.0 (123)',
          icon: Icons.info,
          onTap: _showAboutDialog,
        ),
      ],
    );
  }

  Widget _buildAccountActions() {
    return _SettingsSection(
      title: 'Hesap İşlemleri',
      icon: Icons.account_circle,
      children: [
        _ListTile(
          title: 'Hesabı Dondur',
          subtitle: 'Hesabınızı geçici olarak devre dışı bırakın',
          icon: Icons.pause_circle,
          onTap: _showFreezeAccountDialog,
          textColor: Colors.orange,
        ),
        
        _ListTile(
          title: 'Hesabı Sil',
          subtitle: 'Hesabınızı ve tüm verilerinizi kalıcı olarak silin',
          icon: Icons.delete_forever,
          onTap: _showDeleteAccountDialog,
          textColor: Colors.red,
        ),
        
        _ListTile(
          title: 'Çıkış Yap',
          subtitle: 'Tüm cihazlardan güvenli çıkış',
          icon: Icons.logout,
          onTap: _showLogoutDialog,
          textColor: Colors.red,
        ),
      ],
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      default:
        return 'Türkçe';
    }
  }

  String _getCurrencyDisplayName(String currencyCode) {
    switch (currencyCode) {
      case 'TRY':
        return 'Türk Lirası (₺)';
      case 'USD':
        return 'US Dollar (\$)';
      case 'EUR':
        return 'Euro (€)';
      default:
        return 'Türk Lirası (₺)';
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tema Rengi Seç'),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            Colors.blue,
            Colors.green,
            Colors.red,
            Colors.purple,
            Colors.orange,
            Colors.teal,
          ].map((color) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                // TODO: Tema rengini değiştir
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tema rengi güncellendi')),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == AppTheme.primaryColor 
                        ? Colors.white 
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFontSizeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Boyutu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RadioOption(
              title: 'Küçük',
              value: 'small',
              groupValue: 'medium',
              onChanged: (value) => Navigator.pop(context),
            ),
            _RadioOption(
              title: 'Orta',
              value: 'medium',
              groupValue: 'medium',
              onChanged: (value) => Navigator.pop(context),
            ),
            _RadioOption(
              title: 'Büyük',
              value: 'large',
              groupValue: 'medium',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RadioOption(
              title: 'Türkçe',
              value: 'tr',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
            _RadioOption(
              title: 'English',
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
            _RadioOption(
              title: 'Deutsch',
              value: 'de',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Para Birimi Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RadioOption(
              title: 'Türk Lirası (₺)',
              value: 'TRY',
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() => _selectedCurrency = value!);
                Navigator.pop(context);
              },
            ),
            _RadioOption(
              title: 'US Dollar (\$)',
              value: 'USD',
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() => _selectedCurrency = value!);
                Navigator.pop(context);
              },
            ),
            _RadioOption(
              title: 'Euro (€)',
              value: 'EUR',
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() => _selectedCurrency = value!);
                Navigator.pop(context);
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Şifre başarıyla değiştirildi')),
              );
            },
            child: const Text('Değiştir'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Önbellek Temizle'),
        content: const Text(
          'Geçici dosyalar ve önbellek verilerini silmek istediğinizden emin misiniz?',
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
                const SnackBar(content: Text('Önbellek temizlendi')),
              );
            },
            child: const Text('Temizle'),
          ),
        ],
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

  void _showFreezeAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Dondur'),
        content: const Text(
          'Hesabınızı geçici olarak dondurmak istediğinizden emin misiniz? Bu işlemi daha sonra geri alabilirsiniz.',
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
                const SnackBar(content: Text('Hesap donduruldu')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Dondur'),
          ),
        ],
      ),
    );
  }

  // Diğer methodlar - placeholder implementasyonlar
  void _show2FASettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İki faktörlü kimlik doğrulama ayarları yakında')),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gizlilik ayarları yakında')),
    );
  }

  void _showSessionHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oturum geçmişi yakında')),
    );
  }

  void _showDateTimeSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarih/saat ayarları yakında')),
    );
  }

  void _showPhotoQualitySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fotoğraf kalitesi ayarları yakında')),
    );
  }

  void _showBackupSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yedekleme ayarları yakında')),
    );
  }

  void _showDataUsage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veri kullanımı istatistikleri yakında')),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yardım merkezi açılıyor...')),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Destek ekibiyle iletişim kuruluyor...')),
    );
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Geri bildirim formu açılıyor...')),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App Store/Play Store açılıyor...')),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Gleam',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Gleam. Tüm hakları saklıdır.',
      children: [
        const SizedBox(height: 16),
        const Text('Türkiye\'nin en iyi mobil araç yıkama uygulaması.'),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }
}

class _ListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? textColor;

  const _ListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.trailing,
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
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioOption({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }
} 
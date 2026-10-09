import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  // Yıkamacı için ek alanlar
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _taxNumberController = TextEditingController();
  final TextEditingController _vehiclePlateController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _washerFormKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.customer; // Varsayılan olarak müşteri
  int _currentStep = 0;
  
  // Yıkamacı için ek bilgiler
  List<String> _selectedServiceAreas = [];
  String _experienceYears = '1';
  String _vehicleType = 'Minibüs';
  String _workingHours = '09-18';
  String? _selectedCity;
  
  final Map<String, List<String>> _cityDistrictsMap = {
    'İstanbul': [
      'Kadıköy', 'Beşiktaş', 'Şişli', 'Ataşehir', 'Üsküdar', 'Fatih', 'Beyoğlu', 
      'Bakırköy', 'Maltepe', 'Kartal', 'Pendik', 'Tuzla', 'Bağcılar', 'Bahçelievler',
      'Zeytinburnu', 'Avcılar', 'Küçükçekmece', 'Büyükçekmece', 'Esenyurt', 'Arnavutköy'
    ],
    'Ankara': [
      'Çankaya', 'Keçiören', 'Yenimahalle', 'Mamak', 'Sincan', 'Etimesgut', 
      'Altındağ', 'Gölbaşı', 'Pursaklar', 'Elmadağ', 'Kızılcahamam'
    ],
    'İzmir': [
      'Konak', 'Bornova', 'Buca', 'Karşıyaka', 'Alsancak', 'Gaziemir', 'Balçova',
      'Narlıdere', 'Güzelbahçe', 'Çiğli', 'Bayraklı', 'Karabağlar'
    ],
    'Bursa': [
      'Osmangazi', 'Nilüfer', 'Yıldırım', 'Mudanya', 'Gemlik', 'İnegöl', 
      'Orhangazi', 'Iznik', 'Karacabey', 'Mustafakemalpaşa'
    ],
    'Antalya': [
      'Muratpaşa', 'Kepez', 'Konyaaltı', 'Aksu', 'Döşemealtı', 'Alanya', 
      'Manavgat', 'Side', 'Kemer', 'Kaş', 'Kalkan'
    ]
  };
  
  final List<String> _experienceOptions = ['1', '2', '3', '4', '5', '5+'];
  final List<String> _vehicleTypeOptions = ['Minibüs', 'Kamyonet', 'Pickup', 'Van'];
  final List<String> _workingHoursOptions = [
    '08-17', '09-18', '10-19', 'Esnek'
  ];

  // Input decoration helper
  InputDecoration _buildInputDecoration(String labelText, IconData icon, {String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    
    // Yıkamacı controller'ları
    _idNumberController.dispose();
    _licenseNumberController.dispose();
    _taxNumberController.dispose();
    _vehiclePlateController.dispose();
    _vehicleModelController.dispose();
    _ibanController.dispose();
    _bankNameController.dispose();
    
    _pageController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_currentStep == 0 ? 'Kayıt Ol' : 'Yıkamacı Bilgileri'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentStep > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              context.go(AppRoutes.login);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          if (_selectedRole == UserRole.washer)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _currentStep >= 1 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildBasicInfoPage(),
                if (_selectedRole == UserRole.washer) _buildWasherInfoPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Başlık
            Text(
              'Hesap Oluştur',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni hesap oluşturmak için bilgilerinizi girin',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Kullanıcı Türü Seçimi
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hesap Türü',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<UserRole>(
                            value: UserRole.customer,
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                            title: const Text('Müşteri'),
                            subtitle: const Text('Araç yıkama hizmeti almak'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<UserRole>(
                            value: UserRole.washer,
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                            title: const Text('Yıkamacı'),
                            subtitle: const Text('Araç yıkama hizmeti vermek'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Ad
            TextFormField(
              controller: _firstNameController,
              decoration: _buildInputDecoration('Ad', Icons.person),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ad gerekli';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Soyad
            TextFormField(
              controller: _lastNameController,
              decoration: _buildInputDecoration('Soyad', Icons.person_outline),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Soyad gerekli';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _buildInputDecoration('E-posta', Icons.email),
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
            
            // Telefon
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _buildInputDecoration('Telefon', Icons.phone, hintText: '5XX XXX XX XX'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Telefon gerekli';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Şifre
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: _buildInputDecoration('Şifre', Icons.lock).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Şifre gerekli';
                }
                if (value.length < 6) {
                  return 'Şifre en az 6 karakter olmalı';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Şifre Tekrar
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: _buildInputDecoration('Şifre Tekrar', Icons.lock).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Şifre tekrarı gerekli';
                }
                if (value != _passwordController.text) {
                  return 'Şifreler eşleşmiyor';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            
            // Kayıt Ol veya Devam Et Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  if (_selectedRole == UserRole.washer) {
                    _goToWasherInfo();
                  } else {
                    _handleRegister();
                  }
                },
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_selectedRole == UserRole.washer ? 'Devam Et' : 'Kayıt Ol'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Giriş yap linki
            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: RichText(
                  text: TextSpan(
                    text: 'Zaten hesabınız var mı? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    children: [
                      TextSpan(
                        text: 'Giriş Yap',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWasherInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _washerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Başlık
            Text(
              'Yıkamacı Bilgileri',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hizmet verebilmek için aşağıdaki bilgileri doldurun',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // TC Kimlik No
            TextFormField(
              controller: _idNumberController,
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration('TC Kimlik No', Icons.badge),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'TC Kimlik No gerekli';
                }
                if (value.length != 11) {
                  return '11 haneli olmalı';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Sürücü Belgesi No
            TextFormField(
              controller: _licenseNumberController,
              decoration: _buildInputDecoration('Sürücü Belgesi No', Icons.drive_eta),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Sürücü belgesi gerekli';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Vergi Numarası (opsiyonel)
            TextFormField(
              controller: _taxNumberController,
              keyboardType: TextInputType.number,
              decoration: _buildInputDecoration('Vergi Numarası (Opsiyonel)', Icons.receipt),
            ),
            
            const SizedBox(height: 16),
            
            // Tecrübe
            DropdownButtonFormField<String>(
              value: _experienceYears,
              decoration: _buildInputDecoration('Tecrübe (Yıl)', Icons.work_history),
              items: _experienceOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _experienceYears = newValue!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Çalışma Saatleri
            DropdownButtonFormField<String>(
              value: _workingHours,
              decoration: _buildInputDecoration('Çalışma Saatleri', Icons.access_time),
              items: _workingHoursOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _workingHours = newValue!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Araç Plakası
            TextFormField(
              controller: _vehiclePlateController,
              decoration: _buildInputDecoration('Araç Plakası', Icons.directions_car),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Araç plakası gerekli';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Araç Tipi
            DropdownButtonFormField<String>(
              value: _vehicleType,
              decoration: _buildInputDecoration('Araç Tipi', Icons.local_shipping),
              items: _vehicleTypeOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _vehicleType = newValue!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Araç Modeli
            TextFormField(
              controller: _vehicleModelController,
              decoration: _buildInputDecoration(
                'Araç Markası/Modeli', 
                Icons.car_repair,
                hintText: 'ör: Ford Transit, Volkswagen Crafter',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Araç modeli gerekli';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // IBAN
            TextFormField(
              controller: _ibanController,
              decoration: _buildInputDecoration('IBAN', Icons.account_balance, hintText: 'TR33 0006 1005 1978 6457 8413 26'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'IBAN gerekli';
                }
                
                // Boşlukları temizle ve büyük harfe çevir
                String cleanIban = value.replaceAll(' ', '').toUpperCase();
                
                if (!cleanIban.startsWith('TR') || cleanIban.length != 26) {
                  return 'Geçerli IBAN girin (TR ile başlamalı, 26 karakter)';
                }
                
                // Sadece harf ve rakam içermeli
                if (!RegExp(r'^[A-Z0-9]+$').hasMatch(cleanIban)) {
                  return 'IBAN sadece harf ve rakam içerebilir';
                }
                
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Banka Adı
            TextFormField(
              controller: _bankNameController,
              decoration: _buildInputDecoration('Banka Adı', Icons.business),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Banka adı gerekli';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Hizmet Bölgeleri
            Text(
              'Hizmet Verebileceğiniz Bölgeler:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            // İl Seçimi
            DropdownButtonFormField<String>(
              value: _selectedCity,
              isExpanded: true,
              decoration: _buildInputDecoration('İl Seçin', Icons.location_city),
              hint: const Text('İl seçin'),
              items: _cityDistrictsMap.keys.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCity = newValue;
                  _selectedServiceAreas.clear(); // İl değişince ilçeleri temizle
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'İl seçimi zorunludur';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // İlçe Seçimi (Sadece il seçildiyse görünür)
            if (_selectedCity != null) ...[
              Text(
                '${_selectedCity!} İlçeleri:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hizmet verebileceğiniz ilçeleri seçin',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _cityDistrictsMap[_selectedCity]!.map((district) {
                  final isSelected = _selectedServiceAreas.contains(district);
                  return FilterChip(
                    label: Text(district),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedServiceAreas.add(district);
                        } else {
                          _selectedServiceAreas.remove(district);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              
              if (_selectedServiceAreas.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'En az bir ilçe seçmelisiniz',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Önce il seçimi yapın',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
               
            const SizedBox(height: 32),
            
            // Kayıt Ol Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Kayıt Ol'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToWasherInfo() {
    if (_formKey.currentState?.validate() ?? false) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleRegister() async {
    print('DEBUG: _handleRegister başladı');
    
    // Manuel validasyon - form state'ler null olabilir PageView yüzünden
    bool basicFormValid = true;
    bool washerFormValid = true;
    
    // İlk sayfadaki alanları manuel kontrol et
    if (_firstNameController.text.trim().isEmpty) {
      basicFormValid = false;
      print('DEBUG: Ad boş');
    }
    if (_lastNameController.text.trim().isEmpty) {
      basicFormValid = false;
      print('DEBUG: Soyad boş');
    }
    if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
      basicFormValid = false;
      print('DEBUG: Email geçersiz');
    }
    if (_phoneController.text.trim().isEmpty) {
      basicFormValid = false;
      print('DEBUG: Telefon boş');
    }
    if (_passwordController.text.length < 6) {
      basicFormValid = false;
      print('DEBUG: Şifre çok kısa');
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      basicFormValid = false;
      print('DEBUG: Şifreler eşleşmiyor');
    }
    
    print('DEBUG: basicFormValid = $basicFormValid');
    
    // Yıkamacı alanlarını kontrol et
    if (_selectedRole == UserRole.washer) {
      if (_idNumberController.text.trim().isEmpty || _idNumberController.text.trim().length != 11) {
        washerFormValid = false;
        print('DEBUG: TC kimlik hatalı');
      }
      if (_licenseNumberController.text.trim().isEmpty) {
        washerFormValid = false;
        print('DEBUG: Sürücü belgesi boş');
      }
      if (_vehiclePlateController.text.trim().isEmpty) {
        washerFormValid = false;
        print('DEBUG: Araç plakası boş');
      }
      if (_vehicleModelController.text.trim().isEmpty) {
        washerFormValid = false;
        print('DEBUG: Araç modeli boş');
      }
      if (_ibanController.text.trim().isEmpty) {
        washerFormValid = false;
        print('DEBUG: IBAN boş');
      } else {
        String cleanIban = _ibanController.text.replaceAll(' ', '').toUpperCase();
        if (!cleanIban.startsWith('TR') || cleanIban.length != 26) {
          washerFormValid = false;
          print('DEBUG: IBAN geçersiz');
        }
      }
      if (_bankNameController.text.trim().isEmpty) {
        washerFormValid = false;
        print('DEBUG: Banka adı boş');
      }
      print('DEBUG: washerFormValid = $washerFormValid');
    }
    
    if (!basicFormValid || !washerFormValid) {
      print('DEBUG: Validation başarısız');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doğru doldurun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Yıkamacı için ek validasyonlar
    if (_selectedRole == UserRole.washer) {
      print('DEBUG: Yıkamacı validasyonları kontrol ediliyor');
      if (_selectedCity == null) {
        print('DEBUG: İl seçimi yapılmamış');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İl seçimi zorunludur'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedServiceAreas.isEmpty) {
        print('DEBUG: İlçe seçimi yapılmamış');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('En az bir ilçe seçmelisiniz'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    print('DEBUG: setState ile loading true yapılıyor');
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('DEBUG: AuthProvider alınıyor');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      print('DEBUG: UserModel oluşturuluyor');
      // Kullanıcı verilerini hazırla
      final userData = UserModel(
        id: '', // AuthService tarafından atanacak
        email: _emailController.text.trim(),
        phoneNumber: '+90${_phoneController.text.trim()}',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: _selectedRole, // Seçilen rol
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        
        // Yıkamacı için ek bilgiler
        serviceAreas: _selectedRole == UserRole.washer && _selectedCity != null && _selectedServiceAreas.isNotEmpty
          ? _selectedServiceAreas.map((district) => '${_selectedCity!} - $district').toList()
          : null,
        licenseNumber: _selectedRole == UserRole.washer ? _licenseNumberController.text.trim() : null,
        vehicleInfo: _selectedRole == UserRole.washer 
          ? '${_vehicleModelController.text.trim()} - ${_vehiclePlateController.text.trim()} - ${_ibanController.text.replaceAll(' ', '').toUpperCase().trim()} (${_bankNameController.text.trim()})'
          : null,
      );
      
      print('DEBUG: signUpWithEmail çağrılıyor');
      // Kayıt işlemi
      final success = await authProvider.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        userData,
      );
    
      print('DEBUG: Kayıt sonucu: $success');
      if (success && context.mounted) {
        String message = 'Kayıt başarılı! Giriş yapabilirsiniz.';
        if (_selectedRole == UserRole.washer) {
          message = 'Yıkamacı kaydınız alındı! Onay sürecinden sonra hizmet verebilirsiniz.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
        context.go(AppRoutes.login);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Kayıt sırasında bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Hata oluştu: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kayıt sırasında hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      print('DEBUG: finally bloğu - loading false yapılıyor');
      setState(() {
        _isLoading = false;
      });
    }
  }
} 
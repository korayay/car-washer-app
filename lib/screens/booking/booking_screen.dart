import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/booking_model.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form verileri
  WashType? _selectedWashType;
  VehicleType? _selectedVehicleType;
  String _vehicleModel = '';
  String _vehicleColor = '';
  String _vehiclePlate = '';
  String _address = '';
  Map<String, double>? _location;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  String _notes = '';
  bool _isEcoFriendly = false;
  
  // Form anahtarları
  final _vehicleFormKey = GlobalKey<FormState>();
  final _locationFormKey = GlobalKey<FormState>();
  final _detailsFormKey = GlobalKey<FormState>();

  // Adres girişi için TextEditingController
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Rezervasyon'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            print('Debug: AppBar back button tıklandı, currentStep: $_currentStep');
            if (_currentStep > 0) {
              print('Debug: Önceki adıma geçiliyor');
              _previousStep();
            } else {
              print('Debug: Ana sayfaya dönülüyor (context.go)');
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // İlerleme göstergesi
          _buildProgressIndicator(),
          
          // İçerik
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildServiceSelectionStep(),
                _buildVehicleInfoStep(),
                _buildLocationStep(),
                _buildScheduleStep(),
                _buildSummaryStep(),
              ],
            ),
          ),
          
          // Alt butonlar
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index == 4 ? 0 : 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primaryColor : AppTheme.grey300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < 4)
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isCompleted ? AppTheme.primaryColor : AppTheme.grey300,
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 8)
                          : null,
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildServiceSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hizmet Seçin',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Arabanız için hangi yıkama servisini istiyorsunuz?',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              children: [
                _ServiceOption(
                  washType: WashType.dryClean,
                  title: 'Dry Clean',
                  subtitle: 'Hızlı susuz temizlik, özel kimyasal formül',
                  price: '150₺',
                  duration: '20 dakika',
                  color: Colors.lightBlue,
                  isSelected: _selectedWashType == WashType.dryClean,
                  onTap: () => setState(() => _selectedWashType = WashType.dryClean),
                ),
                const SizedBox(height: 12),
                _ServiceOption(
                  washType: WashType.greenShine,
                  title: 'Green Shine',
                  subtitle: 'Sadece dış temizlik, parlatma dahil',
                  price: '200₺',
                  duration: '30 dakika',
                  color: Colors.green,
                  isSelected: _selectedWashType == WashType.greenShine,
                  onTap: () => setState(() => _selectedWashType = WashType.greenShine),
                ),
                const SizedBox(height: 12),
                _ServiceOption(
                  washType: WashType.greenCabin,
                  title: 'Green Cabin',
                  subtitle: 'Sadece iç temizlik, detaylı vakumlama',
                  price: '240₺',
                  duration: '40 dakika',
                  color: Colors.teal,
                  isSelected: _selectedWashType == WashType.greenCabin,
                  onTap: () => setState(() => _selectedWashType = WashType.greenCabin),
                ),
                const SizedBox(height: 12),
                _ServiceOption(
                  washType: WashType.greenPlus,
                  title: 'Green Plus',
                  subtitle: 'İç + dış detaylı temizlik',
                  price: '360₺',
                  duration: '60 dakika',
                  color: Colors.orange,
                  isSelected: _selectedWashType == WashType.greenPlus,
                  onTap: () => setState(() => _selectedWashType = WashType.greenPlus),
                ),
                const SizedBox(height: 12),
                _ServiceOption(
                  washType: WashType.greenDeluxe,
                  title: 'Green Deluxe',
                  subtitle: 'Komple temizlik + cilalama, premium ürünler',
                  price: '460₺',
                  duration: '90 dakika',
                  color: Colors.purple,
                  isSelected: _selectedWashType == WashType.greenDeluxe,
                  onTap: () => setState(() => _selectedWashType = WashType.greenDeluxe),
                ),
                const SizedBox(height: 12),
                _ServiceOption(
                  washType: WashType.greenDeluxeMonthly,
                  title: 'Clean Club',
                  subtitle: 'Ayda 4 kez komple temizlik paketi',
                  price: '800₺/ay',
                  duration: '90 dakika',
                  color: Colors.deepPurple,
                  isSelected: _selectedWashType == WashType.greenDeluxeMonthly,
                  onTap: () => setState(() => _selectedWashType = WashType.greenDeluxeMonthly),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _vehicleFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Araç Bilgileri',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aracınızın bilgilerini girin',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: ListView(
                children: [
                  // Araç tipi
                  Text(
                    'Araç Tipi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: VehicleType.values.map((type) {
                      final isSelected = _selectedVehicleType == type;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedVehicleType = type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : AppTheme.grey300,
                            ),
                          ),
                          child: Text(
                            _getVehicleTypeDisplayName(type),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Araç modeli
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Araç Modeli',
                      hintText: 'Örn: Toyota Corolla, BMW 3 Serisi',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Araç modeli gerekli';
                      }
                      return null;
                    },
                    onSaved: (value) => _vehicleModel = value ?? '',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Araç rengi
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Araç Rengi',
                      hintText: 'Örn: Beyaz, Siyah, Gri',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Araç rengi gerekli';
                      }
                      return null;
                    },
                    onSaved: (value) => _vehicleColor = value ?? '',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Plaka
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Plaka',
                      hintText: '34 ABC 123',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Plaka gerekli';
                      }
                      return null;
                    },
                    onSaved: (value) => _vehiclePlate = value ?? '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _locationFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konum Bilgileri',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yıkama işleminin yapılacağı adresi belirtin',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            
            // Konum seçimi bölümü
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Hizmet Konumu',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Adres girişi
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Tam Adres *',
                      hintText: 'Örn: Atatürk Cad. No:123, Kadıköy/İstanbul',
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen adres bilgisini girin';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _address = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Google Maps ve GPS butonları
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectFromMap,
                          icon: const Icon(Icons.map),
                          label: const Text('Haritadan Seç'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: BorderSide(color: AppTheme.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('GPS Konum'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (_address.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Adres: $_address',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarih ve Saat',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yıkama işleminin yapılacağı zamanı seçin',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              children: [
                // Tarih seçimi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.grey300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Tarih',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectDate,
                          child: Text(
                            _scheduledDate != null
                                ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                                : 'Tarih Seçin',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Saat seçimi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.grey300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Saat',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectTime,
                          child: Text(
                            _scheduledTime != null
                                ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                                : 'Saat Seçin',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Notlar
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Ek Notlar (Opsiyonel)',
                    hintText: 'Özel talepleriniz varsa buraya yazabilirsiniz',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                  maxLines: 3,
                  onSaved: (value) => _notes = value ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    final bookingProvider = context.read<BookingProvider>();
    final price = _selectedWashType != null && _selectedVehicleType != null
        ? bookingProvider.calculatePrice(_selectedWashType!, _selectedVehicleType!, _isEcoFriendly)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rezervasyon Özeti',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bilgilerinizi kontrol edin ve rezervasyonu onaylayın',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              children: [
                _SummaryCard(
                  title: 'Hizmet',
                  content: [
                    'Tip: ${_getWashTypeDisplayName(_selectedWashType)}',
                    if (_isEcoFriendly) 'Çevre dostu ürünler (%10 indirim)',
                  ],
                  icon: Icons.local_car_wash,
                ),
                
                _SummaryCard(
                  title: 'Araç Bilgileri',
                  content: [
                    'Tip: ${_getVehicleTypeDisplayName(_selectedVehicleType)}',
                    'Model: $_vehicleModel',
                    'Renk: $_vehicleColor',
                    'Plaka: $_vehiclePlate',
                  ],
                  icon: Icons.directions_car,
                ),
                
                _SummaryCard(
                  title: 'Konum',
                  content: [
                    _address.isNotEmpty ? _address : 'Mevcut konum kullanılacak',
                  ],
                  icon: Icons.location_on,
                ),
                
                _SummaryCard(
                  title: 'Tarih ve Saat',
                  content: [
                    _scheduledDate != null
                        ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                        : 'Tarih seçilmedi',
                    _scheduledTime != null
                        ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                        : 'Saat seçilmedi',
                  ],
                  icon: Icons.schedule,
                ),
                
                if (_notes.isNotEmpty)
                  _SummaryCard(
                    title: 'Notlar',
                    content: [_notes],
                    icon: Icons.note,
                  ),
                
                const SizedBox(height: 16),
                
                // Fiyat kartı
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Toplam Tutar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        '${price.toStringAsFixed(0)}₺',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
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
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Geri'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canContinue() ? _nextStep : null,
              child: Text(_currentStep == 4 ? 'Rezervasyonu Onayla' : 'Devam'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _selectedWashType != null;
      case 1:
        return _selectedVehicleType != null;
      case 2:
        return _address.isNotEmpty;
      case 3:
        return _scheduledDate != null && _scheduledTime != null;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      // Form validasyonu
      switch (_currentStep) {
        case 1:
          if (_vehicleFormKey.currentState != null && 
              !_vehicleFormKey.currentState!.validate()) return;
          _vehicleFormKey.currentState?.save();
          break;
        case 2:
          if (_locationFormKey.currentState != null && 
              !_locationFormKey.currentState!.validate()) return;
          _locationFormKey.currentState?.save();
          break;
        case 3:
          if (_detailsFormKey.currentState != null && 
              !_detailsFormKey.currentState!.validate()) return;
          _detailsFormKey.currentState?.save();
          break;
      }
      
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _createBooking();
    }
  }

  void _previousStep() {
    print('Debug: _previousStep çağrıldı, currentStep: $_currentStep');
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      print('Debug: Step değiştirildi, yeni currentStep: $_currentStep');
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      print('Debug: PageController.previousPage çağrıldı');
    } else {
      print('Debug: currentStep zaten 0, işlem yapılmadı');
    }
  }

  void _getCurrentLocation() async {
    try {
      // Gerçek GPS konumu almak için LocationProvider kullanılacak
      // Şu an için İstanbul'da örnek konum veriyoruz
      final locations = [
        {'lat': 41.0082, 'lng': 28.9784, 'address': 'Sultanahmet, Fatih/İstanbul'},
        {'lat': 41.0214, 'lng': 29.0061, 'address': 'Üsküdar, İstanbul'},
        {'lat': 40.9917, 'lng': 29.0278, 'address': 'Kadıköy, İstanbul'},
        {'lat': 41.0370, 'lng': 28.9857, 'address': 'Beşiktaş, İstanbul'},
      ];
      
      // Random location seç (simülasyon için)
      final randomLocation = locations[DateTime.now().millisecond % locations.length];
      
      setState(() {
        _location = {
          'lat': randomLocation['lat'] as double, 
          'lng': randomLocation['lng'] as double
        };
        _address = randomLocation['address'] as String;
        _addressController.text = _address;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GPS konumu tespit edildi: ${randomLocation['address']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konum tespit edilemedi. Lütfen manuel adres girin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectFromMap() {
    // Google Maps entegrasyonu için placeholder
    // Gerçek uygulamada google_maps_flutter paketi kullanılacak
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Haritadan Konum Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Google Maps entegrasyonu yakında eklenecek.'),
            const SizedBox(height: 16),
            const Text('Şimdilik popüler konumlardan seçin:'),
            const SizedBox(height: 16),
            ...['Kadıköy', 'Beşiktaş', 'Şişli', 'Ataşehir', 'Üsküdar']
                .map((area) => ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(area),
                      subtitle: Text('$area, İstanbul'),
                      onTap: () {
                        setState(() {
                          _address = '$area, İstanbul';
                          _addressController.text = _address;
                          _location = {'lat': 41.0082, 'lng': 28.9784};
                        });
                        Navigator.pop(context);
                      },
                    )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() => _scheduledDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) {
      setState(() => _scheduledTime = time);
    }
  }

  Future<void> _createBooking() async {
    // Güvenlik kontrolü
    if (_selectedWashType == null || _selectedVehicleType == null || 
        _scheduledDate == null || _scheduledTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm bilgileri doldurun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();
    
    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce giriş yapın'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tarih ve saat değerlerini tekrar kontrol et
    final scheduledDate = _scheduledDate;
    final scheduledTime = _scheduledTime;
    
    if (scheduledDate == null || scheduledTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tarih ve saat seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final booking = BookingModel(
      id: '',
      customerId: user.id,
      customerName: user.fullName,
      customerPhone: user.phoneNumber,
      status: BookingStatus.pending,
      washType: _selectedWashType!,
      vehicleType: _selectedVehicleType!,
      vehicleModel: _vehicleModel,
      vehicleColor: _vehicleColor,
      vehiclePlate: _vehiclePlate,
      address: _address,
      location: _location ?? {'lat': 0.0, 'lng': 0.0},
      scheduledDate: DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledTime.hour,
        scheduledTime.minute,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      price: bookingProvider.calculatePrice(_selectedWashType!, _selectedVehicleType!, _isEcoFriendly),
      notes: _notes,
      isEcoFriendly: _isEcoFriendly,
    );

    final success = await bookingProvider.createBooking(booking);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rezervasyon oluşturuldu!')),
      );
      context.go(AppRoutes.home);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookingProvider.error ?? 'Bir hata oluştu')),
      );
    }
  }

  String _getWashTypeDisplayName(WashType? washType) {
    if (washType == null) return 'Yıkama tipi seçin';
    return washType.displayName;
  }

  String _getVehicleTypeDisplayName(VehicleType? vehicleType) {
    if (vehicleType == null) return '';
    switch (vehicleType) {
      case VehicleType.car:
        return 'Otomobil';
      case VehicleType.suv:
        return 'SUV';
      case VehicleType.truck:
        return 'Kamyonet';
      case VehicleType.motorcycle:
        return 'Motosiklet';
    }
  }
}

class _ServiceOption extends StatelessWidget {
  final WashType washType;
  final String title;
  final String subtitle;
  final String price;
  final String duration;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceOption({
    required this.washType,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.duration,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
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
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Eco-friendly etiketi
                      if (washType.isEcoFriendly)
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
                      if (washType.isPremium) ...[
                        if (washType.isEcoFriendly) const SizedBox(width: 4),
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
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' • $duration',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final List<String> content;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...content.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              item,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          )),
        ],
      ),
    );
  }
} 
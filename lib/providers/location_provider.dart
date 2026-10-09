import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  String? _error;
  bool _permissionGranted = false;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get permissionGranted => _permissionGranted;

  Future<void> initialize() async {
    await checkLocationPermission();
    if (_permissionGranted) {
      await getCurrentLocation();
    }
  }

  Future<void> checkLocationPermission() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _permissionGranted = await _locationService.checkLocationPermission();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestLocationPermission() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _permissionGranted = await _locationService.requestLocationPermission();
      
      if (_permissionGranted) {
        await getCurrentLocation();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _currentPosition = await _locationService.getCurrentPosition();
      
      if (_currentPosition != null) {
        await _getAddressFromCoordinates(_currentPosition!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getAddressFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _currentAddress = _formatAddress(placemark);
      }
    } catch (e) {
      _error = 'Adres bilgisi alınamadı: $e';
    }
  }

  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      parts.add(placemark.administrativeArea!);
    }
    
    return parts.join(', ');
  }

  Future<List<Location>> searchLocation(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final locations = await locationFromAddress(query);
      return locations;
    } catch (e) {
      _error = 'Konum arama hatası: $e';
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return _formatAddress(placemark);
      }
      return null;
    } catch (e) {
      _error = 'Adres bilgisi alınamadı: $e';
      return null;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toInt()} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  bool isLocationServiceEnabled() {
    return _locationService.isLocationServiceEnabled();
  }

  void setCurrentPosition(Position position) {
    _currentPosition = position;
    _getAddressFromCoordinates(position);
    notifyListeners();
  }

  void setCurrentAddress(String address) {
    _currentAddress = address;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isCustomer => _currentUser?.isCustomer ?? false;
  bool get isWasher => _currentUser?.isWasher ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Mock auth state changes - periyodik olarak kontrol et
    _authService.authStateChanges.listen((mockUser) async {
      if (mockUser != null) {
        await _loadCurrentUser(mockUser.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadCurrentUser(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final userData = await _firestoreService.getUserById(uid);
      if (userData != null) {
        // Eski kullanıcılar için eksik field'ları doldur
        final enrichedUserData = {
          ...userData,
          'points': userData['points'] ?? 0,
          'achievements': userData['achievements'] ?? [],
          'totalEcoWashes': userData['totalEcoWashes'] ?? 0,
          'lastWashDate': userData['lastWashDate'],
        };
        
        _currentUser = UserModel.fromMap(enrichedUserData);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithPhoneNumber(String phoneNumber) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final result = await _authService.signInWithPhoneNumber(phoneNumber);
      return result;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(String verificationId, String otp) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final user = await _authService.verifyOTP(verificationId, otp);
      if (user != null) {
        await _loadCurrentUser(user.uid);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        await _loadCurrentUser(user.uid);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpWithEmail(String email, String password, UserModel userData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final user = await _authService.signUpWithEmail(email, password);
      if (user != null) {
        // Kullanıcı verilerini Firestore'a kaydet
        final userWithId = userData.copyWith(id: user.uid);
        await _firestoreService.createUser(userWithId);
        
        await _loadCurrentUser(user.uid);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final updatedUserData = updatedUser.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateUser(updatedUserData);
      _currentUser = updatedUserData;
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfileImage(String imageUrl) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(
          profileImageUrl: imageUrl,
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateUser(updatedUser);
        _currentUser = updatedUser;
        
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authService.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      if (_currentUser != null) {
        await _firestoreService.deleteUser(_currentUser!.id);
        await _authService.deleteAccount();
        _currentUser = null;
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
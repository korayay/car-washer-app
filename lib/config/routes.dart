import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/booking/booking_details_screen.dart';
import '../screens/washer/washer_dashboard_screen.dart';
import '../screens/washer/washer_job_details_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';
  static const String booking = '/booking';
  static const String bookingDetails = '/booking/details';
  static const String washerDashboard = '/washer-dashboard';
  static const String washerJobDetails = '/washer-dashboard/job';
  static const String profile = '/profile';
  static const String settings = '/profile/settings';
  static const String adminDashboard = '/admin-dashboard';

  static final GoRouter router = GoRouter(
    initialLocation: onboarding,
    redirect: (context, state) {
      // AuthProvider'dan user bilgisini almaya çalış
      // Not: Bu kısım uygulama başlatıldığında AuthProvider hazır olmayabilir
      return null; // Şimdilik redirect yapmıyoruz
    },
    routes: [
      // Onboarding ve Auth rotalar
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: otpVerification,
        name: 'otpVerification',
        builder: (context, state) {
          final phoneNumber = state.extra as String?;
          return OtpVerificationScreen(phoneNumber: phoneNumber ?? '');
        },
      ),
      
      // Ana uygulama rotalar
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Rezervasyon rotalar
          GoRoute(
        path: booking,
            name: 'booking',
            builder: (context, state) => const BookingScreen(),
            routes: [
              GoRoute(
                path: 'details/:bookingId',
                name: 'bookingDetails',
                builder: (context, state) {
                  final bookingId = state.pathParameters['bookingId']!;
                  return BookingDetailsScreen(bookingId: bookingId);
                },
          ),
        ],
      ),
      
      // Yıkamacı rotalar
      GoRoute(
        path: washerDashboard,
        name: 'washerDashboard',
        builder: (context, state) => const WasherDashboardScreen(),
        routes: [
          GoRoute(
            path: 'job/:jobId',
            name: 'washerJobDetails',
            builder: (context, state) {
              final jobId = state.pathParameters['jobId']!;
              return WasherJobDetailsScreen(jobId: jobId);
            },
          ),
        ],
      ),
      
      // Profil rotalar
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      
      // Admin rotalar
      GoRoute(
        path: adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
    
    // Hata sayfası
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Hata'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sayfa bulunamadı',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Aranan sayfa: ${state.uri}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
} 
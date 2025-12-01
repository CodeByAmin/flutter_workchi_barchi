import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'WorkConnect';
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const String apiVersion = 'v1';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';
  static const String deviceIdKey = 'device_id';
  static const String selectedRoleKey = 'selected_role';
  static const String selectedCityKey = 'selected_city';
  
  // API Endpoints
  static const String sendOtpEndpoint = '/auth/send-otp';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String getUserEndpoint = '/user/me';
  static const String updateUserEndpoint = '/user/me';
  static const String searchUsersEndpoint = '/users/search';
  
  // WebSocket
  static const String wsEndpoint = 'ws://localhost:8000/ws/chat';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // OTP
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 120;
}

class ValidationRegex {
  static final iranianPhone = RegExp(r'^(\+98|0)?9\d{9}$');
  static final otpCode = RegExp(r'^\d{6}$');
}

class AppRoutes {
  static const String splash = '/';
  static const String phoneInput = '/phone-input';
  static const String otpVerify = '/otp-verify';
  static const String roleSelection = '/role-selection';
  static const String workerHome = '/worker-home';
  static const String employerHome = '/employer-home';
  static const String profile = '/profile';
  static const String messages = '/messages';
  static const String requests = '/requests';
  static const String marketplace = '/marketplace';
  static const String tickets = '/tickets';
}

class AppStrings {
  static const String appTitle = 'WorkConnect ایران';
  static const String enterPhone = 'شماره موبایل خود را وارد کنید';
  static const String enterOtp = 'کد تایید را وارد کنید';
  static const String selectRole = 'نقش خود را انتخاب کنید';
  static const String worker = 'کارگر';
  static const String employer = 'کارفرما';
  static const String resendOtp = 'ارسال مجدد کد';
  static const String verify = 'تایید';
  static const String continueText = 'ادامه';
  static const String error = 'خطا';
  static const String success = 'موفقیت';
  static const String loading = 'لطفا صبر کنید...';
}

class AppColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color secondary = Color(0xFF2196F3);
  static const Color accent = Color(0xFFFF9800);
  static const Color background = Color(0xFFF5F5F5);
  static const Color text = Color(0xFF333333);
  static const Color error = Color(0xFFF44336);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);
}

class AppTheme {
    static const Color primaryColor = AppColors.primary;
  static const Color secondaryColor = AppColors.secondary;
  static const Color errorColor = AppColors.error;
  static const Color successColor = AppColors.success;
  static const Color textColor = AppColors.text;
  
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      filled: true,
      fillColor: AppColors.surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    fontFamily: 'Vazir',
    useMaterial3: true,
  );
}

class AppIcons {
  static const String phone = 'assets/icons/phone.svg';
  static const String message = 'assets/icons/message.svg';
  static const String user = 'assets/icons/user.svg';
  static const String home = 'assets/icons/home.svg';
  static const String market = 'assets/icons/market.svg';
  static const String inbox = 'assets/icons/inbox.svg';
  static const String settings = 'assets/icons/settings.svg';
}

enum UserRole {
  worker('کارگر'),
  employer('کارفرما'),
  admin('مدیر');
  
  final String persianName;
  const UserRole(this.persianName);
  
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'worker':
        return UserRole.worker;
      case 'employer':
        return UserRole.employer;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.worker;
    }
  }
}
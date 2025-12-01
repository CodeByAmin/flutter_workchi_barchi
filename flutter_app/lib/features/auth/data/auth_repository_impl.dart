import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../domain/entities/user.dart';
import './../domain/repositories/auth_repository.dart';
import '../domain/usecases/base_use_case.dart';
import 'auth_local_data_source.dart';
import 'auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, void>> sendOtp(String phone) async {
    try {
      final response = await remoteDataSource.sendOtp(phone);
      
      if (response['ok'] == true) {
        return const Right(null);
      } else {
        return Left(Failure(response['message'] ?? 'خطا در ارسال کد تایید'));
      }
    } catch (e) {
      return Left(Failure('خطا در ارتباط با سرور: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String otp,
    required String deviceId,
  }) async {
    try {
      final response = await remoteDataSource.verifyOtp(
        phone: phone,
        otp: otp,
        deviceId: deviceId,
      );
      
      // Parse the user from response
      final userMap = response['user'] as Map<String, dynamic>? ?? {};
      final user = User.fromJson(userMap);
      
      // Save tokens and user data locally
      await localDataSource.saveAccessToken(response['access_token'] as String? ?? '');
      await localDataSource.saveRefreshToken(response['refresh_token'] as String? ?? '');
      await localDataSource.saveUser(jsonEncode(user.toJson()));
      
      return Right(user);
    } catch (e) {
      return Left(Failure('خطا در تأیید کد: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      
      if (refreshToken == null) {
        return Left(Failure('توکن رفرش موجود نیست'));
      }
      
      final response = await remoteDataSource.refreshToken(refreshToken);
      final newAccessToken = response['access_token'] as String? ?? '';
      
      await localDataSource.saveAccessToken(newAccessToken);
      
      return Right(newAccessToken);
    } catch (e) {
      return Left(Failure('خطا در بروزرسانی توکن: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      // Clear local data even if server logout fails
      await localDataSource.clearAll();
      return Left(Failure('خطا در خروج: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final response = await remoteDataSource.getCurrentUser();
      final user = User.fromJson(response);
      return Right(user);
    } catch (e) {
      return Left(Failure('خطا در دریافت اطلاعات کاربر: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? avatarUrl,
    String? city,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      if (city != null) data['city'] = city;
      
      await remoteDataSource.updateProfile(data);
      return const Right(null);
    } catch (e) {
      return Left(Failure('خطا در بروزرسانی پروفایل: ${e.toString()}'));
    }
  }
  
  @override
  bool isLoggedIn() {
    final token = localDataSource.getAccessToken();
    return token != null && token.isNotEmpty;
  }
  
  @override
  Future<void> clearSession() async {
    await localDataSource.clearAll();
  }
}
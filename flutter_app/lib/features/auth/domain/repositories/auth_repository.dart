import '../entities/user.dart';
import 'package:dartz/dartz.dart';
import '../../domain/usecases/base_use_case.dart'; 
abstract class AuthRepository {
  Future<Either<Failure, void>> sendOtp(String phone);
  
  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String otp,
    required String deviceId,
  });
  
  Future<Either<Failure, String>> refreshToken();
  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, User>> getCurrentUser();
  
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? avatarUrl,
    String? city,
  });
  
  bool isLoggedIn();
  
  Future<void> clearSession();
}

class AuthResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;
  
  const AuthResult.success(this.data)
      : isSuccess = true,
        error = null;
  
  const AuthResult.error(this.error)
      : isSuccess = false,
        data = null;
}
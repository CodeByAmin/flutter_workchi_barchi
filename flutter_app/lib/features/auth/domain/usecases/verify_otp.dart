import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'base_use_case.dart';

class VerifyOtpParams {
  final String phone;
  final String otp;
  final String deviceId;
  
  const VerifyOtpParams({
    required this.phone,
    required this.otp,
    required this.deviceId,
  });
}

class VerifyOtp implements UseCase<User, VerifyOtpParams> {
  final AuthRepository repository;
  
  VerifyOtp(this.repository);
  
  @override
  Future<Either<Failure, User>> execute(VerifyOtpParams params) async {
    try {
      final result = await repository.verifyOtp(
        phone: params.phone,
        otp: params.otp,
        deviceId: params.deviceId,
      );
      return result;
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
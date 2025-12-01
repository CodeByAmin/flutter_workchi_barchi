import 'package:dartz/dartz.dart';
import '../../domain/repositories/auth_repository.dart';
import 'base_use_case.dart';

class SendOtp implements UseCase<void, String> {
  final AuthRepository repository;
  
  SendOtp(this.repository);
  
  @override
  Future<Either<Failure, void>> execute(String phone) async {
    try {
      final result = await repository.sendOtp(phone);
      return result;
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
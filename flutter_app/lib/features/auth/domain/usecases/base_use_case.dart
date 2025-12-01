import 'package:dartz/dartz.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> execute(Params params);
}

class NoParams {}

class Failure {
  final String message;
  final int? code;
  
  const Failure(this.message, {this.code});
  
  @override
  String toString() => 'Failure: $message';
}
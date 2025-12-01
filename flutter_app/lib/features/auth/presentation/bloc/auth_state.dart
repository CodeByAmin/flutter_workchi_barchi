import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/base_use_case.dart'; 
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSent extends AuthState {}

class OtpVerified extends AuthState {
  final User user;
  
  const OtpVerified(this.user);
  
  @override
  List<Object> get props => [user];
}

class ProfileUpdated extends AuthState {
  final User user;
  
  const ProfileUpdated(this.user);
  
  @override
  List<Object> get props => [user];
}

class AuthError extends AuthState {
  final Failure failure;
  
  const AuthError(this.failure);
  
  @override
  List<Object> get props => [failure];
}

class LoggedOut extends AuthState {}

class Authenticated extends AuthState {
  final User user;
  
  const Authenticated(this.user);
  
  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}
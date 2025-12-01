import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object> get props => [];
}

class SendOtpEvent extends AuthEvent {
  final String phone;
  
  const SendOtpEvent(this.phone);
  
  @override
  List<Object> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;
  final String deviceId;
  
  const VerifyOtpEvent({
    required this.phone,
    required this.otp,
    required this.deviceId,
  });
  
  @override
  List<Object> get props => [phone, otp, deviceId];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class UpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? avatarUrl;
  final String? city;
  
  const UpdateProfileEvent({
    this.name,
    this.avatarUrl,
    this.city,
  });
  
  @override
  List<Object> get props => [
    if (name != null) name!,
    if (avatarUrl != null) avatarUrl!,
    if (city != null) city!,
  ];
}
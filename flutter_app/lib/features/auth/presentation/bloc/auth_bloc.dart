import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../core/di.dart';
import '../../domain/repositories/auth_repository.dart';
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtp sendOtp;
  final VerifyOtp verifyOtp;
  
  
 AuthBloc({required this.sendOtp, required this.verifyOtp}) 
      : super(AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }
  
  void _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await sendOtp.execute(event.phone);
    
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) => emit(OtpSent()),
    );
  }
  
 Future<void> _onVerifyOtp(
  VerifyOtpEvent event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());
  
  final result = await verifyOtp.execute(VerifyOtpParams(
    phone: event.phone,
    otp: event.otp,
    deviceId: event.deviceId,
  ));
  
  result.fold(
    (failure) => emit(AuthError(failure)),
    (user) => emit(OtpVerified(user)), // Directly use User, not user.user
  );
}
  
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Call logout through repository
    final authRepo = sl<AuthRepository>();
    await authRepo.logout();
    
    emit(LoggedOut());
  }
  
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final authRepo = sl<AuthRepository>();
    
    if (authRepo.isLoggedIn()) {
      final result = await authRepo.getCurrentUser();
      
      result.fold(
        (failure) => emit(Unauthenticated()),
        (user) => emit(Authenticated(user)),
      );
    } else {
      emit(Unauthenticated());
    }
  }
  
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final authRepo = sl<AuthRepository>();
    final result = await authRepo.updateProfile(
      name: event.name,
      avatarUrl: event.avatarUrl,
      city: event.city,
    );
    
    result.fold(
      (failure) => emit(AuthError(failure)),
      (_) {
        // Get updated user
        // In real app, you'd fetch the updated user
        // For now, emit current state
        final currentUser = (state as Authenticated).user;
        emit(ProfileUpdated(currentUser));
      },
    );
  }
}
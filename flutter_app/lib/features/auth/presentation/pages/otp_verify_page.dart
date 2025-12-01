import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/constants.dart';
import '../../../../core/di.dart';
import '../../data/auth_local_data_source.dart';  // Add this import
import '../../../../shared_widgets/otp_field.dart';

class OtpVerifyPage extends StatefulWidget {
  final String phone;
  
  const OtpVerifyPage({super.key, required this.phone});
  
  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  int _remainingSeconds = AppConstants.otpTimeoutSeconds;
  late Timer _timer;
  bool _canResend = false;
  
  @override
  void initState() {
    super.initState();
    _startTimer();
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }
  
  void _verifyOtp() async {
    if (_otpController.text.length != AppConstants.otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفا کد ۶ رقمی را کامل وارد کنید'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final deviceId = await sl<AuthLocalDataSource>().getDeviceId();
    
    context.read<AuthBloc>().add(
      VerifyOtpEvent(
        phone: widget.phone,
        otp: _otpController.text,
        deviceId: deviceId,
      ),
    );
  }
  
  void _resendOtp() {
    if (_canResend) {
      context.read<AuthBloc>().add(SendOtpEvent(widget.phone));
      setState(() {
        _remainingSeconds = AppConstants.otpTimeoutSeconds;
        _canResend = false;
      });
      _startTimer();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              setState(() => _isLoading = true);
            } else if (state is OtpVerified) {
              setState(() => _isLoading = false);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.roleSelection,
                (route) => false,
              );
            } else if (state is AuthError) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure.message),  // Fixed: use failure.message
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                
                const SizedBox(height: 20),
                
                // Header
                Text(
                  'کد تایید',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    children: [
                      const TextSpan(text: 'کد ارسال شده به شماره '),
                      TextSpan(
                        text: widget.phone,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' را وارد کنید'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // OTP Input
                Center(
                  child: OtpField(
                    length: AppConstants.otpLength,
                    controller: _otpController,
                    onCompleted: (value) => _verifyOtp(),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'تایید و ادامه',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const Spacer(),
                
                // Resend OTP
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _canResend ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _canResend ? _resendOtp : null,
                        child: Text(
                          _canResend ? 'ارسال مجدد کد' : 'ارسال مجدد',
                          style: TextStyle(
                            color: _canResend ? AppColors.secondary : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
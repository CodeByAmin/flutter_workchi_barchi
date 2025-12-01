import 'package:dio/dio.dart';


abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> sendOtp(String phone);
  
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String deviceId,
  });
  
  Future<Map<String, dynamic>> refreshToken(String refreshToken);
  
  Future<void> logout();
  
  Future<Map<String, dynamic>> getCurrentUser();
  
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  
  AuthRemoteDataSourceImpl({required this.dio});
  
  @override
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await dio.post(
      '/auth/send-otp',
      data: {'phone': phone},
    );
    
    return response.data;
  }
  
  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String deviceId,
  }) async {
    final response = await dio.post(
      '/auth/verify-otp',
      data: {
        'phone': phone,
        'otp': otp,
        'device_id': deviceId,
      },
    );
    
    return response.data;
  }
  
  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    
    return response.data;
  }
  
  @override
  Future<void> logout() async {
    await dio.post('/auth/logout');
  }
  
  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await dio.get('/user/me');
    return response.data;
  }
  
  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await dio.put('/user/me', data: data);
    return response.data;
  }
}
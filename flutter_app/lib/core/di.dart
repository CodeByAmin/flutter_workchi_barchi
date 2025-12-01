import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../features/auth/data/auth_local_data_source.dart';
import '../features/auth/data/auth_remote_data_source.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/send_otp.dart';
import '../features/auth/domain/usecases/verify_otp.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'constants.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  
  sl.registerLazySingleton(() => FlutterSecureStorage());
  sl.registerLazySingleton(() => DeviceInfoPlugin()); // Removed the first Dio() registration
  
  // Core - Create Dio with interceptors in one registration
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Create and add the interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add authorization header
        final token = sl<AuthLocalDataSource>().getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Add app signature header for security
        options.headers['X-App-Key'] = _generateAppSignature();
        
        // Add device info
        options.headers['X-Device-ID'] = sl<AuthLocalDataSource>().getDeviceId();
        options.headers['X-Device-Type'] = 'mobile';
        options.headers['X-App-Version'] = '1.0.0';
        
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token refresh
        if (error.response?.statusCode == 401) {
          try {
            final newToken = await sl<AuthRepository>().refreshToken();
            if (newToken != null) {
              // Retry the original request
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    ));
    
    return dio;
  });
  
  // Data Sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
      sharedPreferences: sl(),
      deviceInfoPlugin: sl(),
    ),
  );
  
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  
  // Use Cases
  sl.registerLazySingleton<SendOtp>(() => SendOtp(sl()));
  sl.registerLazySingleton<VerifyOtp>(() => VerifyOtp(sl()));
  
  // Bloc
  sl.registerFactory(() => AuthBloc(
    sendOtp: sl(),
    verifyOtp: sl(),
  ));
}
String _generateAppSignature() {
  // In production, this should be a hash of app secret + timestamp
  const appSecret = 'your-app-secret-change-in-production';
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  // Simple hash for demonstration
  return '${appSecret.hashCode}_$timestamp';
}
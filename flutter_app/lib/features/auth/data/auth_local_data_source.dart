import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

abstract class AuthLocalDataSource {
  Future<String> getDeviceId();
  
  Future<void> saveAccessToken(String token);
  String? getAccessToken();
  
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  
  Future<void> saveUser(String userJson);
  String? getUser();
  
  Future<void> clearAll();
  
  Future<void> saveSelectedRole(String role);
  String? getSelectedRole();
  
  Future<void> saveSelectedCity(String city);
  String? getSelectedCity();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;
  final DeviceInfoPlugin deviceInfoPlugin;
  final Uuid uuid = const Uuid();
  
  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
    required this.deviceInfoPlugin,
  });
  
  @override
  Future<String> getDeviceId() async {
    String? deviceId = sharedPreferences.getString('device_id');
    
    if (deviceId == null) {
      // Generate a unique device ID
      final deviceInfo = await deviceInfoPlugin.deviceInfo;
      final baseId = deviceInfo.data.toString().hashCode.toString();
      deviceId = '${baseId}_${uuid.v4().substring(0, 8)}';
      
      await sharedPreferences.setString('device_id', deviceId);
    }
    
    return deviceId;
  }
  
  @override
  Future<void> saveAccessToken(String token) async {
    await sharedPreferences.setString('access_token', token);
  }
  
  @override
  String? getAccessToken() {
    return sharedPreferences.getString('access_token');
  }
  
  @override
  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: 'refresh_token', value: token);
  }
  
  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: 'refresh_token');
  }
  
  @override
  Future<void> saveUser(String userJson) async {
    await sharedPreferences.setString('user_data', userJson);
  }
  
  @override
  String? getUser() {
    return sharedPreferences.getString('user_data');
  }
  
  @override
  Future<void> clearAll() async {
    await secureStorage.deleteAll();
    await sharedPreferences.clear();
  }
  
  @override
  Future<void> saveSelectedRole(String role) async {
    await sharedPreferences.setString('selected_role', role);
  }
  
  @override
  String? getSelectedRole() {
    return sharedPreferences.getString('selected_role');
  }
  
  @override
  Future<void> saveSelectedCity(String city) async {
    await sharedPreferences.setString('selected_city', city);
  }
  
  @override
  String? getSelectedCity() {
    return sharedPreferences.getString('selected_city');
  }
}
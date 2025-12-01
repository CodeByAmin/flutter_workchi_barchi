import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String phone;
  final String? name;
  final String? avatarUrl;
  final String role;
  final String? city;
  final String verificationStatus;
  final double ratingAvg;
  final int ratingCount;
  final DateTime? lastSeen;
  final DateTime createdAt;
  
  const User({
    required this.id,
    required this.phone,
    this.name,
    this.avatarUrl,
    required this.role,
    this.city,
    this.verificationStatus = 'optional',
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    this.lastSeen,
    required this.createdAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'worker',
      city: json['city'],
      verificationStatus: json['verification_status'] ?? 'optional',
      ratingAvg: (json['rating_avg'] ?? 0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'avatar_url': avatarUrl,
      'role': role,
      'city': city,
      'verification_status': verificationStatus,
      'rating_avg': ratingAvg,
      'rating_count': ratingCount,
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  User copyWith({
    String? id,
    String? phone,
    String? name,
    String? avatarUrl,
    String? role,
    String? city,
    String? verificationStatus,
    double? ratingAvg,
    int? ratingCount,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      city: city ?? this.city,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  bool get isWorker => role == 'worker';
  bool get isEmployer => role == 'employer';
  bool get isAdmin => role == 'admin';
  
  bool get isVerified => verificationStatus == 'verified';
  
  @override
  List<Object?> get props => [
    id,
    phone,
    name,
    avatarUrl,
    role,
    city,
    verificationStatus,
    ratingAvg,
    ratingCount,
    lastSeen,
    createdAt,
  ];
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final User user;
  
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'user': user.toJson(),
    };
  }
}
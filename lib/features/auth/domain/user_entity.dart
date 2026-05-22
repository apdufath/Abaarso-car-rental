import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  customer,
  admin,
  driver;

  String get name {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.admin:
        return 'admin';
      case UserRole.driver:
        return 'driver';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'driver':
        return UserRole.driver;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }
}

class UserEntity {
  final String uid;
  final String fullName;
  final String phone;
  final String? email;
  final String? profileImageUrl;
  final UserRole role;
  final String? licenseImageUrl;
  final String? idCardImageUrl;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserEntity({
    required this.uid,
    required this.fullName,
    required this.phone,
    this.email,
    this.profileImageUrl,
    required this.role,
    this.licenseImageUrl,
    this.idCardImageUrl,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  UserEntity copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? profileImageUrl,
    UserRole? role,
    String? licenseImageUrl,
    String? idCardImageUrl,
    bool? isVerified,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      uid: uid,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      licenseImageUrl: licenseImageUrl ?? this.licenseImageUrl,
      idCardImageUrl: idCardImageUrl ?? this.idCardImageUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'role': role.name,
      'licenseImageUrl': licenseImageUrl,
      'idCardImageUrl': idCardImageUrl,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map['uid'] as String,
      fullName: map['fullName'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      role: UserRole.fromString(map['role'] as String? ?? 'customer'),
      licenseImageUrl: map['licenseImageUrl'] as String?,
      idCardImageUrl: map['idCardImageUrl'] as String?,
      isVerified: map['isVerified'] as bool? ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

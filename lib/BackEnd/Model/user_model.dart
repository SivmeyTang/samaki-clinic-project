import 'package:flutter/foundation.dart';

class UserModel {
  final int userId;
  final String userName;
  final String email;
  final String passwordHash;
  final bool uStatus;
  final int type;
  final String userFullName;
  final String telephone;
  final DateTime createdDate;
  final DateTime lastModifiedDate;

  UserModel({
    required this.userId,
    required this.userName,
    required this.email,
    required this.passwordHash,
    required this.uStatus,
    required this.type,
    required this.userFullName,
    required this.telephone,
    required this.createdDate,
    required this.lastModifiedDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return UserModel(
      userId: json['UserId'] ?? 0,
      userName: json['UserName'] ?? '',
      email: json['Email'] ?? '',
      passwordHash: json['PasswordHash'] ?? '',
      uStatus: json['Ustatus'] ?? false,
      type: json['Type'] ?? 0,
      userFullName: json['UserFullName'] ?? '',
      telephone: json['Telephone'] ?? '',
      createdDate: parseDate(json['CreatedDate']),
      lastModifiedDate: parseDate(json['LastModifiedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'UserName': userName,
      'Email': email,
      'PasswordHash': passwordHash,
      'Ustatus': uStatus,
      'Type': type,
      'UserFullName': userFullName,
      'Telephone': telephone,
      'CreatedDate': createdDate.toIso8601String(),
      'LastModifiedDate': lastModifiedDate.toIso8601String(),
    };
  }
}

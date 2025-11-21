import 'package:flutter/material.dart';

class User {
  final int id;
  final String? username;
  final String? password; // Biasanya tidak disimpan di model setelah login
  final String? role;

  User({
    required this.id,
    this.username,
    this.password,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // 💡 PERBAIKAN: Safely parse 'id' untuk menghindari error "Null is not a subtype of int"
    final idValue = json['id'];
    int parsedId = 0;

    if (idValue != null) {
      if (idValue is int) {
        parsedId = idValue;
      } else if (idValue is num) {
        // Mengatasi kasus jika ID dikirim sebagai double (misalnya 1.0)
        parsedId = idValue.toInt();
      } else if (idValue is String) {
        // Mengatasi kasus jika ID dikirim sebagai string
        parsedId = int.tryParse(idValue) ?? 0;
      }
    }
    
    return User(
      id: parsedId, // Menggunakan ID yang sudah dipastikan berupa int
      username: json['username'] as String?,
      // Password dihilangkan dari fromJson karena tidak pernah diterima dari API
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    // "password": password, // Jangan kirim password
    "role": role,
  };
}
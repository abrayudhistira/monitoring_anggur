import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:monitoring_anggur/core/model/userModel.dart';
import 'package:monitoring_anggur/core/services/api_services.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  // --- Login ---
  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseURL/login'),
        headers: ApiService.getAuthHeaders(null),
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] as String;
        final userData = User.fromJson(data['user']).toJson();

        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _userKey, value: json.encode(userData));

        return token;
      } else if (response.statusCode == 401) {
        // KHUSUS HANDLE 401: Invalid Credentials
        throw Exception('Username atau Password salah');
      } else {
        // Handle error lainnya (500, 404, dll)
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal melakukan login');
      }
    } catch (e) {
      // Menangkap error koneksi (misal server mati / tidak ada internet)
      if (e.toString().contains('SocketException')) {
        throw Exception('Tidak ada koneksi internet');
      }
      rethrow;
    }
  }

  // --- Logout ---
  Future<void> logout(String token) async {
    // await http.post(
    //   Uri.parse('$baseURL/logout'),
    //   headers: ApiService.getAuthHeaders(token),
    //   body: json.encode({
    //     // Sesuaikan jika backend Anda memerlukan body tertentu untuk logout
    //   }),
    // );

    // Clear storage regardless of API response success (for safety)
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // --- Token and User Getter ---
  Future<String?> getToken() async => await _storage.read(key: _tokenKey);

  Future<User?> getLoggedInUser() async {
    final userDataJson = await _storage.read(key: _userKey);
    if (userDataJson == null) return null;
    return User.fromJson(json.decode(userDataJson));
  }
}

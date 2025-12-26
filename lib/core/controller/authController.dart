import 'package:flutter/foundation.dart';
import 'package:monitoring_anggur/core/model/userModel.dart';
import 'package:monitoring_anggur/core/services/auth_services.dart';
import 'package:monitoring_anggur/core/services/socket_services.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();
  final SocketService _socketService;

  User? _user;
  String? _token;
  bool _isLoading = true;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthController(this._socketService) {
    _checkAuthStatus();
  }

  // Memeriksa token saat aplikasi dimulai
  Future<void> _checkAuthStatus() async {
    _token = await _authService.getToken();
    _user = await _authService.getLoggedInUser();

    if (_token != null && _user != null) {
      _socketService.initSocket(_token!); // Inisialisasi Socket jika token ada
    }
    _isLoading = false;
    notifyListeners();
  }

  // --- Login ---
  Future<void> login(String username, String password) async {
    // HAPUS baris ini:
    // _isLoading = true;
    // notifyListeners();

    // PENJELASAN:
    // Jangan set _isLoading global di sini. Biarkan LoginView yang mengatur
    // loading state (spinner di tombol) secara lokal menggunakan setState.
    // Jika Anda set _isLoading = true di sini, main.dart akan me-rebuild
    // dan mematikan LoginView sebelum error sempat muncul.

    try {
      final token = await _authService.login(username, password);
      _token = token;
      _user = await _authService.getLoggedInUser();

      if (_token != null) {
        _socketService.initSocket(_token!);
      }

      // PENTING: Hanya notifyListeners JIKA SUKSES.
      // Ini akan memberitahu main.dart untuk pindah dari LoginView ke HomeView.
      notifyListeners();
    } catch (e) {
      print('Login Gagal: $e');
      _user = null;
      _token = null;

      // HAPUS notifyListeners() di catch/finally agar main.dart tidak kedip
      rethrow; // Lempar error kembali ke LoginView agar ditangkap catch di sana
    }
    // HAPUS finally block yang mengubah _isLoading = false
  }

  // --- Logout ---
  Future<void> logout() async {
    if (_token != null) {
      await _authService.logout(_token!);
    }
    _socketService.disconnect(); // Putuskan koneksi Socket

    _user = null;
    _token = null;
    notifyListeners();
  }

  String? getToken() => _token;
}

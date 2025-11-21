import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:monitoring_anggur/core/controller/authController.dart';
import 'package:monitoring_anggur/core/model/settingModel.dart';
import 'package:monitoring_anggur/core/model/suhuhModel.dart';
import 'package:monitoring_anggur/core/services/api_services.dart';
import 'package:monitoring_anggur/core/services/socket_services.dart';

// class SettingController with ChangeNotifier {
//   final SocketService _socketService;
//   final AuthController _authController;
  
//   Setting? _currentSetting;
//   Suhu? _latestSuhu;
//   StreamSubscription? _settingSubscription;
//   StreamSubscription? _suhuSubscription;

//   Setting? get currentSetting => _currentSetting;
//   Suhu? get latestSuhu => _latestSuhu;

//   SettingController(this._socketService, this._authController) {
//     _listenToSettingUpdates();
//     _listenToSuhuUpdates();
//     // Fetch initial setting status only after auth status is known
//     if (_authController.isAuthenticated) {
//       fetchInitialSetting();
//     }
//   }

//   // --- Socket Listeners ---
//   void _listenToSettingUpdates() {
//     _settingSubscription?.cancel();
//     _settingSubscription = _socketService.settingStream.listen((setting) {
//       _currentSetting = setting;
//       print("Real-time Setting Update: ${setting.status}");
//       notifyListeners();
//     });
//   }

//   void _listenToSuhuUpdates() {
//     _suhuSubscription?.cancel();
//     _suhuSubscription = _socketService.suhuStream.listen((suhu) {
//       _latestSuhu = suhu;
//       print("Real-time Suhu Update: ${suhu.humidity}");
//       notifyListeners();
//     });
//   }


//   // --- HTTP GET (Initial Fetch) ---
//   Future<void> fetchInitialSetting() async {
//     final token = _authController.getToken();
//     if (token == null) return;

//     final response = await http.get(
//       Uri.parse('$baseURL/setting/status'),
//       headers: ApiService.getAuthHeaders(token),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body)['data'];
//       _currentSetting = Setting.fromJson(data as Map<String, dynamic>);
//       notifyListeners();
//     } else {
//       print('Gagal mengambil setting awal: ${response.body}');
//       _currentSetting = Setting(namaSetting: 'main_status', status: 'UNKNOWN');
//       notifyListeners();
//     }
//   }

//   // --- HTTP PUT (Control Update) ---
//   Future<void> updateSetting(String status) async {
//     final token = _authController.getToken();
//     if (token == null || (status != 'ON' && status != 'OFF')) return;

//     // Optimistic Update: Perbarui UI sebelum respons (opsional)
//     final oldStatus = _currentSetting?.status;
//     _currentSetting = Setting(
//       namaSetting: _currentSetting?.namaSetting ?? 'main_status',
//       status: status,
//       updatedAt: DateTime.now(),
//     );
//     notifyListeners();

//     try {
//       final response = await http.put(
//         Uri.parse('$baseURL/setting/status'),
//         headers: ApiService.getAuthHeaders(token),
//         body: json.encode({'status': status}),
//       );

//       if (response.statusCode != 200) {
//         // Rollback jika update gagal
//         _currentSetting = Setting(
//             namaSetting: _currentSetting!.namaSetting,
//             status: oldStatus ?? 'UNKNOWN');
//         notifyListeners();
//         final errorData = json.decode(response.body);
//         throw Exception(errorData['message'] ?? 'Gagal mengubah status');
//       }
      
//       // Jika berhasil, data setting_update akan datang melalui Socket
//       // Namun, jika Socket lambat, kita bisa mengandalkan respons HTTP
//       final data = json.decode(response.body)['data'];
//       _currentSetting = Setting.fromJson(data as Map<String, dynamic>);
      
//     } catch (e) {
//       print('Update Setting Gagal: $e');
//       rethrow;
//     } finally {
//       notifyListeners();
//     }
//   }
  
//   @override
//   void dispose() {
//     _settingSubscription?.cancel();
//     _suhuSubscription?.cancel();
//     super.dispose();
//   }
// }

class SettingController with ChangeNotifier {
  final SocketService _socketService;
  final AuthController _authController;
  
  // 💡 Dua Setting Baru
  Setting? _valveSetting;
  Setting? _modeSetting;
  
  Suhu? _latestSuhu;
  StreamSubscription? _settingSubscription;
  StreamSubscription? _suhuSubscription;

  // 💡 Getters Baru
  Setting? get valveSetting => _valveSetting;
  Setting? get modeSetting => _modeSetting;
  Suhu? get latestSuhu => _latestSuhu;

  SettingController(this._socketService, this._authController) {
    _listenToSettingUpdates();
    _listenToSuhuUpdates();
    // Fetch initial setting status only after auth status is known
    if (_authController.isAuthenticated) {
      fetchInitialSettings();
    }
  }

  // --- Socket Listeners ---
  void _listenToSettingUpdates() {
    _settingSubscription?.cancel();
    _settingSubscription = _socketService.settingStream.listen((setting) {
      // 💡 Pisahkan setting berdasarkan namaSetting
      if (setting.namaSetting == 'Valve') {
        _valveSetting = setting;
      } else if (setting.namaSetting == 'Valve_Mode') {
        _modeSetting = setting;
      }
      print("Real-time Setting Update (${setting.namaSetting}): ${setting.status}");
      notifyListeners();
    });
  }

  void _listenToSuhuUpdates() {
    _suhuSubscription?.cancel();
    _suhuSubscription = _socketService.suhuStream.listen((suhu) {
      _latestSuhu = suhu;
      print("Real-time Suhu Update: ${suhu.humidity}");
      notifyListeners();
    });
  }


  // --- HTTP GET (Initial Fetch) ---
  Future<void> fetchInitialSettings() async {
    final token = _authController.getToken();
    if (token == null) return;

    // 💡 Menggunakan endpoint baru '/all'
    final response = await http.get(
      Uri.parse('$baseURL/setting/all'),
      headers: ApiService.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final List dataList = json.decode(response.body)['data'] as List;
      
      for (var data in dataList) {
        final setting = Setting.fromJson(data as Map<String, dynamic>);
        if (setting.namaSetting == 'Valve') {
          _valveSetting = setting;
        } else if (setting.namaSetting == 'Valve_Mode') {
          _modeSetting = setting;
        }
      }
      notifyListeners();
    } else {
      print('Gagal mengambil setting awal: ${response.body}');
      // Fallback settings
      _valveSetting = Setting(namaSetting: 'Valve', status: 'UNKNOWN');
      _modeSetting = Setting(namaSetting: 'Valve_Mode', status: 'UNKNOWN');
      notifyListeners();
    }
  }

  // --- HTTP PUT: Update Status Valve (Manual) ---
  Future<void> updateValveStatus(String status) async {
    final token = _authController.getToken();
    if (token == null || (status != 'ON' && status != 'OFF')) return;

    // Optimistic Update: Perbarui UI sebelum respons (opsional)
    final oldStatus = _valveSetting?.status;
    _valveSetting = Setting(
      namaSetting: _valveSetting?.namaSetting ?? 'Valve',
      status: status,
      updatedAt: DateTime.now(),
    );
    notifyListeners();

    try {
      // 💡 Menggunakan endpoint baru '/valve'
      final response = await http.put(
        Uri.parse('$baseURL/setting/valve'),
        headers: ApiService.getAuthHeaders(token),
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        // Rollback jika update gagal
        _valveSetting = Setting(
            namaSetting: _valveSetting!.namaSetting,
            status: oldStatus ?? 'UNKNOWN');
        notifyListeners();
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal mengubah status Valve');
      }
      
      // Data update akan datang melalui Socket (atau dari respons HTTP jika socket lambat)
      final data = json.decode(response.body)['data'];
      if (data['namaSetting'] == 'Valve') {
        _valveSetting = Setting.fromJson(data as Map<String, dynamic>);
      }
      
    } catch (e) {
      print('Update Valve Status Gagal: $e');
      rethrow;
    } finally {
      notifyListeners();
    }
  }
  
  // --- HTTP PUT: Update Status Mode (Auto/Manual) ---
  Future<void> updateModeStatus(String status) async {
    final token = _authController.getToken();
    if (token == null || (status != 'Auto' && status != 'Manual')) return;

    // Tambahkan Optimistic Update untuk Mode
    final oldStatus = _modeSetting?.status;
    _modeSetting = Setting(
      namaSetting: _modeSetting?.namaSetting ?? 'Valve_Mode',
      status: status,
      updatedAt: DateTime.now(),
    );
    notifyListeners();

    try {
      // 💡 Menggunakan endpoint baru '/mode'
      final response = await http.put(
        Uri.parse('$baseURL/setting/mode'),
        headers: ApiService.getAuthHeaders(token),
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal mengubah mode kontrol');
      }
      
      // Data update akan datang melalui Socket (atau dari respons HTTP jika socket lambat)
      final data = json.decode(response.body)['data'];
      if (data['namaSetting'] == 'Valve_Mode') {
        _modeSetting = Setting.fromJson(data as Map<String, dynamic>);
      }
      
    } catch (e) {
      print('Update Mode Status Gagal: $e');
      rethrow;
    } finally {
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _settingSubscription?.cancel();
    _suhuSubscription?.cancel();
    super.dispose();
  }
}
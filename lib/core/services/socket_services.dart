import 'dart:async';
import 'package:flutter/material.dart';
import 'package:monitoring_anggur/core/model/settingModel.dart';
import 'package:monitoring_anggur/core/model/suhuhModel.dart';
import 'package:monitoring_anggur/core/services/api_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum SocketConnectionStatus {
  idle,
  connecting,
  connected,
  disconnected, 
  noInternet,   
}

class SocketService extends ChangeNotifier {
  io.Socket? _socket;
  
  // Stream Controllers
  final _settingController = StreamController<Setting>.broadcast();
  Stream<Setting> get settingStream => _settingController.stream;

  final _suhuController = StreamController<Suhu>.broadcast();
  Stream<Suhu> get suhuStream => _suhuController.stream;

  SocketConnectionStatus _status = SocketConnectionStatus.idle;
  SocketConnectionStatus get status => _status;

  // Notifikasi & Logika Flag
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();
  bool _isKlepOpenNotified = false; // Flag agar tidak spam notifikasi kering
  bool _isKlepClosedNotified = false; // Flag agar tidak spam notifikasi basah

  SocketService() {
    _initNotification();
  }

  // --- Inisialisasi Notifikasi Lokal ---
  Future<void> _initNotification() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSetting = InitializationSettings(android: androidInit);
    await _localNotif.initialize(initSetting);
  }

  // --- Fungsi Menampilkan Notifikasi Push ---
  Future<void> _showPushNotification(String title, String body) async {
    const androidDetail = AndroidNotificationDetails(
      'channel_anggur_id',
      'Monitoring Anggur',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const detail = NotificationDetails(android: androidDetail);
    await _localNotif.show(DateTime.now().millisecond, title, body, detail);
  }

  // --- Logika Pengecekan Ambang Batas Kelembaban ---
  void _analyzeHumidity(double humidity) {
    // 1. Kondisi Tanah Kering (Bawah 300)
    if (humidity < 300) {
      if (!_isKlepOpenNotified) {
        _showPushNotification(
          "Peringatan: Tanah Kering!",
          "Kelembaban ${humidity.toStringAsFixed(1)}. Sistem akan membuka klep otomatis."
        );
        _isKlepOpenNotified = true; // Kunci agar tidak kirim notif lagi
        _isKlepClosedNotified = false; // Reset status sebaliknya
      }
    } 
    // 2. Kondisi Tanah Basah (Atas 700)
    else if (humidity > 700) {
      if (!_isKlepClosedNotified) {
        _showPushNotification(
          "Info: Tanah Basah!",
          "Kelembaban ${humidity.toStringAsFixed(1)}. Sistem akan menutup klep otomatis."
        );
        _isKlepClosedNotified = true; // Kunci
        _isKlepOpenNotified = false; // Reset status sebaliknya
      }
    }
    // 3. Kondisi Normal (Antara 300 - 700)
    else {
      // Jika kembali ke kondisi normal, reset semua flag agar siap kirim notif lagi nantinya
      _isKlepOpenNotified = false;
      _isKlepClosedNotified = false;
    }
  }

  void _setStatus(SocketConnectionStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    notifyListeners();
  }

  Future<void> _checkFailureReason() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _setStatus(SocketConnectionStatus.noInternet);
    } else {
      _setStatus(SocketConnectionStatus.disconnected);
    }
  }

  void initSocket(String token) {
    if (_socket != null && _socket!.connected) return;

    _setStatus(SocketConnectionStatus.connecting);

    try {
      _socket = io.io(
        baseURL,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setQuery({'token': token})
            .enableForceNew()
            .disableAutoConnect()
            .setReconnectionAttempts(5)
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        print('Socket Connected: ${_socket!.id}');
        _setStatus(SocketConnectionStatus.connected);
      });

      _socket!.onDisconnect((_) {
        _checkFailureReason();
      });

      _socket!.onConnectError((err) {
        _checkFailureReason();
      });

      _socket!.on('setting_update', (data) {
        final setting = Setting.fromJson(data as Map<String, dynamic>);
        _settingController.sink.add(setting);
      });

      _socket!.on('suhu_update', (data) {
        final suhu = Suhu.fromJson(data as Map<String, dynamic>);
        _suhuController.sink.add(suhu);

        // --- Panggil Fungsi Analisa Notifikasi ---
        _analyzeHumidity(suhu.humidity);
      });

    } catch (e) {
      _checkFailureReason();
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _setStatus(SocketConnectionStatus.idle);
  }

  @override
  void dispose() {
    _settingController.close();
    _suhuController.close();
    disconnect();
    super.dispose();
  }
}
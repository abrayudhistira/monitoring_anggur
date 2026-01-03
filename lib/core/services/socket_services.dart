import 'dart:async';
import 'package:flutter/material.dart';
import 'package:monitoring_anggur/core/model/settingModel.dart';
import 'package:monitoring_anggur/core/model/suhuhModel.dart';
import 'package:monitoring_anggur/core/services/api_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:connectivity_plus/connectivity_plus.dart'; // Tambahkan ini

enum SocketConnectionStatus {
  idle,
  connecting,
  connected,
  disconnected, // Ini akan kita anggap sebagai Server Down
  noInternet,   // Ini masalah koneksi pengguna
}

class SocketService extends ChangeNotifier {
  io.Socket? _socket;
  final _settingController = StreamController<Setting>.broadcast();
  Stream<Setting> get settingStream => _settingController.stream;

  final _suhuController = StreamController<Suhu>.broadcast();
  Stream<Suhu> get suhuStream => _suhuController.stream;

  SocketConnectionStatus _status = SocketConnectionStatus.idle;
  SocketConnectionStatus get status => _status;

  void _setStatus(SocketConnectionStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    notifyListeners();
  }

  // Fungsi untuk mengecek apakah masalahnya ada di Internet atau di Server
  Future<void> _checkFailureReason() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    
    // Jika tidak ada koneksi WiFi atau Mobile Data sama sekali
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _setStatus(SocketConnectionStatus.noInternet);
    } else {
      // Jika ada sinyal tapi socket tetap gagal, berarti Server Down
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
            .setReconnectionAttempts(5) // Coba recon berkala
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        print('Socket Connected: ${_socket!.id}');
        _setStatus(SocketConnectionStatus.connected);
      });

      _socket!.onDisconnect((_) {
        print('Socket Disconnected');
        _checkFailureReason();
      });

      _socket!.onConnectError((err) {
        print('Socket Connect Error: $err');
        _checkFailureReason();
      });

      _socket!.on('setting_update', (data) {
        final setting = Setting.fromJson(data as Map<String, dynamic>);
        _settingController.sink.add(setting);
      });

      _socket!.on('suhu_update', (data) {
        final suhu = Suhu.fromJson(data as Map<String, dynamic>);
        _suhuController.sink.add(suhu);
      });

    } catch (e) {
      print('Socket Initialization Error: $e');
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
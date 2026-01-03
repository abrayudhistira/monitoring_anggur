import 'dart:async';
import 'package:monitoring_anggur/core/model/settingModel.dart';
import 'package:monitoring_anggur/core/model/suhuhModel.dart';
import 'package:monitoring_anggur/core/services/api_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;

  // Stream Controllers untuk data real-time
  final _settingController = StreamController<Setting>.broadcast();
  Stream<Setting> get settingStream => _settingController.stream;

  final _suhuController = StreamController<Suhu>.broadcast();
  Stream<Suhu> get suhuStream => _suhuController.stream;

  void initSocket(String token) {
    if (_socket != null && _socket!.connected) {
      return; // Already connected
    }

    try {
      // Koneksi ke Socket.IO dengan mengirimkan JWT di query parameter
      _socket = io.io(
        baseURL,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setQuery({'token': token})
            .enableForceNew()
            .disableAutoConnect()
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        print('Socket Connected: ${_socket!.id}');
      });

      _socket!.on('setting_update', (data) {
        // Broadcast data setting baru
        final setting = Setting.fromJson(data as Map<String, dynamic>);
        _settingController.sink.add(setting);
      });

      _socket!.on('suhu_update', (data) {
        // Broadcast data suhu baru
        final suhu = Suhu.fromJson(data as Map<String, dynamic>);
        _suhuController.sink.add(suhu);
      });

      _socket!.onConnectError((err) => print('Socket Connect Error: $err'));
      _socket!.onError((err) => print('Socket Error: $err'));
      _socket!.onDisconnect((_) => print('Socket Disconnected'));

    } catch (e) {
      print('Socket Initialization Error: $e');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    _settingController.close();
    _suhuController.close();
    disconnect();
  }
}
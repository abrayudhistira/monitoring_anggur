import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:monitoring_anggur/core/services/api_services.dart';

class NotificationService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
        
    await _localNotifications.initialize(initializationSettings);

    // Buat High Importance Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id (SAMA DENGAN BACKEND)
      'High Importance Notifications', // title
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  // --- Fungsi Utama: Ambil Token & Kirim ke Backend ---
  Future<void> syncTokenToBackend() async {
    try {
      // 1. Ambil FCM Token dari Firebase
      String? fcmToken = await _fcm.getToken();
      if (fcmToken == null) return;

      // 2. Ambil JWT Token dari Storage (seperti di AuthService Anda)
      String? jwtToken = await _storage.read(key: 'jwt_token');
      if (jwtToken == null) {
        print("Gagal sync FCM: User belum login (JWT tidak ditemukan)");
        return;
      }

      // 3. Kirim ke Endpoint yang kita buat di Backend tadi
      final response = await http.post(
        Uri.parse('$baseURL/update-fcm'), // baseURL dari api_services.dart Anda
        headers: ApiService.getAuthHeaders(jwtToken),
        body: json.encode({'fcm_token': fcmToken}),
      );

      if (response.statusCode == 200) {
        print("FCM Token Berhasil Diperbarui di Backend");
      } else {
        print("Gagal update FCM: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error NotificationService: $e");
    }
  }

  // --- Setup Listener Foreground (Opsional) ---
  // Agar ketika aplikasi terbuka, notifikasi tetap muncul menggunakan Snackbar/Dialog
  void listenForegroundNotifications() { // <--- Hapus parameter di sini
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Menerima pesan foreground: ${message.notification?.title}");
    
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Jika notifikasi ada, tampilkan menggunakan local notifications
    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });
}
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:monitoring_anggur/core/controller/authController.dart';
import 'package:monitoring_anggur/core/controller/settingController.dart';
import 'package:monitoring_anggur/core/services/notification_service.dart';
import 'package:monitoring_anggur/core/services/socket_services.dart';
import 'package:monitoring_anggur/page/dashboard/dashboard.dart';
import 'package:monitoring_anggur/page/auth/login.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- TAMBAHKAN IMPORT INI ---
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Pastikan Firebase diinisialisasi di dalam handler background
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(seconds: 15)
      ..idleTimeout = const Duration(seconds: 15);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- INISIALISASI FIREBASE ---
  await Firebase.initializeApp();
  // 1. Inisialisasi Notification Service
  NotificationService notificationService = NotificationService();
  await notificationService.initLocalNotifications(); // Jalankan init local notif
  notificationService.listenForegroundNotifications(); // Jalankan listener foreground
  // Set background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Subscribe ke topik monitoring (agar bisa menerima push dari backend)
  await FirebaseMessaging.instance.subscribeToTopic('monitoring_anggur');

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await initializeDateFormatting('id_ID', null);
  HttpOverrides.global = MyHttpOverrides();

  final socketService = SocketService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SocketService>(
          create: (_) => socketService,
        ),
        ChangeNotifierProvider(
          create: (context) => AuthController(context.read<SocketService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingController(
            context.read<SocketService>(),
            context.read<AuthController>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IoT Dashboard',
      theme: ThemeData(primarySwatch: Colors.purple), // Sesuaikan tema ungu anggur
      home: Consumer<AuthController>(
        builder: (context, authController, child) {
          if (authController.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (authController.isAuthenticated) {
            return const HomeView();
          } else {
            return const LoginView();
          }
        },
      ),
    );
  }
}
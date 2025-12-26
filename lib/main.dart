import 'dart:io'; // <<-- tambah ini
import 'package:flutter/material.dart';
import 'package:monitoring_anggur/core/controller/authController.dart';
import 'package:monitoring_anggur/core/controller/settingController.dart';
import 'package:monitoring_anggur/core/services/socket_services.dart';
import 'package:monitoring_anggur/page/dashboard/dashboard.dart';
import 'package:monitoring_anggur/page/auth/login.dart';
import 'package:provider/provider.dart';

// OPTIONAL: custom HttpOverrides untuk set timeout / stabilitas koneksi
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(seconds: 15)
      ..idleTimeout = const Duration(seconds: 15);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // PASANG HttpOverrides global DI SINI (sebelum runApp)
  HttpOverrides.global = MyHttpOverrides();

  // Instance service yang akan di-share (Singleton)
  final socketService = SocketService();

  runApp(
    MultiProvider(
      providers: [
        // 1. Service Provider
        Provider<SocketService>(create: (_) => socketService),

        // 2. Auth Controller
        ChangeNotifierProvider(
          create: (context) => AuthController(
            context.read<SocketService>(),
          ),
        ),

        // 3. Setting Controller (membutuhkan AuthController dan SocketService)
        ChangeNotifierProvider(
          create: (context) => SettingController(
            context.read<SocketService>(),
            context.read<AuthController>(),
          ),
          // Set `lazy: false` jika Anda ingin kontroler ini fetch data di awal
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Konsumsi status otentikasi
      home: Consumer<AuthController>(
        builder: (context, authController, child) {
          if (authController.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (authController.isAuthenticated) {
            // Jika terotentikasi, tampilkan Home View
            return const HomeView();
          } else {
            // Jika tidak terotentikasi, tampilkan Login View
            return const LoginView();
          }
        },
      ),
    );
  }
}

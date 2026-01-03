import 'package:flutter/material.dart';
import 'package:monitoring_anggur/core/controller/authController.dart';
import 'package:monitoring_anggur/core/controller/settingController.dart';
import 'package:monitoring_anggur/core/services/socket_services.dart'; // Pastikan path ini sesuai
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  // Palet warna ungu anggur
  static const Color grapeDeep = Color(0xFF4A1942);
  static const Color grapePrimary = Color(0xFF6B2D5C);
  static const Color grapeAccent = Color(0xFF8B4789);
  static const Color grapeLight = Color(0xFFB57FB3);
  static const Color grapeSoft = Color(0xFFE8D4E7);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  SocketConnectionStatus? _lastStatus;

  @override
  Widget build(BuildContext context) {
    // --- Logika Socket Connection Snackbar ---
    final socketStatus = context.watch<SocketService>().status;

    if (_lastStatus != socketStatus) {
      _lastStatus = socketStatus;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSocketSnackbar(context, socketStatus);
      });
    }

    // --- Akses Controller ---
    final settingController = context.watch<SettingController>();
    final authController = context.read<AuthController>();

    // --- Persiapan Data UI ---
    final suhu = settingController.latestSuhu;

    // Data Valve
    final valveSetting = settingController.valveSetting;
    final valveStatus = valveSetting?.status ?? 'UNKNOWN';
    final valveStatusColor = valveStatus == 'ON'
        ? Colors.green.shade600
        : (valveStatus == 'OFF' ? Colors.red.shade600 : Colors.grey);
    final toggleValveLabel = valveStatus == 'ON' ? 'Matikan Valve' : 'Nyalakan Valve';
    final newValveStatus = valveStatus == 'ON' ? 'OFF' : 'ON';

    // Data Mode
    final modeSetting = settingController.modeSetting;
    final modeStatus = modeSetting?.status ?? 'UNKNOWN';
    final isAuto = modeStatus == 'Auto';
    final modeColor = isAuto ? Colors.orange.shade600 : Colors.blue.shade600;
    final modeToggleLabel = isAuto ? 'Ubah ke MANUAL' : 'Ubah ke AUTO';
    final newModeStatus = isAuto ? 'Manual' : 'Auto';

    // Status Disable
    final isValveDisabled = isAuto;

    return Scaffold(
      backgroundColor: HomeView.grapeSoft,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [HomeView.grapeDeep, HomeView.grapePrimary, HomeView.grapeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/smartgrape.id.png',
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SmartGrape.id',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Real-Time Monitoring',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: authController.logout,
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Header Section ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    HomeView.grapePrimary.withOpacity(0.8),
                    HomeView.grapeAccent.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: HomeView.grapePrimary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.spa, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text(
                    'Monitoring Anggur',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now()),
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Kelembaban Card ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.water_drop, size: 32, color: Colors.blue.shade700),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kelembaban Tanah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                              Text('Sensor Real-time', style: TextStyle(fontSize: 14, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            suhu != null ? '${suhu.humidity.toStringAsFixed(1)}H' : 'N/A',
                            style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: suhu != null ? Colors.green.shade50 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  suhu != null ? Icons.check_circle : Icons.pending,
                                  size: 16,
                                  color: suhu != null ? Colors.green.shade700 : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  suhu != null
                                      ? 'Update: ${DateFormat('dd MMM yyyy, HH:mm:ss').format((suhu.timestamp ?? DateTime.now()).toLocal())}'
                                      : 'Menunggu data sensor...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: suhu != null ? Colors.green.shade700 : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Mode Kontrol Section ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings_suggest_rounded, color: HomeView.grapeAccent, size: 24),
                        SizedBox(width: 8),
                        Text('Mode Kontrol', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: HomeView.grapeDeep)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [modeColor.withOpacity(0.1), modeColor.withOpacity(0.05)]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: modeColor, width: 2),
                      ),
                      child: Column(
                        children: [
                          Icon(isAuto ? Icons.smart_toy_rounded : Icons.pan_tool_alt_rounded, size: 48, color: modeColor),
                          const SizedBox(height: 12),
                          Text('Mode: $modeStatus', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: modeColor)),
                          const SizedBox(height: 8),
                          Text(
                            isAuto ? 'Sistem mengontrol valve secara otomatis' : 'Anda mengontrol valve secara manual',
                            style: TextStyle(fontSize: 13, color: modeColor.withOpacity(0.8)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => settingController.updateModeStatus(newModeStatus),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: modeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isAuto ? Icons.pan_tool_alt_rounded : Icons.smart_toy_rounded, size: 20),
                            const SizedBox(width: 12),
                            Text(modeToggleLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Kontrol Valve Section ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.water_rounded, color: HomeView.grapeAccent, size: 24),
                        SizedBox(width: 8),
                        Text('Status Valve', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: HomeView.grapeDeep)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [valveStatusColor.withOpacity(0.3), valveStatusColor.withOpacity(0.1)]),
                        boxShadow: [
                          BoxShadow(color: valveStatusColor.withOpacity(0.4), blurRadius: 20, spreadRadius: 5),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(valveStatus == 'ON' ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 48, color: valveStatusColor),
                            const SizedBox(height: 8),
                            Text(valveStatus, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valveStatusColor)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (isValveDisabled)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_rounded, color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Valve dikontrol otomatis. Ubah ke mode Manual untuk kontrol manual.',
                                style: TextStyle(fontSize: 12, color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isValveDisabled ? null : () => settingController.updateValveStatus(newValveStatus),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: valveStatusColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(valveStatus == 'ON' ? Icons.power_settings_new_rounded : Icons.power_rounded, size: 24),
                            const SizedBox(width: 12),
                            Text(toggleValveLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: HomeView.grapeSoft, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 16, color: HomeView.grapeAccent),
                          const SizedBox(width: 8),
                          Text(
                            valveSetting != null
                                ? 'Update: ${DateFormat('dd MMM yyyy, HH:mm:ss').format((valveSetting.updatedAt ?? DateTime.now()).toLocal())}'
                                : 'Loading Setting...',
                            style: const TextStyle(fontSize: 12, color: HomeView.grapeDeep, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                '© 2025 SmartGrape.id - All rights reserved.',
                style: TextStyle(fontSize: 12, color: HomeView.grapeAccent.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ganti fungsi _showSocketSnackbar Anda dengan ini:
  void _showSocketSnackbar(BuildContext context, SocketConnectionStatus status) {
    String message;
    Color color;
    IconData icon;

    switch (status) {
      case SocketConnectionStatus.connecting:
        message = 'Menghubungkan ke server...';
        color = Colors.blue.shade700;
        icon = Icons.sync;
        break;

      case SocketConnectionStatus.connected:
        message = 'Sistem Online - Tersambung';
        color = Colors.green.shade700;
        icon = Icons.wifi_tethering;
        break;

      case SocketConnectionStatus.disconnected:
        // Logika: Jika status disconnect tapi HP punya paket data, berarti Server Down
        message = 'Server Down / Terputus';
        color = Colors.red.shade900;
        icon = Icons.dns_rounded;
        break;

      case SocketConnectionStatus.noInternet: // Pastikan enum ini ada di SocketService Anda
        message = 'Tidak ada koneksi internet';
        color = Colors.black87;
        icon = Icons.signal_wifi_connected_no_internet_4_rounded;
        break;

      default:
        return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: color,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
  }
}